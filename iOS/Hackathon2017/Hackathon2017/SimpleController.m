//
//  SimpleController.m
//
//  Created by Yue Huang on 2015-09-01.
//  Copyright (c) 2015 InteraXon. All rights reserved.
//

#import "SimpleController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <HueSDK_iOS/HueSDK.h>

// Lifetracker imports
#import "SyncService.h"
#import "BLEWrapper.h"
#import "BLEDevice.h"
#import "BLEDevice+ReadWriteData.h"

@interface SimpleController () <CBCentralManagerDelegate>{
    SRWebSocket *_webSocketEeg;
    SRWebSocket *_webSocketArtifact;
    SRWebSocket *_webSocketHeartRate;
}
@property IXNMuseManagerIos * manager;
@property (weak, nonatomic) IXNMuse * muse;
@property (nonatomic) NSMutableArray* logLines;
@property (nonatomic) BOOL lastBlink;
@property (nonatomic) BOOL lastHeadbandon;
@property (nonatomic) BOOL lastJawclench;
@property (nonatomic, strong) CBCentralManager * btManager;
@property (atomic) BOOL btState;
@property (nonatomic) NSMutableArray* mellow;
@property (nonatomic, weak) BLEDevice *device; // weak - will be retained at lower level
@end

@implementation SimpleController
bool eegDataSending = false;
bool artifactDataSending = false;
bool heartRateDataSending = false;
bool httpDataSending = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    if (!self.manager) {
        self.manager = [IXNMuseManagerIos sharedManager];
    }
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.manager = [IXNMuseManagerIos sharedManager];
        [self.manager setMuseListener:self];
        self.tableView = [[UITableView alloc] init];

        self.logView = [[UITextView alloc] init];
        self.logLines = [NSMutableArray array];
        [self.logView setText:@""];
        
        [[IXNLogManager instance] setLogListener:self];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString * dateStr = [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".log"];
        NSLog(@"%@", dateStr);
        
        self.btManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.btState = FALSE;
        
        self.mellow = [NSMutableArray array];

        _webSocketEeg.delegate = nil;
        _webSocketArtifact.delegate = nil;
        [_webSocketEeg close];
        [_webSocketArtifact close];
        _webSocketEeg = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://wsproxy<account name>.hanatrial.ondemand.com/hcpaddons/iotwebsocketproxy/external/muse/sensor"]];
        _webSocketArtifact = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://wsproxy<account name>.hanatrial.ondemand.com/hcpaddons/iotwebsocketproxy/external/muse/sensor2"]];
        _webSocketHeartRate = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://wsproxy<account name>.hanatrial.ondemand.com/hcpaddons/iotwebsocketproxy/external/muse/sensor3"]];
        _webSocketEeg.delegate = self;
        _webSocketArtifact.delegate = self;
        _webSocketHeartRate.delegate = self;
        [_webSocketEeg open];
        [_webSocketArtifact open];
        [_webSocketHeartRate open];
        
        //Life tracker
        [self connectDevice];
    }
    return self;
}

- (void)log:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSString *line = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    NSLog(@"%@", line);
    [self.logLines insertObject:line atIndex:0];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.logView setText:[self.logLines componentsJoinedByString:@"\n"]];
    });
}

- (void)receiveLog:(nonnull IXNLogPacket *)l {
  [self log:@"%@: %llu raw:%d %@", l.tag, l.timestamp, l.raw, l.message];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.btState = (self.btManager.state == CBCentralManagerStatePoweredOn);
}

- (bool)isBluetoothEnabled {
    return self.btState;
}

- (void)museListChanged {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [[self.manager getMuses] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"nil";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:simpleTableIdentifier];
    }
    NSArray * muses = [self.manager getMuses];
    if (indexPath.row < [muses count]) {
        IXNMuse * muse = [[self.manager getMuses] objectAtIndex:indexPath.row];
        cell.textLabel.text = [muse getName];
        if (![muse isLowEnergy]) {
            cell.textLabel.text = [cell.textLabel.text stringByAppendingString:
                                   [muse getMacAddress]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray * muses = [self.manager getMuses];
    if (indexPath.row < [muses count]) {
        IXNMuse * muse = [muses objectAtIndex:indexPath.row];
        @synchronized (self.muse) {
            if(self.muse == nil) {
                self.muse = muse;
            }else if(self.muse != muse) {
                [self.muse disconnect];
                self.muse = muse;
            }
        }
        [self connect];
        [self log:@"======Choose to connect muse %@ %@======\n",
              [self.muse getName], [self.muse getMacAddress]];
    }
}

- (void)receiveMuseConnectionPacket:(IXNMuseConnectionPacket *)packet
                               muse:(IXNMuse *)muse {
    NSString *state;
    switch (packet.currentConnectionState) {
        case IXNConnectionStateDisconnected:
            state = @"disconnected";
            break;
        case IXNConnectionStateConnected:
            state = @"connected";
            break;
        case IXNConnectionStateConnecting:
            state = @"connecting";
            break;
        case IXNConnectionStateNeedsUpdate: state = @"needs update"; break;
        case IXNConnectionStateUnknown: state = @"unknown"; break;
        default: NSAssert(NO, @"impossible connection state received");
    }
    [self log:@"connect: %@", state];
}

- (void) connect {
    [self.muse registerConnectionListener:self];
    [self.muse registerDataListener:self
                               type:IXNMuseDataPacketTypeArtifacts];
    
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeAlphaScore];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeAlphaAbsolute];
    [self.muse registerDataListener:self type:IXNMuseDataPacketTypeAlphaRelative]; //for mellow state
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeBetaScore];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeBetaAbsolute];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeBetaRelative];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeDeltaScore];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeDeltaAbsolute];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeDeltaRelative];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeGammaScore];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeGammaAbsolute];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeGammaRelative]; //for concentration state
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeThetaScore];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeThetaAbsolute];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeThetaRelative];
    //[self.muse registerDataListener:self type:IXNMuseDataPacketTypeEeg];
    [self.muse runAsynchronously];
}

- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet
                         muse:(IXNMuse *)muse {
//    if (packet.packetType == IXNMuseDataPacketTypeAlphaAbsolute ||
//            packet.packetType == IXNMuseDataPacketTypeEeg) {
    NSString* type = @"unknown";
    if (packet.packetType == IXNMuseDataPacketTypeAlphaScore){
        type = @"alpha_score";
    }else if (packet.packetType == IXNMuseDataPacketTypeAlphaAbsolute){
        type = @"alpha_absolute";
    }else if (packet.packetType == IXNMuseDataPacketTypeAlphaRelative){
        //type = @"alpha_relative";
        type = @"eeg";
        if([self.mellow count] == 20){
            double totalEeg1 = 0;
            double totalEeg2 = 0;
            double totalEeg3 = 0;
            double totalEeg4 = 0;
            for(NSArray<NSNumber *> *dataPacket in self.mellow){
                totalEeg1 = totalEeg1 + [dataPacket[0] doubleValue];
                totalEeg2 = totalEeg2 + [dataPacket[1] doubleValue];
                totalEeg3 = totalEeg3 + [dataPacket[2] doubleValue];
                totalEeg4 = totalEeg4 + [dataPacket[3] doubleValue];
            }
            
            double averageEeg1 = totalEeg1 / 20;
            double averageEeg2 = totalEeg2 / 20;
            double averageEeg3 = totalEeg3 / 20;
            double averageEeg4 = totalEeg4 / 20;
            if(isnan(averageEeg1)){
                averageEeg1 = 0;
            }
            if(isnan(averageEeg2)){
                averageEeg2 = 0;
            }
            if(isnan(averageEeg3)){
                averageEeg3 = 0;
            }
            if(isnan(averageEeg4)){
                averageEeg4 = 0;
            }
            [self sendData:averageEeg1 eeg2:averageEeg2 eeg3:averageEeg3 eeg4:averageEeg4 type:type];
            [self.mellow removeAllObjects];
        }else{
            NSMutableArray *array = [NSMutableArray array];
            if(isnan([packet.values[IXNEegEEG1] doubleValue])){
                [array addObject:[NSNumber numberWithInt:0]];
            }else{
                [array addObject:packet.values[IXNEegEEG1]];
            }
            if(isnan([packet.values[IXNEegEEG1] doubleValue])){
                [array addObject:[NSNumber numberWithInt:0]];
            }else{
                [array addObject:packet.values[IXNEegEEG2]];
            }
            if(isnan([packet.values[IXNEegEEG1] doubleValue])){
                [array addObject:[NSNumber numberWithInt:0]];
            }else{
                [array addObject:packet.values[IXNEegEEG3]];
            }
            if(isnan([packet.values[IXNEegEEG1] doubleValue])){
                [array addObject:[NSNumber numberWithInt:0]];
            }else{
                [array addObject:packet.values[IXNEegEEG4]];
            }
            [self.mellow addObject:array];
        }

    }else if (packet.packetType == IXNMuseDataPacketTypeBetaScore){
        type = @"beta_score";
    }else if (packet.packetType == IXNMuseDataPacketTypeBetaAbsolute){
        type = @"beta_absolute";
    }else if (packet.packetType == IXNMuseDataPacketTypeBetaRelative){
        type = @"beta_relative";
    }else if (packet.packetType == IXNMuseDataPacketTypeDeltaScore){
        type = @"delta_score";
    }else if (packet.packetType == IXNMuseDataPacketTypeDeltaAbsolute){
        type = @"delta_absolute";
    }else if (packet.packetType == IXNMuseDataPacketTypeDeltaRelative){
        type = @"delta_relative";
    }else if (packet.packetType == IXNMuseDataPacketTypeGammaScore){
        type = @"gamma_score";
    }else if (packet.packetType == IXNMuseDataPacketTypeGammaAbsolute){
        type = @"gamma_absolute";
    }else if (packet.packetType == IXNMuseDataPacketTypeGammaRelative){
        type = @"gamma_relative";
    }else if (packet.packetType == IXNMuseDataPacketTypeThetaScore){
        type = @"theta_score";
    }else if (packet.packetType == IXNMuseDataPacketTypeThetaAbsolute){
        type = @"theta_absolute";
    }else if (packet.packetType == IXNMuseDataPacketTypeThetaRelative){
        type = @"theta_relative";
    }else if (packet.packetType == IXNMuseDataPacketTypeEeg){
        type = @"eeg_raw";
    }
    
    NSLog(@"Packet type is %@", type);
    
//    [self sendData:[packet.values[IXNEegEEG1] doubleValue] eeg2:[packet.values[IXNEegEEG2] doubleValue] eeg3:[packet.values[IXNEegEEG3] doubleValue] eeg4:[packet.values[IXNEegEEG4] doubleValue] type:type];
}

- (void)receiveMuseArtifactPacket:(IXNMuseArtifactPacket *)packet
                             muse:(IXNMuse *)muse {
        self.lastBlink = packet.blink;
        self.lastJawclench = packet.jawClench;
        self.lastHeadbandon = packet.headbandOn;
       [self sendData:packet.blink jawclench:packet.jawClench headbandon:packet.headbandOn];
   
}


- (void) sendData: (BOOL) blink jawclench:(BOOL) jawclench headbandon:(BOOL) headbandon{
    if(!artifactDataSending){
        artifactDataSending = true;
        NSString *strBlink = blink ? @"true" : @"false";
        NSString *strJawclench = jawclench ? @"true" : @"false";
        NSString *strHeadbandon = headbandon ? @"true" : @"false";
        NSString *messageType = @"{\"mode\":\"sync\",\"messageType\":\"c1ba4b632cc6ebb2aca7\",\"messages\":[{";
        NSString *artifactData = [messageType stringByAppendingFormat:@"%@%@%@%@%@%@",@"\"blink\":",strBlink,@",\"jawclench\":",strJawclench,@",\"headbandon\":",strHeadbandon];
        
        NSTimeInterval secondsSinceUnixEpoch = [[NSDate date]timeIntervalSince1970];
        
        NSString *timestamp = [artifactData stringByAppendingFormat:@"%@%.f%@",@",\"timestamp\":",secondsSinceUnixEpoch,@","];
        NSString *jsonRequest = [timestamp stringByAppendingFormat:@"%@%@%@%@",@"\"type\":\"",@"artifact",@"\"",@"}]}"];
        //NSLog(@"jsonRequest is %@", jsonRequest);
        [_webSocketArtifact send:jsonRequest];
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(setArtifactDataSendFinishedAfterDelay:)
                                                userInfo:nil
                                                 repeats:NO];

    }
}

- (void) sendData:(double) eeg1 eeg2:(double) eeg2 eeg3:(double) eeg3 eeg4:(double) eeg4 type:(NSString*) type{
    if(!eegDataSending){
        eegDataSending = true;
        NSString *messageType = @"{\"mode\":\"sync\",\"messageType\":\"8a912ad1ce20f4753c23\",\"messages\":[{";
        NSString *eegData = [messageType stringByAppendingFormat:@"%@%5.2f%@%5.2f%@%5.2f%@%5.2f",@"\"eeg1\":",eeg1,@",\"eeg2\":",eeg2,@",\"eeg3\":",eeg3,@",\"eeg4\":",eeg4];
        
        NSTimeInterval secondsSinceUnixEpoch = [[NSDate date]timeIntervalSince1970];
        
        NSString *timestamp = [eegData stringByAppendingFormat:@"%@%.f%@",@",\"timestamp\":",secondsSinceUnixEpoch,@","];
        NSString *jsonRequest = [timestamp stringByAppendingFormat:@"%@%@%@%@",@"\"type\":\"",type,@"\"",@"}]}"];
        //NSLog(@"jsonRequest is %@", jsonRequest);
        [_webSocketEeg send:jsonRequest];
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(setEegDataSendFinishedAfterDelay:)
                                       userInfo:nil
                                        repeats:NO];

    }
}

- (void) sendData:(double) heartRate type:(NSString*) type{
    if(!heartRateDataSending){
        heartRateDataSending = true;
        NSString *messageType = @"{\"mode\":\"sync\",\"messageType\":\"3941d5282bf76f24bb7f\",\"messages\":[{";
        NSString *heartRateData = [messageType stringByAppendingFormat:@"%@%5.2f",@"\"heartrate\":",heartRate];
        
        NSTimeInterval secondsSinceUnixEpoch = [[NSDate date]timeIntervalSince1970];
        
        NSString *timestamp = [heartRateData stringByAppendingFormat:@"%@%.f%@",@",\"timestamp\":",secondsSinceUnixEpoch,@","];
        NSString *jsonRequest = [timestamp stringByAppendingFormat:@"%@%@%@%@",@"\"type\":\"",type,@"\"",@"}]}"];
        //NSLog(@"jsonRequest is %@", jsonRequest);
        [_webSocketHeartRate send:jsonRequest];
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(setHeartRateDataSendFinishedAfterDelay:)
                                       userInfo:nil
                                        repeats:NO];
        
    }
}
    


- (void) setHttpDataSendFinishedAfterDelay:(NSTimer*)t {
    [self log:@"Http Data send to HCP"];
    httpDataSending = false;
}


- (void) setEegDataSendFinishedAfterDelay:(NSTimer*)t {
    [self log:@"Eeg Data send to HCP"];
    eegDataSending = false;
}

- (void) setHeartRateDataSendFinishedAfterDelay:(NSTimer*)t {
    [self log:@"HeartRate Data send to HCP"];
    heartRateDataSending = false;
}

- (void) setArtifactDataSendFinishedAfterDelay:(NSTimer*)t {
    [self log:@"Artifact Data send to HCP"];
    artifactDataSending = false;
}

- (void)applicationWillResignActive {
    NSLog(@"disconnecting before going into background");
    [self.muse disconnect];
}

- (IBAction)disconnect:(id)sender {
    if (self.muse) [self.muse disconnect];
}

- (IBAction)scan:(id)sender {
    [self.manager startListening];
    [self.tableView reloadData];
}

- (IBAction)stopScan:(id)sender {
    [self.manager stopListening];
    [self.tableView reloadData];
}

///--------------------------------------
#pragma mark - SRWebSocketDelegate
///--------------------------------------
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"Websocket opened");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"Websocket message received");
    if([message isKindOfClass:[NSString class]]){
        NSLog(@"lowerCaseString is: %@", [(NSString *)message lowercaseString]);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string{
    NSLog(@"Websocket didReceiveMessageWithString.");
}
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data{
    NSLog(@"Websocket didReceiveMessageWithData.");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"Websocket didFailWithError.");
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"Websocket didCloseWithCode.");
}



///--------------------------------------
#pragma mark - LifeTracker
///--------------------------------------

NSString *lifeTrackerUUID = @"4F399AA6-B347-49BB-AA33-7283DA60DA18";

- (void)connectDevice {
    __weak typeof(self) wSelf = self;
    // check Bluetooth
    [[BLEWrapper shared] setupBLEcompletion:^(CBCentralManagerState state) {
        if (state == CBCentralManagerStatePoweredOn) {
            // auto connect last device
//            [[SyncService shared] autoConnectLastActiveDevice:^(BLEDevice *device, NSError *error) {
//                if (error == nil && device != nil) {
//                    [device connectAndEnable:^(NSError *error) {
//                        if (error == nil) {
//                            [wSelf startHeartRateMonitor:device];
//                        }
//                    }];
//                }
//            }];
            
            // or search
            [[BLEWrapper shared] startScanCompletion:^(NSError *error) {
                if (error == nil && 0 < [[BLEWrapper shared].discoveredPeripherals count]) {
                    BLEDevice *selectedDevice = NULL;
                    for (BLEDevice *device in [BLEWrapper shared].discoveredPeripherals) {
                        NSLog(@"DeviceId: %@", device.cbPeripheral.identifier);
                        if([lifeTrackerUUID isEqualToString:[device.cbPeripheral.identifier UUIDString]]){
                            selectedDevice = device;
                        }
                    }
                    
                    [selectedDevice connectAndEnable:^(NSError *error) {
                        if (error == nil) {
                            [wSelf startHeartRateMonitor:selectedDevice];
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)startHeartRateMonitor:(BLEDevice *)device {
    self.device = device;
    __weak typeof(self) wSelf = self;
    [device setHeartRateMonitor:TRUE completion:^(NSError *error) {
        if (error == nil) {
            NSLog(@"> Start Heart Rate monitor successfully.");
            [self log:@"> Start Heart Rate monitor successfully."];
            // turn off after 60 sec
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wSelf stopHeartRateMonitor];
            });
        } else {
            NSLog(@"> Start Heart Rate monitor error: %@", error.localizedDescription);
            [self log:@"> Start Heart Rate monitor error: %@", error.localizedDescription];
        }
    } valueUpdated:^(uint8_t heartRateValue) {
        NSLog(@"> Heart Rate monitor value notification: %d", heartRateValue);
        [self log:@"> Heart Rate monitor value notification: %d", heartRateValue];
        [self sendData:heartRateValue type:@"heartrate"];
    }];
}

- (void)stopHeartRateMonitor {
    [self.device setHeartRateMonitor:FALSE completion:^(NSError *error) {
        if (error == nil) {
            NSLog(@"> Stop Heart Rate monitor successfully.");
            [self log:@"> Stop Heart Rate monitor successfully."];
        } else {
            NSLog(@"> Stop Heart Rate monitor error: %@", error.localizedDescription);
            [self log:@"> Stop Heart Rate monitor error: %@", error.localizedDescription];
        }
    } valueUpdated:nil];
}

@end

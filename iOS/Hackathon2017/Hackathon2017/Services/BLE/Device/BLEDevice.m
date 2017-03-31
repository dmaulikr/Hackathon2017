//
//  BLEDevice.m
//  ItsMyLife
//
//  Created by Duy Pham on 1/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "BLEDevice.h"
#import "BLEDataService.h"
#import "BLEWrapper.h"
#import "NSError+app.h"
#import "MSWeakTimer.h"


@interface BLEDevice ()

@property (nonatomic, readwrite, assign) BOOL isReady;
@property (nonatomic, strong) NSMutableArray *connectProgressBlocks;
@property (nonatomic, strong) NSMutableArray *connectCompletionBlocks;
@property (nonatomic, assign) BOOL isConnecting;

@property (nonatomic, strong) MSWeakTimer *timeoutTimer;

@end


@implementation BLEDevice

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral central:(YMSCBCentralManager *)owner {
    self = [super initWithPeripheral:peripheral central:owner baseHi:0 baseLo:0];
    
    if (self) {
        BLEDataService *data_svc = [[BLEDataService alloc] initWithParent:self];
        
        self.serviceDict = @{
                             [BLEDataService name]: data_svc,
                             };
        
        _isReady = FALSE;
        _connectProgressBlocks = [NSMutableArray array];
        _connectCompletionBlocks = [NSMutableArray array];
        _isConnecting = FALSE;
    }
    
    return self;
}


- (void)connectAndEnable:(void (^)(NSError *))completion {
    [self connectAndEnableProgress:^(BLEDeviceConnectionStatus status){} completion:completion];
}

- (void)connectAndEnableProgress:(void (^)(BLEDeviceConnectionStatus))progress completion:(void (^)(NSError *))completion {
    if (self.isConnected && self.isReady) {
        completion(nil);
    } else {
        if (progress) [self.connectProgressBlocks addObject:[progress copy]];
        if (completion) [self.connectCompletionBlocks addObject:[completion copy]];
        
        if (!self.isConnecting) {
            self.isConnecting = TRUE;
            // start setting up
            [self connectAndEnable];
        }
    }
}

- (void)connectAndEnable {
    self.isReady = FALSE;
    
    __weak typeof(self) weakSelf = self;
    
    void (^readyCompletion)(YMSCBPeripheral *yp, NSError *error) =  ^void(YMSCBPeripheral *yp, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        if (error) {
            [self triggerCompletion:error];
        } else {
            [self triggerProgress:BLEDeviceConnectionStatusConnecting];
            
            [yp discoverServices:[yp services] withBlock:^(NSArray *yservices, NSError *error) {
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                if (error) {
                    [self triggerCompletion:error];
                } else {
                    [self triggerProgress:BLEDeviceConnectionStatusConnecting];
                    
                    dispatch_group_t dp_group = dispatch_group_create();
                    __block NSError *oneErr;
                    
                    for (YMSCBService *service in yservices) {
                        if ([service isKindOfClass:[BLEDataService class]]) {
                            dispatch_group_enter(dp_group);
                            __weak typeof(service) weakService = service;
                            [service discoverCharacteristics:nil withBlock:^(NSDictionary *chDict, NSError *error) {
                                __strong typeof(weakService) service = weakService;
                                oneErr = error ?: oneErr;
                                if (service) {
                                    [(BLEDataService *)service turnOn:TRUE completion:^(NSError *error) {
                                        oneErr = error ?: oneErr;
                                        dispatch_group_leave(dp_group);
                                    }];
                                } else {
                                    dispatch_group_leave(dp_group);
                                }
                            }];
                        } else {
                        }
                    }
                    
                    dispatch_group_notify(dp_group, dispatch_get_main_queue(), ^{
                        __strong typeof(weakSelf) self = weakSelf;
                        if (!self) return;
                        if (oneErr) {
                            [self triggerCompletion:oneErr];
                        } else {
                            self.isReady = TRUE;
                            [self triggerCompletion:nil];
                        }
                    });
                }
            }];
        }
    };
    
    if (self.isConnected) {
        readyCompletion(self, nil);
    } else {
        // Watchdog aware method
        [self resetWatchdog];
        
        [self triggerProgress:BLEDeviceConnectionStatusConnecting];
        [self connectWithOptions:@{
                                   CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
                                   CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
                                   }
                       withBlock:^(YMSCBPeripheral *yp, NSError *error) {
                           [BLEWrapper shared].activePeripheral = weakSelf;
                           readyCompletion(yp, error);
                       }];
    }
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = [MSWeakTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(triggerTimeout:) userInfo:nil repeats:FALSE dispatchQueue:dispatch_get_main_queue()];
}

- (void)triggerTimeout:(MSWeakTimer *)timer {
    [self triggerCompletion:[NSError error:AppErrorBLEConnectionTimedOut]];
}

- (void)triggerProgress:(BLEDeviceConnectionStatus)status {
    for (void (^progress)(BLEDeviceConnectionStatus) in self.connectProgressBlocks) {
        progress(status);
    }
}

- (void)triggerCompletion:(NSError *)error {
    [self.timeoutTimer invalidate];
    
    self.isConnecting = FALSE;
    
    for (void (^completion)(NSError *) in self.connectCompletionBlocks) {
        completion(error);
    }
    
    [self.connectCompletionBlocks removeAllObjects];
    [self.connectProgressBlocks removeAllObjects];
}

- (void)disconnect {
    [super disconnect];
    [BLEWrapper shared].activePeripheral = nil;
}

- (void)defaultConnectionHandler {
}

- (BLEDataService *)bleDataService {
    return self.serviceDict[[BLEDataService name]];;
}

- (BLEDeviceConnectionStatus)status {
    switch (self.cbPeripheral.state) {
        case CBPeripheralStateDisconnected:
            return BLEDeviceConnectionStatusDisconnected;
        case CBPeripheralStateConnecting:
            return BLEDeviceConnectionStatusConnecting;
        case CBPeripheralStateConnected:
            return self.isReady ?
            BLEDeviceConnectionStatusConnected :
            BLEDeviceConnectionStatusConnecting;
        case CBPeripheralStateDisconnecting:
            return BLEDeviceConnectionStatusDisconnected;
    }
}

@end

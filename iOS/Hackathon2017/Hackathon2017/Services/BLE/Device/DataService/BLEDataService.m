//
//  BLEDataService.m
//  ItsMyLife
//
//  Created by Duy Pham on 1/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "BLEDataService.h"
#import "BLEDataReadCharacteristic.h"
#import "BLEDataWriteCharacteristic.h"
#import "BLEDataServiceBlockLinker.h"
#import "BLEDataServiceNotifyLinker.h"
#import "MSWeakTimer.h"
#import "NSError+app.h"


@interface BLEDataService ()

@property (nonatomic, strong) NSMutableArray /* BLEDataServiceBlockLinker */ *maps;
@property (nonatomic, strong) MSWeakTimer *received_timeout_timer;

@property (nonatomic, strong) NSMutableArray /* BLEDataServiceNotifyLinker */ *notifymaps;

@end

@implementation BLEDataService

- (instancetype)initWithParent:(YMSCBPeripheral *)parent {
    self = [super initWithName:[[self class] name] parent:parent baseHi:0 baseLo:0 serviceOffset:[[self class] serviceUUID]];
    
    if (self) {
        [self addCharacteristic:[[BLEDataReadCharacteristic  alloc] initWithParent:self]];
        [self addCharacteristic:[[BLEDataWriteCharacteristic alloc] initWithParent:self]];
        _maps = [NSMutableArray array];
        _notifymaps = [NSMutableArray array];
    }
    
    return self;
}

+ (int)serviceUUID {
    return 0xFFF0;
}

+ (NSString *)name {
    static NSString * const BLEDataServicename = @"svc_data";
    return BLEDataServicename;
}

- (void)addCharacteristic:(YMSCBCharacteristic *)yc {
    self.characteristicDict[yc.name] = yc;
}

- (void)turnOn:(BOOL)on completion:(void (^)(NSError *))completion {
    // turn ON read notify, so "response" can be received
    BLEDataReadCharacteristic *readCh = self.characteristicDict[[BLEDataReadCharacteristic name]];
    [readCh setNotifyValue:on withBlock:completion];
}

- (void)senddata:(uint8_t [16])writedata accepted:(NSArray *)responsecommands completion:(void (^)(NSError *, NSArray *))completion {
    [self.maps addObject:[[BLEDataServiceBlockLinker alloc] initWithAccepted:responsecommands withCompletion:completion]];
    
    uint16_t checksum = 0;
    for(int i=0;i<15;i++) {
        checksum += writedata[i];
    }
    writedata[15] = checksum & 0xFF;
    
    NSData *data =[NSData dataWithBytes:writedata length:16];
    
#ifdef DEBUG
    NSLog(@"Write: %@", data);
#endif
    
    BLEDataWriteCharacteristic *wc = self.characteristicDict[[BLEDataWriteCharacteristic name]];
    [wc writeValue:data withBlock:^(NSError *error) {
        if (error) {
#ifdef DEBUG
            NSLog(@"Write error: %@", [error localizedDescription]);
#endif
            [self addReceivedValue:nil error:error];
        } else {
        }
    }];
}

- (void)registerNotification:(uint8_t)responsecommand notifyBlock:(void (^)(NSData *))notifyBlock {
    [self.notifymaps addObject:[[BLEDataServiceNotifyLinker alloc] initWithAccepted:responsecommand withNotifyBlock:notifyBlock]];
}

- (void)unRegisterNotification:(uint8_t)responsecommand {
    [self.notifymaps removeObjectsAtIndexes:[self.notifymaps indexesOfObjectsPassingTest:^BOOL(BLEDataServiceNotifyLinker *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return (obj.responsecommand == responsecommand);
    }]];
}

- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error {
    
    if (error) {
#ifdef DEBUG
        NSLog(@"noti: error %@", error.localizedDescription);
#endif
        [self addReceivedValue:nil error:error];
    } else if ([yc.name isEqualToString:[BLEDataReadCharacteristic name]]) {
#ifdef DEBUG
        NSLog(@"noti: %@", yc.cbCharacteristic.value);
#endif
        [self addReceivedValue:yc.cbCharacteristic.value error:nil];
    } else {
        [self addReceivedValue:nil error:[NSError error:AppErrorUnknown]];
    }
}

- (void)addReceivedValue:(NSData *)readdata error:(NSError *)error {
    [self.maps enumerateObjectsUsingBlock:^(BLEDataServiceBlockLinker *obj, NSUInteger idx, BOOL *stop) {
        [obj addReceivedValue:readdata error:error];
    }];
    
    [self.notifymaps enumerateObjectsUsingBlock:^(BLEDataServiceNotifyLinker *obj, NSUInteger idx, BOOL *stop) {
        [obj addReceivedValue:readdata error:error];
    }];
    
    [self.received_timeout_timer invalidate];
    self.received_timeout_timer = [MSWeakTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(finalizeReceivedValues) userInfo:nil repeats:FALSE dispatchQueue:dispatch_get_main_queue()];
}

- (void)finalizeReceivedValues {
    [self.received_timeout_timer invalidate];
    
    [self.maps enumerateObjectsUsingBlock:^(BLEDataServiceBlockLinker *obj, NSUInteger idx, BOOL *stop) {
        if (![obj finalized]) {
            [obj finalizeReceivedValues];
        }
    }];
    
    // cleanup
    self.maps = [NSMutableArray array];
}

- (void)clearAllRegisteredNotifyBlocks {
    [self.notifymaps removeAllObjects];
}

@end

//
//  BLEManager.m
//  ItsMyLife
//
//  Created by Duy Pham on 1/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "BLEManager.h"
#import "BLEDevice.h"
#import "MSWeakTimer.h"

@interface BLEManager ()

@property (nonatomic, strong) MSWeakTimer *timeout_timer;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, copy) void (^scanCompletion)();

@end

@implementation BLEManager

- (instancetype)initWithKnownPeripheralNames:(NSArray *)nameList queue:(dispatch_queue_t)queue useStoredPeripherals:(BOOL)useStore delegate:(id<CBCentralManagerDelegate>) delegate {
    self = [super initWithKnownPeripheralNames:nameList queue:queue useStoredPeripherals:useStore delegate:delegate];
    
    if (self != nil) {
        self.queue = queue;
    }
    
    return self;
}

- (CBCentralManagerState)state {
    return self.manager.state;
}

- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options timeout:(NSTimeInterval)timeout withDiscoveryBlock:(void (^)(CBPeripheral *, NSDictionary *, NSNumber *, NSError *))discoverCallback completion:(void (^)())completion
{
    self.scanCompletion = completion;
    
    __weak typeof(self) this = self;
    [self scanForPeripheralsWithServices:serviceUUIDs options:options withBlock:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error) {
        if (discoverCallback != nil) {
            discoverCallback(peripheral, advertisementData, RSSI, error);
        } else {
            [this handleFoundPeripheral:peripheral];
        }
        
        if ([this timeout_timer] != nil) {
            [[this timeout_timer] invalidate];
        } else {
        }
        
        [this setTimeout_timer:[MSWeakTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(stopScan) userInfo:nil repeats:FALSE dispatchQueue:self.queue]];
    }];
}

- (void)stopScan {
    [super stopScan];
    if (self.scanCompletion != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scanCompletion();
        });
    }
}

- (void)handleFoundPeripheral:(CBPeripheral *)peripheral {
    YMSCBPeripheral *yp = [self findPeripheral:peripheral];
    
    if (yp == nil || ![yp isKindOfClass:[BLEDevice class]]) {
        BOOL isUnknownPeripheral = YES;
        
        for (NSString *pname in self.knownPeripheralNames) {
            if ([pname isEqualToString:peripheral.name]) {
                BLEDevice *sensorTag = [[BLEDevice alloc] initWithPeripheral:peripheral
                                                                     central:self];
                [self addPeripheral:sensorTag];
                isUnknownPeripheral = NO;
                break;
            } else {
            }
        }
        // handle unknown peripheral name
        if (isUnknownPeripheral) {
            BLEDevice *sensorTag = [[BLEDevice alloc] initWithPeripheral:peripheral
                                                                 central:self];
            [self addPeripheral:sensorTag];
        }
    } else {
    }
}

@end

//
//  BLEWrapper.m
//  ItsMyLife
//
//  Created by Duy Pham on 31/5/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "BLEWrapper.h"
#import "BLEManager.h"
#import "BLEDevice.h"
#import "BLEDataService.h"
#import "NSError+app.h"

static BLEWrapper *singleton_BLEWrapper;


@interface BLEWrapper () <CBCentralManagerDelegate>

@property (nonatomic, readwrite, strong) BLEManager *cb_manager;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) BOOL BLEsetupcompleted;
@property (nonatomic, copy) void (^setupBLEcompletion)(CBCentralManagerState);

- (instancetype)init;

@end


@implementation BLEWrapper

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton_BLEWrapper = [[BLEWrapper alloc] init];
    });
    
    return singleton_BLEWrapper;
}

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        _queue = dispatch_queue_create("a80092debe052712e1d5080f2364f760", DISPATCH_QUEUE_SERIAL);
        _BLEsetupcompleted = FALSE;
        
        _cb_manager = [[BLEManager alloc] initWithKnownPeripheralNames:@[] queue:_queue useStoredPeripherals:TRUE delegate:self];
    }
    
    return self;
}

- (CBCentralManagerState)cb_state {
    return [self.cb_manager state];
}

- (NSArray *)discoveredPeripherals {
    return self.cb_manager.ymsPeripherals;
}

- (void)setupBLEcompletion:(void (^)(CBCentralManagerState))completion {
    if (self.BLEsetupcompleted) {
        completion(self.cb_state);
    } else {
        self.setupBLEcompletion = completion;
    }
}

- (void)startScanCompletion:(void (^)(NSError *))completion {
    if ([self.cb_manager state] < CBCentralManagerStatePoweredOn) {
        completion([NSError error:AppErrorBLEoff]);
    } else {
        __weak typeof(self) this = self;
        //hack
        NSString *addrString = [NSString stringWithFormat:@"%x", [BLEDataService serviceUUID]];
        CBUUID *uuid = [CBUUID UUIDWithString:addrString];
        
        [self.cb_manager
         scanForPeripheralsWithServices: @[uuid]
         options: nil
         timeout: 4.0
         withDiscoveryBlock:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error) {
             if (!error) {
#ifdef DEBUG
                 NSLog(@"DISCOVERED: %@, %@, %@ db", peripheral, peripheral.name, RSSI);
#endif
                 [[this cb_manager] handleFoundPeripheral:peripheral];
             } else {
             }
         }
         completion:^{
             completion(nil);
         }];
    }
}

- (void)cancelAllConnection {
    for (BLEDevice *per in self.cb_manager.ymsPeripherals) {
        [per cancelConnection];
    }
}

- (BLEDevice *)retrievePeripheralsWithIdentifier:(NSString *)uuid {
    NSArray *ret = [self.cb_manager retrievePeripheralsWithIdentifiers:@[[[NSUUID alloc] initWithUUIDString:uuid]]];
    
    for (CBPeripheral *per in ret) {
        return (BLEDevice *)[self.cb_manager findPeripheral:per];
    }
    
    return nil;
}

- (void)retrieveOrSearchPeripheralsWithIdentifier:(NSString *)uuid completion:(void (^)(BLEDevice *, NSError *))completion {
    BLEDevice *per = [self retrievePeripheralsWithIdentifier:uuid];
    if (per) {
        completion(per, nil);
    } else {
        self.autoConnectUUID = uuid;
        [self startScanCompletion:^(NSError *error) {
            BLEWrapper *sself = [BLEWrapper shared];
            if (error) {
                sself.autoConnectUUID = nil;
                completion(nil, error);
            } else if (sself.autoConnectUUID) {
                BLEDevice *per = [sself retrievePeripheralsWithIdentifier:sself.autoConnectUUID];
                if (per) {
                    completion(per, nil);
                } else {
                    // TODO: show enum error instead of hardcoded string: device not found
                    completion(nil, [NSError error:AppErrorBLEConnectionFail]);
                }
            } else {
                // Do nothing
            }
        }];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    self.BLEsetupcompleted = TRUE;
    
    if (central.state == CBManagerStatePoweredOff) {
        [_delegate bluetoothIsDisable];
    }
    
    if (self.setupBLEcompletion != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.setupBLEcompletion(self.cb_state);
        });
    } else {
    }
}

@end

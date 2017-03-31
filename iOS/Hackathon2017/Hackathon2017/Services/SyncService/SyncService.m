//
//  SyncService.m
//  ItsMyLife
//
//  Created by Duy Pham on 23/1/17.
//  Copyright © 2017 BHTech. All rights reserved.
//

#import "SyncService.h"
#import "BLEWrapper.h"
#import "BLEDevice+ReadWriteData.h"
#import "UserObject.h"
#import "DayDetail.h"
#import "Configurations.h"
#import "NSError+app.h"
#import "NSDate+Utilities.h"
#import "NSTimeZone+Offset.h"
#import "MSWeakTimer.h"


@interface SyncService ()

@property (nonatomic, strong) NSMutableArray *autoConnectCompletionBlocks;
@property (nonatomic, strong) NSMutableArray *autoConnectProgressBlocks;
@property (nonatomic, assign) BOOL isAutoConnecting;
@property (nonatomic, strong) MSWeakTimer *timeoutTimer;
@property (nonatomic, strong) NSMutableArray *syncingCompletionBlocks;
@property (nonatomic, strong) NSMutableArray *syncingProgressBlocks;
@property (nonatomic, weak) BLEDevice *syncingDevice;
@property (nonatomic, strong) NSArray *syncDataArray;
@property (nonatomic, strong) MSWeakTimer *syncTimeoutTimer;

@end


@implementation SyncService

static SyncService *singleton = nil;
static dispatch_once_t onceToken;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _autoConnectProgressBlocks = [NSMutableArray array];
        _autoConnectCompletionBlocks = [NSMutableArray array];
        _syncingProgressBlocks = [NSMutableArray array];
        _syncingCompletionBlocks = [NSMutableArray array];
        _isAutoConnecting = FALSE;
    }
    
    return self;
}

+ (instancetype)shared {
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

#pragma mark - Validate device

- (void)validateDevice:(BLEDevice *)device serialNumber:(NSString *)serial completion:(void (^)(NSError *error))completion {
    if (!serial || [serial length] == 0) {
        completion(nil);
        return;
    }
    
    __weak typeof(device) wper = device;
    [device getAttributesAndSerialNumCompletion:^(NSError *error, BOOL genderMale, uint8_t age, uint8_t heightCm, uint8_t weightKg, uint8_t stepLengthCm, NSString *serialNumber) {
        __strong typeof(wper) sper = wper;
        if (!sper) return;
        
        if (error) {
            completion(error);
        } else {
            if ([serialNumber isEqualToString:serial]) {
                completion(nil);
            } else {
                completion([NSError error:AppErrorBLENotRegistered]);
            }
        }
    }];
}

#pragma mark - AutoConnect

- (void)autoConnectLastActiveDevice:(void (^)(BLEDevice *, NSError *))completion {
    [self autoConnectLastActiveDeviceProgress:^(BLEDeviceConnectionStatus status){} completion:completion];
}

- (void)autoConnectLastActiveDeviceProgress:(void (^)(BLEDeviceConnectionStatus))progress completion:(void (^)(BLEDevice *, NSError *))completion {
    if ([BLEWrapper shared].activePeripheral && [BLEWrapper shared].activePeripheral.status == BLEDeviceConnectionStatusConnected) {
        completion([BLEWrapper shared].activePeripheral, nil);
    } else {
        if (progress) [self.autoConnectProgressBlocks addObject:[progress copy]];
        if (completion) [self.autoConnectCompletionBlocks addObject:[completion copy]];
        
        if (!self.isAutoConnecting) {
            self.isAutoConnecting = TRUE;
            [self autoConnectLastActiveDevice];
        }
    }
}

- (void)autoConnectLastActiveDevice {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = [MSWeakTimer scheduledTimerWithTimeInterval:12.0 target:self selector:@selector(triggerTimeout:) userInfo:nil repeats:FALSE dispatchQueue:dispatch_get_main_queue()];
    
    __weak typeof(self) weakSelf = self;
    // Find device
    void (^subcompletion)(BLEDevice *device, NSError *error) = ^void(BLEDevice *device, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        if (error) {
            [self triggerCompletionDevice:nil error:error];
        } else {
            [self triggerProgress:device.status];
            
            // Connect device
            if (device.status == BLEDeviceConnectionStatusConnected) {
                [self triggerCompletionDevice:device error:nil];
                return;
            } // else
            
            __weak typeof(device) wper = device;
            [device connectAndEnableProgress:^(BLEDeviceConnectionStatus status) {
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                [self triggerProgress:status];
            } completion:^(NSError *error) {
                __strong typeof(weakSelf) self = weakSelf;
                __strong typeof(wper) sper = wper;
                if (!self || !sper) return;
                
                if (error) {
                    [self triggerCompletionDevice:nil error:error];
                } else {
                    [self validateDevice:sper serialNumber:[UserObject shared].deviceSerialNumber completion:^(NSError *error) {
                        __strong typeof(weakSelf) self = weakSelf;
                        __strong typeof(wper) sper = wper;
                        if (!self || !sper) return;
                        
                        if (error) {
                            [BLEWrapper shared].activePeripheral = nil;
                            [self triggerCompletionDevice:nil error:error];
                        } else {
                            [UserObject shared].lastDeviceUUID = device.cbPeripheral.identifier.UUIDString;
                            [self triggerCompletionDevice:sper error:nil];
                        }
                    }];
                }
            }];
        }
    };
    
    NSString * pUuid = [UserObject shared].lastDeviceUUID;
    if (pUuid && [pUuid length] > 0) {
        // Setup Bluetooth
        [[BLEWrapper shared] setupBLEcompletion:^(CBCentralManagerState state) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            
            if (state == CBCentralManagerStatePoweredOn) {
                [[BLEWrapper shared] retrieveOrSearchPeripheralsWithIdentifier:pUuid completion:subcompletion];
            } else {
                [self triggerCompletionDevice:nil error:[NSError error:AppErrorBLEoff]];
            }
        }];
    } else {
        [self triggerCompletionDevice:nil error:nil];
    }
}

- (void)triggerTimeout:(MSWeakTimer *)timer {
    [self triggerCompletionDevice:nil error:[NSError error:AppErrorBLEConnectionTimedOut]];
}

- (void)triggerProgress:(BLEDeviceConnectionStatus)status {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = [MSWeakTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(triggerTimeout:) userInfo:nil repeats:FALSE dispatchQueue:dispatch_get_main_queue()];
    
    for (void (^progress)(BLEDeviceConnectionStatus) in self.autoConnectProgressBlocks) {
        progress(status);
    }
}

- (void)triggerCompletionDevice:(BLEDevice *)device error:(NSError *)error {
    [self.timeoutTimer invalidate];
    
    self.isAutoConnecting = FALSE;
    
    for (void (^completion)(BLEDevice *, NSError *) in self.autoConnectCompletionBlocks) {
        completion(device, error);
    }
    
    [self.autoConnectCompletionBlocks removeAllObjects];
    [self.autoConnectProgressBlocks removeAllObjects];
}

#pragma mark - Connect

- (void)connectDevice:(BLEDevice *)device progress:(void (^)(BLEDeviceConnectionStatus))progress completion:(void (^)(NSError *))completion {
    __weak typeof(self) weakSelf = self;
    __weak typeof(device) wper = device;
    [device connectAndEnableProgress:^(BLEDeviceConnectionStatus status) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        progress(status);
    } completion:^(NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        __strong typeof(wper) sper = wper;
        if (!self || !sper) return;
        
        if (error) {
            completion(error);
        } else {
            [self validateDevice:sper serialNumber:[UserObject shared].deviceSerialNumber completion:^(NSError *error) {
                __strong typeof(weakSelf) self = weakSelf;
                __strong typeof(wper) sper = wper;
                if (!self || !sper) return;
                
                if (error) {
                    [BLEWrapper shared].activePeripheral = nil;
                    completion(error);
                } else {
                    [UserObject shared].lastDeviceUUID = sper.cbPeripheral.identifier.UUIDString;
                    completion(nil);
                }
            }];
        }
    }];
}

#pragma mark - Disconnect

- (void)disconnectDevice:(BLEDevice *)device {
    [device disconnect];
    [UserObject shared].lastDeviceUUID = nil;
}

#pragma mark - Sync

- (void)syncData:(BLEDevice *)device force:(BOOL)force progress:(void (^)(NSDate *))progress completion:(void (^)(NSError *))completion {
    if (self.syncingDevice && self.syncingDevice != device) {
        completion([NSError error:AppErrorBLESyncOneDeviceOnly]);
    } else {
        self.syncingDevice = device;
        if (completion) [self.syncingCompletionBlocks addObject:[completion copy]];
        if (progress)  [self.syncingProgressBlocks addObject:[progress copy]];
        
        if (!self.syncingDevice.isSyncingDayDetailData) {
            [self syncDataDeviceForce:force];
        }
    }
}

- (void)syncDataDeviceForce:(BOOL)force {
    if (self.syncingDevice && self.syncingDevice.isConnected) {
        [self.syncTimeoutTimer invalidate];
        self.syncTimeoutTimer = [MSWeakTimer scheduledTimerWithTimeInterval:24.0 target:self selector:@selector(triggerSyncTimeout:) userInfo:nil repeats:FALSE dispatchQueue:dispatch_get_main_queue()];
        
        if (force) {
            // force syncing data for 29 days, by clearing cached last sync date
            [UserObject shared].lastSyncDate = nil;
        }
        [self syncDataLoop:FALSE];
    } else {
        [self triggerSyncCompletion:[NSError error:AppErrorBLENotConnected]];
    }
}

- (void)syncDataLoop:(BOOL)isContinuingSyncing {
    if (self.syncingDevice && self.syncingDevice.isConnected) {
        if (!isContinuingSyncing && self.syncingDevice.isSyncingDayDetailData) {
            // syncing is already in progress
            return;
        }
        
        NSDate *nowDate = [NSDate date];
        NSDate *lastDate = [UserObject shared].lastSyncDate;
        NSInteger dayDiffer = (lastDate == nil) ? 29 : [nowDate differenceInDaysWithDate:lastDate];
        dayDiffer = MIN(29, dayDiffer);
        
        if (dayDiffer < 0) {
            [UserObject shared].lastSyncDate = nowDate;
            
            [self triggerSyncCompletion:nil];
        } else {
            [UserObject shared].lastSyncDate = [[nowDate dateBySubtractingDays:dayDiffer] dateAtStartOfDay];
            self.syncingDevice.isSyncingDayDetailData = TRUE;
            
            __weak typeof(self) wself = self;
            [self getAndUploadOnedayDetailFromDaysAgo:dayDiffer completion:^(NSDate *date, NSError *error) {
                __strong typeof(wself) self = wself;
                if (!self) return;
                if (error) {
                    [self triggerSyncCompletion:error];
                } else {
                    [self triggerSyncProgress:date];
                    [UserObject shared].lastSyncDate = [[nowDate dateBySubtractingDays:(dayDiffer-1)] dateAtStartOfDay];
                    [self syncDataLoop:TRUE];
                }
            }];
        }
    } else {
        [self triggerSyncCompletion:[NSError error:AppErrorBLENotConnected]];
    }
}

- (void)getAndUploadOnedayDetailFromDaysAgo:(NSUInteger)days completion:(void (^)(NSDate *date, NSError *error))completion {
    [self.syncingDevice getOnedayDetailFromDaysAgo:days completion:^(NSError *error, DayDetail *dayDetail) {
        if (error) {
            completion(nil, error);
        } else {
            NSArray *syncDataArray = [dayDetail detailForHours];
            NSTimeZone * timeZone = [NSTimeZone systemTimeZone];
            NSMutableArray * params = [NSMutableArray array];
            
            for (HourDetail * hourDetail in syncDataArray) {
                NSString *timestampStr = [hourDetail.timestamp stringWithFormat:k_DATE_FORMAT_LAST_SYNC
                                                                         locale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]
                                                                       timezone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                NSDictionary *param = @{
                                        @"timestamp"       : timestampStr,
                                        @"timezone_name"   : timeZone.name,
                                        @"timezone_offset" : [timeZone offsetString],
                                        @"distance"        : [@(hourDetail.distance) stringValue],
                                        @"duration"        : @(0),
                                        @"calories"        : [@((UInt32)(hourDetail.calories / 10)) stringValue],
                                        @"steps"           : [@(hourDetail.steps) stringValue],
                                        @"running_steps"   : [@(hourDetail.running_steps) stringValue],
                                        @"points"          : [@(hourDetail.points) stringValue],
                                        @"passivity"       : [@(hourDetail.passivity) stringValue],
                                        @"bedtime"         : [@(hourDetail.bedtime) stringValue],
                                        @"goodsleep"       : [@(hourDetail.goodsleep) stringValue]
                                        };
                [params addObject:param];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[UserObject shared] requestUpdateData:params success:^{
                completion(dayDetail.day, nil);
//            } failure:^(NSError *error) {
//                completion(nil, error);
//            }];
            });
        }
    }];
}

- (void)triggerSyncTimeout:(MSWeakTimer *)timer {
    [self triggerSyncCompletion:[NSError error:AppErrorBLEConnectionTimedOut]];
}

- (void)triggerSyncProgress:(NSDate *)date {
    [self.syncTimeoutTimer invalidate];
    self.syncTimeoutTimer = [MSWeakTimer scheduledTimerWithTimeInterval:16.0 target:self selector:@selector(triggerSyncTimeout:) userInfo:nil repeats:FALSE dispatchQueue:dispatch_get_main_queue()];
    
    for (void (^progress)(NSDate *) in self.syncingProgressBlocks) {
        progress(date);
    }
}

- (void)triggerSyncCompletion:(NSError *)error {
    [self.syncTimeoutTimer invalidate];
    
    self.syncingDevice.isSyncingDayDetailData = FALSE;
    
    for (void (^completion)(NSError *) in self.syncingCompletionBlocks) {
        completion(error);
    }
    
    self.syncingDevice = nil;
    [self.syncingCompletionBlocks removeAllObjects];
    [self.syncingProgressBlocks removeAllObjects];
}

@end

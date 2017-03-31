//
//  BLEDevice.h
//  ItsMyLife
//
//  Created by Duy Pham on 1/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMSCBLE.h"
#import "BLEDataService.h"
#import "BLEDevice+ConnectionStatusEnum.h"

/**
 This is the object for J-Style Health Tracker
 */
@interface BLEDevice : YMSCBPeripheral

@property (nonatomic, assign) BOOL isSyncingDayDetailData;
@property (nonatomic, readonly, assign) BLEDeviceConnectionStatus status;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral central:(YMSCBCentralManager *)owner;
#warning connect methods should not be used directly, need validation in SyncService
- (void)connectAndEnable:(void (^)(NSError *error))completion;
- (void)connectAndEnableProgress:(void (^)(BLEDeviceConnectionStatus status))progress  completion:(void (^)(NSError *error))completion;
#warning disconnect methods should not be used directly, need to save state in SyncService
- (void)disconnect;
/// for transfering data between ios client and device
- (BLEDataService *)bleDataService;

@end

#import "BLEDevice+ReadWriteData.h"

//
//  BLEWrapper.h
//  ItsMyLife
//
//  Created by Duy Pham on 31/5/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BLEDevice;


@protocol BLEWrapperDelegate <NSObject>

@required
- (void)bluetoothIsDisable;

@end


@interface BLEWrapper : NSObject

+ (instancetype)shared;
/// current Bluetooth state
- (CBCentralManagerState)cb_state;
/// array of scanned and discovered BLEDevice
- (NSArray *)discoveredPeripherals;
/// wait until Bluetooth framework is initialized
- (void)setupBLEcompletion:(void (^)(CBCentralManagerState state))completion;
/// results is in cb_manager.ymsPeripherals
- (void)startScanCompletion:(void (^)(NSError *error))completion;
/// cancel all connected BLEDevice
- (void)cancelAllConnection;

#pragma mark - specific IML logic

/// this object is retained at lower level - current selected/active BLEDevice, multiple devices can be connected but app will interact with this as default
@property (nonatomic, weak) BLEDevice *activePeripheral;
/// this object is retained at lower level
@property (nonatomic, weak) BLEDevice *lastactivePeripheral;

@property (nonatomic, copy) NSString *autoConnectUUID;

@property (nonatomic, weak) id <BLEWrapperDelegate> delegate;

- (BLEDevice *)retrievePeripheralsWithIdentifier:(NSString *)uuid;
- (void)retrieveOrSearchPeripheralsWithIdentifier:(NSString *)uuid completion:(void (^)(BLEDevice *device, NSError *error))completion;

@end

#import "BLEDevice.h"

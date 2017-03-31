//
//  BLEManager.h
//  ItsMyLife
//
//  Created by Duy Pham on 1/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMSCBLE.h"

@interface BLEManager : YMSCBCentralManager

- (CBCentralManagerState)state;

- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options timeout:(NSTimeInterval)timeout withDiscoveryBlock:(void (^)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error))discoverCallback completion:(void (^)())completion;

@end

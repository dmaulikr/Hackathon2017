//
//  SyncService.h
//  ItsMyLife
//
//  Created by Duy Pham on 23/1/17.
//  Copyright © 2017 BHTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEDevice.h"


@interface SyncService : NSObject

+ (instancetype)shared;
// auto connect
- (void)autoConnectLastActiveDevice:(void (^)(BLEDevice *device, NSError *error))completion;
- (void)autoConnectLastActiveDeviceProgress:(void (^)(BLEDeviceConnectionStatus status))progress completion:(void (^)(BLEDevice *device, NSError *error))completion;
// connect
- (void)connectDevice:(BLEDevice *)device progress:(void (^)(BLEDeviceConnectionStatus status))progress completion:(void (^)(NSError *error))completion;
// disconnect
- (void)disconnectDevice:(BLEDevice *)device;
// sync
- (void)syncData:(BLEDevice *)device force:(BOOL)force progress:(void (^)(NSDate *timestamp))progress completion:(void (^)(NSError *error))completion;

@end

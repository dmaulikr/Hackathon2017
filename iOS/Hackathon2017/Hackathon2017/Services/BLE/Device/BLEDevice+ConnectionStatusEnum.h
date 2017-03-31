//
//  BLEDevice+ConnectionStatusEnum.h
//  ItsMyLife
//
//  Created by Duy Pham on 6/2/17.
//  Copyright © 2017 BHTech. All rights reserved.
//

#ifndef BLEDevice_ConnectionStatusEnum_h
#define BLEDevice_ConnectionStatusEnum_h

typedef enum : NSUInteger {
    BLEDeviceConnectionStatusDisconnected, // state Disconnecting or Disconnected
    BLEDeviceConnectionStatusReconnecting, // special state searching for devices
    BLEDeviceConnectionStatusConnecting, // state Connecting or Connected but services are not Ready
    BLEDeviceConnectionStatusConnected, // state Connected and services are Ready
} BLEDeviceConnectionStatus;

#endif /* BLEDevice_ConnectionStatusEnum_h */

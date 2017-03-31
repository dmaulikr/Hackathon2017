//
//  BLEDataWriteCharacteristic.m
//  ItsMyLife
//
//  Created by Duy Pham on 1/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "BLEDataWriteCharacteristic.h"

#define THIS_TI_KEYFOB_ACCEL_X_WTIRE_UUID                        0xFFF6 // senddata


@implementation BLEDataWriteCharacteristic

- (instancetype)initWithParent:(YMSCBService *)parent {
    NSString *addrString = [NSString stringWithFormat:@"%x", THIS_TI_KEYFOB_ACCEL_X_WTIRE_UUID];
    CBUUID *uuid = [CBUUID UUIDWithString:addrString];
    
    self = [super initWithName:[[self class] name]parent:parent.parent uuid:uuid offset:THIS_TI_KEYFOB_ACCEL_X_WTIRE_UUID];
    
    if (self != nil) {
    }
    
    return self;
}

+ (NSString *)name {
    static NSString * const BLEDataWriteCharacteristicName = @"svc_data_write";
    return BLEDataWriteCharacteristicName;
}

@end

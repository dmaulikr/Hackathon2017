//
//  BLEDataReadCharacteristic.m
//  ItsMyLife
//
//  Created by Duy Pham on 2/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "BLEDataReadCharacteristic.h"

#define THIS_TI_KEYFOB_ACCEL_X_UUID                              0xFFF7 //0xFFA3 - TI


@implementation BLEDataReadCharacteristic

- (instancetype)initWithParent:(YMSCBService *)parent {
    NSString *addrString = [NSString stringWithFormat:@"%x", THIS_TI_KEYFOB_ACCEL_X_UUID];
    CBUUID *uuid = [CBUUID UUIDWithString:addrString];
    
    self = [super initWithName:[[self class] name] parent:parent.parent uuid:uuid offset:THIS_TI_KEYFOB_ACCEL_X_UUID];
    
    if (self != nil) {
    }
    
    return self;
}

+ (NSString *)name {
    static NSString * const BLEDataReadCharacteristicName = @"svc_data_read";
    return BLEDataReadCharacteristicName;
}

@end

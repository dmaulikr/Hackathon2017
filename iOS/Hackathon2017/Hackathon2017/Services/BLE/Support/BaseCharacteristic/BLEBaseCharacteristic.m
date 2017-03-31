//
//  BLEBaseCharacteristic.m
//  ItsMyLife
//
//  Created by Duy Pham on 2/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "BLEBaseCharacteristic.h"

@implementation BLEBaseCharacteristic

- (instancetype)initWithParent:(YMSCBService *)parent {
    NSAssert(NO, @"[BLEBaseCharacteristic initWithParent:] must be overridden.");
    return nil;
}

+ (NSString *)name {
    NSAssert(NO, @"[BLEBaseCharacteristic name] must be overridden.");
    return nil;
}

@end


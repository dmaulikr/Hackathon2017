//
//  BLEBaseCharacteristic.h
//  ItsMyLife
//
//  Created by Duy Pham on 2/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "YMSCBLE.h"

@interface BLEBaseCharacteristic : YMSCBCharacteristic

- (instancetype)initWithParent:(YMSCBService *)parent;

+ (NSString *)name;

@end

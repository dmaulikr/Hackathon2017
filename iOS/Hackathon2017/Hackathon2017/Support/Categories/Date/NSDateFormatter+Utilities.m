//
//  NSDateFormatter+Utilities.m
//  ItsMyLife
//
//  Created by DuongPV on 8/18/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import "NSDateFormatter+Utilities.h"

@implementation NSDateFormatter (Utilities)

- (id)initWithLocaleIdentifier:(NSString *)localeID
{
    self = [self init];
    if (self) {
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:localeID];
        [self setLocale:usLocale];
    }
    return self;
}

@end

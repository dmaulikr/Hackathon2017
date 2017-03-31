//
//  IntervalDetail.m
//  ItsMyLife
//
//  Created by Duy Pham on 5/8/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import "IntervalDetail.h"

@interface IntervalDetail ()
- (instancetype)init;
@end

@implementation IntervalDetail
- (instancetype)init {
    return nil;
}

- (instancetype)initActiveWithNum:(UInt8)num calories:(UInt16)calories steps:(UInt16)steps distance:(UInt16)distance {
    if (num < 0x60) {
        self = [super init];
        if (self != nil) {
            _intervalNum   = num;
            _calories      = calories;
            _steps         = steps;
            _distance      = distance;
            _sleepTime     = 0;
            _deepSleepTime = 0;
            if (_steps == 0) {
                _type = IntervalTypePassive;
            }
            else {
                _type = IntervalTypeActive;
            }
        }
        return self;
    }
    return nil;
}

- (instancetype)initSleepWithNum:(UInt8)num sleepTime:(UInt16)sleepTime deepSleepTime:(UInt16)deepTime {
    if (num < 0x60) {
        self = [super init];
        if (self != nil) {
            _type = IntervalTypeSleep;
            _intervalNum   = num;
            _calories      = 0;
            _steps         = 0;
            _distance      = 0;
            _sleepTime     = sleepTime;
            _deepSleepTime = deepTime;
        }
        return self;
    }
    return nil;
}
@end

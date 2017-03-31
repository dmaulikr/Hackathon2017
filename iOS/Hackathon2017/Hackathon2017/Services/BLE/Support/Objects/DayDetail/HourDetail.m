//
//  HourDetail.m
//  ItsMyLife
//
//  Created by Duy Pham on 5/8/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import "HourDetail.h"
#import "IntervalDetail.h"

#import "NSDate+Utilities.h"

@interface HourDetail ()
- (instancetype)init;
@end

@implementation HourDetail {
    UInt8 _hour;
}
- (instancetype)init {
    return nil;
}

- (instancetype)initWithHour:(NSDate *)hour intervalDetails:(NSArray * /* IntervalDetail */)inArray {
    self = [super init];
    if (self != nil) {
        _timestamp = [hour copy];
        _hour = [_timestamp hour] & 0xFF;
        UInt32 total_distance  = 0;
        UInt32 total_calories  = 0;
        UInt32 total_steps     = 0;
        UInt32 total_bedtime   = 0;
        UInt32 total_goodsleep = 0;
        UInt32 total_passivity = 0;
        if ([inArray count] > 0) {
            // summarize data
            NSUInteger count = [inArray count];
            NSUInteger i = 0;
            for (i = 0; i < count; i++) {
                id obj = [inArray objectAtIndex:i];
                if (obj != nil && [obj isKindOfClass:[IntervalDetail class]]) {
                    IntervalDetail * inDetail = (IntervalDetail *)obj;
                    if (inDetail.intervalNum >= _hour*4 && inDetail.intervalNum < (_hour+1)*4) {
                        switch (inDetail.type) {
                            case IntervalTypeActive:
                                total_passivity += 0;
                                total_distance += inDetail.distance;
                                total_calories += inDetail.calories;
                                total_steps    += inDetail.steps;
                                break;
                            case IntervalTypePassive:
                                total_passivity += 15*60;
                                total_distance += inDetail.distance;
                                total_calories += inDetail.calories;
                                total_steps    += inDetail.steps;
                                break;
                            case IntervalTypeSleep:
                                total_passivity += 0;
                                total_bedtime   += inDetail.sleepTime;
                                total_goodsleep += inDetail.deepSleepTime;
                                break;
                            default:
                                return nil;
                                break;
                        }
                    }
                    else {
                        return nil;
                    }
                }
                else {
                    return nil;
                }
            }
        }
        _distance  = total_distance * 10;   // By default, distance unit from BT device is 10m. This converts that unit to m.
        _calories  = total_calories;
        _steps     = total_steps;
        if (_hour >= 22 || _hour < 7) {
            _passivity = 0;
        }
        else {
            _passivity = total_passivity >= 30*60 ? total_passivity : 0;
        }
        _bedtime   = total_bedtime;
        _goodsleep = total_goodsleep;
        _running_steps = 0;
        _points = _steps;
    }
    return self;
}

@end

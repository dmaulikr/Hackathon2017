//
//  DayDetail.m
//  ItsMyLife
//
//  Created by Duy Pham on 6/8/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import "DayDetail.h"
#import "NSArray+Filter.h"
#import "NSDate+Utilities.h"

@interface DayDetail ()
- (instancetype)init;
@end

@implementation DayDetail

- (instancetype)init {
    return nil;
}

- (instancetype)initWithDay:(NSDate *)day intervalDetails:(NSArray * /* IntervalDetail */)inArray {
    if ([inArray count] > 0) {
        self = [super init];
        if (self != nil) {
            _day = day.dateAtStartOfDay;
            _intervals = inArray;
        }
        return self;
    }
    return nil;
}

- (BOOL)hasData {
    return (_intervals != nil && [_intervals count] > 0);
}

- (HourDetail *)detailForHour:(UInt8)hour {
    NSDate * now= [NSDate date];
    if (hour > 23 || ([[_day sameDayAtHour:hour minute:0] hoursBeforeDate:now] < 1)) {
        return nil;
    }
    
    return [[HourDetail alloc] initWithHour:[_day sameDayAtHour:hour minute:0] intervalDetails:[_intervals filteredArrayUsingBlock:^BOOL(IntervalDetail * obj, NSUInteger idx, BOOL *stop) {
        return (obj.intervalNum >= hour*4 && obj.intervalNum < (hour+1)*4);
    }]];
}

- (NSArray *)detailForHours {
    NSMutableArray *ret = [NSMutableArray array];
    for (UInt8 i = 0; i < 24; i++) {
        HourDetail * hourDetail = [self detailForHour:i];
        if (hourDetail) [ret addObject:hourDetail];
    }
    return [NSArray arrayWithArray:ret];
}

- (IntervalDetail *)detailForInterval:(UInt8)interval {
    if (interval >= 0x60) {
        return nil;
    }
    return [_intervals filteredObjectUsingBlock:^BOOL(IntervalDetail * obj, NSUInteger idx, BOOL *stop) {
        return (obj.intervalNum == interval);
    }];
}

@end

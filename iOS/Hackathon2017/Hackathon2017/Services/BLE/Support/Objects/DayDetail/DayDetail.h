//
//  DayDetail.h
//  ItsMyLife
//
//  Created by Duy Pham on 6/8/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntervalDetail.h"
#import "HourDetail.h"

@interface DayDetail : NSObject

@property (nonatomic, readonly, strong) NSDate * day;
@property (nonatomic, readonly, strong) NSArray * intervals;

- (instancetype)initWithDay:(NSDate *)day intervalDetails:(NSArray * /* IntervalDetail */)inArray;
- (BOOL)hasData;
- (HourDetail *)detailForHour:(UInt8)hour;
- (NSArray *)detailForHours;
- (IntervalDetail *)detailForInterval:(UInt8)interval;

@end

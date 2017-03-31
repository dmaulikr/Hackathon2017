//
//  HourDetail.h
//  ItsMyLife
//
//  Created by Duy Pham on 5/8/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HourDetail : NSObject

// timezone_name & ￼timezone_offset is not included here
// running_steps = 0, because device is not able to track these - see email
// points = steps
@property (nonatomic, readonly, strong) NSDate * timestamp; // use category of NSDate for quick access to hour number
@property (nonatomic, readonly, assign) UInt32 distance; // CGFloat?
@property (nonatomic, readonly, assign) UInt32 calories; // CGFloat?
@property (nonatomic, readonly, assign) UInt32 steps;
@property (nonatomic, readonly, assign) UInt32 running_steps;
@property (nonatomic, readonly, assign) UInt32 points;
@property (nonatomic, readonly, assign) UInt32 passivity; // calculated from steps value
@property (nonatomic, readonly, assign) UInt32 bedtime; // total sleep duration
@property (nonatomic, readonly, assign) UInt32 goodsleep; // deep sleep duration
// passivity & bedtime & goodsleep are in seconds, smaller than 3600 so even UInt16 is enough, use UInt32

- (instancetype)initWithHour:(NSDate *)hour intervalDetails:(NSArray * /* IntervalDetail */)inArray; // hour from 0-23

@end

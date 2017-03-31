//
//  IntervalDetail.h
//  ItsMyLife
//
//  Created by Duy Pham on 5/8/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt8, IntervalType) {
    IntervalTypeActive,
    IntervalTypePassive,
    IntervalTypeSleep
};

@interface IntervalDetail : NSObject

@property (nonatomic, readonly, assign) IntervalType type;
@property (nonatomic, readonly, assign) UInt8 intervalNum; // ranging from 0x00 to 0x5F - 15-minute block
// active
@property (nonatomic, readonly, assign) UInt16 calories;
@property (nonatomic, readonly, assign) UInt16 steps;
@property (nonatomic, readonly, assign) UInt16 distance;
// sleep
@property (nonatomic, readonly, assign) UInt16 sleepTime;
@property (nonatomic, readonly, assign) UInt16 deepSleepTime;

- (instancetype)initActiveWithNum:(UInt8)num calories:(UInt16)calories steps:(UInt16)steps distance:(UInt16)distance;
- (instancetype)initSleepWithNum:(UInt8)num sleepTime:(UInt16)sleepTime deepSleepTime:(UInt16)deepTime;
@end

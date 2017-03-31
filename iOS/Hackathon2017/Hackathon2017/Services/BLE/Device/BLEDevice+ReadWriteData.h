//
//  BLEDevice+ReadWriteData.h
//  ItsMyLife
//
//  Created by Duy Pham on 2/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "BLEDevice.h"
#import <AvailabilityMacros.h>

@class DayDetail;


@interface BLEDevice (ReadWriteData)

// response is success - error is nil, response is failure - error is AppErrorFailed

- (void)getDeviceNameCompletion:(void (^)(NSError *error, NSString *name))completion;

- (void)setDeviceName:(NSString *)name completion:(void (^)(NSError *error))completion;

- (void)getTimeModeCompletion:(void (^)(NSError *error, BOOL is24Hour))completion;

- (void)setTimeMode:(BOOL)is24Hour completion:(void (^)(NSError *error))completion;

- (void)getDistanceUnitCompletion:(void (^)(NSError *error, BOOL isImperial))completion;

- (void)setDistanceUnit:(BOOL)isImperial completion:(void (^)(NSError *error))completion;

- (void)getGoalCompletion:(void (^)(NSError *error, uint32_t personalGoal, uint32_t companyGoal))completion;

- (void)setGoal:(uint32_t)personalGoal completion:(void (^)(NSError *error))completion;

- (void)getSittingReminderTimeCompletion:(void (^)(NSError *error, NSDate *startTime, NSDate *endTime, uint8_t intervalMinutes))completion;

- (void)setSittingReminderTimeStart:(NSDate *)startTime end:(NSDate *)endTime interval:(uint8_t)intervalMinutes completion:(void (^)(NSError *error))completion;

- (void)getTimeCompletion:(void (^)(NSError *error, NSDate *time))completion;

- (void)setTime:(NSDate *)time completion:(void (^)(NSError *error))completion;

- (void)getAttributesCompletion:(void (^)(NSError *error, BOOL genderMale, uint8_t age, uint8_t heightCm, uint8_t weightKg, uint8_t stepLengthCm))completion DEPRECATED_MSG_ATTRIBUTE("deprecated in favor of getAttributesAndSerialNumCompletion");

- (void)getAttributesAndSerialNumCompletion:(void (^)(NSError *error, BOOL genderMale, uint8_t age, uint8_t heightCm, uint8_t weightKg, uint8_t stepLengthCm, NSString *serialNumber))completion;;

- (void)setAttributesGender:(BOOL)genderMale age:(uint8_t)age height:(uint8_t)heightCm weight:(uint8_t)weightKg stepLength:(uint8_t)stepLengthCm completion:(void (^)(NSError *error))completion;

- (void)getOnedayTotalFromDaysAgo:(uint8_t)days completion:(void (^)(NSError *error, uint32_t steps, double_t calories, double_t distance, uint32_t stepTimes, NSDate *date))completion;

- (void)getOnedayGoalRateFromDaysAgo:(uint8_t)days completion:(void (^)(NSError *error, uint16_t personalGoal, uint16_t companyGoal, uint16_t sportSpeed, uint16_t exValue, NSDate *date))completion;

- (void)getOnedayDetailFromDaysAgo:(uint8_t)days completion:(void (^)(NSError *error, DayDetail *dayDetail))completion; // didGetOnedayDetail

// special purpose methods
- (void)resetDeviceCompletion:(void (^)(NSError *error))completion;


#pragma mark Heart Rate
- (void)setHeartRateMonitor:(BOOL)isOn completion:(void (^)(NSError *error))completion valueUpdated:(void (^)(uint8_t heartRateValue))progress;


@end

//
//  BLEDevice+ReadWriteData.m
//  ItsMyLife
//
//  Created by Duy Pham on 2/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "BLEDevice+ReadWriteData.h"
#import "BLEDevice+ReadWriteData+Enum.h"
#import "BLEDataService.h"
#import "BLE_Byte_Offset.h"

#import "DayDetail.h"
#import "IntervalDetail.h"

#import "NSError+app.h"
#import "NSDate+Utilities.h"

static inline uint8_t decimalFromDeviceHex(uint8_t deviceHex) {
    return (UInt8)((((deviceHex >> 4) & 0x0F) * 10) + (deviceHex & 0x0F));
}

static inline uint8_t deviceHexFromDecimal(uint8_t decimal) {
    return (UInt8)((UInt8)(decimal / 10) * 16 + decimal % 10);
}

@implementation BLEDevice (ReadWriteData)

- (void)getDeviceNameCompletion:(void (^)(NSError *, NSString *))completion {
#warning missing implementation
}

- (void)setDeviceName:(NSString *)name completion:(void (^)(NSError *))completion {
#warning seems to be not working
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    [name cStringUsingEncoding:NSUTF8StringEncoding];
    send[0] = DATA_SET_DEVICE_NAME; // command
    while (![name getCString:(char *)(send + 1) maxLength:14 encoding:NSUTF8StringEncoding]) {
        // truncate until it fits in array
        name = [name substringToIndex:[name length] - 1];
    }
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_SET_DEVICE_NAME),@(DATA_SET_DEVICE_NAME_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse]);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_SET_DEVICE_NAME) {
            completion(nil);
        } else if (data[0] == DATA_SET_DEVICE_NAME_ERR) {
            completion([NSError error:AppErrorFailed]);
        } else {
            completion([NSError error:AppErrorInvalidResponse]);
        }
    }];
}

- (void)getTimeModeCompletion:(void (^)(NSError *, BOOL))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_READ_TIMEMODE; // command
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_READ_TIMEMODE),@(DATA_READ_TIMEMODE_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error, FALSE);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse], FALSE);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_READ_TIMEMODE) {
            completion(nil, (data[1] == 0x01));
        } else if (data[0] == DATA_READ_TIMEMODE_ERR) {
            completion([NSError error:AppErrorFailed], FALSE);
        } else {
            completion([NSError error:AppErrorInvalidResponse], FALSE);
        }
    }];
}

- (void)setTimeMode:(BOOL)is24Hour completion:(void (^)(NSError *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_SET_TIME; // command
    send[1] = is24Hour ? 0x01 : 0x00;
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_SET_TIME),@(DATA_SET_TIME_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse]);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_SET_TIME) {
            completion(nil);
        } else if (data[0] == DATA_SET_TIME_ERR) {
            completion([NSError error:AppErrorFailed]);
        } else {
            completion([NSError error:AppErrorInvalidResponse]);
        }
    }];
}

- (void)getDistanceUnitCompletion:(void (^)(NSError *, BOOL))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_READ_DISTACE_UNIT; // command
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_READ_DISTACE_UNIT),@(DATA_READ_DISTACE_UNIT_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error, FALSE);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse], FALSE);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_READ_DISTACE_UNIT) {
            completion(nil, (data[1] == 0x01));
        } else if (data[0] == DATA_READ_DISTACE_UNIT_ERR) {
            completion([NSError error:AppErrorFailed], FALSE);
        } else {
            completion([NSError error:AppErrorInvalidResponse], FALSE);
        }
    }];
}

- (void)setDistanceUnit:(BOOL)isImperial completion:(void (^)(NSError *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_WRITE_DISTACE_UNIT; // command
    send[1] = isImperial ? 0x01 : 0x00;
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_WRITE_DISTACE_UNIT),@(DATA_WRITE_DISTACE_UNIT_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse]);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_WRITE_DISTACE_UNIT) {
            completion(nil);
        } else if (data[0] == DATA_WRITE_DISTACE_UNIT_ERR) {
            completion([NSError error:AppErrorFailed]);
        } else {
            completion([NSError error:AppErrorInvalidResponse]);
        }
    }];
}

- (void)getGoalCompletion:(void (^)(NSError *, uint32_t, uint32_t))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_READ_GOAL; // command
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_READ_GOAL),@(DATA_READ_GOAL_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error, 0, 0);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse], 0, 0);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_READ_GOAL) {
            uint32_t persongoaldata = 0, companygoaldata = 0;
            
            persongoaldata  = persongoaldata + (data[1] <<16) + (data[2] <<8) + data[3];
            companygoaldata = companygoaldata + (data[4] <<16) + (data[5] <<8) + data[6];
            
            completion(nil, persongoaldata, companygoaldata);
        } else if (data[0] == DATA_READ_GOAL_ERR) {
            completion([NSError error:AppErrorFailed], 0, 0);
        } else {
            completion([NSError error:AppErrorInvalidResponse], 0, 0);
        }
    }];
}

- (void)setGoal:(uint32_t)personalGoal completion:(void (^)(NSError *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_WRITE_GOAL; // command
    send[1] = 0xFF & (personalGoal >>16);
    send[2] = 0xFF & (personalGoal >>8);
    send[3] = 0xFF &  personalGoal;
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_WRITE_GOAL),@(DATA_WRITE_GOAL_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse]);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_WRITE_GOAL) {
            completion(nil);
        } else if (data[0] == DATA_WRITE_GOAL_ERR) {
            completion([NSError error:AppErrorFailed]);
        } else {
            completion([NSError error:AppErrorInvalidResponse]);
        }
    }];
}

- (void)getSittingReminderTimeCompletion:(void (^)(NSError *, NSDate *, NSDate *, uint8_t))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_READ_SPORT_TIME; // command
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_READ_SPORT_TIME),@(DATA_READ_SPORT_TIME_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error, nil, nil, 0);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse], nil, nil, 0);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_READ_SPORT_TIME) {
            uint8_t
            startHour   = decimalFromDeviceHex(data[1]),
            startMinute = decimalFromDeviceHex(data[2]),
            endHour     = decimalFromDeviceHex(data[3]),
            endMinute   = decimalFromDeviceHex(data[4]),
            intervalMinutes = decimalFromDeviceHex(data[6]);
            
            NSDate *startTime = [[NSDate date] sameDayAtHour:startHour minute:startMinute],
            *endTime = [[NSDate date] sameDayAtHour:endHour minute:endMinute];
            
            completion(nil, startTime, endTime, intervalMinutes);
        } else if (data[0] == DATA_READ_SPORT_TIME_ERR) {
            completion([NSError error:AppErrorFailed], nil, nil, 0);
        } else {
            completion([NSError error:AppErrorInvalidResponse], nil, nil, 0);
        }
    }];
}

- (void)setSittingReminderTimeStart:(NSDate *)startTime end:(NSDate *)endTime interval:(uint8_t)intervalMinutes completion:(void (^)(NSError *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_SETTING_SPORT_TIME; // command
    send[1] = deviceHexFromDecimal(0xFF & [startTime hour]);
    send[2] = deviceHexFromDecimal(0xFF & [startTime minute]);
    send[3] = deviceHexFromDecimal(0xFF & [endTime hour]);
    send[4] = deviceHexFromDecimal(0xFF & [endTime minute]);
    send[5] = 0xFF;
    send[6] = deviceHexFromDecimal(0xFF & intervalMinutes);
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_SETTING_SPORT_TIME),@(DATA_SETTING_SPORT_TIME_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse]);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_SETTING_SPORT_TIME) {
            completion(nil);
        } else if (data[0] == DATA_SETTING_SPORT_TIME_ERR) {
            completion([NSError error:AppErrorFailed]);
        } else {
            completion([NSError error:AppErrorInvalidResponse]);
        }
    }];
}

- (void)getTimeCompletion:(void (^)(NSError *, NSDate *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_CURRENT_TIMER; // command
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_CURRENT_TIMER),@(DATA_CURRENT_TIMER_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error, nil);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse], nil);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_CURRENT_TIMER) {
            uint8_t
            year   = decimalFromDeviceHex(data[1]),
            month  = decimalFromDeviceHex(data[2]),
            day    = decimalFromDeviceHex(data[3]),
            hour   = decimalFromDeviceHex(data[4]),
            minute = decimalFromDeviceHex(data[5]),
            second = decimalFromDeviceHex(data[6]);
            
            NSDateComponents *components = [[NSDate currentCalendar] components:(NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
            components.year = (components.year - components.year % 100) + year;
            components.month = month;
            components.day = day;
            components.hour = hour;
            components.minute = minute;
            components.second = second;
            NSDate *time = [[NSDate currentCalendar] dateFromComponents:components];
            
            completion(nil, time);
        } else if (data[0] == DATA_CURRENT_TIMER_ERR) {
            completion([NSError error:AppErrorFailed], nil);
        } else {
            completion([NSError error:AppErrorInvalidResponse], nil);
        }
    }];
}

- (void)setTime:(NSDate *)time completion:(void (^)(NSError *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_SETTING_TIMER; // command
    send[1] = deviceHexFromDecimal([time year] % 100);
    send[2] = deviceHexFromDecimal([time month]);
    send[3] = deviceHexFromDecimal([time day]);
    send[4] = deviceHexFromDecimal([time hour]);
    send[5] = deviceHexFromDecimal([time minute]);
    send[6] = deviceHexFromDecimal([time seconds]);
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_SETTING_TIMER),@(DATA_SETTING_TIMER_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse]);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_SETTING_TIMER) {
            completion(nil);
        } else if (data[0] == DATA_SETTING_TIMER_ERR) {
            completion([NSError error:AppErrorFailed]);
        } else {
            completion([NSError error:AppErrorInvalidResponse]);
        }
    }];
}

- (void)getAttributesCompletion:(void (^)(NSError *, BOOL, uint8_t, uint8_t, uint8_t, uint8_t))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_READ_ATTRIBUTE; // command
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_READ_ATTRIBUTE),@(DATA_READ_ATTRIBUTE_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error, FALSE, 0, 0, 0, 0);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse], FALSE, 0, 0, 0, 0);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_READ_ATTRIBUTE) {
            BOOL genderMale = (data[1] == 0);
            uint8_t
            age  = data[2],
            heightCm = data[3],
            weightKg = data[4],
            stepLengthCm = data[5];
            
            completion(nil, genderMale, age, heightCm, weightKg, stepLengthCm);
        } else if (data[0] == DATA_READ_ATTRIBUTE_ERR) {
            completion([NSError error:AppErrorFailed], FALSE, 0, 0, 0, 0);
        } else {
            completion([NSError error:AppErrorInvalidResponse], FALSE, 0, 0, 0, 0);
        }
    }];
}

- (void)getAttributesAndSerialNumCompletion:(void (^)(NSError *, BOOL, uint8_t, uint8_t, uint8_t, uint8_t, NSString *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_READ_ATTRIBUTE; // command
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_READ_ATTRIBUTE),@(DATA_READ_ATTRIBUTE_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error, FALSE, 0, 0, 0, 0, nil);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse], FALSE, 0, 0, 0, 0, nil);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_READ_ATTRIBUTE) {
            BOOL genderMale = (data[1] == 0);
            uint8_t
            age  = data[2],
            heightCm = data[3],
            weightKg = data[4],
            stepLengthCm = data[5];
            
            NSMutableString *serial = [NSMutableString string];
            for (uint8_t i = 6; i < 12; i++) {
                [serial appendFormat:@"%02d", decimalFromDeviceHex(data[i])];
            }
            
            completion(nil, genderMale, age, heightCm, weightKg, stepLengthCm, [NSString stringWithString:serial]);
        } else if (data[0] == DATA_READ_ATTRIBUTE_ERR) {
            completion([NSError error:AppErrorFailed], FALSE, 0, 0, 0, 0, nil);
        } else {
            completion([NSError error:AppErrorInvalidResponse], FALSE, 0, 0, 0, 0, nil);
        }
    }];
}

- (void)setAttributesGender:(BOOL)genderMale age:(uint8_t)age height:(uint8_t)heightCm weight:(uint8_t)weightKg stepLength:(uint8_t)stepLengthCm completion:(void (^)(NSError *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_WRITE_ATTRIBUTE; // command
    send[1] = genderMale ? 0x00 : 0x01;
    send[2] = age;
    send[3] = heightCm;
    send[4] = weightKg;
    send[5] = stepLengthCm;
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_WRITE_ATTRIBUTE),@(DATA_WRITE_ATTRIBUTE_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse]);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_WRITE_ATTRIBUTE) {
            completion(nil);
        } else if (data[0] == DATA_WRITE_ATTRIBUTE_ERR) {
            completion([NSError error:AppErrorFailed]);
        } else {
            completion([NSError error:AppErrorInvalidResponse]);
        }
    }];
}

- (void)getOnedayTotalFromDaysAgo:(uint8_t)days completion:(void (^)(NSError *, uint32_t, double_t, double_t, uint32_t, NSDate *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_READ_ONEDAY; // command
    send[1] = days;
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_READ_ONEDAY),@(DATA_READ_ONEDAY_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error, 0, 0, 0, 0, nil);
            return;
        } else if ([readdatas count] < 2) {
            completion([NSError error:AppErrorInvalidResponse], 0, 0, 0, 0, nil);
            return;
        } else {
        }
        
        NSDate *date;
        uint32_t
        totalsteps = 0,
        totalcalories100 = 0,
        totaldistance100 = 0,
        totaltimes = 0;
        
        for (NSData *readdata in readdatas) {
            uint8_t data[16];
            [readdata getBytes:&data length:16];
            
            if (data[0] == DATA_READ_ONEDAY) {
                uint8_t
                year   = decimalFromDeviceHex(data[3]),
                month  = decimalFromDeviceHex(data[4]),
                day    = decimalFromDeviceHex(data[5]);
                
                date = [NSDate dateWithYear:year month:month day:day];
                
                if (data[1] == 0) { // steps & calories
                    totalsteps = totalsteps + (data[6] << 16) + (data[7] << 8) + data[8];
                    totalcalories100 = totalcalories100 + (data[12] << 16) + (data[13] << 8) + data[14];
                } else if (data[1] ==1) { // distance & time
                    totaldistance100 = totaldistance100 + (data[6] <<16) + (data[7] <<8) + data[8];
                    totaltimes = totaltimes + (data[9] <<8) + data[10];
                }
            } else if (data[0] == DATA_READ_ONEDAY_ERR) {
                completion([NSError error:AppErrorFailed], 0, 0, 0, 0, nil);
                return;
            } else {
                completion([NSError error:AppErrorInvalidResponse], 0, 0, 0, 0, nil);
                return;
            }
        }
        
        double_t totalcalories = ((double_t)totalcalories100) / 100.0;
        double_t totaldistance = ((double_t)totaldistance100) / 100.0;
        
        completion(nil, totalsteps, totalcalories, totaldistance, totaltimes, date);
    }];
}

- (void)getOnedayGoalRateFromDaysAgo:(uint8_t)days completion:(void (^)(NSError *, uint16_t, uint16_t, uint16_t, uint16_t, NSDate *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_READ_ONEDAY_GOALRATE; // command
    send[1] = days;
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_READ_ONEDAY_GOALRATE),@(DATA_READ_ONEDAY_GOALRATE_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error, 0, 0, 0, 0, nil);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse], 0, 0, 0, 0, nil);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        NSDate *date;
        uint16_t
        sportspeed = 0,
        exvalue = 0,
        persongoal = 0,
        companygoal = 0;
        
        if (data[0] == DATA_READ_ONEDAY_GOALRATE) {
            uint8_t
            year   = decimalFromDeviceHex(data[2]),
            month  = decimalFromDeviceHex(data[3]),
            day    = decimalFromDeviceHex(data[4]);
            
            date = [NSDate dateWithYear:year month:month day:day];
            
            sportspeed  = sportspeed  + (data[6]  << 8) + data[7];
            exvalue     = exvalue     + (data[8]  << 8) + data[9];
            persongoal  = persongoal  + (data[11] << 8) + data[12];
            companygoal = companygoal + (data[13] << 8) + data[14];
            
            completion(nil, persongoal, companygoal, sportspeed, exvalue, date);
        } else if (data[0] == DATA_READ_ONEDAY_GOALRATE_ERR) {
            completion([NSError error:AppErrorFailed], 0, 0, 0, 0, nil);
        } else {
            completion([NSError error:AppErrorInvalidResponse], 0, 0, 0, 0, nil);
        }
    }];
}

- (void)getOnedayDetailFromDaysAgo:(uint8_t)days completion:(void (^)(NSError *, DayDetail *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_ONEDAY_DETAIL; // command
    send[1] = days;
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_ONEDAY_DETAIL),@(DATA_ONEDAY_DETAIL_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error, nil);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse], nil);
            return;
        } else {
        }
        
         // NOTE: normally 96 data packets for 15 minutes interval for a day, or 1 time for error 43ff...
        NSDate *currentDate, *dataDate;
        NSMutableArray *intervalsArray = [NSMutableArray array];
        
        for (NSData *readdata in readdatas) {
            uint8_t data[16];
            [readdata getBytes:&data length:16];
            
            if (data[0] == DATA_ONEDAY_DETAIL) {
                // process date
                uint8_t
                year   = decimalFromDeviceHex(data[DETAIL_DATA_YEAR]),
                month  = decimalFromDeviceHex(data[DETAIL_DATA_MONTH]),
                day    = decimalFromDeviceHex(data[DETAIL_DATA_DAY]);
                
                dataDate = [NSDate dateWithYear:year month:month day:day];
                
                if (currentDate == nil) {
                    currentDate = dataDate;
                } else if (![currentDate isSameDayAsDate:dataDate]) {
                    completion(nil, [[DayDetail alloc] initWithDay:currentDate intervalDetails:intervalsArray]);
                    return;
                } else {
                }
                // process data
                if (data[DETAIL_DATA_ERROR] == 0xFF) {
                    completion(nil, [[DayDetail alloc] initWithDay:currentDate intervalDetails:nil]);
                    return;
                }
                else {
                    IntervalDetail * inDetail = nil;
                    
                    if (data[DETAIL_DATA_TYPE] == 0xFF) { // means sleep
                        uint16_t deepSleepMinute = 0;
                        
                        for (int i = DETAIL_DATA_SLEEP0; i < DETAIL_DATA_SLEEP7; i++) {
                            if (data[i] < 3) {
                                deepSleepMinute += 2;
                            }
                        }
                        
                        if (data[DETAIL_DATA_SLEEP7] < 3) {
                            deepSleepMinute += 1;
                        }
                        
                        inDetail = [[IntervalDetail alloc] initSleepWithNum:data[DETAIL_DATA_TIME] sleepTime:(15 * 60) deepSleepTime:(deepSleepMinute * 60)];
                    } else if (data[DETAIL_DATA_TYPE] == 0x00) { // means active
                        uint16_t calories = (data[DETAIL_DATA_CALORIES_H] << 8) + data[DETAIL_DATA_CALORIES_L];
                        uint16_t steps    = (data[DETAIL_DATA_STEP_H]     << 8) + data[DETAIL_DATA_STEP_L];
                        uint16_t distance = (data[DETAIL_DATA_DISTANCE_H] << 8) + data[DETAIL_DATA_DISTANCE_L];
                        
                        inDetail = [[IntervalDetail alloc] initActiveWithNum:data[DETAIL_DATA_TIME] calories:calories steps:steps distance:distance];
                    } else {
                        completion([NSError error:AppErrorInvalidResponse], nil);
                        return;
                    }
                    
                    if (inDetail != nil) {
                        [intervalsArray addObject:inDetail];
                    } else {
                        completion([NSError error:AppErrorInvalidResponse], nil);
                        return;
                    }
                }
                
            } else if (data[0] == DATA_ONEDAY_DETAIL_ERR) {
                completion([NSError error:AppErrorFailed], nil);
                return;
            } else {
                completion([NSError error:AppErrorInvalidResponse], nil);
                return;
            }
        }
        
        completion(nil, [[DayDetail alloc] initWithDay:currentDate intervalDetails:intervalsArray]);
    }];
}

- (void)resetDeviceCompletion:(void (^)(NSError *))completion {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_RESET; // command
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    [ds senddata:send accepted:@[@(DATA_RESET),@(DATA_RESET_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse]);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_RESET) {
            completion(nil);
        } else if (data[0] == DATA_RESET_ERR) {
            completion([NSError error:AppErrorFailed]);
        } else {
            completion([NSError error:AppErrorInvalidResponse]);
        }
    }];
}

- (void)setHeartRateMonitor:(BOOL)isOn completion:(void (^)(NSError *))completion valueUpdated:(void (^)(uint8_t))progress {
    uint8_t send[16];
    memset(send, 0, 16);
    // parameters
    send[0] = DATA_HEART_RATE_MONITOR; // command
    send[1] = isOn ? 0x01 : 0x00;
    // send
    BLEDataService *ds = self.serviceDict[[BLEDataService name]];
    // handle notified value first
    if (isOn) {
        [ds registerNotification:DATA_HEART_RATE_MONITOR notifyBlock:^(NSData *readdata) {
            uint8_t data[16];
            [(NSData *)readdata getBytes:&data length:16];
            
            if (data[0] == DATA_HEART_RATE_MONITOR && data[1] != 0x00) {
                // value updated
                progress(data[1]);
            } else {
                completion([NSError error:AppErrorInvalidResponse]);
            }
        }];
    } else {
        [ds unRegisterNotification:DATA_HEART_RATE_MONITOR];
    }
    
    // handle setting up
    [ds senddata:send accepted:@[@(DATA_HEART_RATE_MONITOR),@(DATA_HEART_RATE_MONITOR_ERR)] completion:^(NSError *error, NSArray *readdatas) {
        // receive
        if (error) {
            completion(error);
            return;
        } else if ([readdatas count] < 1) {
            completion([NSError error:AppErrorInvalidResponse]);
            return;
        } else {
        }
        
        uint8_t data[16];
        [(NSData *)(readdatas[0]) getBytes:&data length:16];
        
        if (data[0] == DATA_HEART_RATE_MONITOR && data[1] == 0x00) {
            // setup success
            completion(nil);
        } else if (data[0] == DATA_HEART_RATE_MONITOR_ERR) {
            completion([NSError error:AppErrorFailed]);
        } else {
            completion([NSError error:AppErrorInvalidResponse]);
        }
    }];
}

@end

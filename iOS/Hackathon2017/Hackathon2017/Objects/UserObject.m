//
//  UserObject.m
//  ItsMyLife
//
//  Created by DuongPV on 6/9/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import "UserObject.h"
#import "Configurations.h"
#import "NSDate+Utilities.h"

@implementation UserObject

static UserObject * singleton;


- (NSString *)deviceSerialNumber {
    return [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:kUD_SERIAL_NUMBER_FROM_EMAIL_FORMAT, self.email]];
}

- (void)setDeviceSerialNumber:(NSString *)deviceSerialNumber {
    [[NSUserDefaults standardUserDefaults] setObject:deviceSerialNumber forKey:[NSString stringWithFormat:kUD_SERIAL_NUMBER_FROM_EMAIL_FORMAT, self.email]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)lastDeviceUUID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:kUD_LAST_UUID_FROM_EMAIL_FORMAT, self.email]];
}

- (void)setLastDeviceUUID:(NSString *)lastDeviceUUID {
    [[NSUserDefaults standardUserDefaults] setObject:lastDeviceUUID forKey:[NSString stringWithFormat:kUD_LAST_UUID_FROM_EMAIL_FORMAT, self.email]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)lastSyncDate {
    NSString* lastUpdateString = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:kUD_DATE_LAST_SYNC_FROM_EMAIL_FORMAT, self.email]];
    NSDate* lastUpdateTime = [NSDate dateWithString:lastUpdateString format:k_DATE_FORMAT_LAST_SYNC];
    return lastUpdateTime;
}

- (void)setLastSyncDate:(NSDate *)lastSyncDate {
    NSString* lastUpdateString = [lastSyncDate stringWithFormat:k_DATE_FORMAT_LAST_SYNC];
    [[NSUserDefaults standardUserDefaults] setObject:lastUpdateString forKey:[NSString stringWithFormat:kUD_DATE_LAST_SYNC_FROM_EMAIL_FORMAT, self.email]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (instancetype)shared {
    return singleton;
}


@end

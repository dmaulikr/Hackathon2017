//
//  UserObject.h
//  ItsMyLife
//
//  Created by DuongPV on 6/9/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObject : NSObject

@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString *deviceSerialNumber;
@property (nonatomic, strong) NSString *lastDeviceUUID;
@property (nonatomic, strong) NSDate *lastSyncDate;

+ (instancetype)shared;
- (void)currentUser;

@end

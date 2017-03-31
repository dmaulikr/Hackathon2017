//
//  BLEDataService.h
//  ItsMyLife
//
//  Created by Duy Pham on 1/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "YMSCBLE.h"

@interface BLEDataService : YMSCBService

+ (int)serviceUUID;

+ (NSString *)name;

- (instancetype)initWithParent:(YMSCBPeripheral *)parent;

- (void)turnOn:(BOOL)on completion:(void (^)(NSError *error))completion;

- (void)senddata:(uint8_t[16])writedata accepted:(NSArray /* uint8_t */ *)responsecommands completion:(void (^)(NSError *error, NSArray /* NSData */ *readdatas))completion;

- (void)registerNotification:(uint8_t)responsecommand notifyBlock:(void (^)(NSData *readdata))notifyBlock;
- (void)unRegisterNotification:(uint8_t)responsecommand;

- (void)clearAllRegisteredNotifyBlocks;

@end

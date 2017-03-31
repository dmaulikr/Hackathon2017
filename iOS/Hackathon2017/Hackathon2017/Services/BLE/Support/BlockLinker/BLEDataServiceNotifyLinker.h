//
//  BLEDataServiceNotifyLinker.h
//  IMLHeartRate
//
//  Created by Duy Pham on 10/3/17.
//  Copyright © 2017 __ORGANIZATIONNAME__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEDataServiceNotifyLinker : NSObject

@property (nonatomic, readonly, assign) uint8_t responsecommand;

- (instancetype)initWithAccepted:(uint8_t)responsecommand withNotifyBlock:(void (^)(NSData *readdata))notifyBlock;
- (void)addReceivedValue:(NSData *)readdata error:(NSError *)error;

@end

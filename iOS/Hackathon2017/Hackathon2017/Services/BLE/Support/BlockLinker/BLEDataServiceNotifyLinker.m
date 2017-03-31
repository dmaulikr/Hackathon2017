//
//  BLEDataServiceNotifyLinker.m
//  IMLHeartRate
//
//  Created by Duy Pham on 10/3/17.
//  Copyright © 2017 __ORGANIZATIONNAME__. All rights reserved.
//

#import "BLEDataServiceNotifyLinker.h"


@interface BLEDataServiceNotifyLinker ()

@property (nonatomic, readwrite, assign) uint8_t responsecommand;
@property (nonatomic, copy) void (^receiveDataNotifyBlock)(NSData *);

@end

@implementation BLEDataServiceNotifyLinker

- (instancetype)initWithAccepted:(uint8_t)responsecommand withNotifyBlock:(void (^)(NSData *))notifyBlock {
    self = [super init];
    
    if (self != nil) {
        _responsecommand = responsecommand;
        _receiveDataNotifyBlock = notifyBlock;
    }
    
    return self;
}

- (void)addReceivedValue:(NSData *)readdata error:(NSError *)error {
    if (!readdata) return;
        
    uint8_t data;
    // read first byte command
    [readdata getBytes:&data length:1];
    
    if (data == self.responsecommand) {
        _receiveDataNotifyBlock(readdata);
    }
}

@end

//
//  BLEDataServiceBlockLinker.m
//  ItsMyLife
//
//  Created by Duy Pham on 5/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import "BLEDataServiceBlockLinker.h"
#import "MSWeakTimer.h"


@interface BLEDataServiceBlockLinker ()

@property (nonatomic, copy) NSArray /* NSNumber uint8_t */ *responsecommands;
@property (nonatomic, copy) void (^sendDataCompletion)(NSError *, NSArray *);
@property (nonatomic, strong) NSMutableArray *received_datas;
@property (nonatomic, strong) NSError *received_error;
@property (nonatomic, strong) MSWeakTimer *received_timeout_timer;

@end


@implementation BLEDataServiceBlockLinker

- (instancetype)initWithAccepted:(NSArray *)responsecommands withCompletion:(void (^)(NSError *, NSArray *))completion {
    self = [super init];
    
    if (self != nil) {
        _responsecommands = [responsecommands copy];
        _sendDataCompletion = [completion copy];
        _received_datas = [NSMutableArray array];
        _received_error = nil;
        _finalized = FALSE;
    }
    
    return self;
}

- (void)addReceivedValue:(NSData *)readdata error:(NSError *)error {
    if (readdata) {
        uint8_t data;
        // read first byte command
        [readdata getBytes:&data length:1];
        
        if ([self.responsecommands containsObject:@(data)]) {
            [self.received_datas addObject:readdata];
        } else {
            return;
        }
    } else if (error) {
        self.received_error = error;
    } else {
    }
    
    [self.received_timeout_timer invalidate];
    self.received_timeout_timer = [MSWeakTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(finalizeReceivedValues) userInfo:nil repeats:FALSE dispatchQueue:dispatch_get_main_queue()];
}

- (void)finalizeReceivedValues {
    [self.received_timeout_timer invalidate];
    
    if (self.sendDataCompletion) {
        self.sendDataCompletion(self.received_error, [NSArray arrayWithArray:self.received_datas]);
        self.sendDataCompletion = nil;
    } else {
    }
    
    _finalized = TRUE;
}

@end

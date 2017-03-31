//
//  BLEDataServiceBlockLinker.h
//  ItsMyLife
//
//  Created by Duy Pham on 5/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEDataServiceBlockLinker : NSObject

@property (nonatomic, readonly, assign) BOOL finalized;

- (instancetype)initWithAccepted:(NSArray /* uint8_t */ *)responsecommands withCompletion:(void (^)(NSError *error, NSArray /* NSData */ *readdatas))completion;
- (void)addReceivedValue:(NSData *)readdata error:(NSError *)error;
- (void)finalizeReceivedValues;

@end

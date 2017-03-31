//
//  NSArray+Filter.h
//  ItsMyLife
//
//  Created by Duy Pham on 6/8/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Filter)
- (NSArray *)filteredArrayUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (id)filteredObjectUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))block;//first object
@end

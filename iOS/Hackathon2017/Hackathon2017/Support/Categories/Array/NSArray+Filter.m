//
//  NSArray+Filter.m
//  ItsMyLife
//
//  Created by Duy Pham on 6/8/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#import "NSArray+Filter.h"

@implementation NSArray (Filter)
- (NSArray *)filteredArrayUsingBlock:(BOOL (^)(id, NSUInteger, BOOL *))block {
    return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:block]];
}

- (id)filteredObjectUsingBlock:(BOOL (^)(id, NSUInteger, BOOL *))block {
    return [self objectAtIndex:[self indexOfObjectPassingTest:block]];
}
@end

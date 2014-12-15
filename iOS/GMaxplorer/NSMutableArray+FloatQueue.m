//
//  NSMutableArray+Queue.m
//  GMaxplorer
//
//  Created by Hadziq Fabroyir on 3/30/13.
//  Copyright (c) 2013 NRLab. All rights reserved.
//

#import "NSMutableArray+FloatQueue.h"

#define ARRAYSIZE 10

@implementation NSMutableArray (FloatQueue)

- (void)enqueue:(float)item
{
    if ([self count] == ARRAYSIZE) {  // Array is full
        [self dequeue];
    }
    [self addObject:[NSNumber numberWithFloat:item]];
}

- (float)dequeue
{
    float item = 0;                 // assigned just to avoid warning
    if ([self count] != 0) {
        item = [[self objectAtIndex:0] floatValue];
        [self removeObjectAtIndex:0];
    }
    return item;
}

- (float)head
{
    float item = 0;                 // assigned just to avoid warning
    if ([self count] != 0) {
        item = [[self objectAtIndex:0] floatValue];
    }
    return item;
}

- (float)tail
{
    float item = 0;                 // assigned just to avoid warning
    if ([self count] != 0) {
        item = [[self objectAtIndex:[self count]-1] floatValue];
    }
    return item;
}

- (void)clear
{
    [self removeAllObjects];
}

- (void)print
{
    NSLog(@"Queue [%lu elements]: ", (unsigned long)[self count]);
    for (int i=0; i<[self count]; i++) {
        NSLog(@"[%d] %@", i, [self objectAtIndex:i]);
    }
}

- (BOOL)isIncremental
{
    BOOL incremental = YES;
    for (int i=1; i<[self count]; i++) {
        if ([[self objectAtIndex:i] floatValue] < [[self objectAtIndex:i-1] floatValue]) {
            incremental = NO;
            break;
        }
    }
    return incremental;
}

- (BOOL)isDecremental
{
    BOOL decremental = YES;
    for (int i=1; i<[self count]; i++) {
        if ([[self objectAtIndex:i] floatValue] > [[self objectAtIndex:i-1] floatValue]) {
            decremental = NO;
            break;
        }
    }
    return decremental;
}

- (float)getElementsAverage:(NSString*)queueName
{
    float sum = 0.f;
    
    for (int i=0; i<[self count]; i++) {
        sum += [[self objectAtIndex:i] floatValue];
    }
    NSLog(@"Average of %@ = %f", queueName, (sum/[self count]));
    return sum/[self count];
}

@end

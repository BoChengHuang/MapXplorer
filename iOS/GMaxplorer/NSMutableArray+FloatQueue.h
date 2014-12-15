//
//  NSMutableArray+Queue.h
//  GMaxplorer
//
//  Created by Hadziq Fabroyir on 3/30/13.
//  Copyright (c) 2013 NRLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (FloatQueue)

- (void)enqueue:(float)item;
- (float)dequeue;
- (float)head;
- (float)tail;
- (void)clear;
- (void)print;
- (BOOL)isIncremental;
- (BOOL)isDecremental;
- (float)getElementsAverage:(NSString*)queueName;

@end
//
//  NotificationView.m
//  MaxplorerStreet
//
//  Created by Graphics on 13/7/2.
//  Copyright (c) 2013年 NRLab. All rights reserved.
//

#import "NotificationView.h"

@implementation NotificationView

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)drawRect:(NSRect)frame
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame
                                                         xRadius:6.0 yRadius:6.0];
    [[NSColor blackColor] set];
    [path fill];
}

@end

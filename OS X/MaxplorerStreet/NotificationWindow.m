//
//  NotificationWindow.m
//  MaxplorerStreet
//
//  Created by Graphics on 13/7/2.
//  Copyright (c) 2013年 NRLab. All rights reserved.
//

#import "NotificationWindow.h"

@implementation NotificationWindow
    - (id)initWithContentRect:(NSRect)contentRect
                    styleMask:(NSUInteger)windowStyle
                      backing:(NSBackingStoreType)bufferingType
                        defer:(BOOL)deferCreation {
    
        if (self = [super initWithContentRect:contentRect
                                    styleMask:NSBorderlessWindowMask    // Set as borderless window
                                      backing:NSBackingStoreBuffered
                                        defer:deferCreation]) {
            [self setAlphaValue:0.75];
            [self setOpaque:NO];
            [self setExcludedFromWindowsMenu:NO];
            [self setBackgroundColor:[NSColor clearColor]];
        }
        return self;
    }
@end

//
//  AppDelegate.h
//  MaxplorerStreet
//
//  Created by Graphics on 13/1/14.
//  Copyright (c) 2013年 NRLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;

@end

//
//  AppDelegate.m
//  MaxplorerStreet
//
//  Created by Graphics on 13/1/14.
//  Copyright (c) 2013年 NRLab. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[self window] setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    NSURL *url = [NSURL URLWithString:@"http://localhost/maxplorer/streetview.php?latitude=25.014811&longitude=121.541662&heading=0&zooming=16"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[[self webView] mainFrame] loadRequest:request];
}

@end

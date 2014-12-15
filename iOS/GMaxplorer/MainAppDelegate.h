//
//  AppDelegate.h
//  GMaxplorer
//
//  Created by Hadziq Fabroyir on 3/7/13.
//  Copyright (c) 2013 NRLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Server.h"

@class MapViewController;
@class ServerBrowserTableViewController;

@interface MainAppDelegate : NSObject <UIApplicationDelegate, ServerDelegate> {
    Server *_server;
    UIWindow *_window;
    UINavigationController *_navigationController;
    ServerBrowserTableViewController *_serverBrowserVC;
    MapViewController *_mapVC;
}

- (void)startMap;
- (BOOL)isConnectedToServer;
- (void)toggleUserLocation:(BOOL)on;
- (void)toggleLocationDescription:(BOOL)on;
- (void)togglePitchPreference:(NSString*)preference;
- (void)toggleRouteOriented:(BOOL)on;
- (void)toggleNorthDependent:(BOOL)on;
- (void)toggleIntersectionAwared:(BOOL)on;
- (void)changeDrivingAccelerationLevel:(int)value;

- (void)setLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude;

@end

//
//  AppDelegate.m
//  GMaxplorer
//
//  Created by Hadziq Fabroyir on 3/7/13.
//  Copyright (c) 2013 NRLab. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

#import "MainAppDelegate.h"
#import "MapViewController.h"
#import "ServerBrowserTableViewController.h"

@implementation MainAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialization of Bonjour Network Service
    NSString *type = @"mapXplorer";
    _server = [[Server alloc] initWithProtocol:type];
    _server.delegate = self;
    NSError *error = nil;
    if (![_server start:&error]) {
        NSLog(@"error = %@", error);
    }
    
    // Key of Google Maps API for iOS
    [GMSServices provideAPIKey:@"AIzaSyBQByNhNdE-NIOadATFbGAZ4DKcf6MkjGQ"];
    
    // Window initialization for iPhone and iPad
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self->_mapVC = [[MapViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
        self->_serverBrowserVC = [[ServerBrowserTableViewController alloc] initWithNibName:@"ServerBrowserView_iPhone" bundle:nil];
    } else {
        self->_mapVC = [[MapViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
        self->_serverBrowserVC = [[ServerBrowserTableViewController alloc] initWithNibName:@"ServerBrowserView_iPad" bundle:nil];
    }
    
    // Preparing the display of Server Browser View Controller
    _serverBrowserVC.server = _server;
    _navigationController = [[UINavigationController alloc] initWithRootViewController:self->_serverBrowserVC];
    [_window setRootViewController:_navigationController];
    [_window addSubview:_navigationController.view];
    [_window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [_server stop];
    [_server stopBrowser];
}

#pragma mark Server Delegate Methods

- (void)serverRemoteConnectionComplete:(Server *)server {
    // this is called when the remote side finishes joining with the socket as
    // notification that the other side has made its connection with this side
    _mapVC.server = server;
    [_serverBrowserVC enableStartButton:self];
}

- (void)startMap
{
    // Sending location over bonjour network
    NSString *stringMessage = [NSString stringWithFormat:@"Location,%f,%f,%f",
                       self->_mapVC.latitude,
                       self->_mapVC.longitude,
                       self->_mapVC.bearing];
    NSData *data = [stringMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    [_server sendData:data error:&error];
    [self->_navigationController pushViewController:_mapVC animated:YES];
}

- (BOOL)isConnectedToServer
{
    return (self->_mapVC.server != nil);
}

- (void)toggleUserLocation:(BOOL)on
{
    self->_mapVC.isUserLocationEnabled = on;
}

- (void)toggleLocationDescription:(BOOL)on
{
    self->_mapVC.isLocationDescriptionEnabled = on;
}

- (void)togglePitchPreference:(NSString *)preference
{
    self->_mapVC.pitchPreference = preference;
}

- (void)toggleRouteOriented:(BOOL)on
{
    self->_mapVC.isRouteOriented = on;
}

- (void)toggleNorthDependent:(BOOL)on
{
    self->_mapVC.isNorthDependent = on;
}

- (void)toggleIntersectionAwared:(BOOL)on
{
    self->_mapVC.isIntersectionAwared = on;
}

- (void)changeDrivingAccelerationLevel:(int)value
{
    self->_mapVC.drivingAccelerationLevel = value;
}

- (void)setLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude {
    self->_mapVC.latitude = latitude;
    self->_mapVC.longitude = longitude;
}

- (void)serverStopped:(Server *)server {
    NSLog(@"Server Stopped");
    [_serverBrowserVC disableStartButton:self];
    [self->_navigationController popViewControllerAnimated:YES];
}

- (void)server:(Server *)server didNotStart:(NSDictionary *)errorDict {
    NSLog(@"Server did not start %@", errorDict);
}

- (void)server:(Server *)server didAcceptData:(NSData *)data {
    //NSLog(@"Server did accept data %@", data);
    NSString *localMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(nil != localMessage || [localMessage length] > 0) {
        _mapVC.message = localMessage;
    } else {
        _mapVC.message = @"no data received";
    }
    
    NSArray *messageData = [_mapVC.message componentsSeparatedByString:@","];
    NSString *messageHeader = [NSString stringWithFormat:@"%@", [messageData objectAtIndex:0]];
    
    if ([messageHeader isEqualToString:@"Location"]) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        _mapVC.latitude = [[numberFormatter numberFromString:[messageData objectAtIndex:1]] doubleValue];
        _mapVC.longitude = [[numberFormatter numberFromString:[messageData objectAtIndex:2]] doubleValue];
        _mapVC.movingBearing = [[numberFormatter numberFromString:[messageData objectAtIndex:3]] doubleValue];
        _mapVC.numberOfPathLinks = [[numberFormatter numberFromString:[messageData objectAtIndex:4]] intValue];
        
        // change location on the map
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_mapVC.latitude, _mapVC.longitude);
        [_mapVC resetLocation:coordinate];
    } else if ([messageHeader isEqualToString:@"Notification"]) {
        [_mapVC showNotification:[messageData objectAtIndex:1] withType:[messageData objectAtIndex:2]];
    }
}

- (void)server:(Server *)server lostConnection:(NSDictionary *)errorDict {
    NSLog(@"Server lost connection %@", errorDict);
    [_serverBrowserVC disableStartButton:self];
    [self->_navigationController popViewControllerAnimated:YES];
}

- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more {
    [_serverBrowserVC addService:service moreComing:more];
}

- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more {
    [_serverBrowserVC removeService:service moreComing:more];
}

@end

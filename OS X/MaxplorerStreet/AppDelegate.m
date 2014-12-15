//
//  AppDelegate.m
//  MaxplorerStreet
//
//  Created by Hadziq 哈明飛 on 13/1/14.
//  Copyright (c) 2013年 NRLab. All rights reserved.
//

#import "AppDelegate.h"
#import "Server.h"

@implementation AppDelegate

@synthesize server;
@synthesize services;
@synthesize message;
@synthesize isConnectedToService;
@synthesize latitude;
@synthesize longitude;
@synthesize heading;
@synthesize pitch;
@synthesize resetPitchFloat;
@synthesize resetPitchTimer;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.streetWindow setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
    //[self.streetWindow toggleFullScreen:self];
    
    self.message = @"Message";
    connectedRow = -1;
    self.services = [[NSMutableArray alloc] init];
    
    NSString *type = @"mapXplorer";
    
    self.server = [[Server alloc] initWithProtocol:type];
    self.server.delegate = self;
    
    NSError *error = nil;
    if (![self.server start:&error]) {
        NSLog(@"Error = %@", error);
    }
}

- (void)awakeFromNib
{
    // [self loadStreetViewWithLatitude:@"25.015229" longitude:@"121.540589" heading:@"0"];
    
    [self.streetWebView setUIDelegate:self];
    [self.streetWebView setResourceLoadDelegate:self];
    [self.streetWebView setFrameLoadDelegate:self];
}

#pragma mark -
#pragma mark Bonjour Interface Methods

- (IBAction)connectToService:(id)sender
{
    [self.server connectToRemoteService:[self.services objectAtIndex:selectedRow]];
}

- (void)sendMessage:(id)sender
{
    NSData *data = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    [self.server sendData:data error:&error];
}

#pragma mark Street View PHP JS Method Call

- (void)loadStreetViewWithLatitude:(NSString *)latitudeString longitude:(NSString *)longitudeString heading:(NSString *)headingString
{
    self.latitude = latitudeString;
    self.longitude = longitudeString;
    self.heading = headingString;
    
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost/MapXplorer_Service/streetview.php?latitude=%@&longitude=%@&heading=%@",
                   latitudeString, longitudeString, headingString]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[[self streetWebView] mainFrame] loadRequest:request];
}

- (void)adjustBearing:(NSString *)bearingString
{
    // call JavaScript function on PHP rotate the street view camera
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *headingNumber = [numberFormatter numberFromString:bearingString];
    id jsCallerObject = [self.streetWebView windowScriptObject];
    NSArray *args = [NSArray arrayWithObjects:headingNumber, nil];
    [jsCallerObject callWebScriptMethod:@"turnHeading" withArguments:args];
}

- (void)adjustPitch:(NSString *)pitchString
{
    // Call JavaScript function on PHP pitch the street view camera
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *pitchNumber = [numberFormatter numberFromString:pitchString];
    // Save the latest pitch float value for later use.
    // when we need to reset the pitch view
    self.resetPitchFloat = [pitchNumber floatValue];
    id jsCallerObject = [self.streetWebView windowScriptObject];
    NSArray *args = [NSArray arrayWithObjects:pitchNumber, nil];
    [jsCallerObject callWebScriptMethod:@"turnPitch" withArguments:args];
}

- (void)resetPitch
{
    id jsCallerObject = [self.streetWebView windowScriptObject];
    NSArray *args = [NSArray arrayWithObjects:[NSNumber numberWithFloat:self.resetPitchFloat], nil];
    [jsCallerObject callWebScriptMethod:@"turnPitch" withArguments:args];
    
    if (self.resetPitchFloat == 0) {
        return;
    }
    else if (fabs(self.resetPitchFloat) < 1) {
        self.resetPitchFloat = 0;
    }
    else {
        self.resetPitchFloat /= 2;
    }
    self.resetPitchTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(resetPitch) userInfo:nil repeats:NO];
}

- (void)moveForward
{
    id jsCallerObject = [self.streetWebView windowScriptObject];
    [jsCallerObject callWebScriptMethod:@"moveForward" withArguments:nil];
}

- (void)moveBackward
{
    id jsCallerObject = [self.streetWebView windowScriptObject];
    [jsCallerObject callWebScriptMethod:@"moveBackward" withArguments:nil];
}

- (void)fastForward
{
    id jsCallerObject = [self.streetWebView windowScriptObject];
    [jsCallerObject callWebScriptMethod:@"fastForward" withArguments:nil];
}

#pragma mark -
#pragma mark Bonjour Server Client Delegate Methods

- (void)serverRemoteConnectionComplete:(Server *)server
{
    //NSLog(@"Connected to service");
    
    self.isConnectedToService = YES;
    
    connectedRow = selectedRow;
    [tableView reloadData];
}

- (void)serverStopped:(Server *)server
{
    //NSLog(@"Disconnected from service");
    
    self.isConnectedToService = NO;
    
    connectedRow = -1;
    [tableView reloadData];
}

- (void)server:(Server *)server didNotStart:(NSDictionary *)errorDict
{
    //NSLog(@"Server did not start %@", errorDict);
}

- (void)server:(Server *)server didAcceptData:(NSData *)data
{
    NSString *localMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (localMessage != nil || localMessage.length > 0) {
        self.message = localMessage;
    } else {
        self.message = @"No data is received";
    }
    
    NSArray *messageComponents = [self.message componentsSeparatedByString:@","];
    NSString *messageHeader = [NSString stringWithFormat:@"%@", [messageComponents objectAtIndex:0]];
    
    if ([messageHeader isEqualToString:@"Location"]) {
        NSLog(@"On Long Press For LOCATION");
        self.latitude = [messageComponents objectAtIndex:1];
        self.longitude = [messageComponents objectAtIndex:2];
        self.heading = [messageComponents objectAtIndex:3];
        
        // change location of street view
        [self loadStreetViewWithLatitude:self.latitude longitude:self.longitude heading:self.heading];
    }
    else if ([messageHeader isEqualToString:@"Bearing"]) {
        if (![_lastMessageHeader isEqualToString:@"Bearing"]) {
            NSLog(@"On Acceleration or On Map Touch For ROTATION");
        }
        self.heading = [messageComponents objectAtIndex:1];
        
        // adjust street view bearing
        [self adjustBearing:self.heading];
    }
    else if ([messageHeader isEqualToString:@"Pitch"]) {
        if (![_lastMessageHeader isEqualToString:@"Pitch"]) {
            NSLog(@"On Pan For PITCH");
        }
        self.pitch = [messageComponents objectAtIndex:1];
        // adjust street view pitch
        [self adjustPitch:self.pitch];
    }
    else if ([messageHeader isEqualToString:@"ResetPitch"]) {
        [self resetPitch];
    }
    else if ([messageHeader isEqualToString:@"Forward"]) {
        NSLog(@"On Pan For MOVING FORWARD");
        [self moveForward];
    }
    else if ([messageHeader isEqualToString:@"Backward"]) {
        NSLog(@"On Pan For MOVING BACKWARD");
        [self moveBackward];
    }
    else if ([messageHeader isEqualToString:@"Jump"]) {
        NSLog(@"On Shake For JUMP TO NEXT INTERSECTION");
        [self fastForward];
    }
    else if ([messageHeader isEqualToString:@"OnMapTouchBegan"]) {
        NSLog(@"On Map Touch Began");
    }
    else if ([messageHeader isEqualToString:@"OnPanTouchBegan"]) {
        NSLog(@"On Pan Touch Began");
    }
    else if ([messageHeader isEqualToString:@"OnMapTouchEnd"]) {
        NSLog(@"On Map Touch End");
    }
    else if ([messageHeader isEqualToString:@"OnPanTouchEnd"]) {
        NSLog(@"On Pan Touch End");
    }
    else if ([messageHeader isEqualToString:@"Notification"]) {
        NSLog(@"Notification: %@", [messageComponents objectAtIndex:1]);
        [self displayHUDNotification:[messageComponents objectAtIndex:1]];
    }
    
    _lastMessageHeader = messageHeader;
}

- (void)server:(Server *)server lostConnection:(NSDictionary *)errorDict
{
    //NSLog(@"Lost connection");
    
    self.isConnectedToService = NO;
    connectedRow = -1;
    [tableView reloadData];
}

- (void)serviceAdded:(NSNetService *)service moreComing:(BOOL)more
{
    //NSLog(@"Added a service: %@", [service name]);
    
    [self.services addObject:service];
    if (!more) {
        [tableView reloadData];
    }
}

- (void)serviceRemoved:(NSNetService *)service moreComing:(BOOL)more
{
    //NSLog(@"Removed a service: %@", [service name]);
    
    [self.services removeObject:service];
    if (!more) {
        [tableView reloadData];
    }
}

#pragma mark -
#pragma mark NSTableView Delegate Methods

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (row == connectedRow) {
        [cell setTextColor:[NSColor redColor]];
    }
    else {
        [cell setTextColor:[NSColor blackColor]];
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[self.services objectAtIndex:row] name];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //NSLog(@"Count: %ld", (unsigned long)[self.services count]);
    return [self.services count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    selectedRow = [[notification object] selectedRow];
}

#pragma mark -
#pragma mark JavaScript bridge

- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    //NSLog(@"%@ received %@", self, NSStringFromSelector(_cmd));
    [windowScriptObject setValue:self forKey:@"mapXplorer"];
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)webmessage initiatedByFrame:(WebFrame *)frame
{
    //NSLog(@"%@ received %@ with '%@',", self, NSStringFromSelector(_cmd), webmessage);
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    //NSLog(@"%@ received %@ for '%@'", self, NSStringFromSelector(_cmd), NSStringFromSelector(selector));
    if (selector == @selector(doOutputToLog:)
        || selector == @selector(sendLatitude:longitude:movingHeading:pathLinks:)
        || selector == @selector(sendNotification:withType:)) {
        return NO;
    }
    return YES;
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)property
{
    //NSLog(@"%@ received %@ for '%s'", self, NSStringFromSelector(_cmd), property);
    if (strcmp(property, "sharedValue") == 0) {
        return NO;
    }
    
    return YES;
}

+ (NSString *)webScriptNameForSelector:(SEL)selector
{
    //NSLog(@"%@ received %@ with sel='%@'", self, NSS tringFromSelector(_cmd), NSStringFromSelector(selector));
    if (selector == @selector(doOutputToLog:)) {
        return @"log";
    } else if (selector == @selector(sendLatitude:longitude:movingHeading:pathLinks:)) {
        return @"syncLatitudeLongitudeHeadingPathlinks";
    } else if (selector == @selector(sendNotification:withType:)) {
        return @"notification";
    } else {
        return nil;
    }
}

- (void)doOutputToLog:(NSString *)log
{
    //NSLog(@"%@ received %@ with message=%@", self, NSStringFromSelector(_cmd), theMessage);
    NSLog(@"EXTERNAL LOG: %@", log);
}

- (void)sendLatitude:(NSNumber *)latitudeNumber longitude:(NSNumber *)longitudeNumber movingHeading:(NSNumber *)movingHeadingNumber pathLinks:(NSNumber *)numberOfPathLinks
{
    NSString *locationMessage = [[NSString alloc] initWithFormat:@"Location,%@,%@,%@,%@", latitudeNumber, longitudeNumber, movingHeadingNumber, numberOfPathLinks];
    NSData *data = [locationMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    [self.server sendData:data error:&error];
}

// Extra function for notification
- (void)sendNotification:(NSString *)notification withType:(NSString *)type
{
    //NSLog(@"Notification [%@]: %@", type, notification);
    NSString *notificationMessage = [[NSString alloc] initWithFormat:@"Notification,%@,%@", notification, type];
    NSData *data = [notificationMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    [self.server sendData:data error:&error];
}

- (void)displayHUDNotification:(NSString*)notification {
    [self.notificationText setStringValue:notification];
    [self.notificationWindow setIsVisible:YES];
    [self.notificationWindow setAlphaValue:1.0];
    [NSTimer scheduledTimerWithTimeInterval:3
                                     target:self
                                   selector:@selector(fadeOutHUDNotification)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)fadeOutHUDNotification {
    [self.notificationWindow.animator setAlphaValue:0.0];
}

@end

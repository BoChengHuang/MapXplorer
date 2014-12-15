//
//  AppDelegate.h
//  MaxplorerStreet
//
//  Created by Hadziq 哈明飛 on 13/1/14.
//  Copyright (c) 2013年 NRLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "Server.h"
#import "NotificationWindow.h"
#import "NotificationView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, ServerDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    NSString *textToSend;
    NSInteger *selectedRow, connectedRow;
    IBOutlet NSTableView *tableView;
    NSString *_lastMessageHeader;
}

@property (assign) IBOutlet NSWindow *bonjourWindow;
@property (assign) IBOutlet NSWindow *streetWindow;
@property (assign) IBOutlet WebView *streetWebView;
@property (strong) IBOutlet NotificationWindow *notificationWindow;
@property (strong) IBOutlet NotificationView *notificationView;
@property (strong) IBOutlet NSTextField *notificationText;

@property (nonatomic, retain) Server *server;
@property (nonatomic, retain) NSMutableArray *services;
@property (readwrite, copy) NSString *message;
@property (readwrite, nonatomic) BOOL isConnectedToService;

@property (nonatomic, assign) NSString *latitude;
@property (nonatomic, assign) NSString *longitude;
@property (nonatomic, assign) NSString *heading;
@property (nonatomic, assign) NSString *pitch;
@property (nonatomic, assign) float resetPitchFloat;
@property (nonatomic, retain) NSTimer *resetPitchTimer;

/* property for our sharedValue instance variable */
// @property (nonatomic, copy) NSString *sharedValue;

- (IBAction)connectToService:(id)sender;
- (void)sendMessage:(id)sender;

- (void)loadStreetViewWithLatitude:(NSString*)latitudeString longitude:(NSString*)longitudeString heading:(NSString*)headingString;
- (void)adjustBearing:(NSString*)bearingString;
- (void)adjustPitch:(NSString*)pitchString;
- (void)resetPitch;
- (void)moveForward;
- (void)moveBackward;

/* WebFrameLoadDelegate method */
- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame;

/* WebUIDelegate method */
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;

/* WebScripting methods */
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector;
+ (BOOL)isKeyExcludedFromWebScript:(const char *)property;
+ (NSString *)webScriptNameForSelector:(SEL)selector;

/* Methods we're sharing with JavaScript */
- (void)doOutputToLog:(NSString *)theMessage;
- (void)sendLatitude:(NSNumber *)latitudeNumber longitude:(NSNumber *)longitudeNumber movingHeading:(NSNumber *)movingHeadingNumber pathLinks:(NSNumber *)numberOfPathLinks;

@end

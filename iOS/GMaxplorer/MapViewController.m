//
//  ViewController.m
//  GMaxplorer
//
//  Created by Hadziq Fabroyir on 3/7/13.
//  Copyright (c) 2013 NRLab. All rights reserved.
//

#import "Server.h"
#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "NSMutableArray+FloatQueue.h"
#import <QuartzCore/QuartzCore.h>
#import "MainAppDelegate.h"
#import "Toast+UIView.h"

@implementation MapViewController {
    GMSMapView *mapView_;
    NSString *locationDescription;
}

@synthesize message = _message;
@synthesize server = _server;

@synthesize pitchTimer = _pitchTimer;
@synthesize movingTimer = _movingTimer;
@synthesize rotationTimer = _rotationTimer;
@synthesize autoRotationTimer = _autoRotationTimer;

@synthesize rightPanGestureView;
@synthesize leftPanGestureView;
@synthesize rightDrivePan;
@synthesize leftDrivePan;
@synthesize rightImageView;
@synthesize leftImageView;

@synthesize motionManager;

@synthesize pitchPreference;

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self prefersStatusBarHidden];
    
    mapView_.myLocationEnabled = self.isUserLocationEnabled;
    _justInitiated = NO;
    self.isInDriving = NO;
    self.isInPitching = NO;
    
    CLLocationCoordinate2D selectedLocation;
    selectedLocation.latitude = self.latitude;
    selectedLocation.longitude = self.longitude;
    
    [mapView_ animateToLocation:selectedLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    if (self.isInAutoRotationMode) {    // Turn off auto rotation if it's running
        [self toggleAutoRotateStreetView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self prefersStatusBarHidden];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"MapXplorer Map View";
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    
    // AUTO ROTATION BUTTON
    _autoRotateStreetViewButton = [[UIBarButtonItem alloc] initWithTitle:@"Start Auto Rotate" style:UIBarButtonItemStylePlain target:self action:@selector(toggleAutoRotateStreetView)];
    self.navigationItem.rightBarButtonItem = _autoRotateStreetViewButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    // When the map is launched for the first time
    if (!self.latitude) {
        // --- Keelung Rd. fly over - in the front of NTUST (25.014496,121.541238) ---
        self.latitude = 25.014496;
        self.longitude = 121.541238;
        self.bearing = 0;
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.latitude longitude:self.longitude zoom:16];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.delegate = self;
    self.view = mapView_;
    // Sending Socket Message
    [self sendMessage:[NSString stringWithFormat:@"Location,%f,%f,%f",
                       self.latitude,
                       self.longitude,
                       self.bearing]];
    
    [mapView_ clear];
    
    _currentMarker = [[GMSMarker alloc] init];
    
    // LOCATION DESCRIPTION IS ON
    if (self.isLocationDescriptionEnabled) {
        // Reverse Geocoding
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:camera.target.latitude longitude:camera.target.longitude];
        CLGeocoder *currentGeocoder = [[CLGeocoder alloc] init];
        [currentGeocoder reverseGeocodeLocation:currentLocation completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if(!error){
                 // Iterate through all of the placemarks returned and output them to the console
                 for(CLPlacemark *placemark in placemarks){
                     locationDescription = [NSString stringWithFormat:@"%@", [placemark name]];
                     _currentMarker.title = [NSString stringWithFormat:@"%@", locationDescription];
                     _currentMarker.position = CLLocationCoordinate2DMake(camera.target.latitude, camera.target.longitude);
                     _currentMarker.snippet =  [NSString stringWithFormat:@"%f, %f", camera.target.latitude, camera.target.longitude];
                     _currentMarker.icon = [UIImage imageNamed:@"mapXplorer_marker.png"];
                     _currentMarker.map = mapView_;
                     mapView_.selectedMarker = _currentMarker;
                 }
             }
             else{
                 // Our geocoder had an error, output a message to the console
                 NSLog(@"There was a reverse geocoding error\n%@",
                       [error localizedDescription]);
             }
         }];
    }
    else {    // LOCATION DESCRIPTION IS OFF
        _currentMarker.title = @"Current Street Position";
        _currentMarker.position = CLLocationCoordinate2DMake(camera.target.latitude, camera.target.longitude);
        _currentMarker.snippet =  [NSString stringWithFormat:@"%f, %f", camera.target.latitude, camera.target.longitude];
        _currentMarker.icon = [UIImage imageNamed:@"mapXplorer_marker.png"];
        _currentMarker.map = mapView_;
    }
    
    // HEADING MARKER
    _headingMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(camera.target.latitude, camera.target.longitude)];
    _headingMarker.icon = [UIImage imageNamed:@"mapXplorer_heading.png"];
    _headingMarker.flat = YES;
    _headingMarker.groundAnchor = CGPointMake(0.5, 0.5);
    _headingMarker.map = mapView_;
    
    // COMPASS MARKER
    _compassMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(camera.target.latitude, camera.target.longitude)];
    _compassMarker.icon = [UIImage imageNamed:@"mapXplorer_compass.png"];
    _compassMarker.flat = YES;
    _compassMarker.groundAnchor = CGPointMake(0.5, 0.5);
    _compassMarker.map = mapView_;
    
    // STEER AND PINCH GESTURE AREA VIEW
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-80, (self.view.bounds.size.height-244)/2-50, 80, 244)];
        self.leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-244)/2-50, 80, 244)];
        self.rightPanGestureView = [[UIView alloc] initWithFrame:CGRectMake(-80, 0, 80, 0)];
        self.leftPanGestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 0)];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-100, (self.view.bounds.size.height-549)/2, 90, 549)];
        self.leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (self.view.bounds.size.height-549)/2, 90, 549)];
        self.rightPanGestureView = [[UIView alloc] initWithFrame:CGRectMake(-110, 0, 110, 0)];
        self.leftPanGestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 0)];
    }
    
    self.rightPanGestureView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [self.rightPanGestureView setBackgroundColor:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.2]];
    [self.view addSubview:self.rightPanGestureView];
    
    self.leftPanGestureView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    [self.leftPanGestureView setBackgroundColor:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.2]];
    [self.view addSubview:self.leftPanGestureView];
    
    self.rightImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | 
                                            UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.rightImageView.image = [UIImage imageNamed:@"mapXplorer_steer.png"];
    [self.view addSubview:self.rightImageView];
    
    self.leftImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | 
                                            UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.leftImageView.image = [UIImage imageNamed:@"mapXplorer_steer.png"];
    [self.view addSubview:self.leftImageView];
    
    // POV GESTURE CONTROLLER
    self.leftDrivePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPitchPan:)];
    self.leftDrivePan.delegate = self;
    self.leftDrivePan.maximumNumberOfTouches = 1;
    [self.leftPanGestureView addGestureRecognizer:self.leftDrivePan];
    
    self.rightDrivePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPitchPan:)];
    self.rightDrivePan.delegate = self;
    self.rightDrivePan.maximumNumberOfTouches = 1;
    [self.rightPanGestureView addGestureRecognizer:self.rightDrivePan];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
/*
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if (touch.view == self.leftPanGestureView)
    {
        _leftTouchPoint = [touch locationInView:self.leftPanGestureView];
    }
    else if (touch.view == self.rightPanGestureView)
    {
        _rightTouchPoint = [touch locationInView:self.rightPanGestureView];
    }
    else
    {
        [self sendMessage:@"OnMapTouchBegan"];
    }
    
    unsigned long steerTouch = (unsigned long)[[event touchesForView:self.leftPanGestureView] count] +
                                (unsigned long)[[event touchesForView:self.rightPanGestureView] count];
    if (steerTouch == 2) {
        if (self.isInAutoRotationMode) {
            [self toggleAutoRotateStreetView];    // Turn off auto rotation when user press both buttons
        }
        
        _justInitiated = YES;
        
        [self sendMessage:@"OnPanTouchBegan"];
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelData, NSError *error) {
            [self doAcceleration:accelData.acceleration];
        }];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if (touch.view == self.leftPanGestureView || touch.view == self.rightPanGestureView)
    {
        [self sendMessage:@"OnPanTouchEnd"];
        _leftPanTranslationY = 0;
        self.leftImageView.image = [UIImage imageNamed:@"mapXplorer_steer.png"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.leftImageView setFrame:CGRectMake(self.leftImageView.frame.origin.x,
                                                    (self.view.bounds.size.height-244)/2,
                                                    self.leftImageView.frame.size.width,
                                                    self.leftImageView.frame.size.height)];
        }
        else {
            [self.leftImageView setFrame:CGRectMake(self.leftImageView.frame.origin.x,
                                                    (self.view.bounds.size.height-549)/2,
                                                    self.leftImageView.frame.size.width,
                                                    self.leftImageView.frame.size.height)];
        }
        
        _rightPanTranslationY = 0;
        self.rightImageView.image = [UIImage imageNamed:@"mapXplorer_steer.png"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.rightImageView setFrame:CGRectMake(self.rightImageView.frame.origin.x,
                                                     (self.view.bounds.size.height-244)/2,
                                                     self.rightImageView.frame.size.width,
                                                     self.rightImageView.frame.size.height)];
        }
        else {
            [self.rightImageView setFrame:CGRectMake(self.rightImageView.frame.origin.x,
                                                     (self.view.bounds.size.height-549)/2,
                                                     self.rightImageView.frame.size.width,
                                                     self.rightImageView.frame.size.height)];
        }
    }
    else {
        [self sendMessage:@"OnMapTouchEnd"];
    }
    
    unsigned long steerTouch = (unsigned long)[[event touchesForView:self.leftPanGestureView] count] +
                                (unsigned long)[[event touchesForView:self.rightPanGestureView] count];
    if (steerTouch <= 2) {
        _leftPanTranslationY = 0;
        self.leftImageView.image = [UIImage imageNamed:@"mapXplorer_steer.png"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.leftImageView setFrame:CGRectMake(self.leftImageView.frame.origin.x,
                                                    (self.view.bounds.size.height-244)/2,
                                                    self.leftImageView.frame.size.width,
                                                    self.leftImageView.frame.size.height)];
        }
        else {
            [self.leftImageView setFrame:CGRectMake(self.leftImageView.frame.origin.x,
                                                    (self.view.bounds.size.height-549)/2,
                                                    self.leftImageView.frame.size.width,
                                                    self.leftImageView.frame.size.height)];
        }
        
        _rightPanTranslationY = 0;
        self.rightImageView.image = [UIImage imageNamed:@"mapXplorer_steer.png"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.rightImageView setFrame:CGRectMake(self.rightImageView.frame.origin.x,
                                                     (self.view.bounds.size.height-244)/2,
                                                     self.rightImageView.frame.size.width,
                                                     self.rightImageView.frame.size.height)];
        }
        else {
            [self.rightImageView setFrame:CGRectMake(self.rightImageView.frame.origin.x,
                                                     (self.view.bounds.size.height-549)/2,
                                                     self.rightImageView.frame.size.width,
                                                     self.rightImageView.frame.size.height)];
        }
        
        [self.motionManager stopAccelerometerUpdates];
        [self.rotationTimer invalidate];
        [self.movingTimer invalidate];
        [self.pitchTimer invalidate];
        [self sendMessage:@"ResetPitch"];
        self.pitch = 0;
        self.isInDriving = NO;
        self.isInPitching = NO;
    }
}

- (void)handleLeftPitchPan:(UIPanGestureRecognizer *)event {
    CGPoint translation = [event translationInView:self.leftPanGestureView];
    
    if (event.state == UIGestureRecognizerStateBegan) {
        if (self.rightDrivePan.state == UIGestureRecognizerStateBegan ||
            self.rightDrivePan.state == UIGestureRecognizerStateChanged) {
            [self doMove];
            [self doPitch];
            NSLog(@"Left first");
        }
    }
    
    //NSLog(@"isInDriving = %d", self.isInDriving);
    
    if (event.state == UIGestureRecognizerStateChanged) {
        _leftPanTranslationY = translation.y;
    }
    else if (event.state == UIGestureRecognizerStateEnded ||
             event.state == UIGestureRecognizerStateCancelled ||
             event.state == UIGestureRecognizerStateFailed/* ||
             event.state == UIGestureRecognizerStateRecognized*/)
    {
        _leftPanTranslationY = 0;
        self.leftImageView.image = [UIImage imageNamed:@"mapXplorer_steer.png"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.leftImageView setFrame:CGRectMake(self.leftImageView.frame.origin.x,
                                                    (self.view.bounds.size.height-244)/2,
                                                    self.leftImageView.frame.size.width,
                                                    self.leftImageView.frame.size.height)];
        }
        else {
            [self.leftImageView setFrame:CGRectMake(self.leftImageView.frame.origin.x,
                                                    (self.view.bounds.size.height-549)/2,
                                                    self.leftImageView.frame.size.width,
                                                    self.leftImageView.frame.size.height)];
        }
        
        [self.motionManager stopAccelerometerUpdates];
        [self.rotationTimer invalidate];
        [self.movingTimer invalidate];
        [self.pitchTimer invalidate];
        [self sendMessage:@"ResetPitch"];
        self.pitch = 0;
        self.isInDriving = NO;
        self.isInPitching = NO;
    }
}

- (void)handleRightPitchPan:(UIPanGestureRecognizer *)event {
    CGPoint translation = [event translationInView:self.rightPanGestureView];
    
    if (event.state == UIGestureRecognizerStateBegan) {
        if (self.leftDrivePan.state == UIGestureRecognizerStateBegan ||
            self.leftDrivePan.state == UIGestureRecognizerStateChanged) {
            [self doMove];
            [self doPitch];
            NSLog(@"Right first");
        }
    }
    
    //NSLog(@"isInDriving = %d", self.isInDriving);
    
    if (event.state == UIGestureRecognizerStateChanged) {
        _rightPanTranslationY = translation.y;
    }
    else if (event.state == UIGestureRecognizerStateEnded ||
             event.state == UIGestureRecognizerStateCancelled ||
             event.state == UIGestureRecognizerStateFailed/* ||
             event.state == UIGestureRecognizerStateRecognized*/)
    {
        _rightPanTranslationY = 0;
        self.rightImageView.image = [UIImage imageNamed:@"mapXplorer_steer.png"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.rightImageView setFrame:CGRectMake(self.rightImageView.frame.origin.x,
                                                     (self.view.bounds.size.height-244)/2,
                                                     self.rightImageView.frame.size.width,
                                                     self.rightImageView.frame.size.height)];
        }
        else {
            [self.rightImageView setFrame:CGRectMake(self.rightImageView.frame.origin.x,
                                                     (self.view.bounds.size.height-549)/2,
                                                     self.rightImageView.frame.size.width,
                                                     self.rightImageView.frame.size.height)];
        }
        
        [self.motionManager stopAccelerometerUpdates];
        [self.rotationTimer invalidate];
        [self.movingTimer invalidate];
        [self.pitchTimer invalidate];
        [self sendMessage:@"ResetPitch"];
        self.pitch = 0;
        self.isInDriving = NO;
        self.isInPitching = NO;
    }
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self resetLocation:coordinate];
    
    if (self.isNorthDependent) {
        self.bearing = 0;   // Reset back to face North
        [mapView_ animateToBearing:self.bearing];
    }
    
    // Sending location over bonjour network
    [self sendMessage:[NSString stringWithFormat:@"Location,%f,%f,%f",
                       coordinate.latitude,
                       coordinate.longitude,
                       self.bearing]];
}

- (void)resetLocation:(CLLocationCoordinate2D)coordinate {
    if (self.isLocationDescriptionEnabled) {
        // Reverse Geocoding
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        CLGeocoder *currentGeocoder = [[CLGeocoder alloc] init];
        [currentGeocoder reverseGeocodeLocation:currentLocation completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if(!error){
                 // Iterate through all of the placemarks returned
                 // and output them to the console
                 for(CLPlacemark *placemark in placemarks){
                     locationDescription = [NSString stringWithFormat:@"%@", [placemark name]];
                     _currentMarker.title = [NSString stringWithFormat:@"%@", locationDescription];
                     _currentMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
                     _currentMarker.snippet =  [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];
                     _currentMarker.icon = [UIImage imageNamed:@"mapXplorer_marker.png"];
                     _currentMarker.map = mapView_;
                     mapView_.selectedMarker = _currentMarker;
                 }
             }
             else{
                 // Our geocoder had an error, output a message
                 // to the console
                 NSLog(@"There was a reverse geocoding error\n%@",
                       [error localizedDescription]);
             }
         }];
    } else {
        _currentMarker.title = @"Current Street Position";
        _currentMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        _currentMarker.snippet = [NSString stringWithFormat:@"%f, %f", coordinate.latitude, coordinate.longitude];
        _currentMarker.icon = [UIImage imageNamed:@"mapXplorer_marker.png"];
        _currentMarker.map = mapView_;
    }
    
    // HEADING MARKER
    _headingMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    
    // COMPASS MARKER
    _compassMarker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    
    if ((self.isInDriving && self.isRouteOriented) ||
        (self.isInJumping))
    {
        //NSLog(@"Moving bearing = %f",self.movingBearing);
        [mapView_ animateToLocation:coordinate];
        [mapView_ animateToBearing:self.movingBearing];
    }

    // Terminate jump when intersection is found
    if (self.isInJumping && self.numberOfPathLinks > 2)
    {
        self.isInJumping = FALSE;
    }
    
    self.latitude = coordinate.latitude;
    self.longitude = coordinate.longitude;
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    if (self.bearing != position.bearing)
    {
        self.bearing = position.bearing;
        _headingMarker.rotation = self.bearing;
        // sending bearing message update to bonjour
        [self sendMessage:[NSString stringWithFormat:@"Bearing,%f", self.bearing]];
    }
}

#pragma mark - Messaging Protocol

- (void)sendMessage:(NSString *)stringMessage {
    //NSLog(@"-- Message = %@", stringMessage);
    NSData *data = [stringMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    [self.server sendData:data error:&error];
}

#pragma mark - Acceleration Handler

- (void)doAcceleration:(CMAcceleration)acceleration {
    // FOR WHETHER MOVING OR PITCHING
    if (!self.isInDriving && !self.isInPitching) {
        if (acceleration.z < -0.7) {
            self.isDeviceLaying = YES;
            self.leftImageView.image = [UIImage imageNamed:@"mapXplorer_steerDrive.png"];
            self.rightImageView.image = [UIImage imageNamed:@"mapXplorer_steerDrive.png"];
        }
        else {
            self.isDeviceLaying = NO;
            self.leftImageView.image = [UIImage imageNamed:@"mapXplorer_steerPitch.png"];
            self.rightImageView.image = [UIImage imageNamed:@"mapXplorer_steerPitch.png"];
        }
    }
    
    //NSLog(@"%lf", acceleration.z);
    if (fabsf(acceleration.z) > kShakingThreshold) {
        [self sendMessage:@"Jump"];
        [self showNotification:@"Moving forward to next intersection" withType:@"info"];
        //[self.view makeToastActivity];
        self.isInJumping = YES;
        // Hide both side visual
        _rightPanTranslationY = 0;
        self.rightImageView.image = nil;
        _leftPanTranslationY = 0;
        self.leftImageView.image = nil;
        // Cancel all activity
        [self sendMessage:@"ResetPitch"];
        self.pitch = 0;
        [self.rotationTimer invalidate];
        [self.movingTimer invalidate];
        [self.pitchTimer invalidate];
        [self.motionManager stopAccelerometerUpdates];
    }
    
    if (_justInitiated) {
        _justInitiated = NO;
        _xAccelerationBasis = acceleration.x;
        _yAccelerationBasis = acceleration.y;
        _zAccelerationBasis = acceleration.z;
        
        // SET SIDE VIEW AREA PICTURES
        [self.leftImageView setFrame:CGRectMake(self.leftImageView.frame.origin.x,
                                                _leftTouchPoint.y - (self.leftImageView.frame.size.height)/2,
                                                self.leftImageView.frame.size.width,
                                                self.leftImageView.frame.size.height)];
        [self.rightImageView setFrame:CGRectMake(self.rightImageView.frame.origin.x,
                                                 _rightTouchPoint.y - (self.rightImageView.frame.size.height)/2,
                                                 self.rightImageView.frame.size.width,
                                                 self.rightImageView.frame.size.height)];
    }
    
    // FOR ROTATION
    float cosinusXY = (_xAccelerationBasis*acceleration.x+
                       _yAccelerationBasis*acceleration.y)/
                        (sqrt(_xAccelerationBasis*_xAccelerationBasis+
                              _yAccelerationBasis*_yAccelerationBasis)*
                        sqrt(acceleration.x*acceleration.x+
                             acceleration.y*acceleration.y));
    float angleXY = acosf(cosinusXY);
    
    // Turn off auto rotation if it is ON
    if (_isInAutoRotationMode)
    {
        [self toggleAutoRotateStreetView];
    }
    
    if (angleXY > 0.2) {
        if (acceleration.y > 0) {
            // RIGHT ROTATION
            _bearingAddingValue = angleXY*10; // We put a constant of 10,
            // So the lowest speed will be 1.5 degree/0.2 seconds
            // Or in the other word: 7.5 degree/second
            [self doRotation];
        }
        else if (acceleration.y < 0) {
            // LEFT ROTATION
            _bearingAddingValue = -(angleXY*10);  // We put a constant of 10,
            // So the lowest speed will be 1.5 degree/0.2 seconds
            // Or in the other word: 7.5 degree/second
            [self doRotation];
        }
    }
    else {
        [_rotationTimer invalidate];
    }
}

- (void)doMove {
    CGFloat movingTranslation = (_leftPanTranslationY>_rightPanTranslationY)?_leftPanTranslationY:_rightPanTranslationY;
    //NSLog(@"%d", self.isInPitching);
    
    if (_leftPanTranslationY*_rightPanTranslationY > 0 &&
        fabs(_leftPanTranslationY) > self.view.bounds.size.height/10 &&
        fabs(_rightPanTranslationY) > self.view.bounds.size.height/10 &&
        self.isDeviceLaying && !self.isInPitching)
    {
        // Intersection checking
        if (self.numberOfPathLinks > 2 && self.isIntersectionAwared) {
            _leftPanTranslationY = 0;
            self.leftImageView.image = [UIImage imageNamed:@"mapXplorer_steer.png"];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.leftImageView setFrame:CGRectMake(self.leftImageView.frame.origin.x,
                                                        (self.view.bounds.size.height-244)/2,
                                                        self.leftImageView.frame.size.width,
                                                        self.leftImageView.frame.size.height)];
            }
            else {
                [self.leftImageView setFrame:CGRectMake(self.leftImageView.frame.origin.x,
                                                        (self.view.bounds.size.height-549)/2,
                                                        self.leftImageView.frame.size.width,
                                                        self.leftImageView.frame.size.height)];
            }
            
            _rightPanTranslationY = 0;
            self.rightImageView.image = [UIImage imageNamed:@"mapXplorer_steer.png"];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.rightImageView setFrame:CGRectMake(self.rightImageView.frame.origin.x,
                                                         (self.view.bounds.size.height-244)/2,
                                                         self.rightImageView.frame.size.width,
                                                         self.rightImageView.frame.size.height)];
            }
            else {
                [self.rightImageView setFrame:CGRectMake(self.rightImageView.frame.origin.x,
                                                         (self.view.bounds.size.height-549)/2,
                                                         self.rightImageView.frame.size.width,
                                                         self.rightImageView.frame.size.height)];
            }
            
            [self.motionManager stopAccelerometerUpdates];
            [self.rotationTimer invalidate];
            [self.movingTimer invalidate];
            [self.pitchTimer invalidate];
            [self sendMessage:@"ResetPitch"];
            self.pitch = 0;
            self.isInDriving = NO;
            self.isInPitching = NO;
            
            self.numberOfPathLinks = -1;
            
            [self showNotification:@"Arrived on an intersection" withType:@"info"];
        }
        else {
            if (self.pitch != 0) {
                self.pitch = 0;
                [self sendMessage:@"ResetPitch"];
            }
            
            self.isInDriving = YES;
            if (movingTranslation < 0) {
                [self sendMessage:@"Forward"];
            }
            else if (movingTranslation > 0) {
                [self sendMessage:@"Backward"];
            }
            NSLog(@"interval = %f", self.view.bounds.size.height/fabs(movingTranslation)/self.drivingAccelerationLevel);
            self.movingTimer = [NSTimer scheduledTimerWithTimeInterval:self.view.bounds.size.height/fabs(movingTranslation)/self.drivingAccelerationLevel target:self selector:@selector(doMove) userInfo:nil repeats:NO];
        }
    }
    else {
        self.isInDriving = NO;
        // DEFAULT SPEED FOR NEXT TIMER CHECKING = 0.5 second
        self.movingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doMove) userInfo:nil repeats:NO];
    }
}

- (void)doPitch {
    CGFloat pitchTranslation = (_leftPanTranslationY>_rightPanTranslationY)?_leftPanTranslationY:_rightPanTranslationY;
    
    if ([self.pitchPreference isEqualToString:@"Velocity"]) {
        if (_leftPanTranslationY*_rightPanTranslationY > 0 &&
            fabs(_leftPanTranslationY) > self.view.bounds.size.height/10 &&
            fabs(_rightPanTranslationY) > self.view.bounds.size.height/10 &&
            !self.isDeviceLaying && !self.isInDriving)
        {
            self.isInPitching = YES;
            if (pitchTranslation < 0 && self.pitch < 89.8) {        // Expected highest pitch = 90 degrees
                self.pitch += 0.2;
            }
            else if (pitchTranslation > 0 && self.pitch > -39.8) {  // Expected lowest pitch = -40 degrees
                self.pitch -= 0.2;
            }
            [self sendMessage:[NSString stringWithFormat:@"Pitch,%f", self.pitch]];
            self.pitchTimer = [NSTimer scheduledTimerWithTimeInterval:self.view.bounds.size.height/fabs(pitchTranslation)/300 target:self selector:@selector(doPitch) userInfo:nil repeats:NO];
        }
        else {
            // DEFAULT SPEED FOR NEXT TIMER CHECKING = 0.5 second
            self.isInPitching = NO;
            self.pitchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doPitch) userInfo:nil repeats:NO];
        }
    }
    else if ([self.pitchPreference isEqualToString:@"Position"]) {
        if (!self.isDeviceLaying && !self.isInDriving) {
            if (_leftPanTranslationY*_rightPanTranslationY > 0) {
                self.pitch = -pitchTranslation/self.leftPanGestureView.frame.size.height*90;
                [self sendMessage:[NSString stringWithFormat:@"Pitch, %f", self.pitch]];
            }
            if (fabs(_leftPanTranslationY) > self.view.bounds.size.height/10 &&
                fabs(_rightPanTranslationY) > self.view.bounds.size.height/10) {
                self.isInPitching = YES;
            }
            else {
                self.isInPitching = NO;
            }
        }
        self.pitchTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(doPitch) userInfo:nil repeats:NO];
    }
}

- (void)doRotation {
    if (!self.isInDriving) {
        self.bearing += _bearingAddingValue;
        [mapView_ animateToBearing:self.bearing];
    }
}

#pragma mark Additional Features

- (void)toggleAutoRotateStreetView {
    self.isInAutoRotationMode = self.isInAutoRotationMode?NO:YES;
    if (self.isInAutoRotationMode) {
        _autoRotateStreetViewButton.title = @"Stop Auto Rotate";
        _bearingAddingValue = 1.5;
        self.autoRotationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(doRotation) userInfo:nil repeats:YES];
    } else {
        _autoRotateStreetViewButton.title = @"Start Auto Rotate";
        [self.autoRotationTimer invalidate];
    }
}

- (void)showNotification:(NSString *)notification withType:(NSString *)type {
    //[self.view hideToastActivity];
    if ([type isEqualToString:@"info"]) {
        /*
        [self.view makeToast:notification
                    duration:3.0
                    position:@"center"
                    title:@"Notification Info:"
                    image:[UIImage imageNamed:@"info.png"]]; */
        [self.view makeToast:notification
                    duration:2.0
                    position:@"bottom"
                    image:[UIImage imageNamed:@"info.png"]];
    }
    [self sendMessage:[NSString stringWithFormat:@"Notification,%@",notification]];
}

@end

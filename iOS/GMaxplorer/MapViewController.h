//
//  ViewController.h
//  GMaxplorer
//
//  Created by Hadziq Fabroyir on 3/7/13.
//  Copyright (c) 2013 NRLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreMotion/CoreMotion.h>
#import "NSMutableArray+FloatQueue.h"

#define kShakingThreshold 1.2

@class Server;

@interface MapViewController : UIViewController<GMSMapViewDelegate, UIGestureRecognizerDelegate> {
    NSString *_message;
    Server *_server;
    
    UIBarButtonItem *_autoRotateStreetViewButton;
    
    BOOL _justInitiated;
    
    float _xAccelerationBasis;
    float _yAccelerationBasis;
    float _zAccelerationBasis;
    
    float _bearingAddingValue;
    
    NSTimer *_pitchTimer;
    NSTimer *_movingTimer;
    NSTimer *_rotationTimer;
    NSTimer *_autoRotationTimer;
    
    GMSMarker *_currentMarker;
    GMSMarker *_compassMarker;
    GMSMarker *_headingMarker;
    
    CGFloat _leftPanTranslationY;
    CGFloat _rightPanTranslationY;
    CGPoint _leftTouchPoint;
    CGPoint _rightTouchPoint;
}

@property(nonatomic, retain) NSTimer *pitchTimer;
@property(nonatomic, retain) NSTimer *movingTimer;
@property(nonatomic, retain) NSTimer *rotationTimer;
@property(nonatomic, retain) NSTimer *autoRotationTimer;

@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) Server *server;

@property(nonatomic, strong) UIView *rightPanGestureView;
@property(nonatomic, strong) UIView *leftPanGestureView;
@property(nonatomic, strong) UIImageView *leftImageView;
@property(nonatomic, strong) UIImageView *rightImageView;
@property(nonatomic, strong) UIPanGestureRecognizer *leftDrivePan;
@property(nonatomic, strong) UIPanGestureRecognizer *rightDrivePan;

@property(nonatomic, assign) BOOL isUserLocationEnabled;
@property(nonatomic, assign) BOOL isLocationDescriptionEnabled;
@property(nonatomic, assign) NSString *pitchPreference;
@property(nonatomic, assign) BOOL isRouteOriented;
@property(nonatomic, assign) BOOL isNorthDependent;
@property(nonatomic, assign) BOOL isIntersectionAwared;
@property(nonatomic, assign) int drivingAccelerationLevel;
@property(nonatomic, assign) BOOL isInAutoRotationMode;
@property(nonatomic, assign) BOOL isDeviceLaying;
@property(nonatomic, assign) BOOL isInDriving;
@property(nonatomic, assign) BOOL isInJumping;
@property(nonatomic, assign) BOOL isInPitching;

@property(nonatomic, assign) CLLocationDirection bearing;
@property(nonatomic, assign) CLLocationDirection movingBearing;
@property(nonatomic, assign) CLLocationDegrees latitude;
@property(nonatomic, assign) CLLocationDegrees longitude;
@property(nonatomic, assign) int numberOfPathLinks;
@property(nonatomic, assign) CGFloat pitch;

@property(nonatomic, strong) CMMotionManager *motionManager;

- (void)sendMessage:(NSString*)stringMessage;
- (void)doAcceleration:(CMAcceleration)acceleration;
- (void)resetLocation:(CLLocationCoordinate2D)coordinate;

- (void)handleLeftPitchPan:(UIPanGestureRecognizer *)event;
- (void)handleRightPitchPan:(UIPanGestureRecognizer *)event;

- (void)toggleAutoRotateStreetView;

- (void)doMove;
- (void)doRotation;
- (void)doPitch;

- (void)showNotification:(NSString*)notification withType:(NSString*)type;

@end

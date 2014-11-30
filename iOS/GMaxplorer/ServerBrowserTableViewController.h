//
//  ServerBrowserTableViewController.h
//

#import <UIKit/UIKit.h>

@class Server;
@class MainAppDelegate;
@class MapViewController;

@interface ServerBrowserTableViewController : UITableViewController {
    Server *_server;
	NSMutableArray *_services;
    NSArray *_spotName;
    NSArray *_spotPosition;
    int _selectedSpotIndex;
    
    MainAppDelegate *_appDelegate;
    UIView *_firstFooterView;
    UIButton *_startButton;
    UILabel *_userLocationLabel;
    UISwitch *_userLocationSwitch;
    UILabel *_locationDescriptionLabel;
    UISwitch *_locationDescriptionSwitch;
    UILabel *_pitchPreferenceLabel;
    UISegmentedControl *_pitchPreferenceSegmentedControl;
    UILabel *_routeOrientedLabel;
    UISwitch *_routeOrientedSwitch;
    UILabel *_northDependentLabel;
    UISwitch *_northDependentSwitch;
    UILabel *_intersectionAwaredLabel;
    UISwitch *_intersectionAwaredSwitch;
}

@property(nonatomic, retain) Server *server;
@property(nonatomic, retain) NSMutableArray *services;
@property(nonatomic, retain) NSArray *spotName;
@property(nonatomic, retain) NSArray *spotPosition;

@property(nonatomic, strong) MainAppDelegate *appDelegate;
@property(nonatomic, strong) UIView *firstFooterView;
@property(nonatomic, strong) UIButton *startButton;
@property(nonatomic, strong) UILabel *userLocationLabel;
@property(nonatomic, strong) UISwitch *userLocationSwitch;
@property(nonatomic, strong) UILabel *locationDescriptionLabel;
@property(nonatomic, strong) UISwitch *locationDescriptionSwitch;
@property(nonatomic, strong) UILabel *pitchPreferenceLabel;
@property(nonatomic, strong) UISegmentedControl *pitchPreferenceSegmentedControl;
@property(nonatomic, strong) UILabel *routeOrientedLabel;
@property(nonatomic, strong) UISwitch *routeOrientedSwitch;
@property(nonatomic, strong) UILabel *northDependentLabel;
@property(nonatomic, strong) UISwitch *northDependentSwitch;
@property(nonatomic, strong) UILabel *intersectionAwaredLabel;
@property(nonatomic, strong) UISwitch *intersectionAwaredSwitch;
@property(nonatomic, strong) UILabel *drivingAccelerationLevelLabel;
@property(nonatomic, strong) UIStepper *drivingAccelerationLevelStepper;

- (void)addService:(NSNetService *)service moreComing:(BOOL)moreComing;
- (void)removeService:(NSNetService *)service moreComing:(BOOL)moreComing;

- (void)enableStartButton:(id)sender;
- (void)disableStartButton:(id)sender;
- (void)startMap:(id)sender;

- (void)didChangeUserLocationSwitch:(id)sender;
- (void)didChangeLocationDescriptionSwitch:(id)sender;
- (void)didChangePitchPreferenceSegmentedControl:(id)sender;
- (void)didChangeRouteOrientedSwitch:(id)sender;
- (void)didChangeNorthDependentSwitch:(id)sender;
- (void)didChangeIntersectionAwaredSwitch:(id)sender;
- (void)drivingAccelerationLevelStepperValueChanged:(UIStepper *)sender;

@end

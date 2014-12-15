//
//  ServerBrowser.m
//  NetworkingTesting
//
//  Created by Bill Dudney on 2/21/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//

#import "ServerBrowserTableViewController.h"
#import "MainAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation ServerBrowserTableViewController

@synthesize services = _services;
@synthesize server = _server;
@synthesize spotName = _spotName;
@synthesize spotPosition = _spotPosition;

@synthesize firstFooterView = _firstFooterView;
@synthesize appDelegate = _appDelegate;
@synthesize startButton = _startButton;
@synthesize userLocationLabel = _userLocationLabel;
@synthesize userLocationSwitch = _userLocationSwitch;
@synthesize locationDescriptionLabel = _locationDescriptionLabel;
@synthesize locationDescriptionSwitch = _locationDescriptionSwitch;
@synthesize northDependentLabel = _northDependentLabel;
@synthesize northDependentSwitch = _northDependentSwitch;
@synthesize routeOrientedLabel = _routeOrientedLabel;
@synthesize routeOrientedSwitch = _routeOrientedSwitch;
@synthesize intersectionAwaredLabel = _intersectionAwaredLabel;
@synthesize intersectionAwaredSwitch = _intersectionAwaredSwitch;
@synthesize pitchPreferenceLabel = _pitchPreferenceLabel;
@synthesize pitchPreferenceSegmentedControl = _pitchPreferenceSegmentedControl;
@synthesize drivingAccelerationLevelLabel = _drivingAccelerationLevelLabel;
@synthesize drivingAccelerationLevelStepper = _drivingAccelerationLevelStepper;

-(void)viewDidLoad {
    self.title = @"MapXplorer Settings";
    self.services = nil;
    self.appDelegate = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    // Layout Configuration
    int xLeft;
    int xRight;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        xLeft = 14;
        xRight = -92;
    } else {
        xLeft = 60;
        xRight = -136;
    }
    self.userLocationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake                (xRight, 40, 0, 0)];
    self.userLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake                  (xLeft, 40, 600, 29)];
    self.locationDescriptionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake         (xRight, 80, 0, 0)];
    self.locationDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake           (xLeft, 80, 600, 29)];
    self.routeOrientedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake               (xRight, 120, 0, 0)];
    self.routeOrientedLabel = [[UILabel alloc] initWithFrame:CGRectMake                 (xLeft, 120, 600, 29)];
    self.northDependentSwitch = [[UISwitch alloc] initWithFrame:CGRectMake              (xRight, 160, 0, 0)];
    self.northDependentLabel = [[UILabel alloc] initWithFrame:CGRectMake                (xLeft, 160, 600, 29)];
    self.intersectionAwaredSwitch = [[UISwitch alloc] initWithFrame:CGRectMake          (xRight, 200, 0, 0)];
    self.intersectionAwaredLabel = [[UILabel alloc] initWithFrame:CGRectMake            (xLeft, 200, 600, 29)];
    self.drivingAccelerationLevelStepper = [[UIStepper alloc] initWithFrame:CGRectMake  (xRight-40, 240, 0, 0)];
    self.drivingAccelerationLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake      (xLeft, 240, 600, 29)];
    NSArray *itemArray = [NSArray arrayWithObjects: @"Velocity", @"Position", nil];
    self.pitchPreferenceSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    self.pitchPreferenceSegmentedControl.frame = CGRectMake                             (xRight-120, 280, 200, 30);
    self.pitchPreferenceLabel = [[UILabel alloc] initWithFrame:CGRectMake               (xLeft, 280, 500, 29)];
    
    // Starting Location List Configuration
   self.spotName = [NSArray arrayWithObjects:
                    //@"Keelung Rd. Sec. 4 (fly over), Taipei, Taiwan",
                    //@"NTUST (inside front gate), Taipei, Taiwan",
                    @"NCTU (front gate), Hsinchu, Taiwan",
                    @"Hsinchu Train Station",
                    @"National Palace Museum (inside), Taipei, Taiwan",
                    @"Chiang Kai-Shek Memorial Hall, Taipei, Taiwan",
                    /*@"Yeonsero, Seoul, South Korea",
                    @"Road 14, Busan, South Korea",
                    @"Shibuya Station, Tokyo, Japan",
                    @"3, Sonezaki 2-Chome, Osaka, Japan",
                    @"3, Umeda 1-Chome, Osaka, Japan",
                    @"Argyle Street, Hongkong",
                    @"265-267 Oxford Street, Sydney, Australia",
                    @"97 Ponsoby Road, Auckland, New Zealand",
                    @"Jhancian Underpass, Taipei, Taiwan",
                    @"Siyuan Road Section 1, Taipei, Taiwan",*/
                    @"Sendai Train Station (Front Gate), Sendai, Japan",
                    @"Taichung Train Station (Front Gate), Taichung, Taiwan",
                    @"Harajuku Train Station (Front Gate), Tokyo, Japan",
                    @"Ximen MRT Station (Exit 3), Taipei, Taiwan",
                    nil
                    ];
    self.spotPosition = [NSArray arrayWithObjects:
                         //[NSValue valueWithCGPoint:CGPointMake(25.014496, 121.541238)],
                         //[NSValue valueWithCGPoint:CGPointMake(25.013578, 121.540597)],
                         [NSValue valueWithCGPoint:CGPointMake(24.789426, 121.000081)],
                         [NSValue valueWithCGPoint:CGPointMake(24.801643, 120.971696)],
                         [NSValue valueWithCGPoint:CGPointMake(25.102205, 121.548571)],
                         [NSValue valueWithCGPoint:CGPointMake(25.035447, 121.520226)],
                         /*[NSValue valueWithCGPoint:CGPointMake(37.555332, 126.936844)],
                         [NSValue valueWithCGPoint:CGPointMake(35.198343, 129.096528)],
                         [NSValue valueWithCGPoint:CGPointMake(35.659545, 139.702420)],
                         [NSValue valueWithCGPoint:CGPointMake(34.698300, 135.500610)],
                         [NSValue valueWithCGPoint:CGPointMake(34.698504, 135.495577)],
                         [NSValue valueWithCGPoint:CGPointMake(22.319786, 114.171560)],
                         [NSValue valueWithCGPoint:CGPointMake(-33.881604, 151.219196)],
                         [NSValue valueWithCGPoint:CGPointMake(-36.856384, 174.746760)],
                         [NSValue valueWithCGPoint:CGPointMake(25.047220, 121.513270)],
                         [NSValue valueWithCGPoint:CGPointMake(25.033105, 121.498001)],*/
                         [NSValue valueWithCGPoint:CGPointMake(38.261447,140.881637)],
                         [NSValue valueWithCGPoint:CGPointMake(24.136973,120.684836)],
                         [NSValue valueWithCGPoint:CGPointMake(35.670264,139.702863)],
                         [NSValue valueWithCGPoint:CGPointMake(25.041982,121.508749)],
                         nil
                        ];
    _selectedSpotIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.tableView reloadData];
    [self.startButton setTitle:@"Click Here to Go Back to the Map" forState:UIControlStateNormal];
    _selectedSpotIndex = -1;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //self.services = nil;
}

- (NSMutableArray *)services {
    if(nil == _services) {
        self.services = [NSMutableArray array];
    }
    return _services;
}

- (void)addService:(NSNetService *)service moreComing:(BOOL)more {
    [self.services addObject:service];
    if(!more) {
        [self.tableView reloadData];
    }
}

- (void)removeService:(NSNetService *)service moreComing:(BOOL)more {
    [self.services removeObject:service];
    if(!more) {
        [self.tableView reloadData];
    }
}

#pragma mark Table View methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionHeaderTitle;
    if (section == 0) {
        if (self.services.count > 0) {
            sectionHeaderTitle = @"Select Available Services:";
        } else {
            sectionHeaderTitle = @"- None of Service is Available -";
        }
    }
    else if (section == 1 && self.appDelegate.isConnectedToServer) {
        sectionHeaderTitle = @"Select Initial Location:";
    }
    
    return sectionHeaderTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cellContent = 0;
    
    if (section == 0) {
        cellContent = self.services.count;
    }
    else if (section == 1 && self.appDelegate.isConnectedToServer) {
        cellContent = self.spotName.count;
    }
    
    return cellContent;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        height = 380;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [[self.services objectAtIndex:indexPath.row] name];
    }
    else if (indexPath.section == 1 && self.appDelegate.isConnectedToServer) {
        cell.textLabel.text = [self.spotName objectAtIndex:indexPath.row];
    }
    
    if (indexPath.row % 2) {
        [cell setBackgroundColor:[UIColor colorWithRed:238.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0]];
    }
    else {
        [cell setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    }
    
    /*
    if (_selectedSpotIndex > -1) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedSpotIndex inSection:1] animated:NO scrollPosition:0];
    }*/
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.server connectToRemoteService:[self.services objectAtIndex:indexPath.row]];
    }
    else if (indexPath.section == 1 && self.appDelegate.isConnectedToServer) {
        _selectedSpotIndex = indexPath.row;
        [self.appDelegate setLatitude:[[self.spotPosition objectAtIndex:indexPath.row] CGPointValue].x
                         andLongitude:[[self.spotPosition objectAtIndex:indexPath.row] CGPointValue].y];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = nil;
    if (section == 0) {
        if (self.firstFooterView == nil) {
            self.firstFooterView = [[UIView alloc] init];
            // START BUTTON
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.startButton setFrame:CGRectMake(14, 340, tableView.frame.size.width-30, 44)];
                [self.startButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
            } else {
                [self.startButton setFrame:CGRectMake(60, 340, tableView.frame.size.width-120, 44)];
                [self.startButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
            }
            // Button settings for enabled mode
            UIImage *activeImage = [[UIImage imageNamed:@"button_green.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
            [self.startButton setBackgroundImage:activeImage forState:UIControlStateNormal];
            [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.startButton setTitle:@"Click Here to Start the Map" forState:UIControlStateNormal];
            // Button settings for pressed mode
            UIImage *clickImage = [[UIImage imageNamed:@"button_grey_dark.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
            [self.startButton setBackgroundImage:clickImage forState:UIControlStateHighlighted];
            [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [self.startButton setTitle:@"Now is Loading the Map ..." forState:UIControlStateHighlighted];
            // Button settings for disabled mode
            UIImage *inactiveImage = [[UIImage imageNamed:@"button_grey_light.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
            [self.startButton setBackgroundImage:inactiveImage forState:UIControlStateDisabled];
            [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
            [self.startButton setTitle:@"None of Service is Selected" forState:UIControlStateDisabled];
            // Set an action for the button
            [self.startButton addTarget:self action:@selector(startMap:) forControlEvents:UIControlEventTouchUpInside];
            // Check server connectivity
            [self.startButton setEnabled:[self.appDelegate isConnectedToServer]];
            // Register the button to the view
            [self.firstFooterView addSubview:self.startButton];
            
            // LOCATION DESCRIPTION LABEL
            self.locationDescriptionLabel.text = @"Show Street Location Description";
            self.locationDescriptionLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            self.locationDescriptionLabel.textAlignment = NSTextAlignmentLeft;
            self.locationDescriptionLabel.backgroundColor = [UIColor clearColor];
            self.locationDescriptionLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
            self.locationDescriptionLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.locationDescriptionLabel.layer.shadowOpacity = 1.0f;
            self.locationDescriptionLabel.layer.shadowRadius = 0.0f;
            [self.firstFooterView addSubview:self.locationDescriptionLabel];
            
            // LOCATION DESCRIPTION SWITCH
            self.locationDescriptionSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self.locationDescriptionSwitch addTarget:self action:@selector(didChangeLocationDescriptionSwitch:)
                                     forControlEvents:UIControlEventValueChanged];
            self.locationDescriptionSwitch.on = NO;
            [self.appDelegate toggleLocationDescription:NO];
            [self.firstFooterView addSubview:self.locationDescriptionSwitch];
            
            // USER LOCATION LABEL
            self.userLocationLabel.text = @"Show Real Current Location";
            self.userLocationLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            self.userLocationLabel.textAlignment = NSTextAlignmentLeft;
            self.userLocationLabel.backgroundColor = [UIColor clearColor];
            self.userLocationLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
            self.userLocationLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.userLocationLabel.layer.shadowOpacity = 1.0f;
            self.userLocationLabel.layer.shadowRadius = 0.0f;
            [self.firstFooterView addSubview:self.userLocationLabel];
            
            // USER LOCATION SWITCH
            self.userLocationSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self.userLocationSwitch addTarget:self action:@selector(didChangeUserLocationSwitch:)
                              forControlEvents:UIControlEventValueChanged];
            self.userLocationSwitch.on = YES;
            [self.appDelegate toggleUserLocation:YES];
            [self.firstFooterView addSubview:self.userLocationSwitch];
            
            // ROUTE ORIENTED LABEL
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                self.routeOrientedLabel.text = @"Route-based Orientation";
            } else {
                self.routeOrientedLabel.text = @"Adjust Street View Orientation Based on The Driving Route";
            }
            self.routeOrientedLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            self.routeOrientedLabel.textAlignment = NSTextAlignmentLeft;
            self.routeOrientedLabel.backgroundColor = [UIColor clearColor];
            self.routeOrientedLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
            self.routeOrientedLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.routeOrientedLabel.layer.shadowOpacity = 1.0f;
            self.routeOrientedLabel.layer.shadowRadius = 0.0f;
            [self.firstFooterView addSubview:self.routeOrientedLabel];
            
            // ROUTE ORIENTED SWITCH
            self.routeOrientedSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self.routeOrientedSwitch addTarget:self action:@selector(didChangeRouteOrientedSwitch:)
                               forControlEvents:UIControlEventValueChanged];
            self.routeOrientedSwitch.on = YES;
            [self.appDelegate toggleRouteOriented:YES];
            [self.firstFooterView addSubview:self.routeOrientedSwitch];
            
            // NORTH DEPENDENT LABEL
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                self.northDependentLabel.text = @"North Orientation Priority";
            } else {
                self.northDependentLabel.text = @"Once Location is Updated Rotate Orientation to North";
            }
            
            self.northDependentLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            self.northDependentLabel.textAlignment = NSTextAlignmentLeft;
            self.northDependentLabel.backgroundColor = [UIColor clearColor];
            self.northDependentLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
            self.northDependentLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.northDependentLabel.layer.shadowOpacity = 1.0f;
            self.northDependentLabel.layer.shadowRadius = 0.0f;
            [self.firstFooterView addSubview:self.northDependentLabel];
            
            // NORTH DEPENDENT SWITCH
            self.northDependentSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self.northDependentSwitch addTarget:self action:@selector(didChangeNorthDependentSwitch:)
                                forControlEvents:UIControlEventValueChanged];
            self.northDependentSwitch.on = NO;
            [self.appDelegate toggleNorthDependent:NO];
            [self.firstFooterView addSubview:self.northDependentSwitch];
            
            // INTERSECTION AWARE LABEL
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                self.intersectionAwaredLabel.text = @"Intersection Aware Driving";
            } else {
                self.intersectionAwaredLabel.text = @"Always Stop by at Intersection During The Drive";
            }
            self.intersectionAwaredLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            self.intersectionAwaredLabel.textAlignment = NSTextAlignmentLeft;
            self.intersectionAwaredLabel.backgroundColor = [UIColor clearColor];
            self.intersectionAwaredLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
            self.intersectionAwaredLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.intersectionAwaredLabel.layer.shadowOpacity = 1.0f;
            self.intersectionAwaredLabel.layer.shadowRadius = 0.0f;
            [self.firstFooterView addSubview:self.intersectionAwaredLabel];
            
            // INTERSECTION AWARE SWITCH
            self.intersectionAwaredSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self.intersectionAwaredSwitch addTarget:self action:@selector(didChangeIntersectionAwaredSwitch:)
                                    forControlEvents:UIControlEventValueChanged];
            self.intersectionAwaredSwitch.on = YES;
            [self.appDelegate toggleIntersectionAwared:YES];
            [self.firstFooterView addSubview:self.intersectionAwaredSwitch];
            
            // PITCH PREFERENCE LABEL
            self.pitchPreferenceLabel.text = @"Pitch Street View Based On ";
            self.pitchPreferenceLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            self.pitchPreferenceLabel.textAlignment = NSTextAlignmentLeft;
            self.pitchPreferenceLabel.backgroundColor = [UIColor clearColor];
            self.pitchPreferenceLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
            self.pitchPreferenceLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.pitchPreferenceLabel.layer.shadowOpacity = 1.0f;
            self.pitchPreferenceLabel.layer.shadowRadius = 0.0f;
            [self.firstFooterView addSubview:self.pitchPreferenceLabel];
            
            // PITCH PREFERENCE SEGMENTED CONTROL
            self.pitchPreferenceSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self.pitchPreferenceSegmentedControl addTarget:self action:@selector(didChangePitchPreferenceSegmentedControl:)
                                           forControlEvents:UIControlEventValueChanged];
            self.pitchPreferenceSegmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
            self.pitchPreferenceSegmentedControl.selectedSegmentIndex = 1;
            [self.appDelegate togglePitchPreference:[self.pitchPreferenceSegmentedControl titleForSegmentAtIndex:self.pitchPreferenceSegmentedControl.selectedSegmentIndex]];
            [self.firstFooterView addSubview:self.pitchPreferenceSegmentedControl];
            
            // DRIVING ACCELERATION LEVEL LABEL
            self.drivingAccelerationLevelLabel.text = @"Driving Acceleration Level = 2";
            self.drivingAccelerationLevelLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            self.drivingAccelerationLevelLabel.textAlignment = NSTextAlignmentLeft;
            self.drivingAccelerationLevelLabel.backgroundColor = [UIColor clearColor];
            self.drivingAccelerationLevelLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
            self.drivingAccelerationLevelLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.drivingAccelerationLevelLabel.layer.shadowOpacity = 1.0f;
            self.drivingAccelerationLevelLabel.layer.shadowRadius = 0.0f;
            [self.firstFooterView addSubview:self.drivingAccelerationLevelLabel];
            
            // DRIVING ACCELERATION LEVEL STEPPER
            self.drivingAccelerationLevelStepper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self.drivingAccelerationLevelStepper addTarget:self action:@selector(drivingAccelerationLevelStepperValueChanged:)
                                           forControlEvents:UIControlEventValueChanged];
            self.drivingAccelerationLevelStepper.maximumValue = 6;
            self.drivingAccelerationLevelStepper.minimumValue = 1;
            self.drivingAccelerationLevelStepper.stepValue = 1;
            self.drivingAccelerationLevelStepper.value = 2;
            [self.appDelegate changeDrivingAccelerationLevel:2];
            [self.firstFooterView addSubview:self.drivingAccelerationLevelStepper];
        }
        footer = self.firstFooterView;
    }
    return footer;
}

#pragma mark - UI Handler

- (void)startMap:(id)sender {
    [self.startButton setTitle:@"Now is Loading the Map ..." forState:UIControlStateNormal];
    [self.appDelegate startMap];
}

- (void)enableStartButton:(id)sender {
    [self.startButton setEnabled:YES];
}

- (void)disableStartButton:(id)sender {
    [self.startButton setEnabled:NO];
}

- (void)didChangeUserLocationSwitch:(id)sender {
    [self.appDelegate toggleUserLocation:self.userLocationSwitch.isOn];
}

- (void)didChangeLocationDescriptionSwitch:(id)sender {
    [self.appDelegate toggleLocationDescription:self.locationDescriptionSwitch.isOn];
}

- (void)didChangePitchPreferenceSegmentedControl:(id)sender {
    [self.appDelegate togglePitchPreference:[self.pitchPreferenceSegmentedControl titleForSegmentAtIndex:self.pitchPreferenceSegmentedControl.selectedSegmentIndex]];
}

- (void)didChangeRouteOrientedSwitch:(id)sender {
    [self.appDelegate toggleRouteOriented:self.routeOrientedSwitch.isOn];
}

- (void)didChangeNorthDependentSwitch:(id)sender {
    [self.appDelegate toggleNorthDependent:self.northDependentSwitch.isOn];
}

- (void)didChangeIntersectionAwaredSwitch:(id)sender {
    [self.appDelegate toggleIntersectionAwared:self.intersectionAwaredSwitch.isOn];
}

- (void)drivingAccelerationLevelStepperValueChanged:(UIStepper *)sender {
    double value = [sender value];
    [self.drivingAccelerationLevelLabel setText:[NSString stringWithFormat:@"Driving Acceleration Level = %d", (int)value]];
    [self.appDelegate changeDrivingAccelerationLevel:self.drivingAccelerationLevelStepper.value];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    self.services = nil;
    self.server = nil;
}

@end

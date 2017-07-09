//
//  NearYouViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/20/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "NearYouViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface NearYouViewController () {
    UIVisualEffectView *ev;
    UITapGestureRecognizer *tapGestureRecognizer;
}

@end

@implementation NearYouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inAppNotification:)
                                                 name:@"InAppNotification"
                                               object:nil];
    _notification = [[AFDropdownNotification alloc] init];
    _notification.notificationDelegate = self;
    // Do any additional setup after loading the view.
    locationsArray = [[NSMutableArray alloc] init];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.mapContainerView.layer.cornerRadius = 10;
    self.backgroundView.layer.cornerRadius = 10;
    self.handleView.layer.cornerRadius = 2.5;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    [self.mapContainerView addGestureRecognizer:panGestureRecognizer];
    self.mapContainerView.layer.masksToBounds = NO;
    self.mapContainerView.layer.shadowRadius = 2;
    self.mapContainerView.layer.shadowOpacity = .25;
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    ev = [[UIVisualEffectView alloc] initWithEffect:blur];
    ev.frame = self.mapContainerView.frame;
    [self.view addSubview:ev];
    [self.view bringSubviewToFront:self.mapContainerView];
    //[self getTable];
    //timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTable) userInfo:nil repeats:YES];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        // Call your method/function here
        [self getTable];
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            [self.tableView reloadData];

        });
    });
}




- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    return center;
}


-(void)getTable {
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    //    scanExpression.limit = @10;
    
    [[[dynamoDBObjectMapper scan:[Locations class]
                      expression:scanExpression]
      continueWithBlock:^id(AWSTask *task) {
          if (task.error) {
              NSLog(@"The request failed. Error: [%@]", task.error);
          } else {
              AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
              for (Locations *location in paginatedOutput.items) {
                  NSMutableArray *item = [[NSMutableArray alloc] initWithObjects:location.Name, location.Address, nil];
                  [locationsArray addObject:item];
                  CLLocationCoordinate2D locationCoordinate = [self geoCodeUsingAddress:location.Address];
                  MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                  point.coordinate = locationCoordinate;
                  point.title = location.Name;
                  point.subtitle = location.Address;
                  [self.mapView addAnnotation:point];
              }
          }
          return nil;
      }] waitUntilFinished];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (locationUpdated) {
        
    } else {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 5000, 5000);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        locationUpdated = YES;
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return locationsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [locationsArray objectAtIndex:indexPath.row][0]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [locationsArray objectAtIndex:indexPath.row][1]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    // OPEN ORDER DETAILS VIEW CONTROLLER
    selectedLocationAddress = [locationsArray objectAtIndex:indexPath.row][1];
    [self performSegueWithIdentifier:@"goOrderNow" sender:nil];
    //    OrderDetailsTableViewController *secondViewController = [[OrderDetailsTableViewController alloc] init];
    //    secondViewController.orderId = [(Orders *)[ordersArray objectAtIndex:indexPath.row] OrderId]; // Set the exposed property
    //    [self.navigationController pushViewController:secondViewController animated:YES];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // Annotation is your custom class that holds information about the annotation
    //view.annotation.title
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewWithGestureRecognizer:)];
    [view addGestureRecognizer:tapGestureRecognizer];
    selectedLocationAddress = view.annotation.subtitle;
}


-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    [view removeGestureRecognizer:tapGestureRecognizer];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
    OrderNowTableViewController *controller = (OrderNowTableViewController *)navController.topViewController;
    controller.selectedAddress = selectedLocationAddress;
}


-(void)tapViewWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self performSegueWithIdentifier:@"goOrderNow" sender:nil];
    NSLog(@"TAPPED");
}


-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];

    if((panGestureRecognizer.view.frame.origin.y + translation.y) <= 80) {
        panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x, 410);
        [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        ev.frame = self.mapContainerView.frame;
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, panGestureRecognizer.view.center.y-330, 0)];

    } else {
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if ((panGestureRecognizer.view.frame.origin.y + translation.y) >= 500) {
                panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x, 957);
                [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
                ev.frame = self.mapContainerView.frame;
                [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, panGestureRecognizer.view.center.y-330, 0)];
            } else if (((panGestureRecognizer.view.frame.origin.y + translation.y) <= 500) && ((panGestureRecognizer.view.frame.origin.y + translation.y) >= 300)) {
                panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x, 692);
                [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
                ev.frame = self.mapContainerView.frame;
                [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, panGestureRecognizer.view.center.y-330, 0)];
            } else if (((panGestureRecognizer.view.frame.origin.y + translation.y) <= 300)) {
                panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x, 410);
                [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
                ev.frame = self.mapContainerView.frame;
                [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, panGestureRecognizer.view.center.y-330, 0)];
            }
            
        } else {
            panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x, panGestureRecognizer.view.center.y + translation.y);
            [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
            ev.frame = self.mapContainerView.frame;
            [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, panGestureRecognizer.view.center.y-330, 0)];
        }
        
    }

}

-(void)inAppNotification:(NSNotification*)sender {
    // Perform action here
    _notification.titleText = @"DRINKS";
    _notification.subtitleText = [[sender object] valueForKey:@"message"];
    _notification.image = [UIImage imageNamed:@"profileIcon"];
    _notification.topButtonText = @"Accept";
    _notification.bottomButtonText = @"Cancel";
    _notification.dismissOnTap = YES;
    [_notification presentInView:self.view withGravityAnimation:YES];
    
    [_notification listenEventsWithBlock:^(AFDropdownNotificationEvent event) {
        
        switch (event) {
            case AFDropdownNotificationEventTopButton:
                // Top button
                break;
                
            case AFDropdownNotificationEventBottomButton:
                // Bottom button
                break;
                
            case AFDropdownNotificationEventTap:
                // Tap
                break;
                
            default:
                break;
        }
    }];
    
    NSLog(@"show notification");
    
    
}

-(void)dropdownNotificationTopButtonTapped {
    
    NSLog(@"Top button tapped");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Top button tapped" message:@"Hooray! You tapped the top button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [_notification dismissWithGravityAnimation:YES];
}

-(void)dropdownNotificationBottomButtonTapped {
    
    NSLog(@"Bottom button tapped");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bottom button tapped" message:@"Hooray! You tapped the bottom button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [_notification dismissWithGravityAnimation:YES];
}

@end

//
//  YourOrdersTableViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/19/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "YourOrdersTableViewController.h"

@interface YourOrdersTableViewController ()

@end

@implementation YourOrdersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    locationsArray = [[NSMutableArray alloc] init];
    distanceAwayArray = [[NSMutableArray alloc] init];
    currentOrdersArray = [[NSMutableArray alloc] init];
    pastOrdersArray = [[NSMutableArray alloc] init];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    
    [[dynamoDBObjectMapper scan:[Orders class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         } else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (Orders *order in paginatedOutput.items) {
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 NSString *username = [defaults stringForKey:@"currentUsername"];
                 NSString *userPool = [defaults stringForKey:@"userPool"];
                 if([userPool isEqualToString:@"CUSTOMER"]) {
                     if ([order.customerUsername isEqualToString:username]) {
                         if ([order.Completed isEqualToString:@"YES"]) {
                             [pastOrdersArray addObject:order];
                         } else {
                             [currentOrdersArray addObject:order];
                         }
                     }
                 } else {
                     if ([order.driverUsername isEqualToString:username]) {
                         if ([order.Completed isEqualToString:@"YES"]) {
                             [pastOrdersArray addObject:order];
                         } else {
                             [currentOrdersArray addObject:order];
                         }
                     }
                 }

                 
             }
         }
         return nil;
     }];
    greyView = [[UIView alloc] initWithFrame:self.view.frame];
    greyView.backgroundColor = [UIColor grayColor];
    greyView.alpha = 0.5;
    [self.view addSubview:greyView];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
    [self.view addSubview:spinner];
    [spinner startAnimating];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getLocations) userInfo:nil repeats:YES];
}


-(void)getLocations {
    [timer invalidate];
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    //    scanExpression.limit = @10;
    
    [[dynamoDBObjectMapper scan:[Locations class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         } else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (int i = 0; i < currentOrdersArray.count; i++) {
                 for (Locations *location in paginatedOutput.items) {
                     if ([location.Name isEqualToString:[(Orders *)[currentOrdersArray objectAtIndex:i] Location]]) {
                         if ([location.Area isEqualToString:[(Orders *)[currentOrdersArray objectAtIndex:i] Area]]) {
                             [locationsArray addObject:location];
                             break;
                         }
                     }
                 }
             }
         }
         return nil;
     }];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTable) userInfo:nil repeats:YES];
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        currentLoc = currentLocation;
        [locationManager stopUpdatingLocation];
    }
    
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Current Orders", @"Current Orders");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Past Orders", @"Past Orders");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


-(void)getTable {
    [timer invalidate];
    NSMutableArray *sortedOrdersArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < currentOrdersArray.count; i++) {
        CLLocationCoordinate2D locationCoordinate = [self geoCodeUsingAddress:[(Locations *)[locationsArray objectAtIndex:i] Address]];
        CLLocation *restaurantLoc = [[CLLocation alloc] initWithLatitude:locationCoordinate.latitude longitude:locationCoordinate.longitude];
        float milesToStore = ([restaurantLoc distanceFromLocation:currentLoc]/1000)/1.60934;
        [distanceAwayArray addObject:[NSNumber numberWithFloat:milesToStore]];
    }
    NSMutableArray *unsortedDistanceArray = [[NSMutableArray alloc] initWithArray:distanceAwayArray];
    NSMutableArray *sortedDistanceArray = [self sortDistance:unsortedDistanceArray];
    
    for (int i = 0; i < sortedDistanceArray.count; i++) {
        for (int j = 0; j < distanceAwayArray.count; j++) {
            if ([distanceAwayArray objectAtIndex:j] == [sortedDistanceArray objectAtIndex:i]) {
                [sortedOrdersArray addObject:[currentOrdersArray objectAtIndex:j]];
                break;
            }
        }
    }
    currentOrdersArray = sortedOrdersArray;
    distanceAwayArray = sortedDistanceArray;
    [self.tableView reloadData];
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    [greyView removeFromSuperview];
}

-(NSMutableArray *)sortDistance:(NSMutableArray *)unsortedDistance {
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [unsortedDistance sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    return unsortedDistance;
}

//-(void)getTable {
//    [self.tableView reloadData];
//    [timer invalidate];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return currentOrdersArray.count;
    } else if (section == 1) {
        return pastOrdersArray.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userPool = [defaults stringForKey:@"userPool"];
    if (indexPath.section == 0) {
        if ([userPool isEqualToString:@"CUSTOMER"]) {
            cell.textLabel.text = [NSString stringWithFormat:@"Order #: %@", [(Orders *)[currentOrdersArray objectAtIndex:indexPath.row] OrderId]];
            cell.detailTextLabel.text = [(Orders *)[currentOrdersArray objectAtIndex:indexPath.row] Location];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"Order #: %@", [(Orders *)[currentOrdersArray objectAtIndex:indexPath.row] OrderId]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ miles away", [(Orders *)[currentOrdersArray objectAtIndex:indexPath.row] Location], [[[distanceAwayArray objectAtIndex:indexPath.row] stringValue] substringToIndex:3]];
        }
    } else if (indexPath.section == 1) {
        if ([userPool isEqualToString:@"CUSTOMER"]) {
            cell.textLabel.text = [NSString stringWithFormat:@"Order #: %@", [(Orders *)[pastOrdersArray objectAtIndex:indexPath.row] OrderId]];
            cell.detailTextLabel.text = [(Orders *)[pastOrdersArray objectAtIndex:indexPath.row] Location];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"Order #: %@", [(Orders *)[pastOrdersArray objectAtIndex:indexPath.row] OrderId]];
            cell.detailTextLabel.text = [(Orders *)[pastOrdersArray objectAtIndex:indexPath.row] Location];
        }
    }

    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    // OPEN ORDER DETAILS VIEW CONTROLLER
    if (indexPath.section == 0) {
        orderNumSelected = [(Orders *)[currentOrdersArray objectAtIndex:indexPath.row] OrderId];
    } else {
        orderNumSelected = [(Orders *)[pastOrdersArray objectAtIndex:indexPath.row] OrderId];
    }
    [self performSegueWithIdentifier:@"detailsOrderSegue" sender:nil];
    //    OrderDetailsTableViewController *secondViewController = [[OrderDetailsTableViewController alloc] init];
    //    secondViewController.orderId = [(Orders *)[ordersArray objectAtIndex:indexPath.row] OrderId]; // Set the exposed property
    //    [self.navigationController pushViewController:secondViewController animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"detailsOrderSegue"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        OrderDetailsTableViewController *controller = (OrderDetailsTableViewController *)navController.topViewController;
        controller.orderId = orderNumSelected;
    }
}


@end

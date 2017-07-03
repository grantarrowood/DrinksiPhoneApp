//
//  OrderDetailsTableViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/18/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "OrderDetailsTableViewController.h"
#import <AWSSNS/AWSSNS.h>


@interface OrderDetailsTableViewController ()

@end

@implementation OrderDetailsTableViewController



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSLog(@"View Will Appear!");
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    orderItems = [[NSMutableArray alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
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
    //    scanExpression.limit = @10;
    
    [[dynamoDBObjectMapper scan:[Orders class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         } else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (Orders *order in paginatedOutput.items) {
                 if (order.OrderId == _orderId) {
                     transactionId = order.transactionId;
                     driverUsername = order.driverUsername;
                     customerUsername = order.customerUsername;
                     locationName = order.Location;
                     AWSDynamoDBObjectMapper *dynamoDBObjectMapperLocation = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
                     
                     AWSDynamoDBScanExpression *scanExpressionLocation = [AWSDynamoDBScanExpression new];
                     
                     [[dynamoDBObjectMapperLocation scan:[Locations class]
                                              expression:scanExpressionLocation]
                      continueWithBlock:^id(AWSTask *task) {
                          if (task.error) {
                              NSLog(@"The request failed. Error: [%@]", task.error);
                          } else {
                              AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                              for (Locations *location in paginatedOutput.items) {
                                  if ([location.Name isEqualToString: locationName]) {
                                      locationAddress = location.Address;
//                                      if ([driverUsername isEqualToString:@"UNKNOWN"]) {
//                                          sleep(1);
//                                          //[self getDeliveryFee];
//                                      }
                                  }
                              }
                          }
                          return nil;
                      }];
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     NSString *userPool = [defaults stringForKey:@"userPool"];
                     if ([userPool isEqualToString:@"CUSTOMER"]) {
                         if([driverUsername isEqualToString:@"UNKNOWN"]) {
                             
                         } else {
                             AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
                             AWSCognitoIdentityUserPoolConfiguration *userPoolConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7abpokft5to0bnmbpordu8ou7r"  clientSecret:@"lo4l2ui4oggikjfqo6afgo5mv4u1839jvsikrot5uh1rksf1ad2" poolId:@"us-east-1_KpiGHtI7M"];
                             [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:userPoolConfiguration forKey:@"DrinksDriverPool"];
                             AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksDriverPool"];
                             pool.delegate = self;
                             AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6" identityProviderManager:pool];
                             [AWSCognitoIdentityProvider registerCognitoIdentityProviderWithConfiguration:[[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider] forKey:@"DrinksDriverPool"];
                             AWSCognitoIdentityProvider *provider = [AWSCognitoIdentityProvider CognitoIdentityProviderForKey:@"DrinksDriverPool"];
                             AWSCognitoIdentityProviderAdminGetUserRequest *user = [AWSCognitoIdentityProviderAdminGetUserRequest new];
                             user.username = driverUsername;
                             user.userPoolId = @"us-east-1_KpiGHtI7M";
                             [[[provider adminGetUser:user] continueWithBlock:^id(AWSTask *task) {
                                 if(task.error){
                                     [[[UIAlertView alloc] initWithTitle:task.error.userInfo[@"__type"]
                                                                 message:task.error.userInfo[@"message"]
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:@"Retry", nil] show];
                                 }else{
                                     AWSCognitoIdentityUserGetDetailsResponse *response = task.result;
                                     //do something with response.userAttributes
                                     for (AWSCognitoIdentityUserAttributeType *attribute in response.userAttributes) {
                                         //print the user attributes
                                         NSLog(@"Attribute: %@ Value: %@", attribute.name, attribute.value);
                                         if([attribute.name isEqualToString:@"name"]) {
                                             driverName = attribute.value;
                                         } else if([attribute.name isEqualToString:@"custom:stripeUserId"]) {
                                             driverStripeId = attribute.value;
                                         }
                                     }
                                 }
                                 return nil;
                             }] waitUntilFinished];
                         }
                         
                     } else {
                         AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
                         AWSCognitoIdentityUserPoolConfiguration *userPoolConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
                         [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:userPoolConfiguration forKey:@"DrinksCustomerPool"];
                         AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
                         pool.delegate = self;
                         AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6" identityProviderManager:pool];
                         [AWSCognitoIdentityProvider registerCognitoIdentityProviderWithConfiguration:[[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider] forKey:@"DrinksCustomerPool"];
                         AWSCognitoIdentityProvider *provider = [AWSCognitoIdentityProvider CognitoIdentityProviderForKey:@"DrinksCustomerPool"];
                         AWSCognitoIdentityProviderAdminGetUserRequest *user = [AWSCognitoIdentityProviderAdminGetUserRequest new];
                         user.username = customerUsername;
                         user.userPoolId = @"us-east-1_rwnjPpBrw";
                        [[[provider adminGetUser:user] continueWithBlock:^id(AWSTask *task) {
                             if(task.error){
                                 [[[UIAlertView alloc] initWithTitle:task.error.userInfo[@"__type"]
                                                             message:task.error.userInfo[@"message"]
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"Retry", nil] show];
                             }else{
                                 AWSCognitoIdentityUserGetDetailsResponse *response = task.result;
                                 //do something with response.userAttributes
                                 for (AWSCognitoIdentityUserAttributeType *attribute in response.userAttributes) {
                                     //print the user attributes
                                     NSLog(@"Attribute: %@ Value: %@", attribute.name, attribute.value);
                                     if([attribute.name isEqualToString:@"name"]) {
                                         customerName = attribute.value;
                                     } else if([attribute.name isEqualToString:@"address"]) {
                                         customerAddress = attribute.value;
                                     }
                                 }
                             }
                             return nil;
                         }] waitUntilFinished];
                     }
                     
                     isPaid = order.paid;
                     if ([isPaid isEqualToString: @"YES"]) {
                         AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                                         identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
                         
                         AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
                         
                         AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
                         
                         AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                         
                         NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_CUSTOMERDRIVERSLICENSE_%@.jpg", customerUsername,transactionId]];
                         NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                         
                         AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                         
                         downloadRequest.bucket = @"drinkscustomerdriverslicense";
                         downloadRequest.key = [NSString stringWithFormat:@"%@_CUSTOMERDRIVERSLICENSE_%@.jpg", customerUsername,transactionId];
                         downloadRequest.downloadingFileURL = downloadingFileURL;
                         [[[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                                                withBlock:^id(AWSTask *task) {
                                                                                    if (task.error){
                                                                                        if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                                            switch (task.error.code) {
                                                                                                case AWSS3TransferManagerErrorCancelled:
                                                                                                case AWSS3TransferManagerErrorPaused:
                                                                                                    break;
                                                                                                    
                                                                                                default:
                                                                                                    NSLog(@"Error: %@", task.error);
                                                                                                    break;
                                                                                            }
                                                                                            
                                                                                        } else {
                                                                                            NSLog(@"Error: %@", task.error);
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    if (task.result) {
                                                                                        AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
                                                                                        customerDriversLicense = [UIImage imageWithContentsOfFile:downloadingFilePath];
                                                                                    }
                                                                                    return nil;
                                                                                }] waitUntilFinished];

                     }
                     if ([driverUsername isEqualToString:@"UNKNOWN"]) {
                         orderStatus = @"Awaiting Driver";
                     } else {
                         if ([isPaid isEqualToString:@"NO"]) {
                             orderStatus = @"Awaiting Payment";
                         } else {
                             if ([order.AcceptedDelivery isEqualToString:@"NO"]) {
                                 orderStatus = @"On the Way";
                             } else {
                                 orderStatus = @"Order Completed";
                             }
                         }
                     }
                     NSString *stringWithoutSpaces = [order.Order
                                                      stringByReplacingOccurrencesOfString:@" " withString:@""];
                     NSString *stringEndBracket = [stringWithoutSpaces
                                                      stringByReplacingOccurrencesOfString:@"}" withString:@""];
                     NSString *stringStartBracket = [stringEndBracket
                                                      stringByReplacingOccurrencesOfString:@"{" withString:@""];
                     NSArray *strings = [stringStartBracket componentsSeparatedByString:@","];
                     for (int i = 0; i<strings.count; i+=2) {
                         NSMutableArray *item = [[NSMutableArray alloc] initWithObjects:strings[i], strings[i+1], nil];
                         [orderItems addObject:item];
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
    timer = [NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(getTable) userInfo:nil repeats:YES];
}

-(void)getTable {
    [self.tableView reloadData];
    [timer invalidate];
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    [greyView removeFromSuperview];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userPool = [defaults stringForKey:@"userPool"];
    if ([userPool isEqualToString:@"CUSTOMER"]) {
        if ([driverUsername isEqualToString:@"UNKNOWN"]) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 623, 375, 44)];
            footerView.backgroundColor = [UIColor whiteColor];
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 1)];
            separatorView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
            [footerView addSubview:separatorView];
            UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 44)];
            [acceptButton setTitle:@"Cancel Order" forState:UIControlStateNormal];
            [acceptButton setTitleColor:[UIColor colorWithRed:201.0/255.0 green:77.0/255.0 blue:32.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [acceptButton addTarget:self action:@selector(cancelOrder) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:acceptButton];
            [self.navigationController.view addSubview:footerView];
        } else {
//            if([isPaid isEqualToString:@"NO"]) {
//                UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 623, 375, 44)];
//                footerView.backgroundColor = [UIColor whiteColor];
//                UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 1)];
//                separatorView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
//                [footerView addSubview:separatorView];
//                UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 44)];
//                [acceptButton setTitle:@"Pay Now" forState:UIControlStateNormal];
//                [acceptButton setTitleColor:[UIColor colorWithRed:201.0/255.0 green:77.0/255.0 blue:32.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//                [acceptButton addTarget:self action:@selector(payNow) forControlEvents:UIControlEventTouchUpInside];
//                [footerView addSubview:acceptButton];
//                [self.navigationController.view addSubview:footerView];
//            } else {
                UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 623, 375, 44)];
                footerView.backgroundColor = [UIColor whiteColor];
                UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 1)];
                separatorView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
                [footerView addSubview:separatorView];
                UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 44)];
                [acceptButton setTitle:@"Problem?" forState:UIControlStateNormal];
                [acceptButton setTitleColor:[UIColor colorWithRed:201.0/255.0 green:77.0/255.0 blue:32.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                //[acceptButton addTarget:self action:@selector(payNow) forControlEvents:UIControlEventTouchUpInside];
                [footerView addSubview:acceptButton];
                [self.navigationController.view addSubview:footerView];
//            }
        }
        
    } else {
        if ([driverUsername isEqualToString:@"UNKNOWN"]) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 623, 375, 44)];
            footerView.backgroundColor = [UIColor whiteColor];
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 1)];
            separatorView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
            [footerView addSubview:separatorView];
            UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 44)];
            [acceptButton setTitle:@"Accept Order" forState:UIControlStateNormal];
            [acceptButton setTitleColor:[UIColor colorWithRed:201.0/255.0 green:77.0/255.0 blue:32.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [acceptButton addTarget:self action:@selector(acceptAction) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:acceptButton];
            [self.navigationController.view addSubview:footerView];
        } else {
            if([isPaid isEqualToString:@"YES"]) {
                UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 579, 375, 44)];
                footerView.backgroundColor = [UIColor whiteColor];
                UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 1)];
                separatorView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
                [footerView addSubview:separatorView];
                UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 44)];
                [acceptButton setTitle:@"Deliver" forState:UIControlStateNormal];
                [acceptButton setTitleColor:[UIColor colorWithRed:201.0/255.0 green:77.0/255.0 blue:32.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                [acceptButton addTarget:self action:@selector(deliverOrder) forControlEvents:UIControlEventTouchUpInside];
                [footerView addSubview:acceptButton];
                [self.navigationController.view addSubview:footerView];
            }
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 623, 375, 44)];
            footerView.backgroundColor = [UIColor whiteColor];
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 1)];
            separatorView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
            [footerView addSubview:separatorView];
            UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 44)];
            [acceptButton setTitle:@"Problem?" forState:UIControlStateNormal];
            [acceptButton setTitleColor:[UIColor colorWithRed:201.0/255.0 green:77.0/255.0 blue:32.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            //[acceptButton addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:acceptButton];
            [self.navigationController.view addSubview:footerView];
        }
    }
}

-(void)getDeliveryFee {
    [timerTwo invalidate];
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    
//    [locationManager startUpdatingLocation];
//    sleep(0.5);
//    CLLocationCoordinate2D locationCoordinate = [self geoCodeUsingAddress:locationAddress];
//    restaurantLoc = [[CLLocation alloc] initWithLatitude:locationCoordinate.latitude longitude:locationCoordinate.longitude];
//    
//    CLLocationCoordinate2D customerCoordinate = [self geoCodeUsingAddress:customerAddress];
//    CLLocation *customerLoc = [[CLLocation alloc] initWithLatitude:customerCoordinate.latitude longitude:customerCoordinate.longitude];
//    float milesToHouse = ([restaurantLoc distanceFromLocation:customerLoc]/1000)/1.60934;
//    float milesToStore = ([restaurantLoc distanceFromLocation:currentLoc]/1000)/1.60934;
//    float totalMiles = milesToHouse+milesToStore;
//    
//    // 18 mi / g --- $2.50 / g
//    float gasCosts = (totalMiles/18.0) * 2.5;
//    // 1 mi = 5 min + 8 min in store ---- $10/ 60 min
//    float timeCosts = (((totalMiles*5.0)+8.0)/60)*10;
//    float totalCosts = gasCosts+timeCosts;
    deliveryFee = 6.0+6.0;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userPool = [defaults stringForKey:@"userPool"];
        if ([userPool isEqualToString:@"CUSTOMER"]) {
            return 5;
        } else {
            if ([isPaid isEqualToString:@"YES"]) {
                return 7;
            } else {
                return 6;
            }
        }
        return 0;
    } else if(section == 1) {
        if (orderItems.count > 0) {
            return orderItems.count+2;
        }
        return 1;
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Order Info", @"Order Info");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Order Details", @"Order Details");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            cell.detailMainLabel.text = @"Order Number:";
            cell.detailDynamicLabel.text = [NSString stringWithFormat:@"%@", self.orderId];
            [cell.detailMainLabel sizeToFit];
            //[cell.detailDynamicLabel sizeToFit];
            cell.detailDynamicLabel.minimumFontSize = 10;
            cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            return cell;
        } else if (indexPath.row == 1) {
            DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *userPool = [defaults stringForKey:@"userPool"];
            if ([userPool isEqualToString:@"CUSTOMER"]) {
                if([driverUsername isEqualToString:@"UNKNOWN"]) {
                    cell.detailMainLabel.text = @"Driver Name:";
                    cell.detailDynamicLabel.text = @"No Driver";
                    [cell.detailMainLabel sizeToFit];
                    //[cell.detailDynamicLabel sizeToFit];
                    cell.detailDynamicLabel.minimumFontSize = 10;
                    cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
                } else {
                    cell.detailMainLabel.text = @"Driver Name:";
                    cell.detailDynamicLabel.text = driverName;
                    [cell.detailMainLabel sizeToFit];
                    //[cell.detailDynamicLabel sizeToFit];
                    cell.detailDynamicLabel.minimumFontSize = 10;
                    cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
                }
            } else {
                cell.detailMainLabel.text = @"Customer Name:";
                cell.detailDynamicLabel.text = customerName;
                [cell.detailMainLabel sizeToFit];
                //[cell.detailDynamicLabel sizeToFit];
                cell.detailDynamicLabel.minimumFontSize = 10;
                cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            }
            return cell;
        } else if (indexPath.row == 2) {
            DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *userPool = [defaults stringForKey:@"userPool"];
            if ([userPool isEqualToString:@"CUSTOMER"]) {
                cell.detailMainLabel.text = @"Location Name:";
                cell.detailDynamicLabel.text = locationName;
                [cell.detailMainLabel sizeToFit];
                //[cell.detailDynamicLabel sizeToFit];
                cell.detailDynamicLabel.minimumFontSize = 10;
                cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            } else {
                cell.detailMainLabel.text = @"Customer Address:";
                cell.detailDynamicLabel.text = customerAddress;
                [cell.detailMainLabel sizeToFit];
                //[cell.detailDynamicLabel sizeToFit];
                cell.detailDynamicLabel.minimumFontSize = 10;
                cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            }
            return cell;
        } else if (indexPath.row == 3) {
            DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *userPool = [defaults stringForKey:@"userPool"];
            if ([userPool isEqualToString:@"CUSTOMER"]) {
                cell.detailMainLabel.text = @"Location Address:";
                cell.detailDynamicLabel.text = locationAddress;
                [cell.detailMainLabel sizeToFit];
                //[cell.detailDynamicLabel sizeToFit];
                cell.detailDynamicLabel.minimumFontSize = 10;
                cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            } else {
                cell.detailMainLabel.text = @"Location Name:";
                cell.detailDynamicLabel.text = locationName;
                [cell.detailMainLabel sizeToFit];
                //[cell.detailDynamicLabel sizeToFit];
                cell.detailDynamicLabel.minimumFontSize = 10;
                cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            }
            return cell;
        } else if (indexPath.row == 4) {
            DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *userPool = [defaults stringForKey:@"userPool"];
            if ([userPool isEqualToString:@"CUSTOMER"]) {
                cell.detailMainLabel.text = @"Order Status:";
                cell.detailDynamicLabel.text = orderStatus;
                [cell.detailMainLabel sizeToFit];
                //[cell.detailDynamicLabel sizeToFit];
                cell.detailDynamicLabel.minimumFontSize = 10;
                cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            } else {
                cell.detailMainLabel.text = @"Location Address:";
                cell.detailDynamicLabel.text = locationAddress;
                [cell.detailMainLabel sizeToFit];
                //[cell.detailDynamicLabel sizeToFit];
                cell.detailDynamicLabel.minimumFontSize = 10;
                cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            }
            
            return cell;
        } else if (indexPath.row == 5) {
            DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            cell.detailMainLabel.text = @"Order Status:";
            cell.detailDynamicLabel.text = orderStatus;
            [cell.detailMainLabel sizeToFit];
            //[cell.detailDynamicLabel sizeToFit];
            cell.detailDynamicLabel.minimumFontSize = 10;
            cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            return cell;
        } else if (indexPath.row == 6) {
            CustomerLicenseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customerLicense" forIndexPath:indexPath];
            cell.licenseImageView.image = customerDriversLicense;
            return cell;
        }
    } else {
        if ([driverUsername isEqualToString:@"UNKNOWN"]) {
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"static6" forIndexPath:indexPath];
                return cell;
            } /*else if (indexPath.row == orderItems.count+1) {
                ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"items" forIndexPath:indexPath];
                cell.itemNameLabel.text = @"Delivery Fee";
                cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.2f", deliveryFee];
                //[cell.itemPriceLabel sizeToFit];
                [cell.itemNameLabel sizeToFit];
                return cell;
            }*/ else if (indexPath.row == orderItems.count+1) {
                ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"items" forIndexPath:indexPath];
                cell.itemNameLabel.text = @"Total:";
                float total = 0;
                for (int i = 0; i<orderItems.count; i++) {
                    total += [[orderItems objectAtIndex:i][1] floatValue];
                }
                //total += deliveryFee;
                cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.2f", total];
                //[cell.itemPriceLabel sizeToFit];
                [cell.itemNameLabel sizeToFit];
                return cell;
            } else {
                ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"items" forIndexPath:indexPath];
                cell.itemNameLabel.text = [orderItems objectAtIndex:(indexPath.row-1)][0];
                cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%@",[orderItems objectAtIndex:(indexPath.row-1)][1]];
                //[cell.itemPriceLabel sizeToFit];
                [cell.itemNameLabel sizeToFit];
                return cell;
            }
        } else {
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"static6" forIndexPath:indexPath];
                return cell;
            } else if (indexPath.row == orderItems.count+1) {
                ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"items" forIndexPath:indexPath];
                cell.itemNameLabel.text = @"Total:";
                float total = 0;
                for (int i = 0; i<orderItems.count; i++) {
                    total += [[orderItems objectAtIndex:i][1] floatValue];
                }
                //total += deliveryFee;
                cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.2f", total];
                //[cell.itemPriceLabel sizeToFit];
                [cell.itemNameLabel sizeToFit];
                return cell;
            } else {
                ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"items" forIndexPath:indexPath];
                cell.itemNameLabel.text = [orderItems objectAtIndex:(indexPath.row-1)][0];
                cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%@",[orderItems objectAtIndex:(indexPath.row-1)][1]];
                //[cell.itemPriceLabel sizeToFit];
                [cell.itemNameLabel sizeToFit];
                return cell;
            }
        }
    }
    return nil;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 6) {
        return 290;
    }
    return 44;
}



-(void)acceptAction {
    Orders *newOrder = [Orders new];

    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    //    scanExpression.limit = @10;
    
    [[[dynamoDBObjectMapper scan:[Orders class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         } else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (Orders *order in paginatedOutput.items) {
                 if (order.OrderId == _orderId) {
                     if (![order.driverUsername isEqualToString:@"UNKNOWN"]) {
                         [[[UIAlertView alloc] initWithTitle:@"ERROR"
                                                     message:@"Order already being fulfilled."
                                                    delegate:self
                                           cancelButtonTitle:@"Ok"
                                           otherButtonTitles:nil] show];
                     } else {
                         newOrder.DeliveryAddress = order.DeliveryAddress;
                         newOrder.CustomerEndpointArn = order.CustomerEndpointArn;
                         customerEndpointArn = order.CustomerEndpointArn;
                         newOrder.Area = order.Area;
                         newOrder.Location = order.Location;
//                         newOrder.Order = [NSString stringWithFormat:@"%@, {DeliveryFee, %.2f}", order.Order, deliveryFee];
                         newOrder.Order = order.Order;
                         newOrder.customerUsername = order.customerUsername;
                         newOrder.OrderId = _orderId;
                         newOrder.AcceptedDelivery = @"NO";
                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                         NSString *username = [defaults stringForKey:@"currentUsername"];
                         newOrder.driverUsername = username;
                         newOrder.paid = order.paid;
                         newOrder.transactionId = order.transactionId;
                         [[dynamoDBObjectMapper save:newOrder]
                          continueWithBlock:^id(AWSTask *task) {
                              if (task.error) {
                                  NSLog(@"The request failed. Error: [%@]", task.error);
                              } else {
                                  //Do something with task.result or perform other operations.
                              }
                              return nil;
                          }];
                     }
                 }
             }
         }
         return nil;
     }] waitUntilFinished];
    
    [[[dynamoDBObjectMapper scan:[Transactions class]
                      expression:scanExpression]
      continueWithBlock:^id(AWSTask *task) {
          if (task.error) {
              NSLog(@"The request failed. Error: [%@]", task.error);
          } else {
              AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
              for (Transactions *transaction in paginatedOutput.items) {
                  if(transactionId == transaction.TransactionId) {
                      stripeTransactionId = transaction.transactionResult;
                  }
              }
          }
          return nil;
      }] waitUntilFinished];
    float total = 0;
    for (int i = 0; i<orderItems.count; i++) {
        total += [[orderItems objectAtIndex:i][1] floatValue];
    }
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
    
    AWSCognitoIdentityUserPoolConfiguration *driverConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7abpokft5to0bnmbpordu8ou7r"  clientSecret:@"lo4l2ui4oggikjfqo6afgo5mv4u1839jvsikrot5uh1rksf1ad2" poolId:@"us-east-1_KpiGHtI7M"];
    
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:driverConfiguration forKey:@"DrinksDriverPool"];
    
    AWSCognitoIdentityUserPool *driverPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksDriverPool"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"currentUsername"];
    [[[[driverPool getUser:username] getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(task.error){
                [[[UIAlertView alloc] initWithTitle:task.error.userInfo[@"__type"]
                                            message:task.error.userInfo[@"message"]
                                           delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Retry", nil] show];
            }else{
                AWSCognitoIdentityUserGetDetailsResponse *response = task.result;
                //do something with response.userAttributes
                for (AWSCognitoIdentityUserAttributeType *attribute in response.userAttributes) {
                    //print the user attributes
                    //NSLog(@"Attribute: %@ Value: %@", attribute.name, attribute.value);
                    if ([attribute.name isEqualToString:@"custom:stripeUserId"]) {
                        driverStripeId = attribute.value;
                        AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
                        NSNumber *totalCents = [NSNumber numberWithInteger:(total * 100)];
                        
                        [[lambdaInvoker invokeFunction:@"drinksCapturePayment"
                                            JSONObject:@{@"stripeTransactionId" : stripeTransactionId,
                                                         @"amount" : totalCents,
                                                         @"driverId" : driverStripeId,
                                                         @"transferGroup" : [_orderId stringValue]
                                                         }] continueWithBlock:^id(AWSTask *task) {
                            if (task.error) {
                                NSLog(@"Error: %@", task.error);
                                if ([task.error.domain isEqualToString:AWSLambdaInvokerErrorDomain]
                                    && task.error.code == AWSLambdaInvokerErrorTypeFunctionError) {
                                    NSLog(@"Function error: %@", task.error.userInfo[AWSLambdaInvokerFunctionErrorKey]);
                                }
                            }
                            if (task.result) {
                                NSDictionary *JSONObject = task.result;
                                NSLog(@"result: %@", JSONObject[@"paid"]);
                                if ([JSONObject[@"paid"] isEqual: @1]) {
                                    NSLog(@"SUCCESS");
                                } else {
                                    NSLog(@"FAILURE");
                                }
                            }
                            // Handle response
                            return nil;
                        }];

                    }
                }
            }
        });
        return nil;
    }] waitUntilFinished];
    
    AWSSNS *sns = [AWSSNS defaultSNS];
    AWSSNSPublishInput *input = [AWSSNSPublishInput new];
    input.message = [NSString stringWithFormat:@"Order #%@ was accepted by a driver. It is being fulfilled now.", _orderId];
    input.targetArn = customerEndpointArn;
    [sns publish:input completionHandler:^(AWSSNSPublishResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Success: %@", response);
        }
    }];
    greyView = [[UIView alloc] initWithFrame:self.view.frame];
    greyView.backgroundColor = [UIColor grayColor];
    greyView.alpha = 0.5;
    [self.view addSubview:greyView];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
    [self.view addSubview:spinner];
    [spinner startAnimating];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(avalibleScreen) userInfo:nil repeats:YES];
}

-(void)avalibleScreen {
    [timer invalidate];
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    [greyView removeFromSuperview];
    [self performSegueWithIdentifier:@"backToYourOrdersSegue" sender:nil];
}

-(id<AWSCognitoIdentityPasswordAuthentication>) startPasswordAuthentication{
    //implement code to instantiate and display login UI here
    //return something that implements the AWSCognitoIdentityPasswordAuthentication protocol
    return self;
}

-(void) didCompletePasswordAuthenticationStepWithError:(NSError*) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        //present error to end user
        if(error){
            [[[UIAlertView alloc] initWithTitle:error.userInfo[@"__type"]
                                        message:error.userInfo[@"message"]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Ok", nil] show];
        }
    });
}

-(void) getPasswordAuthenticationDetails: (AWSCognitoIdentityPasswordAuthenticationInput *) authenticationInput  passwordAuthenticationCompletionSource: (AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails *> *) passwordAuthenticationCompletionSource {
    //self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource;
    
}


//-(void)payNow {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    PaySequencePopoverViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paySequenceViewController"];
//    controller.orderDetails = orderItems;
//    controller.orderId = _orderId;
//    controller.driverStripeId = driverStripeId;
//    controller.payDelegate = self;
//    // present the controller
//    // on iPad, this will be a Popover
//    // on iPhone, this will be an action sheet
//    controller.modalPresentationStyle = UIModalPresentationPopover;
//    [self presentViewController:controller animated:YES completion:nil];
//    
//    // configure the Popover presentation controller
//    UIPopoverPresentationController *popController = [controller popoverPresentationController];
//    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
//    popController.delegate = self;
//    popController.sourceView = self.view;
//    popController.sourceRect = CGRectMake(10, 50, 355, 567);
//    //[self performSegueWithIdentifier:@"paySequence" sender:nil];
//}

-(void)cancelOrder {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    Orders *orderToCancel = [Orders new];
    orderToCancel.OrderId = _orderId;
    
    [[dynamoDBObjectMapper remove:orderToCancel]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         } else {
             //Item deleted.
             [self performSegueWithIdentifier:@"backToYourOrdersSegue" sender:nil];
         }
         return nil;
     }];
}


-(void)deliverOrder {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DriverAcceptOrderViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"driverAcceptViewController"];
    controller.orderDetails = orderItems;
    controller.transactionId = transactionId;
    controller.orderId = _orderId;
    controller.acceptDelegate = self;
    // present the controller
    // on iPad, this will be a Popover
    // on iPhone, this will be an action sheet
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    // configure the Popover presentation controller
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.delegate = self;
    popController.sourceView = self.view;
    popController.sourceRect = CGRectMake(10, 50, 355, 567);

//    CLLocationCoordinate2D locationCoordinate = [self geoCodeUsingAddress:locationAddress];
//    restaurantLoc = [[CLLocation alloc] initWithLatitude:locationCoordinate.latitude longitude:locationCoordinate.longitude];
//    
//    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",currentLoc.coordinate.latitude, currentLoc.coordinate.longitude, restaurantLoc.coordinate.latitude, restaurantLoc.coordinate.longitude];
//    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: directionsURL]];
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}
*/

- (IBAction)backAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userPool = [defaults stringForKey:@"userPool"];
    if ([userPool isEqualToString:@"CUSTOMER"]) {
        [self performSegueWithIdentifier:@"backToYourOrdersSegue" sender:nil];
    } else {
        if ([driverUsername isEqualToString:@"UNKNOWN"]) {
            [self performSegueWithIdentifier:@"backToAvalibleSegue" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"backToYourOrdersSegue" sender:nil];
        }
    }
}

- (void)payViewControllerDismissed:(NSString *)paid
{
    greyView = [[UIView alloc] initWithFrame:self.view.frame];
    greyView.backgroundColor = [UIColor grayColor];
    greyView.alpha = 0.5;
    [self.view addSubview:greyView];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
    [self.view addSubview:spinner];
    [spinner startAnimating];
    if([paid isEqualToString:@"YES"]) {
        isPaid = @"YES";
        orderStatus = @"On the Way";
        [self getTable];
    }
}

- (void)acceptViewControllerDismissed:(NSString *)accepted
{
    if([accepted isEqualToString:@"YES"]) {
        [self performSegueWithIdentifier:@"acceptedOrder" sender:nil];
    }
}
@end

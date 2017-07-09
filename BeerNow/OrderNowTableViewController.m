//
//  OrderNowTableViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 5/27/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "OrderNowTableViewController.h"

@interface OrderNowTableViewController ()
{
    NSTimer *timer;
    UIActivityIndicatorView *spinner;
    UIView *greyView;
    UIView *modalView;
    UITextField *streetAddressTextField;
    UITextField *cityTextField;
    UITextField *stateTextField;
    CGPoint svos;
}

@end

@implementation OrderNowTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inAppNotification:)
                                                 name:@"InAppNotification"
                                               object:nil];
    _notification = [[AFDropdownNotification alloc] init];
    _notification.notificationDelegate = self;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    orderItems = [[NSMutableArray alloc] init];
    allLocations = [[NSMutableArray alloc] init];
    allAreas = [[NSMutableArray alloc] init];
    allMenuItems = [[NSMutableArray alloc] init];
    selectedMenuItems = [[NSMutableArray alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager authorizationStatus] == 0) {
        [locationManager requestWhenInUseAuthorization];
    }
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
//    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnTextField)];
//    [self.tableView addGestureRecognizer:recognizer];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    if (_selectedAddress != nil) {
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        
        AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
        //scanExpression.limit = @10;
        
        [[dynamoDBObjectMapper scan:[Locations class]
                         expression:scanExpression]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
             } else {
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (Locations *location in paginatedOutput.items) {
                     //Do something with book.
                     if([location.Address isEqualToString:_selectedAddress]) {
//                         [allLocations addObject:location];
//                         [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:allLocations.count+1 inSection:2]].accessoryType = UITableViewCellAccessoryCheckmark;
                         selectedArea = location.Area;
                         selectedLocationObject = location;
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
    } else {
        greyView = [[UIView alloc] initWithFrame:self.view.frame];
        greyView.backgroundColor = [UIColor grayColor];
        greyView.alpha = 0.5;
        [self.view addSubview:greyView];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
        [self.view addSubview:spinner];
        [spinner startAnimating];
    }
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];

    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    //scanExpression.limit = @10;
    
    [[dynamoDBObjectMapper scan:[Areas class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         } else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             for (Areas *area in paginatedOutput.items) {
                 //Do something with book.
                 [allAreas addObject:area];
                 if (selectedArea != nil) {
                     if ([selectedArea isEqualToString:area.Name]) {
                         selectedAreaObject = area;
                     }
                 }
             }
         }
         return nil;
     }];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(getTable) userInfo:nil repeats:YES];
    
}

-(void)returnTextField {
    if(([streetAddressTextField isFirstResponder]) || ([cityTextField isFirstResponder]) || ([stateTextField isFirstResponder])) {
        [self.tableView setContentOffset:svos animated:YES];
        [self.view endEditing:YES];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //Keyboard becomes visible
    //    if (textField == self.cityTextField || self.stateTextField || self.birthdateTextField) {
    //        CGPoint point = CGPointMake(0, textField.frame.origin.y) ;
    //        [self.signUpScrollView setContentOffset:point animated:YES];
    //    }
    //    CGRect rect = [textField bounds];
    //    rect = [textField convertRect:rect toView:self.signUpScrollView];
    //    rect.origin.x = 0;
    //    rect.origin.y -= 60;
    //    rect.size.height = 600;
    //    [self.signUpScrollView scrollRectToVisible:rect animated:YES];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnTextField)];
    [self.tableView addGestureRecognizer:recognizer];
    [self.tableView setScrollEnabled:NO];
    svos = self.tableView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:self.tableView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 300;
    [self.tableView setContentOffset:pt animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    //keyboard will hide
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.tableView setContentOffset:svos animated:YES];
    [textField resignFirstResponder];
    return NO;
}


-(void)getTable {
    [self.tableView reloadData];
    [timer invalidate];
    if (_selectedAddress != nil) {
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        
        AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
        
        queryExpression.keyConditionExpression = @"Area = :areaName";
        queryExpression.indexName = @"Area-index";
        queryExpression.expressionAttributeValues = @{@":areaName": selectedArea};
        
        [[dynamoDBObjectMapper query:[Locations class]
                          expression:queryExpression]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
             } else {
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (Locations *locations in paginatedOutput.items) {
                     //Do something with book.
                     [allLocations addObject:locations];
                     
                 }
             }
             _selectedAddress = nil;
             return nil;
         }];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTable) userInfo:nil repeats:YES];
    } else {
        if (selectedArea != nil) {
            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[allLocations indexOfObject:selectedLocationObject] inSection:1]].accessoryType = UITableViewCellAccessoryCheckmark;
            [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[allAreas indexOfObject:selectedAreaObject] inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
            AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
            
            AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
            
            queryExpression.keyConditionExpression = @"MenuLocation = :locationName AND Address = :addressName";
            queryExpression.indexName = @"MenuLocation-Address-index";
            queryExpression.expressionAttributeValues = @{@":locationName": [selectedLocationObject Name], @":addressName": [selectedLocationObject Address]};
            
            [[dynamoDBObjectMapper query:[MenuItems class]
                              expression:queryExpression]
             continueWithBlock:^id(AWSTask *task) {
                 if (task.error) {
                     NSLog(@"The request failed. Error: [%@]", task.error);
                 } else {
                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     for (MenuItems *menuItem in paginatedOutput.items) {
                         //Do something with book.
                         [allMenuItems addObject:menuItem];
                     }
                     selectedArea = nil;
                 }
                 return nil;
             }];
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, 375, 44)];
            footerView.backgroundColor = [UIColor whiteColor];
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 1)];
            separatorView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
            [footerView addSubview:separatorView];
            UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 44)];
            [acceptButton setTitle:@"Submit Order" forState:UIControlStateNormal];
            [acceptButton setTitleColor:[UIColor colorWithRed:201.0/255.0 green:77.0/255.0 blue:32.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [acceptButton addTarget:self action:@selector(submitOrder) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:acceptButton];
            [self.navigationController.view addSubview:footerView];

            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTable) userInfo:nil repeats:YES];

        } else {
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            [greyView removeFromSuperview];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(allAreas.count > 0) {
        if(allLocations.count > 0) {
            if (allMenuItems.count > 0) {
                return 3;
            } else {
                return 2;
            }
        } else {
            return 1;
        }
        
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(allAreas.count > 0) {
        if(allLocations.count > 0) {
            if(section == 0) {
                return allAreas.count;
            } else {
                if (allMenuItems.count > 0) {
                    if (section == 1) {
                        return allLocations.count;
                    } else {
                        return allMenuItems.count;
                    }
                } else {
                    return allLocations.count;
                }
            }
        } else {
            return allAreas.count;
        }
    }
    return 0;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if(allAreas.count > 0) {
        if(allLocations.count > 0) {
            if (indexPath.section == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
                cell.textLabel.text = [(Areas *)[allAreas objectAtIndex:indexPath.row] Name];
            } else {
                if (allMenuItems > 0) {
                    if (indexPath.section == 1) {
                        cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
                        cell.textLabel.text = [(Locations *)[allLocations objectAtIndex:indexPath.row] Name];
                        cell.detailTextLabel.text = [(Locations *)[allLocations objectAtIndex:indexPath.row] Address];
                    } else {
//                        if(indexPath.row == allMenuItems.count) {
//                            cell = [tableView dequeueReusableCellWithIdentifier:@"submit" forIndexPath:indexPath];
//                        } else {
                            cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
                            cell.textLabel.text = [(MenuItems *)[allMenuItems objectAtIndex:indexPath.row] Name];
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.2f", [[(MenuItems *)[allMenuItems objectAtIndex:indexPath.row] Price] floatValue]];
                       // }
                    }
                } else {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
                    cell.textLabel.text = [(Locations *)[allLocations objectAtIndex:indexPath.row] Name];
                }
            }
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.text = [(Areas *)[allAreas objectAtIndex:indexPath.row] Name];
        }
    }
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Step One: Choose your area", @"Step One: Choose your area");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Step Two: Choose your store", @"Step Two: Choose your store");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Step Three: Choose your items", @"Step Three: Choose your items");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([[self.tableView cellForRowAtIndexPath:indexPath].reuseIdentifier  isEqual: @"submit"]) {
        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                        identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
        
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        
        AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
        Orders *newOrder = [Orders new];

        [[dynamoDBObjectMapper scan:[Orders class]
                         expression:scanExpression]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
             } else {
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 NSNumber *highestNumber = @0;
                 for (Orders *order in paginatedOutput.items) {
                     //Do something with book.
                     if (order.OrderId > highestNumber) {
                         highestNumber = order.OrderId;
                     }
                 }
                 int value = [highestNumber intValue];
                 newOrder.OrderId = [NSNumber numberWithInt:value + 1];
             }
             return nil;
         }];
        sleep(2);
        newOrder.Area = [(MenuItems *)[selectedMenuItems objectAtIndex:0] Area];
        newOrder.Location = [(MenuItems *)[selectedMenuItems objectAtIndex:0] MenuLocation];
        for (int i = 0; i < selectedMenuItems.count; i++) {
            if (orderString.length > 0) {
                orderString = [NSString stringWithFormat:@"%@, {%@, %@}", orderString, [(MenuItems *)[selectedMenuItems objectAtIndex:i] Name], [(MenuItems *)[selectedMenuItems objectAtIndex:i] Price]];
            } else {
                orderString = [NSString stringWithFormat:@"{%@, %@}", [(MenuItems *)[selectedMenuItems objectAtIndex:i] Name], [(MenuItems *)[selectedMenuItems objectAtIndex:i] Price]];
            }
            
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:@"currentUsername"];
        NSString *endpointArn = [defaults stringForKey:@"endpointArn"];
        newOrder.CustomerEndpointArn = endpointArn;
        newOrder.Order = orderString;
        newOrder.AcceptedDelivery = @"NO";
        newOrder.DeliveryDate = @"UNKNOWN";
        newOrder.driverUsername = @"UNKNOWN";
        newOrder.customerUsername = username;
        newOrder.paid = @"NO";
        newOrder.transactionId = @0;
        [[dynamoDBObjectMapper save:newOrder]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
             } else {
                 //Do something with task.result or perform other operations.
             }
             return nil;
         }];
        NSLog(@"Submit");
    } else {
        for (NSInteger j = 0; j < [tableView numberOfSections]; ++j)
        { 
            for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
            {
                if ([tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]].accessoryType == UITableViewCellAccessoryCheckmark) {
                    if ((indexPath.section == 0) && (indexPath.section == j)) {
                        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]].accessoryType = UITableViewCellAccessoryNone;
                        [allLocations removeAllObjects];
                        [allMenuItems removeAllObjects];
                        //                    if([tableView numberOfSections] == 3) {
                        //                        for (NSInteger x = 1; j < [tableView numberOfSections]; ++x)
                        //                        {
                        //                            for (NSInteger y = 0; i < [tableView numberOfRowsInSection:x]; ++y)
                        //                            {
                        //                                if ([tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:y inSection:x]].accessoryType == UITableViewCellAccessoryCheckmark) {
                        //                                    if(indexPath.section == 1) {
                        //                                        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:y inSection:x]].accessoryType = UITableViewCellAccessoryNone;
                        //                                    } else if(indexPath.section == 2) {
                        //                                        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:y inSection:x]].accessoryType = UITableViewCellAccessoryNone;
                        //                                        [selectedMenuItems removeAllObjects];
                        //                                    }
                        //                                }
                        //                            }
                        //                        }
                        //                    }
                        return;
                    } else if((indexPath.section == 1) && (indexPath.section == j)) {
                        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]].accessoryType = UITableViewCellAccessoryNone;
                        [allMenuItems removeAllObjects];
                        return;
                    } else if((indexPath.section == 2) && (indexPath.section == j) && ([tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:j]].accessoryType == UITableViewCellAccessoryCheckmark)) {
                        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]].accessoryType = UITableViewCellAccessoryNone;
                        [selectedMenuItems removeObject:[allMenuItems objectAtIndex:indexPath.row]];
                        return;
                    }
                }
            }
        }
        if (allLocations.count > 0) {
            if (allMenuItems.count > 0) {
                [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
                [selectedMenuItems addObject:[allMenuItems objectAtIndex:indexPath.row]];
            } else {
                [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
                
                AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
                
                AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
                
                queryExpression.keyConditionExpression = @"MenuLocation = :locationName AND Address = :addressName";
                queryExpression.indexName = @"MenuLocation-Address-index";
                queryExpression.expressionAttributeValues = @{@":locationName": [(Locations *)[allLocations objectAtIndex:indexPath.row] Name], @":addressName": [(Locations *)[allLocations objectAtIndex:indexPath.row] Address]};
                
                [[dynamoDBObjectMapper query:[MenuItems class]
                                  expression:queryExpression]
                 continueWithBlock:^id(AWSTask *task) {
                     if (task.error) {
                         NSLog(@"The request failed. Error: [%@]", task.error);
                     } else {
                         AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                         for (MenuItems *menuItem in paginatedOutput.items) {
                             //Do something with book.
                             [allMenuItems addObject:menuItem];
                         }
                         
                     }
                     return nil;
                 }];
                UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, 375, 44)];
                footerView.backgroundColor = [UIColor whiteColor];
                UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 1)];
                separatorView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
                [footerView addSubview:separatorView];
                UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 44)];
                [acceptButton setTitle:@"Submit Order" forState:UIControlStateNormal];
                [acceptButton setTitleColor:[UIColor colorWithRed:201.0/255.0 green:77.0/255.0 blue:32.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                [acceptButton addTarget:self action:@selector(submitOrder) forControlEvents:UIControlEventTouchUpInside];
                [footerView addSubview:acceptButton];
                [self.navigationController.view addSubview:footerView];
            }
        } else {
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            
            AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
            
            AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
            
            queryExpression.keyConditionExpression = @"Area = :areaName";
            queryExpression.indexName = @"Area-index";
            queryExpression.expressionAttributeValues = @{@":areaName": [(Areas *)[allAreas objectAtIndex:indexPath.row] Name]};
            
            [[dynamoDBObjectMapper query:[Locations class]
                              expression:queryExpression]
             continueWithBlock:^id(AWSTask *task) {
                 if (task.error) {
                     NSLog(@"The request failed. Error: [%@]", task.error);
                 } else {
                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     for (Locations *locations in paginatedOutput.items) {
                         //Do something with book.
                         
                         [allLocations addObject:locations];
                     }
                 }
                 return nil;
             }];
        }
        greyView = [[UIView alloc] initWithFrame:self.view.frame];
        greyView.backgroundColor = [UIColor grayColor];
        greyView.alpha = 0.5;
        [self.view addSubview:greyView];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
        [self.view addSubview:spinner];
        [spinner startAnimating];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTable) userInfo:nil repeats:YES];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)useEnteredAddress {
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    Orders *newOrder = [Orders new];
    
    [[[dynamoDBObjectMapper scan:[Orders class]
                      expression:scanExpression]
      continueWithBlock:^id(AWSTask *task) {
          if (task.error) {
              NSLog(@"The request failed. Error: [%@]", task.error);
          } else {
              AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
              NSNumber *highestNumber = @0;
              for (Orders *order in paginatedOutput.items) {
                  //Do something with book.
                  if (order.OrderId > highestNumber) {
                      highestNumber = order.OrderId;
                  }
              }
              int value = [highestNumber intValue];
              orderId = [NSNumber numberWithInt:value + 1];
              newOrder.OrderId = [NSNumber numberWithInt:value + 1];
          }
          return nil;
      }] waitUntilFinished];
    newOrder.Area = [(MenuItems *)[selectedMenuItems objectAtIndex:0] Area];
    newOrder.Location = [(MenuItems *)[selectedMenuItems objectAtIndex:0] MenuLocation];
    for (int i = 0; i < selectedMenuItems.count; i++) {
        if (orderString.length > 0) {
            orderString = [NSString stringWithFormat:@"%@, {%@, %.2f}", orderString, [(MenuItems *)[selectedMenuItems objectAtIndex:i] Name], [[(MenuItems *)[selectedMenuItems objectAtIndex:i] Price] floatValue]];
        } else {
            orderString = [NSString stringWithFormat:@"{%@, %@}", [(MenuItems *)[selectedMenuItems objectAtIndex:i] Name], [(MenuItems *)[selectedMenuItems objectAtIndex:i] Price]];
        }
        
    }
    orderString = [NSString stringWithFormat:@"%@, {DeliveryFee, 0.49}", orderString];
    
    newOrder.Order = orderString;
    newOrder.AcceptedDelivery = @"NO";
    newOrder.DeliveryDate = @"UNKNOWN";
    newOrder.DeliveryAddress = [NSString stringWithFormat:@"%@, %@, %@", streetAddressTextField.text, cityTextField.text, stateTextField.text];
    newOrder.driverUsername = @"UNKNOWN";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"currentUsername"];
    NSString *endpointArn = [defaults stringForKey:@"endpointArn"];
    newOrder.CustomerEndpointArn = endpointArn;
    newOrder.customerUsername = username;
    newOrder.paid = @"NO";
    newOrder.transactionId = @0;
    [[[dynamoDBObjectMapper save:newOrder]
      continueWithBlock:^id(AWSTask *task) {
          if (task.error) {
              NSLog(@"The request failed. Error: [%@]", task.error);
          } else {
              //Do something with task.result or perform other operations.
              
          }
          return nil;
      }] waitUntilFinished];
    NSString *stringWithoutSpaces = [orderString
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PaySequencePopoverViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paySequenceViewController"];
    controller.orderDetails = orderItems;
    controller.orderId = orderId;
    controller.payDelegate = self;
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
}



-(void)useProfileAddress {
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    Orders *newOrder = [Orders new];
    
    [[[dynamoDBObjectMapper scan:[Orders class]
                      expression:scanExpression]
      continueWithBlock:^id(AWSTask *task) {
          if (task.error) {
              NSLog(@"The request failed. Error: [%@]", task.error);
          } else {
              AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
              NSNumber *highestNumber = @0;
              for (Orders *order in paginatedOutput.items) {
                  //Do something with book.
                  if (order.OrderId > highestNumber) {
                      highestNumber = order.OrderId;
                  }
              }
              int value = [highestNumber intValue];
              orderId = [NSNumber numberWithInt:value + 1];
              newOrder.OrderId = [NSNumber numberWithInt:value + 1];
          }
          return nil;
      }] waitUntilFinished];
    newOrder.Area = [(MenuItems *)[selectedMenuItems objectAtIndex:0] Area];
    newOrder.Location = [(MenuItems *)[selectedMenuItems objectAtIndex:0] MenuLocation];
    for (int i = 0; i < selectedMenuItems.count; i++) {
        if (orderString.length > 0) {
            orderString = [NSString stringWithFormat:@"%@, {%@, %.2f}", orderString, [(MenuItems *)[selectedMenuItems objectAtIndex:i] Name], [[(MenuItems *)[selectedMenuItems objectAtIndex:i] Price] floatValue]];
        } else {
            orderString = [NSString stringWithFormat:@"{%@, %@}", [(MenuItems *)[selectedMenuItems objectAtIndex:i] Name], [(MenuItems *)[selectedMenuItems objectAtIndex:i] Price]];
        }
        
    }
    orderString = [NSString stringWithFormat:@"%@, {DeliveryFee, 0.49}", orderString];
    
    newOrder.Order = orderString;
    newOrder.AcceptedDelivery = @"NO";
    newOrder.DeliveryDate = @"UNKNOWN";
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
    
    //create a pool
    AWSCognitoIdentityUserPoolConfiguration *userConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
    
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:userConfiguration forKey:@"DrinksCustomerPool"];
    
    AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"currentUsername"];
    NSString *endpointArn = [defaults stringForKey:@"endpointArn"];
    newOrder.CustomerEndpointArn = endpointArn;
    [[[[pool getUser:username] getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
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
                    NSLog(@"Attribute: %@ Value: %@", attribute.name, attribute.value);
                    if ([attribute.name isEqualToString:@"address"]) {
                        newOrder.DeliveryAddress = attribute.value;
                        newOrder.driverUsername = @"UNKNOWN";
                        newOrder.customerUsername = username;
                        newOrder.paid = @"NO";
                        newOrder.transactionId = @0;
                        [[[dynamoDBObjectMapper save:newOrder]
                          continueWithBlock:^id(AWSTask *task) {
                              if (task.error) {
                                  NSLog(@"The request failed. Error: [%@]", task.error);
                              } else {
                                  //Do something with task.result or perform other operations.
                                  
                              }
                              return nil;
                          }] waitUntilFinished];
                        NSString *stringWithoutSpaces = [orderString
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
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        PaySequencePopoverViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paySequenceViewController"];
                        controller.orderDetails = orderItems;
                        controller.orderId = orderId;
                        controller.payDelegate = self;
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
                    }
                }
            }
        });
        return nil;
    }] waitUntilFinished];

}




-(void)useCurrentLoc {
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    Orders *newOrder = [Orders new];
    
    [[[dynamoDBObjectMapper scan:[Orders class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         } else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             NSNumber *highestNumber = @0;
             for (Orders *order in paginatedOutput.items) {
                 //Do something with book.
                 if (order.OrderId > highestNumber) {
                     highestNumber = order.OrderId;
                 }
             }
             int value = [highestNumber intValue];
             orderId = [NSNumber numberWithInt:value + 1];
             newOrder.OrderId = [NSNumber numberWithInt:value + 1];
         }
         return nil;
     }] waitUntilFinished];
    newOrder.Area = [(MenuItems *)[selectedMenuItems objectAtIndex:0] Area];
    newOrder.Location = [(MenuItems *)[selectedMenuItems objectAtIndex:0] MenuLocation];
    for (int i = 0; i < selectedMenuItems.count; i++) {
        if (orderString.length > 0) {
            orderString = [NSString stringWithFormat:@"%@, {%@, %.2f}", orderString, [(MenuItems *)[selectedMenuItems objectAtIndex:i] Name], [[(MenuItems *)[selectedMenuItems objectAtIndex:i] Price] floatValue]];
        } else {
            orderString = [NSString stringWithFormat:@"{%@, %@}", [(MenuItems *)[selectedMenuItems objectAtIndex:i] Name], [(MenuItems *)[selectedMenuItems objectAtIndex:i] Price]];
        }
        
    }
    orderString = [NSString stringWithFormat:@"%@, {DeliveryFee, 0.49}", orderString];
    
    newOrder.Order = orderString;
    newOrder.AcceptedDelivery = @"NO";
    newOrder.DeliveryDate = @"UNKNOWN";
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:currentLoc.coordinate.latitude longitude:currentLoc.coordinate.longitude];
    [geoCoder reverseGeocodeLocation:location completionHandler: ^(NSArray *placemarks, NSError *error) {
        //do something
        CLPlacemark *placemark = [placemarks lastObject];
        newOrder.DeliveryAddress = [NSString stringWithFormat:@"%@ %@, %@, %@",placemark.subThoroughfare, placemark.thoroughfare,placemark.locality, placemark.administrativeArea];
        newOrder.driverUsername = @"UNKNOWN";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:@"currentUsername"];
        NSString *endpointArn = [defaults stringForKey:@"endpointArn"];
        newOrder.CustomerEndpointArn = endpointArn;
        newOrder.customerUsername = username;
        newOrder.paid = @"NO";
        newOrder.transactionId = @0;
        [[[dynamoDBObjectMapper save:newOrder]
          continueWithBlock:^id(AWSTask *task) {
              if (task.error) {
                  NSLog(@"The request failed. Error: [%@]", task.error);
              } else {
                  //Do something with task.result or perform other operations.
                  
              }
              return nil;
          }] waitUntilFinished];
        // GO TO PAYMENTS
        NSString *stringWithoutSpaces = [orderString
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

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PaySequencePopoverViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"paySequenceViewController"];
        controller.orderDetails = orderItems;
        controller.orderId = orderId;
        controller.payDelegate = self;
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
    }];
    
        //[self performSegueWithIdentifier:@"submitOrder" sender:nil];
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



-(void)submitOrder {
    [self.tableView setScrollEnabled:NO];
    greyView = [[UIView alloc] initWithFrame:self.view.frame];
    greyView.backgroundColor = [UIColor grayColor];
    greyView.alpha = 0.0;
    [self.view addSubview:greyView];
    CGPoint centerView = self.view.center;
    centerView.y = centerView.y - 44.0;
    UIColor *baseColor = [UIColor colorWithRed:201.0/255.0 green:77.0/255.0 blue:32.0/255.0 alpha:1.0];
    modalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 330)];
    modalView.center = centerView;
    modalView.layer.cornerRadius = 15.0;
    modalView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 100, 10)];
    titleLabel.text = @"Delivery Address";
    [titleLabel setFont: [UIFont fontWithName:@"Optima" size:17.0]];
    [titleLabel sizeToFit];
    CGPoint center = titleLabel.center;
    center.x = modalView.frame.size.width / 2;
    [titleLabel setCenter:center];
    UIButton *currentLocButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 65, 250, 10)];
    [currentLocButton setTitle:@"Use Current Location" forState:UIControlStateNormal];
    [currentLocButton.titleLabel sizeToFit];
    [currentLocButton setTitleColor:baseColor forState:UIControlStateNormal];
    [currentLocButton.titleLabel setFont: [UIFont fontWithName:@"Optima" size:17.0]];
    currentLocButton.titleLabel.textColor = [UIColor blueColor];
    CGPoint currentButtonCenter = currentLocButton.center;
    currentButtonCenter.x = modalView.frame.size.width / 2;
    [currentLocButton setCenter:currentButtonCenter];
    [currentLocButton addTarget:self action:@selector(useCurrentLoc) forControlEvents:UIControlEventTouchUpInside];
    UIButton *savedLocButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 115, 250, 10)];
    [savedLocButton setTitle:@"Use Profile Address" forState:UIControlStateNormal];
    [savedLocButton.titleLabel sizeToFit];
    [savedLocButton setTitleColor:baseColor forState:UIControlStateNormal];
    [savedLocButton.titleLabel setFont: [UIFont fontWithName:@"Optima" size:17.0]];
    CGPoint savedButtonCenter = savedLocButton.center;
    savedButtonCenter.x = modalView.frame.size.width / 2;
    [savedLocButton setCenter:savedButtonCenter];
    [savedLocButton addTarget:self action:@selector(useProfileAddress) forControlEvents:UIControlEventTouchUpInside];
    UIButton *addLocButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 165, 250, 10)];
    [addLocButton setTitle:@"Use Entered Address" forState:UIControlStateNormal];
    [addLocButton.titleLabel sizeToFit];
    [addLocButton setTitleColor:baseColor forState:UIControlStateNormal];
    [addLocButton.titleLabel setFont: [UIFont fontWithName:@"Optima" size:17.0]];
    CGPoint addButtonCenter = addLocButton.center;
    addButtonCenter.x = modalView.frame.size.width / 2;
    [addLocButton setCenter:addButtonCenter];
    [addLocButton addTarget:self action:@selector(useEnteredAddress) forControlEvents:UIControlEventTouchUpInside];
    streetAddressTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 210, 240, 40)];
    [streetAddressTextField setPlaceholder:@"Street Address"];
    [streetAddressTextField setBorderStyle:UITextBorderStyleBezel];
    streetAddressTextField.layer.borderColor = [[UIColor redColor] CGColor];
    [streetAddressTextField setDelegate:self];
    CGPoint streetAddressCenter = streetAddressTextField.center;
    streetAddressCenter.x = modalView.frame.size.width / 2;
    [streetAddressTextField setCenter:streetAddressCenter];
    cityTextField = [[UITextField alloc] initWithFrame:CGRectMake(streetAddressTextField.frame.origin.x, 265, 115, 40)];
    [cityTextField setPlaceholder:@"City"];
    [cityTextField setBorderStyle:UITextBorderStyleBezel];
    [cityTextField setDelegate:self];
    stateTextField = [[UITextField alloc] initWithFrame:CGRectMake(streetAddressTextField.frame.origin.x+cityTextField.frame.size.width + 10, 265, 115, 40)];
    [stateTextField setPlaceholder:@"State"];
    [stateTextField setBorderStyle:UITextBorderStyleBezel];
    [stateTextField setDelegate:self];
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(streetAddressTextField.frame.origin.x, titleLabel.frame.origin.y+5, 10, 10)];
    [closeButton setTitle:@"X" forState:UIControlStateNormal];
    [closeButton.titleLabel sizeToFit];
    [closeButton setTitleColor:baseColor forState:UIControlStateNormal];
    [closeButton.titleLabel setFont: [UIFont fontWithName:@"Optima" size:17.0]];
    [closeButton addTarget:self action:@selector(closeModalView) forControlEvents:UIControlEventTouchUpInside];
    [modalView addSubview:closeButton];
    [modalView addSubview:streetAddressTextField];
    [modalView addSubview:cityTextField];
    [modalView addSubview:stateTextField];
    [modalView addSubview:addLocButton];
    [modalView addSubview:savedLocButton];
    [modalView addSubview:currentLocButton];
    [modalView addSubview:titleLabel];
    modalView.alpha = 0.0;
    [self.view addSubview:modalView];

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         modalView.alpha = 1.0;
                         greyView.alpha = 0.5;
                     }
                     completion:^(BOOL finished){
                     }];

}
-(void)closeModalView {
    [self.tableView setScrollEnabled:YES];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         modalView.alpha = 0.0;
                         greyView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [modalView removeFromSuperview];
                         [greyView removeFromSuperview];
                     }];
}
- (void)payViewControllerDismissed:(NSString *)paid
{
    [self performSegueWithIdentifier:@"submitOrder" sender:nil];
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

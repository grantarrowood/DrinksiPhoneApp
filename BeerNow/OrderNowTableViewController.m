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
}

@end

@implementation OrderNowTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    allLocations = [[NSMutableArray alloc] init];
    allAreas = [[NSMutableArray alloc] init];
    allMenuItems = [[NSMutableArray alloc] init];
    selectedMenuItems = [[NSMutableArray alloc] init];

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
    scanExpression.limit = @10;
    
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
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getTable) userInfo:nil repeats:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)getTable {
    [self.tableView reloadData];
    [timer invalidate];
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    [greyView removeFromSuperview];
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
                        return allMenuItems.count + 1;
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
                        if(indexPath.row == allMenuItems.count) {
                            cell = [tableView dequeueReusableCellWithIdentifier:@"submit" forIndexPath:indexPath];
                        } else {
                            cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
                            cell.textLabel.text = [(MenuItems *)[allMenuItems objectAtIndex:indexPath.row] Name];
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@.00", [(MenuItems *)[allMenuItems objectAtIndex:indexPath.row] Price]];
                        }
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
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        Orders *newOrder = [Orders new];
        newOrder.Area = [(MenuItems *)[selectedMenuItems objectAtIndex:0] Area];
        newOrder.Location = [(MenuItems *)[selectedMenuItems objectAtIndex:0] MenuLocation];
        for (int i = 0; i < selectedMenuItems.count; i++) {
            if (orderString.length > 0) {
                orderString = [NSString stringWithFormat:@"%@, {%@, %@}", orderString, [(MenuItems *)[selectedMenuItems objectAtIndex:i] Name], [(MenuItems *)[selectedMenuItems objectAtIndex:i] Price]];
            } else {
                orderString = [NSString stringWithFormat:@"{%@, %@}", [(MenuItems *)[selectedMenuItems objectAtIndex:i] Name], [(MenuItems *)[selectedMenuItems objectAtIndex:i] Price]];
            }
            
        }
        newOrder.Order = orderString;
        newOrder.OrderId = @1;
        newOrder.Completed = @"NO";
        newOrder.Selected = @"NO";
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

@end

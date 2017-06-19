//
//  OrderDetailsTableViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/18/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "OrderDetailsTableViewController.h"

@interface OrderDetailsTableViewController ()

@end

@implementation OrderDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    orderItems = [[NSMutableArray alloc] init];
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
                                  }
                              }
                          }
                          return nil;
                      }];
                     AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
                     
                     AWSCognitoIdentityUserPoolConfiguration *configurationPool = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
                     
                     [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configurationPool forKey:@"DrinksCustomerPool"];
                     
                     AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
                     pool.delegate = self;
                     [[[pool getUser:customerUsername] getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
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
                                     if([attribute.name isEqualToString:@"name"]) {
                                         customerName = attribute.value;
                                     } else if([attribute.name isEqualToString:@"address"]) {
                                         customerAddress = attribute.value;
                                     }
                                 }
                             }
                         });
                         return nil;
                     }];
                     isPaid = order.paid;
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
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getTable) userInfo:nil repeats:YES];
}

-(void)getTable {
    [self.tableView reloadData];
    [timer invalidate];
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    [greyView removeFromSuperview];
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
        return 6;
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
            cell.detailMainLabel.text = @"Customer Name:";
            cell.detailDynamicLabel.text = customerName;
            [cell.detailMainLabel sizeToFit];
            //[cell.detailDynamicLabel sizeToFit];
            cell.detailDynamicLabel.minimumFontSize = 10;
            cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            return cell;
        } else if (indexPath.row == 2) {
            DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            cell.detailMainLabel.text = @"Customer Address:";
            cell.detailDynamicLabel.text = customerAddress;
            [cell.detailMainLabel sizeToFit];
            //[cell.detailDynamicLabel sizeToFit];
            cell.detailDynamicLabel.minimumFontSize = 10;
            cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            return cell;
        } else if (indexPath.row == 3) {
            DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            cell.detailMainLabel.text = @"Location Name:";
            cell.detailDynamicLabel.text = locationName;
            [cell.detailMainLabel sizeToFit];
            //[cell.detailDynamicLabel sizeToFit];
            cell.detailDynamicLabel.minimumFontSize = 10;
            cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            return cell;
        } else if (indexPath.row == 4) {
            DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            cell.detailMainLabel.text = @"Location Address:";
            cell.detailDynamicLabel.text = locationAddress;
            [cell.detailMainLabel sizeToFit];
            //[cell.detailDynamicLabel sizeToFit];
            cell.detailDynamicLabel.minimumFontSize = 10;
            cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            return cell;
        } else if (indexPath.row == 5) {
            DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            cell.detailMainLabel.text = @"Paid:";
            cell.detailDynamicLabel.text = isPaid;
            [cell.detailMainLabel sizeToFit];
            //[cell.detailDynamicLabel sizeToFit];
            cell.detailDynamicLabel.minimumFontSize = 10;
            cell.detailDynamicLabel.adjustsFontSizeToFitWidth = YES;
            return cell;
        }
    } else {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"static6" forIndexPath:indexPath];
            return cell;
        } else if (indexPath.row == orderItems.count+1) {
            ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"items" forIndexPath:indexPath];
            cell.itemNameLabel.text = @"Total:";
            int total = 0;
            for (int i = 0; i<orderItems.count; i++) {
                total += [[orderItems objectAtIndex:i][1] intValue];
            }
            cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%i", total];
            [cell.itemPriceLabel sizeToFit];
            [cell.itemNameLabel sizeToFit];
            return cell;
        } else {
            ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"items" forIndexPath:indexPath];
            cell.itemNameLabel.text = [orderItems objectAtIndex:(indexPath.row-1)][0];
            cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%@",[orderItems objectAtIndex:(indexPath.row-1)][1]];
            [cell.itemPriceLabel sizeToFit];
            [cell.itemNameLabel sizeToFit];
            return cell;
        }
    }
    
    // Configure the cell...
    
    return nil;
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
    
    [[dynamoDBObjectMapper scan:[Orders class]
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
                         newOrder.Area = order.Area;
                         newOrder.Location = order.Location;
                         newOrder.Order = order.Order;
                         newOrder.customerUsername = order.customerUsername;
                         newOrder.OrderId = _orderId;
                         newOrder.Completed = @"NO";
                         newOrder.Selected = @"YES";
                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                         NSString *username = [defaults stringForKey:@"currentUsername"];
                         newOrder.driverUsername = username;
                         newOrder.paid = @"NO";
                         newOrder.receipt = @"NONE";
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
     }];
    greyView = [[UIView alloc] initWithFrame:self.view.frame];
    greyView.backgroundColor = [UIColor grayColor];
    greyView.alpha = 0.5;
    [self.view addSubview:greyView];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
    [self.view addSubview:spinner];
    [spinner startAnimating];
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(avalibleScreen) userInfo:nil repeats:YES];
}

-(void)avalibleScreen {
    [timer invalidate];
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    [greyView removeFromSuperview];
    [self performSegueWithIdentifier:@"backToAvalibleSegue" sender:nil];
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
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}
*/

@end

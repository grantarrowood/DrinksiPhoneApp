//
//  ProfileTableViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/20/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "ProfileTableViewController.h"

@interface ProfileTableViewController () {
    UIView *footerView;
}

@end

@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userPool = [defaults stringForKey:@"userPool"];
    if ([userPool isEqualToString:@"CUSTOMER"]) {
        AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
        
        //create a pool
        AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
        
        [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"DrinksCustomerPool"];
        
        AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
        NSString *username = [defaults stringForKey:@"currentUsername"];
        self.usernameLabel.text = username;
        self.passwordLabel.text = @"*****";
        [[[pool getUser:username] getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
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
                        if ([attribute.name isEqualToString:@"name"]) {
                            self.fullNameLabel.text = attribute.value;
                            [self.fullNameLabel sizeToFit];
                            self.fullNameTextField.text = attribute.value;
                        } else if ([attribute.name isEqualToString:@"address"]) {
                            self.addressLabel.text = attribute.value;
                            self.addressTextField.text = attribute.value;
                            [self.addressLabel sizeToFit];
                        } else if ([attribute.name isEqualToString:@"birthdate"]) {
                            self.birthdayLabel.text = attribute.value;
                            self.birthdayTextField.text = attribute.value;
                            [self.birthdayLabel sizeToFit];
                        } else if ([attribute.name isEqualToString:@"phone_number"]) {
                            self.phoneNumberLabel.text = attribute.value;
                            self.phoneNumberTextField.text = attribute.value;
                            [self.phoneNumberLabel sizeToFit];
                        } else if ([attribute.name isEqualToString:@"email"]) {
                            self.emailLabel.text = attribute.value;
                            self.emailTextField.text = attribute.value;
                            [self.emailLabel sizeToFit];
                        }
                    }
                }
            });
            return nil;
        }];
    } else {
        AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
        
        AWSCognitoIdentityUserPoolConfiguration *driverConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7abpokft5to0bnmbpordu8ou7r"  clientSecret:@"lo4l2ui4oggikjfqo6afgo5mv4u1839jvsikrot5uh1rksf1ad2" poolId:@"us-east-1_KpiGHtI7M"];
        
        [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:driverConfiguration forKey:@"DrinksDriverPool"];
        
        AWSCognitoIdentityUserPool *driverPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksDriverPool"];
        NSString *username = [defaults stringForKey:@"currentUsername"];
        self.usernameLabel.text = username;
        self.passwordLabel.text = @"*****";
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
                        NSLog(@"Attribute: %@ Value: %@", attribute.name, attribute.value);
                        if ([attribute.name isEqualToString:@"name"]) {
                            self.fullNameLabel.text = attribute.value;
                            [self.fullNameLabel sizeToFit];
                            self.fullNameTextField.text = attribute.value;
                        } else if ([attribute.name isEqualToString:@"address"]) {
                            self.addressLabel.text = attribute.value;
                            self.addressTextField.text = attribute.value;
                            [self.addressLabel sizeToFit];
                        } else if ([attribute.name isEqualToString:@"birthdate"]) {
                            self.birthdayLabel.text = attribute.value;
                            self.birthdayTextField.text = attribute.value;
                            [self.birthdayLabel sizeToFit];
                        } else if ([attribute.name isEqualToString:@"phone_number"]) {
                            self.phoneNumberLabel.text = attribute.value;
                            self.phoneNumberTextField.text = attribute.value;
                            [self.phoneNumberLabel sizeToFit];
                        } else if ([attribute.name isEqualToString:@"email"]) {
                            self.emailLabel.text = attribute.value;
                            self.emailTextField.text = attribute.value;
                            [self.emailLabel sizeToFit];
                        }
                    }
                }
            });
            return nil;
        }] waitUntilFinished];
        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                        identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
        
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        
        NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_license.jpg", username]];
        NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
        
        AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
        
        downloadRequest.bucket = @"drinksdriverlicenses";
        downloadRequest.key = [NSString stringWithFormat:@"%@_license.jpg", username];
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
                                                                        self.driversLicenseImageView.image = [UIImage imageWithContentsOfFile:downloadingFilePath];
                                                                    }
                                                                    return nil;
                                                                }] waitUntilFinished];

    }
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userPool = [defaults stringForKey:@"userPool"];
    if ([userPool isEqualToString:@"CUSTOMER"]) {
        return 2;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userPool = [defaults stringForKey:@"userPool"];
    if ([userPool isEqualToString:@"CUSTOMER"]) {
        if (section == 0) {
            return 7;
        } else if (section == 1) {
            return 4;
        }
    } else {
        if (section == 0) {
            return 7;
        } else if (section == 1) {
            return 4;
        } else if (section == 2) {
            return 1;
        }
    }
    return 4;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

- (IBAction)editAction:(id)sender {
    if ([self.editBarButton.title isEqualToString:@"Edit"]) {
        self.editBarButton.title = @"Cancel";
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 623, 375, 44)];
        footerView.backgroundColor = [UIColor whiteColor];
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 1)];
        separatorView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
        [footerView addSubview:separatorView];
        UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 44)];
        [acceptButton setTitle:@"Submit" forState:UIControlStateNormal];
        [acceptButton setTitleColor:[UIColor colorWithRed:201.0/255.0 green:77.0/255.0 blue:32.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [acceptButton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:acceptButton];
        
        self.fullNameLabel.hidden = YES;
        self.fullNameTextField.hidden = NO;
        self.addressLabel.hidden = YES;
        self.addressTextField.hidden = NO;
        self.birthdayLabel.hidden = YES;
        self.birthdayTextField.hidden = NO;
        self.phoneNumberLabel.hidden = YES;
        self.phoneNumberTextField.hidden = NO;
        self.emailLabel.hidden = YES;
        self.emailTextField.hidden = NO;
        self.passwordLabel.hidden = YES;
        self.passwordTextField.hidden = NO;

    } else {
        self.editBarButton.title = @"Edit";
        
        [footerView removeFromSuperview];
        
        self.fullNameLabel.hidden = NO;
        self.fullNameTextField.hidden = YES;
        self.addressLabel.hidden = NO;
        self.addressTextField.hidden = YES;
        self.birthdayLabel.hidden = NO;
        self.birthdayTextField.hidden = YES;
        self.phoneNumberLabel.hidden = NO;
        self.phoneNumberTextField.hidden = YES;
        self.emailLabel.hidden = NO;
        self.emailTextField.hidden = YES;
        self.passwordLabel.hidden = NO;
        self.passwordTextField.hidden = YES;
    }
}

-(void)submit {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userPool = [defaults stringForKey:@"userPool"];
    if ([userPool isEqualToString:@"CUSTOMER"]) {
        AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
        
        //create a pool
        AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
        
        [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"DrinksCustomerPool"];
        
        AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
        NSString *username = [defaults stringForKey:@"currentUsername"];

        AWSCognitoIdentityUserAttributeType *fullNameAttribute = [AWSCognitoIdentityUserAttributeType new];
        fullNameAttribute.name = @"name";
        fullNameAttribute.value = self.fullNameTextField.text;
        AWSCognitoIdentityUserAttributeType *birthdateAttribute = [AWSCognitoIdentityUserAttributeType new];
        birthdateAttribute.name = @"birthdate";
        birthdateAttribute.value = self.birthdayTextField.text;
        AWSCognitoIdentityUserAttributeType *addressAttribute = [AWSCognitoIdentityUserAttributeType new];
        addressAttribute.name = @"address";
        addressAttribute.value = self.addressTextField.text;
        AWSCognitoIdentityUserAttributeType *emailAttribute = [AWSCognitoIdentityUserAttributeType new];
        emailAttribute.name = @"email";
        emailAttribute.value = self.emailTextField.text;
        AWSCognitoIdentityUserAttributeType *phoneNumberAttribute = [AWSCognitoIdentityUserAttributeType new];
        phoneNumberAttribute.name = @"phone_number";
        phoneNumberAttribute.value = self.phoneNumberTextField.text;
        [[[pool getUser:username] updateAttributes:@[fullNameAttribute, birthdateAttribute, addressAttribute, emailAttribute, phoneNumberAttribute]] continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserUpdateAttributesResponse *> * _Nonnull task) {
            //success
            return nil;
        }];
        if (self.passwordTextField.text != nil) {
            [[[pool getUser:username] changePassword:@"currentPassword" proposedPassword:self.passwordTextField.text] continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserChangePasswordResponse *> * _Nonnull task) {
                //success
                return nil;
            }];
        }
    } else {
        AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
        
        AWSCognitoIdentityUserPoolConfiguration *driverConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7abpokft5to0bnmbpordu8ou7r"  clientSecret:@"lo4l2ui4oggikjfqo6afgo5mv4u1839jvsikrot5uh1rksf1ad2" poolId:@"us-east-1_KpiGHtI7M"];
        
        [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:driverConfiguration forKey:@"DrinksDriverPool"];
        
        AWSCognitoIdentityUserPool *driverPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksDriverPool"];
        NSString *username = [defaults stringForKey:@"currentUsername"];
        AWSCognitoIdentityUserAttributeType *fullNameAttribute = [AWSCognitoIdentityUserAttributeType new];
        fullNameAttribute.name = @"name";
        fullNameAttribute.value = self.fullNameTextField.text;
        AWSCognitoIdentityUserAttributeType *birthdateAttribute = [AWSCognitoIdentityUserAttributeType new];
        birthdateAttribute.name = @"birthdate";
        birthdateAttribute.value = self.birthdayTextField.text;
        AWSCognitoIdentityUserAttributeType *addressAttribute = [AWSCognitoIdentityUserAttributeType new];
        addressAttribute.name = @"address";
        addressAttribute.value = self.addressTextField.text;
        AWSCognitoIdentityUserAttributeType *emailAttribute = [AWSCognitoIdentityUserAttributeType new];
        emailAttribute.name = @"email";
        emailAttribute.value = self.emailTextField.text;
        AWSCognitoIdentityUserAttributeType *phoneNumberAttribute = [AWSCognitoIdentityUserAttributeType new];
        phoneNumberAttribute.name = @"phone_number";
        phoneNumberAttribute.value = self.phoneNumberTextField.text;
        [[[driverPool getUser:username] updateAttributes:@[fullNameAttribute, birthdateAttribute, addressAttribute, emailAttribute, phoneNumberAttribute]] continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserUpdateAttributesResponse *> * _Nonnull task) {
            //success
            return nil;
        }];
        if (self.passwordTextField.text != nil) {
            [[[driverPool getUser:username] changePassword:@"currentPassword" proposedPassword:self.passwordTextField.text] continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserChangePasswordResponse *> * _Nonnull task) {
                //success
                return nil;
            }];
        }
    }
}

@end

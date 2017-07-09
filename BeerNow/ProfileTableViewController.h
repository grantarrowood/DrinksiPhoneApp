//
//  ProfileTableViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/20/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "AWSCognitoIdentityProvider.h"
#import <AWSS3/AWSS3.h>
#import "AFDropdownNotification.h"


@interface ProfileTableViewController : UITableViewController <AFDropdownNotificationDelegate>
@property (nonatomic, strong) AFDropdownNotification *notification;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
- (IBAction)editAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UIImageView *driversLicenseImageView;

@end

//
//  LoginViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 5/24/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "AWSCognitoIdentityProvider.h"
#import "SWRevealViewController.h"


@interface LoginViewController : UIViewController <AWSCognitoIdentityPasswordAuthentication, AWSCognitoIdentityInteractiveAuthenticationDelegate, AWSCognitoIdentityRememberDevice>
@property (nonatomic, strong) AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails*>* passwordAuthenticationCompletion;
@property (nonatomic,strong) AWSTaskCompletionSource<NSNumber *>* rememberDeviceCompletionSource;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *loginButtonView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;


@end

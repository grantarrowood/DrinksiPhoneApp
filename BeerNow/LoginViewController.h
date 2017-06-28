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
#import "ViewController.h"
#import <AWSS3/AWSS3.h>



@interface LoginViewController : UIViewController <AWSCognitoIdentityPasswordAuthentication, AWSCognitoIdentityInteractiveAuthenticationDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIWebViewDelegate>
{
    NSString *loginType;
    BOOL profilePhoto;
}
@property (nonatomic, strong) AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails*>* passwordAuthenticationCompletion;
@property (nonatomic,strong) AWSTaskCompletionSource<NSNumber *>* rememberDeviceCompletionSource;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIImageView *carLoginImage;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *loginButtonView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *addProfilePhotoButton;
@property (weak, nonatomic) IBOutlet UILabel *addPhotoLabel;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIView *birthdateView;
@property (weak, nonatomic) IBOutlet UITextField *birthdateTextField;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
- (IBAction)signUpAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
- (IBAction)forgotPasswordAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *notAMemberLabel;
@property (weak, nonatomic) IBOutlet UILabel *drinksLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *customerLoginLabel;
@property (weak, nonatomic) IBOutlet UILabel *driverLoginLabel;
@property (weak, nonatomic) IBOutlet UIButton *customerLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *driverLoginButton;
- (IBAction)customerLoginAction:(id)sender;
- (IBAction)driverLoginAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *addDriversLicenseLabel;
@property (weak, nonatomic) IBOutlet UIButton *addDriversLicenseButton;
@property (weak, nonatomic) IBOutlet UIImageView *driversLicenseImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *signUpScrollView;
- (IBAction)addProfilePhotoAction:(id)sender;
- (IBAction)addDriversLicenseAction:(id)sender;
- (IBAction)addDriversLicenseTapAction:(id)sender;
- (IBAction)addProfilePhotoTapAction:(id)sender;



@end

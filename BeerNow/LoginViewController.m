//
//  LoginViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 5/24/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@end

@implementation LoginViewController


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    //setup service config
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
    
    //create a pool
    AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
    
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"DrinksCustomerPool"];
    
    AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
    pool.delegate = self;
    if([[pool currentUser] getSession].result != nil) {
        [[pool currentUser] signOut];
    }
    [[pool getUser] getSession];
    
}
-(id<AWSCognitoIdentityPasswordAuthentication>) startPasswordAuthentication {
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // show image
    self.backgroundImage.image = [UIImage imageNamed:@"beerglasslogin"];
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    // add the effect view to the image view
    [self.backgroundImage addSubview:effectView];
    self.usernameView.layer.cornerRadius = 20;
    self.passwordView.layer.cornerRadius = 20;
    self.loginButtonView.layer.cornerRadius = 20;
    self.nameView.layer.cornerRadius = 20;
    self.emailView.layer.cornerRadius = 20;
    self.phoneView.layer.cornerRadius = 20;
    self.addressView.layer.cornerRadius = 20;
    self.birthdateView.layer.cornerRadius = 20;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) getPasswordAuthenticationDetails: (AWSCognitoIdentityPasswordAuthenticationInput *) authenticationInput  passwordAuthenticationCompletionSource: (AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails *> *) passwordAuthenticationCompletionSource {
    self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource;
    
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
        }else{
        }
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButtonAction:(id)sender {
    if([self.loginButton.titleLabel.text isEqualToString:@"Login"]) {
        self.passwordAuthenticationCompletion.result = [[AWSCognitoIdentityPasswordAuthenticationDetails alloc] initWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
    } else {
        AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
    
        AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
    
        [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"DrinksCustomerPool"];
        AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
        if (self.profileImageView.image != [UIImage imageNamed:@"profileIcon"]) {
            AWSCognitoIdentityUserAttributeType *profileImage = [AWSCognitoIdentityUserAttributeType new];
            profileImage.name = @"picture";
            //phone number must be prefixed by country code
            profileImage.value = self.profileImageView.image;
        }
        
        
        AWSCognitoIdentityUserAttributeType * phone = [AWSCognitoIdentityUserAttributeType new];
        phone.name = @"phone_number";
        //phone number must be prefixed by country code
        phone.value = self.phoneTextField.text;
        AWSCognitoIdentityUserAttributeType * email = [AWSCognitoIdentityUserAttributeType new];
        email.name = @"email";
        email.value = self.emailTextField.text;
        AWSCognitoIdentityUserAttributeType * birthdate = [AWSCognitoIdentityUserAttributeType new];
        birthdate.name = @"birthdate";
        birthdate.value = self.birthdateTextField.text;
        AWSCognitoIdentityUserAttributeType * address = [AWSCognitoIdentityUserAttributeType new];
        address.name = @"address";
        address.value = self.addressTextField.text;
        AWSCognitoIdentityUserAttributeType * name = [AWSCognitoIdentityUserAttributeType new];
        name.name = @"name";
        name.value = self.nameTextField.text;
        //register the user
        [[pool signUp:self.usernameTextField.text password:self.passwordTextField.text userAttributes:@[email,phone,birthdate,address,name] validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(task.error){
                    [[[UIAlertView alloc] initWithTitle:task.error.userInfo[@"__type"]
                                                message:task.error.userInfo[@"message"]
                                               delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil] show];
                }else {
                    AWSCognitoIdentityUserPoolSignUpResponse * response = task.result;
                    if(!response.userConfirmed){
                        //need to confirm user using user.confirmUser:
                    }
                }});
            return nil;
        }];
    }
}
- (IBAction)signUpAction:(id)sender {
    self.loginButton.titleLabel.frame = CGRectMake(self.loginButton.frame.origin.x, self.loginButton.frame.origin.y, self.loginButton.frame.size.width+10, self.loginButton.frame.size.height);
    [self.loginButton setTitle: @"Sign Up" forState: UIControlStateNormal];
    self.usernameTextField.placeholder = @"Username";
    self.profileImageView.alpha = 0.0;
    self.profileImageView.hidden = NO;
    self.addPhotoLabel.alpha = 0.0;
    self.addPhotoLabel.hidden = NO;
    self.nameView.alpha = 0.0;
    self.nameView.hidden = NO;
    self.emailView.alpha = 0.0;
    self.emailView.hidden = NO;
    self.phoneView.alpha = 0.0;
    self.phoneView.hidden = NO;
    self.addressView.alpha = 0.0;
    self.addressView.hidden = NO;
    self.birthdateView.alpha = 0.0;
    self.birthdateView.hidden = NO;
    self.backButton.alpha = 0.0;
    self.backButton.hidden = NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.profileImageView.alpha = 0.75;
                         self.addPhotoLabel.alpha = 0.75;
                         self.nameView.alpha = 0.75;
                         self.emailView.alpha = 0.75;
                         self.phoneView.alpha = 0.75;
                         self.addressView.alpha = 0.75;
                         self.birthdateView.alpha = 0.75;
                         self.backButton.alpha = 1.0;

                     }
                     completion:^(BOOL finished){
                         
                     }];
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.drinksLabel.transform = CGAffineTransformMakeTranslation(0, -100);
                         self.usernameView.transform = CGAffineTransformMakeTranslation(0, -23);
                         self.passwordView.transform = CGAffineTransformMakeTranslation(0, -34);
                         self.loginButtonView.transform = CGAffineTransformMakeTranslation(0, 237);
                         self.notAMemberLabel.alpha = 0.0;
                         self.signUpButton.alpha = 0.0;
                         self.forgotPasswordButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         self.notAMemberLabel.hidden = YES;
                         self.signUpButton.hidden = YES;
                         self.forgotPasswordButton.hidden = YES;
                         self.notAMemberLabel.alpha = 1.0;
                         self.signUpButton.alpha = 1.0;
                         self.forgotPasswordButton.alpha = 1.0;
                    }];
    
    
    
    
    
}
- (IBAction)forgotPasswordAction:(id)sender {
}
- (IBAction)backButtonAction:(id)sender {
    [self.loginButton setTitle: @"Login" forState: UIControlStateNormal];
    self.usernameTextField.placeholder = @"Username or Email";
    self.notAMemberLabel.alpha = 0.0;
    self.signUpButton.alpha = 0.0;
    self.forgotPasswordButton.alpha = 0.0;
    self.notAMemberLabel.hidden = NO;
    self.signUpButton.hidden = NO;
    self.forgotPasswordButton.hidden = NO;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.profileImageView.alpha = 0.0;
                         self.addPhotoLabel.alpha = 0.0;
                         self.nameView.alpha = 0.0;
                         self.emailView.alpha = 0.0;
                         self.phoneView.alpha = 0.0;
                         self.addressView.alpha = 0.0;
                         self.birthdateView.alpha = 0.0;
                         self.backButton.alpha = 0.0;
                         
                     }
                     completion:^(BOOL finished){
                         self.profileImageView.hidden = YES;
                         self.addPhotoLabel.hidden = YES;
                         self.nameView.hidden = YES;
                         self.emailView.hidden = YES;
                         self.phoneView.hidden = YES;
                         self.addressView.hidden = YES;
                         self.birthdateView.hidden = YES;
                         self.backButton.hidden = YES;
                     }];
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.drinksLabel.transform = CGAffineTransformIdentity;
                         self.usernameView.transform = CGAffineTransformIdentity;
                         self.passwordView.transform = CGAffineTransformIdentity;
                         self.loginButtonView.transform = CGAffineTransformIdentity;
                         self.notAMemberLabel.alpha = 1.0;
                         self.signUpButton.alpha = 1.0;
                         self.forgotPasswordButton.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                     }];
}
@end

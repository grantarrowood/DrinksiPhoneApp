//
//  LoginViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 5/24/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "LoginViewController.h"
#import "SidebarTableViewController.h"

@interface LoginViewController () {
    NSTimer *timer;
    UIActivityIndicatorView *spinner;
    UIView *greyView;
}
@end

@implementation LoginViewController


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    //setup service config

    
}
-(id<AWSCognitoIdentityPasswordAuthentication>) startPasswordAuthentication {
    return self;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"SCROLLING");
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //NSLog(@"SCROLLING");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    loginType = @"";
    [self.backgroundImage setFrame:CGRectMake(self.backgroundImage.bounds.origin.x-55, self.backgroundImage.bounds.origin.y, (self.view.bounds.size.width/2)+55, self.view.bounds.size.height)];
    [self.carLoginImage setFrame:CGRectMake(self.view.bounds.size.width/2, self.carLoginImage.bounds.origin.y, (self.view.bounds.size.width/2)+55, self.view.bounds.size.height)];
    [self.carLoginImage layoutIfNeeded];
    [self.drinksLabel setFont:[UIFont fontWithName:@"Optima" size:45]];
    [self.drinksLabel sizeToFit];
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.drinksLabel.transform = CGAffineTransformMakeTranslation(0, 155);
                     }
                     completion:^(BOOL finished){
                     }];
    
    // Do any additional setup after loading the view.
    // show image
    self.backgroundImage.image = [UIImage imageNamed:@"beerglasslogin"];
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    effectView.alpha = 0.8;
    // add the effect view to the image view
    [self.backgroundImage addSubview:effectView];
    
    self.carLoginImage.image = [UIImage imageNamed:@"carLogin"];
    
    // create effect
    UIBlurEffect *carBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    
    // add effect to an effect view
    UIVisualEffectView *carEffectView = [[UIVisualEffectView alloc]initWithEffect:carBlur];
    carEffectView.frame = self.view.frame;
    carEffectView.alpha = 0.8;
    // add the effect view to the image view
    [self.carLoginImage addSubview:carEffectView];
    
    
    
    self.usernameView.layer.cornerRadius = 20;
    self.passwordView.layer.cornerRadius = 20;
    self.loginButtonView.layer.cornerRadius = 20;
    self.nameView.layer.cornerRadius = 20;
    self.emailView.layer.cornerRadius = 20;
    self.phoneView.layer.cornerRadius = 20;
    self.addressView.layer.cornerRadius = 20;
    self.birthdateView.layer.cornerRadius = 20;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnTextField)];
    [self.signUpScrollView addGestureRecognizer:recognizer];
//    UITapGestureRecognizer *profileRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addProfilePhotoAction:)];
//    [self.profileImageView addGestureRecognizer:profileRecognizer];
//    UITapGestureRecognizer *licenseRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addDriversLicenseAction:)];
//    [self.driversLicenseImageView addGestureRecognizer:licenseRecognizer];
}

-(void)returnTextField {
    [self.view endEditing:YES];
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
            if ([loginType isEqualToString:@"CUSTOMER"]) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:self.usernameTextField.text forKey:@"currentUsername"];
                [defaults synchronize];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"ReloadSidebar"
                 object:self];
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                [greyView removeFromSuperview];
                [self performSegueWithIdentifier:@"loginToCustomer" sender:nil];
            } else {
                
                timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(authenticateDriver) userInfo:nil repeats:YES];

            }
            
            
        }
    });
}

-(void)authenticateDriver {
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
    
    AWSCognitoIdentityUserPoolConfiguration *driverConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7abpokft5to0bnmbpordu8ou7r"  clientSecret:@"lo4l2ui4oggikjfqo6afgo5mv4u1839jvsikrot5uh1rksf1ad2" poolId:@"us-east-1_KpiGHtI7M"];
    
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:driverConfiguration forKey:@"DrinksDriverPool"];
    
    AWSCognitoIdentityUserPool *driverPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksDriverPool"];
    driverPool.delegate = self;
    [[[driverPool getUser:self.usernameTextField.text] getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
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
                    if ([attribute.name isEqualToString:@"custom:isAccepted"]) {
                        if ([attribute.value isEqualToString:@"YES"]) {
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setValue:self.usernameTextField.text forKey:@"currentUsername"];
                            [defaults synchronize];
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:@"ReloadSidebar"
                             object:self];
                            [spinner stopAnimating];
                            [spinner removeFromSuperview];
                            [greyView removeFromSuperview];
                            [self performSegueWithIdentifier:@"loginToDriver" sender:nil];
                        } else {
                            [[[UIAlertView alloc] initWithTitle:@"You have not been accepted yet!"
                                                        message:@"Please check again later."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil] show];
                        }
                    }
                }
            }
        });
        return nil;
    }];
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
        greyView = [[UIView alloc] initWithFrame:self.view.frame];
        greyView.backgroundColor = [UIColor grayColor];
        greyView.alpha = 0.5;
        [self.view addSubview:greyView];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
        [self.view addSubview:spinner];
        [spinner startAnimating];
        [self.view endEditing:YES];
    } else {
        [self.view endEditing:YES];
        if ([loginType isEqualToString:@"CUSTOMER"]) {
            AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                            identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
            
            AWSServiceConfiguration *s3configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
            
            AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = s3configuration;
            AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
            
            AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
            
            [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"DrinksCustomerPool"];
            AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
            AWSCognitoIdentityUserAttributeType *profileImage = [AWSCognitoIdentityUserAttributeType new];
            if (self.profileImageView.image != [UIImage imageNamed:@"profileIcon"]) {
                AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                NSData *pngData = UIImagePNGRepresentation(self.profileImageView.image);
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsPath = [paths objectAtIndex:0];
                NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-profilePicture-%@.jpg", self.usernameTextField.text,loginType]];
                [pngData writeToFile:filePath atomically:YES];
                NSURL *uploadingFileURL = [NSURL fileURLWithPath:filePath];
                AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
                uploadRequest.bucket = @"drinksprofilepictures";
                uploadRequest.key = [NSString stringWithFormat:@"%@-profilePicture-%@.jpg", self.usernameTextField.text,loginType];
                uploadRequest.body = uploadingFileURL;
                [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                                   withBlock:^id(AWSTask *task) {
                                                                       if (task.error) {
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
                                                                               // Unknown error.
                                                                               NSLog(@"Error: %@", task.error);
                                                                           }
                                                                       }
                                                                       
                                                                       if (task.result) {
                                                                           AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                                           // The file uploaded successfully.
                                                                       }
                                                                       return nil;
                                                                   }];
                
                
                profileImage.name = @"picture";
                //phone number must be prefixed by country code
                profileImage.value = [NSString stringWithFormat:@"%@-profilePicture-%@.jpg", self.usernameTextField.text,loginType];
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
            [[pool signUp:self.usernameTextField.text password:self.passwordTextField.text userAttributes:@[email,phone,birthdate,address,name,profileImage] validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
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
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setValue:self.usernameTextField.text forKey:@"currentUsername"];
                        [defaults synchronize];
                        [self performSegueWithIdentifier:@"loginToCustomer" sender:nil];
                    }});
                return nil;
            }];

        } else if([loginType isEqualToString:@"DRIVER"]) {
            AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                            identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
            
            AWSServiceConfiguration *s3configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
            
            AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = s3configuration;
            AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
            
            AWSCognitoIdentityUserPoolConfiguration *driverConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7abpokft5to0bnmbpordu8ou7r"  clientSecret:@"lo4l2ui4oggikjfqo6afgo5mv4u1839jvsikrot5uh1rksf1ad2" poolId:@"us-east-1_KpiGHtI7M"];
            
            [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:driverConfiguration forKey:@"DrinksDriverPool"];
            
            AWSCognitoIdentityUserPool *driverPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksDriverPool"];
            AWSCognitoIdentityUserAttributeType *profileImage = [AWSCognitoIdentityUserAttributeType new];

            if (self.profileImageView.image != [UIImage imageNamed:@"profileIcon"]) {
                AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                NSData *pngData = UIImagePNGRepresentation(self.profileImageView.image);
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsPath = [paths objectAtIndex:0];
                NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-profilePicture-%@.jpg", self.usernameTextField.text,loginType]];
                [pngData writeToFile:filePath atomically:YES];
                NSURL *uploadingFileURL = [NSURL fileURLWithPath:filePath];
                AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
                uploadRequest.bucket = @"drinksprofilepictures";
                uploadRequest.key = [NSString stringWithFormat:@"%@-profilePicture-%@.jpg", self.usernameTextField.text,loginType];
                uploadRequest.body = uploadingFileURL;
                [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                                   withBlock:^id(AWSTask *task) {
                                                                       if (task.error) {
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
                                                                               // Unknown error.
                                                                               NSLog(@"Error: %@", task.error);
                                                                           }
                                                                       }
                                                                       
                                                                       if (task.result) {
                                                                           AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                                           // The file uploaded successfully.
                                                                       }
                                                                       return nil;
                                                                   }];
                
                
                profileImage.name = @"custom:profilePicture";
                //phone number must be prefixed by country code
                profileImage.value = [NSString stringWithFormat:@"%@-profilePicture-%@.jpg", self.usernameTextField.text,loginType];
            }
            AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
            NSData *pngData = UIImagePNGRepresentation(self.driversLicenseImageView.image);
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsPath = [paths objectAtIndex:0];
            NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-license.jpg", self.usernameTextField.text]];
            [pngData writeToFile:filePath atomically:YES];
            NSURL *uploadingFileURL = [NSURL fileURLWithPath:filePath];
            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.bucket = @"drinksdriverlicenses";
            uploadRequest.key = [NSString stringWithFormat:@"%@-license.jpg", self.usernameTextField.text];
            uploadRequest.body = uploadingFileURL;
            [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                               withBlock:^id(AWSTask *task) {
                                                                   if (task.error) {
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
                                                                           // Unknown error.
                                                                           NSLog(@"Error: %@", task.error);
                                                                       }
                                                                   }
                                                                   
                                                                   if (task.result) {
                                                                       AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                                       // The file uploaded successfully.
                                                                   }
                                                                   return nil;
                                                               }];

            AWSCognitoIdentityUserAttributeType *driversLicense = [AWSCognitoIdentityUserAttributeType new];
            driversLicense.name = @"picture";
            driversLicense.value = [NSString stringWithFormat:@"%@-license.jpg", self.usernameTextField.text];
            
            AWSCognitoIdentityUserAttributeType *isAccepted = [AWSCognitoIdentityUserAttributeType new];
            isAccepted.name = @"custom:isAccepted";
            isAccepted.value = @"NO";
            
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
            [[driverPool signUp:self.usernameTextField.text password:self.passwordTextField.text userAttributes:@[email,phone,birthdate,address,name,profileImage,isAccepted,profileImage] validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
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
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setValue:self.usernameTextField.text forKey:@"currentUsername"];
                        [defaults synchronize];
                        [self backButtonAction:self.backButton];
                    }});
                return nil;
            }];

        }
    }
}
- (IBAction)signUpAction:(id)sender {
    self.loginButton.titleLabel.frame = CGRectMake(self.loginButton.frame.origin.x, self.loginButton.frame.origin.y, self.loginButton.frame.size.width+10, self.loginButton.frame.size.height);
    [self.loginButton setTitle: @"Sign Up" forState: UIControlStateNormal];
    if([loginType isEqualToString:@"CUSTOMER"]) {
        self.drinksLabel.text = @"DRINKS CUSTOMER";
    } else {
        self.drinksLabel.text = @"DRINKS DRIVER";
        self.driversLicenseImageView.hidden = NO;
        self.addDriversLicenseButton.hidden = NO;
    }
    [self.drinksLabel sizeToFit];
    self.usernameTextField.placeholder = @"Username";
    self.profileImageView.alpha = 0.0;
    self.profileImageView.hidden = NO;
    self.addProfilePhotoButton.alpha = 0.0;
    self.addProfilePhotoButton.hidden = NO;
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
                         self.profileImageView.alpha = 1.0;
                         self.addProfilePhotoButton.alpha = 1.0;
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
                         self.drinksLabel.transform = CGAffineTransformMakeTranslation(0, -105);
                         if([loginType isEqualToString:@"CUSTOMER"]) {
                             self.loginButtonView.transform = CGAffineTransformMakeTranslation(0, 340);
                         } else {
                             self.loginButtonView.transform = CGAffineTransformMakeTranslation(0, 599);
                         }
                         self.signUpScrollView.contentSize = CGSizeMake(375, self.loginButtonView.frame.origin.y + self.loginButtonView.frame.size.height + 50);
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
    if ([self.usernameTextField.text isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Username" message:@"Please enter your username." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        if ([loginType isEqualToString:@"CUSTOMER"]) {
            AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
            
            AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
            
            [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"DrinksCustomerPool"];
            AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
            
            [[[pool getUser:self.usernameTextField.text] forgotPassword] continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserForgotPasswordResponse*> * _Nonnull task) {
                //success
                return nil;
            }];
        } else {
            AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
            
            AWSCognitoIdentityUserPoolConfiguration *driverConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7abpokft5to0bnmbpordu8ou7r"  clientSecret:@"lo4l2ui4oggikjfqo6afgo5mv4u1839jvsikrot5uh1rksf1ad2" poolId:@"us-east-1_KpiGHtI7M"];
            
            [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:driverConfiguration forKey:@"DrinksDriverPool"];
            
            AWSCognitoIdentityUserPool *driverPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksDriverPool"];

            [[[driverPool getUser:self.usernameTextField.text] forgotPassword] continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserForgotPasswordResponse*> * _Nonnull task) {
                //success
                return nil;
            }];
        }

    }


}
- (IBAction)backButtonAction:(id)sender {
    if([self.loginButton.titleLabel.text  isEqual: @"Login"]) {
        self.customerLoginLabel.alpha = 0.0;
        self.driverLoginLabel.alpha = 0.0;
        self.customerLoginLabel.hidden = NO;
        self.driverLoginLabel.hidden = NO;
        self.usernameTextField.text = @"";
        self.passwordTextField.text= @"";
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.customerLoginLabel.alpha = 1.0;
                             self.driverLoginLabel.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                         }];
        [UIView animateWithDuration:0.75
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.drinksLabel setFont:[UIFont fontWithName:@"Optima" size:45]];
                             self.drinksLabel.text = @"DRINKS";
                             [self.drinksLabel sizeToFit];
                             self.drinksLabel.transform = CGAffineTransformMakeTranslation(0, 150);
                             [self.backgroundImage setFrame:CGRectMake(self.backgroundImage.bounds.origin.x-55, self.backgroundImage.bounds.origin.y, (self.view.bounds.size.width/2)+55, self.view.bounds.size.height)];
                             [self.carLoginImage setFrame:CGRectMake(self.view.bounds.size.width/2, self.carLoginImage.bounds.origin.y, (self.view.bounds.size.width/2)+55, self.view.bounds.size.height)];
                             self.backButton.alpha = 0.0;
                             self.usernameView.alpha = 0.0;
                             self.passwordView.alpha = 0.0;
                             self.loginButtonView.alpha = 0.0;
                             self.notAMemberLabel.alpha = 0.0;
                             self.signUpButton.alpha = 0.0;
                             self.forgotPasswordButton.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             self.backButton.hidden = YES;
                             self.usernameView.hidden = YES;
                             self.passwordView.hidden = YES;
                             self.loginButtonView.hidden = YES;
                             self.notAMemberLabel.hidden = YES;
                             self.signUpButton.hidden = YES;
                             self.forgotPasswordButton.hidden = YES;
                         }];
        self.customerLoginButton.hidden = NO;
        self.driverLoginButton.hidden = NO;
    } else {
        self.driversLicenseImageView.hidden = YES;
        self.addDriversLicenseButton.hidden = YES;
        self.usernameTextField.text = @"";
        self.passwordTextField.text= @"";
        self.nameTextField.text = @"";
        self.emailTextField.text= @"";
        self.phoneTextField.text = @"";
        self.addressTextField.text= @"";
        self.birthdateTextField.text = @"";
        self.profileImageView.image = [UIImage imageNamed:@"profileIcon"];
        self.driversLicenseImageView.image = [UIImage imageNamed:@"fakeId"];
        [self.addDriversLicenseButton setTitle:@"Add Drivers License" forState:UIControlStateNormal];
        [self.addProfilePhotoButton setTitle:@"Add Profile Photo" forState:UIControlStateNormal];
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
                             self.addProfilePhotoButton.alpha = 0.0;
                             self.nameView.alpha = 0.0;
                             self.emailView.alpha = 0.0;
                             self.phoneView.alpha = 0.0;
                             self.addressView.alpha = 0.0;
                             self.birthdateView.alpha = 0.0;
                             
                         }
                         completion:^(BOOL finished){
                             self.profileImageView.hidden = YES;
                             self.addProfilePhotoButton.hidden = YES;
                             self.nameView.hidden = YES;
                             self.emailView.hidden = YES;
                             self.phoneView.hidden = YES;
                             self.addressView.hidden = YES;
                             self.birthdateView.hidden = YES;
                         }];
        [UIView animateWithDuration:0.75
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.drinksLabel.transform = CGAffineTransformIdentity;
                             self.loginButtonView.transform = CGAffineTransformIdentity;
                             self.signUpScrollView.contentSize = CGSizeMake(375, 667);
                             self.notAMemberLabel.alpha = 1.0;
                             self.signUpButton.alpha = 1.0;
                             self.forgotPasswordButton.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                         }];

    }
}
- (IBAction)customerLoginAction:(id)sender {
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"CUSTOMER" forKey:@"userPool"];
    [defaults synchronize];
    loginType = @"CUSTOMER";
    self.notAMemberLabel.alpha = 0.0;
    self.signUpButton.alpha = 0.0;
    self.forgotPasswordButton.alpha = 0.0;
    self.notAMemberLabel.hidden = NO;
    self.signUpButton.hidden = NO;
    self.forgotPasswordButton.hidden = NO;
    self.usernameView.alpha = 0.0;
    self.passwordView.alpha = 0.0;
    self.loginButtonView.alpha = 0.0;
    self.usernameView.hidden = NO;
    self.passwordView.hidden = NO;
    self.loginButtonView.hidden = NO;
    self.customerLoginButton.hidden = YES;
    self.driverLoginButton.hidden = YES;
    self.backButton.alpha = 0.0;
    self.backButton.hidden = NO;

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.customerLoginLabel.alpha = 0.0;
                         self.driverLoginLabel.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         self.customerLoginLabel.hidden = YES;
                         self.driverLoginLabel.hidden = YES;
                     }];
    
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.drinksLabel setFont:[UIFont fontWithName:@"Optima" size:27]];
                         self.drinksLabel.text = @"DRINKS\nCUSTOMER";
                         [self.drinksLabel sizeToFit];
                         self.drinksLabel.transform = CGAffineTransformIdentity;
                         self.backgroundImage.transform = CGAffineTransformMakeTranslation(55, 0);
                         self.backgroundImage.frame = self.view.frame;
                         self.carLoginImage.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width/2, 0);
                         self.backButton.alpha = 1.0;
                         self.usernameView.alpha = 0.75;
                         self.passwordView.alpha = 0.75;
                         self.loginButtonView.alpha = 1.0;
                         self.notAMemberLabel.alpha = 1.0;
                         self.signUpButton.alpha = 1.0;
                         self.forgotPasswordButton.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                     }];

}

- (IBAction)driverLoginAction:(id)sender {
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
    
    AWSCognitoIdentityUserPoolConfiguration *driverConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7abpokft5to0bnmbpordu8ou7r"  clientSecret:@"lo4l2ui4oggikjfqo6afgo5mv4u1839jvsikrot5uh1rksf1ad2" poolId:@"us-east-1_KpiGHtI7M"];
    
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:driverConfiguration forKey:@"DrinksDriverPool"];
    
    AWSCognitoIdentityUserPool *driverPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksDriverPool"];
    driverPool.delegate = self;
    if([[driverPool currentUser] getSession].result != nil) {
        [[driverPool currentUser] signOut];
    }
    [[driverPool getUser] getSession];
    loginType = @"DRIVER";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"DRIVER" forKey:@"userPool"];
    [defaults synchronize];
    self.notAMemberLabel.alpha = 0.0;
    self.signUpButton.alpha = 0.0;
    self.forgotPasswordButton.alpha = 0.0;
    self.notAMemberLabel.hidden = NO;
    self.signUpButton.hidden = NO;
    self.forgotPasswordButton.hidden = NO;
    self.usernameView.alpha = 0.0;
    self.passwordView.alpha = 0.0;
    self.loginButtonView.alpha = 0.0;
    self.usernameView.hidden = NO;
    self.passwordView.hidden = NO;
    self.loginButtonView.hidden = NO;
    self.customerLoginButton.hidden = YES;
    self.driverLoginButton.hidden = YES;
    self.backButton.alpha = 0.0;
    self.backButton.hidden = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.customerLoginLabel.alpha = 0.0;
                         self.driverLoginLabel.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         self.customerLoginLabel.hidden = YES;
                         self.driverLoginLabel.hidden = YES;
                     }];
    
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.drinksLabel setFont:[UIFont fontWithName:@"Optima" size:27]];
                         self.drinksLabel.text = @"DRINKS\nDRIVER";
                         [self.drinksLabel sizeToFit];
                         self.drinksLabel.transform = CGAffineTransformIdentity;
                         self.carLoginImage.transform = CGAffineTransformMakeTranslation(-(self.view.bounds.size.width/2), 0);
                         self.carLoginImage.frame = self.view.frame;
                         self.backgroundImage.transform = CGAffineTransformMakeTranslation(-(self.view.bounds.size.width/2), 0);
                         self.backButton.alpha = 1.0;
                         self.usernameView.alpha = 0.75;
                         self.passwordView.alpha = 0.75;
                         self.loginButtonView.alpha = 1.0;
                         self.notAMemberLabel.alpha = 1.0;
                         self.signUpButton.alpha = 1.0;
                         self.forgotPasswordButton.alpha = 1.0;

                     }
                     completion:^(BOOL finished){
                     }];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //Keyboard becomes visible
//    CGPoint point = CGPointMake(0, textField.frame.origin.y) ;
//    [self.signUpScrollView setContentOffset:point animated:YES];   //resize
    CGRect rect = [textField bounds];
    rect = [textField convertRect:rect toView:self.signUpScrollView];
    rect.origin.x = 0 ;
    rect.origin.y -= 60 ;
    rect.size.height = 600;
    [self.signUpScrollView scrollRectToVisible:rect animated:YES];

}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    //keyboard will hide
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    if (profilePhoto) {
        self.profileImageView.image = chosenImage;
        self.profileImageView.layer.cornerRadius = 50;
        self.profileImageView.clipsToBounds = YES;
        [self.addProfilePhotoButton setTitle:@"Retake Profile Photo" forState:UIControlStateNormal];
        [self.addProfilePhotoButton sizeToFit];
    } else {
        self.driversLicenseImageView.image = chosenImage;
        [self.addDriversLicenseButton setTitle:@"Retake Drivers License Photo" forState:UIControlStateNormal];
        [self.addDriversLicenseButton sizeToFit];
    }

    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)addProfilePhotoAction:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:picker animated:YES completion:NULL];
    profilePhoto = YES;
}

- (IBAction)addDriversLicenseAction:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    profilePhoto = NO;
}

- (IBAction)addDriversLicenseTapAction:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    profilePhoto = NO;
    
}

- (IBAction)addProfilePhotoTapAction:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    profilePhoto = YES;
}

@end

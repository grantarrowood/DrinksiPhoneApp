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
    self.passwordAuthenticationCompletion.result = [[AWSCognitoIdentityPasswordAuthenticationDetails alloc] initWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
//    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
//
//    AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
//
//    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"DrinksCustomerPool"];
//    AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
//    AWSCognitoIdentityUserAttributeType * phone = [AWSCognitoIdentityUserAttributeType new];
//    phone.name = @"phone_number";
//    //phone number must be prefixed by country code
//    phone.value = @"+15555555555";
//    AWSCognitoIdentityUserAttributeType * email = [AWSCognitoIdentityUserAttributeType new];
//    email.name = @"email";
//    email.value = @"email@mydomain.com";
//    AWSCognitoIdentityUserAttributeType * birthdate = [AWSCognitoIdentityUserAttributeType new];
//    birthdate.name = @"birthdate";
//    birthdate.value = @"04/18/2000";
//    AWSCognitoIdentityUserAttributeType * address = [AWSCognitoIdentityUserAttributeType new];
//    address.name = @"address";
//    address.value = @"861 Southern Shore Drive, Peachtree City, Georgia";
//    AWSCognitoIdentityUserAttributeType * name = [AWSCognitoIdentityUserAttributeType new];
//    name.name = @"name";
//    name.value = @"Grant";
//    //register the user
//    [[pool signUp:self.usernameTextField.text password:self.passwordTextField.text userAttributes:@[email,phone,birthdate,address,name] validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(task.error){
//                [[[UIAlertView alloc] initWithTitle:task.error.userInfo[@"__type"]
//                                            message:task.error.userInfo[@"message"]
//                                           delegate:self
//                                  cancelButtonTitle:@"Ok"
//                                  otherButtonTitles:nil] show];
//            }else {
//                AWSCognitoIdentityUserPoolSignUpResponse * response = task.result;
//                if(!response.userConfirmed){
//                    //need to confirm user using user.confirmUser:
//                }
//            }});
//        return nil;
//    }];
}
@end

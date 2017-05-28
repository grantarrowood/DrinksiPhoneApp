//
//  ViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 5/24/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.backgroundImage.image = [UIImage imageNamed:@"beerMain"];
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    [self.backgroundImage addSubview:effectView];

    self.storeImageView.image = [self.storeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.bookImageView.image = [self.bookImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.starImangeView.image = [self.starImangeView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.pinImageView.image = [self.pinImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
    
    //create a pool
    AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7ffg3sd7gu2fh3cjfr2ig5j8o8"  clientSecret:@"acilon9h90v9kgc9n831epnpqng8tqsac12po3g31h570ov9qmb" poolId:@"us-east-1_rwnjPpBrw"];
    
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"DrinksCustomerPool"];
    
    AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksCustomerPool"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"currentUsername"];
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
                        self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@", attribute.value];
                    }
                }
            }
        });
        return nil;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

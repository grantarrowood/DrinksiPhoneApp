//
//  DriverMainViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/16/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "DriverMainViewController.h"

@interface DriverMainViewController ()

@end

@implementation DriverMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.backgroundImage.image = [UIImage imageNamed:@"carLogin"];
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    effectView.alpha = 0.9;
    [self.backgroundImage addSubview:effectView];
    self.storeImageView.image = [self.storeImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.bookImageView.image = [self.bookImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.starImageView.image = [self.starImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.personImageView.image = [self.personImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
    
    AWSCognitoIdentityUserPoolConfiguration *driverConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:@"7abpokft5to0bnmbpordu8ou7r"  clientSecret:@"lo4l2ui4oggikjfqo6afgo5mv4u1839jvsikrot5uh1rksf1ad2" poolId:@"us-east-1_KpiGHtI7M"];
    
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:driverConfiguration forKey:@"DrinksDriverPool"];
    
    AWSCognitoIdentityUserPool *driverPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"DrinksDriverPool"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"currentUsername"];
    [[[driverPool getUser:username] getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
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
                        //NSLog(@"Attribute: %@ Value: %@", attribute.name, attribute.value);
                    if ([attribute.name isEqualToString:@"name"]) {
                        self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@", attribute.value];
                    } else if([attribute.name isEqualToString:@"custom:profilePicture"]) {
                        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                                                                                                                       identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
                                                                              
                        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
                                                                                                       
                        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;

                        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
                        
                        NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:attribute.value];
                        NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                        
                        AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                        
                        downloadRequest.bucket = @"drinksprofilepictures";
                        downloadRequest.key = attribute.value;
                        downloadRequest.downloadingFileURL = downloadingFileURL;
                        [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
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
                                                                                       self.profilePictureImage.image = [UIImage imageWithContentsOfFile:downloadingFilePath];
                                                                                       self.profilePictureImage.layer.cornerRadius = 37.5;
                                                                                       self.profilePictureImage.clipsToBounds = YES;
                                                                                   }
                                                                                   return nil;
                                                                               }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

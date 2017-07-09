//
//  ServingAtViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/30/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "ServingAtViewController.h"

@interface ServingAtViewController ()

@end

@implementation ServingAtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inAppNotification:)
                                                 name:@"InAppNotification"
                                               object:nil];
    _notification = [[AFDropdownNotification alloc] init];
    _notification.notificationDelegate = self;

    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.campusImageView.image = [UIImage imageNamed:@"campusImage"];
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.alpha = 0.88;
    effectView.frame = self.view.frame;
    [self.campusImageView addSubview:effectView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)inAppNotification:(NSNotification*)sender {
    // Perform action here
    _notification.titleText = @"DRINKS";
    _notification.subtitleText = [[sender object] valueForKey:@"message"];
    _notification.image = [UIImage imageNamed:@"profileIcon"];
    _notification.topButtonText = @"Accept";
    _notification.bottomButtonText = @"Cancel";
    _notification.dismissOnTap = YES;
    [_notification presentInView:self.view withGravityAnimation:YES];
    
    [_notification listenEventsWithBlock:^(AFDropdownNotificationEvent event) {
        
        switch (event) {
            case AFDropdownNotificationEventTopButton:
                // Top button
                break;
                
            case AFDropdownNotificationEventBottomButton:
                // Bottom button
                break;
                
            case AFDropdownNotificationEventTap:
                // Tap
                break;
                
            default:
                break;
        }
    }];
    
    NSLog(@"show notification");
    
    
}

-(void)dropdownNotificationTopButtonTapped {
    
    NSLog(@"Top button tapped");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Top button tapped" message:@"Hooray! You tapped the top button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [_notification dismissWithGravityAnimation:YES];
}

-(void)dropdownNotificationBottomButtonTapped {
    
    NSLog(@"Bottom button tapped");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bottom button tapped" message:@"Hooray! You tapped the bottom button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [_notification dismissWithGravityAnimation:YES];
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

//
//  ServingAtViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/30/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "AFDropdownNotification.h"

@interface ServingAtViewController : UIViewController <AFDropdownNotificationDelegate>

@property (nonatomic, strong) AFDropdownNotification *notification;

@property (weak, nonatomic) IBOutlet UIImageView *campusImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

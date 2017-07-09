//
//  FAQTableViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/20/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "AFDropdownNotification.h"

@interface FAQTableViewController : UITableViewController <AFDropdownNotificationDelegate>
@property (nonatomic, strong) AFDropdownNotification *notification;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

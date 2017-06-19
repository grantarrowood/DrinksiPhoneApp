//
//  OrderNowTableViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 5/27/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Locations.h"
#import "Areas.h"
#import "MenuItems.h"
#import "Orders.h"


@interface OrderNowTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *allLocations;
    NSMutableArray *allAreas;
    NSMutableArray *allMenuItems;
    NSMutableArray *selectedMenuItems;
    NSString *orderString;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

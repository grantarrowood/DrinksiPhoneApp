//
//  AvailableOrdersTableViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/17/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Locations.h"
#import "Areas.h"
#import "MenuItems.h"
#import "Orders.h"
#import "OrderDetailsTableViewController.h"

@interface AvailableOrdersTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *ordersArray;
    NSTimer *timer;
    NSNumber *orderNumSelected;
    
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

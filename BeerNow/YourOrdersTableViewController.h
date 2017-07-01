//
//  YourOrdersTableViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/19/17.
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
#import <CoreLocation/CoreLocation.h>


@interface YourOrdersTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate> {
    
    NSMutableArray *currentOrdersArray;
    NSMutableArray *pastOrdersArray;
    NSTimer *timer;
    NSNumber *orderNumSelected;
    CLLocationManager *locationManager;
    CLLocation *currentLoc;
    NSMutableArray *locationsArray;
    NSMutableArray *distanceAwayArray;
    UIActivityIndicatorView *spinner;
    UIView *greyView;
    
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

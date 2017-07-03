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
#import <CoreLocation/CoreLocation.h>
#import "PaySequencePopoverViewController.h"


@interface OrderNowTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, PayDelegate, UIPopoverPresentationControllerDelegate> {
    NSMutableArray *allLocations;
    NSMutableArray *allAreas;
    NSMutableArray *allMenuItems;
    NSMutableArray *selectedMenuItems;
    NSString *orderString;
    NSString *selectedArea;
    Areas *selectedAreaObject;
    Locations *selectedLocationObject;
    CLLocationManager *locationManager;
    CLLocation *currentLoc;
    NSMutableArray *orderItems;
    NSNumber *orderId;
}

@property (strong) NSString *selectedAddress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

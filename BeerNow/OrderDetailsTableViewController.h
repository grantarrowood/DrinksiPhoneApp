//
//  OrderDetailsTableViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/18/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Orders.h"
#import "Locations.h"
#import "ItemTableViewCell.h"
#import "DetailTableViewCell.h"
#import <CoreLocation/CoreLocation.h>

@interface OrderDetailsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, AWSCognitoIdentityPasswordAuthentication, AWSCognitoIdentityInteractiveAuthenticationDelegate, CLLocationManagerDelegate> {
    NSMutableArray *orderItems;
    NSTimer *timerTwo;
    NSTimer *timer;
    NSString *driverUsername;
    NSString *driverName;
    NSString *customerUsername;
    NSString *customerName;
    NSString *customerAddress;
    NSString *locationName;
    NSString *locationAddress;
    NSString *isPaid;
    UIActivityIndicatorView *spinner;
    UIView *greyView;
    double deliveryFee;
    CLLocationManager *locationManager;
    CLLocation *currentLoc;
}

@property (strong) NSNumber *orderId;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails*>* passwordAuthenticationCompletion;

@end

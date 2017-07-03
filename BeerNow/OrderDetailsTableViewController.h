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
#import "Transactions.h"
#import "Locations.h"
#import "ItemTableViewCell.h"
#import "DetailTableViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import "PaySequencePopoverViewController.h"
#import "AWSCognitoIdentityProviderService.h"
#import <AWSS3/AWSS3.h>
#import "CustomerLicenseTableViewCell.h"
#import "DriverAcceptOrderViewController.h"

@interface OrderDetailsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, AWSCognitoIdentityPasswordAuthentication, AWSCognitoIdentityInteractiveAuthenticationDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, PayDelegate, AcceptDelegate> {
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
    NSString *orderStatus;
    UIActivityIndicatorView *spinner;
    UIView *greyView;
    double deliveryFee;
    CLLocationManager *locationManager;
    CLLocation *currentLoc;
    CLLocation *restaurantLoc;
    UIImage *customerDriversLicense;
    NSString *driverStripeId;
    NSNumber *transactionId;
    NSString *stripeTransactionId;
}

@property (strong) NSNumber *orderId;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails*>* passwordAuthenticationCompletion;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButton;
- (IBAction)backAction:(id)sender;

@end

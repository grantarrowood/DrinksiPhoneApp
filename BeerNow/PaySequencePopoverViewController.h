//
//  PaySequencePopoverViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/19/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import <AWSLambda/AWSLambda.h>
#import "Orders.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Transactions.h"
#import <Stripe/Stripe.h>
#import <AWSS3/AWSS3.h>
#import "PromoCodes.h"


@protocol PayDelegate <NSObject>
-(void)payViewControllerDismissed:(NSString *)paid;
@end

@interface PaySequencePopoverViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PKPaymentAuthorizationViewControllerDelegate> {
    NSTimer *timer;
    NSNumber *total;
    bool paymentSuccess;
    NSString *transactionResultId;
    NSNumber *transactionId;
    NSString *promoCodeType;

}

@property (strong) NSMutableArray *orderDetails;
@property (strong) NSNumber *orderId;
@property (strong) NSString *driverStripeId;
@property (nonatomic, assign) id<PayDelegate> payDelegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *canelBarButton;
- (IBAction)cancelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UITextView *termsAndConditionsTextView;
@property (weak, nonatomic) IBOutlet UISwitch *termsAndConditionsSwitch;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIButton *applePayButton;
- (IBAction)applePayAction:(id)sender;

@end

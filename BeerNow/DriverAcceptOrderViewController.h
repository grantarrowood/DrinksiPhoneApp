//
//  DriverAcceptOrderViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/28/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <MicroBlink/MicroBlink.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Transactions.h"
#import "Orders.h"
#import <AWSS3/AWSS3.h>


@protocol AcceptDelegate <NSObject>
-(void)acceptViewControllerDismissed:(NSString *)accepted;
@end

@interface DriverAcceptOrderViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PPScanningDelegate>
{
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    int matches;
    UIAlertView *matchesAlertView;
    UIAlertView *infoAlertView;
}
-(void)drawPageNbr:(int)pageNumber;
-(CFRange*)updatePDFPage:(int)pageNumber setTextRange:(CFRange*)pageRange setFramesetter:(CTFramesetterRef*)framesetter;


@property (weak, nonatomic) IBOutlet UIScrollView *recieptScrollView;
@property (strong) NSMutableArray *orderDetails;
@property (strong) NSNumber *transactionId;
@property (strong) NSNumber *orderId;
@property (nonatomic, assign) id<AcceptDelegate> acceptDelegate;


@property (weak, nonatomic) IBOutlet UIView *signatureView;
@property (weak, nonatomic) IBOutlet UIImageView *signatureImageView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

- (IBAction)cancelAction:(id)sender;
- (IBAction)acceptDeliveryAction:(id)sender;

@end

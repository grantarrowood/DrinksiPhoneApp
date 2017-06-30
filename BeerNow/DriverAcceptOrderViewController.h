//
//  DriverAcceptOrderViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/28/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MicroBlink/MicroBlink.h>

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

@property (strong) NSMutableArray *orderDetails;
@property (weak, nonatomic) IBOutlet UIView *signatureView;
@property (weak, nonatomic) IBOutlet UIImageView *signatureImageView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;


- (IBAction)cancelAction:(id)sender;

@end

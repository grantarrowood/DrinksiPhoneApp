//
//  PaySequencePopoverViewController.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/19/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>

@interface PaySequencePopoverViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PKPaymentAuthorizationViewControllerDelegate> {
    NSTimer *timer;
}
@property (strong) NSMutableArray *orderDetails;

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

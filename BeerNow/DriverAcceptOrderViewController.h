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

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

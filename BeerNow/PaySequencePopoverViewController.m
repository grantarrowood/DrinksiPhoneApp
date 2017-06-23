//
//  PaySequencePopoverViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/19/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "PaySequencePopoverViewController.h"

@interface PaySequencePopoverViewController ()

@end

@implementation PaySequencePopoverViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.imageView.hidden = YES;
//    if (self.imageView.image == nil) {
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.allowsEditing = YES;
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        
//        [self presentViewController:picker animated:YES completion:NULL];
//    }
    double total = 0.0;
    for (int i = 0; i<_orderDetails.count; i++) {
        total += [[_orderDetails objectAtIndex:i][1] floatValue];
    }
    self.totalLabel.text = [NSString stringWithFormat:@"%.2f", total];
    [self.totalLabel sizeToFit];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideDetailView) userInfo:nil repeats:YES];

}
-(void)hideDetailView {
    [timer invalidate];
    self.detailView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.hidden = YES;
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.navigationItem.title = @"Step 2: Review Terms and Pay Now";
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)applePayAction:(id)sender {
    if (![self.termsAndConditionsSwitch isOn]) {
        NSLog(@"NOT ENABLED");
    } else {
        if([PKPaymentAuthorizationViewController canMakePayments]) {
            PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
            request.countryCode = @"US";
            request.currencyCode = @"USD";
            request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
            request.merchantCapabilities = PKMerchantCapabilityEMV;
            request.merchantIdentifier = @"merchant.com.drinks.pigletproducts";
            NSMutableArray *itemArray = [[NSMutableArray alloc] init];
            double total = 0.0;
            for (int i = 0; i<_orderDetails.count; i++) {
                PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:[_orderDetails objectAtIndex:i][0] amount:[NSDecimalNumber decimalNumberWithString:[_orderDetails objectAtIndex:i][1]]];
                [itemArray addObject:item];
                total += [[_orderDetails objectAtIndex:i][1] floatValue];
            }
            PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[[NSDecimalNumber alloc] initWithDouble:total]];
            [itemArray addObject:item];
            request.paymentSummaryItems = itemArray;
            PKPaymentAuthorizationViewController *paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
            paymentPane.delegate = self;
            [self presentViewController:paymentPane animated:YES completion:nil];
        }
    }
}


- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
}

@end

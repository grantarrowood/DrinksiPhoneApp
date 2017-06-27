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
    paymentSuccess = NO;
    self.imageView.hidden = YES;
    [self fetchClientToken];
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
            total = [[NSNumber alloc] init];
            for (int i = 0; i<_orderDetails.count; i++) {
                PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:[_orderDetails objectAtIndex:i][0] amount:[NSDecimalNumber decimalNumberWithString:[_orderDetails objectAtIndex:i][1]]];
                [itemArray addObject:item];
                total = [NSNumber numberWithFloat:([total floatValue] + [[_orderDetails objectAtIndex:i][1] floatValue])];;
            }
            PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[[NSDecimalNumber alloc] initWithDouble:[total doubleValue]]];
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
    if (paymentSuccess) {
        //SET PAID TO YES AND SET TRANSACTION
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {

    BTApplePayClient *applePayClient = [[BTApplePayClient alloc]
                                        initWithAPIClient:self.braintreeClient];
    [applePayClient tokenizeApplePayPayment:payment
                                 completion:^(BTApplePayCardNonce *tokenizedApplePayPayment,
                                              NSError *error) {
                                     if (tokenizedApplePayPayment) {
                                         // On success, send nonce to your server for processing.
                                         AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
                                         
                                         [[lambdaInvoker invokeFunction:@"drinksApplePayPaymentProcessing"
                                                             JSONObject:@{@"nonce" : tokenizedApplePayPayment.nonce,
                                                                          @"amount" : total}] continueWithBlock:^id(AWSTask *task) {
                                             if (task.error) {
                                                 NSLog(@"Error: %@", task.error);
                                                 if ([task.error.domain isEqualToString:AWSLambdaInvokerErrorDomain]
                                                     && task.error.code == AWSLambdaInvokerErrorTypeFunctionError) {
                                                     NSLog(@"Function error: %@", task.error.userInfo[AWSLambdaInvokerFunctionErrorKey]);
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                     paymentSuccess = NO;
                                                 }
                                             }
                                             if (task.result) {
                                                 NSDictionary *JSONObject = task.result;
                                                 NSLog(@"result: %@", JSONObject[@"success"]);
                                                 if ([JSONObject[@"success"] isEqual: @1]) {
                                                     NSLog(@"SUCCESS");
                                                     paymentSuccess = YES;
                                                     transactionResult = task.result;
                                                     completion(PKPaymentAuthorizationStatusSuccess);
                                                 } else {
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                     NSLog(@"FAILURE");
                                                     paymentSuccess = NO;

                                                 }
                                                 
                                             }
                                             // Handle response
                                             return nil;
                                         }];

                                         // If applicable, address information is accessible in `payment`.
                                         NSLog(@"nonce = %@", tokenizedApplePayPayment.nonce);
                                         
                                         // Then indicate success or failure via the completion callback, e.g.
                                     } else {
                                         // Tokenization failed. Check `error` for the cause of the failure.
                                         
                                         // Indicate failure via the completion callback:
                                         completion(PKPaymentAuthorizationStatusFailure);
                                         paymentSuccess = NO;
                                     }
                                 }];
}

- (void)fetchClientToken {
    
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    
    [[lambdaInvoker invokeFunction:@"drinksGetClientToken"
                        JSONObject:@{}] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error);
            if ([task.error.domain isEqualToString:AWSLambdaInvokerErrorDomain]
                && task.error.code == AWSLambdaInvokerErrorTypeFunctionError) {
                NSLog(@"Function error: %@", task.error.userInfo[AWSLambdaInvokerFunctionErrorKey]);
            }
        }
        if (task.result) {
            NSLog(@"Result: %@", task.result);
            self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:task.result];
        }
        // Handle response
        return nil;
    }];
}

@end

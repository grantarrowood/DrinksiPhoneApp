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
@synthesize payDelegate;

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    paymentSuccess = NO;
    self.imageView.hidden = YES;
    self.imageView.image = [UIImage imageNamed:@"campusImage"];
//    if (self.imageView.image == nil) {
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.allowsEditing = YES;
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        
//        [self presentViewController:picker animated:YES completion:NULL];
//    }
    total = [[NSNumber alloc] init];
    for (int i = 0; i<_orderDetails.count; i++) {
        total = [NSNumber numberWithFloat:([total floatValue] + [[_orderDetails objectAtIndex:i][1] floatValue])];
    }
    self.totalLabel.text = [NSString stringWithFormat:@"%.2f", [total doubleValue]];
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
            for (int i = 0; i<_orderDetails.count; i++) {
                PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:[_orderDetails objectAtIndex:i][0] amount:[NSDecimalNumber decimalNumberWithString:[_orderDetails objectAtIndex:i][1]]];
                [itemArray addObject:item];
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:@"currentUsername"];
        //SET PAID TO YES AND SET TRANSACTION
        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                        identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
        AWSServiceConfiguration *s3configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
        
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = s3configuration;

        Orders *newOrder = [Orders new];
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
        
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
        transactionId = [[NSNumber alloc] init];
        Transactions *newTransaction = [Transactions new];
        newTransaction.transactionResult = transactionResultId;
        newTransaction.date = [NSString stringWithFormat:@"%@", [NSDate date]];
        newTransaction.scannedCustomerLicenseInfo = @"INCOMPLETE";
        [[[dynamoDBObjectMapper scan:[Transactions class]
                         expression:scanExpression]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
             } else {
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 NSNumber *highestNumber = @0;
                 for (Transactions *transaction in paginatedOutput.items) {
                     //Do something with book.
                     if (transaction.TransactionId > highestNumber) {
                         highestNumber = transaction.TransactionId;
                     }
                 }
                 int value = [highestNumber intValue];
                 newTransaction.TransactionId = [NSNumber numberWithInt:value + 1];
                 transactionId = [NSNumber numberWithInt:value + 1];
             }
             return nil;
         }] waitUntilFinished];
        
        [[[dynamoDBObjectMapper save:newTransaction]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
             } else {
                 //Do something with task.result or perform other operations.
             }
             return nil;
         }] waitUntilFinished];
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        NSData *pngData = UIImagePNGRepresentation(self.imageView.image);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_CUSTOMERDRIVERSLICENSE_%@.jpg", username,transactionId]];
        [pngData writeToFile:filePath atomically:YES];
        NSURL *uploadingFileURL = [NSURL fileURLWithPath:filePath];
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = @"drinkscustomerdriverslicense";
        uploadRequest.key = [NSString stringWithFormat:@"%@_CUSTOMERDRIVERSLICENSE_%@.jpg", username,transactionId];
        uploadRequest.body = uploadingFileURL;
        [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error) {
                                                                   if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                       switch (task.error.code) {
                                                                           case AWSS3TransferManagerErrorCancelled:
                                                                           case AWSS3TransferManagerErrorPaused:
                                                                               break;
                                                                               
                                                                           default:
                                                                               NSLog(@"Error: %@", task.error);
                                                                               break;
                                                                       }
                                                                   } else {
                                                                       // Unknown error.
                                                                       NSLog(@"Error: %@", task.error);
                                                                   }
                                                               }
                                                               
                                                               if (task.result) {
                                                                   AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                                   // The file uploaded successfully.
                                                               }
                                                               return nil;
                                                           }];

        AWSDynamoDBObjectMapper *dynamoDBObjectMapperOrder = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        AWSDynamoDBScanExpression *scanExpressionOrder = [AWSDynamoDBScanExpression new];
        
        [[[dynamoDBObjectMapperOrder scan:[Orders class]
                         expression:scanExpressionOrder]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
             } else {
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (Orders *order in paginatedOutput.items) {
                     if (order.OrderId == _orderId) {
                         newOrder.Area = order.Area;
                         newOrder.Location = order.Location;
                         newOrder.Order = order.Order;
                         newOrder.customerUsername = order.customerUsername;
                         newOrder.OrderId = _orderId;
                         newOrder.AcceptedDelivery = @"NO";
                         newOrder.DeliveryDate = @"UNKNOWN";
                         newOrder.driverUsername = order.driverUsername;
                         newOrder.paid = @"YES";
                         newOrder.transactionId = transactionId;
                         [[dynamoDBObjectMapper save:newOrder]
                          continueWithBlock:^id(AWSTask *task) {
                              if (task.error) {
                                  NSLog(@"The request failed. Error: [%@]", task.error);
                              } else {
                                  //Do something with task.result or perform other operations.
                              }
                              return nil;
                          }];
                     }
                 }
             }
             return nil;
         }] waitUntilFinished];
        
        [self.payDelegate payViewControllerDismissed:@"YES"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {

//    BTApplePayClient *applePayClient = [[BTApplePayClient alloc]
//                                        initWithAPIClient:self.braintreeClient];
//    [applePayClient tokenizeApplePayPayment:payment
//                                 completion:^(BTApplePayCardNonce *tokenizedApplePayPayment,
//                                              NSError *error) {
//                                     if (tokenizedApplePayPayment) {
//                                         // On success, send nonce to your server for processing.
//                                         AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
//                                         
//                                         [[lambdaInvoker invokeFunction:@"drinksApplePayPaymentProcessing"
//                                                             JSONObject:@{@"nonce" : tokenizedApplePayPayment.nonce,
//                                                                          @"amount" : total}] continueWithBlock:^id(AWSTask *task) {
//                                             if (task.error) {
//                                                 NSLog(@"Error: %@", task.error);
//                                                 if ([task.error.domain isEqualToString:AWSLambdaInvokerErrorDomain]
//                                                     && task.error.code == AWSLambdaInvokerErrorTypeFunctionError) {
//                                                     NSLog(@"Function error: %@", task.error.userInfo[AWSLambdaInvokerFunctionErrorKey]);
//                                                     completion(PKPaymentAuthorizationStatusFailure);
//                                                     paymentSuccess = NO;
//                                                 }
//                                             }
//                                             if (task.result) {
//                                                 NSDictionary *JSONObject = task.result;
//                                                 NSLog(@"result: %@", JSONObject[@"success"]);
//                                                 if ([JSONObject[@"success"] isEqual: @1]) {
//                                                     NSLog(@"SUCCESS");
//                                                     paymentSuccess = YES;
//                                                     transactionResult = task.result;
//                                                     completion(PKPaymentAuthorizationStatusSuccess);
//                                                 } else {
//                                                     completion(PKPaymentAuthorizationStatusFailure);
//                                                     NSLog(@"FAILURE");
//                                                     paymentSuccess = NO;
//                                                 }
//                                                 
//                                             }
//                                             // Handle response
//                                             return nil;
//                                         }];
//
//                                         // If applicable, address information is accessible in `payment`.
//                                         NSLog(@"nonce = %@", tokenizedApplePayPayment.nonce);
//                                         
//                                         // Then indicate success or failure via the completion callback, e.g.
//                                     } else {
//                                         // Tokenization failed. Check `error` for the cause of the failure.
//                                         
//                                         // Indicate failure via the completion callback:
//                                         completion(PKPaymentAuthorizationStatusFailure);
//                                         paymentSuccess = NO;
//                                     }
//                                 }];
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken *token, NSError *error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure);
            return;
        }
        [self createBackendChargeWithToken:token completion:completion];
    }];
}

- (void)createBackendChargeWithToken:(STPToken *)token completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    //We are printing Stripe token here, you can charge the Credit Card using this token from your backend.
    NSLog(@"Stripe Token is %@",token);
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSNumber *totalCents = [NSNumber numberWithInteger:([total floatValue] * 100)];

    [[lambdaInvoker invokeFunction:@"drinksApplePayPaymentProcessing"
                         JSONObject:@{@"token" : token.tokenId,
                                      @"amount" : totalCents,
                                      @"driverStripeId" : _driverStripeId}] continueWithBlock:^id(AWSTask *task) {
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
             NSLog(@"result: %@", JSONObject[@"paid"]);
             if ([JSONObject[@"paid"] isEqual: @1]) {
                 NSLog(@"SUCCESS");
                 paymentSuccess = YES;
                 transactionResultId = JSONObject[@"id"];
                 completion(PKPaymentAuthorizationStatusSuccess);
             } else {
                 completion(PKPaymentAuthorizationStatusFailure);
                 NSLog(@"FAILURE");
                 paymentSuccess = NO;
             }
//             NSLog(@"%@", task.result);
//             completion(PKPaymentAuthorizationStatusSuccess);

         }
         // Handle response
         return nil;
     }];

}


/*
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
*/
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}
@end

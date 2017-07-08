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
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    Orders *orderToCancel = [Orders new];
    orderToCancel.OrderId = _orderId;
    
    [[[dynamoDBObjectMapper remove:orderToCancel]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         } else {
             //Item deleted.
         }
         return nil;
     }] waitUntilFinished];
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
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Promo Code" message:@"Do you have a promo code?" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"code";
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleNone;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
            
            AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
            
            AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
            AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
            
            AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
            PromoCodes *codeUsed = [PromoCodes new];
            [[[dynamoDBObjectMapper scan:[PromoCodes class]
                              expression:scanExpression]
              continueWithBlock:^id(AWSTask *task) {
                  if (task.error) {
                      NSLog(@"The request failed. Error: [%@]", task.error);
                  } else {
                      AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                      for (PromoCodes *promoCode in paginatedOutput.items) {
                          //Do something with book.
                          if([promoCode.PromoCode isEqualToString:alertController.textFields[0].text]) {
                              codeUsed.CodeId = promoCode.CodeId;
                              codeUsed.Used = @"YES";
                              codeUsed.PromoCode  = promoCode.PromoCode;
                              codeUsed.UsedBy = @"1 Person";
                              codeUsed.CodeType = promoCode.CodeType;
                              promoCodeType = promoCode.CodeType;
                          }
                      }
                  }
                  return nil;
              }] waitUntilFinished];
            if (codeUsed.Used != nil) {
                [[[dynamoDBObjectMapper save:codeUsed]
                  continueWithBlock:^id(AWSTask *task) {
                      if (task.error) {
                          NSLog(@"The request failed. Error: [%@]", task.error);
                      } else {
                          //Do something with task.result or perform other operations.
                      }
                      return nil;
                  }] waitUntilFinished];
                [alertController dismissViewControllerAnimated:YES completion:nil];
                if ([promoCodeType isEqualToString:@"10% Off"]) {
                    if([PKPaymentAuthorizationViewController canMakePayments]) {
                        if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]])  {
                            PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
                            request.countryCode = @"US";
                            request.currencyCode = @"USD";
                            request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
                            request.merchantCapabilities = PKMerchantCapabilityEMV | PKMerchantCapability3DS;
                            request.merchantIdentifier = @"merchant.com.drinksapp.pigletproducts";
                            NSMutableArray *itemArray = [[NSMutableArray alloc] init];
                            for (int i = 0; i<_orderDetails.count; i++) {
                                PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:[_orderDetails objectAtIndex:i][0] amount:[NSDecimalNumber decimalNumberWithString:[_orderDetails objectAtIndex:i][1]]];
                                [itemArray addObject:item];
                            }
                            total = [NSNumber numberWithFloat:([total floatValue] - 1.20)];
                            PKPaymentSummaryItem *discount = [PKPaymentSummaryItem summaryItemWithLabel:@"Discount" amount:[NSDecimalNumber decimalNumberWithString:@"-1.20"]];
                            [itemArray addObject:discount];
                            PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[[NSDecimalNumber alloc] initWithDouble:[total doubleValue]]];
                            [itemArray addObject:item];
                            request.paymentSummaryItems = itemArray;
                            PKPaymentAuthorizationViewController *paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
                            paymentPane.delegate = self;
                            if ([Stripe canSubmitPaymentRequest:request]) {
                                [self presentViewController:paymentPane animated:YES completion:nil];
                            } else {
                                NSLog(@"cannont submit request");
                            }
                        } else {
                            NSLog(@"NO PAYMENT");
                        }
                    } else {
                        NSLog(@"NO PAYMENTS");
                    }

                } else if ([promoCodeType isEqualToString:@"Free Service"]){
                    if([PKPaymentAuthorizationViewController canMakePayments]) {
                        if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]])  {
                            PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
                            request.countryCode = @"US";
                            request.currencyCode = @"USD";
                            request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
                            request.merchantCapabilities = PKMerchantCapabilityEMV | PKMerchantCapability3DS;
                            request.merchantIdentifier = @"merchant.com.drinksapp.pigletproducts";
                            NSMutableArray *itemArray = [[NSMutableArray alloc] init];
                            for (int i = 0; i<_orderDetails.count; i++) {
                                PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:[_orderDetails objectAtIndex:i][0] amount:[NSDecimalNumber decimalNumberWithString:[_orderDetails objectAtIndex:i][1]]];
                                [itemArray addObject:item];
                            }
                            total = [NSNumber numberWithFloat:([total floatValue] - 0.49)];
                            PKPaymentSummaryItem *discount = [PKPaymentSummaryItem summaryItemWithLabel:@"Discount" amount:[NSDecimalNumber decimalNumberWithString:@"-0.49"]];
                            [itemArray addObject:discount];
                            PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[[NSDecimalNumber alloc] initWithDouble:[total doubleValue]]];
                            [itemArray addObject:item];
                            request.paymentSummaryItems = itemArray;
                            PKPaymentAuthorizationViewController *paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
                            paymentPane.delegate = self;
                            if ([Stripe canSubmitPaymentRequest:request]) {
                                [self presentViewController:paymentPane animated:YES completion:nil];
                            } else {
                                NSLog(@"cannont submit request");
                            }
                        } else {
                            NSLog(@"NO PAYMENT");
                        }
                    } else {
                        NSLog(@"NO PAYMENTS");
                    }
                }
            } else {
                [alertController dismissViewControllerAnimated:YES completion:nil];
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Code" message:@"Re-enter your code." preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if([PKPaymentAuthorizationViewController canMakePayments]) {
                if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]])  {
                    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
                    request.countryCode = @"US";
                    request.currencyCode = @"USD";
                    request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
                    request.merchantCapabilities = PKMerchantCapabilityEMV | PKMerchantCapability3DS;
                    request.merchantIdentifier = @"merchant.com.drinksapp.pigletproducts";
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
                    if ([Stripe canSubmitPaymentRequest:request]) {
                        [self presentViewController:paymentPane animated:YES completion:nil];
                    } else {
                        NSLog(@"cannont submit request");
                    }
                } else {
                    NSLog(@"NO PAYMENT");
                }
            } else {
                NSLog(@"NO PAYMENTS");
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
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
        newTransaction.refunded = @"NO";
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
                     if ([order.OrderId isEqualToNumber: _orderId]) {
                         newOrder.CustomerEndpointArn = order.CustomerEndpointArn;
                         newOrder.Area = order.Area;
                         newOrder.Location = order.Location;
                         newOrder.Order = order.Order;
                         newOrder.customerUsername = order.customerUsername;
                         newOrder.OrderId = _orderId;
                         newOrder.AcceptedDelivery = @"NO";
                         newOrder.DeliveryDate = @"UNKNOWN";
                         newOrder.DeliveryAddress = order.DeliveryAddress;
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

    
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken *token, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
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
                                      @"transferGroup" : [_orderId stringValue]
                                      }] continueWithBlock:^id(AWSTask *task) {
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

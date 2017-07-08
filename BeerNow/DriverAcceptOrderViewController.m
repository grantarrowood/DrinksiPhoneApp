//
//  DriverAcceptOrderViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/28/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "DriverAcceptOrderViewController.h"

@interface DriverAcceptOrderViewController ()

@end

@implementation DriverAcceptOrderViewController
@synthesize acceptDelegate;


-(void)viewDidAppear:(BOOL)animated {
    if (matches == 1) {
        int y = 150;
        float total = 0.0;
        for (int i = 0; i < self.orderDetails.count; i++) {
            UILabel *itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, y, 65, 30)];
            itemNameLabel.text = [self.orderDetails objectAtIndex:i][0];
            [self.view addSubview:itemNameLabel];
            UILabel *itemPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, y, 65, 30)];
            itemPriceLabel.text = [self.orderDetails objectAtIndex:i][1];
            [self.view addSubview:itemPriceLabel];
            y += 55;
            total += [[self.orderDetails objectAtIndex:i][1] floatValue];
        }
        UILabel *itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, y, 65, 30)];
        itemNameLabel.text = @"Total:";
        [self.view addSubview:itemNameLabel];
        UILabel *itemPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, y, 65, 30)];
        itemPriceLabel.text = [NSString stringWithFormat:@"%.2f", total];
        [self.view addSubview:itemPriceLabel];
        self.signatureView.layer.borderColor = [UIColor blackColor].CGColor;
        self.signatureView.layer.borderWidth = 1.0f;
        red = 0.0/255.0;
        green = 0.0/255.0;
        blue = 0.0/255.0;
        brush = 2.0;
        opacity = 1.0;
    } else if(matches == 0) {
        /** Instantiate the scanning coordinator */
        NSError *error;
        PPCameraCoordinator *coordinator = [self coordinatorWithError:&error];
        
        /** If scanning isn't supported, present an error */
        if (coordinator == nil) {
            NSString *messageString = [error localizedDescription];
            [[[UIAlertView alloc] initWithTitle:@"Warning"
                                        message:messageString
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil] show];
            
            return;
        }
        
        /** Allocate and present the scanning view controller */
        UIViewController<PPScanningViewController>* scanningViewController = [PPViewControllerFactory cameraViewControllerWithDelegate:self coordinator:coordinator error:nil];
        
        /** You can use other presentation methods as well */
        [self presentViewController:scanningViewController animated:YES completion:nil];
        infoAlertView = [[UIAlertView alloc] initWithTitle:@"Drivers License" message:@"Please scan the barcode on the back of the customer's license." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [infoAlertView show];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * Method allocates and initializes the Scanning coordinator object.
 * Coordinator is initialized with settings for scanning
 * Modify this method to include only those recognizer settings you need. This will give you optimal performance
 *
 *  @param error Error object, if scanning isn't supported
 *
 *  @return initialized coordinator
 */
- (PPCameraCoordinator *)coordinatorWithError:(NSError**)error {
    
    /** 0. Check if scanning is supported */
    
    if ([PPCameraCoordinator isScanningUnsupportedForCameraType:PPCameraTypeBack error:error]) {
        return nil;
    }
    
    
    /** 1. Initialize the Scanning settings */
    
    // Initialize the scanner settings object. This initialize settings with all default values.
    PPSettings *settings = [[PPSettings alloc] init];
    
    
    /** 2. Setup the license key */
    
    // Visit www.microblink.com to get the license key for your app
    settings.licenseSettings.licenseKey = @"C3W7RLMN-IUG77F6Q-TD7NCZ4R-VR5OQ2TI-OF7EYOVS-S6II6AW3-IA6H7JP4-C7U5MRZ3";
    
    
    /**
     * 3. Set up what is being scanned. See detailed guides for specific use cases.
     * Here's an example for initializing MRTD and USDL scanning
     */
    
    // To specify we want to perform MRTD (machine readable travel document) recognition, initialize the MRTD recognizer settings
    PPMrtdRecognizerSettings *mrtdRecognizerSettings = [[PPMrtdRecognizerSettings alloc] init];
    
    // Add MRTD Recognizer setting to a list of used recognizer settings
    [settings.scanSettings addRecognizerSettings:mrtdRecognizerSettings];
    
    // To specify we want to perform USDL (US Driver's license) recognition, initialize the USDL recognizer settings
    PPUsdlRecognizerSettings *usdlRecognizerSettings = [[PPUsdlRecognizerSettings alloc] init];
    
    // Add USDL Recognizer setting to a list of used recognizer settings
    [settings.scanSettings addRecognizerSettings:usdlRecognizerSettings];
    
    
    /** 4. Initialize the Scanning Coordinator object */
    
    PPCameraCoordinator *coordinator = [[PPCameraCoordinator alloc] initWithSettings:settings];
    
    return coordinator;
}

- (void)scanningViewControllerUnauthorizedCamera:(UIViewController<PPScanningViewController> *)scanningViewController {
    // Add any logic which handles UI when app user doesn't allow usage of the phone's camera
}

- (void)scanningViewController:(UIViewController<PPScanningViewController> *)scanningViewController
                  didFindError:(NSError *)error {
    // Can be ignored. See description of the method
}

- (void)scanningViewControllerDidClose:(UIViewController<PPScanningViewController> *)scanningViewController {
    
    // As scanning view controller is presented full screen and modally, dismiss it
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scanningViewController:(UIViewController<PPScanningViewController> *)scanningViewController
              didOutputResults:(NSArray *)results {
    
    // Here you process scanning results. Scanning results are given in the array of PPRecognizerResult objects.
    
    // first, pause scanning until we process all the results
    [scanningViewController pauseScanning];
    
    NSString* message;
    NSString* title;
    
    // Collect data from the result
    for (PPRecognizerResult* result in results) {
        
//        if ([result isKindOfClass:[PPMrtdRecognizerResult class]]) {
//            PPMrtdRecognizerResult* mrtdResult = (PPMrtdRecognizerResult*)result;
//            title = @"MRTD";
//            message = [mrtdResult description];
//        }
        if ([result isKindOfClass:[PPUsdlRecognizerResult class]]) {
            PPUsdlRecognizerResult* usdlResult = (PPUsdlRecognizerResult*)result;
            title = @"Does the info match?";
            message = [NSString stringWithFormat:@"Name: %@ %@\nAddress: %@\nDate of Birth: %@\nLicense Number: %@",[usdlResult getAllStringElements][@"Customer First Name"],[usdlResult getAllStringElements][@"Customer Family Name"],[usdlResult getAllStringElements][@"Full Address"],[usdlResult getAllStringElements][@"Date of Birth"],[usdlResult getAllStringElements][@"Customer ID Number"] ];
            AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                            identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
            
            AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
            
            AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
            
            AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
            AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];

            Transactions *newTransaction = [Transactions new];
            newTransaction.TransactionId = self.transactionId;
            newTransaction.scannedCustomerLicenseInfo = [NSString stringWithFormat:@"Name: %@ %@, Address: %@, Date of Birth: %@, License Number: %@",[usdlResult getAllStringElements][@"Customer First Name"],[usdlResult getAllStringElements][@"Customer Family Name"],[usdlResult getAllStringElements][@"Full Address"],[usdlResult getAllStringElements][@"Date of Birth"],[usdlResult getAllStringElements][@"Customer ID Number"] ];
            newTransaction.refunded = @"NO";
            [[[dynamoDBObjectMapper scan:[Transactions class]
                              expression:scanExpression]
              continueWithBlock:^id(AWSTask *task) {
                  if (task.error) {
                      NSLog(@"The request failed. Error: [%@]", task.error);
                  } else {
                      AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                      for (Transactions *transaction in paginatedOutput.items) {
                          //Do something with book.
                          if (transaction.TransactionId == self.transactionId) {
                              newTransaction.transactionResult = transaction.transactionResult;
                              newTransaction.date = transaction.date;
                          }
                      }
                  }
                  return nil;
              }] waitUntilFinished];
            
            [[dynamoDBObjectMapper save:newTransaction]
              continueWithBlock:^id(AWSTask *task) {
                  if (task.error) {
                      NSLog(@"The request failed. Error: [%@]", task.error);
                  } else {
                      //Do something with task.result or perform other operations.
                  }
                  return nil;
              }];

        }
    };
    
    // present the alert view with scanned results
    matchesAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"YES",@"NO", nil];
    [matchesAlertView show];
}

    // dismiss the scanning view controller when user presses OK.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if (alertView == matchesAlertView) {
            self.navigationItem.title = @"Step 2: Receipt Signature";
            [infoAlertView dismissWithClickedButtonIndex:0 animated:YES];
            matches = 1;
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
        }
    } else {
        matches = 3;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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

- (IBAction)acceptDeliveryAction:(id)sender {
    if(!self.signatureImageView.image) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Signature" message:@"Please sign below." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];

    } else {
//        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Add Tip"
//                                                                                  message: @"Do you want to add a tip? ($1 - $25)"
//                                                                           preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//            textField.placeholder = @"name";
//            textField.textColor = [UIColor blueColor];
//            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//            textField.borderStyle = UITextBorderStyleNone;
//        }];
//        [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            NSArray * textfields = alertController.textFields;
//            UITextField * tipfield = textfields[0];
//            NSLog(@"%@",tipfield.text);
//            if ([tipfield.text floatValue] > 25.0) {
//                [[[UIAlertView alloc] initWithTitle:@"Warning"
//                                            message:@"Tip is too high. Pleas enter a tip lower than $25."
//                                           delegate:nil
//                                  cancelButtonTitle:@"OK"
//                                  otherButtonTitles:nil, nil] show];
//            } else {
//                [self addTip:[tipfield.text floatValue]];
//            }
//        }]];
//        [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            
//        }]];
//        [self presentViewController:alertController animated:YES completion:nil];

        Orders *newOrder = [Orders new];
        
        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                        identityPoolId:@"us-east-1:05a67f89-89d3-485c-a991-7ef01ff18de6"];
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
        
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
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
                          newOrder.CustomerEndpointArn = order.CustomerEndpointArn;
                          newOrder.Area = order.Area;
                          newOrder.Location = order.Location;
                          newOrder.Order = order.Order;
                          newOrder.customerUsername = order.customerUsername;
                          newOrder.OrderId = _orderId;
                          newOrder.AcceptedDelivery = @"YES";
                          newOrder.DeliveryDate = [NSString stringWithFormat:@"%@",[NSDate date]];
                          newOrder.driverUsername = order.driverUsername;
                          newOrder.paid = order.paid;
                          newOrder.transactionId = order.transactionId;
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
        //Get Document Directory path
        NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //Define path for PDF file
        NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"RecieptOrderNumber%@", self.orderId]];
        
        // Prepare the text using a Core Text Framesetter.
        float total = 0.0;
        NSString *theText = [NSString stringWithFormat:@"Reciept For Order Number: %@", self.orderId];
        
        for (int i = 0; i < _orderDetails.count; i++) {
            theText = [NSString stringWithFormat:@"%@\nItem Name:%@      Price:%@",theText,[_orderDetails objectAtIndex:i][0],[_orderDetails objectAtIndex:i][1]];
            total += [[self.orderDetails objectAtIndex:i][1] floatValue];
        }
        theText = [NSString stringWithFormat:@"%@\nTotal:%.2f", theText,total];
        CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, (__bridge CFStringRef)theText, NULL);
        if (currentText) {
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
            if (framesetter) {
                
                
                // Create the PDF context using the default page size of 612 x 792.
                UIGraphicsBeginPDFContextToFile(documentPath, CGRectZero, nil);
                
                CFRange currentRange = CFRangeMake(0, 0);
                NSInteger currentPage = 0;
                BOOL done = NO;
                
                do {
                    // Mark the beginning of a new page.
                    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                    
                    // Draw a page number at the bottom of each page.
                    currentPage++;
                    [self drawPageNbr:currentPage];
                    
                    // Render the current page and update the current range to
                    // point to the beginning of the next page.
                    currentRange = *[self updatePDFPage:currentPage setTextRange:&currentRange setFramesetter:&framesetter];
                    
                    // If we're at the end of the text, exit the loop.
                    if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText))
                        [self.signatureImageView.image drawAtPoint:CGPointMake(10, currentRange.location+25)];
                        done = YES;
                } while (!done);
                
                // Close the PDF context and write the contents out.
                UIGraphicsEndPDFContext();
                
                // Release the framewetter.
                CFRelease(framesetter);
                
            } else {
                NSLog(@"Could not create the framesetter..");
            }
            // Release the attributed string.
            CFRelease(currentText);
        } else {
            NSLog(@"currentText could not be created");
        }
        
//        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
//        NSURL *uploadingFileURL = [NSURL fileURLWithPath:documentPath];
//        
//        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
//        uploadRequest.bucket = @"drinksdriverlicenses";
//        uploadRequest.key = [NSString stringWithFormat:@"RecieptOrderNumber%@", self.orderId];
//        uploadRequest.body = uploadingFileURL;
//        [[[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
//                                                           withBlock:^id(AWSTask *task) {
//                                                               if (task.error) {
//                                                                   if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
//                                                                       switch (task.error.code) {
//                                                                           case AWSS3TransferManagerErrorCancelled:
//                                                                           case AWSS3TransferManagerErrorPaused:
//                                                                               break;
//                                                                               
//                                                                           default:
//                                                                               NSLog(@"Error: %@", task.error);
//                                                                               break;
//                                                                       }
//                                                                   } else {
//                                                                       // Unknown error.
//                                                                       NSLog(@"Error: %@", task.error);
//                                                                   }
//                                                               }
//                                                               
//                                                               if (task.result) {
//                                                                   AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
//                                                                   // The file uploaded successfully.
//                                                                   
//                                                               }
//                                                               return nil;
//                                                           }] waitUntilFinished];

        [self.acceptDelegate acceptViewControllerDismissed:@"YES"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)drawPageNbr:(int)pageNumber{
    NSString *setPageNum = [NSString stringWithFormat:@"Page %d", pageNumber];
    UIFont *pageNbrFont = [UIFont systemFontOfSize:14];
    
    CGSize maxSize = CGSizeMake(612, 72);
    CGSize pageStringSize = [setPageNum sizeWithFont:pageNbrFont
                                   constrainedToSize:maxSize
                                       lineBreakMode:UILineBreakModeClip];
    
    CGRect stringRect = CGRectMake(((612.0 - pageStringSize.width) / 2.0),
                                   720.0 + ((72.0 - pageStringSize.height) / 2.0),
                                   pageStringSize.width,
                                   pageStringSize.height);
    [setPageNum drawInRect:stringRect withFont:pageNbrFont];
}

-(CFRange*)updatePDFPage:(int)pageNumber setTextRange:(CFRange*)pageRange setFramesetter:(CTFramesetterRef*)framesetter{
    // Get the graphics context.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    // Create a path object to enclose the text. Use 72 point
    // margins all around the text.
    CGRect frameRect = CGRectMake(72, 72, 468, 648);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    // Get the frame that will do the rendering.
    // The currentRange variable specifies only the starting point. The framesetter
    // lays out as much text as will fit into the frame.
    CTFrameRef frameRef = CTFramesetterCreateFrame(*framesetter, *pageRange,
                                                   framePath, NULL);
    CGPathRelease(framePath);
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, 792);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    // Update the current range based on what was drawn.
    *pageRange = CTFrameGetVisibleStringRange(frameRef);
    pageRange->location += pageRange->length;
    pageRange->length = 0;
    CFRelease(frameRef);
    return pageRange;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.signatureImageView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.signatureImageView];
    
    UIGraphicsBeginImageContext(self.signatureImageView.frame.size);
    [self.signatureImageView.image drawInRect:CGRectMake(0, 0, self.signatureImageView.frame.size.width, self.signatureImageView.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.signatureImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.signatureImageView setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UIGraphicsBeginImageContext(self.signatureImageView.frame.size);
    [self.signatureImageView.image drawInRect:CGRectMake(0, 0, self.signatureImageView.frame.size.width, self.signatureImageView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    CGContextFlush(UIGraphicsGetCurrentContext());
    self.signatureImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //UIGraphicsBeginImageContext(self.signatureImageView.frame.size);
//    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.signatureImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    //self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    //self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
}
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

-(void)addTip:(float)amount {
    //INTEGRATE TIP
    
}


@end

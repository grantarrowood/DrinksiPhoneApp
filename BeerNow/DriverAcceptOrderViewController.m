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

-(void)viewDidAppear:(BOOL)animated {
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

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Username" message:@"Please enter your username." preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }]];
//    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.navigationItem.title = @"Step 2: Sign for Order";
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
            NSLog(@"element: %@", [usdlResult getAllStringElements][@"Customer Name"]);
            message = [usdlResult description];
        }
    };
    
    // present the alert view with scanned results
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

// dismiss the scanning view controller when user presses OK.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
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

}
@end

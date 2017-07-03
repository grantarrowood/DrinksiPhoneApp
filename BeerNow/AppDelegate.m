//
//  AppDelegate.m
//  BeerNow
//
//  Created by Grant Arrowood on 5/24/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <AWSSNS/AWSSNS.h>
#import <AWSMobileAnalytics/AWSMobileAnalytics.h>
static NSString *const SNSPlatformApplicationArn = @"arn:aws:sns:us-east-1:585566417461:app/APNS_SANDBOX/Drinks";


@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey:@"pk_test_C6FhEd8zoD4zqkHDTJ5iWEy9"];
    [[STPPaymentConfiguration sharedConfiguration] setAppleMerchantIdentifier:@"merchant.com.drinks.pigletproducts"];
    
    UIMutableUserNotificationAction *readAction = [[UIMutableUserNotificationAction alloc] init];
    readAction.identifier = @"READ_IDENTIFIER";
    readAction.title = @"Read";
    readAction.activationMode = UIUserNotificationActivationModeForeground;
    readAction.destructive = NO;
    readAction.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *ignoreAction = [[UIMutableUserNotificationAction alloc] init];
    ignoreAction.identifier = @"IGNORE_IDENTIFIER";
    ignoreAction.title = @"Ignore";
    ignoreAction.activationMode = UIUserNotificationActivationModeBackground;
    ignoreAction.destructive = NO;
    ignoreAction.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *deleteAction = [[UIMutableUserNotificationAction alloc] init];
    deleteAction.identifier = @"DELETE_IDENTIFIER";
    deleteAction.title = @"Delete";
    deleteAction.activationMode = UIUserNotificationActivationModeForeground;
    deleteAction.destructive = YES;
    deleteAction.authenticationRequired = YES;
    
    UIMutableUserNotificationCategory *messageCategory = [[UIMutableUserNotificationCategory alloc] init];
    messageCategory.identifier = @"MESSAGE_CATEGORY";
    [messageCategory setActions:@[readAction, ignoreAction, deleteAction] forContext:UIUserNotificationActionContextDefault];
    [messageCategory setActions:@[readAction, deleteAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObject:messageCategory];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    if(launchOptions!=nil){
        NSString *msg = [NSString stringWithFormat:@"%@", launchOptions];
        NSLog(@"%@",msg);
        [self createAlert:msg];
    }

    
    
    
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    NSString *deviceTokenString = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"deviceTokenString: %@", deviceTokenString);
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    [self.window.rootViewController.childViewControllers.firstObject performSelectorOnMainThread:@selector(displayDeviceInfo) withObject:nil waitUntilDone:nil];

    
    AWSSNS *sns = [AWSSNS defaultSNS];
    AWSSNSCreatePlatformEndpointInput *request = [AWSSNSCreatePlatformEndpointInput new];
    request.token = deviceTokenString;
    request.platformApplicationArn = SNSPlatformApplicationArn;
    [[sns createPlatformEndpoint:request] continueWithBlock:^id(AWSTask *task) {
        if (task.error != nil) {
            NSLog(@"Error: %@",task.error);
        } else {
            AWSSNSCreateEndpointResponse *createEndPointResponse = task.result;
            NSLog(@"endpointArn: %@",createEndPointResponse);
            [[NSUserDefaults standardUserDefaults] setObject:createEndPointResponse.endpointArn forKey:@"endpointArn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
//            [self.window.rootViewController.childViewControllers.firstObject performSelectorOnMainThread:@selector(displayDeviceInfo) withObject:nil waitUntilDone:NO];
            
        }
        
        return nil;
    }];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    NSLog(@"Failed to register with error : %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    application.applicationIconBadgeNumber = 0;
    NSString *msg = [NSString stringWithFormat:@"%@", userInfo];
    NSLog(@"%@",msg);
    [self createAlert:msg];
}

- (void)createAlert:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Received" message:[NSString stringWithFormat:@"%@", msg]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    AWSMobileAnalytics *mobileAnalytics = [AWSMobileAnalytics defaultMobileAnalytics];
    id<AWSMobileAnalyticsEventClient> eventClient = mobileAnalytics.eventClient;
    id<AWSMobileAnalyticsEvent> pushNotificationEvent = [eventClient createEventWithEventType:@"PushNotificationEvent"];
    
    NSString *action = @"Undefined";
    if ([identifier isEqualToString:@"READ_IDENTIFIER"]) {
        action = @"read";
        NSLog(@"User selected 'Read'");
    } else if ([identifier isEqualToString:@"DELETE_IDENTIFIER"]) {
        action = @"Deleted";
        NSLog(@"User selected `Delete`");
    } else {
        action = @"Undefined";
    }
    
    [pushNotificationEvent addAttribute:action forKey:@"Action"];
    [eventClient recordEvent:pushNotificationEvent];

    completionHandler();
}




@end

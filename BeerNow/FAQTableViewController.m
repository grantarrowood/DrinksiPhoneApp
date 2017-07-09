//
//  FAQTableViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/20/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "FAQTableViewController.h"

@interface FAQTableViewController ()

@end

@implementation FAQTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inAppNotification:)
                                                 name:@"InAppNotification"
                                               object:nil];
    _notification = [[AFDropdownNotification alloc] init];
    _notification.notificationDelegate = self;

    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
-(void)inAppNotification:(NSNotification*)sender {
    // Perform action here
    _notification.titleText = @"DRINKS";
    _notification.subtitleText = [[sender object] valueForKey:@"message"];
    _notification.image = [UIImage imageNamed:@"profileIcon"];
    _notification.topButtonText = @"Accept";
    _notification.bottomButtonText = @"Cancel";
    _notification.dismissOnTap = YES;
    [_notification presentInView:self.view withGravityAnimation:YES];
    
    [_notification listenEventsWithBlock:^(AFDropdownNotificationEvent event) {
        
        switch (event) {
            case AFDropdownNotificationEventTopButton:
                // Top button
                break;
                
            case AFDropdownNotificationEventBottomButton:
                // Bottom button
                break;
                
            case AFDropdownNotificationEventTap:
                // Tap
                break;
                
            default:
                break;
        }
    }];
    
    NSLog(@"show notification");
    
    
}

-(void)dropdownNotificationTopButtonTapped {
    
    NSLog(@"Top button tapped");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Top button tapped" message:@"Hooray! You tapped the top button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [_notification dismissWithGravityAnimation:YES];
}

-(void)dropdownNotificationBottomButtonTapped {
    
    NSLog(@"Bottom button tapped");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bottom button tapped" message:@"Hooray! You tapped the bottom button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [_notification dismissWithGravityAnimation:YES];
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

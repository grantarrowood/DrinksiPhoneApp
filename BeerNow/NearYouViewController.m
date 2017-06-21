//
//  NearYouViewController.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/20/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "NearYouViewController.h"

@interface NearYouViewController ()

@end

@implementation NearYouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.handleView.layer.cornerRadius = 2.5;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    [self.mapContainerView addGestureRecognizer:panGestureRecognizer];
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
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    // OPEN ORDER DETAILS VIEW CONTROLLER
    //[self performSegueWithIdentifier:@"detailsOrderSegue" sender:nil];
    //    OrderDetailsTableViewController *secondViewController = [[OrderDetailsTableViewController alloc] init];
    //    secondViewController.orderId = [(Orders *)[ordersArray objectAtIndex:indexPath.row] OrderId]; // Set the exposed property
    //    [self.navigationController pushViewController:secondViewController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];

    if((panGestureRecognizer.view.frame.origin.y + translation.y) <= 80) {
        panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x, 410);
        [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    } else {
        panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x, panGestureRecognizer.view.center.y + translation.y);
        [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
}

@end

//
//  DetailTableViewCell.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/18/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *detailDynamicLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailMainLabel;

@end

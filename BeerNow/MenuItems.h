//
//  MenuItems.h
//  BeerNow
//
//  Created by Grant Arrowood on 5/27/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface MenuItems : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *Address;
@property (nonatomic, strong) NSString *MenuLocation;
@property (nonatomic, strong) NSNumber *Price;
@property (nonatomic, strong) NSString *MenuId;

@end

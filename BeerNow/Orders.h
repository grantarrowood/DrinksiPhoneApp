//
//  Orders.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/12/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface Orders : AWSDynamoDBObjectModel <AWSDynamoDBModeling>


@property (nonatomic, strong) NSString *Selected;
@property (nonatomic, strong) NSString *Completed;
@property (nonatomic, strong) NSString *Order;
@property (nonatomic, strong) NSString *Location;
@property (nonatomic, strong) NSNumber *OrderId;
@property (nonatomic, strong) NSString *Area;

@end
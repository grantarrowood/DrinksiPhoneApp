//
//  Orders.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/12/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface Orders : AWSDynamoDBObjectModel <AWSDynamoDBModeling>


@property (nonatomic, strong) NSString *AcceptedDelivery;
@property (nonatomic, strong) NSString *DeliveryDate;
@property (nonatomic, strong) NSString *Order;
@property (nonatomic, strong) NSString *Location;
@property (nonatomic, strong) NSNumber *OrderId;
@property (nonatomic, strong) NSString *Area;
@property (nonatomic, strong) NSString *driverUsername;
@property (nonatomic, strong) NSString *customerUsername;
@property (nonatomic, strong) NSString *paid;
@property (nonatomic, strong) NSNumber *transactionId;



@end

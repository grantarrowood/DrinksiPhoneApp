//
//  Orders.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/12/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "Orders.h"

@implementation Orders

+ (NSString *)dynamoDBTableName {
    return @"DrinksOrders";
}

+ (NSString *)hashKeyAttribute {
    return @"OrderId";
}

@end

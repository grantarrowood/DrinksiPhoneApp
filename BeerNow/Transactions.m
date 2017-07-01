//
//  Transactions.m
//  BeerNow
//
//  Created by Grant Arrowood on 6/26/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "Transactions.h"

@implementation Transactions

+ (NSString *)dynamoDBTableName {
    return @"DrinksTransactions";
}

+ (NSString *)hashKeyAttribute {
    return @"TransactionId";
}

@end

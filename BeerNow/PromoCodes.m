//
//  PromoCodes.m
//  BeerNow
//
//  Created by Grant Arrowood on 7/8/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "PromoCodes.h"

@implementation PromoCodes

+ (NSString *)dynamoDBTableName {
    return @"DrinksPromoCodes";
}

+ (NSString *)hashKeyAttribute {
    return @"CodeId";
}

@end

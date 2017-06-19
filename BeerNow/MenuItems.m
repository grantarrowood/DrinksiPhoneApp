//
//  MenuItems.m
//  BeerNow
//
//  Created by Grant Arrowood on 5/27/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "MenuItems.h"

@implementation MenuItems

+ (NSString *)dynamoDBTableName {
    return @"DrinksMenu";
}

+ (NSString *)hashKeyAttribute {
    return @"MenuId";
}

@end

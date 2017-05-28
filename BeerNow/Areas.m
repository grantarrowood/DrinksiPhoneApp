//
//  Areas.m
//  BeerNow
//
//  Created by Grant Arrowood on 5/27/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "Areas.h"

@implementation Areas

+ (NSString *)dynamoDBTableName {
    return @"DrinksAreas";
}

+ (NSString *)hashKeyAttribute {
    return @"AreaId";
}

@end

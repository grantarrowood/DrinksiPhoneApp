//
//  Locations.m
//  BeerNow
//
//  Created by Grant Arrowood on 5/27/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import "Locations.h"

@implementation Locations

+ (NSString *)dynamoDBTableName {
    return @"DrinksLocations";
}

+ (NSString *)hashKeyAttribute {
    return @"LocationId";
}


@end

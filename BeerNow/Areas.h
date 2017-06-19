//
//  Areas.h
//  BeerNow
//
//  Created by Grant Arrowood on 5/27/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface Areas : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *AreaId;

@end

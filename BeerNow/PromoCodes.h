//
//  PromoCodes.h
//  BeerNow
//
//  Created by Grant Arrowood on 7/8/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface PromoCodes : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSNumber *CodeId;
@property (nonatomic, strong) NSString *PromoCode;
@property (nonatomic, strong) NSString *Used;
@property (nonatomic, strong) NSString *UsedBy;
@property (nonatomic, strong) NSString *CodeType;

@end

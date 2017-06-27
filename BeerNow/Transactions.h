//
//  Transactions.h
//  BeerNow
//
//  Created by Grant Arrowood on 6/26/17.
//  Copyright © 2017 Piglet Products, LLC. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface Transactions : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSNumber *TransactionId;

@end

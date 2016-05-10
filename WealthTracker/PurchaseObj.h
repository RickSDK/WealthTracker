//
//  PurchaseObj.h
//  WealthTracker
//
//  Created by Rick Medved on 5/7/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PurchaseObj : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *month;
@property (nonatomic, strong) NSString *day;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *amountStr;

@property (nonatomic, strong) NSDate *itemDate;
@property (nonatomic) double amount;
@property (nonatomic) int purchaseId;
@property (nonatomic) int bucket;

+(PurchaseObj *)objFromMO:(NSManagedObject *)mo;

@end

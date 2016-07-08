//
//  AmountObj.h
//  WealthTracker
//
//  Created by Rick Medved on 7/7/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmountObj : NSObject

@property (nonatomic) BOOL amount_confirm_flg;
@property (nonatomic) BOOL futureDayFlg;
@property (nonatomic) double amount;
@property (nonatomic) double equity;
@property (nonatomic) double balance;
@property (nonatomic) double value;
@property (nonatomic) double interest;

@property (nonatomic) double amountChange;
@property (nonatomic) double equityChange;
@property (nonatomic) double balanceChange;
@property (nonatomic) double valueChange;
@property (nonatomic) double interestChange;

@end

//
//  ItemObject.h
//  WealthTracker
//
//  Created by Rick Medved on 7/11/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemObject : NSObject

@property (nonatomic, strong) NSString *rowId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *sub_type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *payment_type;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *value;

@property (nonatomic, strong) NSString *statement_day;
@property (nonatomic, strong) NSString *homeowner_dues;
@property (nonatomic, strong) NSString *interest_rate;
@property (nonatomic, strong) NSString *monthly_payment;
@property (nonatomic, strong) NSString *loan_balance;
@property (nonatomic, strong) NSString *valueUrl;
@property (nonatomic, strong) NSString *balanceUrl;

@property (nonatomic, strong) NSDate *last_upd_balance;

@property (nonatomic) BOOL bal_confirm_flg;
@property (nonatomic) BOOL val_confirm_flg;
@property (nonatomic) BOOL futureDayFlg;
@property (nonatomic) int status;
@property (nonatomic) int day;

@end

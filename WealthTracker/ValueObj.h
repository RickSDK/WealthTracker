//
//  ValueObj.h
//  WealthTracker
//
//  Created by Rick Medved on 7/30/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValueObj : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) double value;
@property (nonatomic) double balance;
@property (nonatomic) double badDebt;
@property (nonatomic) double interest;
@property (nonatomic) double monthlyPayment;
@property (nonatomic) BOOL reverseColorFlg;

@end

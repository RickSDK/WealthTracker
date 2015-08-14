//
//  ProfileObj.h
//  WealthTracker
//
//  Created by Rick Medved on 7/11/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileObj : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *dependants;
@property (nonatomic, strong) NSString *emergency_fund;
@property (nonatomic, strong) NSString *income;
@property (nonatomic, strong) NSString *retirement_payments;
@property (nonatomic, strong) NSString *monthly_rent;

@end

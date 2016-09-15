//
//  AnalysisObj.h
//  WealthTracker
//
//  Created by Rick Medved on 9/8/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AnalysisObj : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) int status;
@property (nonatomic) double amount;
@property (nonatomic) double prevAmount;
@property (nonatomic) int hi;
@property (nonatomic) int lo;
@property (nonatomic) BOOL reverseFlg;

+(AnalysisObj *)objectWithTitle:(NSString *)title value:(NSString *)value amount:(double)amount hi:(int)hi lo:(int)lo reverseFlg:(BOOL)reverseFlg;


@end

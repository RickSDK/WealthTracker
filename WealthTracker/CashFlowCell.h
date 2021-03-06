//
//  CashFlowCell.h
//  WealthTracker
//
//  Created by Rick Medved on 8/3/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "CashFlowObj.h"

@interface CashFlowCell : UITableViewCell

@property (nonatomic, retain) UILabel *dayLabel;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *amountLabel;
@property (nonatomic, retain) UILabel *amountRemainingLabel;
@property (nonatomic, retain) CustomButton *checkMarkButton;

+(void)populateCell:(CashFlowCell *)cell obj:(CashFlowObj *)obj;
+(NSString *)fASymbolForType:(int)type;
+(NSString *)fANameForType:(int)type;

@end

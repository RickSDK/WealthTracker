//
//  UpdateCell.h
//  WealthTracker
//
//  Created by Rick Medved on 7/15/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface UpdateCell : UITableViewCell

@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UILabel *currentYearLabel;
@property (nonatomic, retain) CustomButton *prevYearButton;
@property (nonatomic, retain) CustomButton *nextYearButton;

@property (nonatomic, retain) UIImageView *valueStatusImageView;
@property (nonatomic, retain) UIImageView *balanceStatusImageView;
@property (nonatomic, retain) UIImageView *statusImage;
@property (nonatomic, retain) UILabel *valueLabel;
@property (nonatomic, retain) UILabel *loanAmountLabel;

@property (nonatomic, retain) UITextField *valueTextField;
@property (nonatomic, retain) UITextField *loanAmountTextField;

@property (nonatomic, retain) CustomButton *updateValueButton;
@property (nonatomic, retain) CustomButton *updateBalanceButton;

@end

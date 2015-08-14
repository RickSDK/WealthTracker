//
//  MoneyCell.h
//  WealthTracker
//
//  Created by Rick Medved on 7/10/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface MoneyCell : UITableViewCell

@property (nonatomic, retain) UIImageView *statusImage;
@property (nonatomic, retain) UIView *bgView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *amountLabel;
@property (nonatomic, retain) UILabel *descLabel;
@property (nonatomic, retain) CustomButton *updateButton;
@property (nonatomic, retain) UIButton *updateButton2;

@end

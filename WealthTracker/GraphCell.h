//
//  GraphCell.h
//  WealthTracker
//
//  Created by Rick Medved on 7/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface GraphCell : UITableViewCell

@property (nonatomic, retain) UIView *titleView;
@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UILabel *currentYearLabel;
@property (nonatomic, retain) CustomButton *prevYearButton;
@property (nonatomic, retain) CustomButton *nextYearButton;

@property (nonatomic, retain) UIImageView *graphImageView;

@end

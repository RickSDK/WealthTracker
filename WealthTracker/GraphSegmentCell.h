//
//  GraphSegmentCell.h
//  WealthTracker
//
//  Created by Rick Medved on 8/6/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface GraphSegmentCell : UITableViewCell

@property (nonatomic, retain) UIView *titleView;
@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UILabel *currentYearLabel;
@property (nonatomic, retain) CustomButton *prevYearButton;
@property (nonatomic, retain) CustomButton *nextYearButton;

@property (nonatomic, retain) UIView *segmentView;
@property (nonatomic, retain) UIButton *lineButton;
@property (nonatomic, retain) UIButton *barButton;
@property (nonatomic, retain) UIButton *pieButton;

@property (nonatomic, retain) UIImageView *graphImageView;

@end

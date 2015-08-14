//
//  UpdateWebCell.h
//  WealthTracker
//
//  Created by Rick Medved on 7/23/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface UpdateWebCell : UITableViewCell

@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIImageView *iconImageView;
@property (nonatomic, retain) UIImageView *statusImageView;
@property (nonatomic, retain) CustomButton *updateButton;

@end

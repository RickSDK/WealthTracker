//
//  DateCell.h
//  WealthTracker
//
//  Created by Rick Medved on 7/17/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface DateCell : UITableViewCell

@property (nonatomic, retain) UILabel *currentYearLabel;

@property (nonatomic, retain) CustomButton *prevYearButton;
@property (nonatomic, retain) CustomButton *nextYearButton;

@end

//
//  BreakdownCell.h
//  WealthTracker
//
//  Created by Rick Medved on 7/22/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BreakdownCell : UITableViewCell

@property (nonatomic, retain) UILabel *monthLabel;
@property (nonatomic, retain) UILabel *amountLabel;
@property (nonatomic, retain) UILabel *past30DaysLabel;

@end

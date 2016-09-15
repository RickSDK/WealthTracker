//
//  AnalysisCell.h
//  WealthTracker
//
//  Created by Rick Medved on 9/8/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnalysisObj.h"

@interface AnalysisCell : UITableViewCell

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UIView *bgView;
@property (nonatomic, retain) NSArray *dataArray;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(NSArray *)data;
+ (CGFloat)cellHeightForData:(NSArray *)dataArray;

@end

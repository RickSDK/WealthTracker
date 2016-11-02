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
@property (nonatomic, retain) UILabel *descriptionLabel;
@property (nonatomic, retain) UIView *bgView;
@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, retain) NSString *desc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(NSArray *)data desc:(NSString *)desc;
+ (CGFloat)cellHeightForData:(NSArray *)dataArray desc:(NSString *)desc;

@end

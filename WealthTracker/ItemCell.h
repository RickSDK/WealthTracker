//
//  ItemCell.h
//  WealthTracker
//
//  Created by Rick Medved on 7/12/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCell : UITableViewCell

@property (nonatomic, retain) UIImageView *valStatusImage;
@property (nonatomic, retain) UIImageView *typeImageView;
@property (nonatomic, retain) UIView *bgView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *subTypeLabel;
@property (nonatomic, retain) UILabel *amountLabel;
@property (nonatomic, retain) UILabel *last30Label;
@property (nonatomic, retain) UILabel *statement_dayLabel;
@property (nonatomic, retain) UILabel *statement_dayLabel2;

@end

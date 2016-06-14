//
//  ItemCell.h
//  WealthTracker
//
//  Created by Rick Medved on 7/12/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveCScripts.h"
#import "ItemObject.h"

@interface ItemCell : UITableViewCell

@property (nonatomic, retain) UIImageView *valStatusImage;
@property (nonatomic, retain) UIImageView *typeImageView;
@property (nonatomic, retain) UIView *bgView;
@property (nonatomic, retain) UIView *redLineView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *subTypeLabel;
@property (nonatomic, retain) UILabel *balanceLabel;
@property (nonatomic, retain) UILabel *balanceChangeLabel;
@property (nonatomic, retain) UILabel *valueLabel;
@property (nonatomic, retain) UILabel *valueChangeLabel;
@property (nonatomic, retain) UILabel *equityLabel;
@property (nonatomic, retain) UILabel *equityChangeLabel;
@property (nonatomic, retain) UILabel *statement_dayLabel;
@property (nonatomic, retain) UILabel *statement_dayLabel2;
@property (nonatomic, retain) UILabel *rightLabel;
@property (nonatomic, retain) UILabel *arrowLabel;

+(void)updateCell:(ItemCell *)cell obj:(ItemObject *)obj;

@end

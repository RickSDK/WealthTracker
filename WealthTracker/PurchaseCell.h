//
//  PurchaseCell.h
//  WealthTracker
//
//  Created by Rick Medved on 5/7/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PurchaseObj.h"

@interface PurchaseCell : UITableViewCell

@property (nonatomic, retain) UILabel *monthLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *iconLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *amountLabel;

+(PurchaseCell *)populateCell:(PurchaseCell *)cell obj:(PurchaseObj *)obj;

@end

//
//  PurchaseCell.m
//  WealthTracker
//
//  Created by Rick Medved on 5/7/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "PurchaseCell.h"
#import "ObjectiveCScripts.h"

@implementation PurchaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		
		UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 46, 40)];
		bgView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
		[self.contentView addSubview:bgView];
		
		UIColor *themeColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
		
		self.monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 50, 15)];
		self.monthLabel.font = [UIFont boldSystemFontOfSize:12];
		self.monthLabel.adjustsFontSizeToFitWidth = YES;
		self.monthLabel.minimumScaleFactor = .8;
		self.monthLabel.text = @"Mar";
		self.monthLabel.textAlignment = NSTextAlignmentCenter;
		self.monthLabel.textColor = themeColor;
		self.monthLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.monthLabel];
		
		self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 50, 30)];
		self.dateLabel.font = [UIFont boldSystemFontOfSize:22];
		self.dateLabel.adjustsFontSizeToFitWidth = YES;
		self.dateLabel.minimumScaleFactor = .8;
		self.dateLabel.text = @"23";
		self.dateLabel.textAlignment = NSTextAlignmentCenter;
		self.dateLabel.textColor = themeColor;
		self.dateLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.dateLabel];
		
		self.iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 30, 44)];
		self.iconLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:17];
		self.iconLabel.adjustsFontSizeToFitWidth = YES;
		self.iconLabel.minimumScaleFactor = .8;
		self.iconLabel.text = @"X";
		self.iconLabel.textAlignment = NSTextAlignmentLeft;
		self.iconLabel.textColor = [UIColor blackColor];
		self.iconLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.iconLabel];
		
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 150, 44)];
		self.nameLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:17];
		self.nameLabel.adjustsFontSizeToFitWidth = YES;
		self.nameLabel.minimumScaleFactor = .8;
		self.nameLabel.text = @"Food Purchase";
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.nameLabel];
		
		self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 170, 44)];
		self.amountLabel.font = [UIFont systemFontOfSize:20];
		self.amountLabel.adjustsFontSizeToFitWidth = YES;
		self.amountLabel.minimumScaleFactor = .8;
		self.amountLabel.text = @"amountLabel";
		self.amountLabel.textAlignment = NSTextAlignmentRight;
		self.amountLabel.textColor = themeColor;
		self.amountLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.amountLabel];
		
		
		
	}
	return self;
}

+(PurchaseCell *)populateCell:(PurchaseCell *)cell obj:(PurchaseObj *)obj {
	cell.monthLabel.text = obj.month;
	cell.dateLabel.text = obj.day;
	cell.timeLabel.text = obj.time;
	cell.amountLabel.text = obj.amountStr;
	cell.iconLabel.text = [self iconForBucket:obj.bucket];
	cell.nameLabel.text = obj.name;
	return cell;
	
}

+(NSString *)iconForBucket:(int)bucket {
	switch (bucket) {
  case 0:
			return [NSString fontAwesomeIconStringForEnum:FACoffee];
			break;
  case 1:
			return [NSString fontAwesomeIconStringForEnum:FACutlery];
			break;
  case 2:
			return [NSString fontAwesomeIconStringForEnum:FAShoppingCart];
			break;
  case 3:
			return [NSString fontAwesomeIconStringForEnum:FABriefcase];
			break;
  case 4:
			return [NSString fontAwesomeIconStringForEnum:FATicket];
			break;
  case 5:
			return [NSString fontAwesomeIconStringForEnum:FAUsd];
			break;
			
  default:
			return [NSString fontAwesomeIconStringForEnum:FAUser];
			break;
	}
	return [NSString fontAwesomeIconStringForEnum:FAUser];
}


@end

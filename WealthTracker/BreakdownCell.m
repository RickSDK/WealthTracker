//
//  BreakdownCell.m
//  WealthTracker
//
//  Created by Rick Medved on 7/22/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "BreakdownCell.h"

@implementation BreakdownCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 30)];
		self.monthLabel.font = [UIFont boldSystemFontOfSize:20];
		self.monthLabel.adjustsFontSizeToFitWidth = YES;
		self.monthLabel.minimumScaleFactor = .8;
		self.monthLabel.text = @"Jan";
		self.monthLabel.textAlignment = NSTextAlignmentCenter;
		self.monthLabel.textColor = [UIColor blackColor];
		self.monthLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.monthLabel];
		
		self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 110, 30)];
		self.amountLabel.font = [UIFont boldSystemFontOfSize:20];
		self.amountLabel.adjustsFontSizeToFitWidth = YES;
		self.amountLabel.minimumScaleFactor = .8;
		self.amountLabel.text = @"$100";
		self.amountLabel.textAlignment = NSTextAlignmentCenter;
		self.amountLabel.textColor = [UIColor greenColor];
		self.amountLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.amountLabel];
		
		self.past30DaysLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, 30)];
		self.past30DaysLabel.font = [UIFont boldSystemFontOfSize:20];
		self.past30DaysLabel.adjustsFontSizeToFitWidth = YES;
		self.past30DaysLabel.minimumScaleFactor = .8;
		self.past30DaysLabel.text = @"+$50";
		self.past30DaysLabel.textAlignment = NSTextAlignmentCenter;
		self.past30DaysLabel.textColor = [UIColor greenColor];
		self.past30DaysLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.past30DaysLabel];
		
	}
	return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

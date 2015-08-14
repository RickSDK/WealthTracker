//
//  CashFlowCell.m
//  WealthTracker
//
//  Created by Rick Medved on 8/3/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "CashFlowCell.h"

@implementation CashFlowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
		self.dayLabel.font = [UIFont boldSystemFontOfSize:20];
		self.dayLabel.adjustsFontSizeToFitWidth = YES;
		self.dayLabel.minimumScaleFactor = .8;
		self.dayLabel.text = @"15";
		self.dayLabel.textAlignment = NSTextAlignmentCenter;
		self.dayLabel.textColor = [UIColor purpleColor];
		self.dayLabel.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
		self.dayLabel.layer.cornerRadius = 8.0;
		self.dayLabel.layer.masksToBounds = YES;
		self.dayLabel.layer.borderColor = [UIColor blackColor].CGColor;
		self.dayLabel.layer.borderWidth = 1.0;
		[self.contentView addSubview:self.dayLabel];
		
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 150, 30)];
		self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
		self.nameLabel.adjustsFontSizeToFitWidth = YES;
		self.nameLabel.minimumScaleFactor = .8;
		self.nameLabel.text = @"name";
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.nameLabel];
		
		self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 100, 25)];
		self.amountLabel.font = [UIFont boldSystemFontOfSize:20];
		self.amountLabel.adjustsFontSizeToFitWidth = YES;
		self.amountLabel.minimumScaleFactor = .8;
		self.amountLabel.text = @"$100";
		self.amountLabel.textAlignment = NSTextAlignmentRight;
		self.amountLabel.textColor = [UIColor greenColor];
		self.amountLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.amountLabel];
		
		self.amountRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 25, 100, 20)];
		self.amountRemainingLabel.font = [UIFont boldSystemFontOfSize:16];
		self.amountRemainingLabel.adjustsFontSizeToFitWidth = YES;
		self.amountRemainingLabel.minimumScaleFactor = .8;
		self.amountRemainingLabel.text = @"$100";
		self.amountRemainingLabel.textAlignment = NSTextAlignmentRight;
		self.amountRemainingLabel.textColor = [UIColor greenColor];
		self.amountRemainingLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.amountRemainingLabel];
		
		self.checkMarkButton = [[CustomButton alloc] initWithFrame:CGRectMake(285, 5, 30, 34)];
		[self.checkMarkButton setBackgroundImage:[UIImage imageNamed:@"checkMark.jpg"] forState:UIControlStateNormal];
		[self.contentView addSubview:self.checkMarkButton];
		
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

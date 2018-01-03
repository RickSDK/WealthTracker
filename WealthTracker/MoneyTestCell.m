//
//  MoneyTestCell.m
//  WealthTracker
//
//  Created by Rick Medved on 9/21/17.
//  Copyright (c) 2017 Rick Medved. All rights reserved.
//

#import "MoneyTestCell.h"

@implementation MoneyTestCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.checkbox = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 60, 32)];
		self.checkbox.font = [UIFont systemFontOfSize:20];
		self.checkbox.adjustsFontSizeToFitWidth = YES;
		self.checkbox.minimumScaleFactor = .8;
		self.checkbox.text = @"◻☑";
		self.checkbox.textAlignment = NSTextAlignmentLeft;
		self.checkbox.textColor = [UIColor blackColor];
		self.checkbox.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.checkbox];

		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 6, 300, 32)];
		self.titleLabel.font = [UIFont systemFontOfSize:20];
		self.titleLabel.adjustsFontSizeToFitWidth = YES;
		self.titleLabel.minimumScaleFactor = .8;
		self.titleLabel.text = @"Title";
		self.titleLabel.textAlignment = NSTextAlignmentLeft;
		self.titleLabel.textColor = [UIColor blackColor];
		self.titleLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.titleLabel];

		self.infoButton = [[UIButton alloc] initWithFrame:CGRectMake(245, 20, 75, 35)];
		[self.infoButton setTitle:@"ℹ️" forState:UIControlStateNormal];
		[self.contentView addSubview:self.infoButton];
		

	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	float width=self.frame.size.width;
	self.infoButton.frame = CGRectMake(width-35, 6, 30, 30);
	
}

@end

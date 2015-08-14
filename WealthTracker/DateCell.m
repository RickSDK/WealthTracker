//
//  DateCell.m
//  WealthTracker
//
//  Created by Rick Medved on 7/17/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "DateCell.h"

@implementation DateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.currentYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 120, 30)];
		self.currentYearLabel.font = [UIFont boldSystemFontOfSize:20];
		self.currentYearLabel.adjustsFontSizeToFitWidth = YES;
		self.currentYearLabel.minimumScaleFactor = .8;
		self.currentYearLabel.text = @"2015";
		self.currentYearLabel.textAlignment = NSTextAlignmentCenter;
		self.currentYearLabel.textColor = [UIColor whiteColor];
		self.currentYearLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.currentYearLabel];
		
		self.prevYearButton = [[CustomButton alloc] initWithFrame:CGRectMake(5, 5, 60, 30)];
		[self.prevYearButton setTitle:@"Prev" forState:UIControlStateNormal];
		[self.contentView addSubview:self.prevYearButton];
		
		self.nextYearButton = [[CustomButton alloc] initWithFrame:CGRectMake(255, 5, 60, 30)];
		[self.nextYearButton setTitle:@"Next" forState:UIControlStateNormal];
		[self.contentView addSubview:self.nextYearButton];
		
		self.backgroundColor = [UIColor colorWithRed:(6/255.0) green:(122/255.0) blue:(180/255.0) alpha:1.0];
		
	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	[DateCell layoutSubviews:self.currentYearLabel nextYearButton:self.nextYearButton inBound:self.frame];
	
}

+ (void) layoutSubviews:(UILabel *)currentYearLabel
		 nextYearButton:(CustomButton *)nextYearButton
				inBound:(CGRect) cellRect
{
	
	float width=cellRect.size.width;
	
	currentYearLabel.frame = CGRectMake(100, 5, width-200, 30);
	nextYearButton.frame = CGRectMake(width-65, 5, 60, 30);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  GraphCell.m
//  WealthTracker
//
//  Created by Rick Medved on 7/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "GraphCell.h"
#import "ObjectiveCScripts.h"

@implementation GraphCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		
		self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		self.titleView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
		[self.contentView addSubview:self.titleView];

		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
		self.titleLabel.adjustsFontSizeToFitWidth = YES;
		self.titleLabel.minimumScaleFactor = .8;
		self.titleLabel.text = @"Title";
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		self.titleLabel.textColor = [ObjectiveCScripts darkColor];
		self.titleLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.titleLabel];

		self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 40)];
		self.topView.backgroundColor = [ObjectiveCScripts mediumkColor];
		[self.contentView addSubview:self.topView];
		
		self.currentYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 23, 120, 30)];
		self.currentYearLabel.font = [UIFont boldSystemFontOfSize:20];
		self.currentYearLabel.adjustsFontSizeToFitWidth = YES;
		self.currentYearLabel.minimumScaleFactor = .8;
		self.currentYearLabel.text = @"2015";
		self.currentYearLabel.textAlignment = NSTextAlignmentCenter;
		self.currentYearLabel.textColor = [UIColor whiteColor];
		self.currentYearLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.currentYearLabel];
		
		self.prevYearButton = [[CustomButton alloc] initWithFrame:CGRectMake(5, 21, 60, 34)];
		[self.prevYearButton setTitle:@"Prev" forState:UIControlStateNormal];
		[self.contentView addSubview:self.prevYearButton];
		
		self.nextYearButton = [[CustomButton alloc] initWithFrame:CGRectMake(255, 21, 60, 34)];
		[self.nextYearButton setTitle:@"Next" forState:UIControlStateNormal];
		[self.contentView addSubview:self.nextYearButton];
		
		self.graphImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 54, 316, 178-34)];
		self.graphImageView.backgroundColor = [UIColor whiteColor];
		self.graphImageView.layer.cornerRadius = 8.0;
		self.graphImageView.layer.masksToBounds = YES;
		self.graphImageView.layer.borderColor = [UIColor blackColor].CGColor;
		self.graphImageView.layer.borderWidth = 2.0;
		[self.contentView addSubview:self.graphImageView];
		
		self.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
		
	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	[GraphCell layoutSubviews:self.titleView titleLabel:self.titleLabel topView:self.topView currentYearLabel:self.currentYearLabel nextYearButton:self.nextYearButton graphImageView:self.graphImageView inBound:self.frame];
	
}

+ (void) layoutSubviews:(UIView *)titleView
			 titleLabel:(UILabel *)titleLabel
				topView:(UIView *)topView
			 currentYearLabel:(UILabel *)currentYearLabel
		 nextYearButton:(CustomButton *)nextYearButton
		 graphImageView:(UIImageView *)graphImageView
				inBound:(CGRect) cellRect
{
	
	float width=cellRect.size.width;
	
	int height = [ObjectiveCScripts chartHeightForSize:194];
	
	titleView.frame = CGRectMake(0, 0, width, 20);
	titleLabel.frame = CGRectMake(0, 0, width, 20);
	topView.frame = CGRectMake(0, 20, width, 36);
	currentYearLabel.frame = CGRectMake(100, 23, width-200, 30);
	nextYearButton.frame = CGRectMake(width-65, 21, 60, 34);
	graphImageView.frame = CGRectMake(2, 58, width-4, height);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  GraphSegmentCell.m
//  WealthTracker
//
//  Created by Rick Medved on 8/6/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "GraphSegmentCell.h"
#import "ObjectiveCScripts.h"
#import "CustomButton.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"

@implementation GraphSegmentCell

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
		
		self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
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
		
		self.prevYearButton = [[CustomButton alloc] initWithFrame:CGRectMake(5, 23, 60, 34)];
		[self.prevYearButton setTitle:@"Prev" forState:UIControlStateNormal];
		[self.contentView addSubview:self.prevYearButton];
		
		self.nextYearButton = [[CustomButton alloc] initWithFrame:CGRectMake(255, 21, 60, 34)];
		[self.nextYearButton setTitle:@"Next" forState:UIControlStateNormal];
		[self.contentView addSubview:self.nextYearButton];
		
		
		self.segmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 320, 34)];
		self.segmentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:.5 alpha:1.0];
		[self.contentView addSubview:self.segmentView];

		id pieChart  = [NSString fontAwesomeIconStringForEnum:FApieChart];
		id barChartO = [NSString fontAwesomeIconStringForEnum:FABarChartO];
		id lineChart = [NSString fontAwesomeIconStringForEnum:FAlineChart];

		self.lineButton = [[CustomButton alloc] initWithFrame:CGRectMake(10, 62, 98, 30)];
		self.lineButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:17];
		[self.lineButton setTitle:[NSString stringWithFormat:@"%@ Lines", lineChart] forState:UIControlStateNormal];
//		[self.lineButton setBackgroundImage:[UIImage imageNamed:@"lineChart.png"] forState:UIControlStateNormal];
		self.lineButton.enabled=NO;
		[self.contentView addSubview:self.lineButton];
		
		self.barButton = [[CustomButton alloc] initWithFrame:CGRectMake(112, 62, 98, 30)];
		self.barButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:17];
		[self.barButton setTitle:[NSString stringWithFormat:@"%@ Bars", barChartO] forState:UIControlStateNormal];
//		[self.barButton setBackgroundImage:[UIImage imageNamed:@"barChart.png"] forState:UIControlStateNormal];
		[self.contentView addSubview:self.barButton];
		
		self.pieButton = [[CustomButton alloc] initWithFrame:CGRectMake(214, 62, 98, 30)];
		self.pieButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:17];
		[self.pieButton setTitle:[NSString stringWithFormat:@"%@ Pie", pieChart] forState:UIControlStateNormal];
//		[self.pieButton setBackgroundImage:[UIImage imageNamed:@"pieChart.png"] forState:UIControlStateNormal];
		[self.contentView addSubview:self.pieButton];
		
		self.graphImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 94, 316, 178-34)];
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
	
	[GraphSegmentCell layoutSubviews:self.titleView titleLabel:self.titleLabel topView:self.topView segmentView:self.segmentView currentYearLabel:self.currentYearLabel nextYearButton:self.nextYearButton graphImageView:self.graphImageView inBound:self.frame];
	
}

+ (void) layoutSubviews:(UIView *)titleView
			 titleLabel:(UILabel *)titleLabel
				topView:(UIView *)topView
				segmentView:(UIView *)segmentView
			 currentYearLabel:(UILabel *)currentYearLabel
		 nextYearButton:(CustomButton *)nextYearButton
		 graphImageView:(UIImageView *)graphImageView
				inBound:(CGRect) cellRect
{
	
	float width=cellRect.size.width;
	float height = cellRect.size.height;
	NSLog(@"%f %f", height, [ObjectiveCScripts chartHeightForSize:290-30]);
	
//	int height = [ObjectiveCScripts chartHeightForSize:290-30];
	
	titleView.frame = CGRectMake(0, 0, width, 20);
	titleLabel.frame = CGRectMake(0, 0, width, 20);
	topView.frame = CGRectMake(0, 20, width, 40);
	segmentView.frame = CGRectMake(0, 60, width, 34);
	currentYearLabel.frame = CGRectMake(100, 20, width-200, 40);
	nextYearButton.frame = CGRectMake(width-65, 23, 60, 34);
	graphImageView.frame = CGRectMake(2, 94, width-4, height-94);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

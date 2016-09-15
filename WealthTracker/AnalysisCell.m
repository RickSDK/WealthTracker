//
//  AnalysisCell.m
//  WealthTracker
//
//  Created by Rick Medved on 9/8/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "AnalysisCell.h"
#import "UIColor+ATTColor.h"

static NSInteger FONT_SIZE			= 14;
static NSInteger COLUMN_SEP			= 6;
static CGFloat LABEL_PROPORTION		= 0.4;
static NSInteger Y_INSET			= 5;
static NSInteger X_INSET			= 5;

@implementation AnalysisCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		float width=self.frame.size.width;

		self.bgView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, width-4, self.dataArray.count*20+35)];
		self.bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
		self.bgView.layer.cornerRadius = 8.0;
		self.bgView.layer.masksToBounds = YES;
		[self.contentView addSubview:self.bgView];

		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, 170, 22)];
		self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
		self.nameLabel.adjustsFontSizeToFitWidth = YES;
		self.nameLabel.minimumScaleFactor = .7;
		self.nameLabel.text = @"Name";
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.nameLabel];

		UIColor *faintColor = [UIColor ATTCellRowShading];
		NSMutableArray *gridViewArray = [[NSMutableArray alloc] init];

		float yPos = 30;

		UILabel *label;
		UIView *grid;
		for (int i=0; i<self.dataArray.count; i++) {
			// Add grid first so it is at the back;
			
			AnalysisObj *obj = [self.dataArray objectAtIndex:i];
			grid = [[UIView alloc] initWithFrame:CGRectMake(5, yPos, width-10, 20)];
			grid.backgroundColor = (i % 2 == 0 ? faintColor : [UIColor clearColor]);
			[gridViewArray addObject:grid];
			[self.contentView addSubview:grid];
			
			// the title
			label = [[UILabel alloc] initWithFrame:CGRectMake(0, yPos, width/2-10, 20)];
			label.font = [UIFont systemFontOfSize:FONT_SIZE];
			label.textColor = [UIColor ATTBlue];		// default dark gray color
			label.textAlignment = NSTextAlignmentRight;
			label.text = obj.title;
			label.backgroundColor = [UIColor clearColor];
//			[label setLineBreakMode:NSLineBreakByWordWrapping];
//			[label setNumberOfLines:0];
			
			[self.contentView addSubview:label];
			
			// the value
			label = [[UILabel alloc] initWithFrame:CGRectMake(width/2+10, yPos, width/2, 20)];
			label.font = [UIFont systemFontOfSize:FONT_SIZE];
			label.textColor = [UIColor blackColor];			// default black color
			label.backgroundColor = [UIColor clearColor];
			label.text = obj.value;
//			[label setLineBreakMode:NSLineBreakByWordWrapping];
//			[label setNumberOfLines:0];
			
			[self.contentView addSubview:label];
			
			UIImageView *circleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width/2-8, yPos+3, 16, 16)];
			circleImageView.image = [UIImage imageNamed:@"yellow.png"];
			[self.contentView addSubview:circleImageView];
			
			UIImage *loImage = (obj.reverseFlg)?[UIImage imageNamed:@"green.png"]:[UIImage imageNamed:@"red.png"];
			UIImage *hiImage = (obj.reverseFlg)?[UIImage imageNamed:@"red.png"]:[UIImage imageNamed:@"green.png"];
			if(obj.amount<=obj.lo)
				circleImageView.image = loImage;
			if(obj.amount>=obj.hi)
				circleImageView.image = hiImage;
			
			yPos+=20;
		}
		self.backgroundColor = [UIColor grayColor];

	}
	return self;
}

+ (CGFloat)cellHeightForData:(NSArray *)dataArray {
	return 38+dataArray.count*20;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(NSArray *)data {
	self.dataArray = data;
	return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)layoutSubviews {
	[super layoutSubviews];
//	float width=self.frame.size.width;
}


@end

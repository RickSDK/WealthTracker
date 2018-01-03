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

@implementation AnalysisCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
//		float width=self.frame.size.width;
		float width=[[UIScreen mainScreen] bounds].size.width;
//		NSLog(@"+++width: %f %f %f", width, self.frame.size.width, [[UIScreen mainScreen] bounds].size.width);
		int descHeight = [AnalysisCell descHeightForDesc:self.desc];

		self.bgView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, width-4, self.dataArray.count*20+35+descHeight)];
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
		
		self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, yPos, width-10, descHeight)];
		self.descriptionLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
		self.descriptionLabel.adjustsFontSizeToFitWidth = NO;
		self.descriptionLabel.numberOfLines = 0;
		self.descriptionLabel.text = self.desc;
		self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
		self.descriptionLabel.textColor = [UIColor blackColor];
		self.descriptionLabel.backgroundColor = [UIColor colorWithWhite:.93 alpha:1];
		[self.contentView addSubview:self.descriptionLabel];
		
		self.backgroundColor = [UIColor grayColor];

	}
	return self;
}

+(CGFloat)descHeightForDesc:(NSString *)desc {
	CGSize labelSize = [desc sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE]
								constrainedToSize:CGSizeMake(310, 1000)
									lineBreakMode:NSLineBreakByWordWrapping];
	
	CGFloat labelHeight = labelSize.height;
	return labelHeight+8;
}

+ (CGFloat)cellHeightForData:(NSArray *)dataArray desc:(NSString *)desc  {
	return 38+dataArray.count*20+[self descHeightForDesc:desc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(NSArray *)data desc:(NSString *)desc {
	self.dataArray = data;
	self.desc = desc;
	return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	float width=self.contentView.bounds.size.width;
//	float width=self.frame.size.width;
	int descHeight = [AnalysisCell descHeightForDesc:self.desc];
	self.bgView.frame = CGRectMake(2, 2, width-4, self.dataArray.count*20+35+descHeight);
	self.descriptionLabel.frame = CGRectMake(5, 30+self.dataArray.count*20, width-10, descHeight);
}


@end

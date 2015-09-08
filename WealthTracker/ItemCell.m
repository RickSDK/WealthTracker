//
//  ItemCell.m
//  WealthTracker
//
//  Created by Rick Medved on 7/12/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "ItemCell.h"
#import "ObjectiveCScripts.h"

@implementation ItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.bgView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 316, 55)];
		self.bgView.backgroundColor=[UIColor whiteColor];
		self.bgView.layer.cornerRadius = 7.0;
		self.bgView.layer.masksToBounds = YES;				// clips background images to rounded corners
		self.bgView.layer.borderColor = [ObjectiveCScripts mediumkColor].CGColor;
		self.bgView.layer.borderWidth = 1.;
		[self.contentView addSubview:self.bgView];
		
		self.valStatusImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
		self.valStatusImage.image = [UIImage imageNamed:@"red.png"];
		self.valStatusImage.alpha=1;
		[self.contentView addSubview:self.valStatusImage];
		
		self.balStatusImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 5, 25, 25)];
		self.balStatusImage.image = [UIImage imageNamed:@"red.png"];
		self.balStatusImage.alpha=1;
		[self.contentView addSubview:self.balStatusImage];
		
		self.typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 30, 25, 25)];
		self.typeImageView.image = [UIImage imageNamed:@"asset.png"];
		self.typeImageView.alpha=1;
		[self.contentView addSubview:self.typeImageView];

		
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 1, 163, 22)];
		self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
		self.nameLabel.adjustsFontSizeToFitWidth = YES;
		self.nameLabel.minimumScaleFactor = .8;
		self.nameLabel.text = @"Name";
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.nameLabel];

		self.subTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 19, 100, 22)];
		self.subTypeLabel.font = [UIFont boldSystemFontOfSize:14];
		self.subTypeLabel.adjustsFontSizeToFitWidth = YES;
		self.subTypeLabel.minimumScaleFactor = .8;
		self.subTypeLabel.text = @"Type";
		self.subTypeLabel.textAlignment = NSTextAlignmentLeft;
		self.subTypeLabel.textColor = [ObjectiveCScripts darkColor];
		self.subTypeLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.subTypeLabel];

		UILabel * amountLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(66, 36, 163, 22)];
		amountLabel1.backgroundColor = [UIColor clearColor];
		amountLabel1.textAlignment = NSTextAlignmentLeft;
		amountLabel1.textColor = [UIColor grayColor];
		amountLabel1.font = [UIFont systemFontOfSize:10];
		amountLabel1.text = @"Equity:";
		[self.contentView addSubview:amountLabel1];

		self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 36, 163, 22)];
		self.amountLabel.font = [UIFont boldSystemFontOfSize:15];
		self.amountLabel.adjustsFontSizeToFitWidth = YES;
		self.amountLabel.minimumScaleFactor = .8;
		self.amountLabel.text = @"amountLabel";
		self.amountLabel.textAlignment = NSTextAlignmentLeft;
		self.amountLabel.textColor = [UIColor purpleColor];
		self.amountLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.amountLabel];
		
		UILabel * amountTopLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, -2, 140, 22)];
		amountTopLabel.backgroundColor = [UIColor clearColor];
		amountTopLabel.textAlignment = NSTextAlignmentRight;
		amountTopLabel.textColor = [UIColor grayColor];
		amountTopLabel.font = [UIFont systemFontOfSize:9];
		amountTopLabel.text = @"Change This Month";
		[self.contentView addSubview:amountTopLabel];
		
		self.last30Label = [[UILabel alloc] initWithFrame:CGRectMake(210, 12, 100, 22)];
		self.last30Label.font = [UIFont boldSystemFontOfSize:17];
		self.last30Label.adjustsFontSizeToFitWidth = YES;
		self.last30Label.minimumScaleFactor = .8;
		self.last30Label.text = @"last30Label";
		self.last30Label.textAlignment = NSTextAlignmentCenter;
		self.last30Label.textColor = [UIColor purpleColor];
		self.last30Label.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.last30Label];
		
		self.statement_dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 28, 100, 22)];
		self.statement_dayLabel.font = [UIFont boldSystemFontOfSize:15];
		self.statement_dayLabel.adjustsFontSizeToFitWidth = YES;
		self.statement_dayLabel.minimumScaleFactor = .8;
		self.statement_dayLabel.text = @"Day";
		self.statement_dayLabel.textAlignment = NSTextAlignmentCenter;
		self.statement_dayLabel.textColor = [UIColor blackColor];
		self.statement_dayLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.statement_dayLabel];
		
		self.statement_dayLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(210, 40, 100, 22)];
		self.statement_dayLabel2.font = [UIFont boldSystemFontOfSize:8];
		self.statement_dayLabel2.adjustsFontSizeToFitWidth = YES;
		self.statement_dayLabel2.minimumScaleFactor = .8;
		self.statement_dayLabel2.text = @"Statement Day";
		self.statement_dayLabel2.textAlignment = NSTextAlignmentCenter;
		self.statement_dayLabel2.textColor = [ObjectiveCScripts darkColor];
		self.statement_dayLabel2.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.statement_dayLabel2];
		
		self.backgroundColor=[UIColor colorWithWhite:.7 alpha:1];
		
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

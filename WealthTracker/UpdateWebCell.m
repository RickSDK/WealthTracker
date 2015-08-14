//
//  UpdateWebCell.m
//  WealthTracker
//
//  Created by Rick Medved on 7/23/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "UpdateWebCell.h"
#import "ObjectiveCScripts.h"

@implementation UpdateWebCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		
		self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 40, 40)];
		self.iconImageView.image = [UIImage imageNamed:@"asset.png"];
		self.iconImageView.alpha=1;
		self.iconImageView.layer.cornerRadius = 8.0;
		self.iconImageView.layer.masksToBounds = YES;
		self.iconImageView.layer.borderColor = [UIColor blackColor].CGColor;
		self.iconImageView.layer.borderWidth = 2.0;
		self.iconImageView.backgroundColor=[UIColor colorWithWhite:.8 alpha:1];
		[self.contentView addSubview:self.iconImageView];
		
		self.updateButton = [[CustomButton alloc] initWithFrame:CGRectMake(75, 5, 200, 40)];
		[self.updateButton setTitle:@"Check on Web" forState:UIControlStateNormal];
		[self.contentView addSubview:self.updateButton];

		self.statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(285, 10, 20, 20)];
		self.statusImageView.image = [UIImage imageNamed:@"red.png"];
		[self.contentView addSubview:self.statusImageView];

		self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, 320, 44)];
		self.messageLabel.font = [UIFont boldSystemFontOfSize:15];
		self.messageLabel.adjustsFontSizeToFitWidth = YES;
		self.messageLabel.minimumScaleFactor = .8;
		self.messageLabel.text = @"It is best to update the value on the same day each month.";
		self.messageLabel.textAlignment = NSTextAlignmentCenter;
		self.messageLabel.numberOfLines=2;
		self.messageLabel.textColor = [UIColor whiteColor];
		self.messageLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.messageLabel];
		

		self.backgroundColor = [ObjectiveCScripts mediumkColor];
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

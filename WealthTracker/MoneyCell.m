//
//  MoneyCell.m
//  WealthTracker
//
//  Created by Rick Medved on 7/10/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "MoneyCell.h"

@implementation MoneyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.bgView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 316, 106)];
		self.bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
		self.bgView.layer.cornerRadius = 8.0;
		self.bgView.layer.masksToBounds = YES;
		self.bgView.layer.borderColor = [UIColor blackColor].CGColor;
		self.bgView.layer.borderWidth = 2.0;
		[self.contentView addSubview:self.bgView];
		
		self.statusImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
		self.statusImage.image = [UIImage imageNamed:@"red.png"];
		self.statusImage.alpha=1;
		[self.contentView addSubview:self.statusImage];
		
		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 6, 163, 22)];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
		self.titleLabel.adjustsFontSizeToFitWidth = YES;
		self.titleLabel.minimumScaleFactor = .8;
		self.titleLabel.text = @"Title";
		self.titleLabel.textAlignment = NSTextAlignmentLeft;
		self.titleLabel.textColor = [UIColor blackColor];
		self.titleLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.titleLabel];
		
		self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 29, 151, 27)];
		self.amountLabel.font = [UIFont boldSystemFontOfSize:24];
		self.amountLabel.adjustsFontSizeToFitWidth = YES;
		self.amountLabel.minimumScaleFactor = .8;
		self.amountLabel.text = @"Amount";
		self.amountLabel.textAlignment = NSTextAlignmentLeft;
		self.amountLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
		self.amountLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.amountLabel];
		
		self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 56, 288, 46)];
		self.descLabel.font = [UIFont boldSystemFontOfSize:17];
		self.descLabel.adjustsFontSizeToFitWidth = YES;
		self.descLabel.minimumScaleFactor = .8;
		self.descLabel.text = @"Desc";
		self.descLabel.numberOfLines=3;
		self.descLabel.textAlignment = NSTextAlignmentLeft;
		self.descLabel.textColor = [UIColor colorWithRed:0 green:.2 blue:.6 alpha:1];
		self.descLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.descLabel];
		
		self.updateButton = [[CustomButton alloc] initWithFrame:CGRectMake(235, 20, 75, 35)];
		[self.updateButton setTitle:@"Update" forState:UIControlStateNormal];
		[self.contentView addSubview:self.updateButton];
	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];

	float width=self.frame.size.width;
	
	self.bgView.frame = CGRectMake(2, 2, width-4, 126);
	self.updateButton.frame = CGRectMake(width-85, 20, 75, 35);
	self.descLabel.frame = CGRectMake(8, 56, width-32, 61);

}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

@end

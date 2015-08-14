//
//  UpdateCell.m
//  WealthTracker
//
//  Created by Rick Medved on 7/15/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "UpdateCell.h"
#import "ObjectiveCScripts.h"

@implementation UpdateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {

		self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
		self.topView.backgroundColor = [ObjectiveCScripts mediumkColor];
		[self.contentView addSubview:self.topView];
		
		self.currentYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 1, 120, 30)];
		self.currentYearLabel.font = [UIFont boldSystemFontOfSize:20];
		self.currentYearLabel.adjustsFontSizeToFitWidth = YES;
		self.currentYearLabel.minimumScaleFactor = .8;
		self.currentYearLabel.text = @"2015";
		self.currentYearLabel.textAlignment = NSTextAlignmentCenter;
		self.currentYearLabel.textColor = [UIColor whiteColor];
		self.currentYearLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.currentYearLabel];
		
		self.prevYearButton = [[CustomButton alloc] initWithFrame:CGRectMake(5, 1, 60, 30)];
		[self.prevYearButton setTitle:@"Prev" forState:UIControlStateNormal];
		[self.contentView addSubview:self.prevYearButton];
		
		self.nextYearButton = [[CustomButton alloc] initWithFrame:CGRectMake(255, 1, 60, 30)];
		[self.nextYearButton setTitle:@"Next" forState:UIControlStateNormal];
		[self.contentView addSubview:self.nextYearButton];
		

		self.valueStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 35, 30, 30)];
		self.valueStatusImageView.image = [UIImage imageNamed:@"red.png"];
		self.valueStatusImageView.alpha=1;
		[self.contentView addSubview:self.valueStatusImageView];
		
		self.balanceStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 85, 30, 30)];
		self.balanceStatusImageView.image = [UIImage imageNamed:@"red.png"];
		self.balanceStatusImageView.alpha=1;
		[self.contentView addSubview:self.balanceStatusImageView];
		
		self.valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 35, 150, 30)];
		self.valueTextField.borderStyle = UITextBorderStyleRoundedRect;
		self.valueTextField.textAlignment = NSTextAlignmentLeft;
		self.valueTextField.keyboardType = UIKeyboardTypeNumberPad;
		self.valueTextField.font = [UIFont systemFontOfSize:16];
		self.valueTextField.clearButtonMode = UITextFieldViewModeAlways;
		self.valueTextField.clearsOnBeginEditing=YES;
		[self.contentView addSubview:self.valueTextField];
		
		self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 61, 150, 22)];
		self.valueLabel.font = [UIFont boldSystemFontOfSize:16];
		self.valueLabel.adjustsFontSizeToFitWidth = YES;
		self.valueLabel.minimumScaleFactor = .8;
		self.valueLabel.text = @"Current Value";
		self.valueLabel.textAlignment = NSTextAlignmentCenter;
		self.valueLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1.0];
		self.valueLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.valueLabel];
		
		self.loanAmountTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 85, 150, 30)];
		self.loanAmountTextField.borderStyle = UITextBorderStyleRoundedRect;
		self.loanAmountTextField.textAlignment = NSTextAlignmentLeft;
		self.loanAmountTextField.keyboardType = UIKeyboardTypeNumberPad;
		self.loanAmountTextField.clearButtonMode = UITextFieldViewModeAlways;
		self.loanAmountTextField.font = [UIFont systemFontOfSize:16];
		self.loanAmountTextField.clearsOnBeginEditing=YES;
		[self.contentView addSubview:self.loanAmountTextField];
		
		self.loanAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 111, 150, 22)];
		self.loanAmountLabel.font = [UIFont boldSystemFontOfSize:16];
		self.loanAmountLabel.adjustsFontSizeToFitWidth = YES;
		self.loanAmountLabel.minimumScaleFactor = .8;
		self.loanAmountLabel.text = @"Loan Balance";
		self.loanAmountLabel.textAlignment = NSTextAlignmentCenter;
		self.loanAmountLabel.textColor = [UIColor redColor];
		self.loanAmountLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.loanAmountLabel];

		self.updateValueButton = [[CustomButton alloc] initWithFrame:CGRectMake(205, 35, 100, 30)];
		[self.updateValueButton setTitle:@"Update" forState:UIControlStateNormal];
		[self.contentView addSubview:self.updateValueButton];

		self.updateBalanceButton = [[CustomButton alloc] initWithFrame:CGRectMake(205, 85, 100, 30)];
		[self.updateBalanceButton setTitle:@"Update" forState:UIControlStateNormal];
		[self.contentView addSubview:self.updateBalanceButton];

		self.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];

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

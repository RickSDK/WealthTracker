//
//  CashFlowCell.m
//  WealthTracker
//
//  Created by Rick Medved on 8/3/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "CashFlowCell.h"

@implementation CashFlowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
		self.dayLabel.font = [UIFont boldSystemFontOfSize:20];
		self.dayLabel.adjustsFontSizeToFitWidth = YES;
		self.dayLabel.minimumScaleFactor = .8;
		self.dayLabel.text = @"15";
		self.dayLabel.textAlignment = NSTextAlignmentCenter;
		self.dayLabel.textColor = [UIColor purpleColor];
		self.dayLabel.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
		self.dayLabel.layer.cornerRadius = 8.0;
		self.dayLabel.layer.masksToBounds = YES;
		self.dayLabel.layer.borderColor = [UIColor blackColor].CGColor;
		self.dayLabel.layer.borderWidth = 1.0;
		[self.contentView addSubview:self.dayLabel];
		
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 150, 30)];
		self.nameLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18.f];
		self.nameLabel.adjustsFontSizeToFitWidth = YES;
		self.nameLabel.minimumScaleFactor = .8;
		self.nameLabel.text = @"name";
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.nameLabel];
		
		self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 100, 25)];
		self.amountLabel.font = [UIFont boldSystemFontOfSize:20];
		self.amountLabel.adjustsFontSizeToFitWidth = YES;
		self.amountLabel.minimumScaleFactor = .8;
		self.amountLabel.text = @"$100";
		self.amountLabel.textAlignment = NSTextAlignmentRight;
		self.amountLabel.textColor = [UIColor greenColor];
		self.amountLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.amountLabel];
		
		self.amountRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 25, 100, 20)];
		self.amountRemainingLabel.font = [UIFont boldSystemFontOfSize:16];
		self.amountRemainingLabel.adjustsFontSizeToFitWidth = YES;
		self.amountRemainingLabel.minimumScaleFactor = .8;
		self.amountRemainingLabel.text = @"$100";
		self.amountRemainingLabel.textAlignment = NSTextAlignmentRight;
		self.amountRemainingLabel.textColor = [UIColor greenColor];
		self.amountRemainingLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.amountRemainingLabel];
		
		self.checkMarkButton = [[CustomButton alloc] initWithFrame:CGRectMake(285, 5, 30, 34)];
		[self.checkMarkButton setBackgroundImage:[UIImage imageNamed:@"checkMark.jpg"] forState:UIControlStateNormal];
		[self.contentView addSubview:self.checkMarkButton];
		
	}
	return self;
}

+(void)populateCell:(CashFlowCell *)cell obj:(CashFlowObj *)obj {
	cell.dayLabel.text = [NSString stringWithFormat:@"%d", obj.statement_day];
	
	
	if(obj.confirmFlg) {
		cell.backgroundColor=[UIColor colorWithWhite:.7 alpha:1];
		[cell.checkMarkButton setBackgroundImage:[UIImage imageNamed:@"checkMark.jpg"] forState:UIControlStateNormal];
	} else {
		[cell.checkMarkButton setBackgroundImage:nil forState:UIControlStateNormal];
		if(obj.amount>=0)
			cell.backgroundColor=[UIColor colorWithRed:.9 green:1 blue:.9 alpha:1];
		else
			cell.backgroundColor=[UIColor colorWithRed:1 green:.9 blue:.9 alpha:1];
	}
	
	cell.amountLabel.textColor = [ObjectiveCScripts colorBasedOnNumber:obj.amount lightFlg:NO];

	if(obj.amount<0) {
		cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [self fASymbolForType:obj.type], obj.name];
		obj.amount*=-1;
	} else {
		cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAMoney], obj.name];
	}
	cell.amountLabel.text = [ObjectiveCScripts convertNumberToMoneyString:obj.amount];
	

	
	cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
}

+(NSString *)fASymbolForType:(int)type {
	NSString *icon = [NSString fontAwesomeIconStringForEnum:FACalendar];
	switch (type) {
			
  case 0:
			icon = [NSString fontAwesomeIconStringForEnum:FAHome]; // home
			break;
  case 1:
			icon = [NSString fontAwesomeIconStringForEnum:FAplug]; // power/util
			break;
  case 2:
			icon = [NSString fontAwesomeIconStringForEnum:FAtelevision]; // cable
			break;
  case 3:
			icon = [NSString fontAwesomeIconStringForEnum:FAPhone]; // phone
			break;
  case 4:
			icon = [NSString fontAwesomeIconStringForEnum:FAcar]; // vehicle
			break;
  case 5:
			icon = [NSString fontAwesomeIconStringForEnum:FAheartbeat]; // gym
			break;
  case 6:
			icon = [NSString fontAwesomeIconStringForEnum:FACreditCard]; // cc
			break;
  case 7:
			icon = [NSString fontAwesomeIconStringForEnum:FAinternetExplorer]; // internet
			break;
  case 8:
			icon = [NSString fontAwesomeIconStringForEnum:FAUsd]; // other
			break;
			
			
			
  default:
			break;
	}
	return icon;
}

+(NSString *)fANameForType:(int)type {
	NSString *icon = @"Unknown";
	switch (type) {
			
  case 0:
			icon = @"Real Estate"; // home
			break;
  case 1:
			icon = @"Utilities"; // power/util
			break;
  case 2:
			icon = @"Cable"; // cable
			break;
  case 3:
			icon = @"Phone"; // phone
			break;
  case 4:
			icon = @"Vehicle"; // vehicle
			break;
  case 5:
			icon = @"Gym"; // gym
			break;
  case 6:
			icon = @"Credit Card"; // cc
			break;
  case 7:
			icon = @"Internet"; // internet
			break;
  case 8:
			icon = @"Other"; // other
			break;
			
			
			
  default:
			break;
	}
	return icon;
}


@end

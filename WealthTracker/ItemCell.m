//
//  ItemCell.m
//  WealthTracker
//
//  Created by Rick Medved on 7/12/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "ItemCell.h"

#define kleftEdge	58
#define kTopEdge	2

@implementation ItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		
		self.bgView = [[UIView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:self.bgView];
		
		self.statement_dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 9, 25, 25)];
		self.statement_dayLabel.font = [UIFont boldSystemFontOfSize:15];
		self.statement_dayLabel.adjustsFontSizeToFitWidth = YES;
		self.statement_dayLabel.minimumScaleFactor = .8;
		self.statement_dayLabel.layer.cornerRadius = 12;
		self.statement_dayLabel.layer.masksToBounds = YES;				// clips background images to rounded corners
		self.statement_dayLabel.text = @"15";
		self.statement_dayLabel.textAlignment = NSTextAlignmentCenter;
		self.statement_dayLabel.textColor = [UIColor whiteColor];
		self.statement_dayLabel.backgroundColor = [UIColor redColor];
		[self.contentView addSubview:self.statement_dayLabel];

		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, kTopEdge-2, 170, 22)];
		self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
		self.nameLabel.adjustsFontSizeToFitWidth = YES;
		self.nameLabel.minimumScaleFactor = .7;
		self.nameLabel.text = @"Name";
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.nameLabel];
		
		

		self.subTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, kTopEdge+20, 140, 22)];
		self.subTypeLabel.font = [UIFont boldSystemFontOfSize:14];
		self.subTypeLabel.adjustsFontSizeToFitWidth = YES;
		self.subTypeLabel.minimumScaleFactor = .8;
		self.subTypeLabel.text = @"Type";
		self.subTypeLabel.textAlignment = NSTextAlignmentLeft;
		self.subTypeLabel.textColor = [ObjectiveCScripts darkColor];
		self.subTypeLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.subTypeLabel];
		
//		float kRow1 = kTopEdge+30;
//		float kRow2 = kTopEdge+30+15;
//		float kRow3 = kTopEdge+32+30;

		self.arrowLabel = [[UILabel alloc] initWithFrame:CGRectMake(293, 17, 20, 30)];
		self.arrowLabel.font = [UIFont boldSystemFontOfSize:20];
		self.arrowLabel.adjustsFontSizeToFitWidth = YES;
		self.arrowLabel.minimumScaleFactor = .7;
		self.arrowLabel.text = @"U";
		self.arrowLabel.textAlignment = NSTextAlignmentCenter;
		self.arrowLabel.textColor = [UIColor blackColor];
		self.arrowLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.arrowLabel];


		self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, kTopEdge-2, 120, 22)];
		self.rightLabel.backgroundColor = [UIColor clearColor];
		self.rightLabel.textAlignment = NSTextAlignmentCenter;
		self.rightLabel.textColor = [UIColor blackColor];
		self.rightLabel.font = [UIFont boldSystemFontOfSize:11];
		self.rightLabel.text = @"This Month";
		[self.contentView addSubview:self.rightLabel];

		
		float kCol2 = kleftEdge+150;
		
		
		self.equityLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCol2, 2, 100, 22)];
		self.equityLabel.font = [UIFont boldSystemFontOfSize:17];
		self.equityLabel.adjustsFontSizeToFitWidth = YES;
		self.equityLabel.minimumScaleFactor = .8;
		self.equityLabel.text = @"$0";
		self.equityLabel.textAlignment = NSTextAlignmentCenter;
		self.equityLabel.textColor = [UIColor purpleColor];
		self.equityLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.equityLabel];
		
		self.equityChangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCol2, 22, 100, 22)];
		self.equityChangeLabel.font = [UIFont systemFontOfSize:14];
		self.equityChangeLabel.adjustsFontSizeToFitWidth = YES;
		self.equityChangeLabel.minimumScaleFactor = .8;
		self.equityChangeLabel.text = @"$0";
		self.equityChangeLabel.textAlignment = NSTextAlignmentCenter;
		self.equityChangeLabel.textColor = [UIColor purpleColor];
		self.equityChangeLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.equityChangeLabel];
		
		
		
		self.backgroundColor=[UIColor colorWithWhite:.7 alpha:1];
		
	}
	return self;
}

+(void)updateCell:(ItemCell *)cell obj:(ItemObject *)obj {
	cell.nameLabel.text = obj.name;
	cell.subTypeLabel.text = obj.sub_type;
	
	[ObjectiveCScripts displayMoneyLabel:cell.balanceLabel amount:[obj.loan_balance doubleValue] lightFlg:NO revFlg:YES];
	[ObjectiveCScripts displayNetChangeLabel:cell.balanceChangeLabel amount:obj.balanceChange lightFlg:NO revFlg:YES];
	
	[ObjectiveCScripts displayMoneyLabel:cell.valueLabel amount:obj.value lightFlg:NO revFlg:NO];
	[ObjectiveCScripts displayNetChangeLabel:cell.valueChangeLabel amount:obj.valueChange lightFlg:NO revFlg:NO];
	
	[ObjectiveCScripts displayMoneyLabel:cell.equityLabel amount:obj.equity lightFlg:NO revFlg:NO];
	[ObjectiveCScripts displayNetChangeLabel:cell.equityChangeLabel amount:obj.equityChange lightFlg:NO revFlg:NO];
	
	cell.statement_dayLabel.backgroundColor = [self colorForStatus:obj.status];
	cell.statement_dayLabel.textColor =  (obj.status==1)?[UIColor blackColor]:[UIColor whiteColor];
	
	if([obj.statement_day intValue]==0) {
		cell.statement_dayLabel.text=@"";
		cell.statement_dayLabel2.text=@"";
	} else {
		cell.statement_dayLabel.text = obj.statement_day;
		cell.statement_dayLabel2.text = @"Due Day";
	}

	cell.balanceLabel.hidden=YES;
	cell.balanceChangeLabel.hidden=YES;
	cell.valueLabel.hidden=YES;
	cell.valueChangeLabel.hidden=YES;
	cell.equityLabel.hidden=NO;
	cell.equityChangeLabel.hidden=NO;

	cell.typeImageView.image = [ObjectiveCScripts imageIconForType:obj.type];
	
}

+(UIColor *)colorForStatus:(int)status {
	if(status == 1)
		return [UIColor yellowColor];
	else if(status == 2)
		return [UIColor redColor];
	
	return [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
}


- (void)layoutSubviews {
	
	[super layoutSubviews];
	float width=self.frame.size.width;
	self.bgView.frame = CGRectMake(0, 0, width, 48);
	self.rightLabel.frame = CGRectMake(width-110, 0, 100, 15);
	self.equityLabel.frame = CGRectMake(width-110, 10, 100, 22);
	self.equityChangeLabel.frame = CGRectMake(width-110, 25, 100, 22);
	self.arrowLabel.frame = CGRectMake(width-27, 17, 20, 30);
	
	
}


@end

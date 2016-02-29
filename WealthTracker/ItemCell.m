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
		self.bgView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 316, 90)];
		self.bgView.backgroundColor=[UIColor whiteColor];
		self.bgView.layer.cornerRadius = 7.0;
		self.bgView.layer.masksToBounds = YES;				// clips background images to rounded corners
		self.bgView.layer.borderColor = [ObjectiveCScripts mediumkColor].CGColor;
		self.bgView.layer.borderWidth = 1.;
		[self.contentView addSubview:self.bgView];
		
		self.redLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 85, 316, 5)];
		self.redLineView.backgroundColor=[UIColor redColor];
		[self.bgView addSubview:self.redLineView];
		
		self.valStatusImage = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3+15, 50, 50)];
		self.valStatusImage.image = [UIImage imageNamed:@"red.png"];
		self.valStatusImage.alpha=1;
		[self.bgView addSubview:self.valStatusImage];
		
		self.typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 15+15, 25, 25)];
		self.typeImageView.image = [UIImage imageNamed:@"asset.png"];
		self.typeImageView.alpha=1;
		[self.bgView addSubview:self.typeImageView];

		
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kleftEdge, kTopEdge-2, 150, 22)];
		self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
		self.nameLabel.adjustsFontSizeToFitWidth = YES;
		self.nameLabel.minimumScaleFactor = .7;
		self.nameLabel.text = @"Name";
		self.nameLabel.textAlignment = NSTextAlignmentLeft;
		self.nameLabel.textColor = [UIColor blackColor];
		self.nameLabel.backgroundColor = [UIColor clearColor];
		[self.bgView addSubview:self.nameLabel];

		self.subTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kleftEdge, kTopEdge+15, 140, 22)];
		self.subTypeLabel.font = [UIFont boldSystemFontOfSize:14];
		self.subTypeLabel.adjustsFontSizeToFitWidth = YES;
		self.subTypeLabel.minimumScaleFactor = .8;
		self.subTypeLabel.text = @"Type";
		self.subTypeLabel.textAlignment = NSTextAlignmentLeft;
		self.subTypeLabel.textColor = [ObjectiveCScripts darkColor];
		self.subTypeLabel.backgroundColor = [UIColor clearColor];
		[self.bgView addSubview:self.subTypeLabel];
		
		float kRow1 = kTopEdge+30;
		float kRow2 = kTopEdge+30+15;
		float kRow3 = kTopEdge+32+30;

		UILabel * balanceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kleftEdge, kRow1, 163, 22)];
		balanceNameLabel.backgroundColor = [UIColor clearColor];
		balanceNameLabel.textAlignment = NSTextAlignmentLeft;
		balanceNameLabel.textColor = [UIColor grayColor];
		balanceNameLabel.font = [UIFont systemFontOfSize:10];
		balanceNameLabel.text = @"Balance:";
		[self.bgView addSubview:balanceNameLabel];
		
		UILabel * valueNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kleftEdge, kRow2+1, 163, 22)];
		valueNameLabel.backgroundColor = [UIColor clearColor];
		valueNameLabel.textAlignment = NSTextAlignmentLeft;
		valueNameLabel.textColor = [UIColor grayColor];
		valueNameLabel.font = [UIFont systemFontOfSize:10];
		valueNameLabel.text = @"Value:";
		[self.bgView addSubview:valueNameLabel];
		
		UILabel * equityNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kleftEdge, kRow3, 163, 22)];
		equityNameLabel.backgroundColor = [UIColor clearColor];
		equityNameLabel.textAlignment = NSTextAlignmentLeft;
		equityNameLabel.textColor = [UIColor grayColor];
		equityNameLabel.font = [UIFont systemFontOfSize:10];
		equityNameLabel.text = @"Equity:";
		[self.bgView addSubview:equityNameLabel];
		
		float kCol1 = kleftEdge+75;
		float kCol2 = kleftEdge+150;
		
		self.balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCol1, kRow1, 163, 22)];
		self.balanceLabel.font = [UIFont systemFontOfSize:15];
		self.balanceLabel.adjustsFontSizeToFitWidth = YES;
		self.balanceLabel.minimumScaleFactor = .8;
		self.balanceLabel.text = @"";
		self.balanceLabel.textAlignment = NSTextAlignmentLeft;
		self.balanceLabel.textColor = [UIColor redColor];
		self.balanceLabel.backgroundColor = [UIColor clearColor];
		[self.bgView addSubview:self.balanceLabel];
		
		self.balanceChangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCol2, kRow1, 100, 22)];
		self.balanceChangeLabel.font = [UIFont systemFontOfSize:15];
		self.balanceChangeLabel.adjustsFontSizeToFitWidth = YES;
		self.balanceChangeLabel.minimumScaleFactor = .8;
		self.balanceChangeLabel.text = @"";
		self.balanceChangeLabel.textAlignment = NSTextAlignmentCenter;
		self.balanceChangeLabel.textColor = [UIColor blackColor];
		self.balanceChangeLabel.backgroundColor = [UIColor clearColor];
		[self.bgView addSubview:self.balanceChangeLabel];
		
		self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCol1, kRow2, 163, 22)];
		self.valueLabel.font = [UIFont systemFontOfSize:15];
		self.valueLabel.adjustsFontSizeToFitWidth = YES;
		self.valueLabel.minimumScaleFactor = .8;
		self.valueLabel.text = @"";
		self.valueLabel.textAlignment = NSTextAlignmentLeft;
		self.valueLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
		self.valueLabel.backgroundColor = [UIColor clearColor];
		[self.bgView addSubview:self.valueLabel];
		
		self.valueChangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCol2, kRow2, 100, 22)];
		self.valueChangeLabel.font = [UIFont systemFontOfSize:15];
		self.valueChangeLabel.adjustsFontSizeToFitWidth = YES;
		self.valueChangeLabel.minimumScaleFactor = .8;
		self.valueChangeLabel.text = @"";
		self.valueChangeLabel.textAlignment = NSTextAlignmentCenter;
		self.valueChangeLabel.textColor = [UIColor blackColor];
		self.valueChangeLabel.backgroundColor = [UIColor clearColor];
		[self.bgView addSubview:self.valueChangeLabel];
		
		self.equityLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCol1, kRow3, 163, 22)];
		self.equityLabel.font = [UIFont boldSystemFontOfSize:17];
		self.equityLabel.adjustsFontSizeToFitWidth = YES;
		self.equityLabel.minimumScaleFactor = .8;
		self.equityLabel.text = @"amountLabel";
		self.equityLabel.textAlignment = NSTextAlignmentLeft;
		self.equityLabel.textColor = [UIColor purpleColor];
		self.equityLabel.backgroundColor = [UIColor clearColor];
		[self.bgView addSubview:self.equityLabel];
		
		self.equityChangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCol2, kRow3, 100, 22)];
		self.equityChangeLabel.font = [UIFont boldSystemFontOfSize:17];
		self.equityChangeLabel.adjustsFontSizeToFitWidth = YES;
		self.equityChangeLabel.minimumScaleFactor = .8;
		self.equityChangeLabel.text = @"last30Label";
		self.equityChangeLabel.textAlignment = NSTextAlignmentCenter;
		self.equityChangeLabel.textColor = [UIColor purpleColor];
		self.equityChangeLabel.backgroundColor = [UIColor clearColor];
		[self.bgView addSubview:self.equityChangeLabel];
		
		self.statement_dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, kTopEdge, 100, 22)];
		self.statement_dayLabel.font = [UIFont boldSystemFontOfSize:15];
		self.statement_dayLabel.adjustsFontSizeToFitWidth = YES;
		self.statement_dayLabel.minimumScaleFactor = .8;
		self.statement_dayLabel.text = @"Day";
		self.statement_dayLabel.textAlignment = NSTextAlignmentCenter;
		self.statement_dayLabel.textColor = [UIColor blackColor];
		self.statement_dayLabel.backgroundColor = [UIColor clearColor];
		[self.bgView addSubview:self.statement_dayLabel];
		
		self.statement_dayLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(210, kTopEdge+11, 100, 22)];
		self.statement_dayLabel2.font = [UIFont boldSystemFontOfSize:8];
		self.statement_dayLabel2.adjustsFontSizeToFitWidth = YES;
		self.statement_dayLabel2.minimumScaleFactor = .8;
		self.statement_dayLabel2.text = @"Statement Day";
		self.statement_dayLabel2.textAlignment = NSTextAlignmentCenter;
		self.statement_dayLabel2.textColor = [ObjectiveCScripts darkColor];
		self.statement_dayLabel2.backgroundColor = [UIColor clearColor];
		[self.bgView addSubview:self.statement_dayLabel2];
		
		self.backgroundColor=[UIColor colorWithWhite:.7 alpha:1];
		
	}
	return self;
}

+(void)updateCell:(ItemCell *)cell obj:(ItemObject *)obj {
	cell.nameLabel.text = obj.name;
	cell.subTypeLabel.text = obj.sub_type;
	
	if(obj.equityChange>0 && obj.status==0)
		cell.bgView.layer.borderColor = [UIColor colorWithRed:0 green:.6 blue:0 alpha:1].CGColor;
	if(obj.equityChange<0)
		cell.bgView.layer.borderColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1].CGColor;
	
	[ObjectiveCScripts displayMoneyLabel:cell.balanceLabel amount:[obj.loan_balance doubleValue] lightFlg:NO revFlg:YES];
	[ObjectiveCScripts displayNetChangeLabel:cell.balanceChangeLabel amount:obj.balanceChange lightFlg:NO revFlg:YES];
	
	[ObjectiveCScripts displayMoneyLabel:cell.valueLabel amount:obj.value lightFlg:NO revFlg:NO];
	[ObjectiveCScripts displayNetChangeLabel:cell.valueChangeLabel amount:obj.valueChange lightFlg:NO revFlg:NO];
	
	[ObjectiveCScripts displayMoneyLabel:cell.equityLabel amount:obj.equity lightFlg:NO revFlg:NO];
	[ObjectiveCScripts displayNetChangeLabel:cell.equityChangeLabel amount:obj.equityChange lightFlg:NO revFlg:NO];
	
	cell.valStatusImage.image = [ObjectiveCScripts imageForStatus:obj.status];
	
	if([obj.statement_day intValue]==0) {
		cell.statement_dayLabel.text=@"";
		cell.statement_dayLabel2.text=@"";
	} else {
		cell.statement_dayLabel.text = obj.statement_day;
		cell.statement_dayLabel2.text = @"Statement Day";
	}
	
	cell.typeImageView.image = [ObjectiveCScripts imageIconForType:obj.type];
	
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

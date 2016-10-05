//
//  RateVC.m
//  WealthTracker
//
//  Created by Rick Medved on 9/15/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "RateVC.h"
#import "ObjectiveCScripts.h"
#import "GraphLib.h"
#import "GraphObject.h"

@interface RateVC ()

@end

@implementation RateVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Rate"];
	
	[self setupData];
	
}

-(double)addAmountForType:(int)type label:(UILabel *)label mySwitch:(UISwitch *)mySwitch month:(int)month nowMonth:(int)nowMonth year:(int)year {
	double amount = [ObjectiveCScripts changedForItem:0 month:month year:year field:@"" context:self.managedObjectContext numMonths:1 type:type];
	
	if(month==nowMonth)
		[ObjectiveCScripts displayNetChangeLabel:label amount:amount lightFlg:NO revFlg:NO];
	
	if(mySwitch.on)
		return amount;
	else
		return 0;
}

-(void)setupData {
	int year = [ObjectiveCScripts nowYear]-1;
	int nowMonth = [ObjectiveCScripts nowMonth];
	int month = nowMonth;
	
	float amountThisMonth=0;
	NSMutableArray *items = [[NSMutableArray alloc] init];
	for(int i=1; i<=12; i++) {
		month++;
		if(month>12) {
			month=1;
			year++;
		}
		double amount = 0;
		
		amount += [self addAmountForType:1 label:self.homeLabel mySwitch:self.homeSwitch month:month nowMonth:nowMonth year:year];
		amount += [self addAmountForType:2 label:self.vehicleLabel mySwitch:self.vehicleSwitch month:month nowMonth:nowMonth year:year];
		amount += [self addAmountForType:7 label:self.assetLabel mySwitch:self.assetSwitch month:month nowMonth:nowMonth year:year];
		amount += [self addAmountForType:6 label:self.debtLabel mySwitch:self.debtSwitch month:month nowMonth:nowMonth year:year];
		
		if(month==[ObjectiveCScripts nowMonth])
			amountThisMonth=amount;
		
		GraphObject *obj = [[GraphObject alloc] init];
		obj.name = [[ObjectiveCScripts monthListShort] objectAtIndex:month-1];
		obj.amount = amount;
		[items addObject:obj];
	}
	
	self.graphImageView.image = [GraphLib plotGraphWithItems:items];
	
	[ObjectiveCScripts displayNetChangeLabel:self.monthlyLabel amount:amountThisMonth lightFlg:YES revFlg:NO];
	[ObjectiveCScripts displayNetChangeLabel:self.dailyLabel amount:amountThisMonth/30 lightFlg:YES revFlg:NO];
	[ObjectiveCScripts displayNetChangeLabel:self.hourlyLabel amount:amountThisMonth/(30*24) lightFlg:YES revFlg:NO];
}

-(IBAction)switchChanged:(id)sender {
	[self setupData];
}

@end

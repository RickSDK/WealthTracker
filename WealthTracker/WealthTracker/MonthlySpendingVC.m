//
//  MonthlySpendingVC.m
//  WealthTracker
//
//  Created by Rick Medved on 8/18/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "MonthlySpendingVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "GraphLib.h"
#import "GraphObject.h"
#import "DateCell.h"
#import "MultiLineObj.h"
#import "CoreDataLib.h"
#import "ObjectiveCScripts.h"
#import "NSDate+ATTDate.h"

@interface MonthlySpendingVC ()

@end

@implementation MonthlySpendingVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Monthly Spending"];
	
	self.multiLineArray = [[NSMutableArray alloc] init];
	self.graphArray = [[NSMutableArray alloc] init];
	
	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"YYYY"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	self.displayYear=self.nowYear;
	self.displayMonth = self.nowMonth;

	[self setupData];
}

-(void)setupData {
	[self.multiLineArray removeAllObjects];
	[self.graphArray removeAllObjects];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	
	double monthlyIncome = [CoreDataLib getNumberFromProfile:@"annual_income" mOC:self.managedObjectContext];
	monthlyIncome/=12;
	double incomeTaxes = monthlyIncome*.2;
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		int rowId = [obj.rowId intValue];
		double amount = [ObjectiveCScripts changedForItem:rowId month:self.displayMonth year:self.displayYear field:@"balance_owed" context:self.managedObjectContext numMonths:1];
		
		amount *=-1;
		float taxes=0;
		if([@"Real Estate" isEqualToString:obj.type])
			taxes=amount*.2;
		
		float interest = [ObjectiveCScripts amountForItem:rowId month:self.displayMonth year:self.displayYear field:@"interest" context:self.managedObjectContext type:0];
		
		amount += taxes+interest;
		float monthly_payment = [[mo valueForKey:@"monthly_payment"] floatValue];
		if(monthly_payment>amount)
			amount=monthly_payment;
		amount += [[mo valueForKey:@"homeowner_dues"] floatValue];
		if(amount > 0) {
			monthlyIncome-=amount;
			[self addGraphItem:obj.name rowId:[obj.rowId intValue] amount:amount];
		}
	}
	[self addGraphItem:@"Income Tax" rowId:99 amount:incomeTaxes];
	monthlyIncome-=incomeTaxes;

	double retirement_payments = [CoreDataLib getNumberFromProfile:@"retirement_payments" mOC:self.managedObjectContext];
	[self addGraphItem:@"Retirement" rowId:100 amount:retirement_payments];
	monthlyIncome-=retirement_payments;
	if(monthlyIncome>0)
		[self addGraphItem:@"Other" rowId:101 amount:monthlyIncome];
	
	[self.mainTableView reloadData];
}

-(void)addGraphItem:(NSString *)name rowId:(int)rowId amount:(double)amount {
	int amountInt = round(amount);
	GraphObject *graphObject = [[GraphObject alloc] init];
	graphObject.name=name;
	graphObject.amount=amountInt;
	graphObject.rowId = rowId;
	[self.graphArray addObject:graphObject];
	
	MultiLineObj *multiLineObj = [[MultiLineObj alloc] init];
	multiLineObj.name=name;
	multiLineObj.value=[ObjectiveCScripts convertNumberToMoneyString:amountInt];
	multiLineObj.color=[UIColor blackColor];
	[self.multiLineArray addObject:multiLineObj];
}

-(NSMutableArray *)arrayOfType:(int)type {
	NSMutableArray *list = [[NSMutableArray alloc] init];
	for(MultiLineObj *multiLineObj in self.multiLineArray) {
		if(type==0)
			[list addObject:multiLineObj.name];
		if(type==1)
			[list addObject:multiLineObj.value];
		if(type==2)
			[list addObject:multiLineObj.color];
	}
	return list;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	if(indexPath.section==0) {
		DateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if(cell==nil)
			cell = [[DateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		cell.currentYearLabel.text = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
		
		[cell.prevYearButton addTarget:self action:@selector(prevYearButtonPressed) forControlEvents:UIControlEventTouchDown];
		[cell.nextYearButton addTarget:self action:@selector(nextYearButtonPressed) forControlEvents:UIControlEventTouchDown];
		
		cell.nextYearButton.enabled = !(self.displayYear==self.nowYear && self.displayMonth==self.nowMonth);
		

		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	if(indexPath.section==2) {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:self.multiLineArray.count labelProportion:.5];
		
		cell.mainTitle = @"Monthly Spending";
		cell.alternateTitle = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
		
		cell.titleTextArray = [self arrayOfType:0];
		cell.fieldTextArray = [self arrayOfType:1];
		cell.fieldColorArray = [self arrayOfType:2];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	if(indexPath.section==1) {
	if(self.pieChartFlg)
		cell.backgroundView = [[UIImageView alloc] initWithImage:[GraphLib pieChartWithItems:self.graphArray]];
	else
		cell.backgroundView = [[UIImageView alloc] initWithImage:[GraphLib graphBarsWithItems:self.graphArray]];
	}
	
	cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

-(void)prevYearButtonPressed {
	self.displayMonth--;
	if(self.displayMonth<=0) {
		self.displayMonth=12;
		self.displayYear--;
	}
	[self setupData];
}

-(void)nextYearButtonPressed {
	self.displayMonth++;
	if(self.displayMonth>=12) {
		self.displayMonth=1;
		self.displayYear++;
	}
	[self setupData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==1) {
		self.pieChartFlg=!self.pieChartFlg;
		[self.mainTableView reloadData];
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0)
		return 44;
	if(indexPath.section==1)
		return [ObjectiveCScripts chartHeightForSize:170];

	return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:[self arrayOfType:1]
															   tableView:self.mainTableView
													labelWidthProportion:.5]+20;
}

@end

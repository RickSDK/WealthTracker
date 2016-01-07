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
	
	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	self.displayYear=self.nowYear;
	self.displayMonth = self.nowMonth;

	[self setupData];
}

-(void)setupData {
	[self.multiLineArray removeAllObjects];
	[self.graphArray removeAllObjects];
	
	double monthlyIncome = [CoreDataLib getNumberFromProfile:@"annual_income" mOC:self.managedObjectContext];
	monthlyIncome/=12;
	double incomeTaxes = monthlyIncome*.2;

	NSArray *cashItems = [CoreDataLib selectRowsFromEntity:@"CASH_FLOW" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *mo in cashItems) {
		double amount = [[mo valueForKey:@"amount"] doubleValue];
		if(amount<0) {
			monthlyIncome-=amount*-1;
			[self addGraphItem:[mo valueForKey:@"name"] rowId:round(amount) amount:amount*-1 confirmFlg:[[mo valueForKey:@"confirmFlg"] boolValue]];
		}
	}
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		int rowId = [obj.rowId intValue];
		double amount = [ObjectiveCScripts changedForItem:rowId month:self.displayMonth year:self.displayYear field:@"balance_owed" context:self.managedObjectContext numMonths:1 type:0];
		
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
			BOOL confirmFlg=obj.bal_confirm_flg;
			if(self.displayMonth!=self.nowMonth || self.displayYear != self.nowYear)
				confirmFlg=YES;
			
			[self addGraphItem:obj.name rowId:[obj.rowId intValue] amount:amount confirmFlg:confirmFlg];
		}
	}
	[self addGraphItem:@"Income Tax" rowId:99 amount:incomeTaxes confirmFlg:YES];
	monthlyIncome-=incomeTaxes;

	double retirement_payments = [CoreDataLib getNumberFromProfile:@"retirement_payments" mOC:self.managedObjectContext];
	[self addGraphItem:@"Retirement" rowId:100 amount:retirement_payments confirmFlg:YES];
	monthlyIncome-=retirement_payments;
	if(monthlyIncome>0)
		[self addGraphItem:@"Other" rowId:101 amount:monthlyIncome confirmFlg:YES];
	
	[self sortArray];
	[self.mainTableView reloadData];
}

-(void)sortArray {
	if(self.multiLineArray.count<2)
		return;
	for(int i=0; i<self.multiLineArray.count-1;i++)
		[self sortArray2];
}

-(void)sortArray2 {
	for(int i=0; i<self.multiLineArray.count-1;i++) {
		MultiLineObj *obj = [self.multiLineArray objectAtIndex:i];
		MultiLineObj *obj2 = [self.multiLineArray objectAtIndex:i+1];
		double amount1 = [ObjectiveCScripts convertMoneyStringToDouble:obj.value];
		double amount2 = [ObjectiveCScripts convertMoneyStringToDouble:obj2.value];
		if(amount1<amount2) {
			MultiLineObj *temp = [[MultiLineObj alloc] init];
			temp.name=obj.name;
			temp.value=obj.value;
			obj.name=obj2.name;
			obj.value=obj2.value;
			obj2.name=temp.name;
			obj2.value=temp.value;
			if(self.graphArray.count>i+1) {
				GraphObject *gObj = [self.graphArray objectAtIndex:i];
				GraphObject *gObj2 = [self.graphArray objectAtIndex:i+1];
				GraphObject *tempObj = [[GraphObject alloc] init];
				tempObj.name=gObj.name;
				gObj.name=gObj2.name;
				gObj2.name=tempObj.name;
				tempObj.amount=gObj.amount;
				gObj.amount=gObj2.amount;
				gObj2.amount=tempObj.amount;
				tempObj.rowId=gObj.rowId;
				gObj.rowId=gObj2.rowId;
				gObj2.rowId=tempObj.rowId;
			}
		}
	}
}

-(void)addGraphItem:(NSString *)name rowId:(int)rowId amount:(double)amount confirmFlg:(BOOL)confirmFlg {
	int amountInt = round(amount);
	for(MultiLineObj *obj in self.multiLineArray) {
		if([name isEqualToString:obj.name]) {
			if(amount>[ObjectiveCScripts convertMoneyStringToDouble:obj.value])
				obj.value=[ObjectiveCScripts convertNumberToMoneyString:amountInt];
		}
	}
	for(GraphObject *obj in self.graphArray) {
		if([name isEqualToString:obj.name]) {
			if(amountInt>obj.amount)
				obj.amount=amountInt;
			return;
		}
	}
	GraphObject *graphObject = [[GraphObject alloc] init];
	graphObject.name=name;
	graphObject.amount=amountInt;
	graphObject.rowId = rowId;
	[self.graphArray addObject:graphObject];
	
	MultiLineObj *multiLineObj = [[MultiLineObj alloc] init];
	multiLineObj.value=[ObjectiveCScripts convertNumberToMoneyString:amountInt];
	if(confirmFlg) {
		multiLineObj.name=name;
		multiLineObj.color=[UIColor blackColor];
	} else {
		multiLineObj.name=[NSString stringWithFormat:@"*%@", name];
		multiLineObj.color=[UIColor grayColor];
	}
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
		cell.backgroundView = [[UIImageView alloc] initWithImage:[GraphLib pieChartWithItems:self.graphArray startDegree:0]];
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
	if(self.displayMonth>12) {
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

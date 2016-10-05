//
//  AnalysisVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/14/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "AnalysisVC.h"
#import "MyPlanVC.h"
#import "AnalysisDetailsVC.h"
#import "CoreDataLib.h"
#import "ObjectiveCScripts.h"
#import "RetirementVC.h"
#import "HomeBuyVC.h"
#import "AutoBuyVC.h"
#import "PlanningVC.h"
#import "AnalysisCell.h"
#import "AmountObj.h"

@interface AnalysisVC ()

@end

@implementation AnalysisVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	int planStep = [CoreDataLib getNumberFromProfile:@"planStep" mOC:self.managedObjectContext];
	self.currentStepLabel.text = [NSString stringWithFormat:@"%d", planStep];
	
	[self.mainTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Advisor"];
	
	self.dataArray = [[NSMutableArray alloc] init];
	

	[self.dataArray addObject:[self getHomeArray]];
	[self.dataArray addObject:[self getAutoArray]];
	[self.dataArray addObject:[self getDebtArray]];
	[self.dataArray addObject:[self getWealthArray]];
	
	[ObjectiveCScripts fontAwesomeButton:self.debtButton type:3 size:24];
	[ObjectiveCScripts fontAwesomeButton:self.wealthButton type:4 size:24];
	[ObjectiveCScripts fontAwesomeButton:self.homeButton type:1 size:24];
	[ObjectiveCScripts fontAwesomeButton:self.autoButton type:2 size:24];
	
	self.advisorLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:48.f];
	self.advisorLabel.text = [NSString fontAwesomeIconStringForEnum:FAUser];
	
	[self checkStatusLights];
	
	int yearBorn = [CoreDataLib getNumberFromProfile:@"yearBorn" mOC:self.managedObjectContext];
	self.popupView.hidden = (yearBorn>0);
	double retirement_payments = [CoreDataLib getNumberFromProfile:@"retirement_payments" mOC:self.managedObjectContext];
	NSLog(@"%d %f", yearBorn, retirement_payments);
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Plan" style:UIBarButtonItemStyleBordered target:self action:@selector(planButtonPressed)];

}

-(double)equityForRowId:(int)row_id month:(int)month year:(int)year context:(NSManagedObjectContext *)context {
	double asset_valueToday = [ObjectiveCScripts amountForItem:row_id month:month year:year field:@"asset_value" context:self.managedObjectContext type:0];
	double balance_owedToday = [ObjectiveCScripts amountForItem:row_id month:month year:year field:@"balance_owed" context:self.managedObjectContext type:0];
	return asset_valueToday-balance_owedToday;
}

-(NSArray *)getHomeArray {
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	double equityTotal=0;
	double equityLastMonth=0;
	double equity2015=0;
	double equity12=0;
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		if([@"Real Estate" isEqualToString:obj.type]) {
			equityTotal+=[self equityForRowId:[obj.rowId intValue] month:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear] context:self.managedObjectContext];
			
			int month = [ObjectiveCScripts nowMonth]-1;
			int year = [ObjectiveCScripts nowYear];
			if(month<1) {
				month = 12;
				year--;
			}
			equityLastMonth+=[self equityForRowId:[obj.rowId intValue] month:month year:year context:self.managedObjectContext];
			
			equity2015+=[self equityForRowId:[obj.rowId intValue] month:12 year:[ObjectiveCScripts nowYear]-1 context:self.managedObjectContext];

			equity12+=[self equityForRowId:[obj.rowId intValue] month:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear]-1 context:self.managedObjectContext];

		}
	}
	
	NSMutableArray *thisArray = [[NSMutableArray alloc] init];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Equity Total" value:@"" amount:equityTotal hi:1 lo:-1 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Equity this month" value:@"" amount:equityTotal-equityLastMonth hi:1 lo:-1 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:[NSString stringWithFormat:@"Equity in %d", [ObjectiveCScripts nowYear]] value:@"" amount:equityTotal-equity2015 hi:1 lo:-1 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Equity last 12 mo" value:@"" amount:equityTotal-equity12 hi:1 lo:-1 reverseFlg:NO]];
	return thisArray;
}

-(NSArray *)getAutoArray {
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	double equityTotal=0;
	double valueTotal=0;
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		if([@"Vehicle" isEqualToString:obj.type]) {
			equityTotal+=[self equityForRowId:[obj.rowId intValue] month:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear] context:self.managedObjectContext];
			
			double asset_valueToday = [ObjectiveCScripts amountForItem:[obj.rowId intValue] month:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear] field:@"asset_value" context:self.managedObjectContext type:0];
			valueTotal+=asset_valueToday;
		}
	}
	
	int monthlyIncome=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
	int annualIncome = monthlyIncome*12*1.2;
	int percentOfIncome = 0;
	if(annualIncome>0) {
		percentOfIncome = valueTotal*100/annualIncome;
	}
	NSLog(@"+++tag: %d, monthlyIncome: %d", annualIncome, monthlyIncome);
	
	NSMutableArray *thisArray = [[NSMutableArray alloc] init];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Equity" value:@"" amount:equityTotal hi:1 lo:-1 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Value of Vehicles" value:[ObjectiveCScripts convertNumberToMoneyString:valueTotal] amount:percentOfIncome hi:45 lo:55 reverseFlg:YES]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"% of Income" value:[NSString stringWithFormat:@"%d%%", percentOfIncome] amount:percentOfIncome hi:45 lo:55 reverseFlg:YES]];
	

	return thisArray;
}

-(NSArray *)getDebtArray {
	int monthlyIncome=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
	int annualIncome = monthlyIncome*12*1.2;
	double debtToday=0;
	double debtLastMonth=0;
	double houseDebtToday=0;
	int prevMonth = self.nowMonth-1;
	int prevYear = self.nowYear;
	if(prevMonth<1) {
		prevMonth=12;
		prevYear--;
	}
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		if([@"Real Estate" isEqualToString:obj.type]) {
			houseDebtToday += [ObjectiveCScripts amountForItem:[obj.rowId intValue] month:self.nowMonth year:self.nowYear field:@"balance_owed" context:self.managedObjectContext type:0];
			
		}
		debtToday += [ObjectiveCScripts amountForItem:[obj.rowId intValue] month:self.nowMonth year:self.nowYear  field:@"balance_owed" context:self.managedObjectContext type:0];
		debtLastMonth += [ObjectiveCScripts amountForItem:[obj.rowId intValue] month:prevMonth year:prevYear  field:@"balance_owed" context:self.managedObjectContext type:0];
	}
	
	NSMutableArray *thisArray = [[NSMutableArray alloc] init];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Consumer Debt" value:@"" amount:debtToday-houseDebtToday hi:annualIncome/10 lo:annualIncome/100 reverseFlg:YES]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Total Debt" value:@"" amount:debtToday hi:annualIncome*2 lo:annualIncome/2 reverseFlg:YES]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Debt this month" value:@"" amount:debtToday-debtLastMonth hi:1 lo:-1 reverseFlg:YES]];
	return thisArray;
}

-(NSArray *)getWealthArray {
	int monthlyIncome=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
	int annualIncome = monthlyIncome*12*1.2;
	double equityTotal=0;
	double equityLastMonth=0;
	double equityLast12=0;
	double equityLast24=0;
	double equityLast36=0;
	int prevMonth = self.nowMonth-1;
	int prevYear = self.nowYear;
	if(prevMonth<1) {
		prevMonth=12;
		prevYear--;
	}
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		equityTotal+=[self equityForRowId:[obj.rowId intValue] month:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear] context:self.managedObjectContext];
		equityLastMonth+=[self equityForRowId:[obj.rowId intValue] month:prevMonth year:prevYear context:self.managedObjectContext];
		equityLast12+=[self equityForRowId:[obj.rowId intValue] month:self.nowMonth year:self.nowYear-1 context:self.managedObjectContext];
		equityLast24+=[self equityForRowId:[obj.rowId intValue] month:self.nowMonth year:self.nowYear-2 context:self.managedObjectContext];
		equityLast36+=[self equityForRowId:[obj.rowId intValue] month:self.nowMonth year:self.nowYear-3 context:self.managedObjectContext];
	}
	NSMutableArray *thisArray = [[NSMutableArray alloc] init];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Net Worth" value:@"" amount:equityTotal hi:annualIncome*2 lo:annualIncome/2 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Net Worth this month" value:@"" amount:equityTotal-equityLastMonth hi:1 lo:-1 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Net Worth last 12 mo" value:@"" amount:equityTotal-equityLast12 hi:annualIncome/10 lo:annualIncome/20 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Net Worth last 24 mo" value:@"" amount:equityTotal-equityLast24 hi:annualIncome/5 lo:annualIncome/10 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Net Worth last 36 mo" value:@"" amount:equityTotal-equityLast36 hi:annualIncome/3 lo:annualIncome/6 reverseFlg:NO]];
	return thisArray;
}

-(void)planButtonPressed {
	PlanningVC *detailViewController = [[PlanningVC alloc] initWithNibName:@"PlanningVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)retirementButtonPressed {
	RetirementVC *detailViewController = [[RetirementVC alloc] initWithNibName:@"RetirementVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)checkStatusLights {
	int monthlyIncome=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
	int annualIncome = monthlyIncome*12*1.2;
	
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"name" mOC:self.managedObjectContext ascendingFlg:NO];
	float totalDebt=0;
	float totalBadDebt=0;
	float totalvalue=0;
	float totalVehicleValue=0;
	float totalRealEstateDebt=0;
	float totalMonthly_payment=0;
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		int loan_balance = [obj.loan_balance intValue];
		totalDebt+=loan_balance;
		totalvalue += obj.value;
		
		float monthly_payment = [obj.monthly_payment intValue];
		
		if([@"Vehicle" isEqualToString:obj.type]) {
			totalVehicleValue += obj.value;
		}
		if([@"Real Estate" isEqualToString:obj.type]) {
			totalRealEstateDebt += loan_balance;
			totalMonthly_payment += monthly_payment;
		}
		
	}
	
	//------------Debt-----------
	totalBadDebt = totalDebt-totalRealEstateDebt;
	
	int debtToIncome=999;
	int badDebtToIncome=999;
	if(annualIncome>0) {
		debtToIncome = totalDebt*100/annualIncome;
		badDebtToIncome = totalBadDebt*100/annualIncome;
	}
	self.debt1ImageView.image = [UIImage imageNamed:@"green.png"];
	if(badDebtToIncome>10)
		self.debt1ImageView.image = [UIImage imageNamed:@"yellow.png"];
	if(badDebtToIncome>40)
		self.debt1ImageView.image = [UIImage imageNamed:@"red.png"];
	
	self.debt2ImageView.image = [UIImage imageNamed:@"green.png"];
	if(debtToIncome>100)
		self.debt2ImageView.image = [UIImage imageNamed:@"yellow.png"];
	if(debtToIncome>300)
		self.debt2ImageView.image = [UIImage imageNamed:@"red.png"];

	//------------Wealth-----------
	
	self.wealthImageView.image = [UIImage imageNamed:@"green.png"];
	int netWorth = totalvalue-totalDebt;
	
	if(netWorth<[ObjectiveCScripts idealNetWorth:self.managedObjectContext])
		self.wealthImageView.image = [UIImage imageNamed:@"yellow.png"];
	if(netWorth<[ObjectiveCScripts averageNetWorth:self.managedObjectContext])
		self.wealthImageView.image = [UIImage imageNamed:@"red.png"];
	
	//------------Home-----------
	self.homeImageView.image = [UIImage imageNamed:@"green.png"];
	int payPercentage = 99;
	if(monthlyIncome>0)
		payPercentage = totalMonthly_payment*100/monthlyIncome;
	
	if(payPercentage>30)
		self.homeImageView.image = [UIImage imageNamed:@"yellow.png"];
	if(payPercentage>40)
		self.homeImageView.image = [UIImage imageNamed:@"red.png"];
	
	//------------Auto-----------
	self.autoImageView.image = [UIImage imageNamed:@"green.png"];
	int vehiclePercentage = 99;
	if(annualIncome>0)
		vehiclePercentage = totalVehicleValue*100/annualIncome;
	
	if(vehiclePercentage>50)
		self.autoImageView.image = [UIImage imageNamed:@"yellow.png"];
	if(vehiclePercentage>60)
		self.autoImageView.image = [UIImage imageNamed:@"red.png"];
}




-(IBAction)myPlanButtonClicked:(id)sender
{
	MyPlanVC *detailViewController = [[MyPlanVC alloc] initWithNibName:@"MyPlanVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)detailsButtonClicked:(id)sender
{
	UIButton *button = sender;
	AnalysisDetailsVC *detailViewController = [[AnalysisDetailsVC alloc] initWithNibName:@"AnalysisDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.tag = (int)button.tag;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	AnalysisDetailsVC *detailViewController = [[AnalysisDetailsVC alloc] initWithNibName:@"AnalysisDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.tag = (int)indexPath.row+1;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)homeButtonPressed {
	HomeBuyVC *detailViewController = [[HomeBuyVC alloc] initWithNibName:@"HomeBuyVC" bundle:nil];
	detailViewController.managedObjectContext=self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
-(IBAction)autoButtonPressed {
	AutoBuyVC *detailViewController = [[AutoBuyVC alloc] initWithNibName:@"AutoBuyVC" bundle:nil];
	detailViewController.managedObjectContext=self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)submitButtonClicked:(id)sender {
	if([self.ageTextField.text intValue]==0) {
		[ObjectiveCScripts showAlertPopup:@"Enter a valid age" message:@""];
		return;
	}
	[self.ageTextField resignFirstResponder];
	[self.retirementTextField resignFirstResponder];
	
	int yearBorn = [ObjectiveCScripts nowYear]-[self.ageTextField.text intValue];
	[CoreDataLib saveNumberToProfile:@"yearBorn" value:yearBorn context:self.managedObjectContext];
	[CoreDataLib saveNumberToProfile:@"age" value:[self.ageTextField.text intValue] context:self.managedObjectContext];
	[CoreDataLib saveNumberToProfile:@"retirement_payments" value:[self.retirementTextField.text intValue] context:self.managedObjectContext];
	self.popupView.hidden=YES;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	AnalysisCell *cell = [[AnalysisCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier data:[self.dataArray objectAtIndex:indexPath.row]];
	
	cell.nameLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];

	cell.nameLabel.text=[ObjectiveCScripts fontAwesomeTextForType:(int)indexPath.row+1];
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [AnalysisCell cellHeightForData:[self.dataArray objectAtIndex:indexPath.row]];
}





@end

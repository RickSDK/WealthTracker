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
	self.descArray = [[NSMutableArray alloc] init];
	

	[self.dataArray addObject:[self getHomeArray]];
	[self.dataArray addObject:[self getAutoArray]];
	[self.dataArray addObject:[self getDebtArray]];
	[self.dataArray addObject:[self getWealthArray]];
	
	int percentComplete = [ObjectiveCScripts percentCompleteWithContext:self.managedObjectContext];

	[self.descArray addObject:[self realEstateSmmmaryWithPercent:percentComplete]];
	[self.descArray addObject:[self autoSmmmaryWithPercent:percentComplete]];
	[self.descArray addObject:[self debtSmmmaryWithPercent:percentComplete]];
	[self.descArray addObject:[self wealthSmmmaryWithPercent:percentComplete]];
	
	[ObjectiveCScripts fontAwesomeButton:self.debtButton type:3 size:24];
	[ObjectiveCScripts fontAwesomeButton:self.wealthButton type:4 size:24];
	[ObjectiveCScripts fontAwesomeButton:self.homeButton type:1 size:24];
	[ObjectiveCScripts fontAwesomeButton:self.autoButton type:2 size:24];
	
	self.advisorLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:48.f];
	self.advisorLabel.text = [NSString fontAwesomeIconStringForEnum:FAUser];
	
	[self checkStatusLights];
	
	int yearBorn = [CoreDataLib getNumberFromProfile:@"yearBorn" mOC:self.managedObjectContext];
	self.popupView.hidden = (yearBorn>0);
//	double retirement_payments = [CoreDataLib getNumberFromProfile:@"retirement_payments" mOC:self.managedObjectContext];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Plan" style:UIBarButtonItemStyleBordered target:self action:@selector(planButtonPressed)];

}
-(NSString *)wealthSmmmaryWithPercent:(int)percent {
	if(percent>40) {
		double netWorthChange = [ObjectiveCScripts changedForItem:0 month:self.nowMonth year:self.nowYear field:@"" context:self.managedObjectContext numMonths:1 type:0];
		int monthlyIncome=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
		int annualIncome = monthlyIncome*12*1.2;
		double oldAmount = self.totalEquity-netWorthChange;
		float percentChange=0;
		if(oldAmount>0)
			percentChange = netWorthChange*100/oldAmount;
		if(netWorthChange>annualIncome/10) {
			return [NSString stringWithFormat:@"Fantastic month for you, seeing your net worth increase by %@, bringing you up to %@. That's a %.1f%% increase just this month.", [ObjectiveCScripts convertNumberToMoneyString:netWorthChange], [ObjectiveCScripts convertNumberToMoneyString:self.totalEquity], percentChange];
		}
		else if(netWorthChange>=0)
			return [NSString stringWithFormat:@"You had a positive month, seeing your net worth increase by %@, bringing you up to %@. That's a %.1f%% annual rate of increase.", [ObjectiveCScripts convertNumberToMoneyString:netWorthChange], [ObjectiveCScripts convertNumberToMoneyString:self.totalEquity], percentChange*12];
		else
			return [NSString stringWithFormat:@"Unfortunately you had a negative month, seeing your net worth decrease by %@, bringing you down to %@. That's a %.1f%% drop in net worth.", [ObjectiveCScripts convertNumberToMoneyString:netWorthChange*-1], [ObjectiveCScripts convertNumberToMoneyString:self.totalEquity], percentChange*-1];
	} else {
		double averageAmount = [ObjectiveCScripts averageNetWorth:self.managedObjectContext];
		double idealAmount = [ObjectiveCScripts idealNetWorth:self.managedObjectContext];
		
		if(self.totalEquity<0)
			return @"You are broke! You currently have a negative net worth, meaning you owe more money than you own. This is a very serious problem and needs to be turned around ASAP. Follow the 10 Broke to Baron steps to get things back on track.";
		else if(self.totalEquity<averageAmount)
			return [NSString stringWithFormat:@"Your total net worth is only %@ which is below the average for someone your age. You need to change some things around in your life to focus on paying down debt and building net worth. Follow the 10 Broke to Baron steps to get things back on track.", [ObjectiveCScripts convertNumberToMoneyString:self.totalEquity]];
		else if(self.totalEquity<idealAmount)
			if(self.totalEquityThisMonth>=0)
				return [NSString stringWithFormat:@"Good job with your finances! Your total net worth is currently %@ which is above the average for someone your age. But more work is still needed. Follow the 10 Broke to Baron steps to get things really fired up and set yourself up for a nice retirement.", [ObjectiveCScripts convertNumberToMoneyString:self.totalEquity]];
			else
				return [NSString stringWithFormat:@"Rough month for your finances. Your total net worth has dropped to %@, but that is still above the average for someone your age.\n\nMore work is still needed. Follow the 10 Broke to Baron steps to get things really fired up and set yourself up for a nice retirement.", [ObjectiveCScripts convertNumberToMoneyString:self.totalEquity]];
		else {
			if(self.totalEquityThisMonth>=0)
				return [NSString stringWithFormat:@"Fantastic job with your finances! Your total net worth is currently %@ which easily puts you in the top 5%% of skill level for managing money. Continue working through the Broke to Baron steps to make sure you are ready for a comfortable retirement.", [ObjectiveCScripts convertNumberToMoneyString:self.totalEquity]];
			else
				return [NSString stringWithFormat:@"Unfortunately this has been a rare down month for your finances. Your total net worth has dropped to %@, but that is still a very good number for someone your age.\n\nContinue working through the Broke to Baron steps to make sure you are ready for a comfortable retirement.", [ObjectiveCScripts convertNumberToMoneyString:self.totalEquity]];
		}
	}
}

-(NSString *)debtSmmmaryWithPercent:(int)percent {
	double debtChange = [ObjectiveCScripts changedForItem:0 month:self.nowMonth year:self.nowYear field:@"balance_owed" context:self.managedObjectContext numMonths:1 type:0];
	if(percent>=100) {
		if(self.totalConsumerDebt>0) {
			if(debtChange>=0)
				return [NSString stringWithFormat:@"Things are moving in the wrong direction this month as you added %@ of debt, bringing your total up to %@. Your goal should be to pay that down as quickly as possible.", [ObjectiveCScripts convertNumberToMoneyString:debtChange], [ObjectiveCScripts convertNumberToMoneyString:self.totalDebt]];
			else
				return [NSString stringWithFormat:@"You were able to pay off %@ of debt this month, leaving you with %@ remaining. Your goal should be to pay that down as quickly as possible.", [ObjectiveCScripts convertNumberToMoneyString:debtChange*-1], [ObjectiveCScripts convertNumberToMoneyString:self.totalDebt]];
		} else if(self.totalDebt>0) {
			if(debtChange>=0)
				return [NSString stringWithFormat:@"Unfortunately you added %@ of debt this month, bringing your total up to %@. Your goal should be to pay that down as quickly as possible.", [ObjectiveCScripts convertNumberToMoneyString:debtChange], [ObjectiveCScripts convertNumberToMoneyString:self.totalDebt]];
			else
				return [NSString stringWithFormat:@"You were able to pay off %@ of debt this month, leaving you with %@ housing debt remaining. Your consumer debt is now paid off leaving you just to focus on the real estate debt.", [ObjectiveCScripts convertNumberToMoneyString:debtChange*-1], [ObjectiveCScripts convertNumberToMoneyString:self.totalDebt]];
		} else {
			return @"Great job paying off your debt! You are now completely debt free! Continue working the Broke to Baron steps to get youself building wealth and setting yourself up for a great retirement.";
		}
	} else if(percent>40) {
		if(self.totalConsumerDebt>0) {
			return [NSString stringWithFormat:@"So far you have been able to pay off %@ of debt this month, leaving you with %@ remaining. Your goal should be to pay that down as quickly as possible.", [ObjectiveCScripts convertNumberToMoneyString:debtChange*-1], [ObjectiveCScripts convertNumberToMoneyString:self.totalDebt]];
		} else if(self.totalDebt>0) {
			return [NSString stringWithFormat:@"So far you have been able to pay off %@ of debt this month, leaving you with %@ housing debt remaining. Your consumer debt is now paid off leaving you just to focus on the real estate debt.", [ObjectiveCScripts convertNumberToMoneyString:debtChange*-1], [ObjectiveCScripts convertNumberToMoneyString:self.totalDebt]];
		} else {
			return @"Great job paying off your debt! You are now completely debt free! Continue working the Broke to Baron steps to get youself building wealth and setting yourself up for a great retirement.";
		}
	} else {
		if(self.totalConsumerDebt>0) {
			if(self.debtThisMonth>0)
				return [NSString stringWithFormat:@"Unfortuntely you have added %@ of debt this month bringing the total up to %@.\n\nYour goal should be to pay that down as quickly as possible. Follow the Broke to Baron steps to get yourself debt free and building wealth.", [ObjectiveCScripts convertNumberToMoneyString:self.debtThisMonth], [ObjectiveCScripts convertNumberToMoneyString:self.totalDebt]];
			else
				return [NSString stringWithFormat:@"You are currently sitting on %@ of debt. Your goal should be to pay that down as quickly as possible. Follow the Broke to Baron steps to get yourself debt free and building wealth.", [ObjectiveCScripts convertNumberToMoneyString:self.totalDebt]];
		} else if(self.totalDebt>0) {
			return @"Great job paying off your consumer debt! You are now debt free except for your home. Continue working the Broke to Baron steps to get youself completely debt free and building wealth.";
		} else {
			return @"Great job paying off your debt! You are now completely debt free! Continue working the Broke to Baron steps to get youself building wealth and setting yourself up for a great retirement.";
		}
	}
}

-(NSString *)autoSmmmaryWithPercent:(int)percent {
	double totalValue = [ObjectiveCScripts amountForItem:0 month:self.nowMonth year:self.nowYear field:@"asset_value" context:self.managedObjectContext type:2];
	double totalBalance = [ObjectiveCScripts amountForItem:0 month:self.nowMonth year:self.nowYear field:@"balance_owed" context:self.managedObjectContext type:2];

	if(totalValue<=10)
		return @"You don't currently own any vehicles or are leasing. If you are leasing, you should consider getting out of the leasing program and getting yourself into a paid for car. As a rule, we suggest people ONLY pay cash for cars. Don't finance and never lease. Check out the Vehicle Guide under the 'Plan' button at the top of this page for more details.";

	int monthlyIncome=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
	int annualIncome = monthlyIncome*12*1.2;
	int percentOfIncome = 0;
	if(annualIncome>0) {
		percentOfIncome = totalValue*100/annualIncome;
	}
	
	if(percentOfIncome<=50) {
		if(totalBalance>0)
			return [NSString stringWithFormat:@"Currently your vehicle value is %d%% of your annual income, which is a good number for you. It's best to be under 50%%. You currently have %@ left to pay on them.", percentOfIncome, [ObjectiveCScripts convertNumberToMoneyString:totalBalance]];
		else
			return [NSString stringWithFormat:@"Currently your vehicle value is %d%% of your annual income, which is a good number for you. It's best to be under 50%%. Good job paying them off and remember to only pay cash for all future purchases.", percentOfIncome];
	} else {
		if(totalBalance>0)
			return [NSString stringWithFormat:@"Your vehicles are currently worth %d%% of your annual income which is way too high. You are paying too much per month and it is going to make things hard to get out of debt. Consider selling one and getting a low cost beater car until you are out of debt.", percentOfIncome];
		else
			return [NSString stringWithFormat:@"Your vehicles are currently worth %d%% of your annual income which is a really high number. Ideally you should be under 50%%. Lukily they are paid off but don't rush out an finance a new car any time soon.", percentOfIncome];
	}
}

-(NSString *)realEstateSmmmaryWithPercent:(int)percent {
	double realEstateValue = [ObjectiveCScripts amountForItem:0 month:self.nowMonth year:self.nowYear field:@"asset_value" context:self.managedObjectContext type:1];
	if(realEstateValue<=10)
		return @"You don't currently own any real estate. Follow the Broke to Baron plan and get yourself on a path to home ownership!";
	
	double realEstateEquity = [ObjectiveCScripts amountForItem:0 month:self.nowMonth year:self.nowYear field:@"" context:self.managedObjectContext type:1];
	double realEstateValueAtStart = [ObjectiveCScripts amountForItem:0 month:12 year:self.nowYear-1 field:@"asset_value" context:self.managedObjectContext type:1];
	if(realEstateValueAtStart<=10)
		return [NSString stringWithFormat:@"Your real estate equity is now sitting at %@", [ObjectiveCScripts convertNumberToMoneyString:realEstateEquity]];
	if(percent>40) {
		double realEstateEquityChange = [ObjectiveCScripts changedForItem:0 month:self.nowMonth year:self.nowYear field:@"" context:self.managedObjectContext numMonths:1 type:1];
		double realEstateValueChange = [ObjectiveCScripts changedForItem:0 month:self.nowMonth year:self.nowYear field:@"asset_value" context:self.managedObjectContext numMonths:1 type:1];
		NSString *line1 = @"";
		if(percent==100) {
			line1 = @"Your portfolio has been fully updated for the month so this analysis contains the final details for this month.";
		} else {
			line1 = @"You haven't updated all of your portfolio for the month so some of this analysis might change.";
		}
		NSString *line2 = @"";
		if(realEstateEquityChange>0 && realEstateValueChange>0) {
			line2 = [NSString stringWithFormat:@"This has been a good month for your real estate as your value has increaed by %@, and your equity is up by %@", [ObjectiveCScripts convertNumberToMoneyString:realEstateValueChange], [ObjectiveCScripts convertNumberToMoneyString:realEstateEquityChange]];
		} else if(realEstateEquityChange<0 && realEstateValueChange<0)
			line2 = [NSString stringWithFormat:@"This has been a bad month for your real estate with a value change of %@, and your equity is down by %@", [ObjectiveCScripts convertNumberToMoneyString:realEstateValueChange], [ObjectiveCScripts convertNumberToMoneyString:realEstateEquityChange*-1]];
		else
			line2 = [NSString stringWithFormat:@"This month has been a mixed bag for your real estate with a value change of %@, but your equity is up by %@", [ObjectiveCScripts convertNumberToMoneyString:realEstateValueChange], [ObjectiveCScripts convertNumberToMoneyString:realEstateEquityChange]];
		
		return [NSString stringWithFormat:@"%@\n\n%@", line1, line2];
	} else {
		double realEstateEquityAtStart = [ObjectiveCScripts amountForItem:0 month:12 year:self.nowYear-1 field:@"" context:self.managedObjectContext type:1];
		NSString *line1 = @"You haven't updated much of your portfolio for the month so some of this analysis is likey to change.";
		if(percent==0)
			line1 = @"You haven't started updating your portfolio this month so the analysis will change as you enter new data.";
		NSString *line2 = @"";
		if(self.homeEquityThisYear==0 || realEstateEquityAtStart==0)
			line2 = [NSString stringWithFormat:@"Your home equity is unchanged this year and is sitting at %@.", [ObjectiveCScripts convertNumberToMoneyString:realEstateEquity]];
		else if (self.homeEquityThisYear>0) {
			float equityPercent = self.homeEquityThisYear*100/realEstateEquityAtStart;
			if(equityPercent>30) {
				if(self.homeEquityThisMonth>=0)
					line2 = [NSString stringWithFormat:@"This has been a fantastic year for your real estate. Your home equity is booming in %d, up a whopping %.1f%% to %@. Nice job!", self.nowYear, equityPercent, [ObjectiveCScripts convertNumberToMoneyString:realEstateEquity]];
				else
					line2 = [NSString stringWithFormat:@"Unfortunately your home equity is down this month, but you are still way up for the year. Your real estate equity is still looking very good in %d, up a whopping %.1f%% to %@.", self.nowYear, equityPercent, [ObjectiveCScripts convertNumberToMoneyString:realEstateEquity]];
			} else if(equityPercent>10)
				line2 = [NSString stringWithFormat:@"This has been a great year for your real estate. Your home equity is on the rise in %d, up %.1f%% to %@. That is great news.", self.nowYear, equityPercent, [ObjectiveCScripts convertNumberToMoneyString:realEstateEquity]];
			else
				line2 = [NSString stringWithFormat:@"This has been a positive year for your real estate so far. Your home equity is up slightly in %d, by %.1f%% to %@. Hope to see this trend continue.", self.nowYear, equityPercent, [ObjectiveCScripts convertNumberToMoneyString:realEstateEquity]];
		} else {
			float equityPercent = self.homeEquityThisYear*100/realEstateEquityAtStart;
			line2 = [NSString stringWithFormat:@"Unfortunately this has been a negative year for your real estate so far. Your home equity is currently down in %d, by %.1f%% to %@.", self.nowYear, equityPercent*-1, [ObjectiveCScripts convertNumberToMoneyString:realEstateEquity]];
		}
		return [NSString stringWithFormat:@"%@\n\n%@", line1, line2];
	}
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
	self.homeEquityThisYear = equityTotal-equity2015;
	self.homeEquityThisMonth = equityTotal-equityLastMonth;
	NSMutableArray *thisArray = [[NSMutableArray alloc] init];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Equity Total" value:@"" amount:equityTotal hi:1 lo:-1 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Equity this month" value:@"" amount:self.homeEquityThisMonth hi:1 lo:-1 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:[NSString stringWithFormat:@"Equity in %d", [ObjectiveCScripts nowYear]] value:@"" amount:self.homeEquityThisYear hi:1 lo:-1 reverseFlg:NO]];
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
	self.totalConsumerDebt = debtToday-houseDebtToday;
	self.totalDebt = debtToday;
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Consumer Debt" value:@"" amount:debtToday-houseDebtToday hi:annualIncome/10 lo:annualIncome/100 reverseFlg:YES]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Total Debt" value:@"" amount:debtToday hi:annualIncome*2 lo:annualIncome/2 reverseFlg:YES]];
	self.debtThisMonth = debtToday-debtLastMonth;
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Debt this month" value:@"" amount:self.debtThisMonth hi:1 lo:-1 reverseFlg:YES]];
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
	self.totalEquity = equityTotal;
	self.totalEquityThisMonth = equityTotal-equityLastMonth;
	NSMutableArray *thisArray = [[NSMutableArray alloc] init];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Net Worth" value:@"" amount:equityTotal hi:annualIncome*2 lo:annualIncome/2 reverseFlg:NO]];
	[thisArray addObject:[AnalysisObj objectWithTitle:@"Net Worth this month" value:@"" amount:self.totalEquityThisMonth hi:1 lo:-1 reverseFlg:NO]];
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
	
	AnalysisCell *cell = [[AnalysisCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier data:[self.dataArray objectAtIndex:indexPath.row] desc:[self.descArray objectAtIndex:indexPath.row]];
	
	cell.nameLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];

	cell.nameLabel.text=[ObjectiveCScripts fontAwesomeTextForType:(int)indexPath.row+1];
	cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [AnalysisCell cellHeightForData:[self.dataArray objectAtIndex:indexPath.row] desc:[self.descArray objectAtIndex:indexPath.row]];
}





@end

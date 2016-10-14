//
//  UpdateDetails.m
//  WealthTracker
//
//  Created by Rick Medved on 7/13/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "UpdateDetails.h"
#import "EditItemVC.h"
#import "ObjectiveCScripts.h"
#import "MultiLineDetailCellWordWrap.h"
#import "UpdateCell.h"
#import "NSDate+ATTDate.h"
#import "ObjectiveCScripts.h"
#import "GraphCell.h"
#import "GraphLib.h"
#import "UpdateWebCell.h"
#import "WebViewVC.h"
#import "PayoffVC.h"
#import "BreakdownByMonthVC.h"
#import "UpdatePortfolioVC.h"

@interface UpdateDetails ()

@end

@implementation UpdateDetails



- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:self.itemObject.name];
	
	self.valuesArray = [[NSMutableArray alloc] init];
	self.namesArray = [[NSMutableArray alloc] init];
	self.colorsArray = [[NSMutableArray alloc] init];
	
	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	self.nowDay = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
	self.displayYear = self.nowYear;
	self.displayMonth = self.nowMonth;
	self.graphYear = self.nowYear;
	
	self.topView.backgroundColor = [ObjectiveCScripts mediumkColor];

//	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStylePlain target:self action:@selector(mainMenuButtonClicked)];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonPressed)];
	UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																					 action:@selector(handleSwipeLeft:)];
	[recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
	[self.mainTableView addGestureRecognizer:recognizer];
	
	self.monthView.backgroundColor = [ObjectiveCScripts mediumkColor];
	
	
	[ObjectiveCScripts swipeBackRecognizerForTableView:self.mainTableView delegate:self selector:@selector(handleSwipeRight:)];
	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	NSManagedObject *mo = [CoreDataLib managedObjFromId:self.itemObject.rowId managedObjectContext:self.managedObjectContext];
	self.itemObject = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
	
	[self setupData];
	
	
}

-(IBAction)prevButtonPressed:(id)sender {
	self.displayMonth--;
	if(self.displayMonth<1) {
		self.displayMonth=12;
		self.displayYear--;
	}
	self.monthOffset--;
	[self setupData];
}
-(IBAction)nextButtonPressed:(id)sender {
	self.displayMonth++;
	if(self.displayMonth>12) {
		self.displayMonth=1;
		self.displayYear++;
	}
	self.monthOffset++;
	[self setupData];
}

-(IBAction)menuButtonPressed:(id)sender {
	[self mainMenuButtonClicked];
}

-(void)mainMenuButtonClicked {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
	[self breakdownLink];

//	CGPoint location = [gestureRecognizer locationInView:self.mainTableView];
//	//Get the corresponding index path within the table view
//	NSIndexPath *indexPath = [self.mainTableView indexPathForRowAtPoint:location];
//	if(indexPath.section==0) {
//		[self breakdownLink];
//	}
}

-(ItemObject *)refreshObjFromObj:(ItemObject *)obj {
	NSManagedObject *mo = [CoreDataLib managedObjFromId:obj.rowId managedObjectContext:self.managedObjectContext];
	return [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
}

-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if([@"|" isEqualToString:string])
		return NO;
	if(textFieldlocal.text.length>=20)
		return NO;
	
	if(string.length==0) // backspace
		return YES;
	if([@"." isEqualToString:string])
		return YES;
	
	NSString *value = [NSString stringWithFormat:@"%@%@", textFieldlocal.text, string];
	value = [value stringByReplacingOccurrencesOfString:@"$" withString:@""];
	value = [value stringByReplacingOccurrencesOfString:@"," withString:@""];
	value = [ObjectiveCScripts convertNumberToMoneyString:[value doubleValue]];
	textFieldlocal.text = value;
	return NO;
}


-(NSString *)monthNameForNumber:(int)number {
	return [[NSArray arrayWithObjects:
			 @"Jan",
			 @"Feb",
			 @"Mar",
			 @"Apr",
			 @"May",
			 @"Jun",
			 @"Jul",
			 @"Aug",
			 @"Sep",
			 @"Oct",
			 @"Nov",
			 @"Dec",
			 nil] objectAtIndex:number-1];
}


-(NSString *)format:(NSString *)value type:(int)type {
	if(value.length==0)
		return @"";
	
	switch (type) {
  case 0:
			return value;
			break;
  case 1:
			return [ObjectiveCScripts convertNumberToMoneyString:[value doubleValue]];
			break;
  case 2:
			return [NSString stringWithFormat:@"%d", [value intValue]];
			break;
  case 3:
			return [NSString stringWithFormat:@"%@%%", value];
			break;
			
  default:
			break;
	}
	return @"";
}

-(void)displayTopBar {
	self.statusImageView.image=[ObjectiveCScripts imageForStatus:self.itemObject.status];
	int month=self.displayMonth;
	int year = self.displayYear;
	
	double equityChange = [ObjectiveCScripts changedForItem:[self.itemObject.rowId intValue] month:month year:year field:nil context:self.managedObjectContext numMonths:1 type:0];
	[self updateTopBoxView:self.changeView label:self.changeLabel arrow:self.changeArrowLabel amount:equityChange];
	
	month--;
	if(month<1) {
		month=12;
		year--;
	}
	double equityChange2 = [ObjectiveCScripts changedForItem:[self.itemObject.rowId intValue] month:month year:year field:nil context:self.managedObjectContext numMonths:1 type:0];
	[self updateTopBoxView:self.trendView label:self.trendLabel arrow:self.trendArrowLabel amount:equityChange-equityChange2];

	month--;
	if(month<1) {
		month=12;
		year--;
	}
	double equityChange3 = [ObjectiveCScripts changedForItem:[self.itemObject.rowId intValue] month:month year:year field:nil context:self.managedObjectContext numMonths:1 type:0];

	[self updateTopBoxView:self.paceView label:self.paceLabel arrow:self.paceArrowLabel amount:equityChange-equityChange2-(equityChange2-equityChange3)];

}

-(void)updateTopBoxView:(UIView *)view label:(UILabel *)label arrow:(UILabel *)arrow amount:(float)amount {
	[ObjectiveCScripts displayNetChangeLabel:label amount:amount lightFlg:NO revFlg:NO];
	if(amount==0) {
		view.backgroundColor=[UIColor colorWithWhite:.8 alpha:1];
		arrow.hidden=YES;
		return;
	}
	arrow.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19.f];
	if(amount>0) {
		view.backgroundColor=[UIColor greenColor];
		arrow.text = [NSString fontAwesomeIconStringForEnum:FAArrowUp];
		arrow.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	} else {
		view.backgroundColor=[UIColor yellowColor];
		arrow.text = [NSString fontAwesomeIconStringForEnum:FAArrowDown];
		arrow.textColor = [UIColor redColor];
	}
}

-(void)checkHighLow {
	self.highValue=0;
	self.lowValue=9999999;
	int month = self.displayMonth;
	int year = self.displayYear-1;
	for(int i=1; i<=13; i++) {
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d AND month = %d AND item_id = %d", year, month, [self.itemObject.rowId intValue]];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		if(items.count>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			double value = [[mo valueForKey:@"asset_value"] doubleValue];
			if(value==0)
				value = [[mo valueForKey:@"balance_owed"] doubleValue];
			if(value>self.highValue)
				self.highValue=value;
			if(value<self.lowValue)
				self.lowValue=value;
		}
		month++;
		if(month>12) {
			month=1;
			year++;
		}
	}
}

-(UIColor *)colorForField:(UIColor *)color {
	if(self.itemObject.status>0 && self.monthOffset==0)
		return [UIColor grayColor];
	else
		return color;
}

-(void)setupData {
	[self.namesArray removeAllObjects];
	[self.valuesArray removeAllObjects];
	[self.colorsArray removeAllObjects];
	
	self.nextButton.enabled=(self.displayYear<self.nowYear || self.displayMonth != self.nowMonth);
	self.monthDisplayLabel.text = [NSString stringWithFormat:@"%@ %d", [self monthNameForNumber:self.displayMonth], self.displayYear];


	[self displayTopBar];

	NSString *year_month = [NSString stringWithFormat:@"%d%02d", self.displayYear, self.displayMonth];
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", year_month, [self.itemObject.rowId intValue]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	double value=0;
	double balance=0;
	double interest=0;
	if(items.count>0) {
		NSManagedObject *mo = [items objectAtIndex:0];
		value = [[mo valueForKey:@"asset_value"] doubleValue];
		self.currentValue = value;
		balance = [[mo valueForKey:@"balance_owed"] doubleValue];
		if(self.currentValue==0)
			self.currentValue = balance;
		interest = [[mo valueForKey:@"interest"] doubleValue];
	}
	
	[self checkHighLow];
	
	if(balance<=0)
		self.payoffButton.enabled=NO;
	
	int type = [ObjectiveCScripts typeNumberFromTypeString:self.itemObject.type];
	if(type!=3) {
		[self.namesArray addObject:@"Value"];
		[self.valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:value]];
		[self.colorsArray addObject:[self colorForField:[ObjectiveCScripts colorBasedOnNumber:value lightFlg:NO]]];
	}
	
	if([self.itemObject.loan_balance floatValue]>0) {
		[self.namesArray addObject:@"Loan Balance"];
		[self.valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:balance]];
		[self.colorsArray addObject:[self colorForField:[ObjectiveCScripts colorBasedOnNumber:-1 lightFlg:NO]]];
	}
	
	if([self.itemObject.interest_rate floatValue]>0) {
		[self.namesArray addObject:@"Interest Rate"];
		[self.valuesArray addObject:[self format:self.itemObject.interest_rate type:3]];
		[self.colorsArray addObject:[UIColor blackColor]];

		[self.namesArray addObject:@"Interest Amount"];
		[self.valuesArray addObject:[NSString stringWithFormat:@"%@/month", [ObjectiveCScripts convertNumberToMoneyString:(int)interest]]];
		[self.colorsArray addObject:[UIColor blackColor]];
	}
	
	if(balance==0)
		self.itemObject.monthly_payment = 0;
	
	if([self.itemObject.monthly_payment intValue]+[self.itemObject.homeowner_dues intValue]>0) {
		[self.namesArray addObject:@"Monthly Payment"];
		[self.valuesArray addObject:[self format:self.itemObject.monthly_payment type:1]];
		[self.colorsArray addObject:[UIColor blackColor]];

		if(type==1) {
			[self.namesArray addObject:@"Homeowner Dues"];
			[self.valuesArray addObject:[self format:self.itemObject.homeowner_dues type:1]];
			[self.colorsArray addObject:[UIColor blackColor]];
			
		}
		
		int monthlyIncome=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
		int annualIncome = monthlyIncome*12*1.2;
		if(annualIncome>0) {
			[self.namesArray addObject:@"% of Gross Income"];
			double totalPayment = [self.itemObject.monthly_payment doubleValue]+[self.itemObject.homeowner_dues doubleValue];
			int percent = round(totalPayment*1200/annualIncome);
			[self.valuesArray addObject:[NSString stringWithFormat:@"%d%%", percent]];
			[self.colorsArray addObject:[UIColor blackColor]];
		}

	}
	

	[self.namesArray addObject:@"Statement Day"];
	[self.valuesArray addObject:[self format:self.itemObject.statement_day type:2]];
	[self.colorsArray addObject:[UIColor blackColor]];
	
	double loan_balance=balance;
	int equityToday = [self equityForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset]];
	int equityLastYear = [self equityForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-13]];
	int equityLast12 = equityToday-equityLastYear;
	double valueLastYear = [self valueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-13]];
	
	if(type<3) {
		[self addBlankLine];
		double equity = value-loan_balance;
		float percent=100;
		if(value>0)
			percent = equity*100/value;
		NSString *percentStr = (percent>5)?[NSString stringWithFormat:@"%d%%", (int)percent]:[NSString stringWithFormat:@"%.1f%%", percent];
		[self.namesArray addObject:@"Equity"];
		[self.valuesArray addObject:[NSString stringWithFormat:@"%@ (%@)", [ObjectiveCScripts convertNumberToMoneyString:equity], percentStr]];
		[self.colorsArray addObject:[self colorForField:[ObjectiveCScripts colorBasedOnNumber:equity lightFlg:NO]]];

		int equityLastMonth = [self equityForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-1]];
		int equityLastQuarter = [self equityForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-3]];
		
		[self addNetChangeLineWithName:@"Equity This Month" amount:equityToday-equityLastMonth revFlg:NO];
		[self addNetChangeLineWithName:@"Equity Last 3 Months" amount:equityToday-equityLastQuarter revFlg:NO];
		[self addNetChangeLineWithName:@"Equity Last 12 Months" amount:equityToday-equityLastYear revFlg:NO];

	}
	
	int investment = ([self.itemObject.monthly_payment intValue] + [self.itemObject.homeowner_dues intValue])*12;
	if(investment>0) {
		[self.namesArray addObject:@"Investment Last 12 months"];
		[self.valuesArray addObject:[self format:[NSString stringWithFormat:@"%d", investment] type:1]];
		[self.colorsArray addObject:[UIColor blackColor]];

		[self addNetChangePercentLineWithName:@"Annual ROI" amount:valueLastYear+equityLast12-investment prevAmount:valueLastYear revFlg:NO];
	}

	if(value>0) {
		[self addBlankLine];

		double valueToday = [self valueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset]];
		double value30 = [self valueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-1]];
		double valueLastDec = [self valueForMonth:[NSString stringWithFormat:@"%d%02d", self.displayYear-1, 12]];
		
		[self.namesArray addObject:@"Value"];
		[self.valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:value]];
		[self.colorsArray addObject:[self colorForField:[ObjectiveCScripts colorBasedOnNumber:value lightFlg:NO]]];
		
		[self.namesArray addObject:@"12 Month High"];
		[self.valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:self.highValue]];
		[self.colorsArray addObject:[UIColor blackColor]];
		
		[self.namesArray addObject:@"12 Month Low"];
		[self.valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:self.lowValue]];
		[self.colorsArray addObject:[UIColor blackColor]];
		
		[self addNetChangePercentLineWithName:@"Change This Month" amount:valueToday prevAmount:value30 revFlg:NO];
		[self addNetChangePercentLineWithName:@"Current Annual Rate" amount:value30+((valueToday-value30)*12) prevAmount:value30 revFlg:NO];
		[self addNetChangePercentLineWithName:[NSString stringWithFormat:@"Change in %d", self.displayYear] amount:valueToday prevAmount:valueLastDec revFlg:NO];
		[self addNetChangePercentLineWithName:@"Change Last 12 Months" amount:valueToday prevAmount:valueLastYear revFlg:NO];
		

	}
	
	if(loan_balance>0) {
		[self addBlankLine];
		double balToday = [self balanceForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset]];
		double bal30 = [self balanceForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-1]];
		double bal90 = [self balanceForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-3]];
		double balLastYear = [self balanceForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-12]];


		[self.namesArray addObject:@"Loan Balance"];
		[self.valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:balance]];
		[self.colorsArray addObject:[self colorForField:[ObjectiveCScripts colorBasedOnNumber:-1 lightFlg:NO]]];

		if(value>0 && type==1) {
			[self.namesArray addObject:@"LTV"];
			int ltv = balance*100/value;
			[self.valuesArray addObject:[NSString stringWithFormat:@"%d%%", ltv]];
			[self.colorsArray addObject:[UIColor blackColor]];
		}
		
		[self addNetChangeLineWithName:@"Change This Month" amount:balToday-bal30 revFlg:YES];
		[self addNetChangeLineWithName:@"Change Last 3 Months" amount:balToday-bal90 revFlg:YES];
		
		int principalPaid = [ObjectiveCScripts calculatePaydownRate:balToday balLastYear:balLastYear bal30:bal30 bal90:bal90];
		if(principalPaid>0) {
			
			if(principalPaid>balToday)
				self.payoffButton.enabled=NO;

			[self.namesArray addObject:@"Debt Reduction Rate"];
			[self.valuesArray addObject:[NSString stringWithFormat:@"%@ / month", [ObjectiveCScripts convertNumberToMoneyString:principalPaid]]];
			[self.colorsArray addObject:[self colorForField:[UIColor blackColor]]];
			
			int monthsToGo = 999;
			if (principalPaid>0)
				monthsToGo = ceil(loan_balance/principalPaid);
			if(monthsToGo>0) {
				[self.namesArray addObject:@"Est Months to pay off"];
				[self.valuesArray addObject:[NSString stringWithFormat:@"%d (%.1f years)", monthsToGo, (float)monthsToGo/12]];
				[self.colorsArray addObject:[self colorForField:[UIColor blackColor]]];
				
				monthsToGo+=self.monthOffset;
				NSDate *payoffDate = [[NSDate date] dateByAddingTimeInterval:monthsToGo*60*60*24*30];
				[self.namesArray addObject:@"Est. Payoff Month"];
				[self.valuesArray addObject:[payoffDate convertDateToStringWithFormat:@"MMMM, yyyy"]];
				[self.colorsArray addObject:[self colorForField:[UIColor blackColor]]];
			}
		}
	}
	self.rangeLowLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.lowValue];
	self.rangeHighLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.highValue];
	self.rangeCurrentLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.currentValue];

	float range = self.highValue-self.lowValue;
	float current = self.currentValue-self.lowValue;

	if(range>0) {
		self.range12ImageView.center = CGPointMake(self.screenWidth*current/range, 10);
		if(self.currentValue>=((self.highValue+self.lowValue)/2)) {
			self.rangeCurrentLabel.center = CGPointMake(self.range12ImageView.center.x-50, self.rangeCurrentLabel.center.y);
		} else
			self.rangeCurrentLabel.center = CGPointMake(self.range12ImageView.center.x+50, self.rangeCurrentLabel.center.y);
	} else {
		self.rangeCurrentLabel.hidden=YES;
		self.rangeLowLabel.hidden=YES;
		self.rangeHighLabel.hidden=YES;
		self.range12ImageView.hidden=YES;
	}
	[self.mainTableView reloadData];
	
}

-(void)addNetChangeLineWithName:(NSString *)name amount:(double)amount revFlg:(BOOL)revFlg {
	[self.namesArray addObject:name];
	NSString *sign=(amount>=0)?@"+":@"";
	[self.valuesArray addObject:[NSString stringWithFormat:@"%@%@", sign, [ObjectiveCScripts convertNumberToMoneyString:amount]]];
	if(revFlg)
		amount*=-1;
	[self.colorsArray addObject:[self colorForField:[ObjectiveCScripts colorBasedOnNumber:amount lightFlg:NO]]];
}

-(void)addNetChangePercentLineWithName:(NSString *)name amount:(double)amount prevAmount:(double)prevAmount revFlg:(BOOL)revFlg {
	[self.namesArray addObject:name];
	amount-=prevAmount;
	NSString *sign=(amount>=0)?@"+":@"";
	float percent=100;
	if(prevAmount>0)
		percent=amount*100/prevAmount;
	NSString *percentStr = (percent>5)?[NSString stringWithFormat:@"%d", (int)percent]:[NSString stringWithFormat:@"%.1f", percent];
	
	[self.valuesArray addObject:[NSString stringWithFormat:@"%@%@ (%@%%)", sign, [ObjectiveCScripts convertNumberToMoneyString:amount], percentStr]];
	if(revFlg)
		amount*=-1;
	[self.colorsArray addObject:[self colorForField:[ObjectiveCScripts colorBasedOnNumber:amount lightFlg:NO]]];
}

-(void)addBlankLine {
	[self.namesArray addObject:@""];
	[self.valuesArray addObject:@""];
	[self.colorsArray addObject:[UIColor blackColor]];
}

-(double)equityForMonth:(NSString *)yearMonth {
	double equity=0;
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", yearMonth, [self.itemObject.rowId intValue]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		double balance = [[mo valueForKey:@"balance_owed"] doubleValue];
		double value = [[mo valueForKey:@"asset_value"] doubleValue];
		equity+=value-balance;
	}
	return equity;
}

-(double)valueForMonth:(NSString *)yearMonth {
	double valueTotal=0;
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", yearMonth, [self.itemObject.rowId intValue]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		valueTotal += [[mo valueForKey:@"asset_value"] doubleValue];
	}
	return valueTotal;
}

-(double)balanceForMonth:(NSString *)yearMonth {
	double total=0;
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", yearMonth, [self.itemObject.rowId intValue]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		total += [[mo valueForKey:@"balance_owed"] doubleValue];
	}
	return total;
}


-(void)editButtonPressed {
	UpdatePortfolioVC *detailViewController = [[UpdatePortfolioVC alloc] initWithNibName:@"UpdatePortfolioVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.itemObject = self.itemObject;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(int)numRecordsForYear:(int)year month:(int)month {
	NSString *year_month = [NSString stringWithFormat:@"%d%02d", year, month];
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ and item_id = %d", year_month, [self.itemObject.rowId intValue]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	return (int)items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	if(indexPath.section==0) {
		NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		cell.backgroundView = [[UIImageView alloc] initWithImage:[GraphLib plotItemChart:self.managedObjectContext type:[ObjectiveCScripts typeNumberFromTypeString:self.itemObject.type] displayYear:self.displayYear item_id:[self.itemObject.rowId intValue] displayMonth:self.displayMonth startMonth:self.displayMonth startYear:self.displayYear numYears:1]];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else if(indexPath.section==1) {
		NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		int type = [ObjectiveCScripts typeNumberFromTypeString:self.itemObject.type];
		BOOL reverseColorFlg=NO;
		if(type==3)
			reverseColorFlg=YES; // debt
		
		NSArray *graphArray = [GraphLib barChartValuesLast6MonthsForItem:[self.itemObject.rowId intValue] month:self.displayMonth year:self.displayYear reverseColorFlg:reverseColorFlg type:type context:self.managedObjectContext fieldType:0 displayTotalFlg:NO];
		

		cell.backgroundView = [[UIImageView alloc] initWithImage:[GraphLib graphBarsWithItems:graphArray]];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else  {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:self.valuesArray.count labelProportion:0.6];
		
		cell.mainTitle = self.itemObject.name;
		cell.alternateTitle = [NSString stringWithFormat:@"%@ %d", [self monthNameForNumber:self.displayMonth], self.displayYear];
		
		cell.titleTextArray = self.namesArray;
		cell.fieldTextArray = self.valuesArray;
		cell.fieldColorArray = self.colorsArray;
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
}

-(void)webViewButtonPressed {
	WebViewVC *detailViewController = [[WebViewVC alloc] initWithNibName:@"WebViewVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.itemObject = self.itemObject;
	detailViewController.callBackViewController=self;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)webViewBalanceButtonPressed {
	WebViewVC *detailViewController = [[WebViewVC alloc] initWithNibName:@"WebViewVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.itemObject = self.itemObject;
	detailViewController.balanceFlg=YES;
	detailViewController.callBackViewController=self;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)resetView {
	[self.balanceTextField resignFirstResponder];
	[self.valueTextField resignFirstResponder];
	[self scrollToHeight:0];
	[self setupData];
}
/*
-(void)prevMonthButtonPressed {
	self.displayMonth--;
	if(self.displayMonth<=0) {
		self.displayYear--;
		self.displayMonth=12;
	}
	NSLog(@"+++monthOffset: %d", self.monthOffset);
	self.monthOffset--;
	NSLog(@"+++monthOffset: %d", self.monthOffset);
	[self setupData];
}

-(void)nextMonthButtonPressed {
	 if (self.displayYear>=self.nowYear && self.displayMonth>=self.nowMonth)
		 return;

	self.displayMonth++;
	if(self.displayMonth>=13) {
		self.displayYear++;
		self.displayMonth=1;
	}
	self.monthOffset++;
	[self setupData];
}
*/
-(BOOL)isCurrent {
	return (self.displayYear==self.nowYear && self.displayMonth==self.nowMonth);
}

-(void)updateValue:(NSString *)value {
	double amount = [ObjectiveCScripts convertMoneyStringToDouble:value];
	[CoreDataLib updateItemAmount:self.itemObject type:0 month:self.displayMonth year:self.displayYear currentFlg:[self isCurrent] amount:amount moc:self.managedObjectContext noHistoryFlg:NO];
	self.itemObject = [self refreshObjFromObj:self.itemObject];
	
	[ObjectiveCScripts badgeStatusForAppWithContext:self.managedObjectContext label:nil];
	[self resetView];
}

-(void)updateBalance:(NSString *)value {
	double amount = [ObjectiveCScripts convertMoneyStringToDouble:value];
	[CoreDataLib updateItemAmount:self.itemObject type:1 month:self.displayMonth year:self.displayYear currentFlg:[self isCurrent] amount:amount moc:self.managedObjectContext noHistoryFlg:NO];
	self.itemObject = [self refreshObjFromObj:self.itemObject];
	
	[ObjectiveCScripts badgeStatusForAppWithContext:self.managedObjectContext label:nil];
	[self resetView];
}

-(BOOL)checkFlag:(NSString *)flag {
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d AND month = %d AND item_id = %d", self.displayYear, self.displayMonth, [self.itemObject.rowId intValue]];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	
	if(items.count>0) {
		NSManagedObject *mo = [items objectAtIndex:0];
		
		return [[mo valueForKey:flag] boolValue];
	}
	return NO;
}

-(void)updateValueButtonPressed {
	if(self.valueTextField.text.length==0) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Value blank"];
		return;
	}

	if([self checkFlag:@"val_confirm_flg"])
		[ObjectiveCScripts showConfirmationPopup:@"Overwrite Existing Data?" message:@"You can only have one entry per month. Overwrite the existing entry?" delegate:self tag:1];
	else
		[self updateValue:self.valueTextField.text];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex!=alertView.cancelButtonIndex && alertView.tag==1) {
		[self updateValue:self.valueTextField.text];
	}
	if (buttonIndex!=alertView.cancelButtonIndex && alertView.tag==2) {
		[self updateBalance:self.balanceTextField.text];
	}
	
	if(alertView.tag==45) {
		if (buttonIndex==alertView.cancelButtonIndex) {
			[self.valueTextField resignFirstResponder];
			[self.balanceTextField resignFirstResponder];
			[self setupData];
		} else
			[self beginEditing];
	}
}

-(void)updateBalanceButtonPressed {
	if(self.balanceTextField.text.length==0) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Value blank"];
		return;
	}
	if([self checkFlag:@"bal_confirm_flg"])
		[ObjectiveCScripts showConfirmationPopup:@"Overwrite Existing Data?" message:@"You can only have one entry per month. Overwrite the existing entry?" delegate:self tag:2];
	else
		[self updateBalance:self.balanceTextField.text];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

-(IBAction)payoffButtonPressed:(id)sender {
	[self drillDown];
}

-(void)breakdownLink {
	BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.itemObject = self.itemObject;
	detailViewController.displayYear=self.nowYear;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)breakdownButtonPressed:(id)sender {
	[self breakdownLink];
}

-(void)drillDown {
	PayoffVC *detailViewController = [[PayoffVC alloc] initWithNibName:@"PayoffVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.row_id=[self.itemObject.rowId intValue];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}

-(void)scrollToHeight:(float)height {
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0);
	self.mainTableView.contentInset = contentInsets;
	self.mainTableView.scrollIndicatorInsets = contentInsets;
	
	[self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(void)beginEditing {
	if(self.editTextFieldNum==1) {
		self.updateValueButton.enabled=YES;
		self.updateBalanceButton.enabled=NO;
	}
	if(self.editTextFieldNum==2) {
		self.updateBalanceButton.enabled=YES;
		self.updateValueButton.enabled=NO;
	}
	[self scrollToHeight:250];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
	if(textField==self.valueTextField) {
		self.editTextFieldNum=1;
	}
	if(textField==self.balanceTextField) {
		self.editTextFieldNum=2;
	}

	if(self.itemObject.status==1 && self.itemObject.day>self.nowDay && self.displayMonth==self.nowMonth && self.displayYear==self.nowYear) {
		[ObjectiveCScripts showConfirmationPopup:@"Notice" message:@"You are attempting to edit a value before it's statement date has arrived. Continue?" delegate:self tag:45];
		return;
	}
	
	[self beginEditing];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section<2)
		return [ObjectiveCScripts chartHeightForSize:200];
	else
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:self.valuesArray
																			  tableView:self.mainTableView
																   labelWidthProportion:0.6]+20;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	self.startTouchPosition = [touch locationInView:self.view];
	
	if(CGRectContainsPoint(self.changeView.frame, self.startTouchPosition)) {
		self.popupView.hidden=NO;
		self.popupTitleLabel.text = @"Change";
		self.popupDescLabel.text = @"Equity this month versus equity last month.";
	}
	if(CGRectContainsPoint(self.trendView.frame, self.startTouchPosition)) {
		self.popupView.hidden=NO;
		self.popupTitleLabel.text = @"Trend";
		self.popupDescLabel.text = @"Change this month versus change last month.";
	}
	if(CGRectContainsPoint(self.paceView.frame, self.startTouchPosition)) {
		self.popupView.hidden=NO;
		self.popupTitleLabel.text = @"Pace";
		self.popupDescLabel.text = @"Trend this month versus trend last month.";
	}
}

@end

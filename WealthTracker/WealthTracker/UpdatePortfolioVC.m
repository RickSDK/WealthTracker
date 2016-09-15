//
//  UpdatePortfolioVC.m
//  WealthTracker
//
//  Created by Rick Medved on 4/27/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "UpdatePortfolioVC.h"
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

@interface UpdatePortfolioVC ()

@end

@implementation UpdatePortfolioVC

- (void)viewDidLoad {
    [super viewDidLoad];

	self.valuesArray = [[NSMutableArray alloc] init];
	self.namesArray = [[NSMutableArray alloc] init];
	self.colorsArray = [[NSMutableArray alloc] init];

	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	self.nowDay = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
	self.displayYear = self.nowYear;
	self.displayMonth = self.nowMonth;

	[self setTitle:self.itemObject.name];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonPressed)];
}

-(void)editButtonPressed {
	EditItemVC *detailViewController = [[EditItemVC alloc] initWithNibName:@"EditItemVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.itemObject = self.itemObject;
	[self.navigationController pushViewController:detailViewController animated:YES];
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


-(void)setupData {
	[self.namesArray removeAllObjects];
	[self.valuesArray removeAllObjects];
	[self.colorsArray removeAllObjects];
	
	NSString *year_month = [NSString stringWithFormat:@"%d%02d", self.displayYear, self.displayMonth];
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", year_month, [self.itemObject.rowId intValue]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	double value=0;
	double balance=0;
	double interest=0;
	if(items.count>0) {
		NSManagedObject *mo = [items objectAtIndex:0];
		value = [[mo valueForKey:@"asset_value"] doubleValue];
		balance = [[mo valueForKey:@"balance_owed"] doubleValue];
		interest = [[mo valueForKey:@"interest"] doubleValue];
	}
	
	
	int type = [ObjectiveCScripts typeNumberFromTypeString:self.itemObject.type];
	if(type!=3) {
		[self.namesArray addObject:@"Value"];
		[self.valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:value]];
		[self.colorsArray addObject:[ObjectiveCScripts colorBasedOnNumber:value lightFlg:NO]];
	}
	
	if([self.itemObject.loan_balance floatValue]>0) {
		[self.namesArray addObject:@"Loan Balance"];
		[self.valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:balance]];
		[self.colorsArray addObject:[ObjectiveCScripts colorBasedOnNumber:-1 lightFlg:NO]];
	}
	
	if([self.itemObject.interest_rate floatValue]>0) {
		[self.namesArray addObject:@"Interest Rate"];
		[self.valuesArray addObject:[self format:self.itemObject.interest_rate type:3]];
		[self.colorsArray addObject:[UIColor blackColor]];
		
		[self.namesArray addObject:@"Interest Amount"];
		[self.valuesArray addObject:[NSString stringWithFormat:@"%@/month", [ObjectiveCScripts convertNumberToMoneyString:(int)interest]]];
		[self.colorsArray addObject:[UIColor blackColor]];
	}
	
	if([self.itemObject.monthly_payment intValue]>0) {
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
	
	if(type<3) {
		[self addBlankLine];
		double equity = value-loan_balance;
		float percent=100;
		if(value>0)
			percent = equity*100/value;
		NSString *percentStr = (percent>5)?[NSString stringWithFormat:@"%d%%", (int)percent]:[NSString stringWithFormat:@"%.1f%%", percent];
		[self.namesArray addObject:@"Equity"];
		[self.valuesArray addObject:[NSString stringWithFormat:@"%@ (%@)", [ObjectiveCScripts convertNumberToMoneyString:equity], percentStr]];
		[self.colorsArray addObject:[ObjectiveCScripts colorBasedOnNumber:equity lightFlg:NO]];
		
		int equityToday = [self equityForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset]];
		int equityLastMonth = [self equityForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-1]];
		int equityLastQuarter = [self equityForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-3]];
		int equityLastYear = [self equityForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-12]];
		
		[self addNetChangeLineWithName:@"Equity This Month" amount:equityToday-equityLastMonth revFlg:NO];
		[self addNetChangeLineWithName:@"Equity Last 3 Months" amount:equityToday-equityLastQuarter revFlg:NO];
		[self addNetChangeLineWithName:@"Equity Last 12 Months" amount:equityToday-equityLastYear revFlg:NO];
		
	}
	if(value>0) {
		[self addBlankLine];
		
		double valueToday = [self valueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset]];
		double value30 = [self valueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-1]];
		double valueLastYear = [self valueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-12]];
		double valueLastDec = [self valueForMonth:[NSString stringWithFormat:@"%d%02d", self.displayYear-1, 12]];
		
		[self.namesArray addObject:@"Value"];
		[self.valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:value]];
		[self.colorsArray addObject:[ObjectiveCScripts colorBasedOnNumber:value lightFlg:NO]];
		
		[self addNetChangePercentLineWithName:@"Value This Month" amount:valueToday prevAmount:value30 revFlg:NO];
		[self addNetChangePercentLineWithName:[NSString stringWithFormat:@"Value in %d", self.displayYear] amount:valueToday prevAmount:valueLastDec revFlg:NO];
		[self addNetChangePercentLineWithName:@"Value Last 12 Months" amount:valueToday prevAmount:valueLastYear revFlg:NO];
	}
	
	if(loan_balance>0) {
		[self addBlankLine];
		double balToday = [self balanceForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset]];
		double bal30 = [self balanceForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-1]];
		double bal90 = [self balanceForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-3]];
		double balLastYear = [self balanceForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-12]];
		
		
		[self.namesArray addObject:@"Loan Balance"];
		[self.valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:balance]];
		[self.colorsArray addObject:[ObjectiveCScripts colorBasedOnNumber:-1 lightFlg:NO]];
		
		if(value>0 && type==1) {
			[self.namesArray addObject:@"LTV"];
			int ltv = balance*100/value;
			[self.valuesArray addObject:[NSString stringWithFormat:@"%d%%", ltv]];
			[self.colorsArray addObject:[UIColor blackColor]];
		}
		
		[self addNetChangeLineWithName:@"Balance This Month" amount:balToday-bal30 revFlg:YES];
		[self addNetChangeLineWithName:@"Balance Last 3 Months" amount:balToday-bal90 revFlg:YES];
		
		int principalPaid = [ObjectiveCScripts calculatePaydownRate:balToday balLastYear:balLastYear bal30:bal30 bal90:bal90];
		if(principalPaid>0) {
			
			[self.namesArray addObject:@"Debt Reduction Rate"];
			[self.valuesArray addObject:[NSString stringWithFormat:@"%@ / month", [ObjectiveCScripts convertNumberToMoneyString:principalPaid]]];
			[self.colorsArray addObject:[UIColor blackColor]];
			
			int monthsToGo = 999;
			if (principalPaid>0)
				monthsToGo = ceil(loan_balance/principalPaid);
			if(monthsToGo>0) {
				[self.namesArray addObject:@"Est Months to pay off"];
				[self.valuesArray addObject:[NSString stringWithFormat:@"%d (%.1f years)", monthsToGo, (float)monthsToGo/12]];
				[self.colorsArray addObject:[UIColor blackColor]];
				
				NSDate *payoffDate = [[NSDate date] dateByAddingTimeInterval:monthsToGo*60*60*24*30];
				[self.namesArray addObject:@"Est. Payoff Month"];
				[self.valuesArray addObject:[payoffDate convertDateToStringWithFormat:@"MMMM, yyyy"]];
				[self.colorsArray addObject:[UIColor blackColor]];
			}
		}
	}
	[self.mainTableView reloadData];
	
}

-(void)addNetChangeLineWithName:(NSString *)name amount:(double)amount revFlg:(BOOL)revFlg {
	[self.namesArray addObject:name];
	NSString *sign=(amount>=0)?@"+":@"";
	[self.valuesArray addObject:[NSString stringWithFormat:@"%@%@", sign, [ObjectiveCScripts convertNumberToMoneyString:amount]]];
	if(revFlg)
		amount*=-1;
	[self.colorsArray addObject:[ObjectiveCScripts colorBasedOnNumber:amount lightFlg:NO]];
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
	[self.colorsArray addObject:[ObjectiveCScripts colorBasedOnNumber:amount lightFlg:NO]];
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


-(int)numRecordsForYear:(int)year month:(int)month {
	NSString *year_month = [NSString stringWithFormat:@"%d%02d", year, month];
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ and item_id = %d", year_month, [self.itemObject.rowId intValue]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	return (int)items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	if(indexPath.section==0) {
		UpdateCell *cell = [[UpdateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		cell.currentYearLabel.text = [NSString stringWithFormat:@"%@ %d", [self monthNameForNumber:self.displayMonth], self.displayYear];
		[cell.prevYearButton addTarget:self action:@selector(prevMonthButtonPressed) forControlEvents:UIControlEventTouchDown];
		[cell.nextYearButton addTarget:self action:@selector(nextMonthButtonPressed) forControlEvents:UIControlEventTouchDown];
		
		BOOL nextFlg = !(self.displayYear>=self.nowYear && self.displayMonth>=self.nowMonth);
		if(nextFlg)
			[cell.nextYearButton setTitle:@"Next" forState:UIControlStateNormal];
		else
			[cell.nextYearButton setTitle:@"-" forState:UIControlStateNormal];
		
		cell.loanAmountTextField.delegate=self;
		cell.valueTextField.delegate=self;
		
		if([ObjectiveCScripts getUserDefaultValue:@"allowDecFlg"].length==0) {
			cell.loanAmountTextField.keyboardType=UIKeyboardTypeNumberPad;
			cell.valueTextField.keyboardType=UIKeyboardTypeNumberPad;
		} else {
			cell.loanAmountTextField.keyboardType=UIKeyboardTypeDecimalPad;
			cell.valueTextField.keyboardType=UIKeyboardTypeDecimalPad;
		}
		
		self.balanceTextField = cell.loanAmountTextField;
		self.valueTextField = cell.valueTextField;
		
		cell.valueLabel.text = [NSString stringWithFormat:@"%@ %d Value", [self monthNameForNumber:self.displayMonth], self.displayYear];
		cell.loanAmountLabel.text = [NSString stringWithFormat:@"%@ %d Balance", [self monthNameForNumber:self.displayMonth], self.displayYear];
		
		NSString *year_month = [NSString stringWithFormat:@"%d%02d", self.displayYear, self.displayMonth];
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", year_month, [self.itemObject.rowId intValue]];
		
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		
		self.valueTextField.text = @"";
		self.balanceTextField.text = @"";
		
		BOOL bal_confirm_flg = NO;
		BOOL val_confirm_flg = NO;
		
		self.updateValueButton=cell.updateValueButton;
		self.updateValueButton.enabled=self.nowDay>=[self.itemObject.statement_day intValue];
		self.updateBalanceButton=cell.updateBalanceButton;
		self.updateBalanceButton.enabled=self.nowDay>=[self.itemObject.statement_day intValue];
		
		if(items.count>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			double value = [[mo valueForKey:@"asset_value"] doubleValue];
			double balance = [[mo valueForKey:@"balance_owed"] doubleValue];
			
			if(value==0 || [self.itemObject.statement_day intValue] == self.nowDay)
				self.updateValueButton.enabled=YES;
			if(balance==0 || [self.itemObject.statement_day intValue] == self.nowDay)
				self.updateBalanceButton.enabled=YES;
			
			bal_confirm_flg = [[mo valueForKey:@"bal_confirm_flg"] boolValue];
			val_confirm_flg = [[mo valueForKey:@"val_confirm_flg"] boolValue];
			
			self.valueTextField.text = [ObjectiveCScripts convertNumberToMoneyString:value];
			self.balanceTextField.text = [ObjectiveCScripts convertNumberToMoneyString:balance];
		}
		
		
		BOOL hideAssetFlg = [@"Asset" isEqualToString:self.itemObject.type];
		cell.updateBalanceButton.hidden=hideAssetFlg;
		cell.loanAmountTextField.hidden=hideAssetFlg;
		cell.loanAmountLabel.hidden=hideAssetFlg;
		cell.balanceStatusImageView.hidden=hideAssetFlg;
		
		BOOL hideDebtFlg = [@"Debt" isEqualToString:self.itemObject.type];
		cell.updateValueButton.hidden=hideDebtFlg;
		cell.valueTextField.hidden=hideDebtFlg;
		cell.valueLabel.hidden=hideDebtFlg;
		cell.valueStatusImageView.hidden=hideDebtFlg;
		
		cell.balanceStatusImageView.image = (bal_confirm_flg)?[UIImage imageNamed:@"green.png"]:[UIImage imageNamed:@"red.png"];
		cell.valueStatusImageView.image = (val_confirm_flg)?[UIImage imageNamed:@"green.png"]:[UIImage imageNamed:@"red.png"];
		
		[cell.updateValueButton addTarget:self action:@selector(updateValueButtonPressed) forControlEvents:UIControlEventTouchDown];
		[cell.updateBalanceButton addTarget:self action:@selector(updateBalanceButtonPressed) forControlEvents:UIControlEventTouchDown];
		
		if (self.displayYear>self.nowYear ||  (self.displayYear==self.nowYear && self.displayMonth>self.nowMonth)) {
			cell.valueTextField.enabled=NO;
			cell.valueTextField.textColor=[UIColor orangeColor];
			cell.loanAmountTextField.enabled=NO;
			cell.loanAmountTextField.textColor=[UIColor orangeColor];
			cell.balanceStatusImageView.image = [UIImage imageNamed:@"yellow.png"];
			cell.valueStatusImageView.image = [UIImage imageNamed:@"yellow.png"];
		} else {
			cell.valueTextField.enabled=YES;
			cell.valueTextField.textColor=[UIColor blackColor];
			cell.loanAmountTextField.enabled=YES;
			cell.loanAmountTextField.textColor=[UIColor blackColor];
		}
		
		if([@"Leasing" isEqualToString:self.itemObject.payment_type]) {
			cell.valueTextField.enabled=NO;
			cell.valueTextField.backgroundColor=[UIColor grayColor];
			cell.loanAmountTextField.enabled=NO;
			cell.loanAmountTextField.backgroundColor=[UIColor grayColor];
		}
		
		cell.topView.backgroundColor = [ObjectiveCScripts colorForType:[ObjectiveCScripts typeNumberFromTypeString:self.itemObject.type]];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else if (indexPath.section==1) {
		UpdateWebCell *cell = [[UpdateWebCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		if(indexPath.row==1 || [@"Debt" isEqualToString:self.itemObject.type]) {
			[cell.updateButton setTitle:@"Check Balance" forState:UIControlStateNormal];
			cell.messageLabel.text = @"Enter the current balance from this month's statement.";
			[cell.updateButton addTarget:self action:@selector(webViewBalanceButtonPressed) forControlEvents:UIControlEventTouchDown];
			cell.statusImageView.image = (self.itemObject.balanceUrl.length>0)?[UIImage imageNamed:@"green.png"]:[UIImage imageNamed:@"red.png"];
		} else {
			[cell.updateButton setTitle:@"Check Value" forState:UIControlStateNormal];
			[cell.updateButton addTarget:self action:@selector(webViewButtonPressed) forControlEvents:UIControlEventTouchDown];
			cell.statusImageView.image = (self.itemObject.valueUrl.length>0)?[UIImage imageNamed:@"green.png"]:[UIImage imageNamed:@"red.png"];
		}
		
		cell.iconImageView.image = [ObjectiveCScripts imageIconForType:self.itemObject.type];
		
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

-(void)prevMonthButtonPressed {
	self.displayMonth--;
	if(self.displayMonth<=0) {
		self.displayYear--;
		self.displayMonth=12;
	}
	self.monthOffset--;
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

-(ItemObject *)refreshObjFromObj:(ItemObject *)obj {
	NSManagedObject *mo = [CoreDataLib managedObjFromId:obj.rowId managedObjectContext:self.managedObjectContext];
	return [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
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
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==1 && ([@"Vehicle" isEqualToString:self.itemObject.type] || [@"Real Estate" isEqualToString:self.itemObject.type]))
		return 2;
	else
		return 1;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}

-(void)scrollToHeight:(float)height {
	return;
	/*
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0);
	self.mainTableView.contentInset = contentInsets;
	self.mainTableView.scrollIndicatorInsets = contentInsets;
	
	[self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	 */
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
	if(indexPath.section==0)
		return 132;
	else
		return 90;
}


@end

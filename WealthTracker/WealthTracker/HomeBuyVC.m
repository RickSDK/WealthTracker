//
//  HomeBuyVC.m
//  WealthTracker
//
//  Created by Rick Medved on 3/9/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "HomeBuyVC.h"
#import "TipsVC.h"
#import "ValueObj.h"

@interface HomeBuyVC ()

@end

@implementation HomeBuyVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Buy Home"];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Strategy" style:UIBarButtonItemStyleBordered target:self action:@selector(tipsButtonPressed)];
	
	self.annualIncome = [CoreDataLib getNumberFromProfile:@"annual_income" mOC:self.managedObjectContext];
	self.monthlyTakehome = self.annualIncome*.8/12;
	self.annualIncomeLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.monthlyTakehome];
	
	int nowMonth = [ObjectiveCScripts nowMonth];
	int nowYear = [ObjectiveCScripts nowYear];
	self.totalDebt = [ObjectiveCScripts amountForItem:0 month:nowMonth year:nowYear field:@"balance_owed" context:self.managedObjectContext type:0];
	
	ValueObj *valueObj = [self populateTopCellForMonth:nowMonth year:nowYear context:self.managedObjectContext tag:1];
	self.currentHousingLabel.text = [ObjectiveCScripts convertNumberToMoneyString:valueObj.monthlyPayment];

	double realDebt = [ObjectiveCScripts amountForItem:0 month:nowMonth year:nowYear field:@"balance_owed" context:self.managedObjectContext type:1];
	
	int consumerDebtMonthly = (self.totalDebt-realDebt)*.03;
	self.consumerDebtLabel.text = [ObjectiveCScripts convertNumberToMoneyString:consumerDebtMonthly];

	self.monthlyPayOnDebt = consumerDebtMonthly+valueObj.monthlyPayment;
	self.monthlyIncome = self.annualIncome*.8/12;
	self.debtSwitch.on=NO;
	[self calculateDTI];
	[self calculateNewLoan];
}

-(void)calculateDTI {
	int dti = self.monthlyPayOnDebt*100/self.monthlyIncome;
	self.currentDTILabel.text = [NSString stringWithFormat:@"%d%%", dti];
	if(self.debtSwitch.on) {
		dti=25;
		self.rateSlider.minimumValue=dti;
	}
	if(dti>25) {
		self.rateSlider.minimumValue=dti;
		self.sliderAmountLabel.text = [NSString stringWithFormat:@"%d%%", dti];
	}
}

-(void)calculateNewLoan {
	

	int monthlyPayment = self.monthlyIncome*self.rateSlider.value/100;
	if(!self.debtSwitch.on)
		monthlyPayment -= self.monthlyPayOnDebt;
	if(monthlyPayment<0)
		monthlyPayment=0;
	self.monthlyPaymentLabel.text = [ObjectiveCScripts convertNumberToMoneyString:monthlyPayment];

	int termYears = (self.termSegment.selectedSegmentIndex==0)?15:30;
	
	int taxes = monthlyPayment*.16;
	float interestRate = 3;
	if(self.mainSegmentControl.selectedSegmentIndex==1)
		interestRate=3.5;
	if(self.mainSegmentControl.selectedSegmentIndex==2)
		interestRate=4;
	if(self.mainSegmentControl.selectedSegmentIndex==3)
		interestRate=4.5;
	
//	int taxes=self.itemObject.value*.0007;
//	float paymentInterest = self.totalAmount*self.interestRate/100/12;

	
	
	int loanAmount = (monthlyPayment-taxes)*12*termYears;
	int monthlyInterest = loanAmount*.7*interestRate/100/12;
	loanAmount = (monthlyPayment-taxes-monthlyInterest)*12*termYears;
	self.loanAMountLabel.text = [ObjectiveCScripts convertNumberToMoneyString:loanAmount];

}

-(ValueObj *)populateTopCellForMonth:(int)month year:(int)year context:(NSManagedObjectContext *)context tag:(int)tag {
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"name" mOC:context ascendingFlg:NO];
	ValueObj *totalValueObj = [[ValueObj alloc] init];
	double totalAmount=0;
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:context];
		ValueObj *valueObj = [self valueObjectForObjectId:[obj.rowId intValue] month:month year:year type:obj.type context:context];
		
		
		double amount=0;
		if(tag==1) {
			if(![@"Real Estate" isEqualToString:obj.type])
				continue;
			amount = valueObj.value;
		}
		
		totalValueObj.balance+=valueObj.balance;
		totalValueObj.value+=valueObj.value;
		totalValueObj.interest += valueObj.interest;
		totalValueObj.badDebt += valueObj.badDebt;
		totalValueObj.monthlyPayment += [obj.monthly_payment doubleValue]+[obj.homeowner_dues doubleValue];
		totalAmount+=amount;
		
		
	}
	
	return totalValueObj;
}

-(ValueObj *)valueObjectForObjectId:(int)rowId month:(int)month year:(int)year type:(NSString *)type context:(NSManagedObjectContext *)context {
	ValueObj *valueObj = [[ValueObj alloc] init];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"month = %d AND year = %d AND item_id = %d", month, year, rowId];
	NSArray *items2 = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:context ascendingFlg:NO];
	if(items2.count>0) {
		NSManagedObject *mo2 = [items2 objectAtIndex:0];
		valueObj.balance = [[mo2 valueForKey:@"balance_owed"] intValue];
		valueObj.value = [[mo2 valueForKey:@"asset_value"] intValue];
		valueObj.interest = [[mo2 valueForKey:@"interest"] intValue];
		
		if(![@"Real Estate" isEqualToString:type])
			valueObj.badDebt = valueObj.balance;
		
	}
	return valueObj;
}



-(void)tipsButtonPressed {
	TipsVC *detailViewController = [[TipsVC alloc] initWithNibName:@"TipsVC" bundle:nil];
	detailViewController.type=1;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)sliderChanged:(id)sender {
	self.sliderAmountLabel.text = [NSString stringWithFormat:@"%d%%", (int)self.rateSlider.value];
	[self calculateNewLoan];
}

-(IBAction)segmentChanged:(id)sender {
	[self.mainSegmentControl changeSegment];
	[self calculateNewLoan];
}

-(IBAction)termSegmentChanged:(id)sender {
	[self.termSegment changeSegment];
	[self calculateNewLoan];
}

-(IBAction)switchChanged:(id)sender {
	[self calculateDTI];
	[self calculateNewLoan];
}


@end

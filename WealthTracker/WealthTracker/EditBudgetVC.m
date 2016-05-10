//
//  EditBudgetVC.m
//  WealthTracker
//
//  Created by Rick Medved on 5/5/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "EditBudgetVC.h"
#import "AdjustBudgetVC.h"

@interface EditBudgetVC ()

@end

@implementation EditBudgetVC

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setTitle:@"Budget"];
	
	self.fixedExpenses=[ObjectiveCScripts calculateExpenses:self.managedObjectContext];
	
	self.fixedExpenses/=5;
	self.fixedExpenses*=5;
	
	self.monthlySavingsSlider.enabled=NO;
	self.continueButton.enabled=NO;
	self.continueButton.backgroundColor=[ObjectiveCScripts mediumkColor];
	[self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	[self adjustFields];
	
}

-(void)adjustFields {
	self.monthlyIncome=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
		self.monthlyIncomeLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.monthlyIncome];
		self.fixedExpenseSlider.enabled=YES;
		self.fixedExpenseSlider.maximumValue = self.monthlyIncome;
	
	self.monthlySavingsSlider.enabled=self.monthlyIncome>0;
	self.continueButton.enabled=self.monthlyIncome>0;
	
	self.fixedLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.fixedExpenses];
	self.monthlySavingsSlider.maximumValue = self.monthlyIncome-self.fixedExpenses;
	
	self.monthlySavings = [[ObjectiveCScripts getUserDefaultValue:@"monthlySavings"] intValue];
	self.savingsLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.monthlySavings];
	self.monthlySavingsSlider.value = self.monthlySavings;
	[self displayDiscetionaryAmount];
	
}



- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[self.monthlyIncomeField resignFirstResponder];
	return YES;
}

-(IBAction)updateButtonPressed:(id)sender {
	self.monthlyIncome = [self.monthlyIncomeField.text intValue]/10;
	self.monthlyIncome *= 10;
	self.monthlyIncomeField.text = [NSString stringWithFormat:@"%d", self.monthlyIncome];
	self.monthlySavingsSlider.enabled=YES;
	self.continueButton.enabled=YES;
	
	self.monthlySavingsSlider.maximumValue = self.monthlyIncome-self.fixedExpenses;
	self.monthlySavingsSlider.minimumValue = 0;
	self.monthlySavingsSlider.value = 0;
	if(self.monthlyIncome>0) {
		[self.monthlyIncomeField resignFirstResponder];
		[ObjectiveCScripts setUserDefaultValue:[NSString stringWithFormat:@"%d", self.monthlyIncome] forKey:@"monthlyIncome"];
		[self adjustFields];
	}
}


-(IBAction)savingsSliderChanged:(id)sender {
	int rounding = 50;
	if(self.monthlySavingsSlider.maximumValue>1000)
		rounding=100;
	self.monthlySavings = (self.monthlySavingsSlider.value/rounding);
	self.monthlySavings *= rounding;
	self.savingsLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.monthlySavings];
	[self displayDiscetionaryAmount];
}

-(void)displayDiscetionaryAmount {
	self.discretionaryBudget = self.monthlyIncome-self.fixedExpenses-self.monthlySavings;
	self.discretionaryBudgetLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.discretionaryBudget];
}

-(IBAction)continueButtonPressed:(id)sender {
	[ObjectiveCScripts setUserDefaultValue:[NSString stringWithFormat:@"%d", self.monthlySavings] forKey:@"monthlySavings"];
	
	AdjustBudgetVC *detailViewController = [[AdjustBudgetVC alloc] initWithNibName:@"AdjustBudgetVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.totalBudget = self.discretionaryBudget;
	detailViewController.title = @"Budgets";
	[self.navigationController pushViewController:detailViewController animated:YES];
	
}

-(IBAction)info1ButtonPressed:(id)sender {
	[ObjectiveCScripts showAlertPopup:@"This is total monthly take-home income (after taxes). Include any rental or other forms of income." message:@""];
}
-(IBAction)info2ButtonPressed:(id)sender {
	[ObjectiveCScripts showAlertPopup:@"How much are you hoping to save or put towards paying down debt each month?" message:@""];
}


@end

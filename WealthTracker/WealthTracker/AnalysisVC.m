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
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Advisor"];
	
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



@end

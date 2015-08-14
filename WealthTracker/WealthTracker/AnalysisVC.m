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
	[self setTitle:@"Analysis"];

	self.myPlanView.layer.cornerRadius = 8.0;
	self.myPlanView.layer.masksToBounds = YES;
	self.myPlanView.layer.borderColor = [UIColor blackColor].CGColor;
	self.myPlanView.layer.borderWidth = 3.0;

	self.ButtonsView.layer.cornerRadius = 8.0;
	self.ButtonsView.layer.masksToBounds = YES;
	self.ButtonsView.layer.borderColor = [UIColor blackColor].CGColor;
	self.ButtonsView.layer.borderWidth = 3.0;
	
	[self checkStatusLights];
}

-(void)checkStatusLights {
	int annual_income = [CoreDataLib getNumberFromProfile:@"annual_income" mOC:self.managedObjectContext];
	
	
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
		float value = [obj.value intValue];
		totalvalue += value;
		
		float monthly_payment = [obj.monthly_payment intValue];
		
		if([@"Vehicle" isEqualToString:obj.type]) {
			totalVehicleValue += value;
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
	if(annual_income>0) {
		debtToIncome = totalDebt*100/annual_income;
		badDebtToIncome = totalBadDebt*100/annual_income;
	}
	self.debt1ImageView.image = [UIImage imageNamed:@"green.png"];
	if(badDebtToIncome>10)
		self.debt1ImageView.image = [UIImage imageNamed:@"yellow.png"];
	if(badDebtToIncome>25)
		self.debt1ImageView.image = [UIImage imageNamed:@"red.png"];
	
	self.debt2ImageView.image = [UIImage imageNamed:@"green.png"];
	if(debtToIncome>50)
		self.debt2ImageView.image = [UIImage imageNamed:@"yellow.png"];
	if(debtToIncome>200)
		self.debt2ImageView.image = [UIImage imageNamed:@"red.png"];

	//------------Wealth-----------
	self.wealthImageView.image = [UIImage imageNamed:@"green.png"];
	int netWorth = totalvalue-totalDebt;
	int idealNetWorth = [ObjectiveCScripts calculateIdealNetWorth:annual_income];

	if(netWorth<idealNetWorth*.8)
		self.wealthImageView.image = [UIImage imageNamed:@"yellow.png"];
	if(netWorth<=0)
		self.wealthImageView.image = [UIImage imageNamed:@"red.png"];
	
	//------------Home-----------
	self.homeImageView.image = [UIImage imageNamed:@"green.png"];
	int monthlyIncome = annual_income*.8/12;
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
	if(annual_income>0)
		vehiclePercentage = totalVehicleValue*100/annual_income;
	
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



@end

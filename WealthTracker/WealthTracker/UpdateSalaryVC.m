//
//  UpdateSalaryVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/23/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "UpdateSalaryVC.h"
#import "ObjectiveCScripts.h"
#import "NSDate+ATTDate.h"
#import "CoreDataLib.h"

@interface UpdateSalaryVC ()

@end

@implementation UpdateSalaryVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Salary"];
	self.displayYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.yearStepper.maximumValue=self.displayYear;
	self.yearStepper.value=self.displayYear;
	[self setupData];
}

-(void)setupData {
	self.displayYear = self.yearStepper.value;
	self.yearLabel.text = [NSString stringWithFormat:@"%d", self.displayYear];

	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d", self.displayYear];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"INCOME" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	double annualIncome=0;
	BOOL confirmFlg=NO;
	if(items.count>0) {
		NSManagedObject *mo = [items objectAtIndex:0];
		annualIncome = [[mo valueForKey:@"amount"] doubleValue];
		confirmFlg=YES;
	}
	
	self.statusImageView.image=(confirmFlg)?[UIImage imageNamed:@"green.png"]:[UIImage imageNamed:@"red.png"];
	if(annualIncome==0) {
		int monthlyIncome=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
		annualIncome = monthlyIncome*12*1.2;
	}
	
	self.amountTextField.text = [ObjectiveCScripts convertNumberToMoneyString:annualIncome];

}

-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return [ObjectiveCScripts shouldChangeCharactersForMoneyField:textFieldlocal replacementString:string];
}

-(IBAction)stepperClicked:(id)sender {
	[self setupData];
}


-(IBAction)updateButtonClicked:(id)sender {
	double amount = [ObjectiveCScripts convertMoneyStringToDouble:self.amountTextField.text];
	[ObjectiveCScripts updateSalary:amount year:self.displayYear context:self.managedObjectContext];
	[self setupData];
}


@end

//
//  PayoffVC.m
//  WealthTracker
//
//  Created by Rick Medved on 8/27/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "PayoffVC.h"
#import "ObjectiveCScripts.h"
#import "NSDate+ATTDate.h"
#import "ItemObject.h"
#import "CoreDataLib.h"

@interface PayoffVC ()

@end

@implementation PayoffVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Payoff Date"];

	NSManagedObject *mo = [CoreDataLib managedObjFromId:[NSString stringWithFormat:@"%d", self.row_id] managedObjectContext:self.managedObjectContext];
	ItemObject *itemObject = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
	self.nameLabel.text = itemObject.name;
	self.interestRate=[itemObject.interest_rate floatValue];
	
	int nowYear = [[[NSDate date] convertDateToStringWithFormat:@"YYYY"] intValue];
	int nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];

	self.totalAmount = [ObjectiveCScripts amountForItem:self.row_id month:nowMonth year:nowYear field:@"balance_owed" context:self.managedObjectContext type:0];
	
	double balLastYear = [self amountForMonthsBack:12 year:nowYear month:nowMonth];
	double bal30 = [self amountForMonthsBack:1 year:nowYear month:nowMonth];
	double bal90 = [self amountForMonthsBack:3 year:nowYear month:nowMonth];
	int principalPaid = [ObjectiveCScripts calculatePaydownRate:self.totalAmount balLastYear:balLastYear bal30:bal30 bal90:bal90];

	self.currentPaydownAmount = principalPaid;
	self.displayPaydownAmount = principalPaid;
	
	self.currentBalanceLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.totalAmount];
	self.currentPaydownLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.currentPaydownAmount];

	self.amountSlider.value=(float)1/4;
	[self displayLabels];

}

-(double)amountForMonthsBack:(int)months year:(int)year month:(int)month {
	month-=months;
	while (month<1) {
		month+=12;
		year--;
	}
	return [ObjectiveCScripts amountForItem:self.row_id month:month year:year field:@"balance_owed" context:self.managedObjectContext type:0];
}

-(void)displayLabels {
	self.displayPaydownLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.displayPaydownAmount];
	self.monthsLabel.text = [NSString stringWithFormat:@"%d (%.1f years)", (int)self.totalAmount/self.displayPaydownAmount, self.totalAmount/self.displayPaydownAmount/12];
	int interest=0;
	int balance=self.totalAmount;
	while (balance>0) {
		interest+=balance*self.interestRate/100/12;
		balance-=self.displayPaydownAmount;
	}
	NSDate *payoffDate = [[NSDate date] dateByAddingTimeInterval:60*60*24*30*self.totalAmount/self.displayPaydownAmount];
	self.dateLabel.text = [payoffDate convertDateToStringWithFormat:@"MMM, yyyy"];
	self.interestLabel.text = [ObjectiveCScripts convertNumberToMoneyString:interest];
}

-(IBAction)sliderChanged:(id)sender {
	self.displayPaydownAmount = (self.currentPaydownAmount/2)+(self.currentPaydownAmount*self.amountSlider.value*2);
	[self displayLabels];
}



@end

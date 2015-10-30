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
#import "GraphLib.h"

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

	self.barGraphObjects = [[NSMutableArray alloc] init];
	
	NSManagedObject *mo = [CoreDataLib managedObjFromId:[NSString stringWithFormat:@"%d", self.row_id] managedObjectContext:self.managedObjectContext];
	self.itemObject = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
	[self setTitle:self.itemObject.name];
	self.nameLabel.text = self.itemObject.name;
	self.interestRate=[self.itemObject.interest_rate floatValue];
	
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
	

	self.amountSlider.value=(float)1/6;
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
	if(self.displayPaydownAmount<10)
		return;
	
	float months = self.totalAmount/self.displayPaydownAmount;
	[self.barGraphObjects removeAllObjects];
	self.displayPaydownLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.displayPaydownAmount];
	self.monthsLabel.text = [NSString stringWithFormat:@"%d (%.1f years)", (int)months, months/12];
	
	UIColor *textColor = [UIColor greenColor];
	if(months>15*12)
		textColor = [UIColor yellowColor];
	if(months>20*12)
		textColor = [UIColor orangeColor];
	if(months>30*12)
		textColor = [UIColor redColor];
	if(months>40*12)
		textColor = [UIColor blackColor];
	
	int interest=0;
	int balance=self.totalAmount;
	
	while (balance>0) {
		interest+=balance*self.interestRate/100/12;
		balance-=self.displayPaydownAmount;
	}
	
	int taxes=[self.itemObject.value intValue]*.0007;
	float paymentInterest = self.totalAmount*self.interestRate/100/12;
	self.monthlyPaymnetLabel.text = [ObjectiveCScripts convertNumberToMoneyString:round(self.displayPaydownAmount+paymentInterest+taxes)];
	
	NSDate *payoffDate = [[NSDate date] dateByAddingTimeInterval:60*60*24*30*self.totalAmount/self.displayPaydownAmount];
	self.dateLabel.text = [payoffDate convertDateToStringWithFormat:@"MMM, yyyy"];
	self.interestLabel.text = [ObjectiveCScripts convertNumberToMoneyString:interest];

	self.monthsLabel.textColor = textColor;
	self.dateLabel.textColor = textColor;
	self.interestLabel.textColor = textColor;
	

	[self.barGraphObjects addObject:[GraphLib graphObjectWithName:@"Principal" amount:self.displayPaydownAmount rowId:3 reverseColorFlg:NO currentMonthFlg:NO]];
	[self.barGraphObjects addObject:[GraphLib graphObjectWithName:@"Interest" amount:paymentInterest rowId:2 reverseColorFlg:NO currentMonthFlg:NO]];
	
	
	if([@"Real Estate" isEqualToString:self.itemObject.type])
		[self.barGraphObjects addObject:[GraphLib graphObjectWithName:@"Taxes" amount:taxes rowId:4 reverseColorFlg:NO currentMonthFlg:NO]];
	
	self.imageView.image = [GraphLib pieChartWithItems:self.barGraphObjects startDegree:self.startDegree];

}

-(IBAction)sliderChanged:(id)sender {
	self.displayPaydownAmount = (self.currentPaydownAmount/4)+(self.currentPaydownAmount*self.amountSlider.value*4);
	self.displayPaydownAmount /=25;
	self.displayPaydownAmount *=25;
	[self displayLabels];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	self.startTouchPosition = [touch locationInView:self.view];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint newTouchPosition = [touch locationInView:self.view];
	
	self.startDegree = [GraphLib spinPieChart:self.imageView startTouchPosition:self.startTouchPosition newTouchPosition:newTouchPosition startDegree:self.startDegree barGraphObjects:self.barGraphObjects];
	self.startTouchPosition=newTouchPosition;
	
	
}




@end

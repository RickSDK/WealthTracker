//
//  RetirementVC.m
//  WealthTracker
//
//  Created by Rick Medved on 9/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "RetirementVC.h"
#import "CoreDataLib.h"

@interface RetirementVC ()

@end

@implementation RetirementVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if(self.finFlg) {
		self.textView.text = @"3 keys to financial Success\n\nHere are the 3 rules to follow in life that lead to financial success. It's smart to always follow these.\n\n1) Avoid Credit Cards\n2) Pay cash for cars\n3) 15 year mortgages\n\n1) Avoid credit card debt. Unless it is an emergency, avoid revolving debt at all costs. Pay for things as you go and pay your balance in full each month. Living outside your means is the fast-track to ruin.\n\n2) As a general rule, you should ONLY pay cash for your cars. Avoid financing. Even with a zero-interest loan, you are adding risk to your life and not leaving yourself in the best possible situation to handle life's speed-bumps. If you can't afford to pay cash, consider getting a beater and saving up each month until you can afford to buy with cash. It's the smartest way to go.\n\n3) ONLY buy real estate on 15 years or less. Never on a 30 year term. 15-year gets you the best interest rate and gets it paid off quickly. Banks and Lenders will try to steer you into a 30-year loan because their commission bonus checks go way up, but don't fall for it. Think of it this way: If you can't afford the payment of a 15 year mortgage, you can't afford that house.";;
		
	} else {
	
	double annual_income = [CoreDataLib getNumberFromProfile:@"annual_income" mOC:self.managedObjectContext];
	double retirement_payments = [CoreDataLib getNumberFromProfile:@"retirement_payments" mOC:self.managedObjectContext];
	
	float rate = 0;
	if(annual_income>0)
		rate = retirement_payments*100/(annual_income*.8/12);
	
	self.textView.text = [NSString stringWithFormat:@"You are currently paying %.1f%% of your income towards retirement. Follow the plan on the main menu to find out if you are currently paying the right amount into retirement. Also be sure to update the values on your profile if they are not up to date and accurate.\n\nKeys for Retirement\n\n* Pay off all credit cards and student loans before starting retirement.\n* Start by investing 5%% of your income towards 401k or IRA.\n* Never trade individual stocks. Mutual funds only.\n* Pay off your house before boosting investment to 10%% of income.\n*Finally boost investment to 15%% OR purchase real estate investments.\n\n401k/IRA Basics\nYou are able to invest up to 15%% of your income or about $15,000 per year into the account. The money comes straight out of your pay-check, pre taxed, which means you are able to earn interest on the taxed portion of your investment.\n\nIf you are lucky enough to have employer matching funds, your account will grow much faster as you are essentially getting free money. Maxing out these matching funds should always be your first step in planning retirement.\n\nDo not plan on pulling any money out of this account before age 59.5 because you will incur a 10%% penalty. There is almost no scenario where this is a wise move.\n\nYou will start withdrawing money from your account at some point in your 60s. It is your choice when you want to start, but by law, you must start withdrawing funds by age 70 or you will lose part of the money.\n\nTypically you will withdraw somewhere between 4%% and 8%% of your account each year from then on.\n\nNote: This info is extremely basic and omits a lot of fine details related to investment accounts."
						  , rate];
		
	}
	

}

@end

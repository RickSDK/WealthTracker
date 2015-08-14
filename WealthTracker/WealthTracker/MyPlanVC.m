//
//  MyPlanVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/14/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "MyPlanVC.h"
#import "ObjectiveCScripts.h"
#import "CoreDataLib.h"
#import "NSDate+ATTDate.h"

@interface MyPlanVC ()

@end

@implementation MyPlanVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setTitle:@"My Plan"];
	
	self.bgView.layer.cornerRadius = 8.0;
	self.bgView.layer.masksToBounds = YES;
	self.bgView.layer.borderColor = [UIColor blackColor].CGColor;
	self.bgView.layer.borderWidth = 3.0;
	
	self.stepView.layer.cornerRadius = 8.0;
	self.stepView.layer.masksToBounds = YES;
	self.stepView.layer.borderColor = [UIColor blackColor].CGColor;
	self.stepView.layer.borderWidth = 3.0;
	
	self.tipsView.layer.cornerRadius = 8.0;
	self.tipsView.layer.masksToBounds = YES;
	self.tipsView.layer.borderColor = [UIColor blackColor].CGColor;
	self.tipsView.layer.borderWidth = 3.0;

	self.tipsView.hidden=YES;

	self.myStep = [CoreDataLib getNumberFromProfile:@"planStep" mOC:self.managedObjectContext];
	if(self.myStep==0)
		self.myStep=1;
	
	self.step = self.myStep;
	
	[self displayProgressLabel];
	
	[self displayButtons];
	
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"3 Keys" style:UIBarButtonItemStyleBordered target:self action:@selector(keysButtonPressed)];

	
}

-(void)displayProgressLabel {
	self.myStepLabel.text = [NSString stringWithFormat:@"%d", self.step];

	int year = [[[NSDate date] convertDateToStringWithFormat:@"YYYY"] intValue];
	int month = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];

	switch (self.myStep) {
  case 1: {
			double amount = [CoreDataLib getNumberFromProfile:@"emergency_fund" mOC:self.managedObjectContext];
			self.progressLabel.text = [NSString stringWithFormat:@"Step 1 Progress: You currently have %@ in your emergency fund.", [ObjectiveCScripts convertNumberToMoneyString:amount]];
			break;
  }
  case 2: {
	  double amount=0;
	  NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d AND month = %d", year, month];
	  NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	  for(NSManagedObject *mo in items) {
		  NSManagedObject *itemObj = [CoreDataLib managedObjFromId:[mo valueForKey:@"item_id"] managedObjectContext:self.managedObjectContext];
		  if(![@"Real Estate" isEqualToString:[itemObj valueForKey:@"type"]])
			  amount += [[mo valueForKey:@"balance_owed"] doubleValue];
	  }
			self.progressLabel.text = [NSString stringWithFormat:@"Step 2 Progress:  %@ of Class A debt remaining.", [ObjectiveCScripts convertNumberToMoneyString:amount]];
			break;
  }
  case 3: {
			double amount = [CoreDataLib getNumberFromProfile:@"emergency_fund" mOC:self.managedObjectContext];
			self.progressLabel.text = [NSString stringWithFormat:@"Step 3 Progress: You currently have %@ in your emergency fund.", [ObjectiveCScripts convertNumberToMoneyString:amount]];
			break;
  }
  case 4: {
			double annual_income = [CoreDataLib getNumberFromProfile:@"annual_income" mOC:self.managedObjectContext];
			double retirement_payments = [CoreDataLib getNumberFromProfile:@"retirement_payments" mOC:self.managedObjectContext];
	  double target = (annual_income*.8*.05)/12;
	  target = (int)(target/10)*10;
			self.progressLabel.text = [NSString stringWithFormat:@"Step 4 Progress: You are currently paying %@ towards retirement. and should be paying %@/month.", [ObjectiveCScripts convertNumberToMoneyString:retirement_payments], [ObjectiveCScripts convertNumberToMoneyString:target]];
			break;
  }
  case 5: {
	  double amount=0;
	  NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d AND month = %d", year, month];
	  NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	  for(NSManagedObject *mo in items) {
		  amount += [[mo valueForKey:@"balance_owed"] doubleValue];
	  }
			self.progressLabel.text = [NSString stringWithFormat:@"Step 5 Progress:  %@ debt remaining.", [ObjectiveCScripts convertNumberToMoneyString:amount]];
			break;
  }
  case 6: {
			double annual_income = [CoreDataLib getNumberFromProfile:@"annual_income" mOC:self.managedObjectContext];
			double retirement_payments = [CoreDataLib getNumberFromProfile:@"retirement_payments" mOC:self.managedObjectContext];
	  double target = (annual_income*.8*.1)/12;
	  target = (int)(target/10)*10;
			self.progressLabel.text = [NSString stringWithFormat:@"Step 6 Progress: You are currently paying %@ towards retirement. and should be paying %@/month.", [ObjectiveCScripts convertNumberToMoneyString:retirement_payments], [ObjectiveCScripts convertNumberToMoneyString:target]];
			break;
  }
			
  default:
			self.progressLabel.text = @"";
			break;
	}
}

-(void)keysButtonPressed {
	self.scrollView.text = @"3 keys to financial Success\n\nHere are the 3 rules to follow in life that lead to financial success. It's smart to always follow these.\n\n1) Avoid credit card debt. Unless it is an emergency, avoid revolving debt at all costs. Pay for things as you go and pay your balance in full each month. Living outside your means is the fast-track to ruin.\n\n2) As a general rule, you should ONLY pay cash for your cars. Avoid financing. Even with a zero-interest loan, you are adding risk to your life and not leaving yourself in the best possible situation to handle life's speed-bumps. If you can't afford to pay cash, consider getting a beater and saving up each month until you can afford to buy with cash. It's the smartest way to go.\n\n3) ONLY buy real estate on 15 years or less. Never on a 30 year term. 15-year gets you the best interest rate and gets it paid off quickly. Banks and Lenders will try to steer you into a 30-year loan because their commission bonus checks go way up, but don't fall for it. Think of it this way: If you can't afford the payment of a 15 year mortgage, you can't afford that house.";
	[self.scrollView scrollRectToVisible:CGRectMake(0,0,1,1) animated:YES];
	self.tipsView.hidden=NO;
}

-(void)displayButtons {
	self.currentStepLabel.text = [NSString stringWithFormat:@"%d", self.step];

	self.prevButton.enabled=YES;
	self.nextButton.enabled=YES;
	self.completedSwitch.enabled = (self.myStep==self.step || self.myStep==self.step+1)?YES:NO;
	self.completedSwitch.on = self.myStep>self.step?YES:NO;
	
	[self.prevButton setTitle:[NSString stringWithFormat:@"Step %d", self.step-1] forState:UIControlStateNormal];
	[self.nextButton setTitle:[NSString stringWithFormat:@"Step %d", self.step+1] forState:UIControlStateNormal];
	
	if(self.step==1) {
		self.prevButton.enabled=NO;
		[self.prevButton setTitle:@"-" forState:UIControlStateNormal];
	}
	if(self.step==10) {
		self.nextButton.enabled=NO;
		[self.nextButton setTitle:@"-" forState:UIControlStateNormal];
	}
	
	NSArray *titles=[NSArray arrayWithObjects:
					 @"Emergency Fund",
					 @"Pay Debt",
					 @"Emergency Fund",
					 @"Start Funding Retirement",
					 @"Pay off House",
					 @"Fully Fund Retirement",
					 @"Save for Rental",
					 @"Buy Rental Property",
					 @"Pay off Rental",
					 @"Buy and Pay Second Rental",
					 nil];
	self.titleLabel.text = [titles objectAtIndex:self.step-1];

	NSArray *descs=[NSArray arrayWithObjects:
					 @"In order to get your finances in shape and go from Broke to Baron, the very first thing you need to do is scrape together a $1000 emergency fund.",
					 @"The best way to achieve wealth is to eliminate your debts. Stop paying interest! The goal for step 2 is to pay off all debt EXCEPT for your house.",
					 @"Now it's time to boost your emergency fund to $3,000 so you can better handle emergencies in your life.",
					 @"If you don't have a retirement account or 401k, start setting 5% of your income into a tax deferred retirement account (IRA).",
					 @"Pay off that mortgage! start making double and triple payments until it's gone. Be debt free!",
					 @"Now boost your retirement to 10% of your income, and devote another 10% toward children's college funds, church tithe or charity. Be generous!",
					 @"Start saving for a 20% down payment on a rental property.",
					 @"Purchase rental property on NO MORE than 15 year loan. Not a 30 year. You want to be debt free!",
					 @"Pay off Rental property and get debt free once again.",
					 @"Buy and Pay Second Rental. You are now a Baron!",
					 nil];
	self.descLabel.text = [descs objectAtIndex:self.step-1];

	NSArray *tips=[NSArray arrayWithObjects:
					 @"Tips:\n\nIf you don't currently have an emergency fund, this needs to be the FIRST thing you do. You can not break out of the cycle of debt if your bank account is always on empty.\n\nSounds like a tough thing to do? It's not as bad as you think. Just follow these steps:\n\n1) Reduced all credit card payments to minimum until your emergency fund is in place. Also put any retirement and investing on hold.\n\n2) Reduce your spending! Cut down on lattes, clothes and shopping. Keep the money in the bank.\n\n3) Sell anything not nailed down. Have garage sales, use eBay. Clean out the garage and storage units and sell whatever you can.\n\n4) Work extra hours and pick up any side jobs. Every penny you can scrape together helps!",
				   @"Tips:\n\nWith an emergency fund in place, it's now time to tackle your debt! Your goal is to pay off everything but the house. Every last penny.\n\nSounds like an impossible mission? It's not as bad as you think. The key is to do all 5 of these tips. Not one or two, but all 5.\n\nArrange your debts smallest to largest and start tackling them one at a time, starting with the smallest. Don't try to pay off more than one at a time. Throw everything at your smallest debt and close it out. Here are the 5 tips for helping you out. Be sure to do all 5:\n\n1) Pay Minimum on All Debt.\n     Drop all credit card payments to minimum and throw the extra money at your smallest debt. Also put any retirement and investing on hold.\n\n2) Reduce Bills\n     Cancel any recurring bills you can live without. This means gym memberships if you aren't using them. Empty storage units, reduce your TV cable to a minimum package, etc.\n\n3) Reduce Spending\n     Cut down on coffee, clothes, shopping and eating out. The only time you should be in a restaurant is if you are working!\n\n4) Sell Stuff\n     Hold garage sales, place things on eBay. Sell your car if you owe a ton and get a beater. Sell gold and jewelry (you can always buy it back later). Cash in those savings bonds from grandma. Time to get radical about getting out of debt.\n\n5) Work More\n     You need to get that income up. Work side jobs, put in overtime at work, get a second job, whatever it takes. Its just temporary.",
					 @"Tips:\n\nCongratulations on paying off your debt! For most people, that is the hardest step.\n\nThe next thing you want to do is build your emergency fund up to $3,000. This will help you better deal with some of life's speed bumps.\n\nWithout having to worry about credit card payments, this step should be pretty easy to accomplish.",
					 @"Tips:\n\nWith a nice emergency fund it place, you can now start planning for retirement. Max out any employer contributions on your 401k account. This is your best rate of return. Altogether you should plan on spending about 5% of your take-home pay on retirement.\n\nYou will bump it up even further once the home is paid for (Step 6).",
					 @"Tips:\n\nYour next step is to throw everything you can at the house and become truly debt free. Rather than buying expensive cars and going on expensive vacations, it's better to keep driving the same car, go camping, and get that house paid off. Every available dollar should go into paying it off early.\n\nIf you don't own a house, it's time to start saving up for a 20% down payment on a 15 year loan.\n\nReview the tips for step-2 if you need help in coming up with the extra money.",
					 @"Tips:\n\nWith all debts fully paid, you will notice your expendable income is going to explode. This is good!\n\n You should now bump up your retirement contributions to a full 10% of take-home pay. Another 10% should go towards either church tithe, kids college funds or charity. Don't be afraid of being generous with your money. Hoarding it is not the secret to happiness. Remember to be helping others along the way.",
					 @"Tips:\n\nIf you do it right, owning rental property can be one of the fastest ways to generate wealth. The secret is to get good deals, get good renters, and don't over-extend yourself.\n\nBuying property should ONLY be done one way: Put 20% down and finance the rest at 15 years or less. No exceptions.\n\nSo start saving up for your 20% down payment.",
					 @"Tips:\n\nOnce you have your down payment saved up, shop around for great deals. Throw out low-ball offers and wait for one to take. You shouldn't be in a hurry to buy. Once your offer gets accepted, finance at 15 years or less. That's how you get the best interest rates.",
					 @"Tips:\n\nPut all available money towards paying off the rental property early. With the added income of renters, this should be easy to do.",
					 @"Tips:\n\nThe final step in this program is to buy a second rental property and pay it off as soon as possible, For most people, this plan is enough to guarantee a comfortable living and a wealthy retirement.\n\nCongratulations!",
					 nil];
	self.scrollView.text = [NSString stringWithFormat:@"Step %d: %@\n\n%@", self.step, [titles objectAtIndex:self.step-1], [tips objectAtIndex:self.step-1]];
	

}

-(IBAction)nextButtonClicked:(id)sender {
	self.step++;
	[self displayButtons];
}
-(IBAction)prevButtonClicked:(id)sender {
	self.step--;
	[self displayButtons];
}

-(IBAction)switchClicked:(id)sender {
	if(self.completedSwitch.on) {
		self.myStep++;
		self.step=self.myStep;
		[self displayButtons];
		[ObjectiveCScripts showAlertPopup:@"Congratulations!" message:@""];
	} else {
		self.myStep--;
		self.step=self.myStep;
		[self displayButtons];
	}
	NSArray *items = [CoreDataLib selectRowsFromTable:@"PROFILE" mOC:self.managedObjectContext];
	if(items.count>0) {
		NSManagedObject *mo = [items objectAtIndex:0];
		[mo setValue:[NSNumber numberWithInt:self.myStep] forKey:@"planStep"];
		[self.managedObjectContext save:nil];
	}
	[self displayProgressLabel];
}

-(IBAction)closeTipsButtonClicked:(id)sender {
	self.tipsView.hidden=YES;
}

-(IBAction)openTipsButtonClicked:(id)sender {
	[self displayButtons];
	[self.scrollView scrollRectToVisible:CGRectMake(0,0,1,1) animated:YES];
	self.tipsView.hidden=NO;
}





@end

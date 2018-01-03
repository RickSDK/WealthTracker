//
//  MoneyTestVC.m
//  WealthTracker
//
//  Created by Rick Medved on 9/21/17.
//  Copyright (c) 2017 Rick Medved. All rights reserved.
//

#import "MoneyTestVC.h"
#import "MoneyTestCell.h"

@interface MoneyTestVC ()

@end

@implementation MoneyTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Money Test"];
	
	[self.itemsArray addObject:@"💰 $500 Emergency Fund"];
	[self.itemsArray addObject:@"💰 $3000 Emergency Fund"];
	[self.itemsArray addObject:@"💳 No Credit Card Debt"];
	[self.itemsArray addObject:@"💳 No Timeshares"];
	[self.itemsArray addObject:@"💳 No Student Loans"];
	[self.itemsArray addObject:@"💳 Avoid Collecting Stuff"];
	[self.itemsArray addObject:@"📈 Contributing to Retirement"];
	[self.itemsArray addObject:@"📈 Avoid Individual Stocks"];
	[self.itemsArray addObject:@"🚘 All Vehicles Paid Off"];
	[self.itemsArray addObject:@"🚘 No Vehicle Leases"];
	[self.itemsArray addObject:@"🏠 Own a Home"];
	[self.itemsArray addObject:@"🏠 15 Year loan (or less)"];
	[self.itemsArray addObject:@"🏠 20% Equity on Home"];
	[self calculateScore];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.itemsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	MoneyTestCell *cell = [[MoneyTestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	cell.titleLabel.text = [self.itemsArray objectAtIndex:indexPath.row];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	cell.checkbox.text = ([userDefaults boolForKey:[NSString stringWithFormat:@"moneyTest%dFlag", (int)indexPath.row]])?@"☑":@"◻";
	
	cell.infoButton.tag = indexPath.row;
	[cell.infoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

	cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

-(void)infoButtonClicked:(UIButton *)button {
	self.popupView2.hidden=!self.popupView2.hidden;
	self.popupView2.titleLabel.text = [self.itemsArray objectAtIndex:button.tag];
	self.popupView2.textView.hidden=NO;
	NSArray *messages = [NSArray arrayWithObjects:
						 @"Check this item if you have at least $500 cash left in your bank accounts after paying all bills for the month.",
						 @"Check this item if you have at least $3000 cash left in your bank accounts after paying all bills for the month.",
						 @"Check this item if you currently do not carry a balance on your credit cards. If you use credit cards but pay off the balance in full each month, then go ahead and check this box.",
						 @"Timeshares are a scam and a waste of money. Only check this box if you do not own any timeshares.",
						 @"Check this item if you do NOT owe any student loans.",
						 @"Collecting junk is a waste of money. Whether its baseball cards or nick-nacks, some day these will end up in the garbage can and you will have nothing to show for your time and money.\n\nIt's far better to be a Creator than a Collector. Find a hobby or craft and become good at it. This is a better investment of your money. Or put your extra cash towards retirement or purchasing real estate or some other project that is building wealth.",
						 @"Check this item if you are currently contributing at least 3% of your income to a 401k or other retirement fund.",
						 @"It is not a good idea to invest in single stocks. It's too risky and too stressful. Don't try to micro manage your investments. You will get burned out. When the market takes a downturn, people end up jumping out of windows. Don't put yourself in a position of having that much stress.\n\nTreat yourself to a low stress retirement strategy. Just invest in trusted, diverse mutual funds and let nature take it's course.\n\nOnce your 401k is maxed out at 15%, move on to investing in real estate. That's where smart money is invested. Dumb money goes towards playing the stock market slot machine.",
						 @"Avoid debt, avoid interest and avoid over-spending. If you vehicles are not currently paid off, it means you spent too much on them.",
						 @"Avoid leases. Never lease a vehicle. You are locking yourself into a lifetime of making large monthly payments, with no wealth building to show for it.",
						 @"Owning a home is the single best wealth-building thing you can do. If you don't currently own a home, figure out a plan of making it happen.",
						 @"Check this item if you are on track to pay off your home in 15 years or less. The key to wealth building is to own assets. Assets that have value. If you owe more than your home is worth, it's not a asset, so don't fall into this trap.",
						 @"Check this item if you have at least 20% equity in your home. This is key to wealth building because it means you can drop PMI, which was monthly money being thrown down the toilet. Its also means your home is now a certified asset and not in danger of going under water.",
						 nil];
	
	if(messages.count>button.tag)
		self.popupView2.textView.text = [messages objectAtIndex:button.tag];
	

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *key = [NSString stringWithFormat:@"moneyTest%dFlag", (int)indexPath.row];
	BOOL flag = [userDefaults boolForKey:key];
	[userDefaults setBool:!flag forKey:key];
	[self.mainTableView reloadData];
	[self calculateScore];
}

-(void)calculateScore {
	int totalNumber = (int)self.itemsArray.count;
	int correctCount=0;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if(totalNumber>0) {
		for (int i=0; i<totalNumber; i++) {
			NSString *key = [NSString stringWithFormat:@"moneyTest%dFlag", i];
			BOOL flag = [userDefaults boolForKey:key];
			if(flag)
				correctCount++;
		}
		int finalScore = correctCount*100/totalNumber;
		self.scoreLabel.text = [NSString stringWithFormat:@"%d%%", finalScore];
		self.scoreLabel.textColor = [UIColor redColor];
		if(finalScore>25)
			self.scoreLabel.textColor = [UIColor orangeColor];
		if(finalScore>50)
			self.scoreLabel.textColor = [UIColor yellowColor];
		if(finalScore>75)
			self.scoreLabel.textColor = [UIColor colorWithRed:0 green:.7 blue:0 alpha:1];
		if(finalScore>99)
			self.scoreLabel.textColor = [UIColor greenColor];
		
	}
}




@end

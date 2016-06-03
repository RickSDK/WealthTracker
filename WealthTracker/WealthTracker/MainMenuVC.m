//
//  MainMenuVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/10/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "MainMenuVC.h"
#import "StartupVC.h"
#import "ObjectiveCScripts.h"
#import "CoreDataLib.h"
#import "UpdateVC.h"
#import "AnalysisVC.h"
#import "GraphLib.h"
#import "NSDate+ATTDate.h"
#import "ChartsVC.h"
#import "NSString+ATTString.h"
#import "BreakdownByMonthVC.h"
#import "OptionsVC.h"
#import "InfoVC.h"
#import "MyPlanVC.h"
#import "GraphObject.h"
#import "UnLockAppVC.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "PlanningVC.h"
#import "BudgetVC.h"
#import "PortfolioVC.h"
#import "AssetsDebtsVC.h"

@interface MainMenuVC ()

@end

@implementation MainMenuVC


- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:[ObjectiveCScripts appName]];
	if(kTestMode)
		[self setTitle:@"Test Mode!"];
	
	
	self.popupArray=[[NSMutableArray alloc] init];
	self.graphObjects = [[NSMutableArray alloc] init];
	self.barGraphObjects = [[NSMutableArray alloc] init];
	
	self.portfolioButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19.f];
	[self.portfolioButton setTitle:[NSString stringWithFormat:@"%@ Portfolio", [NSString fontAwesomeIconStringForEnum:FAbank]] forState:UIControlStateNormal];
	self.chartsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19.f];
	[self.chartsButton setTitle:[NSString stringWithFormat:@"%@ Charts", [NSString fontAwesomeIconStringForEnum:FABarChartO]] forState:UIControlStateNormal];
	self.myPlanButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19.f];
	[self.myPlanButton setTitle:@"" forState:UIControlStateNormal];
	
	self.budgetLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19.f];
	self.budgetLabel.textColor = [UIColor colorWithRed:0 green:.2 blue:.5 alpha:1];
	self.budgetLabel.text = [NSString stringWithFormat:@"%@ Budget", [NSString fontAwesomeIconStringForEnum:FAMoney]];
	self.myPlanButton.titleLabel.frame = CGRectMake(0, 0, 100, 100);
	self.analysisButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19.f];
	[self.analysisButton setTitle:[NSString stringWithFormat:@"%@ Advisor", [NSString fontAwesomeIconStringForEnum:FAUser]] forState:UIControlStateNormal];
	
	self.b2bButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20.f];
	[self.b2bButton setTitle:[NSString stringWithFormat:@"%@ Broke to Baron", [NSString fontAwesomeIconStringForEnum:FAStar]] forState:UIControlStateNormal];
	[self.b2bButton setBackgroundColor:[ObjectiveCScripts lightColor]];
	[self.b2bButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

	
	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	
	self.expiredFlg = [self checkForExpiredFlg];
	
	if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
		//		UIImage *image = [UIImage imageNamed:@"blueGrad.jpg"]; //greenGradient.png
		//		[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.barTintColor = [ObjectiveCScripts darkColor];
		self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
		self.navigationController.navigationBar.translucent = NO;
		self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
	}
	
	[self displayMainTitle];
	self.netWorthView.backgroundColor=[ObjectiveCScripts mediumkColor];
	self.botView.backgroundColor=[ObjectiveCScripts darkColor];
	
	
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:kFontAwesomeFamilyName size:20.f] forKey:UITextAttributeFont]];
	
	self.chartSegmentControl.selectedSegmentIndex=1;
/*
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
											 [UIFont fontWithName:kFontAwesomeFamilyName size:20.f], UITextAttributeFont,
											 [UIColor whiteColor], UITextAttributeTextColor,
											 [UIColor blackColor], UITextAttributeTextShadowColor,
											 [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
											 nil]];
*/	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Plan" style:UIBarButtonItemStyleBordered target:self action:@selector(planButtonPressed)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStyleBordered target:self action:@selector(optionsButtonPressed)];
	
	self.messageView.hidden=YES;
	self.arrowImage.hidden=YES;
	
	[self checkNextItemDue];
	
	self.vaultImageView.hidden=YES;
	self.appLockedFlg=NO;
	if([ObjectiveCScripts getUserDefaultValue:@"lockAppFlg"].length>0) {
		UnLockAppVC *detailViewController = [[UnLockAppVC alloc] initWithNibName:@"UnLockAppVC" bundle:nil];
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	
	
}


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];

	
	if([ObjectiveCScripts getUserDefaultValue:@"appOpened"].length>0) {
		self.vaultImageView.hidden=YES;
		self.appLockedFlg=NO;
	}
	[self setupData];
	
	
}


-(void)setupData {
	self.displaySwitch.on = [@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"displaySwitchFlg"]];
	
	int status = [ObjectiveCScripts badgeStatusForAppWithContext:self.managedObjectContext label:self.percentUpdatedLabel];
	self.percentUpdatedLabel.hidden = (status==0);
	
	
	if([[UIScreen mainScreen] bounds].size.height == 480) {// iPhone 4
		self.percentUpdatedLabel.center = CGPointMake(self.percentUpdatedLabel.center.x, self.botView.frame.origin.y-25);
		self.netWorthView.center = CGPointMake(self.self.botView.center.x, self.self.botView.center.y-60);
		self.chartSegmentControl.hidden=YES;
	}
	
	self.updateNumberLabel.text=@"";
	
	if(status<0) {
		self.updateStatusImageView.image = [UIImage imageNamed:@"yellow.png"];
		self.updateNumberLabel.text=[NSString stringWithFormat:@"%d", status*-1];
	} else if (status==0)
		self.updateStatusImageView.image = [UIImage imageNamed:@"green.png"];
	else
		self.updateStatusImageView.image = [UIImage imageNamed:@"red.png"];
	
	if(status==0)
		self.updateStatusImageView.hidden=YES;
	
	self.needsUpdatingLabel.text = [NSString stringWithFormat:@"%d", status];
	
	
	self.needsUpdatingLabel.hidden=(status<=0);
	self.redCircleImageView.hidden=(status<=0);
	
	[self.popupArray removeAllObjects];
	[self.barGraphObjects removeAllObjects];
	
	[self.popupArray addObject:@"empty"];
	
	
	double prevNetWorth=0;
	double prevValue=0;
	double prevBalance=0;
	
	int displayYear = self.nowYear-1;
	int displayMonth = 12;
	displayMonth=self.nowMonth;
	self.numberOfItems=0;
	
	self.chartLabel.text = @"Net Worth Changes Per Month";
	if (self.chartSegmentControl.selectedSegmentIndex==1)
		self.chartLabel.text = @"Month by Month Tracking";
	if (self.chartSegmentControl.selectedSegmentIndex==2)
		self.chartLabel.text = @"Changes This Month";

	NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"year = %d AND month = %d", displayYear, displayMonth];
	NSArray *itemsPre = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate2 sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	self.numberOfItems=(int)itemsPre.count;
	for (NSManagedObject *mo in itemsPre) {
		prevValue += [[mo valueForKey:@"asset_value"] doubleValue];
		prevBalance += [[mo valueForKey:@"balance_owed"] doubleValue];
	}
	prevNetWorth = (prevValue-prevBalance);
	
	int numMonthsConfirmed = 0;
	
	[self.graphObjects removeAllObjects];
	[self.popupArray addObject:@"Test"];

	for(int i = 1; i <= 12; i++) {
		displayMonth++;
		if(displayMonth>12) {
			displayMonth=1;
			displayYear++;
		}
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %d AND month = %d", displayYear, displayMonth];
		NSArray *updateItems = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		NSString *valFlag = @"N";
		NSString *balFlag = @"N";
		int last30 = 0;
		double value = 0;
		double balance = 0;
		NSString *futureFlag = (displayMonth>self.nowMonth && displayYear>=self.nowYear)?@"Y":@"N";
		
		for(NSManagedObject *mo in updateItems) {
			value += [[mo valueForKey:@"asset_value"] doubleValue];
			balance += [[mo valueForKey:@"balance_owed"] doubleValue];
			
			if([[mo valueForKey:@"val_confirm_flg"] boolValue])
				valFlag=@"Y";
			if([[mo valueForKey:@"bal_confirm_flg"] boolValue])
				balFlag=@"Y";
			
			if (displayMonth==self.nowMonth && displayYear==self.nowYear) {
				
				int item_id = [[mo valueForKey:@"item_id"] intValue];
				double debtChange = [ObjectiveCScripts changedBalanceLast30ForItem:item_id context:self.managedObjectContext];
				if(debtChange<0) {
					NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rowId = %d", item_id];
					NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
					if(items.count>0) {
						NSManagedObject *item = [items objectAtIndex:0];
						[self.barGraphObjects addObject:[GraphLib graphObjectWithName:[item valueForKey:@"name"] amount:debtChange rowId:item_id reverseColorFlg:NO currentMonthFlg:NO]];
					}

				}
			}
		}
		
		if([@"Y" isEqualToString:valFlag] || [@"Y" isEqualToString:balFlag])
			numMonthsConfirmed++;
		
		last30 = (value-balance)-prevNetWorth;
		prevNetWorth = (value-balance);
		prevValue = value;
		prevBalance = balance;
		
		NSString *monthName = [[ObjectiveCScripts monthListShort] objectAtIndex:displayMonth-1];
		[self.graphObjects addObject:[GraphLib graphObjectWithName:monthName amount:last30 rowId:1 reverseColorFlg:NO currentMonthFlg:displayMonth==self.nowMonth && displayYear==self.nowYear]];
		
		[self.popupArray addObject:[NSString stringWithFormat:@"%@ %d|%d|%d|%d|%d|%@|%@|%@", monthName, displayYear, (int)value, (int)balance, (int)(value-balance), last30, valFlag, balFlag, futureFlag]];
		
	} //<-- for month
	
	
	BOOL isDataReady=YES;
	if(self.numberOfItems==0) {
		self.arrowImage.center = CGPointMake(self.assetNameLabel.center.x, self.botView.frame.origin.y-55);
		self.messageView.center = CGPointMake(160, self.botView.frame.origin.y-220);
		self.messageLabel.text = [NSString stringWithFormat:@"Welcome to %@. The best financial app available!\n\nThe purpose of this app is to help you reduce debt and build wealth.\n\nLets start by updating your assets. Click on the assets button below to get started.", [ObjectiveCScripts appName]];
		self.okButton.hidden=YES;
		isDataReady=NO;
	} else if([ObjectiveCScripts getUserDefaultValue:@"DebtsCheckFlg"].length==0) {
		self.arrowImage.center = CGPointMake(self.debtNameLabel.center.x, self.botView.frame.origin.y-55);
		self.messageView.center = CGPointMake(self.screenWidth-160, self.botView.frame.origin.y-220);
		self.messageLabel.text = @"The next step in the process is to track your debts. \n\nClick on the debts button to enter your current debts.";
		self.okButton.hidden=YES;
		isDataReady=NO;
	} else if([ObjectiveCScripts getUserDefaultValue:@"financesFlg"].length==0) {
		self.arrowImage.center = CGPointMake(self.screenWidth/2, self.botView.frame.origin.y-115);
		self.messageView.center = CGPointMake(self.screenWidth/2, self.botView.frame.origin.y-300);
		self.messageLabel.text = @"Good job. You will want to update the Value and Balance of each item in your portfolio on a monthly bases.\n\nAt the bottom of this screen you can view your Net Worth.";
		isDataReady=NO;
		self.okButton.hidden=NO;
	}

	self.arrowImage.hidden=isDataReady;
	self.messageView.hidden=isDataReady;

	self.chartSegmentControl.enabled=isDataReady;
	self.b2bButton.enabled=isDataReady;
	self.portfolioButton.enabled = isDataReady;
	self.myPlanButton.enabled = isDataReady;
	self.chartsButton.enabled = isDataReady;
	self.analysisButton.enabled = isDataReady;
	self.budgetLabel.textColor = (isDataReady)?[ObjectiveCScripts darkColor]:[UIColor grayColor];

	[self displayBottomLabels];
	
	self.graphImageView.layer.cornerRadius = 8.0;
	self.graphImageView.layer.masksToBounds = YES;
	self.graphImageView.layer.borderColor = [UIColor blackColor].CGColor;
	self.graphImageView.layer.borderWidth = 2.0;
	
	self.popUpView.layer.cornerRadius = 8.0;
	self.popUpView.layer.masksToBounds = YES;
	self.popUpView.layer.borderColor = [UIColor blackColor].CGColor;
	self.popUpView.layer.borderWidth = 2.0;
	self.popUpView.backgroundColor=[UIColor colorWithWhite:.8 alpha:1];
	self.popUpView.hidden=YES;
	
	
	self.currentYearLabel.text = [NSString stringWithFormat:@"%d", self.nowYear];
	
	if(self.chartSegmentControl.selectedSegmentIndex==0)
		self.graphImageView.image = [GraphLib graphBarsWithItems:self.graphObjects];
	if(self.chartSegmentControl.selectedSegmentIndex==1)
		self.graphImageView.image = [GraphLib plotItemChart:self.managedObjectContext type:0 displayYear:self.nowYear item_id:0 displayMonth:self.nowMonth startMonth:self.nowMonth startYear:self.nowYear];
	if(self.chartSegmentControl.selectedSegmentIndex==2)
		self.graphImageView.image = [GraphLib pieChartWithItems:self.barGraphObjects startDegree:0];

}



-(void)displayBottomLabels {
	
	self.netWorthNameLabel.text = @"Net Worth";
	self.assetNameLabel.text = @"Assets";
	self.debtNameLabel.text = @"Debts";
	double asset_value1 = [ObjectiveCScripts amountForItem:0 month:self.nowMonth year:self.nowYear field:@"asset_value" context:self.managedObjectContext type:0];
	double balance_owed1 = [ObjectiveCScripts amountForItem:0 month:self.nowMonth year:self.nowYear field:@"balance_owed" context:self.managedObjectContext type:0];
	
	[ObjectiveCScripts displayMoneyLabel:self.netWorthLabel amount:asset_value1-balance_owed1 lightFlg:YES revFlg:NO];
	[ObjectiveCScripts displayMoneyLabel:self.assetsLabel amount:asset_value1 lightFlg:YES revFlg:NO];
	[ObjectiveCScripts displayMoneyLabel:self.debtsLabel amount:balance_owed1 lightFlg:YES revFlg:YES];

	
	double asset_value = [ObjectiveCScripts changedForItem:0 month:self.nowMonth year:self.nowYear field:@"asset_value" context:self.managedObjectContext numMonths:1 type:0];
	double balance_owed = [ObjectiveCScripts changedForItem:0 month:self.nowMonth year:self.nowYear field:@"balance_owed" context:self.managedObjectContext numMonths:1 type:0];
	[ObjectiveCScripts displayNetChangeLabel:self.netWorthChangeLabel amount:asset_value-balance_owed lightFlg:YES revFlg:NO];

	self.monthBotLabel.text = [NSString stringWithFormat:@"Net Worth (%@)", [[NSDate date] convertDateToStringWithFormat:@"MMMM, YYYY"]];
	
	[ObjectiveCScripts displayNetChangeLabel:self.assetChangeLabel amount:asset_value lightFlg:YES revFlg:NO];
	[ObjectiveCScripts displayNetChangeLabel:self.debtChangeLabel amount:balance_owed lightFlg:YES revFlg:YES];
}

-(NSString *)boolToString:(BOOL)flag {
	return (flag)?@"Y":@"N";
}

-(IBAction)displaySwitchChanged:(id)sender {
	[ObjectiveCScripts setUserDefaultValue:[self boolToString:self.displaySwitch.on] forKey:@"displaySwitchFlg"];
	[self setupData];
}

-(void)displayMainTitle {
	if(self.chartSegmentControl.selectedSegmentIndex==0)
		self.chartLabel.text = [NSString stringWithFormat:@"%d Net Worth Change Per Month", self.nowYear];
	if(self.chartSegmentControl.selectedSegmentIndex==1)
		self.chartLabel.text = [NSString stringWithFormat:@"%@ Assets and Debts", [[NSDate date] convertDateToStringWithFormat:@"yyyy"]];
	if(self.chartSegmentControl.selectedSegmentIndex==2)
		self.chartLabel.text = [NSString stringWithFormat:@"%@ Debt Reduction", [[NSDate date] convertDateToStringWithFormat:@"MMMM yyyy"]];
}

-(IBAction)segmentClicked:(id)sender {
	[self.chartSegmentControl changeSegment];
	[self displayMainTitle];
	[self setupData];
}

-(void)checkNextItemDue {
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	int day = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"statement_day > %d", day];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *mo in items) {
		[self fireLocalNotificationForName:[mo valueForKey:@"name"] statement_day:[[mo valueForKey:@"statement_day"] intValue]];
		return;
	}
	day=0;
	NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"statement_day > %d", day];
	NSArray *items2 = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate2 sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *mo in items2) {
		[self fireLocalNotificationForName:[mo valueForKey:@"name"] statement_day:[[mo valueForKey:@"statement_day"] intValue]];
		return;
	}
}

-(void)fireLocalNotificationForName:(NSString *)name statement_day:(int)statement_day {
	int nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	int day = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
	if(statement_day<day) {
		nowMonth++;
		if(nowMonth>12) {
			nowMonth=1;
			nowYear++;
		}
	}
	NSString *dateString = [NSString stringWithFormat:@"%02d/%02d/%d 06:00:00", nowMonth, statement_day, nowYear];
	NSDate *thisDate = [dateString convertStringToDateWithFormat:@"MM/dd/yyyy hh:mm:ss"];
	
	UILocalNotification* local = [[UILocalNotification alloc] init];
	
	if (local)
	{
		local.fireDate = thisDate;
		local.alertBody = [NSString stringWithFormat:@"Update %@ for item: %@", [ObjectiveCScripts appName], name];
		local.timeZone = [NSTimeZone defaultTimeZone];
		[[UIApplication sharedApplication] scheduleLocalNotification:local];
	}
}



-(BOOL)checkForExpiredFlg {
	if([ObjectiveCScripts getUserDefaultValue:@"upgradeFlg"].length>0)
		return NO;
	
	NSString *installTime = [ObjectiveCScripts getUserDefaultValue:@"installTime"];
	if(installTime.length==0) {
		[ObjectiveCScripts setUserDefaultValue:[[NSDate date] convertDateToStringWithFormat:nil] forKey:@"installTime"];
		return NO;
	}
	int secondsSinceInstall = [[NSDate date] timeIntervalSinceDate:[installTime convertStringToDateWithFormat:nil]];
	if(secondsSinceInstall>(60*60*24*30*3)) // 3 month's old
		return YES;
	else
		return NO;
}

-(void)planButtonPressed {
	int incomeTotal=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
	if(incomeTotal==0) {
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Update your income on the 'Budget' page before checking this feature."];
		return;
	}
	int yearBorn = [CoreDataLib getNumberFromProfile:@"yearBorn" mOC:self.managedObjectContext];
	if(yearBorn==0) {
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Update your age on the 'Advisor' page before checking this feature."];
		return;
	}


	PlanningVC *detailViewController = [[PlanningVC alloc] initWithNibName:@"PlanningVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)optionsButtonPressed {
	OptionsVC *detailViewController = [[OptionsVC alloc] initWithNibName:@"OptionsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	NSLog(@"+++shouldAutorotateToInterfaceOrientation");
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (BOOL) shouldAutorotate
{
	NSLog(@"+++shouldAutorotate");
	return NO;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	self.startTouchPosition = [touch locationInView:self.view];
	
//	if(self.initStep>=0) // intro phase
//		return;
	
	if(CGRectContainsPoint(self.netWorthView.frame, self.startTouchPosition) && [ObjectiveCScripts getUserDefaultValue:@"financesFlg"].length>0) {
		BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.tag=4;
		detailViewController.type=0;
		detailViewController.fieldType=2; // equity
		[self.navigationController pushViewController:detailViewController animated:YES];
		return;
	}
	if(CGRectContainsPoint(self.botView.frame, self.startTouchPosition)) {
		if(self.numberOfItems==0 && self.startTouchPosition.x>=[[UIScreen mainScreen] bounds].size.width/2)
			return;
		
		AssetsDebtsVC *detailViewController = [[AssetsDebtsVC alloc] initWithNibName:@"AssetsDebtsVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.filterType=(self.startTouchPosition.x<[[UIScreen mainScreen] bounds].size.width/2)?1:2;
		[self.navigationController pushViewController:detailViewController animated:YES];
		return;
	}
	
	[self displayPopup:self.startTouchPosition];

}

-(void)displayPopup:(CGPoint)point {
	if(self.initStep>=0) // intro phase
		return;
	
	if(self.chartSegmentControl.selectedSegmentIndex==2)
		return; // pie chart

	if(CGRectContainsPoint(self.graphImageView.frame, point)) {
		float x=point.x;
		if(x>[[UIScreen mainScreen] bounds].size.width-80)
			x=[[UIScreen mainScreen] bounds].size.width-80;
		if(x<80)
			x=80;
		
		int month = [GraphLib getMonthFromView:self.graphImageView point:point startingMonth:self.nowMonth];
		
		NSString *popupValues = [self.popupArray objectAtIndex:month-1];
		NSArray *components = [popupValues componentsSeparatedByString:@"|"];
		if(components.count>7) {
			self.popupDateLabel.text = [components objectAtIndex:0];
			double assets = [[components objectAtIndex:1] doubleValue];
			self.popupAssetLabel.text = [NSString stringWithFormat:@"A: %@", [ObjectiveCScripts convertNumberToMoneyString:assets]];
			double debts = [[components objectAtIndex:2] doubleValue];
			self.popupDebtsLabel.text = [NSString stringWithFormat:@"D: %@", [ObjectiveCScripts convertNumberToMoneyString:debts]];
			double netWorth = [[components objectAtIndex:3] doubleValue];
			self.popupNWLabel.text = [NSString stringWithFormat:@"NW: %@", [ObjectiveCScripts convertNumberToMoneyString:netWorth]];
			self.popupNWLabel.textColor = [ObjectiveCScripts colorBasedOnNumber:netWorth lightFlg:NO];
			double last30 = [[components objectAtIndex:4] doubleValue];
			[ObjectiveCScripts displayNetChangeLabel:self.popupLast30Label amount:last30 lightFlg:NO revFlg:NO];

			self.popupValImageView.image = ([@"Y" isEqualToString:[components objectAtIndex:5]])?[UIImage imageNamed:@"green.png"]:[UIImage imageNamed:@"red.png"];
			self.popupBalImageView.image = ([@"Y" isEqualToString:[components objectAtIndex:6]])?[UIImage imageNamed:@"green.png"]:[UIImage imageNamed:@"red.png"];
			if([@"Y" isEqualToString:[components objectAtIndex:7]]) {
				self.popupValImageView.image = [UIImage imageNamed:@"yellow.png"];
				self.popupBalImageView.image = [UIImage imageNamed:@"yellow.png"];
			}
			self.popUpView.hidden=NO;
		} else
			self.popUpView.hidden=YES;

		
		if(month==self.nowMonth)
			self.popUpView.backgroundColor=[UIColor yellowColor];
		else
			self.popUpView.backgroundColor=[UIColor colorWithWhite:.9 alpha:1];

		int i=0;
		for (GraphObject *obj in self.graphObjects) {
			i++;
			obj.currentMonthFlg=NO;
			if(i==month-self.nowMonth || i==month+12-self.nowMonth)
				obj.currentMonthFlg=YES;
		}
		if(self.chartSegmentControl.selectedSegmentIndex==0)
			self.graphImageView.image = [GraphLib graphBarsWithItems:self.graphObjects];
		if(self.chartSegmentControl.selectedSegmentIndex==1)
			self.graphImageView.image = [GraphLib plotItemChart:self.managedObjectContext type:0 displayYear:self.nowYear item_id:0 displayMonth:month startMonth:self.nowMonth startYear:self.nowYear];

		self.popUpView.center=CGPointMake(x, point.y-150);
	} else
		self.popUpView.hidden=YES;

	self.popUpView.hidden=YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint newTouchPosition = [touch locationInView:self.view];
	
	if(self.chartSegmentControl.selectedSegmentIndex==2 && CGRectContainsPoint(self.graphImageView.frame, newTouchPosition)) {

		self.startDegree = [GraphLib spinPieChart:self.graphImageView startTouchPosition:self.startTouchPosition newTouchPosition:newTouchPosition startDegree:self.startDegree barGraphObjects:self.barGraphObjects];
		self.startTouchPosition=newTouchPosition;

	} else
		[self displayPopup:newTouchPosition];

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.popUpView.hidden=YES;
	
}

-(IBAction)budgetButtonClicked:(id)sender {
	BudgetVC *detailViewController = [[BudgetVC alloc] initWithNibName:@"BudgetVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)myPlanButtonClicked:(id)sender {
	int yearBorn = [CoreDataLib getNumberFromProfile:@"yearBorn" mOC:self.managedObjectContext];
	if(yearBorn==0) {
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Update your age on the 'Advisor' page before checking this feature."];
		return;
	}

	MyPlanVC *detailViewController = [[MyPlanVC alloc] initWithNibName:@"MyPlanVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)portfolioButtonClicked:(id)sender {
	AssetsDebtsVC *detailViewController = [[AssetsDebtsVC alloc] initWithNibName:@"AssetsDebtsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.expiredFlg=self.expiredFlg;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)chartsButtonClicked:(id)sender {
	ChartsVC *detailViewController = [[ChartsVC alloc] initWithNibName:@"ChartsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)analysisButtonClicked:(id)sender {
	int incomeTotal=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
	if(incomeTotal==0) {
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Update your income on the 'Budget' page before checking analysis."];
		return;
	}

	AnalysisVC *detailViewController = [[AnalysisVC alloc] initWithNibName:@"AnalysisVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


-(IBAction)okButtonClicked:(id)sender {
	
	
	
	self.initStep++;
	switch (self.initStep) {
  case 1:
			self.messageLabel.text = @"Your goal is to get this number as high as possible. This app will help you achieve that!";
			break;
  case 2:
			[self.arrowImage setImage:[UIImage imageNamed:@"blueArrowUp.png"]];
			self.arrowImage.center = CGPointMake(self.portfolioButton.center.x, self.portfolioButton.frame.origin.y+120);
			self.messageView.center = CGPointMake(self.netWorthView.center.x, self.portfolioButton.center.y+240);
			self.messageLabel.text = @"Use the 'Portfolio' button to track all your assets and debts. Once each month you will enter their values. This only takes a few seconds to update and will help track where your money is going.";
			break;
  case 3:
			self.arrowImage.center = CGPointMake(self.myPlanButton.center.x, self.myPlanButton.frame.origin.y+120);
			self.messageLabel.text = @"Use the 'Budget' tracker to keep track of every dollar you spend. Getting on a budget is the key.";
			break;
  case 4:
			self.arrowImage.center = CGPointMake(self.chartsButton.center.x, self.chartsButton.frame.origin.y+120);
			self.messageView.center = CGPointMake(self.netWorthView.center.x, self.portfolioButton.center.y+290);
			self.messageLabel.text = @"View the 'Charts' to see month by month tracking of your money.";
			break;
  case 5:
			self.arrowImage.center = CGPointMake(self.analysisButton.center.x, self.analysisButton.frame.origin.y+120);
			self.messageLabel.text = @"The Financial Advisor will give you a very detailed breakdown of every area of your finances. Check it to see how you are progressing with your finances.";
			break;
  case 6:
			self.arrowImage.center = CGPointMake(50, self.myPlanButton.frame.origin.y+60);
			self.messageView.center = CGPointMake(self.netWorthView.center.x, self.portfolioButton.center.y+170);
			self.messageLabel.text = @"Check out the Planning section for tips and financial strategy. These tips will help you achieve your financial goals!";
			break;
  case 7:
			self.arrowImage.center = CGPointMake(self.screenWidth-50, self.myPlanButton.frame.origin.y+60);
			self.messageView.center = CGPointMake(self.netWorthView.center.x, self.portfolioButton.center.y+170);
			self.messageLabel.text = @"There are more options and features for this app if you click on the 'Options' button.";
			break;
  case 8:
			self.graphImageView.hidden=NO;
			self.arrowImage.center = CGPointMake(self.b2bButton.center.x, self.myPlanButton.frame.origin.y+80);
			self.messageView.center = CGPointMake(self.netWorthView.center.x, self.portfolioButton.center.y+180);
			self.messageLabel.text = @"Lastly. check out the Broke to Baron plan. This will help guide you to into a healthy financial status!";
			break;
  case 9:
			self.arrowImage.hidden=YES;
			self.messageView.center = CGPointMake(self.netWorthView.center.x, self.portfolioButton.center.y+180);
			self.messageLabel.text = [NSString stringWithFormat:@"Congratulations! You are ready to start using %@. Contact us if you have any questions or suggestions for this app.", [ObjectiveCScripts appName]];
			break;
  case 10:
			self.initStep=-1;
			self.financesButton.hidden=YES;
			self.messageView.hidden=YES;
			self.arrowImage.hidden=YES;
			self.portfolioButton.enabled=YES;
			self.myPlanButton.enabled=YES;
			self.chartsButton.enabled=YES;
			self.analysisButton.enabled=YES;
			self.b2bButton.enabled=YES;
			self.budgetLabel.textColor=[ObjectiveCScripts darkColor];
			[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"financesFlg"];
			break;
			
			
  default:
			break;
	}
}




@end

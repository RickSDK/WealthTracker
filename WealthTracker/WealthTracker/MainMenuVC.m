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


@interface MainMenuVC ()

@end

@implementation MainMenuVC


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];

	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"YYYY"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	
	[self setupData];
}

-(void)setupData {
	self.displaySwitch.on = [@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"displaySwitchFlg"]];
	
	int status = [ObjectiveCScripts badgeStatusForAppWithContext:self.managedObjectContext label:self.percentUpdatedLabel];
	
	self.updateNumberLabel.text=@"";
	
	if(status<0) {
		self.updateStatusImageView.image = [UIImage imageNamed:@"yellow.png"];
		self.updateNumberLabel.text=[NSString stringWithFormat:@"%d", status*-1];
	} else if (status==0)
		self.updateStatusImageView.image = [UIImage imageNamed:@"green.png"];
	else
		self.updateStatusImageView.image = [UIImage imageNamed:@"red.png"];
	
	self.needsUpdatingLabel.text = [NSString stringWithFormat:@"%d", status];
	
	
	self.needsUpdatingLabel.hidden=(status<=0);
	self.redCircleImageView.hidden=(status<=0);
	
	[self.popupArray removeAllObjects];
	[self.popupArray addObject:@"empty"];
	double prevNetWorth=0;
	
	double prevValue=0;
	double prevBalance=0;
	NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"year = %d AND month = 12", self.nowYear-1];
	NSArray *itemsPre = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate2 sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for (NSManagedObject *mo in itemsPre) {
		prevValue += [[mo valueForKey:@"asset_value"] doubleValue];
		prevBalance += [[mo valueForKey:@"balance_owed"] doubleValue];
	}
	prevNetWorth = (prevValue-prevBalance);
	
	double assetChange=0;
	double debtChange=0;
	
	for(int month=1; month<=12; month++) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %d AND month = %d", self.nowYear, month];
		NSArray *updateItems = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		NSString *valFlag = @"N";
		NSString *balFlag = @"N";
		int last30=0;
		double value=0;
		double balance=0;
		NSString *futureFlag = (month>self.nowMonth)?@"Y":@"N";
		
		for(NSManagedObject *mo in updateItems) {
			value+=[[mo valueForKey:@"asset_value"] doubleValue];
			balance += [[mo valueForKey:@"balance_owed"] doubleValue];
			
			if([[mo valueForKey:@"val_confirm_flg"] boolValue])
				valFlag=@"Y";
			if([[mo valueForKey:@"bal_confirm_flg"] boolValue])
				balFlag=@"Y";
		}
		last30 = (value-balance)-prevNetWorth;
		if(month==self.nowMonth) {
			//			netWorthChange=(value-balance)-prevNetWorth;
			assetChange=value-prevValue;
			debtChange=balance-prevBalance;
		}
		prevNetWorth = (value-balance);
		prevValue=value;
		prevBalance=balance;
		
		NSString *monthName = [[ObjectiveCScripts monthListShort] objectAtIndex:month-1];
		
		[self.popupArray addObject:[NSString stringWithFormat:@"%@ %d|%d|%d|%d|%d|%@|%@|%@", monthName, self.nowYear, (int)value, (int)balance, (int)(value-balance), last30, valFlag, balFlag, futureFlag]];
		
	} //<-- for month
	

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
	self.graphImageView.image = [GraphLib plotItemChart:self.managedObjectContext type:0 year:self.nowYear item_id:0 displayMonth:self.nowMonth];
}

-(void)displayBottomLabels {
	if(self.displaySwitch.on) {
		self.netWorthNameLabel.text = @"Change This Month";
		double asset_value = [ObjectiveCScripts changedForItem:0 month:self.nowMonth year:self.nowYear field:@"asset_value" context:self.managedObjectContext numMonths:1 type:0];
		double balance_owed = [ObjectiveCScripts changedForItem:0 month:self.nowMonth year:self.nowYear field:@"balance_owed" context:self.managedObjectContext numMonths:1 type:0];
		[ObjectiveCScripts displayNetChangeLabel:self.netWorthLabel amount:asset_value-balance_owed lightFlg:YES revFlg:NO];
		[ObjectiveCScripts displayNetChangeLabel:self.assetsLabel amount:asset_value lightFlg:YES revFlg:NO];
		[ObjectiveCScripts displayNetChangeLabel:self.debtsLabel amount:balance_owed lightFlg:YES revFlg:YES];
	} else {
		self.netWorthNameLabel.text = @"Net Worth";
		double asset_value = [ObjectiveCScripts amountForItem:0 month:self.nowMonth year:self.nowYear field:@"asset_value" context:self.managedObjectContext type:0];
		double balance_owed = [ObjectiveCScripts amountForItem:0 month:self.nowMonth year:self.nowYear field:@"balance_owed" context:self.managedObjectContext type:0];
		
		[ObjectiveCScripts displayMoneyLabel:self.netWorthLabel amount:asset_value-balance_owed lightFlg:YES revFlg:NO];
		[ObjectiveCScripts displayMoneyLabel:self.assetsLabel amount:asset_value lightFlg:YES revFlg:NO];
		[ObjectiveCScripts displayMoneyLabel:self.debtsLabel amount:balance_owed lightFlg:YES revFlg:YES];
	}
}

-(NSString *)boolToString:(BOOL)flag {
	return (flag)?@"Y":@"N";
}

-(IBAction)displaySwitchChanged:(id)sender {
	[ObjectiveCScripts setUserDefaultValue:[self boolToString:self.displaySwitch.on] forKey:@"displaySwitchFlg"];
	[self displayBottomLabels];
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
	int nowYear = [[[NSDate date] convertDateToStringWithFormat:@"YYYY"] intValue];
	int nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	int day = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
	if(statement_day<day) {
		nowMonth++;
		if(nowMonth>12) {
			nowMonth=1;
			nowYear++;
		}
	}
	NSString *dateString = [NSString stringWithFormat:@"%02d/%02d/%d 06:00:00 AM", nowMonth, statement_day, nowYear];
	NSDate *thisDate = [dateString convertStringToDateWithFormat:@"MM/dd/yyyy hh:mm:ss a"];
	
	UILocalNotification* local = [[UILocalNotification alloc] init];
	
	if (local)
	{
		local.fireDate = thisDate;
		local.alertBody = [NSString stringWithFormat:@"Update Wealth Tracker for item: %@", name];
		local.timeZone = [NSTimeZone defaultTimeZone];
		[[UIApplication sharedApplication] scheduleLocalNotification:local];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Main Menu"];
	if(kTestMode)
		[self setTitle:@"Test Mode!"];
	
	self.popupArray=[[NSMutableArray alloc] init];
	
	self.expiredFlg = [self checkForExpiredFlg];
	
	if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
		UIImage *image = [UIImage imageNamed:@"blueGrad.jpg"]; //greenGradient.png
		[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.barTintColor = [ObjectiveCScripts mediumkColor];
		self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
		self.navigationController.navigationBar.translucent = NO;
		self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1];
	}
	
	self.monthLabel.text = [[NSDate date] convertDateToStringWithFormat:@"MMMM, yyyy"];
	self.netWorthView.backgroundColor=[ObjectiveCScripts mediumkColor];
	self.botView.backgroundColor=[ObjectiveCScripts mediumkColor];

	
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

	if(![ObjectiveCScripts isStartupCompleted]) {
		StartupVC *detailViewController = [[StartupVC alloc] initWithNibName:@"StartupVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(infoButtonPressed)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStyleBordered target:self action:@selector(optionsButtonPressed)];
	
	[self checkNextItemDue];
	
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
	if(secondsSinceInstall>(60*60*24*30*6)) // 6 month's old
		return YES;
	else
		return NO;
}

-(void)infoButtonPressed {
	InfoVC *detailViewController = [[InfoVC alloc] initWithNibName:@"InfoVC" bundle:nil];
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
	CGPoint startTouchPosition = [touch locationInView:self.view];
	
	if(CGRectContainsPoint(self.netWorthView.frame, startTouchPosition)) {
		BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.tag=4;
		detailViewController.type=0;
		detailViewController.fieldType=2; // equity
		[self.navigationController pushViewController:detailViewController animated:YES];
		return;
	}
	if(CGRectContainsPoint(self.botView.frame, startTouchPosition)) {
		BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.tag=(startTouchPosition.x>[[UIScreen mainScreen] bounds].size.width/2)?11:12;
		detailViewController.fieldType=(startTouchPosition.x>[[UIScreen mainScreen] bounds].size.width/2)?1:0;
		detailViewController.type=0;
		[self.navigationController pushViewController:detailViewController animated:YES];
		return;
	}
	
	[self displayPopup:startTouchPosition];

}

-(void)displayPopup:(CGPoint)point {
	if(CGRectContainsPoint(self.graphImageView.frame, point)) {
		float x=point.x;
		if(x>[[UIScreen mainScreen] bounds].size.width-80)
			x=[[UIScreen mainScreen] bounds].size.width-80;
		if(x<80)
			x=80;
		
		float width = self.graphImageView.frame.size.width;
		int month=0;
		if(width>0) {
			int leftEdge = self.graphImageView.center.x-width/2;
			month = (10+point.x-leftEdge)*12/width;
			if(month>12)
				month=12;
		}
		
		NSString *popupValues = [self.popupArray objectAtIndex:month];
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
		}
		
		if(month==self.nowMonth)
			self.popUpView.backgroundColor=[UIColor yellowColor];
		else
			self.popUpView.backgroundColor=[UIColor colorWithWhite:.9 alpha:1];

		self.graphImageView.image = [GraphLib plotItemChart:self.managedObjectContext type:0 year:self.nowYear item_id:0 displayMonth:month];

		self.popUpView.center=CGPointMake(x, point.y-150);
		self.popUpView.hidden=NO;
	} else
		self.popUpView.hidden=YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint newTouchPosition = [touch locationInView:self.view];
	[self displayPopup:newTouchPosition];

}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.popUpView.hidden=YES;
	
}

-(IBAction)myPlanButtonClicked:(id)sender {
	MyPlanVC *detailViewController = [[MyPlanVC alloc] initWithNibName:@"MyPlanVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
-(IBAction)updateButtonClicked:(id)sender {
	UpdateVC *detailViewController = [[UpdateVC alloc] initWithNibName:@"UpdateVC" bundle:nil];
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
	AnalysisVC *detailViewController = [[AnalysisVC alloc] initWithNibName:@"AnalysisVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}




@end

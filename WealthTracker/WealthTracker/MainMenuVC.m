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
#import "StatsVC.h"
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
#import "UsersVC.h"
#import "MoneyTestVC.h"

@interface MainMenuVC ()

@end

@implementation MainMenuVC


- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTitle:[ObjectiveCScripts appName]];
	if(kTestMode)
		[self setTitle:@"Test Mode!"];
	
	self.usersButton.hidden=YES;
	self.graphObjects = [[NSMutableArray alloc] init];
	self.barGraphObjects = [[NSMutableArray alloc] init];
	
	self.monthNameLabel.text = [[NSDate date] convertDateToStringWithFormat:@"MMM"];
	self.monthDayLabel.text = [[NSDate date] convertDateToStringWithFormat:@"d"];
	
	[self makeFAButton:self.portfolioButton icon:[NSString fontAwesomeIconStringForEnum:FAbank] text:@"Portfolio"];
	[self makeFAButton:self.chartsButton icon:[NSString fontAwesomeIconStringForEnum:FABarChartO] text:@"Stats"];
	[self makeFAButton:self.myPlanButton icon:[NSString fontAwesomeIconStringForEnum:FAMoney] text:@"Budget"];
	[self makeFAButton:self.analysisButton icon:[NSString fontAwesomeIconStringForEnum:FAUser] text:@"Advisor"];

	[self makeFAButton:self.b2bButton icon:[NSString fontAwesomeIconStringForEnum:FAStar] text:@"Broke to Baron"];
	[self makeFAButton:self.moneyTestButton icon:[NSString fontAwesomeIconStringForEnum:FAMoney] text:@"Money Test!"];
	self.expiredFlg = [self checkForExpiredFlg];
	self.netWorthView.backgroundColor=[ObjectiveCScripts mediumkColor];
	self.botView.backgroundColor=[ObjectiveCScripts darkColor];
	
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:kFontAwesomeFamilyName size:20.f] forKey:UITextAttributeFont]];
	
	self.chartSegmentControl.selectedSegmentIndex=1;
	[self.chartSegmentControl changeSegment];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	self.itemCountLabel.layer.cornerRadius = 4.0;
	self.itemCountLabel.layer.masksToBounds = YES;				// clips background images to rounded corners

	self.messageView.hidden=YES;
	self.arrowImage.hidden=YES;
	
	[self checkNextItemDue];
	
	self.vaultImageView.hidden=YES;
	self.appLockedFlg=NO;
	if([ObjectiveCScripts getUserDefaultValue:@"lockAppFlg"].length>0) {
		UnLockAppVC *detailViewController = [[UnLockAppVC alloc] initWithNibName:@"UnLockAppVC" bundle:nil];
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	[self setupNavBar];
}

-(void)makeFAButton:(UIButton *)button icon:(NSString *)icon text:(NSString *)text {
	button.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19.f];
	[button setTitle:[NSString stringWithFormat:@"%@ %@", icon, text] forState:UIControlStateNormal];
	[button.titleLabel sizeToFit];
}

-(void)setupNavBar {
	[self tintNavigationBar:self.navigationController.navigationBar];
	self.navigationItem.rightBarButtonItem = [ObjectiveCScripts UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FACog] target:self action:@selector(optionsButtonPressed)];
	
	self.navigationItem.leftBarButtonItem = [ObjectiveCScripts UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAgraduationCap] target:self action:@selector(planButtonPressed)];
}

-(void)tintNavigationBar:(UINavigationBar *)navigationBar {
	[navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
		navigationBar.tintColor = [UIColor colorWithRed:1 green:.8 blue:0 alpha:1]; // button colors
		
		[self applyBGToNavBar:navigationBar image:[UIImage imageNamed:@"blueGrad.jpg"]];
		
		if ([navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
			[navigationBar setBarTintColor:[ObjectiveCScripts darkColor]];
		} else {
			navigationBar.opaque=YES;
			navigationBar.backgroundColor = [ObjectiveCScripts darkColor];
		}
}

-(BOOL)applyBGToNavBar:(UINavigationBar *)navigationBar image:(UIImage *)image {
	if ([navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
		[navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
		return YES;
	} else {
		return NO;
	}
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if([ObjectiveCScripts getUserDefaultValue:@"appOpened"].length>0) {
		self.vaultImageView.hidden=YES;
		self.appLockedFlg=NO;
	}
	
	[self setupData];
}


-(void)viewDidLayoutSubviews {
	self.itemCountLabel.center = CGPointMake(self.portfolioButton.center.x+self.portfolioButton.frame.size.width/2-15, self.portfolioButton.center.y-10);
}

-(void)countItems {
	NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"year = %d AND month = %d", self.nowYear, self.nowMonth];
	NSArray *itemsPre = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate2 sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	self.numberOfItems=(int)itemsPre.count;
}


-(void)setupData {
	[self.barGraphObjects removeAllObjects];
	[self.barGraphObjects addObjectsFromArray:[GraphLib pieItemsForMonth:self.nowMonth year:self.nowYear context:self.managedObjectContext]];
	
	self.chartLabel.text = @"Net Worth Changes Per Month";
	if (self.chartSegmentControl.selectedSegmentIndex==1)
		self.chartLabel.text = @"Month by Month Tracking";
	if (self.chartSegmentControl.selectedSegmentIndex==2)
		self.chartLabel.text = @"Changes This Month";

	self.popUpView.hidden=YES;
	[self countItems];
	
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
	self.usersButton.enabled = isDataReady;
	self.budgetLabel.textColor = (isDataReady)?[ObjectiveCScripts darkColor]:[UIColor grayColor];

	[self displayBottomLabels];
	
	self.currentYearLabel.text = [NSString stringWithFormat:@"%d", self.nowYear];

	if(self.chartSegmentControl.selectedSegmentIndex==2) {
		self.graphImageView.image = [GraphLib pieChartWithItems:self.barGraphObjects startDegree:0];
	} else
		self.graphImageView.image = [GraphLib graphChartForMonth:self.nowMonth year:self.nowYear context:self.managedObjectContext numYears:1 type:4 barsFlg:self.chartSegmentControl.selectedSegmentIndex==0 asset_type:0 amount_type:2];

	self.graphImageView2.hidden=YES;
	if([ObjectiveCScripts isIpadWidth:self.view.frame.size.width]) {
		self.graphImageView2.hidden=NO;
		self.graphImageView2.image = [GraphLib graphChartForMonth:self.nowMonth year:self.nowYear context:self.managedObjectContext numYears:1 type:4 barsFlg:YES asset_type:0 amount_type:2];
		
		float width = self.view.frame.size.width/2;
		self.graphImageView.frame = CGRectMake(0, 200, width, width);
		self.graphImageView2.frame = CGRectMake(width, 200, width, width);
		self.chartSegmentControl.hidden=YES;
	}
	
	[ObjectiveCScripts badgeStatusForAppWithContext:self.managedObjectContext label:self.itemCountLabel];

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

-(IBAction)segmentClicked:(id)sender {
	[self.chartSegmentControl changeSegment];
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
	if([ObjectiveCScripts isUpgraded])
		return NO;
	
	NSString *installTime = [ObjectiveCScripts getUserDefaultValue:@"installTime"];
	if(installTime.length==0) {
		[ObjectiveCScripts setUserDefaultValue:[[NSDate date] convertDateToStringWithFormat:nil] forKey:@"installTime"];
		return NO;
	}
	int secondsSinceInstall = [[NSDate date] timeIntervalSinceDate:[installTime convertStringToDateWithFormat:nil]];
	if(secondsSinceInstall>(60*60*24*30*12)) // 12 month's old
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

-(void)toggleChartSegment {
	self.chartSegmentControl.selectedSegmentIndex = !self.chartSegmentControl.selectedSegmentIndex;
	[self.chartSegmentControl changeSegment];
	[self setupData];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	self.startTouchPosition = [touch locationInView:self.view];
	
	if(self.chartSegmentControl.selectedSegmentIndex<2 && CGRectContainsPoint(self.graphImageView.frame, self.startTouchPosition)) {
		if(self.view.frame.size.width<768)
			[self toggleChartSegment];
		return;
	}
	
	if(CGRectContainsPoint(self.netWorthView.frame, self.startTouchPosition) && [ObjectiveCScripts getUserDefaultValue:@"financesFlg"].length>0) {
		BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.type=4;
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
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint newTouchPosition = [touch locationInView:self.view];
	
	if(self.chartSegmentControl.selectedSegmentIndex==2 && CGRectContainsPoint(self.graphImageView.frame, newTouchPosition)) {

		self.startDegree = [GraphLib spinPieChart:self.graphImageView startTouchPosition:self.startTouchPosition newTouchPosition:newTouchPosition startDegree:self.startDegree barGraphObjects:self.barGraphObjects];
		self.startTouchPosition=newTouchPosition;
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.popUpView.hidden=YES;
	
}

-(IBAction)myPlanButtonClicked:(id)sender {
	int yearBorn = [CoreDataLib getNumberFromProfile:@"yearBorn" mOC:self.managedObjectContext];
	if(yearBorn==0) {
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Update your age on the 'Advisor' page before checking this feature."];
		return;
	}
	[self performSelector:@selector(gotoPlanPage) withObject:nil afterDelay:.01];
}
-(void)gotoPlanPage {
	MyPlanVC *detailViewController = [[MyPlanVC alloc] initWithNibName:@"MyPlanVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)portfolioButtonClicked:(id)sender {
	[self performSelector:@selector(gotoPortfolioPage) withObject:nil afterDelay:.01];
}
-(void)gotoPortfolioPage {
	AssetsDebtsVC *detailViewController = [[AssetsDebtsVC alloc] initWithNibName:@"AssetsDebtsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.expiredFlg=self.expiredFlg;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
-(IBAction)budgetButtonClicked:(id)sender {
	[self performSelector:@selector(gotoBudgetPage) withObject:nil afterDelay:.01];
}

-(void)gotoBudgetPage {
	BudgetVC *detailViewController = [[BudgetVC alloc] initWithNibName:@"BudgetVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)chartsButtonClicked:(id)sender {
	[self performSelector:@selector(gotoStatsPage) withObject:nil afterDelay:.01];
}
-(void)gotoStatsPage {
	StatsVC *detailViewController = [[StatsVC alloc] initWithNibName:@"StatsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)analysisButtonClicked:(id)sender {
	int incomeTotal=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
	if(incomeTotal==0) {
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Update your income on the 'Budget' page before checking analysis."];
		return;
	}
	[self performSelector:@selector(gotoAnalysisPage) withObject:nil afterDelay:.01];
}
-(void)gotoAnalysisPage {
	AnalysisVC *detailViewController = [[AnalysisVC alloc] initWithNibName:@"AnalysisVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)usersButtonClicked:(id)sender {
	UsersVC *detailViewController = [[UsersVC alloc] initWithNibName:@"UsersVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)moneyTestButtonClicked:(id)sender {
	[self performSelector:@selector(gotoTestPage) withObject:nil afterDelay:.01];
}
-(void)gotoTestPage {
	MoneyTestVC *detailViewController = [[MoneyTestVC alloc] initWithNibName:@"MoneyTestVC" bundle:nil];
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
			self.arrowImage.center = CGPointMake(self.portfolioButton.center.x, self.portfolioButton.frame.origin.y+100);
			self.messageView.center = CGPointMake(self.netWorthView.center.x, self.portfolioButton.center.y+240);
			self.messageLabel.text = @"Use the 'Portfolio' button to track all your assets and debts. Once each month you will enter their values. This only takes a few seconds to update and will help track where your money is going.";
			break;
  case 3:
			self.arrowImage.center = CGPointMake(self.myPlanButton.center.x, self.myPlanButton.frame.origin.y+100);
			self.messageLabel.text = @"Use the 'Budget' tracker to keep track of every dollar you spend. Getting on a budget is the key.";
			break;
  case 4:
			self.arrowImage.center = CGPointMake(self.chartsButton.center.x, self.chartsButton.frame.origin.y+100);
			self.messageView.center = CGPointMake(self.netWorthView.center.x, self.portfolioButton.center.y+290);
			self.messageLabel.text = @"View the 'Stats' to see month by month tracking of your money.";
			break;
  case 5:
			self.arrowImage.center = CGPointMake(self.analysisButton.center.x, self.analysisButton.frame.origin.y+100);
			self.messageLabel.text = @"The Financial Advisor will give you a very detailed breakdown of every area of your finances. Check it to see how you are progressing with your finances.";
			break;
  case 6:
			self.arrowImage.center = CGPointMake(50, self.myPlanButton.frame.origin.y+30);
			self.messageView.center = CGPointMake(self.netWorthView.center.x, self.portfolioButton.center.y+170);
			self.messageLabel.text = @"Check out the Planning section for tips and financial strategy. These tips will help you achieve your financial goals!";
			break;
  case 7:
			self.arrowImage.center = CGPointMake(self.screenWidth-50, self.myPlanButton.frame.origin.y+30);
			self.messageView.center = CGPointMake(self.netWorthView.center.x, self.portfolioButton.center.y+170);
			self.messageLabel.text = @"There are more options and features for this app if you click on the 'Options' button.";
			break;
  case 8:
			self.graphImageView.hidden=NO;
			self.arrowImage.center = CGPointMake(self.b2bButton.center.x, self.myPlanButton.frame.origin.y+60);
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

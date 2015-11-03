//
//  AnalysisDetailsVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/14/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "AnalysisDetailsVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "CoreDataLib.h"
#import "ObjectiveCScripts.h"
#import "NSDate+ATTDate.h"
#import "DateCell.h"
#import "BreakdownByMonthVC.h"
#import "GraphLib.h"
#import "GraphObject.h"
#import "ValueObj.h"
#import "TipsVC.h"

#define kProportionList	0.5
#define kProportionAnalysis	0.6


@interface AnalysisDetailsVC ()

@end

@implementation AnalysisDetailsVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title0 = [[NSString alloc] init];
	self.title1 = [[NSString alloc] init];
	self.title2 = [[NSString alloc] init];
	self.altTitle0 = [[NSString alloc] init];

	self.namesArray0 = [[NSMutableArray alloc] init];
	self.valuesArray0 = [[NSMutableArray alloc] init];
	self.chartValuesArray = [[NSMutableArray alloc] init];
	self.colorsArray0 = [[NSMutableArray alloc] init];
	
	self.namesArray1 = [[NSMutableArray alloc] init];
	self.valuesArray1 = [[NSMutableArray alloc] init];
	self.colorsArray1 = [[NSMutableArray alloc] init];
	
	self.namesArray2 = [[NSMutableArray alloc] init];
	self.valuesArray2 = [[NSMutableArray alloc] init];
	self.colorsArray2 = [[NSMutableArray alloc] init];
	
	self.topSegment.layer.backgroundColor = [UIColor colorWithRed:(6/255.0) green:(122/255.0) blue:(180/255.0) alpha:1.0].CGColor;
	self.topSegment.layer.cornerRadius = 7;

	
	NSArray *titles = [NSArray arrayWithObjects:@"Profile", @"Real Estate", @"Auto", @"Debt", @"Wealth", nil];
	[self setTitle:[titles objectAtIndex:self.tag]];

	self.topView.layer.cornerRadius = 8.0;
	self.topView.layer.masksToBounds = YES;
	self.topView.layer.borderColor = [UIColor blackColor].CGColor;
	self.topView.layer.borderWidth = 3.0;

	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"YYYY"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	self.displayYear=self.nowYear;
	self.displayMonth=self.nowMonth;

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Strategy" style:UIBarButtonItemStyleBordered target:self action:@selector(tipsButtonPressed)];

	[ObjectiveCScripts swipeBackRecognizerForTableView:self.mainTableView delegate:self selector:@selector(handleSwipeRight:)];
	
	if(![@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"displaySwitchFlg"]])
		self.topSegment.selectedSegmentIndex=1;

	[self setupData];
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)segmentChanged:(id)sender {
	[self setupData];
}

-(void)tipsButtonPressed {
	TipsVC *detailViewController = [[TipsVC alloc] initWithNibName:@"TipsVC" bundle:nil];
	detailViewController.type=self.tag;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)breakdownButtonPressed {
	int type=self.tag;
	int fieldType = 0;
	if(type==3) {
		type=0;
		fieldType=1;
	}
	if(type==4) {
		type=0;
		fieldType=2;
	}
	
	BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.tag = self.tag;
	detailViewController.type = type;
	detailViewController.fieldType = fieldType;
	detailViewController.displayYear=self.displayYear;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)setupTitles {
	switch (self.tag) {
  case 1:
			self.title0 = @"Properties";
			self.altTitle0 = @"Value";
			self.title1 = @"Real Estate Analysis";
			self.title2 = @"Conclusions";
			break;
  case 2:
			self.title0 = @"Vehicles";
			self.altTitle0 = @"Value";
			self.title1 = @"Vehicle Analysis";
			self.title2 = @"Conclusions";
			break;
  case 3:
			self.title0 = @"Debts";
			self.altTitle0 = @"Remaining Balance";
			self.title1 = @"Debt Analysis";
			self.title2 = @"Conclusions";
			break;
  case 4:
			self.title0 = @"Assets and Debts";
			self.altTitle0 = @"Total Equity";
			self.title1 = @"Wealth Analysis";
			self.title2 = @"Conclusions";
			break;
			
  default:
			break;
	}
	if(self.topSegment.selectedSegmentIndex==0)
		self.altTitle0 = @"Net Change";

}

-(void)setupData {
	
	NSArray *topLeft = [NSArray arrayWithObjects:@"", @"Monthly Payments:", @"Vehicle Value", @"Total Debt", @"Net Worth", nil];
	
	self.monthLabel.text = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
	
	self.nextButton.enabled = !(self.displayYear==self.nowYear && self.displayMonth==self.nowMonth);

	if(self.topSegment.selectedSegmentIndex==0 && self.tag>2)
		self.topLeftlabel.text = @"This Month";
	else
		self.topLeftlabel.text = [topLeft objectAtIndex:self.tag];

	[self.namesArray0 removeAllObjects];
	[self.valuesArray0 removeAllObjects];
	[self.chartValuesArray removeAllObjects];
	[self.colorsArray0 removeAllObjects];
	
	[self.namesArray1 removeAllObjects];
	[self.valuesArray1 removeAllObjects];
	[self.colorsArray1 removeAllObjects];
	
	[self.namesArray2 removeAllObjects];
	[self.valuesArray2 removeAllObjects];
	[self.colorsArray2 removeAllObjects];

	int annual_income = [CoreDataLib getNumberFromProfile:@"annual_income" mOC:self.managedObjectContext];

	[self setupTitles];
	
	switch (self.tag) {
  case 1:	{ // Home (Real estate)
	  int monthlyIncome = annual_income*.8/12;
	  
	  ValueObj *totalValueObj = [self populateTopCellForMonth:self.displayMonth year:self.displayYear context:self.managedObjectContext tag:self.tag];

	  if(totalValueObj.monthlyPayment==0)
		  totalValueObj.monthlyPayment = [CoreDataLib getNumberFromProfile:@"monthly_rent" mOC:self.managedObjectContext];
	  
	  int valueToday = [self homeValueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset]];
	  int valueAtEndOfLastYear = [self homeValueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-self.displayMonth]];
	  int valueLastYear = [self homeValueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-12]];
	  int value3Months = [self homeValueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-3]];

	  [self addNetPercentChangeLabel:@"Value Change Last 3 mo" amountNow:valueToday amountThen:value3Months revFlg:NO];
	  [self addNetPercentChangeLabel:[NSString stringWithFormat:@"Value Change in %d", self.displayYear] amountNow:valueToday amountThen:valueAtEndOfLastYear revFlg:NO];
	  [self addNetPercentChangeLabel:@"Value Change Last 12 mo" amountNow:valueToday amountThen:valueLastYear revFlg:NO];

	  [self addBlankLine];
	  [self addBlackLabelForMoneyWithName:@"Total Monthly Payment" amount:totalValueObj.monthlyPayment];
	  [self addBlackLabelForMoneyWithName:@"Monthly Income" amount:monthlyIncome];
	  
	  int percentOfIncome = [self addPercentLabelWithName:@"% of Net Income" amount:totalValueObj.monthlyPayment otherAmount:monthlyIncome low:25 high:40 revFlg:NO];
 
	  int idealMortgage = monthlyIncome/4;
	  idealMortgage = (idealMortgage/100)*100; // rounding!
	  [self addBlackLabelForMoneyWithName:@"Your Ideal Mortgage" amount:idealMortgage];

	  int idealLoan = (monthlyIncome*118.53/4); // this calculation is based on 4% loan on 15 years
	  idealLoan = (idealLoan/25000)*25000; // rounding!
	  
	  [self addBlackLabelForMoneyWithName:@"Your Ideal Loan" amount:idealLoan];
	  [self addBlankLine];
	  
	  [self addMOneyLabel:@"Total Home Equity" amount:totalValueObj.value-totalValueObj.balance revFlg:NO];
	  int percentOfEquity = [self addPercentLabelWithName:@"Equity %" amount:totalValueObj.value-totalValueObj.balance otherAmount:totalValueObj.value low:5 high:30 revFlg:YES];
	  
	  [self addConclusionsForHome:percentOfIncome value:totalValueObj.value balance:totalValueObj.balance idealLoan:idealLoan equity:percentOfEquity];

	  [ObjectiveCScripts displayNetChangeLabel:self.topRightlabel amount:totalValueObj.monthlyPayment lightFlg:YES revFlg:NO];
  }
			break;
			
  case 2: { // vehicles
	  ValueObj *totalValueObj = [self populateTopCellForMonth:self.displayMonth year:self.displayYear context:self.managedObjectContext tag:self.tag];
 
	  int valueToday = [self vehicleValueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset]];
	  int valueAtEndOfLastYear = [self vehicleValueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-self.displayMonth]];
	  int valueLastYear = [self vehicleValueForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-12]];

	  [self addNetChangeLabel:[NSString stringWithFormat:@"Value Change in %d", self.displayYear] amount:valueToday-valueAtEndOfLastYear revFlg:NO];
	  [self addNetChangeLabel:@"Value Change Last 12 mo" amount:valueToday-valueLastYear revFlg:NO];
	  [self addBlackLabelForMoneyWithName:@"Value of Vehicles" amount:totalValueObj.value];
	  [self addBlackLabelForMoneyWithName:@"Annual Income" amount:annual_income];
	  int percentOfIncome = [self addPercentLabelWithName:@"% of Income" amount:totalValueObj.value otherAmount:annual_income low:25 high:55 revFlg:NO];

	  self.topRightlabel.text = [NSString stringWithFormat:@"%@", [ObjectiveCScripts convertNumberToMoneyString:valueToday]];
	  self.topRightlabel.textColor = [ObjectiveCScripts colorBasedOnNumber:valueToday lightFlg:YES];
	  
	  [self addBlankLine];
	  
	  [self addMOneyLabel:@"Total Vehicle Equity" amount:totalValueObj.value-totalValueObj.balance revFlg:NO];
	  int percentOfEquity = [self addPercentLabelWithName:@"Equity %" amount:totalValueObj.value-totalValueObj.balance otherAmount:totalValueObj.value low:50 high:95 revFlg:YES];

	  [self addConclusionsForVehicle:percentOfIncome value:totalValueObj.value equity:percentOfEquity];
  }
			break;
			
  case 3: { // Debt
	  ValueObj *totalValueObj = [self populateTopCellForMonth:self.displayMonth year:self.displayYear context:self.managedObjectContext tag:self.tag];
	  
	  int badDebtToIncome = 999;
	  int dti = totalValueObj.balance*12/100;
	  int homeDTI=(totalValueObj.balance-totalValueObj.badDebt)*12/100;
	  if(annual_income>0) {
		  badDebtToIncome = totalValueObj.badDebt*100/annual_income;
	  }
	  
	  [self addPercentLabelWithName:@"Gross Debt to Income" amount:totalValueObj.balance otherAmount:annual_income low:150 high:350 revFlg:NO];
	  [self addPercentLabelWithName:@"Housing (DTI) Ratio" amount:homeDTI otherAmount:annual_income low:16 high:27 revFlg:NO];
	  [self addPercentLabelWithName:@"Total Debt (DTI) Ratio" amount:dti otherAmount:annual_income low:19 high:40 revFlg:NO];
	  
	  
	  int detbToAssets = [self addPercentLabelWithName:@"Debt to Assets" amount:totalValueObj.balance otherAmount:totalValueObj.value low:25 high:90 revFlg:NO];
	  [self addBlackLabelForMoneyWithName:@"Interest per Month" amount:totalValueObj.interest];
	  int interestToIncome = 999;
	  if(annual_income>0)
		  interestToIncome = totalValueObj.interest*100/(annual_income*.8/12);

	  int debtToday = [self debtForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset]];
	  int debtLastMonth = [self debtForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-1]];
	  int debtLastQuarter = [self debtForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-3]];
	  int debtLastYear = [self debtForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-12]];
	  
	  double homeDebt30 = [ObjectiveCScripts changedForItem:-1 month:0 year:0 field:@"balance_owed" context:self.managedObjectContext numMonths:1 type:0];
	  double homeDebtChangePast12 = [ObjectiveCScripts changedForItem:-1 month:0 year:0 field:@"balance_owed" context:self.managedObjectContext numMonths:12 type:0];
	  double allDebt30 = debtToday-debtLastMonth;
	  
	  double classADebt30 = allDebt30-homeDebt30;
	  int allDebtChangePast12 = debtToday-debtLastYear;
	  int classAReduction = (homeDebtChangePast12-allDebtChangePast12)/12;
	  if(classADebt30>classAReduction)
		  classAReduction=classADebt30; // take the higher of the two


	  [self addBlankLine];
	  [self addBlackLabelForMoneyWithName:@"Total Class A Debt" amount:totalValueObj.badDebt];
	  [self addNetChangeLabel:@"Change this month" amount:classADebt30 revFlg:YES];
	  
	  if(classAReduction>0) {
		  [self addPerMonthLabelWithName:@"Current Reduction Rate" amount:classAReduction];
		  int monthsToPayoff = totalValueObj.badDebt/classAReduction;
		  [self addMonthsToPayoff:@"Time till Payoff" months:monthsToPayoff];
	  }
	  
	  
	  [self addBlankLine];
	  [self addNetChangeLabel:@"Real Estate Debt change" amount:homeDebt30 revFlg:YES];
	  [self addBlankLine];
	  [self addBlackLabelForMoneyWithName:@"Total Debt" amount:totalValueObj.balance];
	  [self addNetChangeLabel:@"Debt Change This Month" amount:debtToday-debtLastMonth revFlg:YES];
	  [self addNetChangeLabel:@"Debt Last 90 days" amount:debtToday-debtLastQuarter revFlg:YES];
	  [self addNetChangeLabel:@"Debt Last 12 months" amount:debtToday-debtLastYear revFlg:YES];
	  int reduction = (debtLastYear-debtToday)/12;
	  if(reduction>0) {
		  [self addPerMonthLabelWithName:@"Current Reduction Rate" amount:reduction];
		  int monthsToPayoff = totalValueObj.balance/reduction;
		  [self addMonthsToPayoff:@"Time till Payoff" months:monthsToPayoff];
	  }
	  [self addBlankLine];

	  int debtAtEndOfLastYear = [self debtForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-self.displayMonth]];
	  
	  [self addNetPercentChangeLabel:[NSString stringWithFormat:@"Debt Change in %d", self.displayYear] amountNow:debtToday amountThen:debtAtEndOfLastYear revFlg:YES];

	  if(self.topSegment.selectedSegmentIndex==0)
		  [self debtAnalysisMonthlyWithReduction:reduction allDebt30:allDebt30 classADebt:totalValueObj.badDebt classAReduction:classAReduction debtThisYear:debtToday-debtAtEndOfLastYear];
	  else
		  [self debtAnalysisWithDetbToAssets:detbToAssets badDebtToIncome:badDebtToIncome interestToIncome:interestToIncome];

	  if(self.topSegment.selectedSegmentIndex==0)
		  [ObjectiveCScripts displayNetChangeLabel:self.topRightlabel amount:(debtToday-debtLastMonth) lightFlg:YES revFlg:YES];
	  else
		  [ObjectiveCScripts displayMoneyLabel:self.topRightlabel amount:debtToday lightFlg:YES revFlg:YES];
  }
			break;
			
  case 4: { // Wealth
	  ValueObj *totalValueObj = [self populateTopCellForMonth:self.displayMonth year:self.displayYear context:self.managedObjectContext tag:self.tag];

	  [self addMOneyLabel:@"Total Assets" amount:totalValueObj.value revFlg:NO];
	  [self addMOneyLabel:@"Income" amount:annual_income revFlg:NO];
	  [self addMOneyLabel:@"Debt" amount:totalValueObj.balance revFlg:YES];
	  
	  int netWorthToday = [self netWorthForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset]];
	  int netWorthLastMonth = [self netWorthForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-1]];
	  int netWorthLastQuarter = [self netWorthForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-3]];
	  int netWorthLastYear = [self netWorthForMonth:[ObjectiveCScripts yearMonthStringNowPlusMonths:self.monthOffset-12]];

	  [self addNetChangeLabel:@"Net Worth This Month" amount:netWorthToday-netWorthLastMonth revFlg:NO];
	  [self addNetChangeLabel:@"Net Worth Last 90 days" amount:netWorthToday-netWorthLastQuarter revFlg:NO];
	  [self addNetChangeLabel:@"Net Worth Last 12 months" amount:netWorthToday-netWorthLastYear revFlg:NO];

	  double estValuePerYear = netWorthToday-netWorthLastYear;
	  if(netWorthToday>netWorthLastMonth)
		  estValuePerYear = ((netWorthToday-netWorthLastYear)+(netWorthToday-netWorthLastMonth)*12)/2;
	  int age = [CoreDataLib getAge:self.managedObjectContext];
	  int netWorth = totalValueObj.value-totalValueObj.balance;
	  
	  int accumRate = estValuePerYear/12;
	  accumRate = accumRate/100*100;
	  
	  [self addPerMonthLabelWithName:@"Accumulation Rate" amount:accumRate];
	  [self addBlankLine];
	  [self addMOneyLabel:@"Net Worth Today" amount:netWorth revFlg:NO];
	  
	  int retAmount = (int)(netWorth*.08/12);
	  if(retAmount<0)
		  retAmount=0;
	  [self addPerMonthLabelWithName:@"Retirement Amount Today" amount:retAmount];

	  int value=0;
	  for(int i=50; i<=70; i+=10) {
		  if(i>age) {
			  value = netWorthToday+(estValuePerYear*(i-age));
			  value = (value/1000)*1000; // rounding
			  [self addMOneyLabel:[NSString stringWithFormat:@"Est Net Worth at age %d", i] amount:value revFlg:NO];
			  if(value<0)
				  value=0;
			  value*=.08/12;
			  value = (value/100)*100; // rounding
			  [self addPerMonthLabelWithName:@"Retirement Amount" amount:value];
		  }
	  } //<-- for
	  
	  [self addConclusionsForWealth:annual_income estValuePerYear:(double)estValuePerYear netWorthToday:netWorthToday];

	  if(self.topSegment.selectedSegmentIndex==0)
		  [ObjectiveCScripts displayNetChangeLabel:self.topRightlabel amount:(netWorthToday-netWorthLastMonth) lightFlg:YES revFlg:NO];
	  else
		  [ObjectiveCScripts displayMoneyLabel:self.topRightlabel amount:netWorthToday lightFlg:YES revFlg:NO];
  } // end wealth
			break;
			
  default:
			break;
	}
	
	[self.mainTableView reloadData];
}

-(void)addConclusionsForVehicle:(int)percentOfIncome value:(double)value equity:(int)equity {
	NSString *line1 = [NSString stringWithFormat:@"Your vehicles are worth %d%% of your annual income which is too much. Regardless of the interest rates or amount you owe, you are driving vehicles that are too expensive for your income. Seriously consider selling at least one and purchasing a beater instead, until you get your debt under control.\n\nIdeally the value of all vehicles combined should be less than 50%% of your annual income.", percentOfIncome];
	
	
	if(percentOfIncome<60)
		line1 = [NSString stringWithFormat:@"Your vehicles are worth %d%% of your annual income so you are in pretty good shape. Ideally you want to be under 50%%.\n\nNote this is based on their real time value, regardless of what you owe on them or what you paid for them.", percentOfIncome];

	NSString *line2 = [NSString stringWithFormat:@"Your vehicle purchases are currently under water at %d%% equity. In order to build wealth, you need to break out of the cycle of buying expensive cars. If you are having trouble making the payments, consider selling the car and getting a beater until you have some money saved up.", equity];

	if(value==0) {
		line1 = @"You don't own any vehicles.";
		
		line2 = @"If you are considering getting a car, it is best to pay cash instead of financing or leasing. Stay out of debt.";
	} else {
		if(equity>=0)
			line2 = [NSString stringWithFormat:@"Your vehicle purchases are currently sitting at %d%% equity. Follow the plan on the main menu screen in order to get them paid off as quickly as possible.", equity];
		if(equity>=80)
			line2 = @"Great job paying off your vehicles. Remember to ONLY pay cash for future purchases. The goal is to saty out of debt.";
	}

	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"type = 'Vehicle' AND payment_type = 'Leasing'"];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	if(items.count>0)
		line1 = @"You are choosing lease over buy, which is attractive in the near term with low monthly payments, but over the course of a 10 year period, you will end up spending many thousands more by going the lease route. Consider breaking out of the lease cycle and purchasing a used car with cash. It's the smarter way to go if you are trying to build wealth.";

	[self.namesArray2 addObject:@""];
	[self.valuesArray2 addObject:[NSString stringWithFormat:@"%@\n\n%@", line1, line2]];
	[self.colorsArray2 addObject:[UIColor blackColor]];

}

-(void)addConclusionsForHome:(int)percentOfIncome value:(double)value balance:(double)balance idealLoan:(double)idealLoan equity:(int)equity {
	NSString *line1 = [NSString stringWithFormat:@"You are currently paying %d%% of your monthly income towards mortgage/rent which is pretty high. Ideally it should be about 25%%. You may find it difficult to dig out of debt with your current payments. It's important to reduce any other debts you have to make room for this monthly payment. Follow the plan on the main menu screen to further build your wealth.", percentOfIncome];
	
	if(balance < idealLoan)
		line1 = [NSString stringWithFormat:@"You are currently paying %d%% of your monthly income towards mortgage/rent which is pretty high, but it looks like this may be due to agressively paying off your mortgage.\n\nIdeally you want your payments to be about 25%% of your monthly income, based on a 15 year loan.", percentOfIncome];
	
	if(percentOfIncome<34)
		line1 = [NSString stringWithFormat:@"You are currently paying %d%% of your monthly income towards mortgage/rent which is a pretty good number. Ideally you want to be at around 25%%.", percentOfIncome];
	
	
	
	NSString *line2 = [NSString stringWithFormat:@"Your real estate purchases are currently under water at %d%% equity. Your best bet is to remain calm and wait for the market to recover. Start working the plan on the analysis page to get out of the hole.", equity];

	if(value==0) {
		if(percentOfIncome<34)
			line1 = [NSString stringWithFormat:@"You are currently paying %d%% of your monthly income towards rent which is pretty good. Ideally you want to be at around 25%%.\n\nView the plan on the main menu page for details on how to start working towards owning your own home.", percentOfIncome];
		else
			line1 = [NSString stringWithFormat:@"You are currently paying %d%% of your monthly income towards rent which is too high. Ideally you want to be at around 25%%. Strongly consider moving to a smaller rental and start saving up for a home.\n\nAnd view the main menu page for details on starting a good plan of action.", percentOfIncome];
		
		line2 = @"You currently do not own any property. Consider following the plan on the analysis page to start building wealth.";
	} else {
		if(equity>=0)
			line2 = [NSString stringWithFormat:@"Your real estate purchases have %d%% equity which is good, but you are still below the 20%% mark. Start working the plan on the analysis page and aim towards getting the mortgage paid down.", equity];
		if(equity>=20)
			line2 = [NSString stringWithFormat:@"Your real estate purchases are in very good shape, sitting at %d%% equity. You are well on your way towards being debt free. Work the plan on the analysis page to continue building wealth.", equity];
		
		if(equity>=80)
			line2 = @"Fantastic job paying down your mortgages! Continue working the plan on the main menu screen as you watch your wealth build.";
	}
	
	[self.namesArray2 addObject:@""];
	[self.valuesArray2 addObject:[NSString stringWithFormat:@"%@\n\n%@", line1, line2]];
	[self.colorsArray2 addObject:[UIColor blackColor]];

}

-(void)addConclusionsForWealth:(double)annual_income estValuePerYear:(double)estValuePerYear netWorthToday:(double)netWorthToday {
	int idealNetWorth = [ObjectiveCScripts calculateIdealNetWorth:annual_income];
	NSString *idealNetWorthString = [GraphLib smallLabelForMoney:idealNetWorth totalMoneyRange:idealNetWorth];
	
	int timeToReach = 99;
	if(estValuePerYear>1000)
		timeToReach = (idealNetWorth-netWorthToday)/estValuePerYear;
	
	NSString *line1=@"'Retirement Amount' is based on the calculation that you can live off 8% of your net worth if your income ends and you instead liquidate some of your assets.";
	
	int yearBorn = [CoreDataLib getNumberFromProfile:@"yearBorn" mOC:self.managedObjectContext];
	int retirementAge = self.nowYear+timeToReach-yearBorn;
	
	NSString *line2=[NSString stringWithFormat:@"Your target net worth goal is: %@, which will allow you to live the same lifestyle after you retire. At your current rate, this will take you about %d years, allowing you to retire at age %d.", idealNetWorthString, timeToReach, retirementAge];
	
	if(timeToReach>50)
		line2=[NSString stringWithFormat:@"Your target net worth goal is: %@, which will allow you to live the same lifestyle after you retire. However, if things don't change, you are unlikely to achieve this. Start the plan on the main menu screen to improve your outlook.", idealNetWorthString];
	
	if(netWorthToday<=0)
		line2=@"You are currently broke, but you can work your way out of debt and into prosperity if you follow the plan on the main menu screen.";
	
	if(netWorthToday>0 && estValuePerYear<0 && netWorthToday<idealNetWorth/2)
		line2=@"You have a positive net worth, but this past year has not been good to you. You can work your way out of debt and into prosperity if you follow the plan on the main menu screen.";
	
	[self.namesArray2 addObject:@""];
	[self.valuesArray2 addObject:[NSString stringWithFormat:@"%@\n\n%@", line1, line2]];
	[self.colorsArray2 addObject:[UIColor blackColor]];
}

-(void)addBlankLine {
	[self.namesArray1 addObject:@""];
	[self.valuesArray1 addObject:@""];
	[self.colorsArray1 addObject:[UIColor blackColor]];
}

-(void)addBlackLabelForMoneyWithName:(NSString *)name amount:(double)amount {
	[self.namesArray1 addObject:name];
	[self.valuesArray1 addObject:[ObjectiveCScripts convertNumberToMoneyString:amount]];
	[self.colorsArray1 addObject:[UIColor blackColor]];
}

-(void)addMonthsToPayoff:(NSString *)name months:(int)months {
	[self.namesArray1 addObject:name];
	if(months<24)
		[self.valuesArray1 addObject:[NSString stringWithFormat:@"%d months", months]];
	else
		[self.valuesArray1 addObject:[NSString stringWithFormat:@"%.1f years", (float)months/12]];
	[self.colorsArray1 addObject:[UIColor blackColor]];
}


-(void)addPerMonthLabelWithName:(NSString *)name amount:(double)amount {
	[self.namesArray1 addObject:name];
	[self.valuesArray1 addObject:[NSString stringWithFormat:@"%@/mo", [ObjectiveCScripts convertNumberToMoneyString:amount]]];
	[self.colorsArray1 addObject:[UIColor blackColor]];
}

-(int)addPercentLabelWithName:(NSString *)name amount:(double)amount otherAmount:(double)otherAmount low:(int)low high:(int)high revFlg:(BOOL)revFlg {
	
	if(high<=low)
		high=low*2;
	
	NSArray *statuses = [NSArray arrayWithObjects:@"Very Good", @"Good", @"Fair", @"High", @"Very High", nil];
	NSArray *colors = [NSArray arrayWithObjects:
					   [UIColor colorWithRed:0 green:.75 blue:0 alpha:1],
					   [UIColor colorWithRed:0 green:.5 blue:0 alpha:1],
					   [UIColor orangeColor],
					   [UIColor redColor],
					   [UIColor colorWithRed:.5 green:0 blue:0 alpha:1],
					   nil];
	if(revFlg) {
		statuses = [NSArray arrayWithObjects:@"Very Low", @"Low", @"Fair", @"Good", @"Very Good", nil];
		colors = [NSArray arrayWithObjects:
				  [UIColor colorWithRed:.5 green:0 blue:0 alpha:1],
				  [UIColor redColor],
				  [UIColor orangeColor],
				  [UIColor colorWithRed:0 green:.5 blue:0 alpha:1],
				  [UIColor colorWithRed:0 green:.75 blue:0 alpha:1],
				  nil];
	}
	int percent = 100;
	if(otherAmount>0)
		percent = amount*100/otherAmount;
	
	int status=0;
	int third=(high-low)/3;
	if(percent>high)
		status=4;
	else if(percent>high-third)
		status=3;
	else if(percent>high-third*2)
		status=2;
	else if(percent>=low)
		status=1;
	
	
	[self.namesArray1 addObject:name];
	[self.valuesArray1 addObject:[NSString stringWithFormat:@"%d%% (%@)", percent, [statuses objectAtIndex:status]]];
	[self.colorsArray1 addObject:[colors objectAtIndex:status]];
	return percent;
}

-(void)addNetPercentChangeLabel:(NSString *)name amountNow:(double)amountNow amountThen:(double)amountThen revFlg:(BOOL)revFlg {
	[self.namesArray1 addObject:name];
	double value = amountNow-amountThen;
	int percentChange = 0;
	if(amountThen>0)
		percentChange = value*100/amountThen;
	
	NSString *sign = (value<0)?@"":@"+";
	[self.valuesArray1 addObject:[NSString stringWithFormat:@"%@%@ (%d%%)", sign, [ObjectiveCScripts convertNumberToMoneyString:value], percentChange]];
	if(revFlg)
		value*=-1;
	[self.colorsArray1 addObject:[ObjectiveCScripts colorBasedOnNumber:value lightFlg:NO]];

}

-(void)addMOneyLabel:(NSString *)name amount:(double)amount revFlg:(BOOL)revFlg {
	[self.namesArray1 addObject:name];
	[self.valuesArray1 addObject:[ObjectiveCScripts convertNumberToMoneyString:amount]];
	int revInt = (revFlg)?-1:1;
	double colorAmount = amount*revInt;
	[self.colorsArray1 addObject:[ObjectiveCScripts colorBasedOnNumber:colorAmount lightFlg:NO]];
}

-(void)addNetChangeLabel:(NSString *)name amount:(double)amount revFlg:(BOOL)revFlg {
	[self.namesArray1 addObject:name];
	[self.valuesArray1 addObject:[self netChangeForAmount:amount]];
	int revInt = (revFlg)?-1:1;
	double colorAmount = amount*revInt;
	[self.colorsArray1 addObject:[ObjectiveCScripts colorBasedOnNumber:colorAmount lightFlg:NO]];
}

-(ValueObj *)populateTopCellForMonth:(int)month year:(int)year context:(NSManagedObjectContext *)context tag:(int)tag {
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"name" mOC:context ascendingFlg:NO];
	ValueObj *totalValueObj = [[ValueObj alloc] init];
	double totalAmount=0;
	int totalNotCompleted=0;
	BOOL reverseColorFlg=NO;
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:context];
		ValueObj *valueObj = [self valueObjectForObjectId:[obj.rowId intValue] month:month year:year type:obj.type context:context];
		
		
		double amount=0;
		if(tag==1) {
			if(![@"Real Estate" isEqualToString:obj.type])
				continue;
			amount = valueObj.value;
			if(self.topSegment.selectedSegmentIndex==0)
				amount = [ObjectiveCScripts changedForItem:[obj.rowId intValue] month:month year:year field:@"asset_value" context:context numMonths:1 type:0];
		}
		if(tag==2) {
			if(![@"Vehicle" isEqualToString:obj.type])
				continue;
			amount = valueObj.value;
			if(self.topSegment.selectedSegmentIndex==0)
				amount = [ObjectiveCScripts changedForItem:[obj.rowId intValue] month:month year:year field:@"asset_value" context:context numMonths:1 type:0];
		}
		if(tag==3) { // debt
			reverseColorFlg=YES;
			amount = valueObj.balance;
			if(self.topSegment.selectedSegmentIndex==0)
				amount = [ObjectiveCScripts changedForItem:[obj.rowId intValue] month:month year:year field:@"balance_owed" context:context numMonths:1 type:0];
		}
		if(tag==4) { //wealth
			amount = valueObj.value-valueObj.balance;
			if(self.topSegment.selectedSegmentIndex==0)
				amount = [ObjectiveCScripts changedForItem:[obj.rowId intValue] month:month year:year field:nil context:context numMonths:1 type:0];
		}

		totalValueObj.balance+=valueObj.balance;
		totalValueObj.value+=valueObj.value;
		totalValueObj.interest += valueObj.interest;
		totalValueObj.badDebt += valueObj.badDebt;
		totalValueObj.monthlyPayment += [obj.monthly_payment doubleValue]+[obj.homeowner_dues doubleValue];
		totalAmount+=amount;

		if(amount != 0) {
			int reverseNum=(reverseColorFlg)?-1:1;
			if(obj.status == 0 || month != self.nowMonth || year != self.nowYear) {
				[self.namesArray0 addObject:obj.name];
				[self.colorsArray0 addObject:[ObjectiveCScripts colorBasedOnNumber:amount*reverseNum lightFlg:NO]];
			} else {
				[self.namesArray0 addObject:[NSString stringWithFormat:@"*%@", obj.name]];
				[self.colorsArray0 addObject:[UIColor grayColor]];
				totalNotCompleted++;
			}
			[self.chartValuesArray addObject:[GraphLib graphObjectWithName:obj.name amount:amount rowId:[obj.rowId intValue] reverseColorFlg:reverseColorFlg currentMonthFlg:NO]];
			if(self.topSegment.selectedSegmentIndex==0) {
				if(tag==4) {
					float changePercent = 100;
					int denominator = valueObj.balance;
					if(valueObj.value>denominator)
						denominator=valueObj.value;
					if(denominator>0)
						changePercent = amount*100/denominator;
					[self.valuesArray0 addObject:[NSString stringWithFormat:@"%@ (%.1f%%)", [self netChangeForAmount:amount], changePercent]];
				} else
					[self.valuesArray0 addObject:[self netChangeForAmount:amount]];
			} else
				[self.valuesArray0 addObject:[ObjectiveCScripts convertNumberToMoneyString:amount]];
		}
		
	}
	int reverseNum=(reverseColorFlg)?-1:1;
	if(totalNotCompleted>0) {
		[self.namesArray0 addObject:@"*Total"];
		[self.valuesArray0 addObject:[ObjectiveCScripts convertNumberToMoneyString:totalAmount]];
		[self.colorsArray0 addObject:[UIColor grayColor]];
	} else {
		[self.namesArray0 addObject:@"Total"];
		[self.valuesArray0 addObject:[ObjectiveCScripts convertNumberToMoneyString:totalAmount]];
		[self.colorsArray0 addObject:[ObjectiveCScripts colorBasedOnNumber:totalAmount*reverseNum lightFlg:NO]];
	}
	self.netChangeLabel.hidden=YES;
	if(month==self.nowMonth && year==self.nowYear && self.topSegment.selectedSegmentIndex==0)
		[self createBarGraph];

	return totalValueObj;
}

-(void)createBarGraph {
	self.netChangeLabel.hidden=NO;
	[self.chartValuesArray removeAllObjects];
	self.chartValuesArray = [self barItemsForMonth:self.nowMonth nowYear:self.nowYear type:self.tag];
}

-(NSString *)netChangeForAmount:(double)amount {
	NSString *sign = (amount>0)?@"+":@"";
	return [NSString stringWithFormat:@"%@%@", sign, [ObjectiveCScripts convertNumberToMoneyString:amount]];
}

-(ValueObj *)valueObjectForObjectId:(int)rowId month:(int)month year:(int)year type:(NSString *)type context:(NSManagedObjectContext *)context {
	ValueObj *valueObj = [[ValueObj alloc] init];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"month = %d AND year = %d AND item_id = %d", month, year, rowId];
	NSArray *items2 = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:context ascendingFlg:NO];
	if(items2.count>0) {
		NSManagedObject *mo2 = [items2 objectAtIndex:0];
		valueObj.balance = [[mo2 valueForKey:@"balance_owed"] intValue];
		valueObj.value = [[mo2 valueForKey:@"asset_value"] intValue];
		valueObj.interest = [[mo2 valueForKey:@"interest"] intValue];

		if(![@"Real Estate" isEqualToString:type])
			valueObj.badDebt = valueObj.balance;

	}
	return valueObj;
}

-(void)debtAnalysisMonthlyWithReduction:(int)reduction allDebt30:(double)allDebt30 classADebt:(double)classADebt classAReduction:(int)classAReduction debtThisYear:(double)debtThisYear {
	allDebt30*=-1;
	[self.namesArray2 addObject:@""];
	
	int percentComplete = [[ObjectiveCScripts getUserDefaultValue:@"percentComplete"] intValue];
	if(self.displayMonth != self.nowMonth || self.displayYear != self.displayYear)
		percentComplete=100;
	
	NSString *line0=@"";
	if(percentComplete==0)
		line0 = @"Note: You have not started updating your portfolio for this month, so the following analysis may not be relevant.\n\n";
	else if(percentComplete<75)
		line0 = [NSString stringWithFormat:@"Note: You have only updated %d%% of your portfolio for this month, so the following analysis may not be entirely accurate.\n\n", percentComplete];
	else if(percentComplete<100)
		line0 = [NSString stringWithFormat:@"Note: You have only updated %d%% of your portfolio for this month, so the following analysis may still be subject to changes.\n\n", percentComplete];
	
	NSString *had = (percentComplete==100)?@"had":@"are having";
	NSString *wereAble = (percentComplete==100)?@"were able":@"are on pace";
	NSString *line1=@"";
	NSString *line4=@"Keep working the plan on the main menu to further build your wealth.";
	if(reduction>0) { // paying off debt
		if(allDebt30 > reduction) // good month
			line1 = [NSString stringWithFormat:@"You %@ a very good month %@ %d paying off %@ of total debt. Keep the needle moving in the right direction.", had, [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear, [ObjectiveCScripts convertNumberToMoneyString:allDebt30]];
		else // bad month
			line1 = [NSString stringWithFormat:@"You %@ to pay down %@ of total debt this month which is good, but that is below your average. More work is needed.", wereAble, [ObjectiveCScripts convertNumberToMoneyString:allDebt30]];
	} else { // falling further behind
		if(allDebt30 >= 0) // good month
			line1 = [NSString stringWithFormat:@"Good job paying off %@ of total debt this month, but you need to do more to reverse the recent trend of adding more debt.", [ObjectiveCScripts convertNumberToMoneyString:allDebt30]];
		else  {// bad month
			line1 = [NSString stringWithFormat:@"You added %@ more in total debt to an ever growing pile. Not a great month for wealth building.", [ObjectiveCScripts convertNumberToMoneyString:allDebt30*-1]];
			line4 = @"Start working the plan on the main menu to get things under control and stard digging your way out.";
		}
	}
	
	NSString *line2=@"";
	if(classADebt>5000) {
		if(classAReduction>0)
			line2 = [NSString stringWithFormat:@"Your total Class A debt now stands at %@, which puts you about %d months away from being debt free at your current rate.", [ObjectiveCScripts convertNumberToMoneyString:classADebt], (int)classADebt/classAReduction];
		else
			line2 = [NSString stringWithFormat:@"Your total Class A debt now stands at %@ and rising. It's time to put the breaks on spending.", [ObjectiveCScripts convertNumberToMoneyString:classADebt]];
	} else {
		line2 = @"Your class A debt is very managable so great job there. Continue building your wealth and planning for the future.";
	}

	NSString *line3=@"";
	NSString *monStr = [NSString stringWithFormat:@"%d months", 12-self.displayMonth];
	if(self.displayMonth>6)
		monStr = [NSString stringWithFormat:@"just %d months", 12-self.displayMonth];
	if(self.displayMonth>12)
		monStr = @"just one month";

	int debtPerMonth = 0;
	if(self.displayMonth>0)
		debtPerMonth = debtThisYear/self.displayMonth;
	if(debtPerMonth<0) { // paying down
		if(debtPerMonth<-1200)
			line3 = [NSString stringWithFormat:@"You have paid off a good deal of total debt this year with %@ reduced so far in %d, with %@ to go.", [ObjectiveCScripts convertNumberToMoneyString:debtThisYear*-1], self.displayYear, monStr];
		else
			line3 = [NSString stringWithFormat:@"You haven't been able to knock out a huge amount of your total debt this year, but have reduced it by %@ in %d, with %@ to go.", [ObjectiveCScripts convertNumberToMoneyString:debtThisYear*-1], self.displayYear, monStr];

	} else { // more debt
		if(debtPerMonth>1200)
			line3 = [NSString stringWithFormat:@"You have been loading tons of total debt this year with %@ added so far in %d, and %@ left to start paying it down.", [ObjectiveCScripts convertNumberToMoneyString:debtThisYear], self.displayYear, monStr];
		else
			line3 = [NSString stringWithFormat:@"You haven't managed to reduce debt this year and have in fact added %@ in %d, with %@ left to start paying it down.", [ObjectiveCScripts convertNumberToMoneyString:debtThisYear], self.displayYear, monStr];
	}

	[self.valuesArray2 addObject:[NSString stringWithFormat:@"%@%@\n\n%@\n\n%@\n\n%@", line0, line1, line2, line3, line4]];
	[self.colorsArray2 addObject:[UIColor blackColor]];
}



-(void)debtAnalysisWithDetbToAssets:(int)detbToAssets badDebtToIncome:(int)badDebtToIncome interestToIncome:(int)interestToIncome
{
	[self.namesArray2 addObject:@""];
	NSString *line1=nil;
	NSString *line2=nil;
	NSString *line3=nil;
	NSString *line4=nil;
	
	if(detbToAssets>100) { // broke!
		line1 = @"You are flat broke as you owe more to creditors than all your assets are worth.";
		line4 = @"Follow the plan on the main menu screen to get your finances back in order.";
		
		if(badDebtToIncome>40) {
			line2 = [NSString stringWithFormat:@"Your class A debt (which is all debt not counting mortgages) is WAY too high, at %d%% of income. This needs to be paid down ASAP!", badDebtToIncome];
		} else if(badDebtToIncome>30) {
			line2 = [NSString stringWithFormat:@"Your class A debt (which is all debt not counting mortgages) is very high, at %d%% of income and needs to be paid down quickly.", badDebtToIncome];
		} else if(badDebtToIncome>20) {
			line2 = [NSString stringWithFormat:@"Your class A debt (which is all debt not counting mortgages) is too high, at %d%% of income and needs to be paid down.", badDebtToIncome];
		} else if(badDebtToIncome>10) {
			line2 = [NSString stringWithFormat:@"Your class A debt (which is all debt not counting mortgages) is a little high, at %d%% of income and should be paid down.", badDebtToIncome];
		} else {
			line2 = @"Your class A debt (which is all debt not counting mortgages) is in pretty good shape.";
		}
		
	} else { // positive net worth
		if(detbToAssets>75) {
			line1 = @"The good news is that you have a positive net worth.";
			line4 = @"The bad news is that your debts are far too high. Follow the plan on the main menu screen to get your finances in better shape.";
		} else if(detbToAssets>50) {
			line1 = @"Your assets are worth more than your debts, but more work is needed to pay off those debts.";
			line4 = @"Follow the plan on the main menu screen to improve your finances situation.";
		} else if(detbToAssets>25) {
			line1 = @"You have a good asset to debt ratio, but more work is still needed.";
			line4 = @"Follow the plan on the main menu screen to get your finances in perfect shape.";
		} else {
			line1 = @"You have done an outstanding job of keeping your debt low and your assets high.";
			line4 = @"Keep up the good work. Follow the plan on the main menu screen to further improve your finances.";
		}
		
		if(badDebtToIncome>25) {
			line2 = [NSString stringWithFormat:@"Even though you are in overall good financial shape, your class A debt (which is all debt not counting mortgages) is at %d%% of income and makes it hard for you to free up enough monthly income to invest in real estate or other high growth opportunities. Once that debt is paid off you will see a significant rise in your monthly expendable income.", badDebtToIncome];
		} else if(badDebtToIncome>10) {
			line2 = [NSString stringWithFormat:@"Nice job keeping your overall financial shape in a good status. Your class A debt (which is all debt not counting mortgages) is very managable at %d%% of income but the monthly payments are enough to keep you away from your next high ticket purchase. Paying off the rest of that debt would be a wise move at this time.", badDebtToIncome];
		} else {
			line2 = @"Your class A debt (which is all debt not counting mortgages) is in great shape.";
		}
	}
	
	if(interestToIncome>20) {
		line3 = [NSString stringWithFormat:@"As of right now, %d%% of your income goes toward paying interest alone. This is way, WAY too high.", interestToIncome];
	} else if(interestToIncome>=15) {
		line3 = [NSString stringWithFormat:@"As of right now, %d%% of your income goes toward paying interest alone. This is much too high.", interestToIncome];
	} else if(interestToIncome>=10) {
		line3 = [NSString stringWithFormat:@"As of right now, %d%% of your income goes toward paying interest alone. This is a little high.", interestToIncome];
	} else if(interestToIncome>=5) {
		line3 = [NSString stringWithFormat:@"As of right now, %d%% of your income goes toward paying interest alone. This is not bad but the goal is to get it to zero.", interestToIncome];
	} else {
		line3 = [NSString stringWithFormat:@"As of right now, %d%% of your income goes toward paying interest, which puts you in pretty good shape.", interestToIncome];
	}
	
	[self.valuesArray2 addObject:[NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@", line1, line2, line3, line4]];
	[self.colorsArray2 addObject:[UIColor blackColor]];
}

-(int)netWorthForMonth:(NSString *)yearMonth {
	int netWorth=0;
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@", yearMonth];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		int value = [[mo valueForKey:@"asset_value"] intValue];
		int balance = [[mo valueForKey:@"balance_owed"] intValue];
		netWorth+=value;
		netWorth-=balance;
	}
	return netWorth;
}

-(int)debtForMonth:(NSString *)yearMonth {
	int debtTotal=0;
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@", yearMonth];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		int balance = [[mo valueForKey:@"balance_owed"] intValue];
		debtTotal+=balance;
	}
	return debtTotal;
}

-(int)houseEquityForMonth:(NSString *)yearMonth {
	int equity=0;
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND type = 1", yearMonth];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		equity += [[mo valueForKey:@"asset_value"] intValue];
		equity -= [[mo valueForKey:@"balance_owed"] intValue];
	}
	return equity;
}

-(int)vehicleValueForMonth:(NSString *)yearMonth {
	int totalValue=0;
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND type = 2", yearMonth];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		totalValue += [[mo valueForKey:@"asset_value"] intValue];
	}
	return totalValue;
}

-(int)homeValueForMonth:(NSString *)yearMonth {
	int totalValue=0;
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND type = 1", yearMonth];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		totalValue += [[mo valueForKey:@"asset_value"] intValue];
	}
	return totalValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	if(self.topSegment.selectedSegmentIndex==0 || self.tag==4)
		self.graphImageView.image = [GraphLib graphBarsWithItems:self.chartValuesArray];
	else
		self.graphImageView.image = [GraphLib pieChartWithItems:self.chartValuesArray startDegree:self.startDegree];

	if(indexPath.section==0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
		if(self.titleLabel==nil) {
			self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -1, 320, 21)];
			[cell addSubview:self.titleLabel];
		}
		self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
		self.titleLabel.adjustsFontSizeToFitWidth = YES;
		self.titleLabel.minimumScaleFactor = .8;
		
		NSString *monthName = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
		if(self.tag==1)
			self.titleLabel.text = @"Real Estate Values";
		if(self.tag==2)
			self.titleLabel.text = @"Vehicle Values";
		if(self.tag==3) {
		if(self.topSegment.selectedSegmentIndex==0)
			self.titleLabel.text = [NSString stringWithFormat:@"Debts Changes in %@", monthName];
		else
			self.titleLabel.text = [NSString stringWithFormat:@"Total Debt Amounts in %@", monthName];
		}
		if(self.tag==4) {
			if(self.topSegment.selectedSegmentIndex==0)
				self.titleLabel.text = [NSString stringWithFormat:@"Changes in %@", monthName];
			else
				self.titleLabel.text = @"Amount of Debts and Assets";
		}
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		self.titleLabel.textColor = [UIColor blackColor];
		self.titleLabel.backgroundColor = [UIColor clearColor];

		return cell;
	} else if(indexPath.section==1) {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:self.namesArray0.count labelProportion:kProportionList];

		cell.mainTitle = self.title0;
		cell.alternateTitle = self.altTitle0;
	
		cell.titleTextArray = self.namesArray0;
		cell.fieldTextArray = self.valuesArray0;
		cell.fieldColorArray = self.colorsArray0;
	
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else if (indexPath.section==2) {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:self.valuesArray1.count labelProportion:kProportionAnalysis];
		cell.mainTitle = self.title1;
		cell.alternateTitle = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
		cell.titleTextArray = self.namesArray1;
		cell.fieldTextArray = self.valuesArray1;
		cell.fieldColorArray = self.colorsArray1;
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:self.valuesArray2.count labelProportion:0];
		cell.mainTitle = self.title2;
		cell.alternateTitle = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
		cell.titleTextArray = self.namesArray2;
		cell.fieldTextArray = self.valuesArray2;
		cell.fieldColorArray = self.colorsArray2;
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
}

-(IBAction)prevButtonPressed:(id)sender {
	self.monthOffset--;
	self.displayMonth--;
	if(self.displayMonth<=0) {
		self.displayMonth=12;
		self.displayYear--;
	}
	[self setupData];
}

-(IBAction)nextButtonPressed:(id)sender {
	self.monthOffset++;
	self.displayMonth++;
	if(self.displayMonth>=12) {
		self.displayMonth=1;
		self.displayYear++;
	}
	[self setupData];
}

-(void)prevYearButtonPressed {
}

-(void)nextYearButtonPressed {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self breakdownButtonPressed];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0)
		return 20;
	if(indexPath.section==1)
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:self.valuesArray0
																   tableView:self.mainTableView
														labelWidthProportion:kProportionList]+20;
	if(indexPath.section==2)
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:self.valuesArray1
																   tableView:self.mainTableView
														labelWidthProportion:kProportionAnalysis]+20;

	return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:self.valuesArray2
															   tableView:self.mainTableView
													labelWidthProportion:0]+20;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	self.startTouchPosition = [touch locationInView:self.view];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint newTouchPosition = [touch locationInView:self.view];
	
	if(self.topSegment.selectedSegmentIndex==1) {
		
		self.startDegree = [GraphLib spinPieChart:self.graphImageView startTouchPosition:self.startTouchPosition newTouchPosition:newTouchPosition startDegree:self.startDegree barGraphObjects:self.chartValuesArray];
		self.startTouchPosition=newTouchPosition;
		
		return; // pie chart
	} else {
		float width = self.graphImageView.frame.size.width;
		int month=0;
		if(width>0) {
			int leftEdge = self.graphImageView.center.x-width/2;
			month = (10+newTouchPosition.x-leftEdge)*12/width;
			if(month>12)
				month=12;
		}
		[self.chartValuesArray removeAllObjects];
		self.chartValuesArray = [self barItemsForMonth:month nowYear:self.nowYear type:self.tag];
		self.graphImageView.image = [GraphLib graphBarsWithItems:self.chartValuesArray];

	}
}

-(NSMutableArray *)barItemsForMonth:(int)nowMonth nowYear:(int)nowYear type:(int)type {
	double prevNetWorth=0;
	double prevValue=0;
	double prevBalance=0;
	
	NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"year = %d AND month = 12", nowYear-1];
	NSArray *itemsPre = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate2 sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for (NSManagedObject *mo in itemsPre) {
		double asset_value = [[mo valueForKey:@"asset_value"] doubleValue];
		double balance_owed = [[mo valueForKey:@"balance_owed"] doubleValue];

		int itemType = [[mo valueForKey:@"type"] intValue];
		if(type==1 && itemType!=1) {
			asset_value=0;
			balance_owed=0;
		}
		if(type==2 && itemType!=2) {
			asset_value=0;
			balance_owed=0;
		}

		prevValue += asset_value;
		prevBalance += balance_owed;
	}
	prevNetWorth = (prevValue-prevBalance);
	
	int numMonthsConfirmed = 0;
	
	NSMutableArray *graphObjects = [[NSMutableArray alloc] init];
	for(int month = 1; month <= 12; month++) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year = %d AND month = %d", nowYear, month];
		NSArray *updateItems = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		NSString *valFlag = @"N";
		NSString *balFlag = @"N";
		int last30 = 0;
		double value = 0;
		double balance = 0;
		
		for(NSManagedObject *mo in updateItems) {
			double itemValue = [[mo valueForKey:@"asset_value"] doubleValue];
			double itemBalance = [[mo valueForKey:@"balance_owed"] doubleValue];
			
			if([[mo valueForKey:@"val_confirm_flg"] boolValue])
				valFlag=@"Y";
			if([[mo valueForKey:@"bal_confirm_flg"] boolValue])
				balFlag=@"Y";
			
			int itemType = [[mo valueForKey:@"type"] intValue];
			if(type==1 && itemType!=1) {
				itemValue=0;
				itemBalance=0;
			}
			if(type==2 && itemType!=2) {
				itemValue=0;
				itemBalance=0;
			}
			
			value += itemValue;
			balance += itemBalance;
			
		}
		
		if([@"Y" isEqualToString:valFlag] || [@"Y" isEqualToString:balFlag])
			numMonthsConfirmed++;
		
		last30 = (value-balance)-prevNetWorth;
		if(type==3)
			last30=balance-prevBalance;
		
		prevNetWorth = (value-balance);
		prevValue = value;
		prevBalance = balance;
		
		if(month==nowMonth)
			[ObjectiveCScripts displayNetChangeLabel:self.netChangeLabel amount:last30 lightFlg:NO revFlg:type==3];
		
		NSString *monthName = [[ObjectiveCScripts monthListShort] objectAtIndex:month-1];
		[graphObjects addObject:[GraphLib graphObjectWithName:monthName amount:last30 rowId:1 reverseColorFlg:type==3 currentMonthFlg:month==nowMonth]];
		
	}
	return graphObjects;
}


@end

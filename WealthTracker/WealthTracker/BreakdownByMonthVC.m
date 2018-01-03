//
//  BreakdownByMonthVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/22/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "BreakdownByMonthVC.h"
#import "CoreDataLib.h"
#import "ObjectiveCScripts.h"
#import "NSDate+ATTDate.h"
#import "BreakdownCell.h"
#import "GraphLib.h"
#import "GraphObject.h"
#import "GraphCell.h"
#import "BreakdownSingleMonthVC.h"
#import "PayoffVC.h"
#import "RateVC.h"
#import "UpdateDetails.h"

@interface BreakdownByMonthVC ()

@end

@implementation BreakdownByMonthVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	if(![ObjectiveCScripts isIpadWidth:self.view.frame.size.width])
		self.changeSegmentControl.selectedSegmentIndex=1;
	[self setupData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	

	
	self.topGraphImageView = [[UIImageView alloc] init];
	self.dataArray2 = [[NSMutableArray alloc] init];
	
	if(self.itemObject) {
		self.type = [ObjectiveCScripts typeNumberFromTypeString:self.itemObject.type];
		self.row_id = [self.itemObject.rowId intValue];
	}

	NSLog(@"+++BreakdownByMonthVC type: %d, [%d]", self.type, self.row_id);

	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	if(self.displayYear==0)
		self.displayYear=self.nowYear;
	self.displayMonth = self.nowMonth;
	
	if(self.type==1 ||self.type==2 ||self.type==4)
		self.topSegmentControl.selectedSegmentIndex=2;
	if(self.type==3) {
		self.topSegmentControl.selectedSegmentIndex=1;
		self.topSegmentControl.enabled=NO;
	}
	if(self.type==5 || self.type==6) {
		self.topSegmentControl.selectedSegmentIndex=1;
		self.topSegmentControl.enabled=NO;
	}
	if(self.type==7) {
		self.topSegmentControl.selectedSegmentIndex=0;
		self.topSegmentControl.enabled=NO;
	}
	
	self.topSegmentControl.hidden = (self.type==5);
	[self setTitle:self.itemObject?self.itemObject.name:[self labelForType:self.type]];

	[ObjectiveCScripts swipeBackRecognizerForTableView:self.mainTableView delegate:self selector:@selector(handleSwipeRight:)];
	
	if(self.type==4) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Rate" style:UIBarButtonItemStyleBordered target:self action:@selector(rateVC)];
	} else {
		[self addHomeButton];
//		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(mainMenuClicked)];
	}
	[self.topSegmentControl changeSegment];
}

-(NSString *)labelForType:(int)type {
	NSArray *titles = [NSArray arrayWithObjects:@"Assets", @"Real Estate", @"Vehicle", @"Debt", @"Net Worth", @"Interest", @"Loans/Credit Card", @"Investments", nil];
	return [titles objectAtIndex:type];
}


-(void)payoffDay {
	
	UpdateDetails *detailViewController = [[UpdateDetails alloc] initWithNibName:@"UpdateDetails" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.itemObject = self.itemObject;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)rateVC {
	RateVC *detailViewController = [[RateVC alloc] initWithNibName:@"RateVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


-(void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)setupData {
	self.yearLabel.text = [NSString stringWithFormat:@"%d", self.displayYear];
	
	self.nextYearButton.enabled = !(self.displayYear>=self.nowYear && self.displayMonth>=self.nowMonth);
	
	[self.dataArray2 removeAllObjects];
	NSMutableArray *chart2Objects = [[NSMutableArray alloc] init];

	NSString *field = @""; // <-- equity
	if(self.topSegmentControl.selectedSegmentIndex==0) {
		field = @"asset_value";
	}
	if(self.topSegmentControl.selectedSegmentIndex==1) {
		field = @"balance_owed";
	}
	
	if(self.type==5)
		field = @"interest";
	
	int year=self.displayYear;
	int month=self.displayMonth;
	year--;
	for(int i=1; i<=12; i++) {
		
		month++;
		if(month>12) {
			month=1;
			year++;
		}

		double amount = [ObjectiveCScripts changedForItem:self.row_id month:month year:year field:field context:self.managedObjectContext numMonths:1 type:self.type];

		double total = [ObjectiveCScripts amountForItem:self.row_id month:month year:year field:field context:self.managedObjectContext type:self.type];
		[self.dataArray2 addObject:[NSString stringWithFormat:@"%f|%f", total, amount]];
		[chart2Objects addObject:[GraphObject graphObjectWithName:[ObjectiveCScripts monthNameForNum:month-1] amount:total rowId:1 reverseColorFlg:NO currentMonthFlg:NO]];
		
	}

	self.chartImageView2.image = [GraphLib graphBarsWithItems:chart2Objects];

	if(self.changeSegmentControl.selectedSegmentIndex==0)
		self.graphTitleLabel.text = [NSString stringWithFormat:@"%@ Totals by Month", [ObjectiveCScripts fieldTypeNameForFieldType:self.type]];
	else
		self.graphTitleLabel.text = [NSString stringWithFormat:@"%@ Change by Month", [ObjectiveCScripts fieldTypeNameForFieldType:self.type]];
	
	
	
	int amount_type = (int)self.topSegmentControl.selectedSegmentIndex;
	if(self.type==5)
		amount_type = 3;
	
	
	if(self.row_id>0) {
		NSArray *graphArray = [GraphLib barChartValuesLast6MonthsForItem:self.row_id month:self.displayMonth year:self.displayYear reverseColorFlg:(self.topSegmentControl.selectedSegmentIndex==1 || self.type==5) type:self.type context:self.managedObjectContext fieldType:amount_type displayTotalFlg:self.changeSegmentControl.selectedSegmentIndex==0];
		
		self.topGraphImageView.image = [GraphLib graphBarsWithItems:graphArray];
	} else {
		self.topGraphImageView.image = [GraphLib graphChartForMonth:self.displayMonth year:self.displayYear context:self.managedObjectContext numYears:1 type:self.type barsFlg:self.changeSegmentControl.selectedSegmentIndex==1 asset_type:self.type amount_type:amount_type];
	}

	int width = [[UIScreen mainScreen] bounds].size.width;
	self.topGraphImageView.frame = CGRectMake(0, 20, width, width/2-20);

	[self.changeSegmentControl changeSegment];
	[self.mainTableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	if(indexPath.section==0) {
		NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
//		cell.backgroundView = [[UIImageView alloc] initWithImage:self.topGraphImageView.image];
		cell.backgroundView	= [ObjectiveCScripts imageViewForWidth:self.view.frame.size.width chart1:self.topGraphImageView.image chart2:self.chartImageView2.image switchFlg:self.topSegment.selectedSegmentIndex==1];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}

	BreakdownCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[BreakdownCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	int month=self.displayMonth+(int)indexPath.row;
	if(month>12)
		month-=12;

	cell.monthLabel.text=[[ObjectiveCScripts monthListShort] objectAtIndex:month];

	double total=0;
	double amount=0;
	NSArray *components = [[self.dataArray2 objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];
	if(components.count>1) {
		total = [[components objectAtIndex:0] doubleValue];
		amount = [[components objectAtIndex:1] doubleValue];
		[ObjectiveCScripts displayMoneyLabel:cell.amountLabel amount:total lightFlg:NO revFlg:(self.topSegmentControl.selectedSegmentIndex==1)];
		[ObjectiveCScripts displayNetChangeLabel:cell.past30DaysLabel amount:amount lightFlg:NO revFlg:(self.topSegmentControl.selectedSegmentIndex==1)];
	}
	
	if(self.displayYear==self.nowYear && indexPath.row==11)
		cell.backgroundColor=[UIColor yellowColor];
	else
		cell.backgroundColor=[UIColor whiteColor];

//	if(total==0 && amount==0) {
//		cell.backgroundColor = [UIColor grayColor];
//		cell.monthLabel.text = @"No Data";
//		cell.amountLabel.text = @"-";
//		cell.past30DaysLabel.text = @"-";
//		self.prevYearButton.enabled=NO;
//	}


	if(self.displayYear>self.nowYear || (self.displayYear==self.nowYear && self.nowMonth<indexPath.row+1)) {
//		cell.monthLabel.textColor = [UIColor grayColor];
//		cell.amountLabel.textColor = [UIColor grayColor];
//		cell.past30DaysLabel.textColor = [UIColor grayColor];
//		cell.backgroundColor=[UIColor colorWithWhite:.8 alpha:1];
	} else {
		cell.monthLabel.textColor = [UIColor blackColor];
	}
	
	if(indexPath.section>0 && self.row_id==0)
		cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	else
		cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

-(IBAction)prevYearButtonPressed:(id)sender {
	self.displayMonth-=12;
	if(self.displayMonth<1) {
		self.displayMonth+=12;
		self.displayYear--;
	}
	[self setupData];
}
-(IBAction)nextYearButtonPressed:(id)sender {
	self.prevYearButton.enabled=YES;
	self.displayMonth+=12;
	if(self.displayMonth>12) {
		self.displayMonth-=12;
		self.displayYear++;
	}
	[self setupData];
}

-(IBAction)topSegmentChanged:(id)sender {
//	self.fieldType = (int)self.topSegmentControl.selectedSegmentIndex;
	[self.topSegmentControl changeSegment];
	[self setupData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==0)
		return 1;
	else
		return self.dataArray2.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0) {
		self.changeSegmentControl.selectedSegmentIndex=(self.changeSegmentControl.selectedSegmentIndex==0);
		[self setupData];
	}
	if(indexPath.section==1 && self.row_id==0) {
		int year=self.nowYear-1;
		int month=self.nowMonth+(int)indexPath.row+1;
		if(month>12) {
			month-=12;
			year++;
		}

		BreakdownSingleMonthVC *detailViewController = [[BreakdownSingleMonthVC alloc] initWithNibName:@"BreakdownSingleMonthVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.displayYear=year;
		detailViewController.displayMonth=month;
		detailViewController.nowYear=self.nowYear;
		detailViewController.nowMonth=self.nowMonth;
		detailViewController.fieldType=(int)self.topSegmentControl.selectedSegmentIndex;
		detailViewController.type=self.type;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section==0)
		return CGFLOAT_MIN;
	else
		return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(section==1) {
	float screenWidth = [[UIScreen mainScreen] bounds].size.width;
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenWidth, 20.0)];
	customView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
	// create the button object
	UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 100, 20)];
	monthLabel.backgroundColor = [UIColor clearColor];
	monthLabel.textColor = [UIColor blackColor];
	monthLabel.font = [UIFont boldSystemFontOfSize:16];
	monthLabel.text = @"Month";
	[customView addSubview:monthLabel];

	UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 0.0, 100, 20)];
	amountLabel.backgroundColor = [UIColor clearColor];
	amountLabel.textColor = [UIColor blackColor];
	amountLabel.font = [UIFont boldSystemFontOfSize:16];
	amountLabel.text = @"Amount";
	[customView addSubview:amountLabel];
	
	UILabel *changeLabel = [[UILabel alloc] initWithFrame:CGRectMake(200.0, 0.0, 100, 20)];
	changeLabel.backgroundColor = [UIColor clearColor];
	changeLabel.textColor = [UIColor blackColor];
	changeLabel.font = [UIFont boldSystemFontOfSize:16];
	changeLabel.text = @"Past 30 Days";
	[customView addSubview:changeLabel];
	

	return customView;
	} else
		return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0)
		return 190;
//		return [ObjectiveCScripts chartHeightForSize:190];
	else
		return 34;
}

-(IBAction)changeSegmentChanged:(id)sender {
	[self setupData];
}


@end

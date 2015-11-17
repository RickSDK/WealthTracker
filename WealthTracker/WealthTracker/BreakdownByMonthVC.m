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
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:self.itemObject?self.itemObject.name:[ObjectiveCScripts typeLabelForType:self.type fieldType:self.fieldType]];
	
	NSLog(@"+++BreakdownByMonthVC type: %d, fieldType: %d", self.type, self.fieldType);

	
	self.topGraphImageView = [[UIImageView alloc] init];
	self.dataArray2 = [[NSMutableArray alloc] init];
	
	
	if(self.itemObject) {
		self.titleLabel.text = self.itemObject.name;
		self.type = [ObjectiveCScripts typeNumberFromTypeString:self.itemObject.type];
		self.row_id = [self.itemObject.rowId intValue];
	} else {
		self.titleLabel.text = [ObjectiveCScripts typeLabelForType:self.type fieldType:self.fieldType];
	}

	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"YYYY"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	if(self.displayYear==0)
		self.displayYear=self.nowYear;
	self.displayMonth = self.nowMonth;
	
	if(self.tag==3 || self.type==3 || self.fieldType==1) {
		self.topSegmentControl.selectedSegmentIndex=1;
		self.topSegmentControl.enabled=NO;
		self.fieldType=1;
	}
	if(self.tag==4 || self.type==4 || self.tag==99 || self.fieldType==3)
		self.topSegmentControl.enabled=NO;
	
	if(self.fieldType==0 && self.type==0)
		self.topSegmentControl.enabled=NO;
	
	if(self.fieldType==2)
		self.topSegmentControl.selectedSegmentIndex=2;
	
	
	[ObjectiveCScripts swipeBackRecognizerForTableView:self.mainTableView delegate:self selector:@selector(handleSwipeRight:)];
	
	if(self.row_id>0) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStyleBordered target:self action:@selector(payoffDay)];
	} else if(self.type==0 && self.fieldType==2) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Rate" style:UIBarButtonItemStyleBordered target:self action:@selector(rateVC)];
	}


	[self setupData];
}

-(void)payoffDay {
	
	UpdateDetails *detailViewController = [[UpdateDetails alloc] initWithNibName:@"UpdateDetails" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.itemObject = self.itemObject;
	[self.navigationController pushViewController:detailViewController animated:YES];

//	PayoffVC *detailViewController = [[PayoffVC alloc] initWithNibName:@"PayoffVC" bundle:nil];
//	detailViewController.managedObjectContext = self.managedObjectContext;
//	detailViewController.row_id=self.row_id;
//	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)rateVC {
	RateVC *detailViewController = [[RateVC alloc] initWithNibName:@"RateVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


-(void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
	[self.navigationController popViewControllerAnimated:YES];
}

-(NSPredicate *)predicateForYearMonth:(NSString *)year_month item_id:(int)item_id tag:(int)tag {
	if(item_id>0)
		return [NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", year_month, item_id];
	
	if(tag==1 || tag==2)
		return [NSPredicate predicateWithFormat:@"year_month = %@ AND type = %d", year_month, tag];

	return [NSPredicate predicateWithFormat:@"year_month = %@", year_month];
}


-(void)setupData {
	self.yearLabel.text = [NSString stringWithFormat:@"%d", self.displayYear];
	
	self.nextYearButton.enabled = !(self.displayYear>=self.nowYear && self.displayMonth>=self.nowMonth);
	
	[self.dataArray2 removeAllObjects];

	for(int i=1; i<=12; i++) {
		
		NSArray *fieldTypes = [NSArray arrayWithObjects:@"asset_value", @"balance_owed", @"", @"interest", nil];
		NSString *field = [fieldTypes objectAtIndex:self.fieldType];
		double amount = [ObjectiveCScripts changedForItem:self.row_id month:i year:self.displayYear field:field context:self.managedObjectContext numMonths:1 type:self.type];

		double total = [ObjectiveCScripts amountForItem:self.row_id month:i year:self.displayYear field:field context:self.managedObjectContext type:self.type];
		
		[self.dataArray2 addObject:[NSString stringWithFormat:@"%f|%f", total, amount]];
		
	}
	
	if(self.displayTotalFlg)
		self.graphTitleLabel.text = [NSString stringWithFormat:@"%@ Totals by Month", [ObjectiveCScripts fieldTypeNameForFieldType:self.fieldType]];
	else
		self.graphTitleLabel.text = [NSString stringWithFormat:@"%@ Change by Month", [ObjectiveCScripts fieldTypeNameForFieldType:self.fieldType]];
	
	NSArray *graphArray = [GraphLib barChartValuesLast6MonthsForItem:self.row_id month:self.displayMonth year:self.displayYear reverseColorFlg:(self.topSegmentControl.selectedSegmentIndex==1 || self.tag==99) type:self.type context:self.managedObjectContext fieldType:self.fieldType displayTotalFlg:self.displayTotalFlg];
	
	self.topGraphImageView.image = [GraphLib graphBarsWithItems:graphArray];
	int width = [[UIScreen mainScreen] bounds].size.width;
	self.topGraphImageView.frame = CGRectMake(0, 20, width, width/2-20);

	[self.mainTableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	if(indexPath.section==0) {
		NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		cell.backgroundView = [[UIImageView alloc] initWithImage:self.topGraphImageView.image];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}

	BreakdownCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[BreakdownCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	cell.monthLabel.text=[[ObjectiveCScripts monthListShort] objectAtIndex:indexPath.row];

	double total=0;
	double amount=0;
	NSArray *components = [[self.dataArray2 objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];
	if(components.count>1) {
		total = [[components objectAtIndex:0] doubleValue];
		amount = [[components objectAtIndex:1] doubleValue];
		cell.amountLabel.text = [ObjectiveCScripts convertNumberToMoneyString:total];
		cell.amountLabel.textColor = [ObjectiveCScripts colorBasedOnNumber:total lightFlg:NO];
		[ObjectiveCScripts displayNetChangeLabel:cell.past30DaysLabel amount:amount lightFlg:NO revFlg:(self.topSegmentControl.selectedSegmentIndex==1)];
	}
	
	if(self.displayYear==self.nowYear && self.nowMonth==indexPath.row+1)
		cell.backgroundColor=[UIColor yellowColor];
	else
		cell.backgroundColor=[UIColor whiteColor];

	if(total==0 && amount==0) {
		cell.backgroundColor = [UIColor grayColor];
		cell.monthLabel.text = @"No Data";
		cell.amountLabel.text = @"-";
		cell.past30DaysLabel.text = @"-";
		self.prevYearButton.enabled=NO;
	}


	if(self.displayYear>self.nowYear || (self.displayYear==self.nowYear && self.nowMonth<indexPath.row+1)) {
		cell.monthLabel.textColor = [UIColor grayColor];
		cell.amountLabel.textColor = [UIColor grayColor];
		cell.past30DaysLabel.textColor = [UIColor grayColor];
		cell.backgroundColor=[UIColor colorWithWhite:.8 alpha:1];
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
	self.fieldType = (int)self.topSegmentControl.selectedSegmentIndex;
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
		self.displayTotalFlg=!self.displayTotalFlg;
		[self setupData];
	}
	if(indexPath.section==1 && self.row_id==0) {
		BreakdownSingleMonthVC *detailViewController = [[BreakdownSingleMonthVC alloc] initWithNibName:@"BreakdownSingleMonthVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.displayYear=self.displayYear;
		detailViewController.displayMonth=(int)indexPath.row+1;
		detailViewController.nowYear=self.nowYear;
		detailViewController.nowMonth=self.nowMonth;
		detailViewController.fieldType=self.fieldType;
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
		return [ObjectiveCScripts chartHeightForSize:190];
	else
		return 34;
}


@end

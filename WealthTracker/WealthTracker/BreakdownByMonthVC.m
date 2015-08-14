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
	[self setTitle:@"Breakdown"];
	
	self.topGraphImageView = [[UIImageView alloc] init];
//	NSLog(@"+tag: %d", self.tag);
	
	if(self.itemObject) {
		self.titleLabel.text = self.itemObject.name;
		self.type = [ObjectiveCScripts typeNumberFromTypeString:self.itemObject.type];
		self.row_id = [self.itemObject.rowId intValue];
	} else {
		if(self.tag==4 || self.tag==0)
			self.titleLabel.text = @"Net Worth";
		else if(self.tag==99)
			self.titleLabel.text = @"Interest";
		else if(self.tag==11)
			self.titleLabel.text = @"Debts Paid";
		else if(self.tag==12)
			self.titleLabel.text = @"Assets";
		else
			self.titleLabel.text = [[ObjectiveCScripts typeList] objectAtIndex:self.tag];

	}

	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"YYYY"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	if(self.displayYear==0)
		self.displayYear=self.nowYear;
	self.displayMonth = self.nowMonth;
	
	self.dataArray = [[NSMutableArray alloc] init];

	if(self.tag==3 || self.type==3) {
		self.topSegmentControl.selectedSegmentIndex=1;
		self.topSegmentControl.enabled=NO;
	}
	if(self.tag==4 || self.type==4 || self.tag==99)
		self.topSegmentControl.enabled=NO;
	
	if(self.tag==11) // show debts
		self.topSegmentControl.selectedSegmentIndex=1;

	[ObjectiveCScripts swipeBackRecognizerForTableView:self.mainTableView delegate:self selector:@selector(handleSwipeRight:)];

	[self setupData];
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
	
	[self.dataArray removeAllObjects];
	
	double prevValue=0;
	double prevBalance=0;
	double prevEquity=0;
	double prevInterest=0;
	NSString *year_month = [NSString stringWithFormat:@"%d%02d", self.displayYear-1, 12];
	NSPredicate *predicate=[self predicateForYearMonth:year_month item_id:self.row_id tag:self.tag];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for (NSManagedObject *mo in items) {
		prevValue += [[mo valueForKey:@"asset_value"] doubleValue];
		prevBalance += [[mo valueForKey:@"balance_owed"] doubleValue];
		prevInterest += [[mo valueForKey:@"interest"] doubleValue];
	}
	prevEquity=prevValue-prevBalance;
	if(self.tag==99)
		prevValue=prevInterest;
	
	for(int i=1; i<=12; i++) {
		NSString *year_month = [NSString stringWithFormat:@"%d%02d", self.displayYear, i];
		NSPredicate *predicate=[self predicateForYearMonth:year_month item_id:self.row_id tag:self.tag];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		double value=0;
		double balance=0;
		double interest=0;
		double equity=0;
		for (NSManagedObject *mo in items) {
			value += [[mo valueForKey:@"asset_value"] doubleValue];
			balance += [[mo valueForKey:@"balance_owed"] doubleValue];
			interest += [[mo valueForKey:@"interest"] doubleValue];
		}

		if(self.tag==99)
			value=interest;

		equity=value-balance;
		double last30Value = value-prevValue;
		double last30Balance = balance-prevBalance;
		
		if(self.tag==4) {
			value=equity;
			last30Value=equity-prevEquity;
		}
	
		prevValue = value;
		prevBalance = balance;
		prevEquity = equity;

		[self.dataArray addObject:[NSString stringWithFormat:@"%f|%f|%f|%f|%d", value, last30Value, balance, last30Balance, (int)items.count]];
	}

	
//	NSLog(@"tag: %d, type: %d", self.tag, type);
	
	if(self.tag==0 && self.topSegmentControl.selectedSegmentIndex==0)
		self.graphTitleLabel.text = @"Value Change by Month";
	if(self.tag==0 && self.topSegmentControl.selectedSegmentIndex==1)
		self.graphTitleLabel.text = @"Debt Change by Month";
	if(self.tag==1 && self.topSegmentControl.selectedSegmentIndex==0)
		self.graphTitleLabel.text = @"Home Value Change by Month";
	if(self.tag==1 && self.topSegmentControl.selectedSegmentIndex==1)
		self.graphTitleLabel.text = @"Home Loan Balance Change by Month";
	if(self.tag==2 && self.topSegmentControl.selectedSegmentIndex==0)
		self.graphTitleLabel.text = @"Vehicle Value Change by Month";
	if(self.tag==2 && self.topSegmentControl.selectedSegmentIndex==1)
		self.graphTitleLabel.text = @"Vehicle Loan Balance Change by Month";
	if(self.tag==3)
		self.graphTitleLabel.text = @"Debt Change by Month";
	if(self.tag==4)
		self.graphTitleLabel.text = @"Net Worth Change by Month";
	if(self.tag==99)
		self.graphTitleLabel.text = @"Interest Change by Month";
	
	int type=self.tag;
	
	NSArray *graphArray = [GraphLib barChartValuesLast6MonthsForItem:self.row_id month:self.displayMonth year:self.displayYear reverseColorFlg:(self.topSegmentControl.selectedSegmentIndex==1 || self.tag==99) type:type context:self.managedObjectContext];
	
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
	
	NSArray *components = [[self.dataArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];
	int items = 0;
	if(components.count>4) {
		double amount = 0;
		double past30Amount = 0;
		if(self.topSegmentControl.selectedSegmentIndex==0) {
			amount = [[components objectAtIndex:0] doubleValue];
			past30Amount = [[components objectAtIndex:1] doubleValue];
		} else {
			amount = [[components objectAtIndex:2] doubleValue];
			past30Amount = [[components objectAtIndex:3] doubleValue];
		}
		
		items = [[components objectAtIndex:4] intValue];


		cell.amountLabel.text = [ObjectiveCScripts convertNumberToMoneyString:amount];
		cell.amountLabel.textColor = [ObjectiveCScripts colorBasedOnNumber:amount lightFlg:NO];
		[ObjectiveCScripts displayNetChangeLabel:cell.past30DaysLabel amount:past30Amount lightFlg:NO revFlg:(self.topSegmentControl.selectedSegmentIndex==1)];
	}
	
	if(self.displayYear==self.nowYear && self.nowMonth==indexPath.row+1)
		cell.backgroundColor=[UIColor yellowColor];
	else
		cell.backgroundColor=[UIColor whiteColor];

	if(items==0) {
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
	
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

-(IBAction)prevYearButtonPressed:(id)sender {
	self.displayMonth-=6;
	if(self.displayMonth<1) {
		self.displayMonth+=12;
		self.displayYear--;
	}
	[self setupData];
}
-(IBAction)nextYearButtonPressed:(id)sender {
	self.prevYearButton.enabled=YES;
	self.displayMonth+=6;
	if(self.displayMonth>12) {
		self.displayMonth-=12;
		self.displayYear++;
	}
	[self setupData];
}

-(IBAction)topSegmentChanged:(id)sender {
	[self setupData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==0)
		return 1;
	else
		return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
	else
		return 30;
}


@end

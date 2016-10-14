//
//  StatsVC.m
//  WealthTracker
//
//  Created by Rick Medved on 8/31/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "StatsVC.h"
#import "ChartsVC.h"
#import "MultiLineObj.h"

@interface StatsVC ()

@end

@implementation StatsVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Stats"];
	
	self.categoryItems = [[NSMutableArray alloc] init];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Charts" style:UIBarButtonItemStyleBordered target:self action:@selector(chartsButtonClicked)];
	
	[self.topSegment setTitle:[NSString stringWithFormat:@"%d", [ObjectiveCScripts nowYear]] forSegmentAtIndex:1];
	int percentComplete = [ObjectiveCScripts percentCompleteWithContext:self.managedObjectContext];
	if(percentComplete>=50) {
		self.amountSegment.selectedSegmentIndex=1;
		[self.amountSegment changeSegment];
	}
	
	[self setupData];
}

-(void)setupData {
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	[self.graphObjects removeAllObjects];
	float totalAmount=0;
	float totalPrev=0;
	float totalEquity=0;
	double equity1 = 0;
	double equity2 = 0;
	double equity3 = 0;
	double equity4 = 0;
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		double thisEquity = obj.value-obj.balance;
		totalEquity += thisEquity;
		double amountToday = [ObjectiveCScripts amountForItem:[obj.rowId intValue] month:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear] field:@"asset_value" context:self.managedObjectContext type:0];
		int month = [ObjectiveCScripts nowMonth]-1;
		int year = [ObjectiveCScripts nowYear];
		if(month<1) {
			month = 12;
			year--;
		}
		if(self.topSegment.selectedSegmentIndex==1) {
			month=12;
			year--;
		}
		if(self.topSegment.selectedSegmentIndex==2)
			year--;
		
		double prevAmount = [ObjectiveCScripts amountForItem:[obj.rowId intValue] month:month year:year field:@"asset_value" context:self.managedObjectContext type:0];
		double prevEquity = [ObjectiveCScripts amountForItem:[obj.rowId intValue] month:month year:year field:@"" context:self.managedObjectContext type:0];

		if(self.amountSegment.selectedSegmentIndex==1)
			thisEquity -= prevEquity;
		
		if([@"Real Estate" isEqualToString:obj.type])
			equity1 += thisEquity;
		if([@"Vehicle" isEqualToString:obj.type])
			equity2 += thisEquity;
		if([@"Debt" isEqualToString:obj.type])
			equity3 += thisEquity;
		if([@"Asset" isEqualToString:obj.type])
			equity4 += thisEquity;

		double thisAmount = (self.amountSegment.selectedSegmentIndex==0)?amountToday:amountToday-prevAmount;
		totalAmount+=thisAmount;
		totalPrev+=prevAmount;
		if(amountToday>0) {
			GraphObject *graphObject = [[GraphObject alloc] init];
			graphObject.name=obj.name;
			graphObject.amount=thisAmount;
			graphObject.prevAmount = prevAmount;
			graphObject.rowId = [obj.rowId intValue];
			[self.graphObjects addObject:graphObject];
		}
	}
	[self.categoryItems removeAllObjects];
	[self.categoryItems addObject:[self multiObjWithName:@"Real Estate" amount:equity1]];
	[self.categoryItems addObject:[self multiObjWithName:@"Vehicles" amount:equity2]];
	[self.categoryItems addObject:[self multiObjWithName:@"Loans/Credit Cards" amount:equity3]];
	[self.categoryItems addObject:[self multiObjWithName:@"Investments" amount:equity4]];
	[self.categoryItems addObject:[self multiObjWithName:@"Total" amount:equity1+equity2+equity3+equity4]];
	NSArray *sortedArray = [self.graphObjects sortedArrayUsingSelector:@selector(compare:)];
	self.graphObjects = [NSMutableArray arrayWithArray:sortedArray];
	
	self.totalValueLabel.text = [NSString stringWithFormat:@"Total Value Change: %@", [self stringForChange:totalAmount prevAmount:totalPrev]];
	if(self.amountSegment.selectedSegmentIndex==0)
		self.totalValueLabel.text = [NSString stringWithFormat:@"Value: %@, Equity: %@", [ObjectiveCScripts convertNumberToMoneyString:totalAmount], [ObjectiveCScripts convertNumberToMoneyString:totalEquity]];
	
	self.chartImageView.image = [GraphLib graphBarsWithItems:self.graphObjects];
}

-(MultiLineObj *)multiObjWithName:(NSString *)name amount:(double)amount {
	MultiLineObj *obj = [[MultiLineObj alloc] init];
	obj.name = name;
	obj.value = [ObjectiveCScripts convertNumberToMoneyString:amount];
	if(amount>0 && self.amountSegment.selectedSegmentIndex==1)
		obj.value = [NSString stringWithFormat:@"+%@", [ObjectiveCScripts convertNumberToMoneyString:amount]];

	obj.color = (amount>0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
	if(amount==0)
		obj.color = [UIColor grayColor];
	return obj;
}
	 
	 

-(void)chartsButtonClicked {
	ChartsVC *detailViewController = [[ChartsVC alloc] initWithNibName:@"ChartsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
		if(indexPath.row==0) {
			UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			
			cell.backgroundView = [[UIImageView alloc] initWithImage:self.chartImageView.image];
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		} else if(indexPath.row==1)  {
			MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:self.graphObjects.count labelProportion:.5];
			
			cell.mainTitle = @"Asset";
			cell.alternateTitle = (self.amountSegment.selectedSegmentIndex==0)?@"Total Value":@"Value Change";
			
			NSMutableArray *namesArray = [[NSMutableArray alloc] init];
			NSMutableArray *valuesArray = [[NSMutableArray alloc] init];
			NSMutableArray *colorsArray = [[NSMutableArray alloc] init];
			
			int prevAmount = 0;
			for(GraphObject *obj in self.graphObjects) {
				[namesArray addObject:obj.name];
				NSString *value = (self.amountSegment.selectedSegmentIndex==0)?[self stringForTotal:obj.amount prevAmount:obj.prevAmount]:[self stringForChange:obj.amount prevAmount:obj.prevAmount];
				[valuesArray addObject:value];
				UIColor *color = (obj.amount>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
				if(obj.amount==0 && self.topSegment.selectedSegmentIndex==0)
					color = [UIColor grayColor];
				[colorsArray addObject:color];
				prevAmount = (int)obj.amount;
			}
			
			cell.titleTextArray = namesArray;
			cell.fieldTextArray = valuesArray;
			cell.fieldColorArray = colorsArray;
			
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		} else {
			MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:self.categoryItems.count labelProportion:.5];
			
			cell.mainTitle = @"Category";
			cell.alternateTitle = (self.amountSegment.selectedSegmentIndex==0)?@"Total Equity":@"Equity Change";
			
			NSMutableArray *namesArray = [[NSMutableArray alloc] init];
			NSMutableArray *valuesArray = [[NSMutableArray alloc] init];
			NSMutableArray *colorsArray = [[NSMutableArray alloc] init];
			
			for(MultiLineObj *obj in self.categoryItems) {
				[namesArray addObject:obj.name];
				[valuesArray addObject:obj.value];
				[colorsArray addObject:obj.color];
			}
			
			cell.titleTextArray = namesArray;
			cell.fieldTextArray = valuesArray;
			cell.fieldColorArray = colorsArray;
			
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
}

-(NSString *)stringForTotal:(float)amount prevAmount:(float)prevAmount {
	NSString *value = [ObjectiveCScripts convertNumberToMoneyString:amount];
	float changeAmount = amount-prevAmount;
	NSString *sign = changeAmount>=0?@"+":@"";
	NSString *percent = @"-";
	if (prevAmount>0) {
		int percentAmount = (changeAmount*100)/prevAmount;
		percent = [NSString stringWithFormat:@"%@%d%%", sign, percentAmount];
	}
	value = [NSString stringWithFormat:@"%@ (%@)", value, percent];
	return value;
}

-(NSString *)stringForChange:(float)amount prevAmount:(float)prevAmount {
	NSString *value = [ObjectiveCScripts convertNumberToMoneyString:amount];
	NSString *sign = amount>=0?@"+":@"";
	NSString *percent = @"-";
	if (prevAmount>0) {
		int percentAmount = (amount*100)/prevAmount;
		percent = [NSString stringWithFormat:@"%@%d%%", sign, percentAmount];
	}
	value = [NSString stringWithFormat:@"%@%@ (%@)", sign, value, percent];
	return value;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row==0)
		return 150;
	else if(indexPath.row==1)
		return 18*self.graphObjects.count+20;
	else
		return 18*self.categoryItems.count+20;
}

-(IBAction)topSegmentChanged:(id)sender {
	[self.topSegment changeSegment];
	if(self.topSegment.selectedSegmentIndex>0) {
		self.amountSegment.selectedSegmentIndex=1;
		[self.amountSegment changeSegment];
	}
	[self setupData];
	[self.mainTableView reloadData];
}

-(IBAction)amountSegmentChanged:(id)sender {
	[self.amountSegment changeSegment];
	if(self.amountSegment.selectedSegmentIndex==0) {
		self.topSegment.selectedSegmentIndex=0;
		[self.topSegment changeSegment];
	}
	[self setupData];
	[self.mainTableView reloadData];
}




@end

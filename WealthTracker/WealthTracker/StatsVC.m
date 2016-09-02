//
//  StatsVC.m
//  WealthTracker
//
//  Created by Rick Medved on 8/31/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "StatsVC.h"
#import "ChartsVC.h"

@interface StatsVC ()

@end

@implementation StatsVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Stats"];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Charts" style:UIBarButtonItemStyleBordered target:self action:@selector(chartsButtonClicked)];
	
	[self.topSegment setTitle:[NSString stringWithFormat:@"%d", [ObjectiveCScripts nowYear]] forSegmentAtIndex:1];
	
	[self setupData];
}

-(void)setupData {
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	[self.graphObjects removeAllObjects];
	float totalAmount=0;
	float totalPrev=0;
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
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
		totalAmount+=amountToday-prevAmount;
		totalPrev+=prevAmount;
		if(amountToday != prevAmount) {
			GraphObject *graphObject = [[GraphObject alloc] init];
			graphObject.name=obj.name;
			graphObject.amount=amountToday-prevAmount;
			graphObject.prevAmount = prevAmount;
			graphObject.rowId = [obj.rowId intValue];
			[self.graphObjects addObject:graphObject];
		}
	}
	self.totalValueLabel.text = [NSString stringWithFormat:@"Total Value Change: %@", [self stringForChange:totalAmount prevAmount:totalPrev]];
	self.chartImageView.image = [GraphLib graphBarsWithItems:self.graphObjects];
}

-(void)chartsButtonClicked {
	ChartsVC *detailViewController = [[ChartsVC alloc] initWithNibName:@"ChartsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
		if(indexPath.row==0) {
			UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			
			cell.backgroundView = [[UIImageView alloc] initWithImage:self.chartImageView.image];
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		} else {
			MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:self.graphObjects.count labelProportion:.5];
			
			cell.mainTitle = @"Asset";
			cell.alternateTitle = @"Value Change";
			
			NSMutableArray *namesArray = [[NSMutableArray alloc] init];
			NSMutableArray *valuesArray = [[NSMutableArray alloc] init];
			NSMutableArray *colorsArray = [[NSMutableArray alloc] init];
			
			int prevAmount = 0;
			for(GraphObject *obj in self.graphObjects) {
				[namesArray addObject:obj.name];
				[valuesArray addObject:[self stringForChange:obj.amount prevAmount:obj.prevAmount]];
				UIColor *color = (obj.amount>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
				[colorsArray addObject:color];
				prevAmount = (int)obj.amount;
			}
			
			cell.titleTextArray = namesArray;
			cell.fieldTextArray = valuesArray;
			cell.fieldColorArray = colorsArray;
			
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
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
	else
		return 18*self.graphObjects.count+20;
}

-(IBAction)topSegmentChanged:(id)sender {
	[self.topSegment changeSegment];
	[self setupData];
	[self.mainTableView reloadData];
}




@end

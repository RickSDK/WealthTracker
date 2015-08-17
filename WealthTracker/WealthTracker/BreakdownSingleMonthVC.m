//
//  BreakdownSingleMonthVC.m
//  WealthTracker
//
//  Created by Rick Medved on 8/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "BreakdownSingleMonthVC.h"
#import "ObjectiveCScripts.h"
#import "MultiLineDetailCellWordWrap.h"
#import "CoreDataLib.h"
#import "GraphLib.h"
#import "GraphObject.h"

@interface BreakdownSingleMonthVC ()

@end

@implementation BreakdownSingleMonthVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.fieldNamesArray = [[NSMutableArray alloc] init];
	self.fieldValuesArray = [[NSMutableArray alloc] init];
	self.fieldColorsArray = [[NSMutableArray alloc] init];
	self.dataArray = [[NSMutableArray alloc] init];
	
	NSLog(@"+++type: %d, fieldType: %d", self.type, self.fieldType);
	[self setTitle:[NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear]];
	self.typeLabel.text = [ObjectiveCScripts typeLabelForType:self.type fieldType:self.fieldType];
	self.fieldTypeLabel.text = [ObjectiveCScripts fieldTypeNameForFieldType:self.fieldType];
	
	[self setupData];
}

-(void)setupData {
	[self.fieldNamesArray removeAllObjects];
	[self.fieldValuesArray removeAllObjects];
	[self.fieldColorsArray removeAllObjects];
	[self.dataArray removeAllObjects];
	
	NSArray *fieldTypes = [NSArray arrayWithObjects:@"asset_value", @"balance_owed", @"", @"interest", nil];
	NSString *field = [fieldTypes objectAtIndex:self.fieldType];
	
	NSPredicate *predicate=nil;
	if(self.type>0)
		predicate = [NSPredicate predicateWithFormat:@"type = %@", [ObjectiveCScripts typeNameForType:self.type]];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:@"name" mOC:self.managedObjectContext ascendingFlg:YES];
	double total=0;
	for(NSManagedObject *mo in items) {
		int rowId = [[mo valueForKey:@"rowId"] intValue];
		double amount = 0;
		if(self.topSegmentControl.selectedSegmentIndex==0)
			amount = [ObjectiveCScripts changedForItem:rowId month:self.displayMonth year:self.displayYear field:field context:self.managedObjectContext numMonths:1];
		else
			amount = [ObjectiveCScripts amountForItem:rowId month:self.displayMonth year:self.displayYear field:field context:self.managedObjectContext type:self.type];
		
		if(amount!=0) {
			[self.fieldNamesArray addObject:[mo valueForKey:@"name"]];
			[self.fieldValuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:amount]];
			[self.fieldColorsArray addObject:[ObjectiveCScripts colorBasedOnNumber:amount lightFlg:NO]];
			
			GraphObject *graphObject = [[GraphObject alloc] init];
			graphObject.name = [mo valueForKey:@"name"];
			graphObject.amount=amount;
			graphObject.rowId=rowId;
			[self.dataArray addObject:graphObject];
			total+=amount;
		}
	}
	[self.fieldNamesArray addObject:@"Total"];
	[self.fieldValuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:total]];
	[self.fieldColorsArray addObject:[ObjectiveCScripts colorBasedOnNumber:total lightFlg:NO]];


	
	[self.mainTableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	if(indexPath.row==0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		if(self.pieChartFlg)
			cell.backgroundView = [[UIImageView alloc] initWithImage:[GraphLib pieChartWithItems:self.dataArray]];
		else
			cell.backgroundView = [[UIImageView alloc] initWithImage:[GraphLib graphBarsWithItems:self.dataArray]];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:self.fieldValuesArray.count labelProportion:0.5];
		
		cell.mainTitle = [ObjectiveCScripts typeLabelForType:self.type fieldType:self.fieldType];
		cell.alternateTitle = [ObjectiveCScripts fieldTypeNameForFieldType:self.fieldType];
		
		cell.titleTextArray = self.fieldNamesArray;
		cell.fieldTextArray = self.fieldValuesArray;
		cell.fieldColorArray = self.fieldColorsArray;
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row==0) {
		self.pieChartFlg=!self.pieChartFlg;
		[self setupData];
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row==0)
		return [ObjectiveCScripts chartHeightForSize:170];
	else
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:self.fieldValuesArray
																   tableView:self.mainTableView
														labelWidthProportion:0.6]+20;
}

-(IBAction)topSegmentChanged:(id)sender {
	[self setupData];
}

@end

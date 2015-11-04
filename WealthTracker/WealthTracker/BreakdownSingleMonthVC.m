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
	
	self.nowYear = [ObjectiveCScripts nowYear];
	self.nowMonth = [ObjectiveCScripts nowMonth];
	[self setTitle:@"By Month"];
	[self setupData];
}

-(void)setupData {
	[self.fieldNamesArray removeAllObjects];
	[self.fieldValuesArray removeAllObjects];
	[self.fieldColorsArray removeAllObjects];
	[self.dataArray removeAllObjects];
	
	self.nextButton.enabled = (self.displayYear<self.nowYear || self.displayMonth < self.nowMonth);
	self.monthLabel.text = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
	self.typeLabel.text = [ObjectiveCScripts typeLabelForType:self.type fieldType:self.fieldType];
	self.fieldTypeLabel.text = [ObjectiveCScripts fieldTypeNameForFieldType:self.fieldType];

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
			amount = [ObjectiveCScripts changedForItem:rowId month:self.displayMonth year:self.displayYear field:field context:self.managedObjectContext numMonths:1 type:0];
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

	if(self.chartSegmentControl.selectedSegmentIndex==0)
		self.graphImageView.image = [GraphLib graphBarsWithItems:self.dataArray];
	else
		self.graphImageView.image = [GraphLib pieChartWithItems:self.dataArray startDegree:self.startDegree];
	
	[self.mainTableView reloadData];
}

-(IBAction)prevButtonClicked:(id)sender {
	self.displayMonth--;
	if(self.displayMonth<1) {
		self.displayMonth=12;
		self.displayYear--;
	}
	[self setupData];
}
-(IBAction)nextButtonClicked:(id)sender {
	self.displayMonth++;
	if(self.displayMonth>12) {
		self.displayMonth=1;
		self.displayYear++;
	}
	[self setupData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:self.fieldValuesArray
																   tableView:self.mainTableView
														labelWidthProportion:0.6]+20;
}

-(IBAction)topSegmentChanged:(id)sender {
	[self setupData];
}

-(IBAction)segmentClicked:(id)sender {
	[self setupData];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	self.startTouchPosition = [touch locationInView:self.view];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint newTouchPosition = [touch locationInView:self.view];
	
	if(self.chartSegmentControl.selectedSegmentIndex==1) {
		self.startDegree = [GraphLib spinPieChart:self.graphImageView startTouchPosition:self.startTouchPosition newTouchPosition:newTouchPosition startDegree:self.startDegree barGraphObjects:self.dataArray];
		self.startTouchPosition=newTouchPosition;
	}
}

@end

//
//  ChartsVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "ChartsVC.h"
#import "NSDate+ATTDate.h"
#import "ObjectiveCScripts.h"
#import "GraphCell.h"
#import "GraphLib.h"
#import "BreakdownByMonthVC.h"
#import "GraphSegmentCell.h"


@interface ChartsVC ()

@end

@implementation ChartsVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Charts"];
	
	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"YYYY"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	
	self.graphTitles = [NSArray arrayWithObjects:@"Assets", @"Real Estate", @"Vehicles", @"Interest", @"Debt", nil];
	
	self.graphDates = [[NSMutableArray alloc] init];
	self.graphSegmentIndexes = [[NSMutableArray alloc] init];
	for(int i=0; i<self.graphTitles.count; i++) {
		[self.graphDates addObject:[NSString stringWithFormat:@"%d|%d", self.nowYear, self.nowMonth]];
		[self.graphSegmentIndexes addObject:@"0"];
	}

	UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																					 action:@selector(handleSwipeLeft:)];
	[recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
	[self.mainTableView addGestureRecognizer:recognizer];
	
	[ObjectiveCScripts swipeBackRecognizerForTableView:self.mainTableView delegate:self selector:@selector(handleSwipeRight:)];


}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)infoButtonPressed {
	[ObjectiveCScripts showAlertPopup:@"Swipe left for month by month breakdown" message:@""];
}


-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
	CGPoint location = [gestureRecognizer locationInView:self.mainTableView];
	//Get the corresponding index path within the table view
	NSIndexPath *indexPath = [self.mainTableView indexPathForRowAtPoint:location];
	int type=(int)indexPath.section;
	int fieldType=0;
	if(type==3) {
		type=0;
		fieldType=3;
	}
	if(type==4) {
		type=0;
		fieldType=1;
	}
	
	NSArray *dates = [[self.graphDates objectAtIndex:indexPath.section] componentsSeparatedByString:@"|"];
	int displayYear = [[dates objectAtIndex:0] intValue];
	BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.type=type;
	detailViewController.fieldType=fieldType;
	detailViewController.displayYear=displayYear;
	if(indexPath.section==3)
		detailViewController.tag = 99; // interest
	else if(indexPath.section==4)
		detailViewController.tag=3; // debt
	else
		detailViewController.tag = (int)indexPath.section;
	
	[self.navigationController pushViewController:detailViewController animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	NSArray *dates = [[self.graphDates objectAtIndex:indexPath.section] componentsSeparatedByString:@"|"];
	int displayYear = [[dates objectAtIndex:0] intValue];
	int displayMonth = [[dates objectAtIndex:1] intValue];
	
	GraphSegmentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[GraphSegmentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

	int segment = [[self.graphSegmentIndexes objectAtIndex:indexPath.section] intValue];

	cell.titleLabel.text = [self.graphTitles objectAtIndex:indexPath.section];
	
	[cell.prevYearButton addTarget:self action:@selector(prevMonthButtonPressed:) forControlEvents:UIControlEventTouchDown];
	[cell.nextYearButton addTarget:self action:@selector(nextMonthButtonPressed:) forControlEvents:UIControlEventTouchDown];
	
	cell.lineButton.tag=indexPath.section;
	cell.barButton.tag=indexPath.section;
	cell.pieButton.tag=indexPath.section;
	[cell.lineButton addTarget:self action:@selector(lineButtonPressed:) forControlEvents:UIControlEventTouchDown];
	[cell.barButton addTarget:self action:@selector(barButtonPressed:) forControlEvents:UIControlEventTouchDown];
	[cell.pieButton addTarget:self action:@selector(pieButtonPressed:) forControlEvents:UIControlEventTouchDown];
	cell.lineButton.enabled=!(segment==0);
	cell.barButton.enabled=!(segment==1);
	cell.pieButton.enabled=!(segment==2);
	
	cell.prevYearButton.tag = indexPath.section;
	cell.nextYearButton.tag = indexPath.section;
	cell.currentYearLabel.text = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:displayMonth-1], displayYear];
	
	int graphType = (int)indexPath.section;
	if(graphType==3)
		graphType=99; // interest
	if(graphType==4)
		graphType=0; // debt
	
	NSMutableArray *chartValuesArray = [[NSMutableArray alloc] init];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"rowId" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *item in items) {
		NSString *name = [item valueForKey:@"name"];
		int rowId = [[item valueForKey:@"rowId"] intValue];
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d AND month = %d AND item_id = %d", displayYear, displayMonth, rowId];
		NSArray *values = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		if(values.count==0)
			cell.prevYearButton.enabled=NO;
		else
			cell.prevYearButton.enabled=YES;
		
		double amount=0;
		if(values.count>0) {
			NSManagedObject *mo = [values objectAtIndex:0];
			
			if(indexPath.section==0) //assets
				amount = [[mo valueForKey:@"asset_value"] doubleValue];
			if(indexPath.section==1 && [@"Real Estate" isEqualToString:[item valueForKey:@"type"]]) //real estate
				amount = [[mo valueForKey:@"asset_value"] doubleValue];
			if(indexPath.section==2 && [@"Vehicle" isEqualToString:[item valueForKey:@"type"]]) //real estate
				amount = [[mo valueForKey:@"asset_value"] doubleValue];
			
			if(indexPath.section==3)
				amount = [[mo valueForKey:@"interest"] doubleValue];
			if(indexPath.section==4)
				amount = [[mo valueForKey:@"balance_owed"] doubleValue];
			
			if(amount>0)
				[chartValuesArray addObject:[GraphLib graphObjectWithName:name amount:amount rowId:rowId reverseColorFlg:(indexPath.section==4)]];
		}
	}
	
	if(segment==0)
		cell.graphImageView.image = [GraphLib plotItemChart:self.managedObjectContext type:graphType year:displayYear item_id:0 displayMonth:displayMonth];
	if(segment==1)
		cell.graphImageView.image =[GraphLib graphBarsWithItems:chartValuesArray];
	if(segment==2)
		cell.graphImageView.image =[GraphLib pieChartWithItems:chartValuesArray];
	
	if(displayYear==self.nowYear && displayMonth==self.nowMonth)
		cell.nextYearButton.enabled=NO;
	else
		cell.nextYearButton.enabled=YES;
	
	cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
	
	
}

-(void)lineButtonPressed:(id)sender {
	UIButton *button=sender;
	[self.graphSegmentIndexes replaceObjectAtIndex:button.tag withObject:@"0"];
	[self.mainTableView reloadData];
}

-(void)barButtonPressed:(id)sender {
	UIButton *button=sender;
	[self.graphSegmentIndexes replaceObjectAtIndex:button.tag withObject:@"1"];
	[self.mainTableView reloadData];
}

-(void)pieButtonPressed:(id)sender {
	UIButton *button=sender;
	[self.graphSegmentIndexes replaceObjectAtIndex:button.tag withObject:@"2"];
	[self.mainTableView reloadData];
}

-(void)prevMonthButtonPressed:(id)sender {
	UIButton *button=sender;
	NSArray *dates = [[self.graphDates objectAtIndex:button.tag] componentsSeparatedByString:@"|"];
	int displayYear = [[dates objectAtIndex:0] intValue];
	int displayMonth = [[dates objectAtIndex:1] intValue];
	displayMonth--;
	if(displayMonth<1) {
		displayMonth=12;
		displayYear--;
	}
	[self.graphDates replaceObjectAtIndex:button.tag withObject:[NSString stringWithFormat:@"%d|%d", displayYear, displayMonth]];
	[self.mainTableView reloadData];
}

-(void)nextMonthButtonPressed:(id)sender {
	UIButton *button=sender;
	NSArray *dates = [[self.graphDates objectAtIndex:button.tag] componentsSeparatedByString:@"|"];
	int displayYear = [[dates objectAtIndex:0] intValue];
	int displayMonth = [[dates objectAtIndex:1] intValue];
	displayMonth++;
	if(displayMonth>12) {
		displayMonth=1;
		displayYear++;
	}
	[self.graphDates replaceObjectAtIndex:button.tag withObject:[NSString stringWithFormat:@"%d|%d", displayYear, displayMonth]];
	[self.mainTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int type=(int)indexPath.section;
	int fieldType=0;
	if(type==3) {
		type=0;
		fieldType=3;
	}
	if(type==4) {
		type=0;
		fieldType=1;
	}
	
	NSArray *dates = [[self.graphDates objectAtIndex:indexPath.section] componentsSeparatedByString:@"|"];
	int displayYear = [[dates objectAtIndex:0] intValue];
	BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.type=type;
	detailViewController.fieldType=fieldType;
	detailViewController.displayYear=displayYear;
	if(indexPath.section==3)
		detailViewController.tag = 99; // interest
	else if(indexPath.section==4)
		detailViewController.tag=3; // debt
	else
		detailViewController.tag = (int)indexPath.section;
	
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 1;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [ObjectiveCScripts chartHeightForSize:290];
}

@end

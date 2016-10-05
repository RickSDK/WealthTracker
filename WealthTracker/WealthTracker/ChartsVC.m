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
#import "GraphSegmentCell.h"
#import "ChartViewVC.h"


@interface ChartsVC ()

@end

@implementation ChartsVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Charts"];

	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	
	self.graphDates = [[NSMutableArray alloc] init];
	self.graphSegmentIndexes = [[NSMutableArray alloc] init];
	for(int i=0; i<6; i++) {
		[self.graphDates addObject:[NSString stringWithFormat:@"%d|%d", self.nowYear, self.nowMonth]];
		[self.graphSegmentIndexes addObject:@"0"];
	}

	UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																					 action:@selector(handleSwipeLeft:)];
	[recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
	[self.mainTableView addGestureRecognizer:recognizer];
	
	[ObjectiveCScripts swipeBackRecognizerForTableView:self.mainTableView delegate:self selector:@selector(handleSwipeRight:)];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(mainMenuClicked)];


}

-(void)mainMenuClicked {
	[self.navigationController popToRootViewControllerAnimated:YES];
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
	[self drilldown:(int)indexPath.section];
}

-(void)drilldown:(int)section {
	NSArray *dates = [[self.graphDates objectAtIndex:section] componentsSeparatedByString:@"|"];
	int displayYear = [[dates objectAtIndex:0] intValue];
	ChartViewVC *detailViewController = [[ChartViewVC alloc] initWithNibName:@"ChartViewVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.type=section;
	detailViewController.fieldType=section;
	detailViewController.displayYear=displayYear;
	detailViewController.tag = section;
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

	cell.titleLabel.text = [ObjectiveCScripts titleForType:(int)indexPath.section];
	
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
	if(graphType==4)
		graphType=0; // debt
	
	
	NSArray *chartValuesArray = [GraphLib itemsForMonth:displayMonth year:displayYear type:(int)indexPath.section context:self.managedObjectContext];
	cell.prevYearButton.enabled=chartValuesArray.count>0;

	if(segment==0)
		cell.graphImageView.image = [GraphLib graphChartForMonth:displayMonth year:displayYear context:self.managedObjectContext numYears:(int)self.timeSegment.selectedSegmentIndex+1 type:(int)indexPath.section barsFlg:self.typeSegment.selectedSegmentIndex==1 asset_type:99 amount_type:99];
	if(segment==1)
		cell.graphImageView.image =[GraphLib graphBarsWithItems:chartValuesArray];
	if(segment==2)
		cell.graphImageView.image =[GraphLib pieChartWithItems:chartValuesArray startDegree:0];
	
	
	
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
	return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self drilldown:(int)indexPath.section];
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

-(IBAction)timeSegmentChanged:(id)sender {
	[self.timeSegment changeSegment];
	if(self.timeSegment.selectedSegmentIndex>0 && self.typeSegment.selectedSegmentIndex==1) {
		self.typeSegment.selectedSegmentIndex=0;
		[self.typeSegment changeSegment];
	}
	[self.mainTableView reloadData];
	
}

-(IBAction)typeSegmentChanged:(id)sender {
	[self.typeSegment changeSegment];
	if(self.typeSegment.selectedSegmentIndex>0 && self.timeSegment.selectedSegmentIndex>0) {
		self.timeSegment.selectedSegmentIndex=0;
		[self.timeSegment changeSegment];
	}
	[self.mainTableView reloadData];
}

@end

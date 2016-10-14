//
//  ChartViewVC.m
//  WealthTracker
//
//  Created by Rick Medved on 12/1/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "ChartViewVC.h"
#import "BreakdownByMonthVC.h"
#import "NSDate+ATTDate.h"
#import "ObjectiveCScripts.h"
#import "GraphCell.h"
#import "GraphLib.h"
#import "GraphSegmentCell.h"
#import "ChartViewVC.h"

@interface ChartViewVC ()

@end

@implementation ChartViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Charts"];
	
	self.chartValuesArray = [[NSMutableArray alloc] init];

	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	self.displayYear = self.nowYear;
	self.displayMonth = self.nowMonth;
	self.startYear = self.nowYear;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Breakdown" style:UIBarButtonItemStyleBordered target:self action:@selector(breakdownButtonPressed)];

	NSLog(@"tag: %d", self.tag);
	self.changeSegmentControl.selectedSegmentIndex=1;

	if(self.tag==3) {
		self.topSegmentControl.selectedSegmentIndex=1;
//		self.tag=0;
	}
	
	if(self.tag==2)
		self.topSegmentControl.selectedSegmentIndex=1;
	if(self.tag==4)
		self.topSegmentControl.selectedSegmentIndex=2; // net worth
	if(self.tag==5)
		self.topSegmentControl.selectedSegmentIndex=2; // interest
	
	if(self.tag==0 || self.tag==3 || self.tag==4) {
		[self.topSegmentControl setTitle:@"Assets" forSegmentAtIndex:0];
		[self.topSegmentControl setTitle:@"Debts" forSegmentAtIndex:1];
		[self.topSegmentControl setTitle:@"Net Worth" forSegmentAtIndex:2];
		self.screen=1;
	} else {
		[self.topSegmentControl setTitle:@"Real Estate" forSegmentAtIndex:0];
		[self.topSegmentControl setTitle:@"Vehicles" forSegmentAtIndex:1];
		[self.topSegmentControl setTitle:@"Interest" forSegmentAtIndex:2];
		self.screen=2;
	}
	
	[self setupData];
}

-(void)setupData {
	[self.chartValuesArray removeAllObjects];
	
	self.graphTitleLabel.text = self.itemObject?self.itemObject.name:[ObjectiveCScripts typeLabelForType:self.type fieldType:self.fieldType];

	[self.topSegmentControl changeSegment];
	
	NSArray *chartValuesArray = [GraphLib itemsForMonth:self.displayMonth year:self.displayYear type:(int)self.tag context:self.managedObjectContext];
	[self.chartValuesArray addObjectsFromArray:chartValuesArray];
	NSLog(@"+++count: %d", (int)self.chartValuesArray.count);

	if(self.changeSegmentControl.selectedSegmentIndex==1)
		self.graphImageView.image = [GraphLib plotItemChart:self.managedObjectContext type:self.tag displayYear:self.displayYear item_id:0 displayMonth:self.displayMonth startMonth:self.nowMonth startYear:self.startYear numYears:1];
	if(self.changeSegmentControl.selectedSegmentIndex==0)
		self.graphImageView.image =[GraphLib graphBarsWithItems:self.chartValuesArray];
	if(self.changeSegmentControl.selectedSegmentIndex==2)
		self.graphImageView.image =[GraphLib pieChartWithItems:self.chartValuesArray startDegree:self.startDegree];
	
	self.nextYearButton.enabled = self.displayYear<self.nowYear;
	
	self.titleLabel.text = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
}

-(void)breakdownButtonPressed {
	BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.type=self.type;
//	detailViewController.fieldType=self.fieldType;
	detailViewController.displayYear=self.displayYear;
	detailViewController.tag = self.tag;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)changeSegmentChanged:(id)sender {
	[self.changeSegmentControl changeSegment];
	[self setupData];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	self.startTouchPosition = [touch locationInView:self.view];
	if(CGRectContainsPoint(self.graphImageView.frame, self.startTouchPosition) && self.changeSegmentControl.selectedSegmentIndex<2)
		[self drawChartAtPoint:self.startTouchPosition];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint newTouchPosition = [touch locationInView:self.view];
	if(CGRectContainsPoint(self.graphImageView.frame, newTouchPosition)) {

	if(self.changeSegmentControl.selectedSegmentIndex==2) {
		
		self.startDegree = [GraphLib spinPieChart:self.graphImageView startTouchPosition:self.startTouchPosition newTouchPosition:newTouchPosition startDegree:self.startDegree barGraphObjects:self.chartValuesArray];
		self.startTouchPosition=newTouchPosition;
	} else
		[self drawChartAtPoint:newTouchPosition];
	}
	
}

-(void)drawChartAtPoint:(CGPoint)point {
	int month = [GraphLib getMonthFromView:self.graphImageView point:point startingMonth:self.nowMonth];
	if(month != self.displayMonth) {
		self.displayMonth=month;
		self.displayYear=(self.displayMonth>self.nowMonth)?self.nowYear-1:self.nowYear;
		
		[self setupData];
	}
}

-(IBAction)topSegmentChanged:(id)sender {
	if(self.screen==1) {
		switch (self.topSegmentControl.selectedSegmentIndex) {
			case 0: // assets
				self.type=0;
				self.fieldType=0;
				self.tag=0;
    break;
			case 1: // debts
				self.type=0;
				self.fieldType=1;
				self.tag=0;
    break;
			case 2: // networth
				self.type=0;
				self.fieldType=2;
				self.tag=0;
    break;
				
			default:
    break;
		}
	} else {
		switch (self.topSegmentControl.selectedSegmentIndex) {
			case 0:
				self.type=1;
				self.fieldType=0;
				self.tag=1;
    break;
			case 1:
				self.type=2;
				self.fieldType=0;
				self.tag=2;
    break;
			case 2:
				self.type=5;
				self.fieldType=5;
				self.tag=5;
    break;
				
			default:
    break;
		}
	}
	[self setupData];
}



-(IBAction)prevYearButtonPressed:(id)sender {
	int leftMOnth = self.nowMonth+1;
	if(leftMOnth>12)
		leftMOnth=1;
	if(self.displayMonth != leftMOnth) {
		if(leftMOnth>self.displayMonth)
			self.displayYear--;
		self.displayMonth=leftMOnth;
	} else {
		self.displayYear--;
		self.startYear--;
	}
	[self setupData];
	
}
-(IBAction)nextYearButtonPressed:(id)sender {
	if(self.displayMonth != self.nowMonth) {
		if(self.nowMonth<self.displayMonth)
			self.displayYear++;
		self.displayMonth=self.nowMonth;
	} else {
		self.displayYear++;
		self.startYear++;
	}
	[self setupData];
	
}


@end

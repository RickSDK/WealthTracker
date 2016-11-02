//
//  TemplateVC.m
//  WealthTracker
//
//  Created by Rick Medved on 3/9/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"
#import "NSDate+ATTDate.h"

@interface TemplateVC ()

@end

@implementation TemplateVC

-(float)screenWidth {
	return [[UIScreen mainScreen] bounds].size.width;
}

-(float)screenHeight {
	return [[UIScreen mainScreen] bounds].size.height;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.itemsArray = [[NSMutableArray alloc] init];
	self.chartImageView = [[UIImageView alloc] init];
	self.graphObjects = [[NSMutableArray alloc] init];
	self.analysisStr = [[NSString alloc] init];
	self.titleStr = [[NSString alloc] init];
	self.altStr = [[NSString alloc] init];
	
	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];

	
	self.monthLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:17.f];
	self.monthLabel.textColor = [UIColor whiteColor];
	NSString *dateStr = [[NSDate date] convertDateToStringWithFormat:@"MMMM YYYY"];
	self.monthLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FACalendar], dateStr];
	self.monthLabel.backgroundColor = [ObjectiveCScripts mediumkColor];

	[ObjectiveCScripts swipeBackRecognizerForTableView:self.mainTableView delegate:self selector:@selector(handleSwipeRight:)];

	self.popupView.hidden=YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}



-(IBAction)popupButtonClicked:(id)sender {
	self.popupView.hidden=NO;
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	if(self.topSegment.selectedSegmentIndex==0) {
		return [self listCellForIndexPath:indexPath];
	}
	if(self.topSegment.selectedSegmentIndex==1) {
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:1 labelProportion:0];
		
		cell.mainTitle = self.titleStr;
		cell.alternateTitle = self.altStr;
		
		
		cell.titleTextArray = [NSArray arrayWithObject:@""];
		cell.fieldTextArray = [NSArray arrayWithObject:self.analysisStr];;
		cell.fieldColorArray = [NSArray arrayWithObject:[UIColor blackColor]];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else {
		if(indexPath.row==0) {
			UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			
			cell.backgroundView = [[UIImageView alloc] initWithImage:self.chartImageView.image];
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		} else {
			MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:12 labelProportion:.5];
			
			cell.mainTitle = self.titleStr;
			cell.alternateTitle = self.altStr;
			
			NSMutableArray *namesArray = [[NSMutableArray alloc] init];
			NSMutableArray *valuesArray = [[NSMutableArray alloc] init];
			NSMutableArray *colorsArray = [[NSMutableArray alloc] init];
			
			int prevAmount = 0;
			for(GraphObject *obj in self.graphObjects) {
				[namesArray addObject:obj.name];
				NSString *value = [ObjectiveCScripts convertNumberToMoneyString:obj.amount];
				NSString *sign = obj.amount-prevAmount>=0?@"+":@"";
				if(prevAmount>0)
					value = [NSString stringWithFormat:@"%@ (%@%@)", value, sign, [ObjectiveCScripts convertNumberToMoneyString:obj.amount-prevAmount]];
				[valuesArray addObject:value];
				UIColor *color = (obj.amount-prevAmount>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
				[colorsArray addObject:color];
				NSLog(@"%@ %d %d", obj.name, (int)obj.amount, prevAmount);
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
}

- (UITableViewCell *)listCellForIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	cell.textLabel.text=@"test";
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(self.topSegment.selectedSegmentIndex==0)
		return self.itemsArray.count;
	if(self.topSegment.selectedSegmentIndex==1)
		return 1;
	else
		return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.topSegment.selectedSegmentIndex==1)
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:[NSArray arrayWithObject:self.analysisStr]
																   tableView:self.mainTableView
														labelWidthProportion:0]+20;
	if(self.topSegment.selectedSegmentIndex==2 && indexPath.row==0)
		return 200;
	if(self.topSegment.selectedSegmentIndex==2 && indexPath.row==1)
		return 18*12+20;
	
	return [self heightForSection0RowAtIndexPath:indexPath];
}

-(float)heightForSection0RowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

-(IBAction)xButtonClicked:(id)sender {
	self.popupView.hidden=YES;
	[self.nameTextField resignFirstResponder];
	[self.amountTextField resignFirstResponder];
	[self.dueDayTextField resignFirstResponder];
}

-(IBAction)topSegmentChanged:(id)sender {
	[self.topSegment changeSegment];
	[self.mainTableView reloadData];
}

-(NSString *)budgetAnalysis:(NSString *)name budget:(int)budget spent:(int)spent {
	if(budget<=0)
		return 	@"You have not yet set up your monthly budget. Click 'Edit' on the main screen.";
	
	if(spent<=0)
		return 	[NSString stringWithFormat:@"Your %@ budget for this month is %@ and you haven't spent any money yet.\n\nEach time you spend money, use this app to log it in the appropriate category. This will help you manage your money and know where every dollar is going.\n\nRemember to adjust your budgets each month to match your current spending needs.",  name, [ObjectiveCScripts convertNumberToMoneyString:budget]];
	
	int percent = spent*100/budget;
	int relativePercent = percent * 30/ [ObjectiveCScripts nowDay];
	int projectedAmount = spent *30/[ObjectiveCScripts nowDay];
	
	NSString *para1 = [NSString stringWithFormat:@"Your %@ budget for this month is %@ and so far you have spent %@.", name, [ObjectiveCScripts convertNumberToMoneyString:budget], [ObjectiveCScripts convertNumberToMoneyString:spent]];
	
	if(relativePercent<80)
		return [NSString stringWithFormat:@"%@ You are currently under budget and on pace to spend %@ this month.", para1, [ObjectiveCScripts convertNumberToMoneyString:projectedAmount]];
	
	if(relativePercent<120)
		return [NSString stringWithFormat:@"%@ You are currently on pace to spend about %@.", para1, [ObjectiveCScripts convertNumberToMoneyString:projectedAmount]];
	
	return [NSString stringWithFormat:@"%@ You are currently WAY over budget and on pace to spend %@ this month.", para1, [ObjectiveCScripts convertNumberToMoneyString:projectedAmount]];
	
}


@end

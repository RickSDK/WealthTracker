//
//  UpdateVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/13/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "UpdateVC.h"
#import "ObjectiveCScripts.h"
#import "CoreDataLib.h"
#import "ItemObject.h"
#import "ItemCell.h"
#import "UpdateDetails.h"
#import "VehiclesVC.h"
#import "NSDate+ATTDate.h"
#import "GraphLib.h"
#import "GraphObject.h"

@interface UpdateVC ()

@end

@implementation UpdateVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	self.nowDay = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
	[self setupData];
}

-(IBAction)topSegmentChanged:(id)sender {
	[self setupData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Portfolio List"];
	
	self.propertyArray = [[NSMutableArray alloc] init];
	self.vehicleArray = [[NSMutableArray alloc] init];
	self.debtArray = [[NSMutableArray alloc] init];
	self.assetArray = [[NSMutableArray alloc] init];
	self.amountArray = [[NSMutableArray alloc] init];
	
	self.topImageView = [[UIImageView alloc] init];
	
	self.monthLabel.text = [[NSDate date] convertDateToStringWithFormat:@"MMM, YYYY"];
	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"YYYY"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];
	
	[ObjectiveCScripts swipeBackRecognizerForTableView:self.mainTableView delegate:self selector:@selector(handleSwipeRight:)];
	
	self.topSegment.layer.backgroundColor = [UIColor colorWithRed:(6/255.0) green:(122/255.0) blue:(180/255.0) alpha:1.0].CGColor;
	self.topSegment.layer.cornerRadius = 7;
	BOOL displayChangeFlg = [@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"displaySwitchFlg"]];
	self.topSegment.selectedSegmentIndex = !displayChangeFlg;


}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
	[self.navigationController popViewControllerAnimated:YES];
}


-(void)addNewItem {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select this item type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Real Estate", @"Vehicle", @"Debt", @"Asset", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [actionSheet cancelButtonIndex]) {
		VehiclesVC *detailViewController = [[VehiclesVC alloc] initWithNibName:@"VehiclesVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.callbackController=self;
		detailViewController.type=(int)buttonIndex+1;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(void)setupData {
	[self.propertyArray removeAllObjects];
	[self.vehicleArray removeAllObjects];
	[self.debtArray removeAllObjects];
	[self.assetArray removeAllObjects];
	[self.amountArray removeAllObjects];
	
	BOOL displayChangeFlg = self.topSegment.selectedSegmentIndex==0;
	
	if(displayChangeFlg) {
		self.graphTitleLabel.text = [NSString stringWithFormat:@"Net Worth Changes in %@", [[NSDate date] convertDateToStringWithFormat:@"MMMM"]];
		self.topRightLabel.text = @"Changes This Month";
		[ObjectiveCScripts displayNetChangeLabel:self.netWorthLabel amount:[ObjectiveCScripts changedEquityLast30:self.managedObjectContext] lightFlg:YES revFlg:NO];
	} else {
		self.graphTitleLabel.text = [NSString stringWithFormat:@"Equity as of %@", [[NSDate date] convertDateToStringWithFormat:@"MMMM"]];
		[ObjectiveCScripts displayMoneyLabel:self.netWorthLabel amount:[ObjectiveCScripts amountForItem:0 month:self.nowMonth year:self.nowYear field:@"" context:self.managedObjectContext type:0] lightFlg:YES revFlg:NO];
		self.topRightLabel.text = @"Total Net Worth";
	}

	NSMutableArray *graphArray = [[NSMutableArray alloc] init];
	
	NSArray *arrayOfArrays = [NSArray arrayWithObjects:self.propertyArray, self.vehicleArray, self.debtArray, self.assetArray, nil];
	int greenCount=0;
	int yellowCount=0;
	int redCount=0;
	for(int i=0; i<4; i++) {
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"type = %@", [ObjectiveCScripts typeNameForType:i+1]];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
		for(NSManagedObject *mo in items) {
			ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
			if(obj.status==0)
				greenCount++;
			if(obj.status==1)
				yellowCount++;
			if(obj.status==2)
				redCount++;
			double amount=0;
			if(displayChangeFlg)
				amount = [ObjectiveCScripts changedEquityLast30ForItem:[obj.rowId intValue] context:self.managedObjectContext];
			else
				amount = [ObjectiveCScripts amountForItem:[obj.rowId intValue] month:self.nowMonth year:self.nowYear field:@"" context:self.managedObjectContext type:i+1];
			
			if(abs(amount) > 0) {
				GraphObject *graphObject = [[GraphObject alloc] init];
				graphObject.name=obj.name;
				graphObject.amount=(self.displayPieFlg)?abs(amount):amount;
				graphObject.rowId = [obj.rowId intValue];
				[graphArray addObject:graphObject];
			}
			[[arrayOfArrays objectAtIndex:i] addObject:obj];
		}
	}
	if(redCount>0) {
		self.statusCountLabel.text = [NSString stringWithFormat:@"%d", redCount];
		self.statusCountLabel.textColor=[UIColor whiteColor];
		self.statusImageView.image = [UIImage imageNamed:@"red.png"];
	} else if(yellowCount>0) {
		self.statusCountLabel.text = [NSString stringWithFormat:@"%d", yellowCount];
		self.statusImageView.image = [UIImage imageNamed:@"yellow.png"];
		self.statusCountLabel.textColor=[UIColor blackColor];
	} else {
		self.statusCountLabel.text = [NSString stringWithFormat:@"%d", greenCount];
		self.statusImageView.image = [UIImage imageNamed:@"green.png"];
		self.statusCountLabel.textColor=[UIColor blackColor];
	}
	
	[self.amountArray addObject:[NSString stringWithFormat:@"%d", (int)[ObjectiveCScripts changedEquityLast30ForItem:-1 context:self.managedObjectContext]]];
	[self.amountArray addObject:[NSString stringWithFormat:@"%d", (int)[ObjectiveCScripts changedEquityLast30ForItem:-2 context:self.managedObjectContext]]];
	[self.amountArray addObject:[NSString stringWithFormat:@"%d", (int)[ObjectiveCScripts changedEquityLast30ForItem:-3 context:self.managedObjectContext]]];
	[self.amountArray addObject:[NSString stringWithFormat:@"%d", (int)[ObjectiveCScripts changedEquityLast30ForItem:-4 context:self.managedObjectContext]]];
	
	self.nextItemDue=[self nextItemDue];
	
	self.topImageView.image = (self.displayPieFlg)?[GraphLib pieChartWithItems:graphArray]:[GraphLib graphBarsWithItems:graphArray];

	[self.mainTableView reloadData];
}

-(int)nextItemDue {
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	int day = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"statement_day > %d", day];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *mo in items) {
		return [[mo valueForKey:@"rowId"] intValue];
	}
	day=0;
	NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"statement_day > %d", day];
	NSArray *items2 = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate2 sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *mo in items2) {
		return [[mo valueForKey:@"rowId"] intValue];
	}
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	if(indexPath.section==0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		cell.backgroundView = [[UIImageView alloc] initWithImage:self.topImageView.image];
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;

	} else {
	ItemCell *cell=nil;
	
		cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil) {
			cell = [[ItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}
		ItemObject *obj = nil;
		if(indexPath.section==1)
			obj = [self.propertyArray objectAtIndex:indexPath.row];
		if(indexPath.section==2)
			obj = [self.vehicleArray objectAtIndex:indexPath.row];
		if(indexPath.section==3)
			obj = [self.debtArray objectAtIndex:indexPath.row];
		if(indexPath.section==4)
			obj = [self.assetArray objectAtIndex:indexPath.row];
		
		cell.bgView.backgroundColor = [UIColor whiteColor];
		
		if(obj)
			[self updateCell:cell obj:obj];
		
		if(self.nextItemDue == [obj.rowId intValue] && obj.status>0)
			cell.bgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:.5 alpha:1];
		
		if(obj.status==2)
			cell.bgView.backgroundColor = [UIColor yellowColor];
		
		cell.textLabel.textColor = [UIColor blackColor];
		cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
		
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
}

-(ItemObject *)itemObjectForRow:(NSIndexPath *)indexPath {
	ItemObject *obj=nil;
	switch (indexPath.section) {
		case 1: {
			obj = [self.propertyArray objectAtIndex:indexPath.row];
		}
			break;
		case 2: {
			obj = [self.vehicleArray objectAtIndex:indexPath.row];
		}
			break;
		case 3: {
			obj = [self.debtArray objectAtIndex:indexPath.row];
		}
			break;
		case 4: {
			obj = [self.assetArray objectAtIndex:indexPath.row];
		}
			break;
			
		default:
			break;
	}
	return obj;
}

/*
-(UIImage *)statusImageForObj:(ItemObject *)obj valCheck:(BOOL)valCheck {
	if(obj.status==1)
		return [UIImage imageNamed:@"yellow.png"];
	if(valCheck) {
		if(obj.val_confirm_flg)
			return [UIImage imageNamed:@"green.png"];
		else
			return [UIImage imageNamed:@"red.png"];
	} else {
		if(obj.bal_confirm_flg)
			return [UIImage imageNamed:@"green.png"];
		else
			return [UIImage imageNamed:@"red.png"];
	}
}
*/


-(void)updateCell:(ItemCell *)cell obj:(ItemObject *)obj {
	cell.nameLabel.text = obj.name;
	cell.subTypeLabel.text = obj.sub_type;
	
	double amount = [obj.value doubleValue]-[obj.loan_balance doubleValue];
	double last30 = [ObjectiveCScripts changedEquityLast30ForItem:[obj.rowId intValue] context:self.managedObjectContext];
	
	if(last30>0 && obj.status==0)
		cell.bgView.layer.borderColor = [UIColor colorWithRed:0 green:.6 blue:0 alpha:1].CGColor;
	if(last30<0)
		cell.bgView.layer.borderColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1].CGColor;

	[ObjectiveCScripts displayMoneyLabel:cell.amountLabel amount:amount lightFlg:NO revFlg:NO];
	[ObjectiveCScripts displayNetChangeLabel:cell.last30Label amount:last30 lightFlg:NO revFlg:NO];

	cell.valStatusImage.image = [ObjectiveCScripts imageForStatus:obj.status];
	
	if([obj.statement_day intValue]==0) {
		cell.statement_dayLabel.text=@"";
		cell.statement_dayLabel2.text=@"";
	} else {
		cell.statement_dayLabel.text = obj.statement_day;
		cell.statement_dayLabel2.text = @"Statement Day";
	}
	
	cell.typeImageView.image = [ObjectiveCScripts imageIconForType:obj.type];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==0)
		return 1;
	if(section==1)
		return self.propertyArray.count;
	if(section==2)
		return self.vehicleArray.count;
	if(section==3)
		return self.debtArray.count;
	if(section==4)
		return self.assetArray.count;
	
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0) {
		self.displayPieFlg=!self.displayPieFlg;
		[self setupData];
		return;
	}
	if(self.expiredFlg)
		[ObjectiveCScripts showAlertPopup:@"Sorry!" message:@"The free version of this app has expired. please go to the options menu to unlock all the features of this awesome app!"];
	else {
		UpdateDetails *detailViewController = [[UpdateDetails alloc] initWithNibName:@"UpdateDetails" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.itemObject = [self itemObjectForRow:indexPath];
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(section==0)
		return CGFLOAT_MIN;
	else
		return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if(section==0)
		return nil;
	
	NSArray *titles = [NSArray arrayWithObjects:@"Real Estate", @"Vehicles", @"Debts", @"Assets", nil];
	return [self viewForHeaderWithText:[titles objectAtIndex:section-1] cellHeight:30 amount:[[self.amountArray objectAtIndex:section-1] doubleValue]];
}

- (UIView *)viewForHeaderWithText:(NSString *)headerText cellHeight:(float)cellHeight amount:(double)amount
{
	float screenWidth = [[UIScreen mainScreen] bounds].size.width;
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenWidth, 44.0)];
	customView.backgroundColor = [ObjectiveCScripts mediumkColor];
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:18];
	headerLabel.shadowColor = [UIColor blackColor];
	headerLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	headerLabel.numberOfLines = 0;
	headerLabel.frame = CGRectMake(10.0, 0.0, screenWidth/2, cellHeight);
	headerLabel.text = headerText;
	[customView addSubview:headerLabel];

	UILabel * amountTopLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2, -9, screenWidth/2-20, cellHeight)];
	amountTopLabel.backgroundColor = [UIColor clearColor];
	amountTopLabel.textAlignment = NSTextAlignmentRight;
	amountTopLabel.textColor = [UIColor whiteColor];
	amountTopLabel.font = [UIFont systemFontOfSize:10];
	amountTopLabel.text = @"Change This Month";
	[customView addSubview:amountTopLabel];

	UILabel * amountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	amountLabel.backgroundColor = [UIColor clearColor];
	amountLabel.opaque = NO;
	amountLabel.textColor = [ObjectiveCScripts colorBasedOnNumber:(double)amount lightFlg:YES];
	amountLabel.highlightedTextColor = [UIColor whiteColor];
	amountLabel.font = [UIFont boldSystemFontOfSize:18];
	amountLabel.shadowColor = [UIColor blackColor];
	amountLabel.textAlignment = NSTextAlignmentRight;
	amountLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	amountLabel.numberOfLines = 0;
	amountLabel.frame = CGRectMake(screenWidth/2, 5, screenWidth/2-20, cellHeight);
	if(amount>0)
		amountLabel.text = [NSString stringWithFormat:@"+%@", [ObjectiveCScripts convertNumberToMoneyString:amount]];
	else
		amountLabel.text = [ObjectiveCScripts convertNumberToMoneyString:amount];
	
	
	[customView addSubview:amountLabel];
	return customView;
}



-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return .01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0)
		return [ObjectiveCScripts chartHeightForSize:190];
	else
		return 60;
}

@end

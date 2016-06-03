//
//  PortfolioVC.m
//  WealthTracker
//
//  Created by Rick Medved on 5/12/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "PortfolioVC.h"
#import "ItemObject.h"
#import "ItemCell.h"
#import "UpdateDetails.h"
#import "VehiclesVC.h"
#import "NSDate+ATTDate.h"
#import "GraphLib.h"
#import "GraphObject.h"
#import "BreakdownByMonthVC.h"
#import "AssetsDebtsVC.h"

@interface PortfolioVC ()

@end

@implementation PortfolioVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Portfolio"];
	
	self.propertyArray = [[NSMutableArray alloc] init];
	self.vehicleArray = [[NSMutableArray alloc] init];
	self.debtArray = [[NSMutableArray alloc] init];
	self.assetArray = [[NSMutableArray alloc] init];
	self.amountArray = [[NSMutableArray alloc] init];
	self.totalArray = [[NSMutableArray alloc] init];
	
	
	self.topImageView = [[UIImageView alloc] init];
	self.graphArray = [[NSMutableArray alloc] init];
	
	self.graphImageView.hidden=YES;
	self.pieSegment.hidden=YES;

	self.portfolioLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20.f];
	self.portfolioLabel.text = [NSString fontAwesomeIconStringForEnum:FAbank];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];
	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setupData];
}


-(void)addNewItem {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select this item type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Asset", @"Debt", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [actionSheet cancelButtonIndex]) {
		[self gotoAssetsPage:(buttonIndex==0) showPopup:YES];
	}
}

-(void)gotoAssetsPage:(BOOL)assetsFlg showPopup:(BOOL)showPopup {
	AssetsDebtsVC *detailViewController = [[AssetsDebtsVC alloc] initWithNibName:@"AssetsDebtsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.filterType=assetsFlg;
	detailViewController.showPopup=showPopup;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)topSegmentChanged:(id)sender {
	[self.topSegment changeSegment];
	self.netWorthLabel.text = (self.topSegment.selectedSegmentIndex==0)?@"Net Worth":@"Net Worth Change";
	[self setupData];
}

-(void)setupData {
	[self.propertyArray removeAllObjects];
	[self.vehicleArray removeAllObjects];
	[self.debtArray removeAllObjects];
	[self.assetArray removeAllObjects];
	[self.amountArray removeAllObjects];
	[self.graphArray removeAllObjects];
	
	BOOL displayChangeFlg = self.pieSegment.selectedSegmentIndex==0;
	
	if(displayChangeFlg) {
		self.graphTitleLabel.text = [NSString stringWithFormat:@"Net Worth Changes in %@", [[NSDate date] convertDateToStringWithFormat:@"MMMM"]];
	} else {
		self.graphTitleLabel.text = [NSString stringWithFormat:@"Equity as of %@", [[NSDate date] convertDateToStringWithFormat:@"MMMM"]];
	}
	
	
	NSArray *arrayOfArrays = [NSArray arrayWithObjects:self.propertyArray, self.vehicleArray, self.debtArray, self.assetArray, nil];
	int greenCount=0;
	int yellowCount=0;
	int redCount=0;
	int totalAsset=0;
	int totalDebts=0;
	for(int i=0; i<4; i++) {
		double totalAmount=0;
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"type = %@", [ObjectiveCScripts typeNameForType:i+1]];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
		for(NSManagedObject *mo in items) {
			ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
			totalAsset+=obj.value;
			totalDebts+=obj.balance;
			if(obj.status==0)
				greenCount++;
			if(obj.status==1)
				yellowCount++;
			if(obj.status==2)
				redCount++;
			double amountChange = [ObjectiveCScripts changedEquityLast30ForItem:[obj.rowId intValue] context:self.managedObjectContext];
			double amountTotal = [ObjectiveCScripts amountForItem:[obj.rowId intValue] month:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear] field:@"" context:self.managedObjectContext type:i+1];
			
			double amount=(self.topSegment.selectedSegmentIndex==1)?amountChange:amountTotal;
			totalAmount += amount;
			
			if(abs(amount) > 0) {
				GraphObject *graphObject = [[GraphObject alloc] init];
				graphObject.name=obj.name;
				graphObject.amount=(self.pieSegment.selectedSegmentIndex==1)?abs(amount):amount;
				graphObject.rowId = [obj.rowId intValue];
				[self.graphArray addObject:graphObject];
			}
			[[arrayOfArrays objectAtIndex:i] addObject:obj];
		}
		[self.totalArray addObject:[NSString stringWithFormat:@"%d", (int)totalAmount]];
	}
	
	[self.amountArray addObject:[NSString stringWithFormat:@"%d", (int)[ObjectiveCScripts changedEquityLast30ForItem:-1 context:self.managedObjectContext]]];
	[self.amountArray addObject:[NSString stringWithFormat:@"%d", (int)[ObjectiveCScripts changedEquityLast30ForItem:-2 context:self.managedObjectContext]]];
	[self.amountArray addObject:[NSString stringWithFormat:@"%d", (int)[ObjectiveCScripts changedEquityLast30ForItem:-3 context:self.managedObjectContext]]];
	[self.amountArray addObject:[NSString stringWithFormat:@"%d", (int)[ObjectiveCScripts changedEquityLast30ForItem:-4 context:self.managedObjectContext]]];
	
	self.graphImageView.image = (self.pieSegment.selectedSegmentIndex==1)?[GraphLib pieChartWithItems:self.graphArray startDegree:self.startDegree]:[GraphLib graphBarsWithItems:self.graphArray];
	
	[self.pieSegment changeSegment];
	
	int year = [ObjectiveCScripts nowYear];
	int month = [ObjectiveCScripts nowMonth];
	
	if(self.topSegment.selectedSegmentIndex==0)
		[ObjectiveCScripts displayMoneyLabel:self.netWorthChangeLabel amount:[ObjectiveCScripts amountForItem:0 month:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear] field:@"" context:self.managedObjectContext type:0] lightFlg:YES revFlg:NO];
	else
		[ObjectiveCScripts displayNetChangeLabel:self.netWorthChangeLabel amount:[ObjectiveCScripts changedEquityLast30:self.managedObjectContext] lightFlg:YES revFlg:NO];
	
	[ObjectiveCScripts displayMoneyLabel:self.assetTotalLabel amount:[ObjectiveCScripts amountForItem:0 month:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear] field:@"asset_value" context:self.managedObjectContext type:0] lightFlg:YES revFlg:NO];
	[ObjectiveCScripts displayMoneyLabel:self.debtTotalLabel amount:[ObjectiveCScripts amountForItem:0 month:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear] field:@"balance_owed" context:self.managedObjectContext type:0] lightFlg:YES revFlg:YES];

	self.assetView.backgroundColor=[ObjectiveCScripts darkColor];
	self.debtView.backgroundColor=[ObjectiveCScripts darkColor];
	self.netWorthView.backgroundColor=[ObjectiveCScripts mediumkColor];
	
	
	double asset_value = [ObjectiveCScripts changedForItem:0 month:month year:year field:@"asset_value" context:self.managedObjectContext numMonths:1 type:0];
	double balance_owed = [ObjectiveCScripts changedForItem:0 month:month year:year field:@"balance_owed" context:self.managedObjectContext numMonths:1 type:0];
	
	[ObjectiveCScripts displayNetChangeLabel:self.assetChangeLabel amount:asset_value lightFlg:YES revFlg:NO];
	[ObjectiveCScripts displayNetChangeLabel:self.debtChangeLabel amount:balance_owed lightFlg:YES revFlg:YES];


	[self.mainTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	ItemCell *cell=nil;
	
	cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil) {
		cell = [[ItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	ItemObject *obj = nil;
	if(indexPath.section==0)
		obj = [self.propertyArray objectAtIndex:indexPath.row];
	if(indexPath.section==1)
		obj = [self.vehicleArray objectAtIndex:indexPath.row];
	if(indexPath.section==2)
		obj = [self.debtArray objectAtIndex:indexPath.row];
	if(indexPath.section==3)
		obj = [self.assetArray objectAtIndex:indexPath.row];
	
	cell.bgView.backgroundColor = [UIColor whiteColor];
	
	if(obj)
		[ItemCell updateCell:cell obj:obj];
	
	cell.nameLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19];
	cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [ObjectiveCScripts faIconOfType:(int)indexPath.section+1], cell.nameLabel.text];
	
	if(self.topSegment.selectedSegmentIndex==0) {
		if(obj.equity>0)
			cell.bgView.backgroundColor = [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];
		if(obj.equity<0)
			cell.bgView.backgroundColor = [UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
	} else {
		if(obj.equityChange>0)
			cell.bgView.backgroundColor = [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];
		if(obj.equityChange<0)
			cell.bgView.backgroundColor = [UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
	}
	
	if(self.topSegment.selectedSegmentIndex==0) {
		cell.rightLabel.text = @"Equity";
		[ObjectiveCScripts displayMoneyLabel:cell.equityChangeLabel amount:obj.equity lightFlg:NO revFlg:NO];
		if([@"Debt" isEqualToString:obj.type]) {
			cell.rightLabel.text = @"Amount";
			[ObjectiveCScripts displayMoneyLabel:cell.equityChangeLabel amount:obj.balance lightFlg:NO revFlg:YES];
		}
		if([@"Asset" isEqualToString:obj.type])
			cell.rightLabel.text = @"Amount";
	} else {
		cell.rightLabel.text = @"Thie Month";
		[ObjectiveCScripts displayNetChangeLabel:cell.equityChangeLabel amount:obj.equityChange lightFlg:NO revFlg:NO];
		
	}
	
	cell.textLabel.textColor = [UIColor blackColor];
	
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	
	float width=0;
	if(self.maxBalance>0)
		width = [obj.loan_balance floatValue]*316/self.maxBalance;
	cell.redLineView.frame=CGRectMake(0, cell.redLineView.frame.origin.y, width, 5);
	cell.bgView.layer.borderColor = [UIColor blackColor].CGColor;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.backgroundColor = [ObjectiveCScripts colorForType:(int)indexPath.section+1];
	
	return cell;
}

-(ItemObject *)itemObjectForRow:(NSIndexPath *)indexPath {
	ItemObject *obj=nil;
	switch (indexPath.section) {
		case 0: {
			obj = [self.propertyArray objectAtIndex:indexPath.row];
		}
			break;
		case 1: {
			obj = [self.vehicleArray objectAtIndex:indexPath.row];
		}
			break;
		case 2: {
			obj = [self.debtArray objectAtIndex:indexPath.row];
		}
			break;
		case 3: {
			obj = [self.assetArray objectAtIndex:indexPath.row];
		}
			break;
			
		default:
			break;
	}
	return obj;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==0)
		return self.propertyArray.count;
	if(section==1)
		return self.vehicleArray.count;
	if(section==2)
		return self.debtArray.count;
	if(section==3)
		return self.assetArray.count;
	
	return 0;
}

-(IBAction)pieSegmentChanged:(id)sender {
	[self setupData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
	return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSString *title = [ObjectiveCScripts fontAwesomeTextAltForType:(int)section+1];
	double amount=0;
	if(self.topSegment.selectedSegmentIndex==1)
		amount = [[self.amountArray objectAtIndex:section] doubleValue];
	else
		amount = [[self.totalArray objectAtIndex:section] doubleValue];
	return [self viewForHeaderWithText:title cellHeight:30 amount:amount section:(int)section];
}

- (UIView *)viewForHeaderWithText:(NSString *)headerText cellHeight:(float)cellHeight amount:(double)amount section:(int)section
{
	float screenWidth = [[UIScreen mainScreen] bounds].size.width;
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenWidth, 44.0)];
	customView.backgroundColor = [ObjectiveCScripts colorForType:section+1];
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18];
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
	if(self.topSegment.selectedSegmentIndex==0)
		amountTopLabel.text = @"Total";
	else
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
	if(amount>0 && self.topSegment.selectedSegmentIndex==1)
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
	return 50;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	self.startTouchPosition = [touch locationInView:self.view];
	if(CGRectContainsPoint(self.assetView.frame, self.startTouchPosition)) {
		[self gotoAssetsPage:YES showPopup:NO];
	}
	
	if(CGRectContainsPoint(self.debtView.frame, self.startTouchPosition)) {
		[self gotoAssetsPage:NO showPopup:NO];
	}

	if(self.pieSegment.selectedSegmentIndex==0) {
		self.pieSegment.selectedSegmentIndex=1;
		[self setupData];
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint newTouchPosition = [touch locationInView:self.view];
	

	if(self.pieSegment.selectedSegmentIndex==1) {
		
		self.startDegree = [GraphLib spinPieChart:self.graphImageView startTouchPosition:self.startTouchPosition newTouchPosition:newTouchPosition startDegree:self.startDegree barGraphObjects:self.graphArray];
		self.startTouchPosition=newTouchPosition;
		
		return; // pie chart
	}
}





@end

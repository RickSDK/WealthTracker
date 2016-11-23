//
//  AssetsDebtsVC.m
//  WealthTracker
//
//  Created by Rick Medved on 5/12/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "AssetsDebtsVC.h"
#import "BreakdownByMonthVC.h"
#import "ItemCell.h"
#import "UpdateDetails.h"

@interface AssetsDebtsVC ()

@end

@implementation AssetsDebtsVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.bottomView.backgroundColor = [ObjectiveCScripts darkColor];
	if(self.showPopup)
		[self addNewItem];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];

	self.iconButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19.f];
	self.keyboardButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19.f];
	[self.keyboardButton setTitle:[NSString fontAwesomeIconStringForEnum:FAKeyboardO] forState:UIControlStateNormal];
	self.type=1;
	self.subType=0;
	[self displayButtons];

	self.showAllSwitch.on=NO;
	
	
	if(self.filterType==2 && [ObjectiveCScripts getUserDefaultValue:@"DebtsCheckFlg"].length==0) {
		[ObjectiveCScripts showAlertPopup:@"Enter Debts" message:@"If you have any loans or credit card debts, enter them here. Then press 'Back' button."];
		[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"DebtsCheckFlg"];
	}
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setupData];
}


-(IBAction)topSegmentChanged:(id)sender {
	[self.topSegment changeSegment];
	[self setupData];
}

-(IBAction)typeSegmentChanged:(id)sender {
	[self.typeSegment changeSegment];
	self.filterType = (int)self.typeSegment.selectedSegmentIndex;
	[self setupData];
}


-(void)displayButtons {
	[self.iconButton setTitle:[ObjectiveCScripts faIconOfType:self.type] forState:UIControlStateNormal];
	[self.subTypeButton setTitle:[self subTypeStringForSubType:self.subType type:self.type] forState:UIControlStateNormal];
	self.typeLabel.text = [ObjectiveCScripts typeNameForType2:self.type];
	self.valueTextField.hidden=(self.type==3);
	self.balanceTextField.hidden=(self.type==4);
	self.interestTextField.hidden=(self.type==4);
	self.interestRateLabel.hidden=(self.type==4);
	self.paymentTextField.hidden=(self.type>2);
	self.moPayLabel.hidden=(self.type>2);
	self.duesTextField.hidden=(self.type>1);
	self.duesLabel.hidden=(self.type>1);
}

-(NSString *)subTypeStringForSubType:(int)subType type:(int)type {
	NSMutableArray *values = [[NSMutableArray alloc] init];
	switch (type) {
  case 1:
			[values addObject:@"Primary Residence"];
			[values addObject:@"Rental"];
			[values addObject:@"Other Property"];
			break;
  case 2:
			[values addObject:@"Auto"];
			[values addObject:@"Motorcycle"];
			[values addObject:@"RV"];
			[values addObject:@"ATV"];
			[values addObject:@"Jet Ski"];
			[values addObject:@"Snomobile"];
			[values addObject:@"Other"];
			break;
  case 3:
			[values addObject:@"Credit Card"];
			[values addObject:@"Student Loan"];
			[values addObject:@"Loan"];
			[values addObject:@"Medical"];
			[values addObject:@"Other"];
			break;
  case 4:
			[values addObject:@"401k"];
			[values addObject:@"Retirement"];
			[values addObject:@"Stocks"];
			[values addObject:@"College Fund"];
			[values addObject:@"Bank Account"];
			[values addObject:@"Other Asset"];
			break;
			
  default:
			break;
	}
	return [values objectAtIndex:subType%values.count];
}

-(void)setupData {
	self.typeSegment.selectedSegmentIndex = self.filterType;
	[self.typeSegment changeSegment];
	
	switch (self.filterType) {
  case 0:
			[self setTitle:@"Portfolio"];
			break;
  case 1:
			[self setTitle:@"Assets"];
			break;
  case 2:
			[self setTitle:@"Debts"];
			break;
			
  default:
			break;
	}
	
	[self.graphObjects removeAllObjects];
	[self.itemsArray removeAllObjects];
	NSMutableArray *chart2Objects = [[NSMutableArray alloc] init];
	self.totalAmount=0;
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"type" mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		if(obj.value>0 || obj.balance>0 || self.showAllSwitch.on || obj.status>0) {
			if(self.filterType==0)
				[self.itemsArray addObject:obj];
			else if(self.filterType==1 && obj.value>0)
				[self.itemsArray addObject:obj];
			else if(self.filterType==2 && obj.balance>0)
				[self.itemsArray addObject:obj];
			
			double amountLeft = (self.filterType==1)?obj.value:obj.balance;
			if(self.filterType==0)
				amountLeft=obj.equity;
			
//			if(self.topSegment.selectedSegmentIndex==1) {
				double amountRight = (self.filterType==1)?obj.valueChange:obj.balanceChange;
				if(self.filterType==0)
					amountRight=obj.equityChange;
//			}
			
			double amount =(self.topSegment.selectedSegmentIndex==0)?amountLeft:amountRight;
			
			self.totalAmount+=amount;
			
			if(amount != 0) {
				GraphObject *gObj = [GraphObject graphObjectWithName:obj.name amount:amountLeft rowId:1 reverseColorFlg:self.filterType==2 currentMonthFlg:NO];
				[self.graphObjects addObject:gObj];

				[chart2Objects addObject:[GraphObject graphObjectWithName:obj.name amount:amountRight rowId:1 reverseColorFlg:self.filterType==2 currentMonthFlg:NO]];

			}
		}
	}
	[ObjectiveCScripts displayMoneyLabel:self.totalAmountLabel amount:self.totalAmount lightFlg:YES revFlg:self.filterType==2];
	
	self.chartImageView.image = [GraphLib graphBarsWithItems:self.graphObjects];
	self.chartImageView2.image = [GraphLib graphBarsWithItems:chart2Objects];
	
	self.messageLabel.hidden=self.itemsArray.count>0;
	self.typeSegment.enabled=self.itemsArray.count>0;
	self.topSegment.enabled=self.itemsArray.count>0;
	if(self.filterType==2)
		self.messageLabel.text = @"Press the '+' button above to enter debts";
	
	if([ObjectiveCScripts getUserDefaultValue:@"DebtsCheckFlg"].length==0) {
		self.typeSegment.enabled=NO;
		self.topSegment.enabled=NO;
	}
	[self.mainTableView reloadData];
}

-(void)addNewItem {
	self.itemObject=nil;
	self.popupView.hidden=NO;
	self.nameTextField.text=@"";
	self.valueTextField.text=@"";
	self.balanceTextField.text=@"";
	self.paymentTextField.text=@"";
	self.interestTextField.text=@"";
	self.dueDayTextField.text = @"1";
	self.viewDetailsButton.enabled=NO;
	self.titleLabel.text = @"New Item";
	self.nameTextField.enabled=NO;
	self.submitButton.enabled=NO;
	self.chooseTypeView.hidden=NO;
	[self.iconButton setTitle:@"" forState:UIControlStateNormal];
	[self.subTypeButton setTitle:@"" forState:UIControlStateNormal];
	self.newItemFlg=YES;
}

-(IBAction)breakdownButtonClicked:(id)sender {
	BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.type=0;
	if(self.typeSegment.selectedSegmentIndex==2) {
		detailViewController.type=3;
	}
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	
	if(indexPath.section==0) {
		NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		cell.backgroundView	= [ObjectiveCScripts imageViewForWidth:self.view.frame.size.width chart1:self.chartImageView.image chart2:self.chartImageView2.image switchFlg:self.topSegment.selectedSegmentIndex==1];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}

	
	ItemCell *cell=nil;
	
	cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil) {
		cell = [[ItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	ItemObject *obj = [self.itemsArray objectAtIndex:indexPath.row];
	
	cell.bgView.backgroundColor = [UIColor whiteColor];
	
	if(obj)
		[ItemCell updateCell:cell obj:obj];
	
	cell.nameLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19];
	cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [ObjectiveCScripts faIconOfTypeString:obj.type], cell.nameLabel.text];
	
	cell.arrowLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
	if(obj.equityChange>0) {
		cell.arrowLabel.text = [NSString fontAwesomeIconStringForEnum:FAArrowUp];
		cell.arrowLabel.textColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	} else {
		cell.arrowLabel.text = [NSString fontAwesomeIconStringForEnum:FAArrowDown];
		cell.arrowLabel.textColor = [UIColor redColor];
	}
	cell.arrowLabel.hidden = obj.equityChange==0;
	if(self.typeSegment.selectedSegmentIndex==2)
		cell.arrowLabel.hidden=YES;
	
	
	if(self.topSegment.selectedSegmentIndex==0) {
		if(obj.equity>0)
			cell.bgView.backgroundColor = [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];
		if(obj.equity<0 || self.filterType==2)
			cell.bgView.backgroundColor = [UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
	} else {
		if(obj.equityChange>0)
			cell.bgView.backgroundColor = [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];
		if(obj.equityChange<0)
			cell.bgView.backgroundColor = [UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
	}
	
	double amount=0;
	double changeAmount=0;
	BOOL revFlg=NO;
	if(self.filterType==0) {
		cell.rightLabel.text = (self.topSegment.selectedSegmentIndex==0)?@"Equity":@"Equity";
		amount = obj.equity;
		changeAmount = obj.equityChange;
	} else if(self.filterType==1) {
		cell.rightLabel.text = (self.topSegment.selectedSegmentIndex==0)?@"Value":@"Value";
		amount = obj.value;
		changeAmount = obj.valueChange;
	} else {
		cell.rightLabel.text = (self.topSegment.selectedSegmentIndex==0)?@"Balance":@"Balance";
		amount = obj.balance;
		changeAmount = obj.balanceChange;
		revFlg=YES;
		if(obj.balance==0)
			cell.bgView.backgroundColor=[UIColor colorWithWhite:.7 alpha:1];
	}
	[ObjectiveCScripts displayMoneyLabel:cell.equityLabel amount:amount lightFlg:NO revFlg:revFlg];
	[ObjectiveCScripts displayNetChangeLabel:cell.equityChangeLabel amount:changeAmount lightFlg:NO revFlg:revFlg];
	self.totalAmount+=(self.topSegment.selectedSegmentIndex==0)?amount:changeAmount;
	
	cell.textLabel.textColor = [UIColor blackColor];
	
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	cell.redLineView.hidden=YES;
	cell.bgView.layer.borderColor = [UIColor blackColor].CGColor;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.backgroundColor = [ObjectiveCScripts colorForType:(int)indexPath.section+1];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0)
		return 190;
//		return [ObjectiveCScripts chartHeightForSize:190];
	else
		return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==0)
		return 1;
	
	return self.itemsArray.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0)
		return;
	
	if(self.expiredFlg)
		[ObjectiveCScripts showAlertPopup:@"Sorry!" message:@"The free version of this app has expired. please go to the options menu to unlock all the features of this awesome app!"];
	else {
		self.itemObject = [self.itemsArray objectAtIndex:indexPath.row];
		
		if(self.typeSegment.selectedSegmentIndex==0) {
			UpdateDetails *detailViewController = [[UpdateDetails alloc] initWithNibName:@"UpdateDetails" bundle:nil];
			detailViewController.managedObjectContext = self.managedObjectContext;
			detailViewController.itemObject = self.itemObject;
			[self.navigationController pushViewController:detailViewController animated:YES];
			return;
		}
		self.viewDetailsButton.enabled=YES;
		self.popupView.hidden=NO;
		self.nameTextField.enabled=YES;
		self.submitButton.enabled=YES;
		self.chooseTypeView.hidden=YES;
		self.nameTextField.text=self.itemObject.name;
		self.valueTextField.text=[NSString stringWithFormat:@"%d", (int)self.itemObject.value];
		self.balanceTextField.text=[NSString stringWithFormat:@"%d", (int)self.itemObject.balance];
		self.paymentTextField.text=self.itemObject.monthly_payment;
		self.duesTextField.text=self.itemObject.homeowner_dues;
		self.interestTextField.text=self.itemObject.interest_rate;
		self.dueDayTextField.text = self.itemObject.statement_day;
		self.titleLabel.text = @"Edit Item";
		self.newItemFlg=NO;
		
		self.type = [ObjectiveCScripts typeNumberFromTypeString:self.itemObject.type];
		[self displayButtons];
		[self.subTypeButton setTitle:self.itemObject.sub_type forState:UIControlStateNormal];
		

	}
}

-(IBAction)viewDetailsButtonClicked:(id)sender {
	UpdateDetails *detailViewController = [[UpdateDetails alloc] initWithNibName:@"UpdateDetails" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.itemObject = self.itemObject;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)xButtonClicked:(id)sender {
	self.popupView.hidden=YES;
	[self resignKeyboards];
}

-(void)resignKeyboards {
	[self.nameTextField resignFirstResponder];
	[self.amountTextField resignFirstResponder];
	[self.dueDayTextField resignFirstResponder];
	[self.valueTextField resignFirstResponder];
	[self.balanceTextField resignFirstResponder];
	[self.paymentTextField resignFirstResponder];
	[self.interestTextField resignFirstResponder];
	[self.duesTextField resignFirstResponder];
}

-(IBAction)keyboardButtonClicked:(id)sender {
	[self resignKeyboards];
}


-(IBAction)submitButtonClicked:(id)sender {
	[self resignKeyboards];
	if(self.nameTextField.text.length==0) {
		[ObjectiveCScripts showAlertPopup:@"Enter a name" message:@""];
		return;
	}
	int balance = [self.balanceTextField.text intValue];
	int value = [self.valueTextField.text intValue];
	if(balance==0 && (self.type==3)) {
		[ObjectiveCScripts showAlertPopup:@"Whoa!" message:@"Be sure to entire a current balance."];
		return;
	}
	if(value==0 && self.type!=3) {
		[ObjectiveCScripts showAlertPopup:@"Whoa!" message:@"Be sure to entire the current value of this asset."];
		return;
	}
	
	self.popupView.hidden=YES;
	
	if(self.newItemFlg) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New or Existing?"
														message:@"Is this item new this month, or have you had it for a while?"
													   delegate:self
											  cancelButtonTitle:@"New"
											  otherButtonTitles: @"Existing", nil];
		alert.tag = 101;
		[alert show];
	} else
		[self createOrUpdateItem];
	
}

-(void)createOrUpdateItem {
	[self createNewItem];
	[self setupData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag==101) {
		self.noHistoryFlg = (buttonIndex==0);
		self.typeSegment.selectedSegmentIndex=0;
		self.filterType=0;
		[self.typeSegment changeSegment];
		[self createOrUpdateItem];
	}
}

-(IBAction)typeButtonClicked:(id)sender {
	self.type++;
	self.chooseTypeView.hidden=YES;
	self.nameTextField.enabled=YES;
	self.submitButton.enabled=YES;
	if(self.type>4)
		self.type=1;
	
	if(self.filterType==1 && self.type==3)
		self.type=4;
	if(self.filterType==2)
		self.type=3;
	
	self.subType=0;
	[self displayButtons];
}
-(IBAction)subtypeButtonClicked:(id)sender {
	if(!self.chooseTypeView.hidden)
		return;
	
	self.subType++;
	self.chooseTypeView.hidden=YES;
	[self displayButtons];
}


-(void)createNewItem {
	NSManagedObject *mo = nil;
	if(!self.newItemFlg && self.itemObject.name.length>0) {
		mo = [ItemObject moFromObject:self.itemObject context:self.managedObjectContext];
	} else {
		mo = [NSEntityDescription insertNewObjectForEntityForName:@"ITEM" inManagedObjectContext:self.managedObjectContext];
		int rowId = [[CoreDataLib autoIncrementNumber] intValue];
		[mo setValue:[NSNumber numberWithInt:rowId] forKey:@"rowId"];
	}

	[self initialyzeDatabaseRecord:mo];
	
	ItemObject *itemObject = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
	
	int nowYear = [ObjectiveCScripts nowYear];
	int nowMonth = [ObjectiveCScripts nowMonth];
	[CoreDataLib updateItemAmount:itemObject type:0 month:nowMonth year:nowYear currentFlg:YES amount:[itemObject.valueStr doubleValue] moc:self.managedObjectContext noHistoryFlg:self.noHistoryFlg];
	[CoreDataLib updateItemAmount:itemObject type:1 month:nowMonth year:nowYear currentFlg:YES amount:[itemObject.loan_balance doubleValue] moc:self.managedObjectContext noHistoryFlg:self.noHistoryFlg];
	
	[self setupData];
	
}

-(IBAction)showAllSwitchChanged:(id)sender {
	[self setupData];
}

-(void)initialyzeDatabaseRecord:(NSManagedObject *)record {
	NSMutableArray *keys = [[NSMutableArray alloc] init];
	NSMutableArray *values = [[NSMutableArray alloc] init];
	NSMutableArray *types = [[NSMutableArray alloc] init];

	[keys addObject:@"name"];
	[values addObject:self.nameTextField.text];
	[types addObject:@"text"];
	
	[keys addObject:@"value"];
	[values addObject:self.valueTextField.text];
	[types addObject:@"double"];

	[keys addObject:@"loan_balance"];
	[values addObject:self.balanceTextField.text];
	[types addObject:@"double"];

	[keys addObject:@"statement_day"];
	[values addObject:self.dueDayTextField.text];
	[types addObject:@"int"];
	
	[keys addObject:@"type"];
	[values addObject:[ObjectiveCScripts typeNameForType2:self.type]];
	[types addObject:@"text"];
	
	[keys addObject:@"sub_type"];
	[values addObject:[self subTypeStringForSubType:self.subType type:self.type]];
	[types addObject:@"text"];
	
	[keys addObject:@"monthly_payment"];
	[values addObject:self.paymentTextField.text];
	[types addObject:@"double"];
	
	[keys addObject:@"homeowner_dues"];
	[values addObject:self.duesTextField.text];
	[types addObject:@"double"];
	
	[keys addObject:@"interest_rate"];
	[values addObject:self.interestTextField.text];
	[types addObject:@"text"];
	
	[CoreDataLib updateManagedObject:record keyList:keys valueList:values typeList:types mOC:self.managedObjectContext];
}






@end

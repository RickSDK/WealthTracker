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

	[self setupData];
	
	
	if(self.filterType==2 && [ObjectiveCScripts getUserDefaultValue:@"DebtsCheckFlg"].length==0) {
		[ObjectiveCScripts showAlertPopup:@"Enter Debts" message:@"Enter all loans and debts"];
		[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"DebtsCheckFlg"];
	}
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
	self.typeLabel.text = [ObjectiveCScripts typeNameForType:self.type];
	self.valueTextField.hidden=(self.type==3);
	self.balanceTextField.hidden=(self.type==4);
	self.interestTextField.hidden=(self.type==4);
	self.interestRateLabel.hidden=(self.type==4);
	self.paymentTextField.hidden=(self.type>2);
	self.moPayLabel.hidden=(self.type>2);
	self.duesTextField.hidden=(self.type>1);
	self.duesLabel.hidden=(self.type>1);
	
	NSLog(@"type: %d", self.type);
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
	self.totalAmount=0;
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"type" mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		
		BOOL isAsset = ([@"Real Estate" isEqualToString:obj.type] || [@"Vehicle" isEqualToString:obj.type] || [@"Asset" isEqualToString:obj.type]);
		BOOL isDebt = ([@"Real Estate" isEqualToString:obj.type] || [@"Vehicle" isEqualToString:obj.type] || [@"Debt" isEqualToString:obj.type]);
		if(self.filterType==0)
			[self.itemsArray addObject:obj];
		else if(self.filterType==1 && isAsset)
			[self.itemsArray addObject:obj];
		else if(self.filterType==2 && isDebt)
			[self.itemsArray addObject:obj];
		
		double amount = (self.filterType==1)?obj.value:obj.balance;
		if(self.filterType==0)
			amount=obj.equity;
		if(self.topSegment.selectedSegmentIndex==1) {
			amount = (self.filterType==1)?obj.valueChange:obj.balanceChange;
			if(self.filterType==0)
				amount=obj.equityChange;
		}
		
		self.totalAmount+=amount;
		
		GraphObject *gObj = [GraphObject graphObjectWithName:obj.name amount:amount rowId:1 reverseColorFlg:self.filterType==2 currentMonthFlg:NO];

		if(amount != 0)
			[self.graphObjects addObject:gObj];
		
	}
	[ObjectiveCScripts displayMoneyLabel:self.totalAmountLabel amount:self.totalAmount lightFlg:YES revFlg:self.filterType==2];
	self.chartImageView.image = [GraphLib graphBarsWithItems:self.graphObjects];
	self.messageLabel.hidden=self.itemsArray.count>0;
	if(self.filterType==2)
		self.messageLabel.text = @"Press the '+' button above to enter debts";
	[self.mainTableView reloadData];
}

-(void)addNewItem {
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
}

-(IBAction)breakdownButtonClicked:(id)sender {
	BreakdownByMonthVC *detailViewController = [[BreakdownByMonthVC alloc] initWithNibName:@"BreakdownByMonthVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.tag=(self.filterType==1)?11:12;
	detailViewController.fieldType=self.filterType==2;
	detailViewController.type=0;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	
	if(indexPath.section==0) {
		NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		cell.backgroundView = [[UIImageView alloc] initWithImage:self.chartImageView.image];
		
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
	BOOL revFlg=NO;
	if(self.filterType==0) {
		cell.rightLabel.text = (self.topSegment.selectedSegmentIndex==0)?@"Equity":@"Change";
		amount = (self.topSegment.selectedSegmentIndex==0)?obj.equity:obj.equityChange;
	} else if(self.filterType==1) {
		cell.rightLabel.text = (self.topSegment.selectedSegmentIndex==0)?@"Value":@"Change";
		amount = (self.topSegment.selectedSegmentIndex==0)?obj.value:obj.valueChange;
	} else {
		cell.rightLabel.text = (self.topSegment.selectedSegmentIndex==0)?@"Balance":@"Change";
		amount = (self.topSegment.selectedSegmentIndex==0)?obj.balance:obj.balanceChange;
		revFlg=YES;
		if(obj.balance==0)
			cell.bgView.backgroundColor=[UIColor colorWithWhite:.7 alpha:1];
	}
	[ObjectiveCScripts displayMoneyLabel:cell.equityChangeLabel amount:amount lightFlg:NO revFlg:revFlg];
	self.totalAmount+=amount;
	
	cell.textLabel.textColor = [UIColor blackColor];
	
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	cell.redLineView.hidden=YES;
	cell.bgView.layer.borderColor = [UIColor blackColor].CGColor;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.backgroundColor = [ObjectiveCScripts colorForType:(int)indexPath.section+1];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0)
		return [ObjectiveCScripts chartHeightForSize:190];
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
	if(self.nameTextField.text.length==0) {
		[ObjectiveCScripts showAlertPopup:@"Enter a name" message:@""];
		return;
	}
	
	self.popupView.hidden=YES;
	[self resignKeyboards];
	
	[self createNewItem];
	[self setupData];
}

-(IBAction)typeButtonClicked:(id)sender {
	self.type++;
	self.chooseTypeView.hidden=YES;
	self.nameTextField.enabled=YES;
	self.submitButton.enabled=YES;
	if(self.type>4)
		self.type=1;
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
	if(self.itemObject.name.length>0) {
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
	[CoreDataLib updateItemAmount:itemObject type:0 month:nowMonth year:nowYear currentFlg:YES amount:[itemObject.valueStr doubleValue] moc:self.managedObjectContext];
	[CoreDataLib updateItemAmount:itemObject type:1 month:nowMonth year:nowYear currentFlg:YES amount:[itemObject.loan_balance doubleValue] moc:self.managedObjectContext];
	
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
	[values addObject:[ObjectiveCScripts typeNameForType:self.type]];
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

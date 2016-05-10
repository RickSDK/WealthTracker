//
//  EditItemVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/11/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "EditItemVC.h"
#import "VehiclesVC.h"
#import "ObjectiveCScripts.h"
#import "MoneyCell.h"
#import "EnterValueVC.h"
#import "ItemCellObj.h"
#import "SelectListVC.h"
#import "ItemObject.h"
#import <CoreData/CoreData.h>
#import "CoreDataLib.h"
#import "MainMenuVC.h"
#import "NSDate+ATTDate.h"


@interface EditItemVC ()

@end

@implementation EditItemVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.cellObjArray = [[NSMutableArray alloc] init];
	self.profileObj = [[ProfileObj alloc] init];
	
	if(self.itemObject)
		self.sub_type = [ObjectiveCScripts subTypeFromSubTypeString:self.itemObject.sub_type];
	
	if(self.itemObject && !self.managedObj) {
		self.managedObj = [CoreDataLib managedObjFromId:self.itemObject.rowId managedObjectContext:self.managedObjectContext];
	}
	
	self.type = [ObjectiveCScripts typeNumberFromSubType:self.sub_type];

	[self setTitle:[ObjectiveCScripts subTypeForNumber:self.sub_type]];
	
	if(self.sub_type==0 || self.sub_type==1) {
		[self checkForProfile];
	}
	
	self.testLabel.hidden = (kTestMode)?NO:YES;

	[self setupData];
	
	if(self.type==0)
		self.deleteButton.hidden=YES;
	
	self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];

	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finished" style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed)];
}

-(void)cancelButtonPressed {
	if(self.stuffChangedFlg)
		[ObjectiveCScripts showConfirmationPopup:@"Discard Changes?" message:@"" delegate:self tag:5];
	else
		[self.navigationController popViewControllerAnimated:YES];
}


-(void)checkForProfile {
	NSArray *items = [CoreDataLib selectRowsFromTable:@"PROFILE" mOC:self.managedObjectContext];
	if(items.count==0) {
		NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:@"PROFILE" inManagedObjectContext:self.managedObjectContext];
		[mo setValue:[NSNumber numberWithInt:1] forKey:@"planStep"];
		[self.managedObjectContext save:nil];
		items = [CoreDataLib selectRowsFromTable:@"PROFILE" mOC:self.managedObjectContext];
		NSLog(@"Inserting new record!");
	}
	if(items.count>0) {
		NSManagedObject *mo = [items objectAtIndex:0];
		self.profileObj.income = [NSString stringWithFormat:@"%d",(int)[[mo valueForKey:@"annual_income"] floatValue]];
		self.profileObj.emergency_fund = [NSString stringWithFormat:@"%d",(int)[[mo valueForKey:@"emergency_fund"] floatValue]];
		self.profileObj.retirement_payments = [NSString stringWithFormat:@"%d",(int)[[mo valueForKey:@"retirement_payments"] floatValue]];
		self.profileObj.dependants = [NSString stringWithFormat:@"%d",[[mo valueForKey:@"dependants"] intValue]];
		self.profileObj.monthly_rent = [NSString stringWithFormat:@"%d",(int)[[mo valueForKey:@"monthly_rent"] floatValue]];
		self.profileObj.age = [NSString stringWithFormat:@"%d",[[mo valueForKey:@"age"] intValue]];
		
	}
}

-(void)insertObjectWithTitle:(NSString *)title
						desc:(NSString *)desc
					   value:(NSString *)value
						flag:(NSString *)flag
				   fieldType:(int)fieldType
				  listNumber:(int)listNumber
{
	if(value.length==0)
		value = @"";
	
	if([value intValue]>0 || value.length>1)
		flag = @"Y";
	ItemCellObj *obj = [[ItemCellObj alloc] init];
	obj.title=title;
	obj.desc=desc;
	obj.value=value;
	obj.flag=flag;
	obj.fieldType=fieldType;
	obj.listNumber=listNumber;
	[self.cellObjArray addObject:obj];
}

-(BOOL)showThisEntry {
	return (![ObjectiveCScripts isStartupCompleted] || !self.managedObj);
}

-(void)setupData {
	[self.cellObjArray removeAllObjects];
	
	NSString *statement_day = (self.itemObject.statement_day.length==0)?@"15":self.itemObject.statement_day;
	switch (self.type) {
  case 0: // profile
			self.topDescLabel.text = @"Profile: This is your basic financial information.";
			if(self.sub_type==0) {
			[self insertObjectWithTitle:@"emergency_fund" desc:@"Approx how much is left in your bank account this month after paying bills? We will call this your 'Emergency Fund'." value:self.profileObj.emergency_fund flag:@"N" fieldType:1 listNumber:0];
			[self insertObjectWithTitle:@"retirement_payments" desc:@"Are you paying into retirement? If so, approx how much per month are you putting into retirement accounts?" value:self.profileObj.retirement_payments flag:@"N" fieldType:1 listNumber:0];
			[self insertObjectWithTitle:@"age" desc:@"What is your age? (This is only needed to calculate your projected retirement analysis)." value:self.profileObj.age flag:@"N" fieldType:2 listNumber:0];
			} else {
				[self insertObjectWithTitle:@"monthly_rent" desc:@"What do you pay per month in rent?" value:self.profileObj.monthly_rent flag:@"N" fieldType:1 listNumber:0];
			}
			break;
  case 1: // real estate
			self.topDescLabel.text = @"Real Estate: Enter information related to this property.";
			[self insertObjectWithTitle:@"name" desc:@"Choose a nickname for this property. It can be anything. Enter 'Home' if nothing else." value:self.itemObject.name flag:@"N" fieldType:0 listNumber:0];
			
			if([self showThisEntry]) {
				[self insertObjectWithTitle:@"value" desc:@"Approx what is your home currently worth? (Check zillow.com)" value:self.itemObject.valueStr flag:@"N" fieldType:1 listNumber:0];
				[self insertObjectWithTitle:@"loan_balance" desc:@"Approx what is your current balance on the home loan?" value:self.itemObject.loan_balance flag:@"N" fieldType:1 listNumber:0];
			}
			[self insertObjectWithTitle:@"interest_rate" desc:@"What interest rate on the home loan?" value:self.itemObject.interest_rate flag:@"N" fieldType:3 listNumber:0];
			[self insertObjectWithTitle:@"monthly_payment" desc:@"What is your monthly payment?" value:self.itemObject.monthly_payment flag:@"N" fieldType:1 listNumber:0];
			[self insertObjectWithTitle:@"homeowner_dues" desc:@"What is your monthly payment for condo/homeowner fees?" value:self.itemObject.homeowner_dues flag:@"Y" fieldType:1 listNumber:0];
			[self insertObjectWithTitle:@"statement_day" desc:@"What day of the month does your statement arrive?" value:statement_day flag:@"Y" fieldType:2 listNumber:0];
			
//			[self checkFieldsForTag:2 value:self.itemObject.loan_balance];
			break;
  case 2: // vehicles
			self.topDescLabel.text = @"Vehicle: Enter information related to this vehicle.";
			[self insertObjectWithTitle:@"name" desc:@"Enter a name. Can be anything. Ex: Ford Explorer" value:self.itemObject.name flag:@"N" fieldType:0 listNumber:0];
			if([self showThisEntry]) {
				[self insertObjectWithTitle:@"loan_balance" desc:@"What is the current Loan balance? (approx amount if you don't know for sure)" value:self.itemObject.loan_balance flag:@"N" fieldType:1 listNumber:0];
			}
			[self insertObjectWithTitle:@"payment_type" desc:@"Own and paid for, Finance or Lease?" value:self.itemObject.payment_type flag:@"N" fieldType:0 listNumber:2];
			BOOL carHasBalance=YES;
			if(self.itemObject && [@"Own outright" isEqualToString:self.itemObject.payment_type])
				carHasBalance=NO;
			
			if(carHasBalance) {
				[self insertObjectWithTitle:@"interest_rate" desc:@"What is the interest Rate?" value:self.itemObject.interest_rate flag:@"N" fieldType:3 listNumber:0];
				[self insertObjectWithTitle:@"monthly_payment" desc:@"What is your current monthly payment?" value:self.itemObject.monthly_payment flag:@"N" fieldType:1 listNumber:0];
			}
			[self insertObjectWithTitle:@"statement_day" desc:@"What day of the month does your statement arrive?" value:statement_day flag:@"Y" fieldType:2 listNumber:0];
			if([self showThisEntry])
				[self insertObjectWithTitle:@"value" desc:@"What is the approx value of this vehicle? (Check kelly blue book)" value:self.itemObject.valueStr flag:@"N" fieldType:1 listNumber:0];
			[self checkFieldsForTag:1 value:self.itemObject.payment_type];

			break;
			
  case 3: // debts
			self.topDescLabel.text = @"Debt: Enter information related to this debt.";
			[self insertObjectWithTitle:@"name" desc:@"Enter a name. Can be anything. Ex: Visa, Student Loan, etc" value:self.itemObject.name flag:@"N" fieldType:0 listNumber:0];
			if([self showThisEntry])
				[self insertObjectWithTitle:@"loan_balance" desc:@"What is the current Loan balance? (approx amount if you don't know for sure)" value:self.itemObject.loan_balance flag:@"N" fieldType:1 listNumber:0];
			[self insertObjectWithTitle:@"interest_rate" desc:@"What is the interest Rate?" value:self.itemObject.interest_rate flag:@"N" fieldType:3 listNumber:0];
			[self insertObjectWithTitle:@"statement_day" desc:@"What day of the month does your statement arrive?" value:statement_day flag:@"Y" fieldType:2 listNumber:0];
			
			break;
  case 4: // assets
			self.topDescLabel.text = @"Asset: Enter information related to this asset.";
			[self insertObjectWithTitle:@"name" desc:@"Enter a name. Can be anything. Ex: 401k, Stocks, etc" value:self.itemObject.name flag:@"N" fieldType:0 listNumber:0];
			if([self showThisEntry])
				[self insertObjectWithTitle:@"value" desc:@"What is the current dollar value?" value:self.itemObject.valueStr flag:@"N" fieldType:1 listNumber:0];
			[self insertObjectWithTitle:@"monthly_payment" desc:@"Monthly contributions to this account" value:self.itemObject.monthly_payment flag:@"N" fieldType:1 listNumber:0];
			[self insertObjectWithTitle:@"statement_day" desc:@"What day of the month does your statement arrive?" value:statement_day flag:@"Y" fieldType:2 listNumber:0];
			
			break;
			
  default:
			break;
	}
}



-(void)doneButtonPressed {
	if([self isCompleted]) {
		if(self.type==0)
			[self updateProfile];
		else
			[self createNewItem];
		
		[self.navigationController popViewControllerAnimated:YES];
	} else
		[ObjectiveCScripts showAlertPopup:@"Update all fields first" message:@""];
}

-(BOOL)isCompleted {
	for (ItemCellObj *obj in self.cellObjArray)
		if ([@"N" isEqualToString:obj.flag])
			return NO;
	return YES;
}

-(void)createNewItem {
	if(self.managedObj) {
		[self updateDatabaseRecord:self.managedObj];
		self.itemObject = [ObjectiveCScripts itemObjectFromManagedObject:self.managedObj moc:self.managedObjectContext];
	} else {
		[self insertObjectWithTitle:@"rowId" desc:@"" value:[CoreDataLib autoIncrementNumber] flag:@"N" fieldType:2 listNumber:0];
		[self insertObjectWithTitle:@"type" desc:@"" value:[ObjectiveCScripts typeFromSubType:self.sub_type] flag:@"N" fieldType:0 listNumber:0];
		[self insertObjectWithTitle:@"sub_type" desc:@"" value:[ObjectiveCScripts subTypeForNumber:self.sub_type] flag:@"N" fieldType:0 listNumber:0];
		
		NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:@"ITEM" inManagedObjectContext:self.managedObjectContext];
		[self updateDatabaseRecord:mo];
		self.itemObject = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
	}
	int nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	[CoreDataLib updateItemAmount:self.itemObject type:0 month:nowMonth year:nowYear currentFlg:YES amount:[self.itemObject.valueStr doubleValue] moc:self.managedObjectContext];
	[CoreDataLib updateItemAmount:self.itemObject type:1 month:nowMonth year:nowYear currentFlg:YES amount:[self.itemObject.loan_balance doubleValue] moc:self.managedObjectContext];
	
	if([@"Asset" isEqualToString:self.itemObject.type] && [@"Emergency Fund" isEqualToString:self.itemObject.name]) {
		int amount = [self.itemObject.valueStr intValue];
		NSArray *items = [CoreDataLib selectRowsFromTable:@"PROFILE" mOC:self.managedObjectContext];
		if(items.count>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			[mo setValue:[NSNumber numberWithInt:amount] forKey:@"emergency_fund"];
			[self.managedObjectContext save:nil];
		}
	}
	
}



-(void)updateProfile {
	NSArray *items = [CoreDataLib selectRowsFromTable:@"PROFILE" mOC:self.managedObjectContext];
	if(items.count>0) {
		NSManagedObject *mo = [items objectAtIndex:0];
		[self updateDatabaseRecord:mo];
		
		int age = [[mo valueForKey:@"age"] intValue];
		int year = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
		int yearBorn = year-age;
		[mo setValue:[NSNumber numberWithInt:yearBorn] forKey:@"yearBorn"];
		[self.managedObjectContext save:nil];

		if(self.sub_type==0)
			[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"profileFlg"];
		if(self.sub_type==1)
			[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"housingFlg"];
		
//		double annual_income = [CoreDataLib getNumberFromProfile:@"annual_income" mOC:self.managedObjectContext];
//		[ObjectiveCScripts updateSalary:annual_income year:year context:self.managedObjectContext];
		
		int emergencyFund = [[mo valueForKey:@"emergency_fund"] intValue];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = 'Asset' AND name = 'Emergency Fund'"];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		if(items.count>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			[mo setValue:[NSNumber numberWithInt:emergencyFund] forKey:@"value"];
			[self.managedObjectContext save:nil];
		} else {
			NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:@"ITEM" inManagedObjectContext:self.managedObjectContext];
			[mo setValue:[NSNumber numberWithInt:[[CoreDataLib autoIncrementNumber] intValue]] forKey:@"rowId"];
			[mo setValue:@"Asset" forKey:@"type"];
			[mo setValue:@"Bank Account" forKey:@"sub_type"];
			[mo setValue:@"Emergency Fund" forKey:@"name"];
			[mo setValue:[NSNumber numberWithInt:emergencyFund] forKey:@"value"];
			[self.managedObjectContext save:nil];
			int nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
			int nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
			self.itemObject = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
			[CoreDataLib updateItemAmount:self.itemObject type:0 month:nowMonth year:nowYear currentFlg:YES amount:self.itemObject.value  moc:self.managedObjectContext];
			[CoreDataLib updateItemAmount:self.itemObject type:1 month:nowMonth year:nowYear currentFlg:YES amount:[self.itemObject.loan_balance doubleValue] moc:self.managedObjectContext];
		}

	}
}

-(void)updateDatabaseRecord:(NSManagedObject *)record {
	NSMutableArray *keys = [[NSMutableArray alloc] init];
	NSMutableArray *values = [[NSMutableArray alloc] init];
	NSMutableArray *types = [[NSMutableArray alloc] init];
	
	for (ItemCellObj *obj in self.cellObjArray) {
		[keys addObject:obj.title];
		[values addObject:obj.value];
		[types addObject:[ObjectiveCScripts typeFromFieldType:obj.fieldType]];
		NSLog(@"%@ = %@", obj.title, obj.value);
	}
	[CoreDataLib updateManagedObject:record keyList:keys valueList:values typeList:types mOC:self.managedObjectContext];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	MoneyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[MoneyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	cell.backgroundColor=[UIColor clearColor];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	ItemCellObj *obj = [self.cellObjArray objectAtIndex:indexPath.row];
	
	cell.updateButton.hidden=YES;
	cell.updateButton.tag = indexPath.row;
	[cell.updateButton addTarget:self
						  action:@selector(updateButtonClicked:)
				forControlEvents:UIControlEventTouchUpInside];
	
	cell.titleLabel.text = [[obj.title stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
	
	if(obj.fieldType==1)
		cell.amountLabel.text = [ObjectiveCScripts convertNumberToMoneyString:[obj.value doubleValue]];
	else if(obj.fieldType==2)
		cell.amountLabel.text = [NSString stringWithFormat:@"%d", [obj.value intValue]];
	else if(obj.fieldType==3)
		cell.amountLabel.text = [NSString stringWithFormat:@"%@%%", obj.value];
	else
		cell.amountLabel.text = obj.value;
	
	if([@"Y" isEqualToString:obj.flag])
		cell.statusImage.image = [UIImage imageNamed:@"green.png"];
	else
		cell.statusImage.image = [UIImage imageNamed:@"red.png"];
	
	cell.descLabel.text = obj.desc;
	return cell;
}



-(void)updateButtonClicked:(UIButton *)button {
	self.tagSelected = (int)button.tag;
	[self updateRowItem];
}

-(void)updateRowItem {
	self.stuffChangedFlg=YES;
	
	if(![@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"assetsFlg"]])
		self.cancelButton.enabled=NO;
	ItemCellObj *obj = [self.cellObjArray objectAtIndex:self.tagSelected];
	if([@"Emergency Fund" isEqualToString:obj.value]) {
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"You cannot change this field."];
		return;
	}
	
	if(obj.listNumber>0) {
		SelectListVC *detailViewController = [[SelectListVC alloc] initWithNibName:@"SelectListVC" bundle:nil];
		detailViewController.callbackController=self;
		detailViewController.titleString=obj.desc;
		detailViewController.listNumber=obj.listNumber;
		[self.navigationController pushViewController:detailViewController animated:YES];
	} else {
		EnterValueVC *detailViewController = [[EnterValueVC alloc] initWithNibName:@"EnterValueVC" bundle:nil];
		detailViewController.callbackController=self;
		detailViewController.cellObject = [self.cellObjArray objectAtIndex:self.tagSelected];
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(void)updateValue:(NSString *)value {
	ItemCellObj *obj = [self.cellObjArray objectAtIndex:self.tagSelected];
	
	if(self.type==2) { // vehicle
		ItemCellObj *balanceObj = [self.cellObjArray objectAtIndex:1];
		double amountVal = [balanceObj.value intValue];
		if([@"Own outright" isEqualToString:value] && amountVal>0) {
			[ObjectiveCScripts showAlertPopup:@"Error" message:@"You cannot 'Own outright' if there is a balance."];
			return;
		}
		if([@"Financing" isEqualToString:value] && self.cellObjArray.count<6) {
			[self setupData];
			[self.mainTableView reloadData];
			[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Resetting form after changing to 'Financing'. Please begin again."];
			return;
		}
		
	}
//	NSLog(@"+++ %d %d %f", self.type, self.tagSelected, [ObjectiveCScripts convertMoneyStringToDouble:value]);
	if(self.type==1 && self.tagSelected==2 && [ObjectiveCScripts convertMoneyStringToDouble:value]>0 && self.cellObjArray.count<6) { // realestate
		[self setupData];
		[self.mainTableView reloadData];
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Resetting form after changing balance. Please begin again."];
		return;
	}
	
	if(obj.fieldType==1)
		value = [NSString stringWithFormat:@"%d", (int)[ObjectiveCScripts convertMoneyStringToDouble:value]];

	obj.value = value;
	
	if([@"statement_day" isEqualToString:obj.title] && [value intValue]>30)
		obj.value = @"30";
	
	obj.flag=@"Y";


	[self checkFieldsForTag:self.tagSelected value:value];
	
	[self.mainTableView reloadData];
}

-(void)checkFieldsForTag:(int)tag value:(NSString *)value {
	if(self.type==1 && tag==2 && [value intValue]==0 && self.cellObjArray.count>6) { // real estate
		[self.cellObjArray removeObjectAtIndex:6];
		[self.cellObjArray removeObjectAtIndex:4];
		[self.cellObjArray removeObjectAtIndex:3];
	}
	if(self.type==2 && tag==2 && [@"Own outright" isEqualToString:value] && self.cellObjArray.count>5) { //vehicle
		[self.cellObjArray removeObjectAtIndex:4];
		[self.cellObjArray removeObjectAtIndex:3];
		[self.cellObjArray removeObjectAtIndex:1];
	}
	if(self.type==2 && tag==2 && [@"Leasing" isEqualToString:value] && self.cellObjArray.count>6) {  //vehicle
		[self.cellObjArray removeObjectAtIndex:6];
		[self.cellObjArray removeObjectAtIndex:5];
		[self.cellObjArray removeObjectAtIndex:3];
		[self.cellObjArray removeObjectAtIndex:1];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.cellObjArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.tagSelected = (int)indexPath.row;
	[self updateRowItem];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 130;
}

-(IBAction)deleteButtonClicked:(id)sender {
	[ObjectiveCScripts showConfirmationPopup:@"WARNING!!!" message:@"Deleting this record is permanant! There will be no history of this record and you can not restore it!" delegate:self tag:1];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag==1 && buttonIndex != [alertView cancelButtonIndex]) {
		int rowId = [self.itemObject.rowId intValue];
		if (self.managedObj && rowId>0) {
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item_id = %d", rowId];
			NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
			NSLog(@"Delete it! %d (%d rows)", rowId, (int)items.count);
			for(NSManagedObject *mo in items) {
				[self.managedObjectContext deleteObject:mo];
			}
			[self.managedObjectContext deleteObject:self.managedObj];
			[self.managedObjectContext save:nil];
			MainMenuVC *detailViewController = [[MainMenuVC alloc] initWithNibName:@"MainMenuVC" bundle:nil];
			detailViewController.managedObjectContext = self.managedObjectContext;
			[self.navigationController pushViewController:detailViewController animated:YES];
		}
	}
	if(alertView.tag==5 && buttonIndex != [alertView cancelButtonIndex]) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

@end

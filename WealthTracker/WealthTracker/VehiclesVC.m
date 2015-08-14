//
//  VehiclesVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/11/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "VehiclesVC.h"
#import "StartupVC.h"
#import "ObjectiveCScripts.h"
#import "EditItemVC.h"
#import "ItemCell.h"
#import "ItemObject.h"
#import "CoreDataLib.h"

@interface VehiclesVC ()

@end

@implementation VehiclesVC


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"type = %@", [ObjectiveCScripts typeNameForType:self.type]];

	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:@"name" mOC:self.managedObjectContext ascendingFlg:NO];
	
	[self.itemArray removeAllObjects];
	[self.managedObjArray removeAllObjects];
	
	for (NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:self.managedObjectContext];
		[self.managedObjArray addObject:mo];
		[self.itemArray addObject:obj];
	}
	
	if(self.vehicleStepper.value < items.count)
		self.vehicleStepper.value = items.count;
	self.vehicleStepper.minimumValue = items.count;
	self.countLabel.text = [NSString stringWithFormat:@"%d", (int)self.vehicleStepper.value];
	
	if(items.count>0)
		[self.mainTableView reloadData];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.itemArray = [[NSMutableArray alloc] init];
	self.managedObjArray = [[NSMutableArray alloc] init];
	
	[self setTitle:[ObjectiveCScripts typeNameForType:self.type]];

	self.testLabel.hidden = (kTestMode)?NO:YES;

	if(![@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"assetsFlg"]]) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	} else {
		self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
		
		self.navigationItem.leftBarButtonItem = self.cancelButton;
	}
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finished" style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed)];
	
	switch (self.type) {
  case 1:
			self.titleLabel.text = @"Number of properties";
			self.descLabel.text = @"Total number of properties owned.";
			break;
  case 2:
			self.titleLabel.text = @"Number of vehicles owned";
			self.descLabel.text = @"Total number of all vehicles: Cars, motor-cycles, boats, RVs, anything with a motor.";
			break;
  case 3:
			self.titleLabel.text = @"Number of loans";
			self.descLabel.text = @"Total number of all credit cards or loans with balances (other than real estate and vehicles).";
			break;
  case 4:
			self.titleLabel.text = @"Number of assets";
			self.descLabel.text = @"Total number of investment accounts (401k, retirement, stocks, valuable art, rental property).";
			break;
			
  default:
			break;
	}

}

-(void)cancelButtonPressed {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)doneButtonPressed {
	if([self isCompleted]) {
		if(self.type==1)
			[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"housingFlg"];
		if(self.type==2)
			[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"vehiclesFlg"];
		if(self.type==3)
			[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"debtsFlg"];
		if(self.type==4)
			[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"assetsFlg"];
		
		[self.navigationController popViewControllerAnimated:YES];
	} else
		[ObjectiveCScripts showAlertPopup:@"Update all fields first" message:@""];
}

-(BOOL)isCompleted {
	if(self.itemArray.count==self.vehicleStepper.value)
		return YES;
	else
		return NO;
}

-(IBAction)stepperClicked:(id)sender {
	self.countLabel.text = [NSString stringWithFormat:@"%d", (int)self.vehicleStepper.value];
	[self.mainTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[ItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	if(indexPath.row<self.itemArray.count) {
		ItemObject *obj = [self.itemArray objectAtIndex:indexPath.row];
		cell.nameLabel.text=obj.name;
		if([obj.value doubleValue]>0)
			cell.amountLabel.text = [ObjectiveCScripts convertNumberToMoneyString:[obj.value doubleValue]];
		else
			cell.amountLabel.text = [ObjectiveCScripts convertNumberToMoneyString:[obj.loan_balance doubleValue]];
		cell.subTypeLabel.text = obj.sub_type;
		cell.last30Label.text = @"";
		cell.statement_dayLabel.text = obj.statement_day;
		cell.valStatusImage.image=[UIImage imageNamed:@"green.png"];
		cell.balStatusImage.image=[UIImage imageNamed:@"green.png"];
	} else {
		cell.nameLabel.text=[NSString stringWithFormat:@"%@ #%d", [ObjectiveCScripts typeNameForType:self.type], (int)indexPath.row+1];
		cell.amountLabel.text = @"";
		cell.subTypeLabel.text = @"";
		cell.last30Label.text = @"";
		cell.statement_dayLabel.text = @"";
		cell.valStatusImage.image=[UIImage imageNamed:@"red.png"];
		cell.balStatusImage.image=[UIImage imageNamed:@"red.png"];
	}
	
	cell.typeImageView.image = [ObjectiveCScripts imageIconForType:[ObjectiveCScripts typeNameForType:self.type]];
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (int)self.vehicleStepper.value;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedRow = (int)indexPath.row;
	self.cancelButton.enabled=NO;
	
	if(self.selectedRow < self.itemArray.count) {
		[self gotoItemDetailView];
		return;
	}
	switch (self.type) {
  case 1: {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select this Property type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Primary Residence", @"Rental", @"Other Property", nil];
			[actionSheet showInView:self.view];
  }
			break;
  case 2: {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select this Vehicle type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Auto", @"Motorcycle", @"RV", @"ATV", @"Jet Ski", @"Snomobile", @"Other", nil];
			[actionSheet showInView:self.view];
  }
			break;
  case 3: {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select this Debt type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Credit Card", @"Student Loan", @"Loan", @"Medical", nil];
			[actionSheet showInView:self.view];
  }
			break;
  case 4: {
	  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select this Asset type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"401k", @"Retirement", @"Stocks", @"College Fund", @"Bank Account", @"Other Asset", nil];
			[actionSheet showInView:self.view];
  }
			break;
			
  default:
			break;
	}
	
}

-(void)gotoItemDetailView {
	EditItemVC *detailViewController = [[EditItemVC alloc] initWithNibName:@"EditItemVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.callbackController=self;
	detailViewController.type=self.type;
	detailViewController.sub_type=self.sub_type;
	if(self.selectedRow < self.itemArray.count) {
		detailViewController.itemObject = [self.itemArray objectAtIndex:self.selectedRow];
		detailViewController.managedObj = [self.managedObjArray objectAtIndex:self.selectedRow];
	} else {
		detailViewController.itemObject = nil;
		detailViewController.managedObj = nil;
	}
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [actionSheet cancelButtonIndex]) {
		switch (self.type) {
			case 1:
    self.sub_type = (int)buttonIndex+2;
    break;
			case 2:
    self.sub_type = (int)buttonIndex+5;
    break;
			case 3:
    self.sub_type = (int)buttonIndex+12;
    break;
			case 4:
    self.sub_type = (int)buttonIndex+16;
    break;
				
			default:
    break;
		}
		[self gotoItemDetailView];
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

@end

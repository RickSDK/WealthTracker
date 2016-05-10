//
//  ItemTemplateVC.m
//  BalanceApp
//
//  Created by Rick Medved on 4/9/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "ItemTemplateVC.h"
#import "CashFlowObj.h"
#import "CoreDataLib.h"
#import "NSDate+ATTDate.h"
#import "CashFlowCell.h"
#import "CashFlowVC.h"

@interface ItemTemplateVC ()

@end

@implementation ItemTemplateVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.amountsArray = [[NSMutableArray alloc] init];
	self.totalAmountLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.totalAmount];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createPressed)];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.multiplyer = (self.itemType==1)?1:-1;

	[self displayItems];
}


-(void)displayItems {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"amount < 0"];
	if(self.itemType==1)
		predicate = [NSPredicate predicateWithFormat:@"amount >= 0"];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CASH_FLOW" predicate:predicate sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	[self.itemsArray removeAllObjects];
	[self.amountsArray removeAllObjects];

	self.numberChecked = 0;
	self.totalAmount = 0;
	for (NSManagedObject *mo in items) {
		CashFlowObj *obj = [CashFlowObj objFromMO:mo context:self.managedObjectContext];

		if(self.clearChecks && obj.confirmFlg) {
			obj.confirmFlg=NO;
			[mo setValue:[NSNumber numberWithBool:NO] forKey:@"confirmFlg"];
		}
		if(obj.confirmFlg)
			self.numberChecked++;
		
		self.totalAmount += obj.amount*self.multiplyer;
		[self.amountsArray addObject:[NSString stringWithFormat:@"%f", obj.amount]];

		[self.itemsArray addObject:obj];

	}
	if(self.clearChecks) {
		self.clearChecks=NO;
		[self.managedObjectContext save:nil];
	}
	self.monthButton.hidden = (self.numberChecked<self.itemsArray.count || self.itemsArray.count==0);
	self.messageLabel.hidden=self.itemsArray.count>0;

	self.totalAmountLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.totalAmount];

	[self populateGraph];
}

-(void)createPressed {
	self.doneButton.hidden=YES;
	self.editingFlg=NO;
	self.deleteButton.enabled=NO;
	self.deleteButton.hidden=YES;
	NSLog(@"self.deleteButton.hidden=YES");

	self.amountTextField.text = @"";
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select the debt type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Credit Card", @"Student Loan", @"Primary Residence", @"Rental Property", @"Vehicle", @"Other", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [actionSheet cancelButtonIndex]) {
		NSArray *titles = [NSArray arrayWithObjects:@"Credit Card", @"Student Loan", @"Primary Residence", @"Rental Property", @"Vehicle", @"Other", nil];
		self.nameTextField.text = [titles objectAtIndex:buttonIndex];
		self.popupView.hidden=NO;
		[self.amountTextField becomeFirstResponder];
		self.selectedType=(int)buttonIndex;
	}
}



-(IBAction)submitButtonClicked:(id)sender {
	self.popupView.hidden=YES;
	if(self.editingFlg) {
		
		CashFlowObj *debtObj = [self.itemsArray objectAtIndex:self.selectedRow];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", debtObj.name];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"CASH_FLOW" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		if(items.count>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			[mo setValue:self.nameTextField.text forKey:@"name"];
			[mo setValue:[NSNumber numberWithDouble:[self.amountTextField.text doubleValue]*self.multiplyer] forKey:@"amount"];
			[mo setValue:[NSNumber numberWithInt:[self.dueDateField.text intValue]] forKey:@"statement_day"];
		}

	} else {
		NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:@"CASH_FLOW" inManagedObjectContext:self.managedObjectContext];

		[mo setValue:[NSNumber numberWithInt:self.selectedType] forKey:@"type"];
		[mo setValue:self.nameTextField.text forKey:@"name"];
		[mo setValue:[NSNumber numberWithDouble:[self.amountTextField.text doubleValue]*self.multiplyer] forKey:@"amount"];
		[mo setValue:[NSNumber numberWithInt:[self.dueDateField.text intValue]] forKey:@"statement_day"];
	}
	
	
	[self.nameTextField resignFirstResponder];
	[self.amountTextField resignFirstResponder];
	[self.dueDateField resignFirstResponder];
	[self.managedObjectContext save:nil];
	[self displayItems];
}

-(void)populateGraph {
	[self.mainTableView reloadData];
}

-(IBAction)doneButtonClicked:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)listCellForIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	CashFlowCell *cell = [[CashFlowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	CashFlowObj *obj = [CashFlowObj objFromMO:[self.itemsArray objectAtIndex:indexPath.row] context:self.managedObjectContext];
	[CashFlowCell populateCell:cell obj:obj];

	cell.checkMarkButton.tag=indexPath.row;
	[cell.checkMarkButton addTarget:self action:@selector(checkMarkPressed:) forControlEvents:UIControlEventTouchDown];
	
	double amountRemaining = [[self.amountsArray objectAtIndex:indexPath.row] doubleValue];
	cell.amountRemainingLabel.text = [NSString stringWithFormat:@"(%@)", [ObjectiveCScripts convertNumberToMoneyString:amountRemaining]];
	cell.amountRemainingLabel.textColor = [ObjectiveCScripts colorBasedOnNumber:amountRemaining lightFlg:NO];
	cell.amountRemainingLabel.hidden=YES;
	
	return cell;
}

-(void)checkMarkPressed:(UIButton *)sender {
	CashFlowObj *obj = [self.itemsArray objectAtIndex:sender.tag];
	NSManagedObject *mo = [self moFromName:obj.name];
	BOOL  confirmFlg = [[mo valueForKey:@"confirmFlg"] boolValue];
	[mo setValue:[NSNumber numberWithBool:!confirmFlg] forKey:@"confirmFlg"];
	[self.managedObjectContext save:nil];
	[self displayItems];
}

-(NSManagedObject *)moFromName:(NSString *)name {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CASH_FLOW" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	if(items.count>0)
		return [items objectAtIndex:0];
	else
		return nil;
	
}

-(void)rightButtonPressed:(UIButton *)button {
	CashFlowObj *obj = [self.itemsArray objectAtIndex:(int)button.tag];
	if(obj.confirmFlg)
		self.numberChecked--;
	else
		self.numberChecked++;
	self.monthButton.hidden = self.numberChecked<self.itemsArray.count;

	obj.confirmFlg = !obj.confirmFlg;
	[self.itemsArray replaceObjectAtIndex:(int)button.tag withObject:obj];
	
	if(self.itemType==0 || self.itemType==1) {
		self.selectedRow=(int)button.tag;
		[self showPopup];
		return;
	}
	
	NSManagedObject *mo = [self moFromName:obj.name];
	
	[mo setValue:[NSNumber numberWithBool:obj.confirmFlg] forKey:@"confirmFlg"];
	
	[self.managedObjectContext save:nil];
	
	
	[self.mainTableView reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.deleteButton.enabled=YES;
	self.deleteButton.hidden=NO;
	NSLog(@"self.deleteButton.hidden=NO");
	self.selectedRow=(int)indexPath.row;
	[self showPopup];
}

-(void)showPopup {
	self.editingFlg=YES;
	CashFlowObj *debtObj = [self.itemsArray objectAtIndex:self.selectedRow];
	NSLog(@"showPopup: %d m: %d debtObj.amount %f", debtObj.statement_day, self.multiplyer, debtObj.amount);
	self.popupView.hidden=NO;
	self.doneButton.hidden=YES;
	
	

	self.nameTextField.text = debtObj.name;
	self.dueDateField.text = [NSString stringWithFormat:@"%d", debtObj.statement_day];
	if(round(debtObj.amount)==debtObj.amount)
		self.amountTextField.text = [NSString stringWithFormat:@"%d", (int)debtObj.amount*self.multiplyer];
	else
		self.amountTextField.text = [NSString stringWithFormat:@"%.02f", debtObj.amount*self.multiplyer];
}

-(IBAction)deleteButtonClicked:(id)sender {
	[ObjectiveCScripts showConfirmationPopup:@"Delete this record?" message:@"" delegate:self tag:1];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag==1 && buttonIndex != alertView.cancelButtonIndex) {
		CashFlowObj *debtObj = [self.itemsArray objectAtIndex:self.selectedRow];
		
		self.popupView.hidden=YES;
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", debtObj.name];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"CASH_FLOW" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		if(items.count>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			[self.managedObjectContext deleteObject:mo];


			[self.managedObjectContext save:nil];
		}
		[self displayItems];
		
	}
}

-(IBAction)newMonthButtonClicked:(id)sender {
	self.clearChecks=YES;
	[self displayItems];
}

-(IBAction)cashFlowButtonClicked:(id)sender {
	CashFlowVC *detailViewController = [[CashFlowVC alloc] initWithNibName:@"CashFlowVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}



@end

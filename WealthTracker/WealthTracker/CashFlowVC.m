//
//  CashFlowVC.m
//  WealthTracker
//
//  Created by Rick Medved on 8/3/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "CashFlowVC.h"
#import "CashFlowEditItemVC.h"
#import "ObjectiveCScripts.h"
#import "CoreDataLib.h"
#import "CashFlowCell.h"
#import "CashFlowObj.h"

@interface CashFlowVC ()

@end

@implementation CashFlowVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	[self setupData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Cash Flow"];
	
	self.amountsArray = [[NSMutableArray alloc] init];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];
}

-(void)setupData {
	double amountRemaining = [CoreDataLib getNumberFromProfile:@"bankAccount" mOC:self.managedObjectContext];
	self.amountTextField.text = [ObjectiveCScripts convertNumberToMoneyString:amountRemaining];
	self.fetchIsReady=NO;
	
	[self.amountsArray removeAllObjects];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CASH_FLOW" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	double minimum=100000;
	for(NSManagedObject *mo in items) {
		if(![[mo valueForKey:@"confirmFlg"] boolValue])
			amountRemaining+=[[mo valueForKey:@"amount"] doubleValue];
		if(amountRemaining<minimum)
			minimum=amountRemaining;
		[self.amountsArray addObject:[NSString stringWithFormat:@"%f", amountRemaining]];
	}
	for(NSManagedObject *mo in items) { // now check into next month as well
		amountRemaining+=[[mo valueForKey:@"amount"] doubleValue];
		if(amountRemaining<minimum)
			minimum=amountRemaining;
	}
	double emergency = [ObjectiveCScripts emergencyFundWithContext:self.managedObjectContext];
	minimum -= emergency;
	if(minimum+emergency<0)
		self.surplusLabel.text = [ObjectiveCScripts convertNumberToMoneyString:minimum];
	else if(minimum<0)
		self.surplusLabel.text = [NSString stringWithFormat:@"$0 (%@ emergency)", [ObjectiveCScripts convertNumberToMoneyString:minimum+emergency]];
	else
		self.surplusLabel.text = [NSString stringWithFormat:@"%@ (+%@)", [ObjectiveCScripts convertNumberToMoneyString:minimum], [ObjectiveCScripts convertNumberToMoneyString:emergency]];
	self.surplusLabel.textColor = [ObjectiveCScripts colorBasedOnNumber:minimum lightFlg:YES];
	
	[self.mainTableView reloadData];
	
	if(self.amountTextField.text.length<3)
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"How much money is currently in your bank account? Enter that number in the bank account field."];
	else if(minimum+emergency<0)
		[ObjectiveCScripts showAlertPopup:@"Notice!!" message:@"You are in danger of overdrawing your account!"];
	
	[self.mainTableView reloadData];
}

-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if([@"|" isEqualToString:string])
		return NO;
	if(textFieldlocal.text.length>=20)
		return NO;
	
	if(string.length==0) // backspace
		return YES;
	if([@"." isEqualToString:string])
		return YES;
		NSString *value = [NSString stringWithFormat:@"%@%@", textFieldlocal.text, string];
		double amount = [ObjectiveCScripts convertMoneyStringToDouble:value];
		value = [ObjectiveCScripts convertNumberToMoneyString:amount];
		textFieldlocal.text = value;
		return NO;
}

- (IBAction) submitButtonPressed: (id) sender {
	[self.amountTextField resignFirstResponder];
	[CoreDataLib saveNumberToProfile:@"bankAccount" value:[ObjectiveCScripts convertMoneyStringToDouble:self.amountTextField.text] context:self.managedObjectContext];
	[self setupData];
}


-(void)addNewItem {
	CashFlowEditItemVC *detailViewController = [[CashFlowEditItemVC alloc] initWithNibName:@"CashFlowEditItemVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%d", (long)indexPath.section, (int)indexPath.row];
	CashFlowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil) {
		cell = [[CashFlowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

	NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	CashFlowObj *obj = [CashFlowObj objFromMO:mo context:self.managedObjectContext];
	[CashFlowCell populateCell:cell obj:obj];

	cell.checkMarkButton.tag=indexPath.row;
	[cell.checkMarkButton addTarget:self action:@selector(checkMarkPressed:) forControlEvents:UIControlEventTouchDown];

	double amountRemaining = [[self.amountsArray objectAtIndex:indexPath.row] doubleValue];
	cell.amountRemainingLabel.text = [NSString stringWithFormat:@"(%@)", [ObjectiveCScripts convertNumberToMoneyString:amountRemaining]];
	cell.amountRemainingLabel.textColor = [ObjectiveCScripts colorBasedOnNumber:amountRemaining lightFlg:NO];

	return cell;
}

-(void)checkMarkPressed:(UIButton *)sender {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
	NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if(mo) {
		BOOL  confirmFlg = [[mo valueForKey:@"confirmFlg"] boolValue];
		[mo setValue:[NSNumber numberWithBool:!confirmFlg] forKey:@"confirmFlg"];
		[self.managedObjectContext save:nil];
	}
	[self setupData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != nil && self.fetchIsReady) {
		return _fetchedResultsController;
	}
	self.fetchIsReady=YES;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"CASH_FLOW" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"statement_day" ascending:YES];
	NSArray *sortDescriptors = @[sortDescriptor];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	
//	[fetchRequest setPredicate:predicate];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
	aFetchedResultsController.delegate = self;
	
	[NSFetchedResultsController deleteCacheWithName:@"Master"];
	
	self.fetchedResultsController = aFetchedResultsController;
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		//		abort();
	}
	
	return _fetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
	return [sectionInfo numberOfObjects];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	CashFlowEditItemVC *detailViewController = [[CashFlowEditItemVC alloc] initWithNibName:@"CashFlowEditItemVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.managedObject = mo;
	detailViewController.cashFlowObj = [CashFlowObj objFromMO:mo context:self.managedObjectContext];
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (IBAction) newMonthButtonPressed: (id) sender {
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CASH_FLOW" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *mo in items) {
		if([[mo valueForKey:@"confirmFlg"] boolValue])
			[mo setValue:[NSNumber numberWithBool:NO] forKey:@"confirmFlg"];
	}
	[self setupData];
}

@end

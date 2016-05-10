//
//  StatsPageVC.m
//  BalanceApp
//
//  Created by Rick Medved on 3/30/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "StatsPageVC.h"
#import "PurchaseCell.h"
#import "ItemObject.h"
#import "NSDate+ATTDate.h"
#import "PurchaseObj.h"

@interface StatsPageVC ()

@end

@implementation StatsPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
	

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createPressed)];
	
	[self loadData];
	

	self.addItemButton.layer.borderColor = [UIColor grayColor].CGColor;
	self.addItemButton.layer.borderWidth = 1.;
	self.deleteButton.backgroundColor = [UIColor redColor];
	self.editDateButton.backgroundColor = [UIColor grayColor];
	
}

-(void)loadData {
	

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"month = %d AND year = %d AND bucket = %d", [ObjectiveCScripts nowMonth], [ObjectiveCScripts nowYear], self.bucket];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"PURCHASE" predicate:predicate sortColumn:@"dateStamp" mOC:self.managedObjectContext ascendingFlg:NO];
	
	self.totalSpent=0;
	[self.itemsArray removeAllObjects];
	for(NSManagedObject *mo in items) {
		PurchaseObj *item1 = [PurchaseObj objFromMO:mo];
		self.totalSpent += item1.amount;
		[self.itemsArray addObject:item1];
	}
	
	self.noEntriesLabel.hidden=self.itemsArray.count>0;
	self.addItemButton.hidden=self.itemsArray.count>0;
	
	

	int budget = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", self.bucket]] intValue];
	self.budgetLabel.text = [ObjectiveCScripts convertNumberToMoneyString:budget];
	
	self.totalSpentLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.totalSpent];
	self.remainingLabel.text = [NSString stringWithFormat:@"(%@ Remaining)", [ObjectiveCScripts convertNumberToMoneyString:budget-self.totalSpent]];
	if(self.totalSpent>budget)
		self.remainingLabel.text = [NSString stringWithFormat:@"(%@ Over Budget)", [ObjectiveCScripts convertNumberToMoneyString:self.totalSpent-budget]];
	[self setBarValue:budget-self.totalSpent max:budget];
	
	
	self.analysisStr = [self budgetAnalysis:[self.titles objectAtIndex:self.bucket] budget:budget spent:self.totalSpent];

	[self populateGraph];
	[self.mainTableView reloadData];
}

-(void)populateGraph {
	int year = [ObjectiveCScripts nowYear];
	int month = [ObjectiveCScripts nowMonth];
	year--;
	[self.graphObjects removeAllObjects];
	for(int i=1; i<=12; i++) {
		month++;
		if(month>12) {
			month=1;
			year++;
		}
		NSString *name = [NSString stringWithFormat:@"%@ %d", [ObjectiveCScripts monthNameForNum:month-1], year];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"month = %d AND year = %d AND bucket = %d", month, year, self.bucket];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"PURCHASE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		int value=0;
		BOOL displayFlg=NO;
		for(NSManagedObject *mo in items) {
			value += [[mo valueForKey:@"amount"] floatValue];
			displayFlg=YES;
		}
		if(displayFlg)
			[self.graphObjects addObject:[GraphLib graphObjectWithName:name amount:value rowId:1 reverseColorFlg:NO currentMonthFlg:NO]];
	}
	self.chartImageView.image = [GraphLib graphBarsWithItems:self.graphObjects];
}

-(void)setBarValue:(float)value max:(float)max {
	float percent = 0;
	if(max>0)
		percent = value/max;
	self.progressView.frame = CGRectMake(0, 0, self.screenWidth*percent, 20);
	self.progressView.backgroundColor = [UIColor greenColor];
	if(percent<=.5)
		self.progressView.backgroundColor = [UIColor yellowColor];
	if(percent<=.25)
		self.progressView.backgroundColor = [UIColor redColor];
	if(value<0) {
		self.progressView.frame = CGRectMake(0, 0, self.screenWidth, 20);
		self.progressView.backgroundColor = [UIColor orangeColor];
	}
}

-(IBAction)addItemButtonPressed:(id)sender {
	[self createPressed];
}

-(void)createPressed {
	self.popupView.hidden=NO;
	self.deleteButton.hidden=YES;
	self.editDateButton.hidden=YES;
	self.editingFlg=NO;
	NSArray *titles = [NSArray arrayWithObjects:@"Snack Purchase", @"Meal Purchase", @"Grocery Purchase", @"Shopping Purchase", @"Entertainment", @"Misc Purchase", nil];
	self.nameTextField.text = [titles objectAtIndex:self.bucket];
	self.amountTextField.text = @"";
	[self.amountTextField becomeFirstResponder];
}

-(IBAction)submitButtonPressed:(id)sender {
	if([self.amountTextField.text floatValue]==0) {
		[ObjectiveCScripts showAlertPopup:@"Enter Amount" message:@""];
		return;
	}
	[self.nameTextField resignFirstResponder];
	[self.amountTextField resignFirstResponder];
	self.popupView.hidden=YES;
	float oldValue=0;
	
	NSManagedObject *mo = nil;
	if(self.editingFlg) {
		PurchaseObj *item = [self.itemsArray objectAtIndex:self.selectedRecord];
		oldValue=item.amount;
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"purchaseId = %d", item.purchaseId];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"PURCHASE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		if(items.count>0) {
			mo = [items objectAtIndex:0];
		}
		
	} else {
		mo = [NSEntityDescription insertNewObjectForEntityForName:@"PURCHASE" inManagedObjectContext:self.managedObjectContext];
		int itemId = [ObjectiveCScripts autoIncrementNumber];
		[mo setValue:[NSNumber numberWithInt:itemId] forKey:@"purchaseId"];
		[mo setValue:[NSNumber numberWithInt:self.bucket] forKey:@"bucket"];
		[mo setValue:[NSDate date] forKey:@"dateStamp"];
		[mo setValue:[NSNumber numberWithInt:[ObjectiveCScripts nowMonth]] forKey:@"month"];
		[mo setValue:[NSNumber numberWithInt:[ObjectiveCScripts nowYear]] forKey:@"year"];
	}

	float newAmount = [self.amountTextField.text floatValue];
	[mo setValue:[NSNumber numberWithFloat:newAmount] forKey:@"amount"];
	[mo setValue:self.nameTextField.text forKey:@"name"];
	[self.managedObjectContext save:nil];

	[self updateBankAccountBySubtracting:newAmount-oldValue];
	[self loadData];
}

-(void)updateBankAccountBySubtracting:(float)value {
	double amountRemaining = [CoreDataLib getNumberFromProfile:@"bankAccount" mOC:self.managedObjectContext];
	[CoreDataLib saveNumberToProfile:@"bankAccount" value:amountRemaining-value context:self.managedObjectContext];
}

-(NSArray *)titles {
	return [NSArray arrayWithObjects:@"Snacks", @"Meals", @"Groceries", @"Shopping", @"Entertainment", @"Misc", nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	if(self.topSegment.selectedSegmentIndex==0) {
		PurchaseCell *cell = [[PurchaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		PurchaseObj *item = [self.itemsArray objectAtIndex:indexPath.row];
		[PurchaseCell populateCell:cell obj:item];
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else if (self.topSegment.selectedSegmentIndex==1) {
		
		
		MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:1 labelProportion:0];
		
		cell.mainTitle = [self.titles objectAtIndex:self.bucket];
		int budget = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", self.bucket]] intValue];
		cell.alternateTitle = [ObjectiveCScripts convertNumberToMoneyString:budget];
		
		
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
			
			cell.mainTitle = [self.titles objectAtIndex:self.bucket];
			int budget = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", self.bucket]] intValue];
			cell.alternateTitle = [ObjectiveCScripts convertNumberToMoneyString:budget];
			
			NSMutableArray *namesArray = [[NSMutableArray alloc] init];
			NSMutableArray *valuesArray = [[NSMutableArray alloc] init];
			NSMutableArray *colorsArray = [[NSMutableArray alloc] init];
			
			for(GraphObject *obj in self.graphObjects) {
				[namesArray addObject:obj.name];
				[valuesArray addObject:[ObjectiveCScripts convertNumberToMoneyString:obj.amount]];
				[colorsArray addObject:[UIColor blackColor]];
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




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.popupView.hidden=NO;
	self.deleteButton.enabled=YES;
	self.editDateButton.enabled=YES;
	self.deleteButton.hidden=NO;
	self.editDateButton.hidden=NO;
	self.editingFlg=YES;

	PurchaseObj *item = [self.itemsArray objectAtIndex:indexPath.row];
	self.selectedRecord = (int)indexPath.row;
	self.nameTextField.text = item.name;
	self.amountTextField.text = [NSString stringWithFormat:@"%.2f", item.amount];
}


-(IBAction)topSegmentChanged:(id)sender {
	[self.topSegment changeSegment];
	[self.mainTableView reloadData];
	self.addItemButton.hidden=YES;
	self.noEntriesLabel.hidden=(self.itemsArray.count>0 || self.topSegment.selectedSegmentIndex>0);

}

-(IBAction)deleteButtonPressed:(id)sender {
	[ObjectiveCScripts showConfirmationPopup:@"Delete this record?" message:@"" delegate:self tag:1];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag==1 && buttonIndex != alertView.cancelButtonIndex) {
		PurchaseObj *item = [self.itemsArray objectAtIndex:self.selectedRecord];
		
		self.popupView.hidden=YES;
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"purchaseId = %d", item.purchaseId];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"PURCHASE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		if(items.count>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			[self.managedObjectContext deleteObject:mo];
			[self.managedObjectContext save:nil];
			[self updateBankAccountBySubtracting:item.amount*-1];
		}
		[self loadData];

	}
}



-(IBAction)editDateButtonPressed:(id)sender {
	
}





@end

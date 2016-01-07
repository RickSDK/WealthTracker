//
//  CreditScoreTracker.m
//  WealthTracker
//
//  Created by Rick Medved on 7/31/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "CreditScoreTracker.h"
#import "ObjectiveCScripts.h"
#import "UpdateCell.h"
#import "NSDate+ATTDate.h"
#import "GraphCell.h"
#import "GraphLib.h"
#import "UpdateWebCell.h"
#import "WebViewVC.h"
#import "GraphObject.h"

@interface CreditScoreTracker ()

@end

@implementation CreditScoreTracker

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Credit Tracker"];

	self.nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	self.nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	self.displayYear = self.nowYear;
	self.displayMonth = self.nowMonth;
	
	self.graphItems = [[NSMutableArray alloc] init];

	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d", self.nowYear];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CREDIT_SCORE" predicate:predicate sortColumn:@"month" mOC:self.managedObjectContext ascendingFlg:NO];
	if(items.count==0) {
		int score=500;
		[self updateRecordScore:score confirmFlg:NO];
	}

	[self setupData];
}

-(void)setupData {
	[self.graphItems removeAllObjects];
	for(int i=1; i<=12; i++) {
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d AND month = %d", self.displayYear, i];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"CREDIT_SCORE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		GraphObject *graphObject = [[GraphObject alloc] init];
		graphObject.name = [[ObjectiveCScripts monthListShort] objectAtIndex:i-1];
		if(items.count>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			graphObject.amount = [[mo valueForKey:@"score"] intValue];
			graphObject.confirmFlg = [[mo valueForKey:@"confirmFlg"] boolValue];
			graphObject.existsFlg=YES;
		}
		[self.graphItems addObject:graphObject];
	}
	[self.mainTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	
	if(indexPath.section==0) {
		NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
		GraphCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[GraphCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		cell.titleLabel.text = @"Credit Score";
		cell.currentYearLabel.text = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
		[cell.prevYearButton addTarget:self action:@selector(prevMonthButtonPressed) forControlEvents:UIControlEventTouchDown];
		[cell.nextYearButton addTarget:self action:@selector(nextMonthButtonPressed) forControlEvents:UIControlEventTouchDown];
		
		
		BOOL nextFlg = !(self.displayYear>=self.nowYear && self.displayMonth>=self.nowMonth);
		if(nextFlg)
			[cell.nextYearButton setTitle:@"Next" forState:UIControlStateNormal];
		else
			[cell.nextYearButton setTitle:@"-" forState:UIControlStateNormal];
		
		cell.graphImageView.image = [GraphLib plotGraphWithItems:self.graphItems];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else if(indexPath.section==1) {
		UpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UpdateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
		cell.currentYearLabel.text = [NSString stringWithFormat:@"%@ %d", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
		[cell.prevYearButton addTarget:self action:@selector(prevMonthButtonPressed) forControlEvents:UIControlEventTouchDown];
		[cell.nextYearButton addTarget:self action:@selector(nextMonthButtonPressed) forControlEvents:UIControlEventTouchDown];
		
		BOOL nextFlg = !(self.displayYear>=self.nowYear && self.displayMonth>=self.nowMonth);
		if(nextFlg)
			[cell.nextYearButton setTitle:@"Next" forState:UIControlStateNormal];
		else
			[cell.nextYearButton setTitle:@"-" forState:UIControlStateNormal];
		
		cell.valueTextField.delegate=self;

		self.valueTextField = cell.valueTextField;
		
		cell.valueLabel.text = [NSString stringWithFormat:@"%@ %d Score", [[ObjectiveCScripts monthListShort] objectAtIndex:self.displayMonth-1], self.displayYear];
		
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d AND month = %d", self.displayYear, self.displayMonth];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"CREDIT_SCORE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		
		self.valueTextField.text = @"";

		BOOL val_confirm_flg = NO;
		
		if(items.count>0) {
			NSManagedObject *mo = [items objectAtIndex:0];
			int value = [[mo valueForKey:@"score"] intValue];
			val_confirm_flg = [[mo valueForKey:@"confirmFlg"] boolValue];
			
			self.valueTextField.text = [NSString stringWithFormat:@"%d", value];
		}
		
		self.updateValueButton=cell.updateValueButton;
		self.updateValueButton.enabled=NO;
		
		cell.updateBalanceButton.hidden=YES;
		cell.loanAmountTextField.hidden=YES;
		cell.loanAmountLabel.hidden=YES;
		cell.balanceStatusImageView.hidden=YES;
		
		cell.valueStatusImageView.image = (val_confirm_flg)?[UIImage imageNamed:@"green.png"]:[UIImage imageNamed:@"red.png"];
		
		[cell.updateValueButton addTarget:self action:@selector(updateValueButtonPressed) forControlEvents:UIControlEventTouchDown];
		
		if (self.displayYear>self.nowYear ||  (self.displayYear==self.nowYear && self.displayMonth>self.nowMonth)) {
			cell.valueTextField.enabled=NO;
			cell.valueTextField.textColor=[UIColor orangeColor];
			cell.loanAmountTextField.enabled=NO;
			cell.loanAmountTextField.textColor=[UIColor orangeColor];
			cell.balanceStatusImageView.image = [UIImage imageNamed:@"yellow.png"];
			cell.valueStatusImageView.image = [UIImage imageNamed:@"yellow.png"];
		} else {
			cell.valueTextField.enabled=YES;
			cell.valueTextField.textColor=[UIColor blackColor];
			cell.loanAmountTextField.enabled=YES;
			cell.loanAmountTextField.textColor=[UIColor blackColor];
		}
		
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else {
		UpdateWebCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell==nil)
			cell = [[UpdateWebCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		
			[cell.updateButton setTitle:@"Check Score" forState:UIControlStateNormal];
			cell.messageLabel.text = @"Check your score once per month.";
			[cell.updateButton addTarget:self action:@selector(webViewBalanceButtonPressed) forControlEvents:UIControlEventTouchDown];
		
		NSString *creditUrl = [CoreDataLib getTextFromProfile:@"creditUrl" mOC:self.managedObjectContext];
			cell.statusImageView.image = (creditUrl.length>0)?[UIImage imageNamed:@"green.png"]:[UIImage imageNamed:@"red.png"];
		
		cell.iconImageView.image = [UIImage imageNamed:@"karma.png"];
		
		cell.accessoryType= UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
}

-(void)scrollToHeight:(float)height {
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0);
	self.mainTableView.contentInset = contentInsets;
	self.mainTableView.scrollIndicatorInsets = contentInsets;
	
	[self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
	if(textField==self.valueTextField) {
		self.updateValueButton.enabled=YES;
	}
	[self scrollToHeight:250];
}



-(void)prevMonthButtonPressed {
	self.displayMonth--;
	if(self.displayMonth<=0) {
		self.displayYear--;
		self.displayMonth=12;
	}
	[self setupData];
}

-(void)nextMonthButtonPressed {
	if (self.displayYear>=self.nowYear && self.displayMonth>=self.nowMonth)
		return;
	
	self.displayMonth++;
	if(self.displayMonth>=13) {
		self.displayYear++;
		self.displayMonth=1;
	}
	[self setupData];
}



-(void)updateValueButtonPressed {
	if(self.valueTextField.text.length==0) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Value blank"];
		return;
	}
	
	if([self checkFlag:@"val_confirm_flg"])
		[ObjectiveCScripts showConfirmationPopup:@"Overwrite Existing Data?" message:@"You can only have one entry per month. Overwrite the existing entry?" delegate:self tag:1];
	else
		[self updateValue:self.valueTextField.text];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex!=alertView.cancelButtonIndex && alertView.tag==1) {
		[self updateValue:self.valueTextField.text];
	}
}

-(void)updateRecordScore:(int)score confirmFlg:(BOOL)confirmFlg {
	[self updateRecordWithScore:score month:self.displayMonth year:self.displayYear confirmFlg:confirmFlg];
	
	int month=self.displayMonth;
	int year=self.displayYear;
	BOOL keepGoing=YES;
	for(int i=1; i<=12; i++) {
		month--;
		if(month<1) {
			month=12;
			year--;
		}
		if(keepGoing)
			keepGoing = [self updateRecordWithScore:score month:month year:year confirmFlg:NO];
	}
	
	keepGoing=YES;
	month=self.displayMonth;
	year=self.displayYear;
	for(int i=1; i<=12; i++) {
		month++;
		if(month>12) {
			month=1;
			year++;
		}
		if(keepGoing)
			keepGoing = [self updateRecordWithScore:score month:month year:year confirmFlg:NO];
	}
	[self.managedObjectContext save:nil];

	[self resetView];
}

-(void)updateValue:(NSString *)value {
	int score = [value intValue];
	[self updateRecordScore:score confirmFlg:YES];
}

-(BOOL)updateRecordWithScore:(int)score month:(int)month year:(int)year confirmFlg:(BOOL)confirmFlg {
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"month = %d AND year = %d", month, year];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CREDIT_SCORE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	NSManagedObject *updateRecord = nil;
	if(items.count>0) {
		updateRecord = [items objectAtIndex:0];
		BOOL oldConfirmFlg = [[updateRecord valueForKey:@"confirmFlg"] boolValue];
		if(oldConfirmFlg && !confirmFlg)
			return NO;
	} else {
		updateRecord = [NSEntityDescription insertNewObjectForEntityForName:@"CREDIT_SCORE" inManagedObjectContext:self.managedObjectContext];
	}
	[updateRecord setValue:[NSNumber numberWithInt:year] forKey:@"year"];
	[updateRecord setValue:[NSNumber numberWithInt:month] forKey:@"month"];
	[updateRecord setValue:[NSNumber numberWithInt:score] forKey:@"score"];
	[updateRecord setValue:[NSNumber numberWithBool:confirmFlg] forKey:@"confirmFlg"];
	return YES;
}

-(void)resetView {
	[self.valueTextField resignFirstResponder];
	[self scrollToHeight:0];
	[self setupData];
}

-(BOOL)checkFlag:(NSString *)flag {
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d AND month = %d", self.displayYear, self.displayMonth];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"CREDIT_SCORE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	
	if(items.count>0) {
		NSManagedObject *mo = [items objectAtIndex:0];
		
		return [[mo valueForKey:@"confirmFlg"] boolValue];
	}
	return NO;
}




-(void)webViewBalanceButtonPressed {
	WebViewVC *detailViewController = [[WebViewVC alloc] initWithNibName:@"WebViewVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.creditScoreFlg=YES;
	detailViewController.callBackViewController=self;
	[self.navigationController pushViewController:detailViewController animated:YES];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
		return 1;
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
	if(indexPath.section==0)
		return [ObjectiveCScripts chartHeightForSize:254];
	else if(indexPath.section==1)
		return 130;
	else
		return 90;
}


@end

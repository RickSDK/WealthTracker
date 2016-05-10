//
//  CashFlowEditItemVC.m
//  WealthTracker
//
//  Created by Rick Medved on 8/3/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "CashFlowEditItemVC.h"
#import "ObjectiveCScripts.h"
#import "CoreDataLib.h"
#import "CashFlowCell.h"

@interface CashFlowEditItemVC ()

@end

@implementation CashFlowEditItemVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setTitle:@"New Item"];
	
	self.buttonArray = [[NSMutableArray alloc] init];
	
	self.FAtypeLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19.f];
	self.type = self.cashFlowObj.type;

	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"statement_day" mOC:self.managedObjectContext ascendingFlg:YES];
	for(NSManagedObject *item in items) {
		[self.buttonArray addObject:[item valueForKey:@"name"]];
	}
	[self.buttonArray addObject:@"-other-"];

	self.deleteButton.hidden=YES;
	if(self.managedObject) {
		[self setTitle:@"Edit Item"];

		self.nameTextField.text = [self.managedObject valueForKey:@"name"];
		double amount = [[self.managedObject valueForKey:@"amount"] doubleValue];
		if(amount<0)
			amount*=-1;
		else
			self.billSwitch.on=NO;
		
		self.amountTextField.text = [ObjectiveCScripts convertNumberToMoneyString:amount];
		self.dayTextField.text = [NSString stringWithFormat:@"%d", [[self.managedObject valueForKey:@"statement_day"] intValue]];
		self.confirmSwitch.on = [[self.managedObject valueForKey:@"confirmFlg"] boolValue];
		self.deleteButton.hidden=NO;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textFieldDidChangeNotification:)
												 name:UITextFieldTextDidBeginEditingNotification
											   object:self.nameTextField];

	
	[self checkConfirmSwitch];
	[self checkbillSwitch];

	[self checkSubmitButtonWithName:self.nameTextField.text amount:self.amountTextField.text day:self.dayTextField.text];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(infoButtonPressed)];

}

-(void)displayFA {
	if(self.billSwitch.on) {
		self.FAtypeLabel.text = [CashFlowCell fASymbolForType:self.type];
		self.typeDescLabel.text = [CashFlowCell fANameForType:self.type];
	} else {
		self.FAtypeLabel.text = [NSString fontAwesomeIconStringForEnum:FAMoney];
		self.typeDescLabel.text = @"Income";
	}

}

-(void)textFieldDidChangeNotification:(id)sender {
	
	if(self.nameTextField.text.length==0 && self.billSwitch.on && !self.okToEditFlg) {
		[self.nameTextField resignFirstResponder];
		[ObjectiveCScripts showAlertPopup:@"Press Select First" message:@""];
	}
}

-(void)infoButtonPressed {
	[ObjectiveCScripts showAlertPopup:@"Cash Flow" message:@"Use the Cash Flow tool to track all money coming in and going out. The surplus figure at the bottom of the previous screen is the amount you can safely devote towards your debt paydown."];
}

-(void)checkSubmitButtonWithName:(NSString *)name amount:(NSString *)amount day:(NSString *)day {
	if(name.length==0 || amount.length==0 || day.length==0)
		self.submitButton.enabled=NO;
	else
		self.submitButton.enabled=YES;
}


-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if([@"|" isEqualToString:string])
		return NO;
	if(textFieldlocal.text.length>=20)
		return NO;
	
	int num=1;
	if(string.length==0)
		num=-1;
	
	
	int nameLen = (int)self.nameTextField.text.length;
	if(textFieldlocal==self.nameTextField)
		nameLen+=num;
	int amountLen = (int)self.amountTextField.text.length;
	if(textFieldlocal==self.amountTextField)
		amountLen+=num;
	int dayLen = (int)self.dayTextField.text.length;
	if(textFieldlocal==self.dayTextField)
		dayLen+=num;

	if(nameLen==0 || amountLen==0 || dayLen==0)
		self.submitButton.enabled=NO;
	else
		self.submitButton.enabled=YES;
	
	if(string.length==0) // backspace
		return YES;
	if([@"." isEqualToString:string])
		return YES;
	if(textFieldlocal==self.amountTextField) {
		NSString *value = [NSString stringWithFormat:@"%@%@", textFieldlocal.text, string];
		value = [value stringByReplacingOccurrencesOfString:@"$" withString:@""];
		value = [value stringByReplacingOccurrencesOfString:@"," withString:@""];
		value = [ObjectiveCScripts convertNumberToMoneyString:[value doubleValue]];
		textFieldlocal.text = value;
		return NO;
	}
	return YES;
}


- (IBAction) submitButtonPressed: (id) sender {
	if(!self.managedObject)
		self.managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"CASH_FLOW" inManagedObjectContext:self.managedObjectContext];
	[self.managedObject setValue:self.nameTextField.text forKey:@"name"];
	double amount = [ObjectiveCScripts convertMoneyStringToDouble:self.amountTextField.text];
	if(self.billSwitch.on)
		amount*=-1;
	[self.managedObject setValue:[NSNumber numberWithInt:(int)amount] forKey:@"amount"];
	[self.managedObject setValue:[NSNumber numberWithInt:(int)self.type] forKey:@"type"];
	[self.managedObject setValue:[NSNumber numberWithBool:self.confirmSwitch.on] forKey:@"confirmFlg"];
	[self.managedObject setValue:[NSNumber numberWithInt:[self.dayTextField.text intValue]] forKey:@"statement_day"];
	[self.managedObjectContext save:nil];
	[self.navigationController popViewControllerAnimated:YES];
	
}

- (IBAction) billSwitchPressed: (id) sender {
	[self checkbillSwitch];
}

-(void)checkbillSwitch {
	if(self.billSwitch.on) {
		self.typeLabel.text = @"Bill (outflow)";
		self.bgView.backgroundColor = [UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
	} else {
		self.typeLabel.text = @"Income";
		self.bgView.backgroundColor = [UIColor colorWithRed:.8 green:1 blue:.8 alpha:1];
	}
	self.selectButton.enabled=self.billSwitch.on;
	[self displayFA];
}

- (IBAction) confirmSwitchPressed: (id) sender {
	[self checkConfirmSwitch];
}

-(void)checkConfirmSwitch {
	if(self.confirmSwitch.on)
		self.confirmLabel.text = @"Already Posted to bank for current month";
	else
		self.confirmLabel.text = @"Not yet posted";
}

- (IBAction) deleteButtonPressed: (id) sender {
	[ObjectiveCScripts showConfirmationPopup:@"Delete Record?" message:@"" delegate:self tag:1];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex==alertView.cancelButtonIndex) {
		return;
	}
	if(alertView.tag==1) {
		[self.managedObjectContext deleteObject:self.managedObject];
		[self.managedObjectContext save:nil];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (IBAction) selectButtonPressed: (id) sender {
	self.okToEditFlg=NO;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select this item type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
	
	for(NSString *button in self.buttonArray)
		[actionSheet addButtonWithTitle:button];

	[actionSheet showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != actionSheet.cancelButtonIndex && buttonIndex>0) {
		self.nameTextField.text = [self.buttonArray objectAtIndex:buttonIndex-1];
		if(buttonIndex==self.buttonArray.count) {
			self.okToEditFlg=YES;
			self.nameTextField.text = @"";
			[self.nameTextField becomeFirstResponder];
		}
	}
}

- (IBAction) typeButtonPressed: (id) sender {
	self.type++;
	if(self.type>8)
		self.type=0;
	[self displayFA];
}



@end

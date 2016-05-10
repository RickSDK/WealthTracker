//
//  FixedExpensesVC.m
//  BalanceApp
//
//  Created by Rick Medved on 4/7/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "FixedExpensesVC.h"

@interface FixedExpensesVC ()

@end

@implementation FixedExpensesVC

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setTitle:@"Expenses"];
	self.itemType = 2;
	
}


-(void)createPressed {
	self.editingFlg=NO;
	self.deleteButton.enabled=NO;
	self.deleteButton.hidden=YES;
	self.amountTextField.text = @"";
	self.dueDateField.text = @"1";
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select this Asset type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Rent/Mortgage/Dues", @"Utilities", @"Cable", @"Phone", @"Vehicle", @"Gym", @"Credit Card", @"Internet", @"Other", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [actionSheet cancelButtonIndex]) {
		NSArray *titles = [NSArray arrayWithObjects:@"Rent/Mortgage/Dues", @"Utilities", @"Cable", @"Phone", @"Vehicle", @"Gym", @"Credit Card", @"Internet", @"Other", nil];
		self.nameTextField.text = [titles objectAtIndex:buttonIndex];
		self.popupView.hidden=NO;
		[self.amountTextField becomeFirstResponder];
		self.selectedType=(int)buttonIndex;
	}
}

-(void)showPopup {
	[super showPopup];
}






@end

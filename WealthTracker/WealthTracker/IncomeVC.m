//
//  IncomeVC.m
//  WealthTracker
//
//  Created by Rick Medved on 5/7/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "IncomeVC.h"

@interface IncomeVC ()

@end

@implementation IncomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Monthly Income"];
	self.itemType = 1; // income

    // Do any additional setup after loading the view from its nib.
}

-(void)createPressed {
	self.popupView.hidden=NO;
	self.editingFlg=NO;
	self.deleteButton.enabled=NO;
	self.deleteButton.hidden=YES;
	self.amountTextField.text = @"";
	self.dueDateField.text = @"1";
	[self.nameTextField becomeFirstResponder];
}


@end

//
//  EnterValueVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/10/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "EnterValueVC.h"
#import "EditItemVC.h"
#import "ObjectiveCScripts.h"

@interface EnterValueVC ()

@end

@implementation EnterValueVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Enter Value"];
	
	self.titleLabel.text = self.cellObject.desc;
	[self.numberTextField becomeFirstResponder];
	
	//		0=string
	//		1=money
	//		2=int
	//		3=float (%)
	//		4=float (any type)

	switch (self.cellObject.fieldType) {
  case 0:
			self.numberTextField.keyboardType=UIKeyboardTypeDefault;
			break;
  case 1:
  case 2:
			self.numberTextField.keyboardType=UIKeyboardTypeNumberPad;
			break;
  case 3:
			self.numberTextField.keyboardType=UIKeyboardTypeDecimalPad;
			break;
			
  default:
			break;
	}
	
	self.prevValueLabel.text = self.cellObject.value;
	
	if(self.cellObject.fieldType==1)
		self.prevValueLabel.text = [ObjectiveCScripts convertNumberToMoneyString:[self.cellObject.value doubleValue]];
		
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed)];
}

-(void)cancelButtonPressed {
	[self.navigationController popViewControllerAnimated:YES];
}


-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if([@"|" isEqualToString:string])
		return NO;
	if(textFieldlocal.text.length>=20)
		return NO;
	
	if(self.cellObject.fieldType==1) {
		return [ObjectiveCScripts shouldChangeCharactersForMoneyField:textFieldlocal replacementString:string];
	}
	return YES;
}

-(void)doneButtonPressed {
	[(EditItemVC *)self.callbackController updateValue:self.numberTextField.text];
	[self.navigationController popViewControllerAnimated:YES];
}


@end

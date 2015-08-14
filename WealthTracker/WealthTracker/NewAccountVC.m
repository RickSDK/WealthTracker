//
//  NewAccountVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/28/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "NewAccountVC.h"
#import "ObjectiveCScripts.h"
#import "PrivacyPolicyVC.h"

@interface NewAccountVC ()

@end

@implementation NewAccountVC

-(void)createAccount
{
	@autoreleasepool {
		NSString *email = [NSString stringWithFormat:@"%@", self.fieldNewEmail.text];
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"appName", @"Password", @"Version", nil];
		NSArray *valueList = [NSArray arrayWithObjects:self.fieldNewEmail.text, @"Wealth Tracker", self.fieldNewPassword.text, [ObjectiveCScripts getProjectDisplayVersion], nil];
		NSString *responseStr = [ObjectiveCScripts getResponseFromServerUsingPost:@"http://www.appdigity.com/poker/createPokerAccount.php" fieldList:nameList valueList:valueList];
		if([ObjectiveCScripts validateStandardResponse:responseStr delegate:nil]) {
			[ObjectiveCScripts showAlertPopupWithDelegate:@"Success!" message:@"Account Created" delegate:self tag:1];
			[ObjectiveCScripts setUserDefaultValue:email forKey:@"emailAddress"];
			[ObjectiveCScripts setUserDefaultValue:email forKey:@"userName"];
			
			[ObjectiveCScripts setUserDefaultValue:self.fieldNewPassword.text forKey:@"password"];
		}
		
		[self.webServiceView stop];
		self.submitButton.enabled=YES;
		
	}
}

- (IBAction) submitButtonPressed: (id) sender
{
	self.submitButton.enabled=NO;
	
	[self.self.fieldNewEmail resignFirstResponder];
	[self.fieldNewPassword resignFirstResponder];
	[self.rePassword resignFirstResponder];
	
	BOOL passChecks=YES;
	if(passChecks && self.termsSwitch.on==NO) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Please view and accept the privacy policy."];
		passChecks=NO;
	}
	if(passChecks && [self.fieldNewEmail.text length]<5) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Enter a valid Email Address"];
		passChecks=NO;
	}
	if(passChecks && [self.fieldNewPassword.text length]<2) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Enter a valid password"];
		passChecks=NO;
	}
	if(passChecks && [self.rePassword.text length]<2) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Re-enter your password"];
		passChecks=NO;
	}
	if(passChecks && ![self.fieldNewPassword.text isEqualToString:self.rePassword.text]) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Passwords do not match!"];
		passChecks=NO;
	}
	
	if(passChecks) {
		[self.webServiceView startWithTitle:@"Working"];
		[self performSelectorInBackground:@selector(createAccount) withObject:nil];
	} else
		self.submitButton.enabled=YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setTitle:@"Create Account"];
	
	self.termsSwitch.on=NO;
	self.termsSwitch.enabled=NO;
	[self setupFields];
	
}




-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (IBAction) termsSwitchPressed: (id) sender {
	[self setupFields];
}

-(void)setupFields {
	if (self.termsSwitch.on) {
		self.fieldNewEmail.enabled=YES;
		self.fieldNewPassword.enabled=YES;
		self.rePassword.enabled=YES;
	}
}

- (IBAction) privacyButtonPressed: (id) sender {
	self.termsSwitch.enabled=YES;
	PrivacyPolicyVC *detailViewController = [[PrivacyPolicyVC alloc] initWithNibName:@"PrivacyPolicyVC" bundle:nil];
	[self.navigationController pushViewController:detailViewController animated:YES];
}


@end

//
//  LoginVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/28/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "LoginVC.h"
#import "NewAccountVC.h"
#import "ObjectiveCScripts.h"

@interface LoginVC ()

@end

@implementation LoginVC

-(void)createNewAccountPressed:(id)sender {
	if(![ObjectiveCScripts isUpgraded])
		[ObjectiveCScripts showAlertPopup:@"Sorry" message:@"You must have the upgraded version of this app to access this feature. Click the 'Upgrade' button at the bottom of the previous page."];
	else {
		NewAccountVC *detailViewController = [[NewAccountVC alloc] initWithNibName:@"NewAccountVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

-(void)loginToSystem
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", nil];
		NSArray *valueList = [NSArray arrayWithObjects:self.loginEmail.text, self.loginPassword.text, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerLogin.php";
		NSString *responseStr = [ObjectiveCScripts getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		if([ObjectiveCScripts validateStandardResponse:responseStr delegate:nil]) {
			NSArray *items = [responseStr componentsSeparatedByString:@"|"];
			NSString *firstName = @"";
			if([items count]>5) {
				firstName = [items objectAtIndex:1];
				[ObjectiveCScripts setUserDefaultValue:self.loginEmail.text forKey:@"emailAddress"];
				[ObjectiveCScripts setUserDefaultValue:self.loginEmail.text forKey:@"userName"];
				[ObjectiveCScripts setUserDefaultValue:firstName forKey:@"firstName"];
				[ObjectiveCScripts setUserDefaultValue:self.loginPassword.text forKey:@"password"];
				[ObjectiveCScripts setUserDefaultValue:[items objectAtIndex:2] forKey:@"userCity"];
				[ObjectiveCScripts setUserDefaultValue:[items objectAtIndex:3] forKey:@"UserState"];
				[ObjectiveCScripts setUserDefaultValue:[items objectAtIndex:4] forKey:@"UserCountry"];
				[ObjectiveCScripts setUserDefaultValue:[items objectAtIndex:5] forKey:@"userStatsFlg"];
				[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"assetsFlg"];
				[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"profileFlg"];
				[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"housingFlg"];
				[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"vehiclesFlg"];
				[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"debtsFlg"];
				[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"upgradeFlg"];
			}
			[ObjectiveCScripts showAlertPopupWithDelegate:@"Success!" message:@"User Logged in" delegate:self tag:1];
			
		}
		[self.webServiceView stop];
		self.loginButton.enabled=YES;
	}
}



-(void)forgotPassword
{
	@autoreleasepool {
		NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", nil];
		NSArray *valueList = [NSArray arrayWithObjects:self.loginEmail.text, self.loginPassword.text, nil];
		NSString *webAddr = @"http://www.appdigity.com/poker/pokerForgotPassword.php";
		NSString *responseStr = @"";
		responseStr = [ObjectiveCScripts getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
		//	NSLog(@"responseStr: %@", responseStr);
		if([ObjectiveCScripts validateStandardResponse:responseStr delegate:nil]) {
			[ObjectiveCScripts showAlertPopupWithDelegate:@"Success!" message:@"Your password has been emailed." delegate:self tag:1];
		}
		[self.webServiceView stop];
		
	}
}

-(void)executeThreadedJob:(SEL)aSelector
{
	[self.webServiceView startWithTitle:@"Working..."];
	[self performSelectorInBackground:aSelector withObject:nil];
}


- (IBAction) loginPressed: (id) sender
{
	[self.loginEmail resignFirstResponder];
	[self.loginPassword resignFirstResponder];
	BOOL passChecks=YES;
	if([self.loginEmail.text length]<5) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Enter a valid Emaill Address"];
		passChecks=NO;
	}
	if(passChecks && [self.loginPassword.text length]<2) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Enter a valid password"];
		passChecks=NO;
	}
	if(passChecks) {
		self.loginButton.enabled=NO;
		[self executeThreadedJob:@selector(loginToSystem)];
	}
}

- (IBAction) forgotPressed: (id) sender
{
	if([self.loginEmail.text length]<5) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Enter a valid Emaill Address"];
		return;
	}
	[self executeThreadedJob:@selector(forgotPassword)];
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
	[self setTitle:@"Login"];

	[ObjectiveCScripts setUserDefaultValue:@"" forKey:@"emailAddress"];

	self.bgView.layer.cornerRadius = 8.0;
	self.bgView.layer.masksToBounds = YES;
	self.bgView.layer.borderColor = [UIColor blackColor].CGColor;
	self.bgView.layer.borderWidth = 2.0;

	UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Create New Account" style:UIBarButtonItemStylePlain target:self action:@selector(createNewAccountPressed:)];
	self.navigationItem.rightBarButtonItem = homeButton;
	
	if(kTestMode) {
		self.loginEmail.text=@"rickmedved@hotmail.com";
		self.loginPassword.text=@"rick23";
	}
	
}


@end

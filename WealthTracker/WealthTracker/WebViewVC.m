//
//  WebViewVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/23/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "WebViewVC.h"
#import "ObjectiveCScripts.h"
#import "UpdateDetails.h"

@interface WebViewVC ()

@end

@implementation WebViewVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	self.currentUrl=[[NSString alloc] init];
	self.currentUrl=@"";
	self.urlLabel.text = self.currentUrl;

	self.webPassword = [[NSString alloc] init];
	
	self.mainWebView.layer.cornerRadius = 8.0;
	self.mainWebView.layer.masksToBounds = YES;
	self.mainWebView.layer.borderColor = [UIColor blackColor].CGColor;
	self.mainWebView.layer.borderWidth = 2.0;
	
	self.infoButton.layer.borderWidth = 0;
	
	self.updateValueButton.enabled=NO;
	NSString *urlString = nil;
	NSString *user = nil;
	
	if(self.creditScoreFlg) {
		[self setTitle:@"Credit Score"];
		urlString = [CoreDataLib getTextFromProfile:@"creditUrl" mOC:self.managedObjectContext];
		if(urlString.length<10)
			urlString = @"http://www.CreditKarma.com";
		user = [CoreDataLib getTextFromProfile:@"creditUser" mOC:self.managedObjectContext];
		self.webPassword = [CoreDataLib getTextFromProfile:@"creditPass" mOC:self.managedObjectContext];
	} else {
	
		[self setTitle:self.itemObject.name];
		self.mo = [CoreDataLib managedObjFromId:self.itemObject.rowId managedObjectContext:self.managedObjectContext];
		
		user = (self.balanceFlg)?[self.mo valueForKey:@"balanceUsername"]:[self.mo valueForKey:@"valueUsername"];
		self.webPassword = (self.balanceFlg)?[self.mo valueForKey:@"balancePassword"]:[self.mo valueForKey:@"valuePassword"];
		
		urlString = (self.balanceFlg)?self.itemObject.balanceUrl:self.itemObject.valueUrl;
		
		if(self.balanceFlg) {
			self.valueTextField.text = [ObjectiveCScripts convertNumberToMoneyString:[self.itemObject.loan_balance doubleValue]];
		} else {
			self.valueTextField.text = [ObjectiveCScripts convertNumberToMoneyString:[self.itemObject.value doubleValue]];
			
			if([@"Vehicle" isEqualToString:self.itemObject.type] && urlString.length==0)
				urlString = @"http://www.kbb.com/whats-my-car-worth/";
			
			if([@"Real Estate" isEqualToString:self.itemObject.type] && urlString.length==0)
				urlString = @"http://www.zillow.com";
		}
	
	}
	
	NSLog(@"+++urlString: %@", urlString);

	if(user.length>0) {
		self.userTextField.text = user;
		self.passTextField.text = [self hiddenPassword:self.webPassword];
	}
	

	if(urlString.length>6) {
		[self startSearchWeb:urlString];
	} else {
		[self.urlTextField becomeFirstResponder];
	}
	self.passwordView.hidden=YES;
	self.globalPasswordView.hidden=YES;

	self.globalPasswordView.layer.cornerRadius = 8.0;
	self.globalPasswordView.layer.masksToBounds = YES;
	self.globalPasswordView.layer.borderColor = [UIColor blackColor].CGColor;
	self.globalPasswordView.layer.borderWidth = 2.0;
	

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Password" style:UIBarButtonItemStyleBordered target:self action:@selector(showPasswordButtonPressed)];

}

-(void)startSearchWeb:(NSString *)urlString {
	urlString = [urlString lowercaseString];
	if(urlString.length>3 && [@"www" isEqualToString:[urlString substringToIndex:3]]) {
		urlString = [NSString stringWithFormat:@"http://%@", urlString];
	}
	urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSLog(@"Go! %@", urlString);
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];

	[self.urlTextField resignFirstResponder];
	self.messageLabel.hidden=YES;
	[self.activityIndicator startAnimating];
	self.webGoButton.enabled=NO;

	[self.mainWebView loadRequest:request];
}

-(NSString *)hiddenPassword:(NSString *)password {
	if(password.length<4)
		return @"***";
	else
		return [NSString stringWithFormat:@"%@***%@", [password substringToIndex:1], [password substringFromIndex:4]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType

{
	NSLog(@"shouldStartLoadWithRequest");
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSString *urlString = [request.mainDocumentURL absoluteString];
		NSLog(@"link clicked = %@", urlString);
	}
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"webViewDidStartLoad");
	if([webView.request mainDocumentURL])
		NSLog(@"Requst url: %@", [webView.request mainDocumentURL]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"webViewDidFinishLoad");
	[self.activityIndicator stopAnimating];
	self.webGoButton.enabled=YES;
	if([webView.request mainDocumentURL]) {
		NSLog(@"Loaded url: %@", [webView.request mainDocumentURL]);
	
		self.currentUrl = [[webView.request mainDocumentURL] absoluteString];
		self.urlLabel.text = self.currentUrl;
	}
}

-(IBAction)updateValueButtonClicked:(id)sender {
	if(self.valueTextField.text.length==0) {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Value blank"];
		return;
	}
	[self saveLink:self.currentUrl];
	if(self.balanceFlg)
		[(UpdateDetails*)self.callBackViewController updateBalance:self.valueTextField.text];
	else
		[(UpdateDetails*)self.callBackViewController updateValue:self.valueTextField.text];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)saveLink:(NSString *)string {
	if(self.creditScoreFlg) {
		NSLog(@"+++saveing Credit");
		[CoreDataLib saveTextToProfile:@"creditUrl" value:string context:self.managedObjectContext];
		return;
	}
	if(self.balanceFlg) {
		NSLog(@"+++saveing balanceUrl: %@", string);
		[self.mo setValue:string forKey:@"balanceUrl"];
	} else {
		NSLog(@"+++saveing valueUrl: %@", string);
		[self.mo setValue:string forKey:@"valueUrl"];
	}


	[self.managedObjectContext save:nil];
}

-(IBAction)updateLinkButtonClicked:(id)sender {
	if(self.currentUrl.length>10) {
		[self saveLink:self.currentUrl];
		[ObjectiveCScripts showAlertPopup:@"URL Set" message:@""];
	} else {
		[ObjectiveCScripts showAlertPopup:@"Error" message:@"Link not updated. Unable to grab the URL. Try finding the vehicle in safari and then copy paste the url."];
		self.urlView.hidden=NO;
	}
}

-(IBAction)resetLinkButtonClicked:(id)sender {
	[self saveLink:@""];
	self.urlView.hidden=NO;
	[ObjectiveCScripts showAlertPopup:@"URL Cleared" message:@""];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.updateValueButton.enabled=YES;
}

-(BOOL)textField:(UITextField *)textFieldlocal shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if(self.creditScoreFlg)
		return YES;
	else
		return [ObjectiveCScripts shouldChangeCharactersForMoneyField:textFieldlocal replacementString:string];
}

-(IBAction)urlGoButtonClicked:(id)sender {
	[self startSearchWeb:self.urlTextField.text];
}

-(IBAction)safariButtonClicked:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.kbb.com/"]];
}

-(void)showPasswordButtonPressed {
	if(self.currentUrl.length>0) {
		self.passwordView.hidden=self.showPasswordFlg;
		self.showPasswordFlg=!self.showPasswordFlg;
	}
}

-(IBAction)revealButtonClicked:(id)sender {
	if(self.passTextField.text.length>0) {
		int globalPass = [CoreDataLib getNumberFromProfile:@"webPassword" mOC:self.managedObjectContext];
		if(globalPass==0)
			[ObjectiveCScripts showAlertPopup:@"Enter a global password" message:@""];
		
		self.globalPasswordView.hidden=NO;
	}
}
-(IBAction)setUserButtonClicked:(id)sender {
	if(self.passTextField.text.length>0) {
		NSString *checkPW = [self.passTextField.text stringByReplacingOccurrencesOfString:@"*" withString:@""];
		if(self.userTextField.text.length>0 && [checkPW isEqualToString:self.passTextField.text]) {
			if(self.creditScoreFlg) {
				[CoreDataLib saveTextToProfile:@"creditUser" value:self.userTextField.text context:self.managedObjectContext];
				[CoreDataLib saveTextToProfile:@"creditPass" value:self.passTextField.text context:self.managedObjectContext];
			} else {
				if(self.balanceFlg) {
					[self.mo setValue:self.userTextField.text forKey:@"balanceUsername"];
					[self.mo setValue:self.passTextField.text forKey:@"balancePassword"];
				} else {
					[self.mo setValue:self.userTextField.text forKey:@"valueUsername"];
					[self.mo setValue:self.passTextField.text forKey:@"valuePassword"];
				}
			}
			[self.managedObjectContext save:nil];
		}
		self.webPassword = self.passTextField.text;
		self.passTextField.text = [self hiddenPassword:self.webPassword];
		
		[self showPasswordButtonPressed];
	}
}

-(IBAction)setPassButtonClicked:(id)sender {
	[self.globalpassTextField resignFirstResponder];
	int globalPassword = [self.globalpassTextField.text intValue];
	if(globalPassword==0)
		[ObjectiveCScripts showAlertPopup:@"Invalid Password" message:@""];
	else {
		int globalPassOld = [CoreDataLib getNumberFromProfile:@"webPassword" mOC:self.managedObjectContext];
		if(globalPassOld==0) {
			[self setPasswordTo:globalPassword];
			self.passTextField.text = self.webPassword;
		} else {
			if(globalPassOld==globalPassword)
				self.passTextField.text = self.webPassword;
			else
				[ObjectiveCScripts showAlertPopup:@"Invalid Password" message:@""];
			
		}
	}
	self.globalPasswordView.hidden=YES;
}

-(void)setPasswordTo:(int)password {
	NSArray *profile = [CoreDataLib selectRowsFromEntity:@"PROFILE" predicate:nil sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	if(profile.count>0) {
		NSManagedObject *profileObj = [profile objectAtIndex:0];
		[profileObj setValue:[NSString stringWithFormat:@"%d", password] forKey:@"webPassword"];
		[self.managedObjectContext save:nil];
	}
}

-(IBAction)resetPassButtonClicked:(id)sender {
	[ObjectiveCScripts showConfirmationPopup:@"Notice" message:@"Resetting your global password will delete any passwords stored on this device. Continue?"  delegate:self tag:1];
	
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex==alertView.cancelButtonIndex)
		return;
	
	if(alertView.tag==1) {
		[self.globalpassTextField resignFirstResponder];
		self.globalPasswordView.hidden=YES;
		[self setPasswordTo:0];
		self.passTextField.text=@"";
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		for(NSManagedObject *mo in items) {
			[mo setValue:@"" forKey:@"valuePassword"];
			[mo setValue:@"" forKey:@"balancePassword"];
		}
		[self.managedObjectContext save:nil];
		[CoreDataLib saveTextToProfile:@"creditPass" value:@"" context:self.managedObjectContext];
		[ObjectiveCScripts showAlertPopup:@"Success" message:@"All passwords have been removed"];
	}
}

-(IBAction)backButtonClicked:(id)sender {
	[self.mainWebView goBack];
}

-(IBAction)infoButtonClicked:(id)sender {
	[ObjectiveCScripts showAlertPopup:@"Global Password" message:@"Choose a numeric password the use in this app. You must use that global password in order to reveal any of your individual passwords."];
}





@end

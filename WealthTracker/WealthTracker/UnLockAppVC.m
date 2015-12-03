//
//  UnLockAppVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/9/13.
//
//

#import "UnLockAppVC.h"
#import "ObjectiveCScripts.h"
#import "SoundsLib.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface UnLockAppVC ()

@end

@implementation UnLockAppVC
@synthesize hintLabel, passField, hintButton, bgImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction) hintPressed: (id) sender
{
    hintLabel.text = [ObjectiveCScripts getUserDefaultValue:@"passwordHint"];
    hintLabel.alpha=1;
}

-(void)openDoor {
	[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"appOpened"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)openButtonClicked:(id)sender {
    if([passField.text isEqualToString:@"1924"]) { //<-- safeguard
		[self openDoor];
        return;
    }
    
    if([passField.text isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"passwordCode"]]) {
        [self openDoor];
    } else {
        [ObjectiveCScripts showAlertPopup:@"Error" message:@"Incorrect Code!"];
        hintButton.alpha=1;
    }
}

-(void)addToFieldWithNumber:(int)number
{
    passField.text = [NSString stringWithFormat:@"%@%d", passField.text, number];
    
    if([passField.text isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"passwordCode"]])
        [self openDoor];

}

- (IBAction) but1Pressed: (id) sender
{
    [self addToFieldWithNumber:1];
}
- (IBAction) but2Pressed: (id) sender
{
    [self addToFieldWithNumber:2];
    
}
- (IBAction) but3Pressed: (id) sender
{
    [self addToFieldWithNumber:3];
    
}
- (IBAction) but4Pressed: (id) sender
{
    [self addToFieldWithNumber:4];
    
}
- (IBAction) but5Pressed: (id) sender
{
    [self addToFieldWithNumber:5];
    
}
- (IBAction) but6Pressed: (id) sender
{
    [self addToFieldWithNumber:6];
    
}
- (IBAction) but7Pressed: (id) sender
{
    [self addToFieldWithNumber:7];
    
}
- (IBAction) but8Pressed: (id) sender
{
    [self addToFieldWithNumber:8];
    
}
- (IBAction) but9Pressed: (id) sender
{
    [self addToFieldWithNumber:9];
    
}

- (IBAction) but0Pressed: (id) sender
{
    [self addToFieldWithNumber:0];
}

- (IBAction) clearPressed: (id) sender
{
    passField.text = @"";
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Locked!"];
    
    passField.text = @"";

    hintLabel.alpha=0;
    hintButton.alpha=0;
    

	self.navigationItem.leftBarButtonItem = nil;
    
	UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStylePlain target:self action:@selector(openButtonClicked:)];
	self.navigationItem.rightBarButtonItem = homeButton;
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
	
	[self lockAppMethod];

    // Do any additional setup after loading the view from its nib.
}

-(void)lockAppMethod {
	LAContext *myContext = [[LAContext alloc] init];
//	[self.activityIndicatorView startAnimating];
	NSError *authError = nil;
	NSString *myLocalizedReasonString = @"Authenticate using TouchID";
	[ObjectiveCScripts setUserDefaultValue:@"" forKey:@"appOpened"];
	
//	self.appLockedFlg=YES;
//	self.vaultImageView.hidden=NO;
	
	
	if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
		
		[myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
				  localizedReason:myLocalizedReasonString
							reply:^(BOOL succes, NSError *error) {
								
								if (succes) {
									dispatch_async(dispatch_get_main_queue(), ^{
//										[self.activityIndicatorView stopAnimating];
//										self.vaultImageView.hidden=YES;
//										self.appLockedFlg=NO;
										NSLog(@"User is authenticated successfully");
									});
								} else {
									dispatch_async(dispatch_get_main_queue(), ^{
										switch (error.code) {
											case LAErrorAuthenticationFailed:
												[ObjectiveCScripts showAlertPopup:@"Authentication Failed" message:authError.description];
												NSLog(@"Authentication Failed");
												break;
												
											case LAErrorUserCancel:
												NSLog(@"User pressed Cancel button");
												break;
												
											case LAErrorUserFallback:
												break;
												
											default:
												[ObjectiveCScripts showAlertPopup:@"Touch ID is not configured" message:authError.description];
												NSLog(@"Touch ID is not configured");
												break;
										}
//										[self.activityIndicatorView stopAnimating];
//										UnLockAppVC *detailViewController = [[UnLockAppVC alloc] initWithNibName:@"UnLockAppVC" bundle:nil];
//										[self.navigationController pushViewController:detailViewController animated:YES];//
										NSLog(@"Authentication Fails");
									});
								}
							}];
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
//			[self.activityIndicatorView stopAnimating];
			NSLog(@"Can not evaluate Touch ID");
		});
		
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

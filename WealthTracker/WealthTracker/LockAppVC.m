//
//  LockAppVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/9/13.
//
//

#import "LockAppVC.h"
#import "ObjectiveCScripts.h"

@interface LockAppVC ()

@end

@implementation LockAppVC
@synthesize messageLabel, passField, hintField, cancelButton, goButton;

-(BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[passField resignFirstResponder];
	[hintField resignFirstResponder];
	return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}


- (IBAction) cancelPressed: (id) sender
{
    [ObjectiveCScripts setUserDefaultValue:@"" forKey:@"passwordCode"];
    [ObjectiveCScripts setUserDefaultValue:@"" forKey:@"passwordHint"];
    
    messageLabel.alpha=1;
    messageLabel.text = @"Lock Canceled";
    passField.alpha=0;
    hintField.alpha=0;
    cancelButton.alpha=0;
    goButton.alpha=0;
    [passField resignFirstResponder];
    [hintField resignFirstResponder];

    [ObjectiveCScripts showAlertPopupWithDelegate:@"Unlocked!" message:@"Password has been removed." delegate:self tag:1];
	[ObjectiveCScripts setUserDefaultValue:@"" forKey:@"lockAppFlg"];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (IBAction) setPressed: (id) sender
{
    if([passField.text length]==0) {
        [ObjectiveCScripts showAlertPopup:@"Error" message:@"No pass entered"];
        return;
    }
    
    if([hintField.text length]==0) {
        [ObjectiveCScripts showAlertPopup:@"Error" message:@"Enter a hint first."];
        return;
    }
    
    [ObjectiveCScripts setUserDefaultValue:passField.text forKey:@"passwordCode"];
    [ObjectiveCScripts setUserDefaultValue:hintField.text forKey:@"passwordHint"];

    messageLabel.alpha=1;
    passField.alpha=0;
    hintField.alpha=0;
    cancelButton.alpha=0;
    goButton.alpha=0;
    [passField resignFirstResponder];
    [hintField resignFirstResponder];
    
    [ObjectiveCScripts showAlertPopupWithDelegate:@"Success!" message:[NSString stringWithFormat:@"Password set to: %@", passField.text] delegate:self tag:2];
	[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"lockAppFlg"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Lock App"];
    
    messageLabel.alpha=0;
    
    passField.text = [ObjectiveCScripts getUserDefaultValue:@"passwordCode"];
    hintField.text = [ObjectiveCScripts getUserDefaultValue:@"passwordHint"];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

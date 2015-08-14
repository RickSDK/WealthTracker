//
//  WebViewVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/23/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemObject.h"
#import "CustomButton.h"
#import "CoreDataLib.h"

@interface WebViewVC : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIViewController *callBackViewController;
@property (nonatomic, strong) ItemObject *itemObject;
@property (nonatomic, strong) NSManagedObject *mo;
@property (nonatomic, strong) NSString *currentUrl;
@property (nonatomic, strong) NSString *webPassword;
@property (nonatomic) BOOL balanceFlg;

@property (nonatomic, strong) IBOutlet UIWebView *mainWebView;
@property (nonatomic, strong) IBOutlet CustomButton *updateValueButton;
@property (nonatomic, strong) IBOutlet CustomButton *updateLinkButton;
@property (nonatomic, strong) IBOutlet UITextField *valueTextField;

@property (nonatomic, strong) IBOutlet UIView *urlView;
@property (nonatomic, strong) IBOutlet UILabel *urlLabel;
@property (nonatomic, strong) IBOutlet UITextField *urlTextField;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;

@property (nonatomic, strong) IBOutlet UIView *passwordView;
@property (nonatomic, strong) IBOutlet UITextField *userTextField;
@property (nonatomic, strong) IBOutlet UITextField *passTextField;
@property (nonatomic, strong) IBOutlet CustomButton *revealPassButton;
@property (nonatomic, strong) IBOutlet CustomButton *setUserButton;
@property (nonatomic, strong) IBOutlet CustomButton *webGoButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) IBOutlet UIView *globalPasswordView;
@property (nonatomic, strong) IBOutlet UITextField *globalpassTextField;
@property (nonatomic, strong) IBOutlet CustomButton *setGlobalPassButton;
@property (nonatomic, strong) IBOutlet CustomButton *resetGlobalPassButton;
@property (nonatomic, strong) IBOutlet CustomButton *infoButton;

@property (nonatomic) BOOL showPasswordFlg;
@property (nonatomic) BOOL creditScoreFlg;


-(IBAction)updateValueButtonClicked:(id)sender;
-(IBAction)updateLinkButtonClicked:(id)sender;
-(IBAction)resetLinkButtonClicked:(id)sender;

-(IBAction)safariButtonClicked:(id)sender;
-(IBAction)urlGoButtonClicked:(id)sender;

-(IBAction)revealButtonClicked:(id)sender;
-(IBAction)setUserButtonClicked:(id)sender;

-(IBAction)setPassButtonClicked:(id)sender;
-(IBAction)resetPassButtonClicked:(id)sender;
-(IBAction)backButtonClicked:(id)sender;
-(IBAction)infoButtonClicked:(id)sender;

@end

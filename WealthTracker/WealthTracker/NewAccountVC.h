//
//  NewAccountVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/28/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceView.h"

@interface NewAccountVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet WebServiceView *webServiceView;

@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UIButton *termsButton;
@property (nonatomic, strong) IBOutlet UISwitch *termsSwitch;


@property (nonatomic, strong) IBOutlet UITextField *fieldNewEmail;
@property (nonatomic, strong) IBOutlet UITextField *fieldNewPassword;
@property (nonatomic, strong) IBOutlet UITextField *rePassword;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;

- (IBAction) submitButtonPressed: (id) sender;
- (IBAction) privacyButtonPressed: (id) sender;
- (IBAction) termsSwitchPressed: (id) sender;

@end

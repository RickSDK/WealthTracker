//
//  LoginVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/28/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceView.h"

@interface LoginVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UITextField *loginEmail;
@property (nonatomic, strong) IBOutlet UITextField *loginPassword;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *forgotButton;

@property (nonatomic, strong) IBOutlet WebServiceView *webServiceView;

- (IBAction) loginPressed: (id) sender;
- (IBAction) forgotPressed: (id) sender;

@end

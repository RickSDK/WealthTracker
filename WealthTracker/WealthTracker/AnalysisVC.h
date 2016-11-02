//
//  AnalysisVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/14/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"

@interface AnalysisVC : TemplateVC

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UIView *myPlanView;
@property (nonatomic, strong) IBOutlet UIView *ButtonsView;

@property (nonatomic, strong) IBOutlet NSMutableArray *dataArray;
@property (nonatomic, strong) IBOutlet NSMutableArray *descArray;

@property (nonatomic, strong) IBOutlet UIImageView *debt1ImageView;
@property (nonatomic, strong) IBOutlet UIImageView *debt2ImageView;
@property (nonatomic, strong) IBOutlet UIImageView *wealthImageView;
@property (nonatomic, strong) IBOutlet UIImageView *homeImageView;
@property (nonatomic, strong) IBOutlet UIImageView *autoImageView;

@property (nonatomic, strong) IBOutlet UIButton *debtButton;
@property (nonatomic, strong) IBOutlet UIButton *wealthButton;
@property (nonatomic, strong) IBOutlet UIButton *homeButton;
@property (nonatomic, strong) IBOutlet UIButton *autoButton;

@property (nonatomic, strong) IBOutlet UITextField *ageTextField;
@property (nonatomic, strong) IBOutlet UITextField *retirementTextField;

@property (nonatomic, strong) IBOutlet UILabel *currentStepLabel;
@property (nonatomic, strong) IBOutlet UILabel *advisorLabel;
@property (nonatomic) double homeEquityThisYear;
@property (nonatomic) double homeEquityThisMonth;
@property (nonatomic) double totalEquity;
@property (nonatomic) double totalEquityThisMonth;
@property (nonatomic) double totalConsumerDebt;
@property (nonatomic) double totalDebt;
@property (nonatomic) double debtThisMonth;

-(IBAction)myPlanButtonClicked:(id)sender;
-(IBAction)detailsButtonClicked:(id)sender;
-(IBAction)homeButtonPressed;
-(IBAction)autoButtonPressed;
-(IBAction)submitButtonClicked:(id)sender;

@end

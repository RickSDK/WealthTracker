//
//  MyPlanVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/14/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPlanVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UIView *stepView;

@property (nonatomic, strong) IBOutlet UIView *tipsView;
@property (nonatomic, strong) IBOutlet UITextView *scrollView;

@property (nonatomic, strong) IBOutlet UIButton *prevButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *tipsButton;
@property (nonatomic, strong) IBOutlet UISwitch *completedSwitch;

@property (nonatomic, strong) IBOutlet UILabel *myStepLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentStepLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *descLabel;

@property (nonatomic, strong) IBOutlet UILabel *progressLabel;

@property (nonatomic) int step;
@property (nonatomic) int myStep;

-(IBAction)nextButtonClicked:(id)sender;
-(IBAction)prevButtonClicked:(id)sender;
-(IBAction)closeTipsButtonClicked:(id)sender;
-(IBAction)openTipsButtonClicked:(id)sender;
-(IBAction)switchClicked:(id)sender;

@end

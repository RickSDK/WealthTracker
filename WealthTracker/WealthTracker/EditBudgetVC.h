//
//  EditBudgetVC.h
//  WealthTracker
//
//  Created by Rick Medved on 5/5/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"

@interface EditBudgetVC : TemplateVC

@property (nonatomic, strong) IBOutlet UISlider *fixedExpenseSlider;
@property (nonatomic, strong) IBOutlet UISlider *monthlySavingsSlider;
@property (nonatomic, strong) IBOutlet UILabel *fixedLabel;
@property (nonatomic, strong) IBOutlet UILabel *savingsLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthlyIncomeLabel;
@property (nonatomic, strong) IBOutlet UILabel *discretionaryBudgetLabel;
@property (nonatomic, strong) IBOutlet UITextField *monthlyIncomeField;
@property (nonatomic, strong) IBOutlet UIButton *continueButton;
@property (nonatomic) int monthlyIncome;
@property (nonatomic) int fixedExpenses;
@property (nonatomic) int monthlySavings;
@property (nonatomic) int discretionaryBudget;

-(IBAction)savingsSliderChanged:(id)sender;
-(IBAction)updateButtonPressed:(id)sender;
-(IBAction)continueButtonPressed:(id)sender;
-(IBAction)info1ButtonPressed:(id)sender;
-(IBAction)info2ButtonPressed:(id)sender;

@end

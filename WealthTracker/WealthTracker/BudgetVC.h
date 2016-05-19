//
//  BudgetVC.h
//  WealthTracker
//
//  Created by Rick Medved on 5/5/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"
#import "BalanceButton.h"

@interface BudgetVC : TemplateVC

@property (nonatomic, strong) IBOutlet BalanceButton *balButton1;
@property (nonatomic, strong) IBOutlet BalanceButton *balButton2;
@property (nonatomic, strong) IBOutlet BalanceButton *balButton3;
@property (nonatomic, strong) IBOutlet BalanceButton *balButton4;
@property (nonatomic, strong) IBOutlet BalanceButton *balButton5;
@property (nonatomic, strong) IBOutlet BalanceButton *balButton6;
@property (nonatomic, strong) IBOutlet UIView *statsView;
@property (nonatomic, strong) IBOutlet UIView *expenseView;
@property (nonatomic, strong) IBOutlet UIView *incomeView;
@property (nonatomic, strong) IBOutlet UIView *cashFlowView;
@property (nonatomic, strong) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *expenseTotalLabel;
@property (nonatomic, strong) IBOutlet UILabel *incomeTotalLabel;
@property (nonatomic, strong) IBOutlet UILabel *bankAccountTotalLabel;

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *subNameTextField;
@property (nonatomic, strong) IBOutlet UIView *editView;
@property (nonatomic, strong) IBOutlet UIButton *iconButton;
@property (nonatomic) int editButton;
@property (nonatomic) int editIcon;

-(IBAction)xButtonClicked:(id)sender;
-(IBAction)symbolButtonClicked:(id)sender;
-(IBAction)submitButtonClicked:(id)sender;


@property (nonatomic) double expensesTotal;
@property (nonatomic) double incomeTotal;

-(IBAction)cashFlowButtonClicked:(id)sender;

@end

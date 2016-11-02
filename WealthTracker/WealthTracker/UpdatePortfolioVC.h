//
//  UpdatePortfolioVC.h
//  WealthTracker
//
//  Created by Rick Medved on 4/27/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"
#import "EditItemVC.h"
#import "ItemObject.h"

@interface UpdatePortfolioVC : TemplateVC <UITextFieldDelegate>

@property (nonatomic, strong) ItemObject *itemObject;
@property (nonatomic, strong) NSMutableArray *namesArray;
@property (nonatomic, strong) NSMutableArray *valuesArray;
@property (nonatomic, strong) NSMutableArray *colorsArray;
@property (nonatomic, strong) NSMutableArray *amountArray;

@property (nonatomic, strong) UITextField *valueTextField;
@property (nonatomic, strong) UITextField *balanceTextField;

@property (nonatomic, strong) IBOutlet UITextField *origValueTextField;
@property (nonatomic, strong) IBOutlet UITextField *origBalanceTextField;
@property (nonatomic, strong) IBOutlet UITextField *origValueTextField2;
@property (nonatomic, strong) IBOutlet UITextField *origBalanceTextField2;
@property (nonatomic, strong) IBOutlet UITextField *origMonthTextField;
@property (nonatomic, strong) IBOutlet UITextField *origYearTextField;
@property (nonatomic, strong) IBOutlet UILabel *origDateLabel;

@property (nonatomic, strong) IBOutlet UIButton *monthUpButton;
@property (nonatomic, strong) IBOutlet UIButton *yearUpButton;
@property (nonatomic, strong) IBOutlet UIButton *monthDownButton;
@property (nonatomic, strong) IBOutlet UIButton *yearDownButton;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong) UIButton *updateValueButton;
@property (nonatomic, strong) UIButton *updateBalanceButton;

@property (nonatomic) int nowDay;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int displayYear;
@property (nonatomic) int displayMonth;
@property (nonatomic) int monthOffset;
@property (nonatomic) int editTextFieldNum;

@property (nonatomic) int origMonth;
@property (nonatomic) int origYear;
@property (nonatomic) int newOrigMonth;
@property (nonatomic) int newOrigYear;
@property (nonatomic) int confirmMonth;
@property (nonatomic) int confirmYear;
@property (nonatomic) double confirmValue;
@property (nonatomic) double confirmBalance;
@property (nonatomic) double startValue;
@property (nonatomic) double startBalance;

-(IBAction)upMonthClicked:(id)sender;
-(IBAction)downMonthClicked:(id)sender;
-(IBAction)upYearClicked:(id)sender;
-(IBAction)downYearClicked:(id)sender;
-(IBAction)updateButtonClicked:(id)sender;


@end

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

@property (nonatomic, strong) UITextField *valueTextField;
@property (nonatomic, strong) UITextField *balanceTextField;

@property (nonatomic, strong) UIButton *updateValueButton;
@property (nonatomic, strong) UIButton *updateBalanceButton;

@property (nonatomic) int nowDay;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int displayYear;
@property (nonatomic) int displayMonth;
@property (nonatomic) int monthOffset;
@property (nonatomic) int editTextFieldNum;

@end

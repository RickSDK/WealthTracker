//
//  StatsPageVC.h
//  BalanceApp
//
//  Created by Rick Medved on 3/30/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"

@interface StatsPageVC : TemplateVC

@property (nonatomic) int bucket;
@property (nonatomic, strong) IBOutlet UIView *entryView;
@property (nonatomic, strong) IBOutlet UIView *botView;
@property (nonatomic, strong) IBOutlet UIView *progressView;
@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalSpentLabel;
@property (nonatomic, strong) IBOutlet UILabel *budgetLabel;
@property (nonatomic, strong) IBOutlet UILabel *remainingLabel;
@property (nonatomic, strong) IBOutlet UILabel *noEntriesLabel;

@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *editDateButton;
@property (nonatomic, strong) IBOutlet UIButton *addItemButton;
@property (nonatomic, strong) IBOutlet UIButton *purchaseTypeButton;
@property (nonatomic, strong) IBOutlet UILabel *purchaseTypeLabel;

@property (nonatomic, strong) IBOutlet UITextField *amountTextField;


@property (nonatomic) float totalSpent;
@property (nonatomic) int selectedRecord;
@property (nonatomic) int paymentType;
@property (nonatomic) BOOL editingFlg;


-(IBAction)topSegmentChanged:(id)sender;
-(IBAction)submitButtonPressed:(id)sender;
-(IBAction)deleteButtonPressed:(id)sender;
-(IBAction)editDateButtonPressed:(id)sender;
-(IBAction)addItemButtonPressed:(id)sender;
-(IBAction)paymentTypeButtonPressed:(id)sender;

@end

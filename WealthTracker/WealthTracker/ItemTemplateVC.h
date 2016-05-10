//
//  ItemTemplateVC.h
//  BalanceApp
//
//  Created by Rick Medved on 4/9/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"

@interface ItemTemplateVC : TemplateVC <UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UILabel *totalAmountLabel;
@property (nonatomic, strong) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *monthButton;
@property (nonatomic, strong) IBOutlet UILabel *dueDateLabel;
@property (nonatomic, strong) IBOutlet UITextField *dueDateField;
@property (nonatomic, strong) NSMutableArray *amountsArray;

@property (nonatomic) int totalAmount;
@property (nonatomic) int selectedType;
@property (nonatomic) int selectedRow;
@property (nonatomic) int itemType;
@property (nonatomic) int numberChecked;
@property (nonatomic) int multiplyer;
@property (nonatomic) BOOL editingFlg;
@property (nonatomic) BOOL clearChecks;

-(IBAction)submitButtonClicked:(id)sender;
-(IBAction)doneButtonClicked:(id)sender;
-(IBAction)deleteButtonClicked:(id)sender;
-(IBAction)newMonthButtonClicked:(id)sender;
-(IBAction)cashFlowButtonClicked:(id)sender;

-(void)showPopup;

@end

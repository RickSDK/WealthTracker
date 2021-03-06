//
//  AssetsDebtsVC.h
//  WealthTracker
//
//  Created by Rick Medved on 5/12/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"
#import "ItemObject.h"
#import "CustomSegment.h"

@interface AssetsDebtsVC : TemplateVC

@property (nonatomic, strong) IBOutlet UIView *bottomView;
@property (nonatomic, strong) IBOutlet UIView *chooseTypeView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalAmountLabel;
@property (nonatomic, strong) IBOutlet UILabel *typeLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *moPayLabel;
@property (nonatomic, strong) IBOutlet UILabel *duesLabel;
@property (nonatomic, strong) IBOutlet UIButton *iconButton;
@property (nonatomic, strong) IBOutlet UIButton *subTypeButton;
@property (nonatomic, strong) IBOutlet UIButton *keyboardButton;
@property (nonatomic, strong) IBOutlet UIButton *viewDetailsButton;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) IBOutlet UITextField *valueTextField;
@property (nonatomic, strong) IBOutlet UITextField *balanceTextField;
@property (nonatomic, strong) IBOutlet UITextField *paymentTextField;
@property (nonatomic, strong) IBOutlet UITextField *interestTextField;
@property (nonatomic, strong) IBOutlet UITextField *duesTextField;
@property (nonatomic, strong) IBOutlet UILabel *interestRateLabel;
@property (nonatomic, strong) IBOutlet CustomSegment *typeSegment;
@property (nonatomic, strong) IBOutlet UISwitch *showAllSwitch;

@property (nonatomic, strong) ItemObject *itemObject;

@property (nonatomic) BOOL showPopup;
@property (nonatomic) BOOL noHistoryFlg;
@property (nonatomic) BOOL newItemFlg;
@property (nonatomic) double totalAmount;
@property (nonatomic) int filterType;
@property (nonatomic) int type;
@property (nonatomic) int subType;

-(IBAction)breakdownButtonClicked:(id)sender;
-(IBAction)submitButtonClicked:(id)sender;
-(IBAction)typeButtonClicked:(id)sender;
-(IBAction)subtypeButtonClicked:(id)sender;
-(IBAction)keyboardButtonClicked:(id)sender;
-(IBAction)viewDetailsButtonClicked:(id)sender;
-(IBAction)typeSegmentChanged:(id)sender;
-(IBAction)showAllSwitchChanged:(id)sender;

@end

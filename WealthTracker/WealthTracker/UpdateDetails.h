//
//  UpdateDetails.h
//  WealthTracker
//
//  Created by Rick Medved on 7/13/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemObject.h"
#import "TemplateVC.h"

@interface UpdateDetails : TemplateVC <UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) ItemObject *itemObject;
@property (nonatomic, strong) NSMutableArray *namesArray;
@property (nonatomic, strong) NSMutableArray *valuesArray;
@property (nonatomic, strong) NSMutableArray *colorsArray;

@property (nonatomic, strong) UITextField *valueTextField;
@property (nonatomic, strong) UITextField *balanceTextField;

@property (nonatomic, strong) UIButton *updateValueButton;
@property (nonatomic, strong) UIButton *updateBalanceButton;
@property (nonatomic, strong) IBOutlet UIButton *prevButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UIButton *payoffButton;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UILabel *monthDisplayLabel;
@property (nonatomic, strong) IBOutlet UIImageView *statusImageView;

@property (nonatomic, strong) IBOutlet UIView *paceView;
@property (nonatomic, strong) IBOutlet UILabel *paceLabel;
@property (nonatomic, strong) IBOutlet UILabel *paceArrowLabel;

@property (nonatomic, strong) IBOutlet UIView *trendView;
@property (nonatomic, strong) IBOutlet UILabel *trendLabel;
@property (nonatomic, strong) IBOutlet UILabel *trendArrowLabel;

@property (nonatomic, strong) IBOutlet UIView *changeView;
@property (nonatomic, strong) IBOutlet UILabel *changeLabel;
@property (nonatomic, strong) IBOutlet UILabel *changeArrowLabel;

@property (nonatomic, strong) IBOutlet UILabel *popupTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *popupDescLabel;
@property (nonatomic, strong) IBOutlet UIView *monthView;


@property (nonatomic) int nowDay;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int displayYear;
@property (nonatomic) int displayMonth;
@property (nonatomic) int monthOffset;
@property (nonatomic) int editTextFieldNum;
@property (nonatomic) double highValue;
@property (nonatomic) double lowValue;

@property (nonatomic) int graphYear;
@property (nonatomic) BOOL displayBarsFlg;

-(void)updateValue:(NSString *)value;
-(void)updateBalance:(NSString *)value;
-(IBAction)payoffButtonPressed:(id)sender;
-(IBAction)menuButtonPressed:(id)sender;
-(IBAction)breakdownButtonPressed:(id)sender;
-(IBAction)prevButtonPressed:(id)sender;
-(IBAction)nextButtonPressed:(id)sender;

@end

//
//  UpdateDetails.h
//  WealthTracker
//
//  Created by Rick Medved on 7/13/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemObject.h"

@interface UpdateDetails : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) ItemObject *itemObject;
@property (nonatomic, strong) NSMutableArray *namesArray;
@property (nonatomic, strong) NSMutableArray *valuesArray;
@property (nonatomic, strong) NSMutableArray *colorsArray;

@property (nonatomic, strong) UITextField *valueTextField;
@property (nonatomic, strong) UITextField *balanceTextField;

@property (nonatomic, strong) UIButton *updateValueButton;
@property (nonatomic, strong) UIButton *updateBalanceButton;

@property (nonatomic, strong) IBOutlet UIButton *payoffButton;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UILabel *amountLabel;
@property (nonatomic, strong) IBOutlet UIImageView *statusImageView;

@property (nonatomic) int nowDay;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int displayYear;
@property (nonatomic) int displayMonth;
@property (nonatomic) int monthOffset;
@property (nonatomic) int editTextFieldNum;

@property (nonatomic) int graphYear;
@property (nonatomic) BOOL displayBarsFlg;

-(void)updateValue:(NSString *)value;
-(void)updateBalance:(NSString *)value;
-(IBAction)payoffButtonPressed:(id)sender;
-(IBAction)menuButtonPressed:(id)sender;
-(IBAction)breakdownButtonPressed:(id)sender;

@end

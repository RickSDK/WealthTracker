//
//  CashFlowEditItemVC.h
//  WealthTracker
//
//  Created by Rick Medved on 8/3/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CashFlowObj.h"

@interface CashFlowEditItemVC : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *managedObject;

@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *amountTextField;
@property (nonatomic, strong) IBOutlet UITextField *dayTextField;
@property (nonatomic, strong) IBOutlet UISwitch *billSwitch;
@property (nonatomic, strong) IBOutlet UILabel *typeLabel;
@property (nonatomic, strong) IBOutlet UISwitch *confirmSwitch;
@property (nonatomic, strong) IBOutlet UILabel *confirmLabel;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *selectButton;
@property (nonatomic, strong) IBOutlet UILabel *FAtypeLabel;
@property (nonatomic, strong) IBOutlet UILabel *typeDescLabel;
@property (nonatomic, strong) IBOutlet UIButton *typeButton;

@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) CashFlowObj *cashFlowObj;
@property (nonatomic) BOOL okToEditFlg;
@property (nonatomic) int type;

- (IBAction) submitButtonPressed: (id) sender;
- (IBAction) billSwitchPressed: (id) sender;
- (IBAction) confirmSwitchPressed: (id) sender;
- (IBAction) deleteButtonPressed: (id) sender;
- (IBAction) selectButtonPressed: (id) sender;
- (IBAction) typeButtonPressed: (id) sender;

@end

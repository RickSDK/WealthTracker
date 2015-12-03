//
//  CashFlowEditItemVC.h
//  WealthTracker
//
//  Created by Rick Medved on 8/3/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CashFlowEditItemVC : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObject *managedObject;

@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *amountTextField;
@property (nonatomic, strong) IBOutlet UITextField *dayTextField;
@property (nonatomic, strong) IBOutlet UISwitch *typeSwitch;
@property (nonatomic, strong) IBOutlet UILabel *typeLabel;
@property (nonatomic, strong) IBOutlet UISwitch *confirmSwitch;
@property (nonatomic, strong) IBOutlet UILabel *confirmLabel;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *selectButton;

@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic) BOOL okToEditFlg;

- (IBAction) submitButtonPressed: (id) sender;
- (IBAction) typeSwitchPressed: (id) sender;
- (IBAction) confirmSwitchPressed: (id) sender;
- (IBAction) deleteButtonPressed: (id) sender;
- (IBAction) selectButtonPressed: (id) sender;

@end

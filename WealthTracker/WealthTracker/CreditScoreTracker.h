//
//  CreditScoreTracker.h
//  WealthTracker
//
//  Created by Rick Medved on 7/31/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditScoreTracker : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;

@property (nonatomic, strong) UITextField *valueTextField;
@property (nonatomic, strong) UIButton *updateValueButton;

@property (nonatomic, strong) NSMutableArray *graphItems;

@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int displayYear;
@property (nonatomic) int displayMonth;

@end

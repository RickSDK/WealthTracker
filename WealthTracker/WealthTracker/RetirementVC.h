//
//  RetirementVC.h
//  WealthTracker
//
//  Created by Rick Medved on 9/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateVC.h"

@interface RetirementVC : TemplateVC

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITextView *textView;

@property (nonatomic, strong) IBOutlet UILabel *netWorthLabel;
@property (nonatomic, strong) IBOutlet UILabel *averageLabel;
@property (nonatomic, strong) IBOutlet UILabel *idealLabel;
@property (nonatomic, strong) IBOutlet UILabel *yourCurrentLabel;
@property (nonatomic, strong) IBOutlet UIImageView *downArrow;
@property (nonatomic, strong) IBOutlet UIView *colorView;

@property (nonatomic, strong) IBOutlet UITextField *ageTextField;
@property (nonatomic, strong) IBOutlet UITextField *retirementTextField;

@property (nonatomic) BOOL finFlg;

-(IBAction)submitButtonClicked:(id)sender;

@end

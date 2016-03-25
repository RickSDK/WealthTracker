//
//  HomeBuyVC.h
//  WealthTracker
//
//  Created by Rick Medved on 3/9/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"

@interface HomeBuyVC : TemplateVC

@property (nonatomic, strong) IBOutlet UILabel *sliderAmountLabel;
@property (nonatomic, strong) IBOutlet UISlider *rateSlider;

@property (nonatomic, strong) IBOutlet UILabel *annualIncomeLabel;
@property (nonatomic, strong) IBOutlet UILabel *consumerDebtLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentHousingLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentDTILabel;

@property (nonatomic, strong) IBOutlet UILabel *loanAMountLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthlyPaymentLabel;
@property (nonatomic, strong) IBOutlet CustomSegment *termSegment;
@property (nonatomic, strong) IBOutlet UISwitch *debtSwitch;

@property (nonatomic) int annualIncome;
@property (nonatomic) int monthlyTakehome;
@property (nonatomic) int totalDebt;
@property (nonatomic) int monthlyPayOnDebt;
@property (nonatomic) int monthlyIncome;


-(IBAction)sliderChanged:(id)sender;
-(IBAction)segmentChanged:(id)sender;
-(IBAction)termSegmentChanged:(id)sender;
-(IBAction)switchChanged:(id)sender;

@end

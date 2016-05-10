//
//  AdjustBudgetVC.h
//  BalanceApp
//
//  Created by Rick Medved on 4/12/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"

@interface AdjustBudgetVC : TemplateVC

@property (nonatomic, strong) IBOutlet UISlider *budget0Slider;
@property (nonatomic, strong) IBOutlet UISlider *budget1Slider;
@property (nonatomic, strong) IBOutlet UISlider *budget2Slider;
@property (nonatomic, strong) IBOutlet UISlider *budget3Slider;
@property (nonatomic, strong) IBOutlet UISlider *budget4Slider;
@property (nonatomic, strong) IBOutlet UISlider *budget5Slider;

@property (nonatomic, strong) IBOutlet UILabel *budget0Label;
@property (nonatomic, strong) IBOutlet UILabel *budget1Label;
@property (nonatomic, strong) IBOutlet UILabel *budget2Label;
@property (nonatomic, strong) IBOutlet UILabel *budget3Label;
@property (nonatomic, strong) IBOutlet UILabel *budget4Label;
@property (nonatomic, strong) IBOutlet UILabel *budget5Label;

@property (nonatomic, strong) IBOutlet UILabel *budgetRemainingLabel;

@property (nonatomic, strong) NSArray *sliders;
@property (nonatomic, strong) NSArray *labels;

@property (nonatomic) int totalBudget;
@property (nonatomic) int remainingBudget;
@property (nonatomic) int selectedSlider;

-(IBAction)sliderMoved:(id)sender;


@end

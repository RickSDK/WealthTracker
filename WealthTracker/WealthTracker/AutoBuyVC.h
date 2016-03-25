//
//  AutoBuyVC.h
//  WealthTracker
//
//  Created by Rick Medved on 3/9/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"

@interface AutoBuyVC : TemplateVC

@property (nonatomic, strong) IBOutlet UILabel *topLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalLabel;
@property (nonatomic, strong) IBOutlet UILabel *percentLabel;
@property (nonatomic, strong) IBOutlet UILabel *availableLabel;

@property (nonatomic, strong) IBOutlet UILabel *conclusionLabel;

@end

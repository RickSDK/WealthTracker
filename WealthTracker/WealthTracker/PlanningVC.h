//
//  PlanningVC.h
//  WealthTracker
//
//  Created by Rick Medved on 3/11/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"

@interface PlanningVC : TemplateVC

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) IBOutlet UIButton *b2bButton;


-(IBAction)myPlanButtonClicked:(id)sender;

@end

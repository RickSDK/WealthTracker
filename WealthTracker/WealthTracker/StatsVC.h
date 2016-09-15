//
//  StatsVC.h
//  WealthTracker
//
//  Created by Rick Medved on 8/31/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"
#import "CustomSegment.h"

@interface StatsVC : TemplateVC

@property (nonatomic, strong) IBOutlet UILabel *totalValueLabel;
@property (nonatomic, strong) IBOutlet CustomSegment *amountSegment;

-(IBAction)amountSegmentChanged:(id)sender;
-(IBAction)topSegmentChanged:(id)sender;

@end

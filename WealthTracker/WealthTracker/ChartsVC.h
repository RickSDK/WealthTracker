//
//  ChartsVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSegment.h"
#import "TemplateVC.h"

@interface ChartsVC : TemplateVC

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet CustomSegment *timeSegment;
@property (nonatomic, strong) IBOutlet CustomSegment *typeSegment;

@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic, strong) NSMutableArray *graphDates;
@property (nonatomic, strong) NSMutableArray *graphSegmentIndexes;

-(IBAction)timeSegmentChanged:(id)sender;
-(IBAction)typeSegmentChanged:(id)sender;

@end

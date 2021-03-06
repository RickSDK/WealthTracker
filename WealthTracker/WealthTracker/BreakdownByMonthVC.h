//
//  BreakdownByMonthVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/22/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemObject.h"
#import "CustomButton.h"
#import "CustomSegment.h"
#import "TemplateVC.h"

@interface BreakdownByMonthVC : TemplateVC

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet CustomSegment *topSegmentControl;
@property (nonatomic, strong) IBOutlet CustomSegment *changeSegmentControl;
@property (nonatomic, strong) IBOutlet UIImageView *topGraphImageView;
@property (nonatomic, strong) IBOutlet UILabel *graphTitleLabel;

@property (nonatomic, strong) IBOutlet UILabel *yearLabel;
@property (nonatomic, strong) IBOutlet CustomButton *prevYearButton;
@property (nonatomic, strong) IBOutlet CustomButton *nextYearButton;

@property (nonatomic, strong) ItemObject *itemObject;
@property (nonatomic, strong) NSMutableArray *dataArray2;

@property (nonatomic) int row_id;
@property (nonatomic) int tag;
@property (nonatomic) int type;
@property (nonatomic) int amount_type;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int displayYear;
@property (nonatomic) int displayMonth;
//@property (nonatomic) int fieldType;

-(IBAction)topSegmentChanged:(id)sender;
-(IBAction)changeSegmentChanged:(id)sender;
-(IBAction)prevYearButtonPressed:(id)sender;
-(IBAction)nextYearButtonPressed:(id)sender;

@end

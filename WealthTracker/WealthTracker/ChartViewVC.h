//
//  ChartViewVC.h
//  WealthTracker
//
//  Created by Rick Medved on 12/1/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "ChartSegmentControl.h"
#import "CustomSegment.h"
#import "ItemObject.h"

@interface ChartViewVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet CustomSegment *topSegmentControl;
@property (nonatomic, strong) IBOutlet ChartSegmentControl *changeSegmentControl;
@property (nonatomic, strong) IBOutlet UIImageView *graphImageView;
@property (nonatomic, strong) IBOutlet UILabel *graphTitleLabel;

@property (nonatomic, strong) IBOutlet UILabel *yearLabel;
@property (nonatomic, strong) IBOutlet CustomButton *prevYearButton;
@property (nonatomic, strong) IBOutlet CustomButton *nextYearButton;

@property (nonatomic, strong) ItemObject *itemObject;
@property (nonatomic, strong) NSMutableArray *dataArray2;
@property (nonatomic) CGPoint startTouchPosition;
@property (nonatomic) float startDegree;
@property (nonatomic, strong) NSMutableArray *chartValuesArray;

@property (nonatomic) int row_id;
@property (nonatomic) int tag;
@property (nonatomic) int type;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int displayYear;
@property (nonatomic) int displayMonth;
@property (nonatomic) int fieldType;
@property (nonatomic) int screen;

-(IBAction)changeSegmentChanged:(id)sender;
-(IBAction)topSegmentChanged:(id)sender;
-(IBAction)prevYearButtonPressed:(id)sender;
-(IBAction)nextYearButtonPressed:(id)sender;

@end

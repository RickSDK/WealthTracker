//
//  BreakdownSingleMonthVC.h
//  WealthTracker
//
//  Created by Rick Medved on 8/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSegment.h"

@interface BreakdownSingleMonthVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet CustomSegment *topSegmentControl;
@property (nonatomic, strong) IBOutlet UILabel *typeLabel;
@property (nonatomic, strong) IBOutlet UILabel *fieldTypeLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) NSMutableArray *fieldNamesArray;
@property (nonatomic, strong) NSMutableArray *fieldValuesArray;
@property (nonatomic, strong) NSMutableArray *fieldColorsArray;
@property (nonatomic, strong) NSMutableArray *dataArray;


@property (nonatomic) int type;
@property (nonatomic) int fieldType;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int displayYear;
@property (nonatomic) int displayMonth;
@property (nonatomic) BOOL pieChartFlg;

@property (nonatomic) CGPoint startTouchPosition;
@property (nonatomic) float startDegree;
@property (nonatomic, strong) IBOutlet UIImageView *graphImageView;
@property (nonatomic, strong) IBOutlet CustomSegment *chartSegmentControl;


-(IBAction)topSegmentChanged:(id)sender;
-(IBAction)prevButtonClicked:(id)sender;
-(IBAction)nextButtonClicked:(id)sender;
-(IBAction)segmentClicked:(id)sender;

@end

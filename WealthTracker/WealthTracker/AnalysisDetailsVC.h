//
//  AnalysisDetailsVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/14/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSegment.h"
#import "TemplateVC.h"

@interface AnalysisDetailsVC : TemplateVC

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *chartValuesArray;

@property (nonatomic, strong) NSMutableArray *namesArray0;
@property (nonatomic, strong) NSMutableArray *valuesArray0;
@property (nonatomic, strong) NSMutableArray *colorsArray0;

@property (nonatomic, strong) NSMutableArray *namesArray1;
@property (nonatomic, strong) NSMutableArray *valuesArray1;
@property (nonatomic, strong) NSMutableArray *colorsArray1;

@property (nonatomic, strong) NSMutableArray *namesArray2;
@property (nonatomic, strong) NSMutableArray *valuesArray2;
@property (nonatomic, strong) NSMutableArray *colorsArray2;

@property (nonatomic, strong) NSString *title0;
@property (nonatomic, strong) NSString *altTitle0;
@property (nonatomic, strong) NSString *title1;
@property (nonatomic, strong) NSString *title2;

@property (nonatomic) int tag;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int displayYear;
@property (nonatomic) int displayMonth;
@property (nonatomic) int monthOffset;
@property (nonatomic) int monthlyIncome;
@property (nonatomic) CGPoint startTouchPosition;
@property (nonatomic) float startDegree;

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet CustomSegment *topSegment;
@property (nonatomic, strong) IBOutlet CustomSegment *typeSegment;
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UILabel *topLeftlabel;
@property (nonatomic, strong) IBOutlet UILabel *topRightlabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *graphImageView;

@property (nonatomic, strong) IBOutlet UILabel *monthBottomLabel;
@property (nonatomic, strong) IBOutlet UILabel *topLeftLabel;
@property (nonatomic, strong) IBOutlet UIButton *prevButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

-(IBAction)topSegmentChanged:(id)sender;
-(IBAction)segmentChanged:(id)sender;
-(IBAction)nextButtonPressed:(id)sender;
-(IBAction)prevButtonPressed:(id)sender;
-(IBAction)typeSegmentChanged:(id)sender;

@end

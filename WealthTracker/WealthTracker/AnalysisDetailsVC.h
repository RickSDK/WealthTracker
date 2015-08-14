//
//  AnalysisDetailsVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/14/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnalysisDetailsVC : UIViewController

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

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *topSegment;
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UILabel *topLeftlabel;
@property (nonatomic, strong) IBOutlet UILabel *topRightlabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

-(IBAction)segmentChanged:(id)sender;

@end

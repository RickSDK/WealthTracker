//
//  TemplateVC.h
//  WealthTracker
//
//  Created by Rick Medved on 3/9/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartSegmentControl.h"
#import "ObjectiveCScripts.h"
#import "CoreDataLib.h"
#import "CustomSegment.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "GraphLib.h"
#import "GraphCell.h"
#import "MultiLineDetailCellWordWrap.h"

@interface TemplateVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet CustomSegment *topSegment;
@property (nonatomic, strong) NSMutableArray *itemsArray;
@property (nonatomic, strong) NSString *analysisStr;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) NSString *altStr;
@property (nonatomic, strong) NSMutableArray *graphObjects;
@property (nonatomic, strong) IBOutlet UIImageView *chartImageView;
@property (nonatomic, strong) IBOutlet CustomSegment *mainSegmentControl;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UIView *popupView;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *amountTextField;
@property (nonatomic, strong) IBOutlet UITextField *dueDayTextField;

@property (nonatomic) int step;
@property (nonatomic) double monthlyBudget;
@property (nonatomic) double monthlySpent;
@property (nonatomic) double monthlyProjected;
@property (nonatomic) CGPoint startTouchPosition;
@property (nonatomic) float startDegree;
@property (nonatomic) BOOL expiredFlg;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;

-(float)screenWidth;
-(float)screenHeight;
-(IBAction)xButtonClicked:(id)sender;
-(IBAction)topSegmentChanged:(id)sender;
-(NSString *)budgetAnalysis:(NSString *)name budget:(int)budget spent:(int)spent;

@end

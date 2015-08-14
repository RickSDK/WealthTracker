//
//  ChartsVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartsVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;

@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
//@property (nonatomic) int displayMonth;
@property (nonatomic, strong) NSArray *graphTitles;
@property (nonatomic, strong) NSMutableArray *graphDates;
@property (nonatomic, strong) NSMutableArray *graphSegmentIndexes;

@end

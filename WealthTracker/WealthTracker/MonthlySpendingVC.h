//
//  MonthlySpendingVC.h
//  WealthTracker
//
//  Created by Rick Medved on 8/18/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthlySpendingVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *multiLineArray;
@property (nonatomic, strong) NSMutableArray *graphArray;

@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int displayMonth;
@property (nonatomic) int displayYear;


@property (nonatomic) BOOL pieChartFlg;



@end

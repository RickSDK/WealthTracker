//
//  SelectListVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/11/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectListVC : UIViewController

@property (nonatomic, strong) UIViewController *callbackController;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic) int listNumber;

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@end

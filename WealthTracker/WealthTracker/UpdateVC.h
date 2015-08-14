//
//  UpdateVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/13/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateVC : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *propertyArray;
@property (nonatomic, strong) NSMutableArray *vehicleArray;
@property (nonatomic, strong) NSMutableArray *debtArray;
@property (nonatomic, strong) NSMutableArray *assetArray;

@property (nonatomic, strong) NSMutableArray *amountArray;

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UILabel *netWorthLabel;
@property (nonatomic, strong) IBOutlet UIImageView *topImageView;
@property (nonatomic, strong) IBOutlet UILabel *graphTitleLabel;

@property (nonatomic, strong) IBOutlet UIImageView *statusImageView;
@property (nonatomic, strong) IBOutlet UILabel *statusCountLabel;

@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int nowDay;
@property (nonatomic) int nextItemDue;
@property (nonatomic) BOOL expiredFlg;
@property (nonatomic) BOOL displayPieFlg;

@end

//
//  MainMenuVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/10/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UILabel *assetsLabel;
@property (nonatomic, strong) IBOutlet UILabel *debtsLabel;
@property (nonatomic, strong) IBOutlet UILabel *netWorthLabel;
@property (nonatomic, strong) IBOutlet UIView *netWorthView;
@property (nonatomic, strong) IBOutlet UIView *botView;
@property (nonatomic, strong) IBOutlet UIImageView *graphImageView;
@property (nonatomic, strong) IBOutlet UIImageView *updateStatusImageView;

@property (nonatomic, strong) IBOutlet UIView *popUpView;
@property (nonatomic, strong) IBOutlet UILabel *popupDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *popupAssetLabel;
@property (nonatomic, strong) IBOutlet UILabel *popupDebtsLabel;
@property (nonatomic, strong) IBOutlet UILabel *popupNWLabel;
@property (nonatomic, strong) IBOutlet UILabel *popupLast30Label;
@property (nonatomic, strong) IBOutlet UIImageView *popupValImageView;
@property (nonatomic, strong) IBOutlet UIImageView *popupBalImageView;

@property (nonatomic, strong) IBOutlet UIImageView *redCircleImageView;
@property (nonatomic, strong) IBOutlet UILabel *needsUpdatingLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentYearLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UILabel *percentUpdatedLabel;


@property (nonatomic, strong) NSMutableArray *popupArray;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) BOOL expiredFlg;

-(IBAction)editButtonClicked:(id)sender;
-(IBAction)updateButtonClicked:(id)sender;
-(IBAction)chartsButtonClicked:(id)sender;
-(IBAction)analysisButtonClicked:(id)sender;

@end

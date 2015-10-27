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
@property (nonatomic, strong) IBOutlet UILabel *netWorthChangeLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthBotLabel;
@property (nonatomic, strong) IBOutlet UILabel *assetChangeLabel;
@property (nonatomic, strong) IBOutlet UILabel *debtChangeLabel;
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
@property (nonatomic, strong) IBOutlet UILabel *updateNumberLabel;
@property (nonatomic, strong) IBOutlet UIImageView *popupValImageView;
@property (nonatomic, strong) IBOutlet UIImageView *popupBalImageView;

@property (nonatomic, strong) IBOutlet UIImageView *redCircleImageView;
@property (nonatomic, strong) IBOutlet UILabel *needsUpdatingLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentYearLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UILabel *percentUpdatedLabel;
@property (nonatomic, strong) IBOutlet UILabel *netWorthNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *assetNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *debtNameLabel;
@property (nonatomic, strong) IBOutlet UISwitch *displaySwitch;
@property (nonatomic, strong) IBOutlet UIButton *financesButton;

@property (nonatomic, strong) IBOutlet UIButton *portfolioButton;
@property (nonatomic, strong) IBOutlet UIButton *myPlanButton;
@property (nonatomic, strong) IBOutlet UIButton *chartsButton;
@property (nonatomic, strong) IBOutlet UIButton *analysisButton;

@property (nonatomic, strong) IBOutlet UIImageView *arrowImage;
@property (nonatomic, strong) IBOutlet UIView *messageView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;



@property (nonatomic, strong) NSMutableArray *popupArray;
@property (nonatomic) int nowYear;
@property (nonatomic) int nowMonth;
@property (nonatomic) int initStep;
@property (nonatomic) BOOL expiredFlg;
@property (nonatomic) BOOL showChartFlg;

-(IBAction)myPlanButtonClicked:(id)sender;
-(IBAction)updateButtonClicked:(id)sender;
-(IBAction)chartsButtonClicked:(id)sender;
-(IBAction)analysisButtonClicked:(id)sender;
-(IBAction)displaySwitchChanged:(id)sender;
-(IBAction)financesButtonClicked:(id)sender;
-(IBAction)okButtonClicked:(id)sender;

@end

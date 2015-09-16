//
//  RateVC.h
//  WealthTracker
//
//  Created by Rick Medved on 9/15/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RateVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UIImageView *graphImageView;

@property (nonatomic, strong) IBOutlet UILabel *monthTopLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthlyLabel;
@property (nonatomic, strong) IBOutlet UILabel *dailyLabel;
@property (nonatomic, strong) IBOutlet UILabel *hourlyLabel;

@property (nonatomic, strong) IBOutlet UILabel *homeLabel;
@property (nonatomic, strong) IBOutlet UILabel *vehicleLabel;
@property (nonatomic, strong) IBOutlet UILabel *assetLabel;
@property (nonatomic, strong) IBOutlet UILabel *debtLabel;

@property (nonatomic, strong) IBOutlet UISwitch *homeSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *vehicleSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *assetSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *debtSwitch;

-(IBAction)switchChanged:(id)sender;

@end

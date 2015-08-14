//
//  StartupVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/10/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImageView.h"

@interface StartupVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UIButton *profileButton;
@property (nonatomic, strong) IBOutlet UIButton *housingButton;
@property (nonatomic, strong) IBOutlet UIButton *vehiclesButton;
@property (nonatomic, strong) IBOutlet UIButton *debtsButton;
@property (nonatomic, strong) IBOutlet UIButton *assetsButton;

@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) IBOutlet UIImageView *housingImageView;
@property (nonatomic, strong) IBOutlet UIImageView *vehiclesImageView;
@property (nonatomic, strong) IBOutlet UIImageView *debtsImageView;
@property (nonatomic, strong) IBOutlet UIImageView *assetsImageView;

@property (nonatomic) BOOL profileFlg;
@property (nonatomic) BOOL housingFlg;
@property (nonatomic) BOOL vehiclesFlg;
@property (nonatomic) BOOL debtsFlg;
@property (nonatomic) BOOL assetsFlg;

-(IBAction)profileButtonClicked:(id)sender;
-(IBAction)housingButtonClicked:(id)sender;
-(IBAction)vehiclesButtonClicked:(id)sender;
-(IBAction)debtsButtonClicked:(id)sender;
-(IBAction)assetsButtonClicked:(id)sender;

//-(void)buttonCompleted:(int)tag;

@end

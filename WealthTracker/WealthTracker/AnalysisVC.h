//
//  AnalysisVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/14/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnalysisVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet UIView *myPlanView;
@property (nonatomic, strong) IBOutlet UIView *ButtonsView;

@property (nonatomic, strong) IBOutlet UIImageView *debt1ImageView;
@property (nonatomic, strong) IBOutlet UIImageView *debt2ImageView;
@property (nonatomic, strong) IBOutlet UIImageView *wealthImageView;
@property (nonatomic, strong) IBOutlet UIImageView *homeImageView;
@property (nonatomic, strong) IBOutlet UIImageView *autoImageView;

@property (nonatomic, strong) IBOutlet UILabel *currentStepLabel;

-(IBAction)myPlanButtonClicked:(id)sender;
-(IBAction)detailsButtonClicked:(id)sender;

@end

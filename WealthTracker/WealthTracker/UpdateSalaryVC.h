//
//  UpdateSalaryVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/23/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateSalaryVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITextField *amountTextField;
@property (nonatomic, strong) IBOutlet UILabel *yearLabel;
@property (nonatomic, strong) IBOutlet UIImageView *statusImageView;
@property (nonatomic, strong) IBOutlet UIStepper *yearStepper;

@property (nonatomic) int displayYear;

-(IBAction)stepperClicked:(id)sender;
-(IBAction)updateButtonClicked:(id)sender;

@end

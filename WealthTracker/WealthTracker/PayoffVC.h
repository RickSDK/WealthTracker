//
//  PayoffVC.h
//  WealthTracker
//
//  Created by Rick Medved on 8/27/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemObject.h"

@interface PayoffVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentBalanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentPaydownLabel;
@property (nonatomic, strong) IBOutlet UILabel *displayPaydownLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthsLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *interestLabel;
@property (nonatomic, strong) IBOutlet UISlider *amountSlider;

@property (nonatomic, strong) ItemObject *itemObject;
@property (nonatomic) int row_id;
@property (nonatomic) double totalAmount;
@property (nonatomic) float currentPaydownAmount;
@property (nonatomic) float interestRate;
@property (nonatomic) int displayPaydownAmount;

-(IBAction)sliderChanged:(id)sender;

@end

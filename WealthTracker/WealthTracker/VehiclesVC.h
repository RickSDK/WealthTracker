//
//  VehiclesVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/11/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VehiclesVC : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIViewController *callbackController;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSMutableArray *managedObjArray;
@property (nonatomic, strong) IBOutlet UILabel *testLabel;

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;

@property (nonatomic, strong) IBOutlet UIStepper *vehicleStepper;
@property (nonatomic, strong) IBOutlet UILabel *countLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *descLabel;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;

@property (nonatomic) int type;
@property (nonatomic) int sub_type;
@property (nonatomic) int selectedRow;

-(IBAction)stepperClicked:(id)sender;

@end

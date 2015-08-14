//
//  OptionsVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/28/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceView.h"

@interface OptionsVC : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UILabel *userLabel;
@property (nonatomic, strong) IBOutlet UIButton *upgradeButton;
@property (nonatomic, strong) IBOutlet WebServiceView *webServiceView;

@property (nonatomic, strong) NSArray *menuItems;

-(IBAction)upgradeButtonClicked:(id)sender;

@end

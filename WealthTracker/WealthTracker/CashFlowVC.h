//
//  CashFlowVC.h
//  WealthTracker
//
//  Created by Rick Medved on 8/3/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CashFlowVC : UIViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UITextField *amountTextField;
@property (atomic) BOOL fetchIsReady;
@property (nonatomic, strong) IBOutlet UILabel *surplusLabel;

@property (nonatomic, strong) NSMutableArray *amountsArray;

- (IBAction) submitButtonPressed: (id) sender;
- (IBAction) newMonthButtonPressed: (id) sender;

@end

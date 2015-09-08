//
//  EditItemVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/11/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileObj.h"
#import "ItemObject.h"
#import "CoreDataLib.h"

@interface EditItemVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIViewController *callbackController;
@property (nonatomic, strong) NSMutableArray *cellObjArray;

@property (nonatomic, strong) ProfileObj *profileObj;
@property (nonatomic, strong) ItemObject *itemObject;
@property (nonatomic, strong) NSManagedObject *managedObj;

@property (nonatomic, strong) NSString *titleString;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UILabel *testLabel;
@property (nonatomic, strong) IBOutlet UILabel *topDescLabel;

@property (nonatomic) int type;
@property (nonatomic) int sub_type;
@property (nonatomic) int tagSelected;
@property (nonatomic) BOOL stuffChangedFlg;

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;

-(void)updateValue:(NSString *)value;
-(IBAction)deleteButtonClicked:(id)sender;

@end

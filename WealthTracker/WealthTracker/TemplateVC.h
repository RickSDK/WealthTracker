//
//  TemplateVC.h
//  WealthTracker
//
//  Created by Rick Medved on 3/9/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartSegmentControl.h"
#import "ObjectiveCScripts.h"
#import "CoreDataLib.h"
#import "CustomSegment.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"

@interface TemplateVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet CustomSegment *mainSegmentControl;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;

@end

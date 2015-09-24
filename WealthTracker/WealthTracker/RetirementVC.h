//
//  RetirementVC.h
//  WealthTracker
//
//  Created by Rick Medved on 9/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RetirementVC : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITextView *textView;

@end

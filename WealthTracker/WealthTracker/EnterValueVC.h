//
//  EnterValueVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/10/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemCellObj.h"

@interface EnterValueVC : UIViewController

@property (nonatomic, strong) UIViewController *callbackController;
@property (nonatomic, strong) ItemCellObj *cellObject;

@property (nonatomic, strong) IBOutlet UITextField *numberTextField;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *prevValueLabel;

@end

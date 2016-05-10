//
//  BalanceButton.h
//  BalanceApp
//
//  Created by Rick Medved on 4/8/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"

@interface BalanceButton : UIView

@property (nonatomic, strong) UIButton *budgetButton;
@property (nonatomic, strong) UIView *barView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *budgetLabel;

-(void)setButtonTitleForType:(int)type delegate:(id)delegate sel:(SEL)sel;
-(void)setBarValue:(float)value max:(float)max;
-(double)updateBudgetAmount:(NSManagedObjectContext *)context;

@end

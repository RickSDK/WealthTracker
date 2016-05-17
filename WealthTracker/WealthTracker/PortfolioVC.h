//
//  PortfolioVC.h
//  WealthTracker
//
//  Created by Rick Medved on 5/12/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "TemplateVC.h"

@interface PortfolioVC : TemplateVC <UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UILabel *netWorthLabel;
@property (nonatomic, strong) IBOutlet UILabel *netWorthChangeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *topImageView;
@property (nonatomic, strong) IBOutlet UILabel *graphTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *portfolioLabel;
@property (nonatomic, strong) IBOutlet ChartSegmentControl *pieSegment;
@property (nonatomic, strong) IBOutlet UIImageView *graphImageView;

@property (nonatomic, strong) IBOutlet UIView *netWorthView;
@property (nonatomic, strong) IBOutlet UIView *assetView;
@property (nonatomic, strong) IBOutlet UIView *debtView;
@property (nonatomic, strong) IBOutlet UILabel *assetTotalLabel;
@property (nonatomic, strong) IBOutlet UILabel *assetChangeLabel;
@property (nonatomic, strong) IBOutlet UILabel *debtTotalLabel;
@property (nonatomic, strong) IBOutlet UILabel *debtChangeLabel;

@property (nonatomic, strong) NSMutableArray *propertyArray;
@property (nonatomic, strong) NSMutableArray *vehicleArray;
@property (nonatomic, strong) NSMutableArray *debtArray;
@property (nonatomic, strong) NSMutableArray *assetArray;

@property (nonatomic, strong) NSMutableArray *amountArray;
@property (nonatomic, strong) NSMutableArray *totalArray;
@property (nonatomic, strong) NSMutableArray *graphArray;
@property (nonatomic) double maxBalance;

@end

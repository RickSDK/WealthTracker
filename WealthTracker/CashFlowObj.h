//
//  CashFlowObj.h
//  WealthTracker
//
//  Created by Rick Medved on 5/5/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCScripts.h"

@interface CashFlowObj : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *a1;
@property (nonatomic, strong) NSString *a2;
@property (nonatomic, strong) NSString *category;

@property (nonatomic) float amount;
@property (nonatomic) int type;
@property (nonatomic) int statement_day;
@property (nonatomic) BOOL confirmFlg;

+(CashFlowObj *)objFromMO:(NSManagedObject *)mo context:(NSManagedObjectContext *)context;

@end

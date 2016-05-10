//
//  CashFlowObj.m
//  WealthTracker
//
//  Created by Rick Medved on 5/5/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "CashFlowObj.h"

@implementation CashFlowObj

+(CashFlowObj *)objFromMO:(NSManagedObject *)mo context:(NSManagedObjectContext *)context {
	CashFlowObj *obj = [[CashFlowObj alloc] init];
	obj.name = [mo valueForKey:@"name"];
	obj.category = [mo valueForKey:@"category"];
	obj.amount = [[mo valueForKey:@"amount"] floatValue];
	obj.type = [[mo valueForKey:@"type"] intValue];
	obj.statement_day = [[mo valueForKey:@"statement_day"] intValue];
	obj.confirmFlg = [[mo valueForKey:@"confirmFlg"] boolValue];
	
	
	return obj;
}

@end

//
//  PurchaseObj.m
//  WealthTracker
//
//  Created by Rick Medved on 5/7/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "PurchaseObj.h"
#import "NSDate+ATTDate.h"
#import "ObjectiveCScripts.h"

@implementation PurchaseObj

+(PurchaseObj *)objFromMO:(NSManagedObject *)mo {
	PurchaseObj *item1 = [[PurchaseObj alloc] init];
	NSDate *dateStamp = [mo valueForKey:@"dateStamp"];
	float amount = [[mo valueForKey:@"amount"] floatValue];
	item1.amount = amount;
	item1.bucket = [[mo valueForKey:@"bucket"] intValue];
	item1.name = [mo valueForKey:@"name"];
	item1.purchaseId = [[mo valueForKey:@"purchaseId"] intValue];
	item1.amountStr = [ObjectiveCScripts convertNumberToMoneyString:amount];
	
	item1.month = [dateStamp convertDateToStringWithFormat:@"MMM"];
	item1.day = [dateStamp convertDateToStringWithFormat:@"dd"];
	return item1;
}

@end

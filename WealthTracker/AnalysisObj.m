//
//  AnalysisObj.m
//  WealthTracker
//
//  Created by Rick Medved on 9/8/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "AnalysisObj.h"
#import "ObjectiveCScripts.h"

@implementation AnalysisObj


+(AnalysisObj *)objectWithTitle:(NSString *)title value:(NSString *)value amount:(double)amount hi:(int)hi lo:(int)lo reverseFlg:(BOOL)reverseFlg delta:(BOOL)delta
{
	AnalysisObj *obj = [[AnalysisObj alloc] init];
	obj.title = title;
	obj.value=value;
	if(value.length==0)
		obj.value = [ObjectiveCScripts convertNumberToMoneyString:amount];
	obj.color = (amount>=0)?[UIColor greenColor]:[UIColor redColor];
	obj.hi = hi;
	obj.lo = lo;
	obj.reverseFlg = reverseFlg;
	obj.amount = amount;
	if(delta && amount>0 && value.length==0)
		obj.value = [NSString stringWithFormat:@"+%@", obj.value];
		
	return obj;
}

@end

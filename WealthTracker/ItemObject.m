//
//  ItemObject.m
//  WealthTracker
//
//  Created by Rick Medved on 7/11/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "ItemObject.h"
#import "CoreDataLib.h"

@implementation ItemObject

+(NSManagedObject *)moFromObject:(ItemObject *)obj context:(NSManagedObjectContext *)context {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rowId = %d", [obj.rowId intValue]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:nil mOC:context ascendingFlg:NO];
	if(items.count>0)
		return [items objectAtIndex:0];
	
	return nil;
	
}

@end

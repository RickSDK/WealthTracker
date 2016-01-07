    //
//  CoreDataLib.m
//  PokerTracker
//
//  Created by Rick Medved on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreDataLib.h"
#import "NSString+ATTString.h"
#import "NSDate+ATTDate.h"
#import "ObjectiveCScripts.h"

#define kLOG2 1

@implementation CoreDataLib

+(UIColor *)getFieldColor:(int)value
{
	if(value>0)
		return [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	if(value<0)
		return [UIColor redColor];
	return [UIColor blackColor];
}

+(NSString *)autoIncrementNumber {
	int number = [[ObjectiveCScripts getUserDefaultValue:@"rowId"] intValue];
	number++;
	[ObjectiveCScripts setUserDefaultValue:[NSString stringWithFormat:@"%d", number] forKey:@"rowId"];
	return [NSString stringWithFormat:@"%d", number];
}



+(NSArray *)selectRowsFromTable:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC
{
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:mOC];
	[fetch setEntity:entity];

	NSError *error;
	NSArray *items = [mOC executeFetchRequest:fetch error:&error];
	
	return items;
}


+(NSArray *)selectRowsFromEntity:(NSString *)entityName predicate:(NSPredicate *)predicate sortColumn:(NSString *)sortColumn mOC:(NSManagedObjectContext *)mOC ascendingFlg:(BOOL)ascendingFlg
{

     if(mOC==nil)
        return nil;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:mOC];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];

    if(predicate != nil)
		[request setPredicate:predicate];
    
 	if([sortColumn length]>0) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortColumn ascending:ascendingFlg];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	}

    NSError *error=nil;
	NSArray *items = [mOC executeFetchRequest:request error:&error];
    return items;

}

+(NSArray *)selectRowsFromEntityWithLimit:(NSString *)entityName predicate:(NSPredicate *)predicate sortColumn:(NSString *)sortColumn mOC:(NSManagedObjectContext *)mOC ascendingFlg:(BOOL)ascendingFlg limit:(int)limit
{
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:mOC];
	[fetch setEntity:entity];
	if(limit>0)
		[fetch setFetchLimit:limit];
	
	if(predicate != nil)
		[fetch setPredicate:predicate];
	
	
	if(sortColumn != nil) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortColumn ascending:ascendingFlg];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[fetch setSortDescriptors:sortDescriptors];
	}
	
	NSError *error;
	NSArray *items = [mOC executeFetchRequest:fetch error:&error];
	
	
	return items;
}


+(void)dumpContentsOfTable:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC key:(NSString *)key
{
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:mOC];
	[fetch setEntity:entity];
	
	NSError *error;
	NSArray *items = [mOC executeFetchRequest:fetch error:&error];
	
	for (NSManagedObject *mo in items) {
			NSString *name = [mo valueForKey:key];
			NSLog(@"%@: %@", key, name);
	}
}

+(NSString *)getFieldValueForEntity:(NSManagedObjectContext *)mOC entityName:(NSString *)entityName field:(NSString *)field predString:(NSString *)predString indexPathRow:(int)indexPathRow
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
	NSArray *items = [CoreDataLib selectRowsFromEntity:entityName predicate:predicate sortColumn:@"startTime" mOC:mOC ascendingFlg:YES];
	if([items count]>indexPathRow) {
		NSManagedObject *mo = [items objectAtIndex:indexPathRow];
		return [mo valueForKey:field];
	}
	return @"";
}

+(NSString *)getFieldValueForEntityWithPredicate:(NSManagedObjectContext *)mOC entityName:(NSString *)entityName field:(NSString *)field predicate:(NSPredicate *)predicate indexPathRow:(int)indexPathRow
{
	NSArray *items = [CoreDataLib selectRowsFromEntity:entityName predicate:predicate sortColumn:nil mOC:mOC ascendingFlg:YES];
	if([items count]>indexPathRow) {
		NSManagedObject *mo = [items objectAtIndex:indexPathRow];
		return [mo valueForKey:field];
	}
	return @"";
}

+(int)updateStreak:(int)streak winAmount:(int)winAmount
{
	if(winAmount>=0) {
		if(streak>0)
			streak++;
		else
			streak=1;
		
	} else {
		if(streak>0)
			streak=-1;
		else
			streak--;
	}
	return streak;
}

+(int)updateWinLoss:(int)gameCount winAmount:(int)winAmount winFlag:(BOOL)winFlag
{
	if(winFlag) {
		if(winAmount>=0)
			gameCount++;
	} else {
		if(winAmount<0)
			gameCount++;
	}
	return gameCount;
}

+(BOOL) insertAttributeManagedObject:(NSString *)entityName valueList:(NSArray *)valueList mOC:(NSManagedObjectContext *)mOC
{
	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:mOC];
	NSMutableArray *keyList = [[NSMutableArray alloc] init];
	NSMutableArray *typeList = [[NSMutableArray alloc] init];
	
	for(int i=0; i<valueList.count; i++) {
		[keyList addObject:@"name"];
		[typeList addObject:@"text"];
	}
	return [CoreDataLib updateManagedObject:mo keyList:keyList valueList:valueList typeList:typeList mOC:mOC];
}

+(BOOL) insertManagedObject:(NSString *)entityName keyList:(NSArray *)keyList valueList:(NSArray *)valueList typeList:(NSArray *)typeList mOC:(NSManagedObjectContext *)mOC
{
	NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:mOC];
	return [CoreDataLib updateManagedObject:mo keyList:keyList valueList:valueList typeList:typeList mOC:mOC];
}

+(BOOL) updateManagedObject:(NSManagedObject *)newManagedObject keyList:(NSArray *)keyList valueList:(NSArray *)valueList typeList:(NSArray *)typeList mOC:(NSManagedObjectContext *)mOC
{
	if([keyList count] != [valueList count] || [keyList count] != [typeList count]) {
		NSLog(@"WARNING!! Unmatching number of columns in newManagedObject: v=%d k=%d t=%lu", (int)[valueList count], (int)[keyList count], (unsigned long)[typeList count]);
	}
	int i=0;
	for(NSString *key in keyList) {
		if(i<[valueList count] && i<[typeList count]) {
			NSString *type = [typeList objectAtIndex:i];
			NSString *value = [valueList objectAtIndex:i];
            if([type isEqualToString:@"int"] && [value length]==0)
                value = @"0";
            
			if(kLOG2)
				NSLog(@"%@ (%@) = '%@'", key, type, value);
			if([type isEqualToString:@"text"])
				[newManagedObject setValue:value forKey:key];
			if([type isEqualToString:@"date"]) {
                NSDate *inputDate = [value convertStringToDateWithFormat:nil];
                 if(inputDate==nil)
                    inputDate = [value convertStringToDateWithFormat:@"MM/dd/yyyy hh:mm:ss a"];
                if(inputDate==nil)
                    inputDate = [NSDate date];
                
				[newManagedObject setValue:inputDate forKey:key];
            }
			if([type isEqualToString:@"time"])
				[newManagedObject setValue:[value convertStringToDateWithFormat:@"MM/dd/yyyy hh:mm:ss a"] forKey:key];
			if([type isEqualToString:@"shortDate"])
				[newManagedObject setValue:[value convertStringToDateWithFormat:@"yyyy-MM-dd"] forKey:key];
			if([type isEqualToString:@"int"])
				[newManagedObject setValue:[NSNumber numberWithInt:[value intValue]] forKey:key];
			if([type isEqualToString:@"float"])
				[newManagedObject setValue:[NSNumber numberWithDouble:[value doubleValue]] forKey:key];
			if([type isEqualToString:@"double"])
				[newManagedObject setValue:[NSNumber numberWithDouble:[value doubleValue]] forKey:key];
			if([type isEqualToString:@"key"])
				[newManagedObject setValue:[valueList objectAtIndex:i] forKey:key];
			i++;
		} else {
			NSLog(@"key: '%@' not populated", key);
		}

	}
	
    NSError *error = nil;
    if (![mOC save:&error]) {
		NSLog(@"Error whoa! %@", error.localizedDescription);
		return FALSE;
	}
	return TRUE;
	
}

+(NSArray *)getEntityNameList:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC
{
	NSMutableArray *finalList = [[NSMutableArray alloc] init];
	NSArray *items = [CoreDataLib selectRowsFromEntity:entityName predicate:nil sortColumn:@"name" mOC:mOC ascendingFlg:YES];
	for (NSManagedObject *mo in items) {
		NSString *name = [mo valueForKey:@"name"];
		[finalList addObject:name];
	}
	return finalList;
}

+(NSArray *)getFieldList:(NSString *)name mOC:(NSManagedObjectContext *)mOC addAllTypesFlg:(BOOL)addAllTypesFlg
{
	NSMutableArray *finalList = [[NSMutableArray alloc] init];
	NSArray *list;
	if([name isEqualToString:@"Game"])
		list = [CoreDataLib getEntityNameList:@"GAMETYPE" mOC:mOC];
	else if([name isEqualToString:@"Game Type"])
		list = [NSArray arrayWithObjects:@"Cash", @"Tournament", nil];
	else if([name isEqualToString:@"Bankroll"])
		list = [CoreDataLib getEntityNameList:@"BANKROLL" mOC:mOC];
	else if([name isEqualToString:@"Location"])
		list = [CoreDataLib getEntityNameList:@"LOCATION" mOC:mOC];
	else if([name isEqualToString:@"Limit"])
		list = [CoreDataLib getEntityNameList:@"LIMIT" mOC:mOC];
	else if([name isEqualToString:@"Stakes"])
		list = [CoreDataLib getEntityNameList:@"STAKES" mOC:mOC];
	else if([name isEqualToString:@"Tournament Type"])
		list = [CoreDataLib getEntityNameList:@"TOURNAMENT" mOC:mOC];
	else
		list = [NSArray arrayWithObjects:name, nil];
	
	NSString *displayName = name;
	if([name isEqualToString:@"Stakes"])
		displayName = @"Stake";
	
	if(addAllTypesFlg) {
		[finalList addObject:[NSString stringWithFormat:@"All %@s", displayName]];
		if(![name isEqualToString:@"Game Type"])
			[finalList addObject:@"*Custom*"];
	}

	for(NSString *value in list)
		[finalList addObject:value];
	
	return finalList;
}

+(int)calculateActiveYearsPlaying:(NSManagedObjectContext *)mOC
{
	int thisYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int minYear = thisYear;
	NSArray *items = [CoreDataLib selectRowsFromTable:@"GAME" mOC:mOC];
	for (NSManagedObject *mo in items) {
		//		NSDate *startDate = [mo valueForKey:@"startTime"];
		int year = [[mo valueForKey:@"year"] intValue];
		if(year<minYear)
			minYear=year;
	}
	
	return thisYear-minYear+1;
}

+(NSManagedObject *)managedObjFromId:(NSString *)rowId managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"rowId = %d", [rowId intValue]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
	if(items.count>0)
		return [items objectAtIndex:0];
	
	[ObjectiveCScripts showAlertPopup:@"ERROR" message:@"no managed Object Found!"];

	return nil;
}

+(int)getNumberFromProfile:(NSString *)field mOC:(NSManagedObjectContext *)mOC {
	NSArray *profile = [CoreDataLib selectRowsFromEntity:@"PROFILE" predicate:nil sortColumn:nil mOC:mOC ascendingFlg:NO];
	if(profile.count>0) {
		NSManagedObject *mo = [profile objectAtIndex:0];
		return [[mo valueForKey:field] intValue];
	}
	return 0;
}

+(NSString *)getTextFromProfile:(NSString *)field mOC:(NSManagedObjectContext *)mOC {
	NSArray *profile = [CoreDataLib selectRowsFromEntity:@"PROFILE" predicate:nil sortColumn:nil mOC:mOC ascendingFlg:NO];
	if(profile.count>0) {
		NSManagedObject *mo = [profile objectAtIndex:0];
		return [[mo valueForKey:field] description];
	}
	return @"-Error-";
}

+(void)saveTextToProfile:(NSString *)field value:(NSString *)value context:(NSManagedObjectContext *)context
{
	NSArray *profile = [CoreDataLib selectRowsFromEntity:@"PROFILE" predicate:nil sortColumn:nil mOC:context ascendingFlg:NO];
	if(profile.count>0) {
		NSManagedObject *mo = [profile objectAtIndex:0];
		[mo setValue:value forKey:field];
		[context save:nil];
	}
}

+(void)saveNumberToProfile:(NSString *)field value:(double)value context:(NSManagedObjectContext *)context
{
	NSArray *profile = [CoreDataLib selectRowsFromEntity:@"PROFILE" predicate:nil sortColumn:nil mOC:context ascendingFlg:NO];
	if(profile.count>0) {
		NSManagedObject *mo = [profile objectAtIndex:0];
		[mo setValue:[NSNumber numberWithDouble:value] forKey:field];
		[context save:nil];
	}
}

+(void)updateItemAmount:(ItemObject *)obj type:(int)type month:(int)month year:(int)year currentFlg:(BOOL)currentFlg amount:(double)amount moc:(NSManagedObjectContext *)moc {
	int rowId = [obj.rowId intValue];
	if(rowId==0) {
		[ObjectiveCScripts showAlertPopup:@"ERROR" message:@"no rowId for Object!"];
		return;
	}
	
	NSManagedObject *mo = [CoreDataLib managedObjFromId:obj.rowId managedObjectContext:moc];
	if(!mo)
		return;
	
	if(type==0 && currentFlg) { // update Value
		[mo setValue:[NSNumber numberWithDouble:amount] forKey:@"value"];
	}
	if(type==1 && currentFlg) { // update Balance
		[mo setValue:[NSNumber numberWithDouble:amount] forKey:@"loan_balance"];
	}
	
	NSString *year_month = [NSString stringWithFormat:@"%d%02d", year, month];
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", year_month, [obj.rowId intValue]];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:moc ascendingFlg:NO];
	NSManagedObject *updateRecord = nil;
	if(items.count>0)
		updateRecord = [items objectAtIndex:0];
	else {
		updateRecord = [NSEntityDescription insertNewObjectForEntityForName:@"VALUE_UPDATE" inManagedObjectContext:moc];
		[updateRecord setValue:year_month forKey:@"year_month"];
		[updateRecord setValue:[NSNumber numberWithInt:rowId] forKey:@"item_id"];
		[updateRecord setValue:[NSNumber numberWithInt:year] forKey:@"year"];
		[updateRecord setValue:[NSNumber numberWithInt:month] forKey:@"month"];
		[updateRecord setValue:[NSNumber numberWithInt:[ObjectiveCScripts typeNumberFromTypeString:obj.type]] forKey:@"type"];
	}
	
	NSString *field = nil;
	NSString *fieldString = nil;
	NSString *flag = nil;
	float multHistory=1.0;
	float multFuture=1.0;
	
	if(type==0) { // update Value
		field = @"asset_value";
		fieldString = @"valueStr";
		flag = @"val_confirm_flg";
		if([@"Real Estate" isEqualToString:obj.type]) {
			multFuture=1.00417; //<-- 5%/year
			multHistory=0.9958; //<-- 5%/year
		}
		if([@"Vehicle" isEqualToString:obj.type]) {
			multFuture=0.9958; //<-- 5%/year
			multHistory=1.00417; //<-- 5%/year
		}
		if([@"Asset" isEqualToString:obj.type]) {
			multFuture=1.00417; //<-- 5%/year
			multHistory=0.9958; //<-- 5%/year
		}
		if([@"Debt" isEqualToString:obj.type]) {
			multFuture=0;
			multHistory=0;
		}
	}
	if(type==1) { // update balance
		field = @"balance_owed";
		fieldString = @"balanceStr";
		flag = @"bal_confirm_flg";
		if([@"Real Estate" isEqualToString:obj.type]) {
			multFuture=0.9972; //<-- 30 year payoff
			multHistory=1.00428; //<-- 30 year payoff
		}
		if([@"Vehicle" isEqualToString:obj.type]) {
			multFuture=0.9833; //<-- 5 year payoff
			multHistory=1.0167; //<-- 5 year payoff
		}
		if([@"Asset" isEqualToString:obj.type]) {
			multFuture=0;
			multHistory=0;
		}
		if([@"Debt" isEqualToString:obj.type]) {
			multFuture=1;
			multHistory=1;
		}
	}
	if([@"Bank Account" isEqualToString:obj.sub_type]) {
		multFuture=1;
		multHistory=1;
	}
	multFuture=1; //<-- new strategy, don't try to predict
	
	int itemType = [ObjectiveCScripts typeNumberFromTypeString:obj.type];
	float interest_rate = [obj.interest_rate floatValue];
	double interest = (interest_rate*amount)/100/12;
	if(type==1)
		[updateRecord setValue:[NSNumber numberWithDouble:interest] forKey:@"interest"];
	[updateRecord setValue:[NSNumber numberWithDouble:amount] forKey:field];
	[updateRecord setValue:[NSString stringWithFormat:@"%g", amount] forKey:fieldString];

	int nowDay = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
	if(nowDay>=[obj.statement_day intValue])
		[updateRecord setValue:[NSNumber numberWithBool:YES] forKey:flag];
	
	[self updateHistory:[obj.rowId intValue] multiplyer:multHistory field:field flag:flag month:month year:year amount:amount moc:moc type:itemType interest_rate:interest_rate statement_day:[obj.statement_day intValue]];

	[self updateFuture:[obj.rowId intValue] multiplyer:multFuture field:field flag:flag month:month year:year amount:amount moc:moc type:itemType interest_rate:interest_rate];
	
	[moc save:nil];
}

+(void)updateHistory:(int)rowId multiplyer:(float)multiplyer field:(NSString *)field flag:(NSString *)flag month:(int)month year:(int)year amount:(int)amount moc:(NSManagedObjectContext *)moc type:(int)type interest_rate:(float)interest_rate statement_day:(int)statement_day {
	
	if(multiplyer==0)
		return; // dont need to update
	
	for(int i=1; i<=24; i++) {
		month--;
		if(month<=0) {
			month=12;
			year--;
		}
		
		amount*=multiplyer;
		if(amount<0)
			amount=0;
		
		NSString *year_month = [NSString stringWithFormat:@"%d%02d", year, month];
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", year_month, rowId];
		
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:moc ascendingFlg:NO];
		NSManagedObject *updateRecord = nil;
		if(items.count>0)
			updateRecord = [items objectAtIndex:0];
		else {
			updateRecord = [NSEntityDescription insertNewObjectForEntityForName:@"VALUE_UPDATE" inManagedObjectContext:moc];
			[updateRecord setValue:year_month forKey:@"year_month"];
			[updateRecord setValue:[NSNumber numberWithInt:year] forKey:@"year"];
			[updateRecord setValue:[NSNumber numberWithInt:month] forKey:@"month"];
			[updateRecord setValue:[NSNumber numberWithInt:rowId] forKey:@"item_id"];
			[updateRecord setValue:[NSNumber numberWithInt:type] forKey:@"type"];
		}
		BOOL confirm_flg = [[updateRecord valueForKey:flag] boolValue];
		if(confirm_flg)
			return; // that's as far as we go!
		
		double currentVal = [[updateRecord valueForKey:field] doubleValue];
		if(currentVal==0 && [ObjectiveCScripts isStartupCompleted])
			return; //don't create history if none existed
		
		[updateRecord setValue:[NSNumber numberWithInt:amount] forKey:field];
		
		if([@"balance_owed" isEqualToString:field]) {
			int interest = (interest_rate*amount)/100/12;
			[updateRecord setValue:[NSNumber numberWithInt:interest] forKey:@"interest"];
		}
		
		int nowDay = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
		if(nowDay<statement_day && i==1) {
			[updateRecord setValue:[NSNumber numberWithBool:YES] forKey:flag]; // Set last month's flag
			NSLog(@"Setting flag! %@", flag);
		}
		
			
		NSLog(@"%@ = %d", year_month, amount);
	}
	
}

+(void)updateFuture:(int)rowId multiplyer:(float)multiplyer field:(NSString *)field flag:(NSString *)flag month:(int)month year:(int)year amount:(int)amount moc:(NSManagedObjectContext *)moc type:(int)type interest_rate:(float)interest_rate {
	
	if(multiplyer==0)
		return; // dont need to update
	
	for(int i=1; i<=24; i++) {
		month++;
		if(month>12) {
			month=1;
			year++;
		}
		
		amount*=multiplyer;
		if(amount<0)
			amount=0;
		
		NSString *year_month = [NSString stringWithFormat:@"%d%02d", year, month];
		NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", year_month, rowId];
		
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:moc ascendingFlg:NO];
		NSManagedObject *updateRecord = nil;
		if(items.count>0)
			updateRecord = [items objectAtIndex:0];
		else {
			updateRecord = [NSEntityDescription insertNewObjectForEntityForName:@"VALUE_UPDATE" inManagedObjectContext:moc];
			[updateRecord setValue:year_month forKey:@"year_month"];
			[updateRecord setValue:[NSNumber numberWithInt:year] forKey:@"year"];
			[updateRecord setValue:[NSNumber numberWithInt:month] forKey:@"month"];
			[updateRecord setValue:[NSNumber numberWithInt:rowId] forKey:@"item_id"];
			[updateRecord setValue:[NSNumber numberWithInt:type] forKey:@"type"];
		}
		BOOL confirm_flg = [[updateRecord valueForKey:flag] boolValue];
		if(confirm_flg)
			return; // that's as far as we go!
		
		[updateRecord setValue:[NSNumber numberWithInt:amount] forKey:field];
		
		if([@"balance_owed" isEqualToString:field]) {
			int interest = (interest_rate*amount)/100/12;
			[updateRecord setValue:[NSNumber numberWithInt:interest] forKey:@"interest"];
		}

		NSLog(@"%@ = %d", year_month, amount);
	}
	
}

+(int)getAge:(NSManagedObjectContext *)context
{
	int yearBorn = [CoreDataLib getNumberFromProfile:@"yearBorn" mOC:context];
	int nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int age = nowYear-yearBorn;
	if(age>110)
		age=40; // just in case of bad data
	return age;
}









@end

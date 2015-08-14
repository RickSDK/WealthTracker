//
//  CoreDataLib.h
//  PokerTracker
//
//  Created by Rick Medved on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ItemObject.h"


@interface CoreDataLib : UIViewController {

}

+(NSString *)autoIncrementNumber;
+(UIColor *)getFieldColor:(int)value;
+(NSArray *)selectRowsFromTable:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC;
+(NSArray *)selectRowsFromEntity:(NSString *)entityName predicate:(NSPredicate *)predicate sortColumn:(NSString *)sortColumn mOC:(NSManagedObjectContext *)mOC ascendingFlg:(BOOL)ascendingFlg;
+(NSArray *)selectRowsFromEntityWithLimit:(NSString *)entityName predicate:(NSPredicate *)predicate sortColumn:(NSString *)sortColumn mOC:(NSManagedObjectContext *)mOC ascendingFlg:(BOOL)ascendingFlg limit:(int)limit;
+(void)dumpContentsOfTable:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC key:(NSString *)key;
+(BOOL) insertAttributeManagedObject:(NSString *)entityName valueList:(NSArray *)valueList mOC:(NSManagedObjectContext *)mOC;
+(BOOL) insertManagedObject:(NSString *)entityName keyList:(NSArray *)keyList valueList:(NSArray *)valueList typeList:(NSArray *)typeList mOC:(NSManagedObjectContext *)mOC;
+(BOOL) updateManagedObject:(NSManagedObject *)newManagedObject keyList:(NSArray *)keyList valueList:(NSArray *)valueList typeList:(NSArray *)typeList mOC:(NSManagedObjectContext *)mOC;
+(NSString *)getFieldValueForEntity:(NSManagedObjectContext *)mOC entityName:(NSString *)entityName field:(NSString *)field predString:(NSString *)predString indexPathRow:(int)indexPathRow;
+(NSString *)getFieldValueForEntityWithPredicate:(NSManagedObjectContext *)mOC entityName:(NSString *)entityName field:(NSString *)field predicate:(NSPredicate *)predicate indexPathRow:(int)indexPathRow;
+(NSArray *)getEntityNameList:(NSString *)entityName mOC:(NSManagedObjectContext *)mOC;
+(NSArray *)getFieldList:(NSString *)name mOC:(NSManagedObjectContext *)mOC addAllTypesFlg:(BOOL)addAllTypesFlg;
+(int)calculateActiveYearsPlaying:(NSManagedObjectContext *)mOC;
+(int)updateStreak:(int)streak winAmount:(int)winAmount;
+(int)updateWinLoss:(int)gameCount winAmount:(int)winAmount winFlag:(BOOL)winFlag;
+(NSManagedObject *)managedObjFromId:(NSString *)rowId managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+(int)getNumberFromProfile:(NSString *)field mOC:(NSManagedObjectContext *)mOC;
+(void)updateItemAmount:(ItemObject *)obj type:(int)type month:(int)month year:(int)year currentFlg:(BOOL)currentFlg amount:(double)amount moc:(NSManagedObjectContext *)moc;
+(int)getAge:(NSManagedObjectContext *)context;
+(NSString *)getTextFromProfile:(NSString *)field mOC:(NSManagedObjectContext *)mOC;
+(void)saveTextToProfile:(NSString *)field value:(NSString *)value context:(NSManagedObjectContext *)context;
+(void)saveNumberToProfile:(NSString *)field value:(double)value context:(NSManagedObjectContext *)context;

@end

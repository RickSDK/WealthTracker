//
//  GraphLib.h
//  WealthTracker
//
//  Created by Rick Medved on 7/16/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ObjectiveCScripts.h"
#import "CoreDataLib.h"
#import "GraphObject.h"
#import "AmountObj.h"


@interface GraphLib : NSObject

+(UIImage *)pieChartWithItems:(NSArray *)itemList startDegree:(float)startDegree;
+(UIImage *)graphBarsWithItems:(NSArray *)itemList;
+(GraphObject *)graphObjectWithName:(NSString *)name amount:(double)amout rowId:(int)rowId reverseColorFlg:(BOOL)reverseColorFlg currentMonthFlg:(BOOL)currentMonthFlg;
+(CGContextRef)contextRefForGraphofWidth:(int)totalWidth totalHeight:(int)totalHeight;
+(UIImage *)plotItemChart:(NSManagedObjectContext *)mOC type:(int)type displayYear:(int)displayYear item_id:(int)item_id displayMonth:(int)displayMonth startMonth:(int)startMonth startYear:(int)startYear numYears:(int)numYears;
+(int)drawZeroLineForContext:(CGContextRef)c min:(float)min max:(float)max bottomEdgeOfChart:(int)bottomEdgeOfChart leftEdgeOfChart:(int)leftEdgeOfChart totalWidth:(int)totalWidth;
+(void)drawLeftLabelsAndLinesForContext:(CGContextRef)c totalMoneyRange:(float)totalMoneyRange min:(double)min leftEdgeOfChart:(int)leftEdgeOfChart totalHeight:(int)totalHeight totalWidth:(int)totalWidth numOnlyFlg:(BOOL)numOnlyFlg;
+(void)drawBottomLabelsForArray:(NSArray *)labels c:(CGContextRef)c bottomEdgeOfChart:(int)bottomEdgeOfChart leftEdgeOfChart:(int)leftEdgeOfChart totalWidth:(int)totalWidth;
+(void)drawBarChartForContext:(CGContextRef)c itemArray:(NSArray *)itemArray leftEdgeOfChart:(int)leftEdgeOfChart mainGoal:(int)mainGoal zeroLoc:(int)zeroLoc yMultiplier:(float)yMultiplier totalWidth:(int)totalWidth;
+(UIImage *)plotGraphWithItems:(NSArray *)itemList;
+(void)drawGraphForContext:(CGContextRef)c itemArray:(NSArray *)itemArray leftEdgeOfChart:(int)leftEdgeOfChart zeroLoc:(int)zeroLoc yMultiplier:(float)yMultiplier totalWidth:(int)totalWidth bottomEdgeOfChart:(int)bottomEdgeOfChart shadingFlg:(BOOL)shadingFlg;
+(NSString *)smallLabelForMoney:(double)money totalMoneyRange:(double)totalMoneyRange;
+(NSArray *)barChartValuesLast6MonthsForItem:(int)row_id month:(int)month year:(int)year reverseColorFlg:(BOOL)reverseColorFlg type:(int)type context:(NSManagedObjectContext *)context fieldType:(int)fieldType displayTotalFlg:(BOOL)displayTotalFlg;
+(float)spinPieChart:(UIImageView *)imageView startTouchPosition:(CGPoint)startTouchPosition newTouchPosition:(CGPoint)newTouchPosition startDegree:(float)startDegree barGraphObjects:(NSMutableArray *)barGraphObjects;
+(int)getMonthFromView:(UIImageView *)imageView point:(CGPoint)point startingMonth:(int)startingMonth;
+(NSArray *)yearGraphItemsForMonth:(int)displayMonth year:(int)displayYear context:(NSManagedObjectContext *)context numYears:(int)numYears type:(int)type amount_type:(int)amount_type;
+(AmountObj *)amountForType:(int)type month:(int)month year:(int)year context:(NSManagedObjectContext *)context asset_type:(int)asset_type amount_type:(int)amount_type;
+(UIImage *)graphChartForMonth:(int)displayMonth year:(int)displayYear context:(NSManagedObjectContext *)context numYears:(int)numYears type:(int)type barsFlg:(BOOL)barsFlg asset_type:(int)asset_type amount_type:(int)amount_type;
+(NSArray *)pieItemsForMonth:(int)month year:(int)year context:(NSManagedObjectContext *)context;
+(NSArray *)itemsForMonth:(int)month year:(int)year type:(int)type context:(NSManagedObjectContext *)context;


@end

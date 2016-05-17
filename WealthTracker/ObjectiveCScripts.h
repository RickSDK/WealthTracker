//
//  ObjectiveCScripts.h
//  WealthTracker
//
//  Created by Rick Medved on 7/10/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ItemObject.h"
#import <CoreData/CoreData.h>
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "CoreDataLib.h"

#define kTestMode	0

@interface ObjectiveCScripts : NSObject

+(NSString *)appName;
+(NSString *)getProjectDisplayVersion;
+(UIColor *)darkColor;
+(UIColor *)mediumkColor;
+(UIColor *)lightColor;
+(void)showAlertPopup:(NSString *)title message:(NSString *)message;
+(void)showConfirmationPopup:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag;
+(NSString *)convertNumberToMoneyString:(double)money;
+(double)convertMoneyStringToDouble:(NSString *)moneyStr;
+(void)setUserDefaultValue:(NSString *)value forKey:(NSString *)key;
+(NSString *)getUserDefaultValue:(NSString *)key;
+(void)showAlertPopupWithDelegate:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag;

+(NSString *)subTypeForNumber:(int)number;
+(NSString *)typeFromSubType:(int)subtype;
+(NSString *)typeFromFieldType:(int)fieldType;
+(int)typeNumberFromSubType:(int)subtype;
+(NSString *)typeNameForType:(int)type;
+(int)subTypeFromSubTypeString:(NSString *)subType;
+(ItemObject *)itemObjectFromManagedObject:(NSManagedObject *)mo moc:(NSManagedObjectContext *)moc;
+(int)typeNumberFromTypeString:(NSString *)typeStr;
+(NSArray *)typeList;
+(UIColor *)colorBasedOnNumber:(float)number lightFlg:(BOOL)lightFlg;
+(NSString *)yearMonthStringNowPlusMonths:(int)months;
+(NSArray *)monthListShort;
+(BOOL)isStatusGreen:(ItemObject *)obj;
+(BOOL)isStartupCompleted;
+(int)calculateIdealNetWorth:(int)annual_income;
+(void)displayMoneyLabel:(UILabel *)label amount:(double)amount lightFlg:(BOOL)lightFlg revFlg:(BOOL)revFlg;
+(void)displayNetChangeLabel:(UILabel *)label amount:(double)amount lightFlg:(BOOL)lightFlg revFlg:(BOOL)revFlg;
+(BOOL)shouldChangeCharactersForMoneyField:(UITextField *)textFieldlocal  replacementString:(NSString *)string;
+(void)updateSalary:(double)amount year:(int)year context:(NSManagedObjectContext *)context;

+(double)changedForItem:(int)item_id month:(int)month year:(int)year field:(NSString *)field context:(NSManagedObjectContext *)context numMonths:(int)numMonths type:(int)type;
+(double)changedEquityLast30ForItem:(int)item_id context:(NSManagedObjectContext *)context;
+(double)changedBalanceLast30ForItem:(int)item_id context:(NSManagedObjectContext *)context;
+(double)changedValueLast30ForItem:(int)item_id context:(NSManagedObjectContext *)context;
+(double)changedEquityLast30:(NSManagedObjectContext *)context;
+(float)chartHeightForSize:(float)height;
+(UIImage *)imageIconForType:(NSString *)typeStr;
+(double)amountForItem:(int)item_id month:(int)month year:(int)year field:(NSString *)field context:(NSManagedObjectContext *)context type:(int)type;
+(NSString *)getResponseFromServerUsingPost:(NSString *)webURL fieldList:(NSArray *)fieldList valueList:(NSArray *)valueList;
+(BOOL)validateStandardResponse:(NSString *)responseStr delegate:(id)delegate;
+(void)swipeBackRecognizerForTableView:(UITableView *)tableview delegate:(id)delegate selector:(SEL)selector;
+(int)badgeStatusForAppWithContext:(NSManagedObjectContext *)context label:(UILabel *)label;
+(NSString *)fieldTypeNameForFieldType:(int)fieldType;
+(NSString *)typeLabelForType:(int)type fieldType:(int)fieldType;
+(int)calculatePaydownRate:(double)balToday balLastYear:(double)balLastYear bal30:(double)bal30 bal90:(double)bal90;
+(UIImage *)imageForStatus:(int)status;
+(int)nowYear;
+(int)nowMonth;
+(int)nowDay;
+(UIColor *)colorForType:(int)type;
+(void)fontAwesomeButton:(UIButton *)button title:(NSString *)title icon:(NSString *)icon size:(float)size;
+(void)fontAwesomeButton:(UIButton *)button type:(int)type size:(float)size;
+(void)fontAwesomeAltButton:(UIButton *)button type:(int)type size:(float)size;
+(NSString *)fontAwesomeTextForType:(int)type;
+(NSString *)fontAwesomeTextAltForType:(int)type;
+(NSString *)faIconOfType:(int)type;
+(double)averageNetWorth:(NSManagedObjectContext *)context;
+(double)idealNetWorth:(NSManagedObjectContext *)context;
+(NSString *)monthNameForNum:(int)number;
+(int)autoIncrementNumber;
+(double)calculateExpenses:(NSManagedObjectContext *)context;
+(double)calculateIncome:(NSManagedObjectContext *)context;
+(NSString *)faIconOfTypeString:(NSString *)type;
+(NSString *)fontAwesomeIconForNumber:(int)number;

@end

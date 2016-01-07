//
//  ObjectiveCScripts.m
//  CardTap
//
//  Created by Rick Medved on 12/30/14.
//  Copyright (c) 2014 Rick Medved. All rights reserved.
//

#import "ObjectiveCScripts.h"
#import "NSDate+ATTDate.h"
#import "CoreDataLib.h"
#import "UIColor+ATTColor.h"


@implementation ObjectiveCScripts


+(NSString *)getProjectDisplayVersion
{
	NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
	NSString *version = infoDictionary[@"CFBundleShortVersionString"];
	UIDevice *device = [UIDevice currentDevice];
	NSString *model = [device model];
	
	return [NSString stringWithFormat:@"Version %@ (%@)", version, model];
}

+(UIColor *)darkColor {
	return [UIColor colorWithRed:(12/255.0) green:(37/255.0) blue:(119/255.0) alpha:1.0];
}

+(UIColor *)mediumkColor {
	return [UIColor colorWithRed:(6/255.0) green:(122/255.0) blue:(180/255.0) alpha:1.0];
}

+(UIColor *)lightColor {
	return [UIColor colorWithRed:(58/255.0) green:(165/255.0) blue:(220/255.0) alpha:1.0];
}

+(void)showAlertPopup:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
	[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
	//	[alert show];
}

+(void)showAlertPopupWithDelegate:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
	alert.tag = tag;
	[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
	//	[alert show];
	//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
}


+(void)showConfirmationPopup:(NSString *)title message:(NSString *)message delegate:(id)delegate tag:(int)tag
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles: @"OK", nil];
	alert.tag = tag;
	[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
//	[alert show];
	//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
}

+(void)showAcceptDeclinePopup:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:delegate
										  cancelButtonTitle:@"Decline"
										  otherButtonTitles: @"Accept", nil];
	
	[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
	//	[alert show];
	//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
}

+(NSString *)getResponseFromWeb:(NSString *)urlString deviceToken:(NSString *)deviceToken
{
	
	NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	
	NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json; api-version=3" forHTTPHeaderField:@"Accept"];
	
	[request setValue:@"apn" forHTTPHeaderField:@"pn_type"];
	[request setValue:deviceToken forHTTPHeaderField:@"pn_reg_id"];
	
	//	NSString *secretKey = @"e18871ab-e10d-4b3f-93a4-80e7c198ce3d";
	//	NSString *user_agent_string = @"com.cardtapp.ctapp";
	//	NSString *consumer = @"TEST-CONS";
	//	NSString *timeStamp = [ObjectiveCScripts convertDateToString:[NSDate date] format:@"yyyyMMddHHmmss"];
	// Example: 20150420113644
	//	NSString *keyLength = @"256";
	//	NSString *payload = @"karnickel";
	//	NSString *message = [NSString stringWithFormat:@"%@%@%@", secretKey, payload, timeStamp];
	
	
	NSError *error = nil;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
	NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	if(error) {
		[ObjectiveCScripts showAlertPopup:@"Network Error" message:error.localizedDescription];
		NSLog(@"+++Response: %@", error.description);
		return nil;
	}
	
	return responseString;
}

+(NSString *)getResponseFromServerUsingPost:(NSString *)webURL fieldList:(NSArray *)fieldList valueList:(NSArray *)valueList
{
	if([fieldList count] != [valueList count]) {
		return [NSString stringWithFormat:@"Invalid value list! (%lu, %lu) %@", (unsigned long)[fieldList count], (unsigned long)[valueList count], webURL];
	}
	int i=0;
	NSMutableString *fieldStr= [[NSMutableString alloc] init];
	for(NSString *name in fieldList)
		[fieldStr appendFormat:@"&%@=%@", name, [valueList objectAtIndex:i++]];
	
	NSString *responseString = nil;
	NSData *postData = [fieldStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
	
	
	NSURL *url = [NSURL URLWithString:webURL];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:url];
	
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSURLResponse *response;
	NSError *err;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
	NSString *reString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	responseString = [NSString stringWithFormat:@"%@", reString];
	
	if(responseData==nil)
		[ObjectiveCScripts showAlertPopup:@"WebService Error" message:@"Not able to connect to the server. Check internet connections."];
	
	return responseString;
}

+(BOOL)validateStandardResponse:(NSString *)responseStr delegate:(id)delegate
{
	if(responseStr==nil || [responseStr length]==0)
		responseStr = @"No Response Sent.";
	
	if([responseStr length]>=7 && [[responseStr substringToIndex:7] isEqualToString:@"Success"]) {
		return YES;
	}
	else {
		if([responseStr length]>100)
			responseStr = [responseStr substringToIndex:100];
		[self showAlertPopup:@"Error" message:responseStr];
		return NO;
	}
}


+(NSData *)createJsonExample {
	NSMutableDictionary *documentDict = [[NSMutableDictionary alloc] init];
	[documentDict setValue:@"12345" forKey:@"end_user[id]"];
	[documentDict setValue:@"test msg" forKey:@"event"];
	
	NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:documentDict forKey:@"trackingData"];
	NSLog(@"jsonDict is %@", jsonDict);
	
	NSData *jsonData = [NSJSONSerialization
						dataWithJSONObject:jsonDict
						options:NSJSONWritingPrettyPrinted
						error:nil];
	return jsonData;
}

/*
 +(NSString *)postRequestToWeb:(NSString *)urlString userId:(NSString *)userId message:(NSString *)message
 {
	
	NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	
	NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
	
	
	NSMutableDictionary *documentDict = [[NSMutableDictionary alloc] init];
 [documentDict setValue:userId forKey:@"end_user[id]"];
 [documentDict setValue:message forKey:@"event"];
	
	NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:documentDict forKey:@"trackingData"];
	NSLog(@"jsonDict is %@", jsonDict);
	
	NSData *jsonData = [NSJSONSerialization
 dataWithJSONObject:jsonDict
 options:NSJSONWritingPrettyPrinted
 error:nil];
 
	
	
 //	NSData *requestData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody: jsonData];
	
	
	NSError *error = nil;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
	NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	if(error) {
 [ObjectiveCScripts showAlertPopup:@"Network Error" message:error.localizedDescription];
 NSLog(@"+++Response: %@", error.description);
 return nil;
	}
	
	return responseString;
 }
 */

+(NSString *)convertDateToString:(NSDate *)date format:(NSString *)format
{
	if(format==nil || [format isEqualToString:@""])
		format = @"MM/dd/yyyy hh:mm:ss a";
	
	if([format isEqualToString:@"short"])
		format = @"MM/dd/yyyy hh:mm a";
	
	if([format isEqualToString:@"date"])
		format = @"MM/dd/yyyy";
	
	if([format isEqualToString:@"long"])
		format = @"yyyy-MM-dd HH:mm:ss ZZ";
	
	if([format isEqualToString:@"cardtapp"])
		format = @"yyyyMMddHHmmss";
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:format];
	NSString *dateString = [df stringFromDate:date];
	if(dateString==nil)
		dateString=@"-";
	return dateString;
}


+(UIImage *)imageFromUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg
{
	if(urlString.length==0)
		return nil;
	
	NSURL *url = [NSURL URLWithString:urlString];
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
	if(image)
		return image;
	else
		return defaultImg;
}

+(void)setUserDefaultValue:(NSString *)value forKey:(NSString *)key
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:value forKey:key];
}

+(NSString *)getUserDefaultValue:(NSString *)key
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults stringForKey:key];
}

+(void)makeSegment:(UISegmentedControl *)segment color:(UIColor *)color {
	[segment setTintColor:color];
	
	segment.layer.backgroundColor = [UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1].CGColor; // BG gray
	segment.layer.cornerRadius = 7;
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
	NSMutableDictionary *attribsNormal = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, NSForegroundColorAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil];
	
	NSMutableDictionary *attribsSelected = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, NSForegroundColorAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
	
	[segment setTitleTextAttributes:attribsNormal forState:UIControlStateNormal];
	[segment setTitleTextAttributes:attribsSelected forState:UIControlStateSelected];
	
}

+(NSString *)convertNumberToMoneyString:(double)money
{
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSString *moneyStr = [formatter stringFromNumber:[NSNumber numberWithDouble:money]];
	
	return [moneyStr stringByReplacingOccurrencesOfString:@".00" withString:@""];
}

+(double)convertMoneyStringToDouble:(NSString *)moneyStr
{
	moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"$" withString:@""];
	moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"," withString:@""];
	return [moneyStr doubleValue];
}

+(NSString *)subTypeForNumber:(int)number
{
	NSArray *subTypes = [self subtypeList];
	NSArray *items = [[subTypes objectAtIndex:number] componentsSeparatedByString:@"|"];
	return [items objectAtIndex:1];
}

+(NSString *)typeNameForType:(int)type {
	NSArray *types = [ObjectiveCScripts typeList];
	return [types objectAtIndex:type];
}

+(NSArray *)typeList {
	return [NSArray arrayWithObjects:
			@"Profile",
			@"Real Estate",
			@"Vehicle",
			@"Debt",
			@"Asset",
			@"N/A",
			nil];
}

+(NSArray *)fieldTypeList {
	return [NSArray arrayWithObjects:
			@"Value",
			@"Balance",
			@"Equity",
			@"Interest",
			nil];
}

+(NSString *)fieldTypeNameForFieldType:(int)fieldType {
	if(fieldType>3)
		return @"Error";
	else
		return [[self fieldTypeList] objectAtIndex:fieldType];
}

+(NSArray *)subtypeList {
			// type | sub_type | type#
	return [NSArray arrayWithObjects:
			@"Profile|Profile|0"
			, @"Profile|I Rent|0"
			, @"Real Estate|Primary Residence|1"
			, @"Real Estate|Rental|1"
			, @"Real Estate|Other Property|1"
			, @"Vehicle|Auto|2"
			, @"Vehicle|Motorcycle|2"
			, @"Vehicle|RV|2"
			, @"Vehicle|ATV|2"
			, @"Vehicle|Jet Ski|2"
			, @"Vehicle|Snomobile|2"
			, @"Vehicle|Other|2"
			, @"Debt|Credit Card|3"
			, @"Debt|Student Loan|3"
			, @"Debt|Loan|3"
			, @"Debt|Medical|3"
			, @"Asset|401k|4"
			, @"Asset|Retirement|4"
			, @"Asset|Stocks|4"
			, @"Asset|College Fund|4"
			, @"Asset|Bank Account|4"
			, @"Asset|Other Asset|4"
			, @"N/A|N/A|5"
			, @"N/A|N/A|5"
			, nil];
}

+(NSString *)typeFromSubType:(int)subtype {
	NSArray *subTypes = [self subtypeList];
	NSArray *items = [[subTypes objectAtIndex:subtype] componentsSeparatedByString:@"|"];
	return [items objectAtIndex:0];
}

+(int)typeNumberFromSubType:(int)subtype {
	NSArray *subTypes = [self subtypeList];
	NSArray *items = [[subTypes objectAtIndex:subtype] componentsSeparatedByString:@"|"];
	return [[items objectAtIndex:2] intValue];
}

+(int)typeNumberFromTypeString:(NSString *)typeStr {
	NSArray *types = [self typeList];
	int typeNum=0;
	for(NSString *type in types) {
		if([typeStr isEqualToString:type])
			return typeNum;
		typeNum++;
	}
	return typeNum;
}

+(int)subTypeFromSubTypeString:(NSString *)subType {
	NSArray *subTypes = [self subtypeList];
	int sub_type=0;
	for(NSString *item in subTypes) {
		NSArray *components = [item componentsSeparatedByString:@"|"];
		if([subType isEqualToString:[components objectAtIndex:1]])
			return sub_type;
		sub_type++;
	}
	return sub_type;
}

+(NSString *)typeFromFieldType:(int)fieldType
{
	switch (fieldType) {
  case 0:
			return @"text";
			break;
  case 1:
			return @"double";
			break;
  case 2:
			return @"int";
			break;
  case 3:
			return @"text";
			break;
  case 4:
			return @"float";
			break;
			
  default:
			break;
	}
	return @"text";
}

+(ItemObject *)itemObjectFromManagedObject:(NSManagedObject *)mo moc:(NSManagedObjectContext *)moc
{
	ItemObject *obj = [[ItemObject alloc] init];
	obj.rowId = [NSString stringWithFormat:@"%d", [[mo valueForKey:@"rowId"] intValue]];
	obj.name = [mo valueForKey:@"name"];
	obj.type = [mo valueForKey:@"type"];
	obj.sub_type = [mo valueForKey:@"sub_type"];
	obj.category = [mo valueForKey:@"category"];
	obj.payment_type = [mo valueForKey:@"payment_type"];
	obj.statement_day = [NSString stringWithFormat:@"%d", [[mo valueForKey:@"statement_day"] intValue]];
	obj.value = [NSString stringWithFormat:@"%d", (int)[[mo valueForKey:@"value"] doubleValue]];
	obj.loan_balance = [NSString stringWithFormat:@"%d", (int)[[mo valueForKey:@"loan_balance"] doubleValue]];
	obj.interest_rate = [mo valueForKey:@"interest_rate"];
	obj.monthly_payment = [NSString stringWithFormat:@"%d", (int)[[mo valueForKey:@"monthly_payment"] doubleValue]];
	obj.homeowner_dues = [NSString stringWithFormat:@"%d", (int)[[mo valueForKey:@"homeowner_dues"] floatValue]];
	obj.valueUrl = [mo valueForKey:@"valueUrl"];
	obj.balanceUrl = [mo valueForKey:@"balanceUrl"];
	obj.day=[obj.statement_day intValue]; // int version of statement_day
	
	int nowDay = [[[NSDate date] convertDateToStringWithFormat:@"dd"] intValue];
	obj.futureDayFlg = [obj.statement_day intValue]>nowDay;
//	int monthToCheck = (obj.futureDayFlg)?-1:0;
//	int monthToCheck=0;
	NSString *yearMonth = [ObjectiveCScripts yearMonthStringNowPlusMonths:0];
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year_month = %@ AND item_id = %d", yearMonth, [obj.rowId intValue]];
	
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:moc ascendingFlg:NO];
	if(items.count>0) {
		NSManagedObject *itemMo = [items objectAtIndex:0];
		obj.bal_confirm_flg = [[itemMo valueForKey:@"bal_confirm_flg"] boolValue];
		obj.val_confirm_flg = [[itemMo valueForKey:@"val_confirm_flg"] boolValue];
	}

	obj.status = 0; //-- green
	if([obj.statement_day intValue]>0) {
		if([obj.statement_day intValue]>nowDay)
			obj.status=1; //--yellow
		else if (![self isStatusGreen:obj])
			obj.status=2;
	}
	if([obj.statement_day intValue]==0) {
		obj.status=0; // emergency fund
		obj.val_confirm_flg=YES;
		obj.bal_confirm_flg=YES;
	}

	return obj;
}

+(UIColor *)colorBasedOnNumber:(float)number lightFlg:(BOOL)lightFlg
{
	if(lightFlg) {
		if(number>=0)
			return [UIColor greenColor];
		else
			return [UIColor colorWithRed:1 green:.7 blue:0 alpha:1];
	}
	if(number>=0)
		return [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
	else
		return [UIColor redColor];
}

+(NSString *)yearMonthStringNowPlusMonths:(int)months
{
	int nowYear = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
	int nowMonth = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	int changeYears = months/12;
	int remainingMonths = months-(changeYears*12);
	
	int newYear = nowYear+changeYears;
	int newMonth = nowMonth+remainingMonths;
	
	if(newMonth>12) {
		newMonth-=12;
		newYear++;
	}
	if(newMonth<1) {
		newMonth+=12;
		newYear--;
	}
	return [NSString stringWithFormat:@"%d%02d", newYear, newMonth];
}

+(NSArray *)monthListShort {
	return [NSArray arrayWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", @"X", nil];
}

+(BOOL)isStatusGreen:(ItemObject *)obj {
	if([@"Asset" isEqualToString:obj.type]) {
		if(obj.val_confirm_flg)
			return YES;
		else
			return NO;
	}
	if([@"Debt" isEqualToString:obj.type]) {
		if(obj.bal_confirm_flg)
			return YES;
		else
			return NO;
	}
	
	if(obj.bal_confirm_flg && obj.val_confirm_flg)
		return YES;
	else
		return NO;
}

+(BOOL)isStartupCompleted {
	return ([ObjectiveCScripts getUserDefaultValue:@"assetsFlg"].length>0);
}

+(int)calculateIdealNetWorth:(int)annual_income {
	int idealNetWorth = annual_income*10; // ideally you would like to retire and make the same amount
	if(idealNetWorth<400000)
		idealNetWorth=400000; // at least 400,000
	if(idealNetWorth>10000000)
		idealNetWorth=10000000; // at most 10 mil
	
	idealNetWorth=(idealNetWorth/100000)*100000; // rounded
	return idealNetWorth;
}

+(void)displayMoneyLabel:(UILabel *)label amount:(double)amount lightFlg:(BOOL)lightFlg revFlg:(BOOL)revFlg {
	label.text = [NSString stringWithFormat:@"%@", [ObjectiveCScripts convertNumberToMoneyString:amount]];
	if(revFlg)
		amount*=-1;
	label.textColor = [ObjectiveCScripts colorBasedOnNumber:amount lightFlg:lightFlg];
}


+(void)displayNetChangeLabel:(UILabel *)label amount:(double)amount lightFlg:(BOOL)lightFlg revFlg:(BOOL)revFlg {
	NSString *sign=(amount>=0)?@"+":@"";
	label.text = [NSString stringWithFormat:@"%@%@", sign, [ObjectiveCScripts convertNumberToMoneyString:amount]];
	if(revFlg)
		amount*=-1;
	label.textColor = [ObjectiveCScripts colorBasedOnNumber:amount lightFlg:lightFlg];
}

+(BOOL)shouldChangeCharactersForMoneyField:(UITextField *)textFieldlocal  replacementString:(NSString *)string {
	if(string.length==0) // backspace
		return YES;
	if([@"." isEqualToString:string])
		return YES;
	
	NSString *value = [NSString stringWithFormat:@"%@%@", textFieldlocal.text, string];
	value = [value stringByReplacingOccurrencesOfString:@"$" withString:@""];
	value = [value stringByReplacingOccurrencesOfString:@"," withString:@""];
	value = [ObjectiveCScripts convertNumberToMoneyString:[value doubleValue]];
	textFieldlocal.text = value;
	return NO;
}

+(void)updateSalary:(double)amount year:(int)year context:(NSManagedObjectContext *)context
{
	NSPredicate *predicate=[NSPredicate predicateWithFormat:@"year = %d", year];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"INCOME" predicate:predicate sortColumn:nil mOC:context ascendingFlg:NO];
	NSManagedObject *mo=nil;
	if(items.count>0) {
		mo = [items objectAtIndex:0];
	} else {
		mo = [NSEntityDescription insertNewObjectForEntityForName:@"INCOME" inManagedObjectContext:context];
		[mo setValue:[NSNumber numberWithInt:year] forKey:@"year"];
	}
	[mo setValue:[NSNumber numberWithDouble:amount] forKey:@"amount"];
	[context save:nil];
}

+(NSPredicate *)predicateForItem:(int)item_id month:(int)month year:(int)year type:(int)type {
	if(type>0) {
		if(item_id>0)
			return [NSPredicate predicateWithFormat:@"year = %d AND month = %d AND item_id = %d AND type = %d", year, month, item_id, type];
		else
			return [NSPredicate predicateWithFormat:@"year = %d AND month = %d AND type = %d", year, month, type];
	} else {
		if(item_id>0)
			return [NSPredicate predicateWithFormat:@"year = %d AND month = %d AND item_id = %d", year, month, item_id];
		else
			return [NSPredicate predicateWithFormat:@"year = %d AND month = %d", year, month];
	}
	return nil;
}

+(double)amountForItem:(int)item_id month:(int)month year:(int)year field:(NSString *)field context:(NSManagedObjectContext *)context type:(int)type {
	double amount=0;
	NSPredicate *predicate=[ObjectiveCScripts predicateForItem:item_id month:month year:year type:type];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:context ascendingFlg:NO];
	for(NSManagedObject *mo in items) {
		if(field.length>0)
			amount += [[mo valueForKey:field] intValue];
		else
			amount += [[mo valueForKey:@"asset_value"] doubleValue]-[[mo valueForKey:@"balance_owed"] doubleValue];
	}
	return amount;
}

+(double)changedForItem:(int)item_id month:(int)month year:(int)year field:(NSString *)field context:(NSManagedObjectContext *)context numMonths:(int)numMonths type:(int)type {
	if(month==0 && year==0) {
		year = [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
		month = [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
	}
	
	int prevMonth = month;
	int prevYear = year;
	for(int i=1; i<=numMonths; i++) {
		prevMonth--;
		if(prevMonth<1) {
			prevMonth=12;
			prevYear--;
		}
	}
	if(item_id<0) {
		type=item_id*-1;
		item_id=0;
	}
	
	double prevAmount = [self amountForItem:item_id month:prevMonth year:prevYear field:field context:context type:type];
	double amount = [self amountForItem:item_id month:month year:year field:field context:context type:type];
	
	return amount-prevAmount;
}

+(double)changedEquityLast30ForItem:(int)item_id context:(NSManagedObjectContext *)context {
	return [ObjectiveCScripts changedForItem:item_id month:0 year:0 field:nil context:context numMonths:1 type:0];
}

+(double)changedBalanceLast30ForItem:(int)item_id context:(NSManagedObjectContext *)context {
	return [ObjectiveCScripts changedForItem:item_id month:0 year:0 field:@"balance_owed" context:context numMonths:1 type:0];
}

+(double)changedEquityLast30:(NSManagedObjectContext *)context {
	return [ObjectiveCScripts changedForItem:0 month:0 year:0 field:nil context:context numMonths:1 type:0];
}

+(int)calculatePaydownRate:(double)balToday balLastYear:(double)balLastYear bal30:(double)bal30 bal90:(double)bal90 {
	int principalPaid = (balLastYear-balToday)/12;
	if((bal30-balToday)>principalPaid)
		principalPaid = bal30-balToday;
	if((bal90-balToday)>principalPaid)
		principalPaid = (bal90-balToday)/3;
	return principalPaid;
}

+(float)chartHeightForSize:(float)height
{
	float width = [[UIScreen mainScreen] bounds].size.width;
	if(width<320)
		width=320;
	return height*width/320;
}

+(UIImage *)imageIconForType:(NSString *)typeStr {
	return [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [[typeStr lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
}

+(void)swipeBackRecognizerForTableView:(UITableView *)tableview delegate:(id)delegate selector:(SEL)selector {
	UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:delegate
																					 action:selector];
	[recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
	[tableview addGestureRecognizer:recognizer];
}

+(int)badgeStatusForAppWithContext:(NSManagedObjectContext *)context label:(UILabel *)label {
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:nil mOC:context ascendingFlg:NO];
	int numberNeedsUpdating=0;
	int numberInYellow=0;
	int totalRecordsForMonth=0;
	int totalRecordsCompleted=0;
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:context];
		if(obj.status==1)
			numberInYellow++;
		if(obj.status==2)
			numberNeedsUpdating++;
		if([obj.statement_day intValue]>0) {
			totalRecordsForMonth++;
			if(obj.status==0)
				totalRecordsCompleted++;
		}
	}
	int percentComplete = 0;
	if(totalRecordsForMonth>0)
		percentComplete = totalRecordsCompleted*100/totalRecordsForMonth;
	
	int oldPercentComplete = [[ObjectiveCScripts getUserDefaultValue:@"percentComplete"] intValue];
	if(oldPercentComplete != percentComplete)
		[ObjectiveCScripts setUserDefaultValue:[NSString stringWithFormat:@"%d", percentComplete] forKey:@"percentComplete"];
	
	if(label)
		label.text=[NSString stringWithFormat:@"%d%% Updated", percentComplete];

	[UIApplication sharedApplication].applicationIconBadgeNumber = numberNeedsUpdating;
	if(numberNeedsUpdating>0)
		return numberNeedsUpdating; // red status
	if(numberInYellow>0)
		return numberInYellow*-1; // yellow status
	else
		return 0; // green status
	
}

+(UIColor *)colorForType:(int)type {
	if(type==1)
		return [UIColor colorWithRed:.5 green:.4 blue:.3 alpha:1];
	if(type==2)
		return [ObjectiveCScripts mediumkColor];
	if(type==3)
		return [UIColor colorWithRed:.6 green:.4 blue:.4 alpha:1];
	if(type==4)
		return [UIColor colorWithRed:.4 green:.55 blue:.4 alpha:1];
	
	return [UIColor blackColor];
}


+(NSString *)typeLabelForType:(int)type fieldType:(int)fieldType {
	if(type==0) {
		if(fieldType==0)
			return @"Assets";
		if(fieldType==1)
			return @"Debts";
		if(fieldType==2)
			return @"Net Worth";
		if(fieldType==3)
			return @"Debt Interest";
	} else
		return [ObjectiveCScripts typeNameForType:type];
	
	return @"Error";
}

+(UIImage *)imageForStatus:(int)status {
	if(status == 1)
		return [UIImage imageNamed:@"yellow.png"];
	else if(status == 2)
		return [UIImage imageNamed:@"red.png"];
	
	return [UIImage imageNamed:@"green.png"];
}

+(int)nowYear {
	return [[[NSDate date] convertDateToStringWithFormat:@"yyyy"] intValue];
}

+(int)nowMonth {
	return [[[NSDate date] convertDateToStringWithFormat:@"MM"] intValue];
}









































@end

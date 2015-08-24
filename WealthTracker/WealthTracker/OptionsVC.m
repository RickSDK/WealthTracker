//
//  OptionsVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/28/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "OptionsVC.h"
#import "LoginVC.h"
#import "ObjectiveCScripts.h"
#import "CoreDataLib.h"
#import "NSDate+ATTDate.h"
#import "NSString+ATTString.h"
#import "InAppPurchaseVC.h"
#import "CreditScoreTracker.h"
#import "CashFlowVC.h"
#import "MonthlySpendingVC.h"
#import "StartupVC.h"

#define kExportAlert	1
#define kImporttAlert	2
#define kDeleteDBAlert	3
#define kEraseDBAlert	4

#define kMenu1	@"Track Your Credit Score"
#define kMenu2	@"Track Cash Flow"
#define kMenu3	@"Export Data"
#define kMenu4	@"Import Data"
#define kMenu5	@"Delete All Database Data"
#define kMenu6	@"Email Developer"
#define kMenu7	@"Allow Decimals"
#define kMenu8	@"Monthly Spending"
#define kMenu9	@"Manage Portfolio"
#define kMenu10	@"Update Profile"

@interface OptionsVC ()

@end

@implementation OptionsVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	self.userLabel.text=[ObjectiveCScripts getUserDefaultValue:@"emailAddress"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Options"];
	
	NSArray *titles = [NSArray arrayWithObjects:
					   kMenu1,
					   kMenu2,
					   kMenu8,
					   kMenu3,
					   kMenu4,
					   kMenu5,
					   kMenu10,
					   kMenu9,
					   kMenu6,
					   kMenu7,
					   nil];
	self.menuItems=[[NSArray alloc] initWithArray:titles];
	
	self.upgradeButton.hidden = ([ObjectiveCScripts getUserDefaultValue:@"upgradeFlg"].length>0);

	NSString *login = ([ObjectiveCScripts getUserDefaultValue:@"emailAddress"].length>0)?@"Logout":@"Login";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:login style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonPressed)];
}

-(void)loginButtonPressed {
	LoginVC *detailViewController = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%d", (long)indexPath.section, (int)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

	cell.textLabel.text=[self.menuItems objectAtIndex:indexPath.row];
	if([kMenu7 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		if([ObjectiveCScripts getUserDefaultValue:@"allowDecFlg"].length==0)
			cell.accessoryType= UITableViewCellAccessoryNone;
		else
			cell.accessoryType= UITableViewCellAccessoryCheckmark;
	} else
		cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	
	cell.backgroundColor=(indexPath.row==1)?[UIColor colorWithRed:1 green:1 blue:.8 alpha:1]:[UIColor whiteColor];

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.menuItems.count;
}

-(IBAction)upgradeButtonClicked:(id)sender {
	InAppPurchaseVC *detailViewController = [[InAppPurchaseVC alloc] initWithNibName:@"InAppPurchaseVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row<=4 && [ObjectiveCScripts getUserDefaultValue:@"emailAddress"].length==0) {
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"You must be logged in to use this feature."];
		return;
	}
	
	if([kMenu1 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		CreditScoreTracker *detailViewController = [[CreditScoreTracker alloc] initWithNibName:@"CreditScoreTracker" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	
	if([kMenu2 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		CashFlowVC *detailViewController = [[CashFlowVC alloc] initWithNibName:@"CashFlowVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	
	
	if([kMenu3 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		[ObjectiveCScripts showConfirmationPopup:@"Export Data?" message:@"" delegate:self tag:kExportAlert];
	}
	if([kMenu4 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"PROFILE" predicate:nil sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		if(items.count==0 || [CoreDataLib getAge:self.managedObjectContext]==99)
			[ObjectiveCScripts showConfirmationPopup:@"Import Data?" message:@"" delegate:self tag:kImporttAlert];
		else
			[ObjectiveCScripts showAlertPopup:@"NOTICE" message:@"First delete all your data."];
	}
	if([kMenu5 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		if([CoreDataLib getAge:self.managedObjectContext]==99)
			[ObjectiveCScripts showConfirmationPopup:@"WARNING!!" message:@"This will delete and erase ALL data currently saved on this device. Proceed?" delegate:self tag:kEraseDBAlert];
		else
			[ObjectiveCScripts showAlertPopup:@"Notice" message:@"As a safety guard, first set your age to 99, under the profile screen. Then come back to this screen to delete the data."];
	}
	if([kMenu6 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", @"rickmedved@hotmail.com"]]];
	}
	if([kMenu7 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		if([ObjectiveCScripts getUserDefaultValue:@"allowDecFlg"].length==0)
			[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"allowDecFlg"];
		else
			[ObjectiveCScripts setUserDefaultValue:@"" forKey:@"allowDecFlg"];
		[self.mainTableView reloadData];
	}
	if([kMenu8 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		MonthlySpendingVC *detailViewController = [[MonthlySpendingVC alloc] initWithNibName:@"MonthlySpendingVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];

	}
	
	if([kMenu9 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		StartupVC *detailViewController = [[StartupVC alloc] initWithNibName:@"StartupVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	if([kMenu10 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		StartupVC *detailViewController = [[StartupVC alloc] initWithNibName:@"StartupVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.cancelButtonIndex)
		return;
	
	if(alertView.tag==kExportAlert) {
		[self exportData];
	}
	if(alertView.tag==kImporttAlert) {
		[self importData];
	}
	if(alertView.tag==kDeleteDBAlert) {
		[self deleteServerData];
	}
	if(alertView.tag==kEraseDBAlert) {
		[self eraseAllData];
		[ObjectiveCScripts showAlertPopup:@"Deleted!" message:@""];
	}
}

-(void)eraseDataForEntity:(NSString *)entity {
	NSArray *items = [CoreDataLib selectRowsFromEntity:entity predicate:nil sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for(NSManagedObject *mo in items)
		[self.managedObjectContext deleteObject:mo];
}

-(NSArray *)keyTypesProfile {
	return [NSArray arrayWithObjects:
			@"age|int",
			@"annual_income|double",
			@"attrib01|text",
			@"attrib02|text",
			@"dependants|int",
			@"email|text",
			@"emergency_fund|double",
			@"monthly_rent|double",
			@"name|text",
			@"password|text",
			@"planStep|int",
			@"retirement_payments|double",
			@"webPassword|text",
			@"yearBorn|int",
			@"creditUrl|text",
			@"creditUser|text",
			@"creditPass|text",
			@"bankAccount|double",
			nil];
}

-(NSArray *)keyTypesItem {
	return [NSArray arrayWithObjects:
			@"attrib01|text",
			@"attrib02|text",
			@"balancePassword|text",
			@"balanceUrl|text",
			@"balanceUsername|text",
			@"category|text",
			@"condo_fees|double",
			@"homeowner_dues|double",
			@"interest_rate|text",
			@"last_upd_balance|date",
			@"loan_balance|double",
			@"monthly_payment|double",
			@"name|text",
			@"needsUpd|bool",
			@"payment_type|text",
			@"rowId|int",
			@"statement_day|int",
			@"sub_type|text",
			@"type|text",
			@"value|double",
			@"valuePassword|text",
			@"valueUrl|text",
			@"valueUsername|text",
			@"taxes|double",
			@"insurance|double",
			@"maxCredit|double",
			nil];
}

-(NSArray *)keyTypesIncome {
	return [NSArray arrayWithObjects:
			@"amount|double",
			@"amountStr|text",
			@"year|int",
			nil];
}

-(NSArray *)keyTypesValue {
	return [NSArray arrayWithObjects:
			@"asset_value|double",
			@"attrib01|double",
			@"attrib02|int",
			@"bal_confirm_flg|bool",
			@"balance_owed|double",
			@"balanceStr|text",
			@"interest|double",
			@"item_id|int",
			@"month|int",
			@"type|int",
			@"val_confirm_flg|bool",
			@"valueStr|text",
			@"year|int",
			@"year_month|text",
			nil];
}

-(NSArray *)keyTypesCredit {
	return [NSArray arrayWithObjects:
			@"attrib01|text",
			@"attrib02|text",
			@"confirmFlg|bool",
			@"month|int",
			@"score|int",
			@"year|int",
			nil];
}

-(NSArray *)keyTypesCashflow {
	return [NSArray arrayWithObjects:
			@"amount|double",
			@"category|text",
			@"confirmFlg|bool",
			@"name|text",
			@"statement_day|int",
			@"type|int",
			nil];
}

-(void)eraseAllData {
	[self eraseDataForEntity:@"PROFILE"];
	[self eraseDataForEntity:@"ITEM"];
	[self eraseDataForEntity:@"INCOME"];
	[self eraseDataForEntity:@"VALUE_UPDATE"];
	[self eraseDataForEntity:@"CREDIT_SCORE"];
	[self eraseDataForEntity:@"CASH_FLOW"];
	[self.managedObjectContext save:nil];
}


-(void)exportDataInBackground {
	@autoreleasepool {
		NSMutableArray *databaseItems = [[NSMutableArray alloc] init];
		
		[databaseItems addObject:[self dataForTable:@"PROFILE" keyTypes:[self keyTypesProfile]]];
		[databaseItems addObject:[self dataForTable:@"ITEM" keyTypes:[self keyTypesItem]]];
		[databaseItems addObject:[self dataForTable:@"INCOME" keyTypes:[self keyTypesIncome]]];
		[databaseItems addObject:[self dataForTable:@"VALUE_UPDATE" keyTypes:[self keyTypesValue]]];
		[databaseItems addObject:[self dataForTable:@"CREDIT_SCORE" keyTypes:[self keyTypesCredit]]];
		[databaseItems addObject:[self dataForTable:@"CASH_FLOW" keyTypes:[self keyTypesCashflow]]];
		
		[self sendExportedData:[databaseItems componentsJoinedByString:@"<table>"]];
		[self.webServiceView stop];
	}
}

-(void)importDataInBackground {
	@autoreleasepool {
		NSArray *keys = [NSArray arrayWithObjects:@"Username", @"Password", nil];
		NSArray *values = [NSArray arrayWithObjects:[ObjectiveCScripts getUserDefaultValue:@"emailAddress"], [ObjectiveCScripts getUserDefaultValue:@"password"], nil];
		NSString *response = [ObjectiveCScripts getResponseFromServerUsingPost:@"http://www.appdigity.com/poker/WTImportData.php" fieldList:keys valueList:values];
		
		NSLog(@"+++%@", response);
		response = [self decodeString:response];
		NSArray *tables = [response componentsSeparatedByString:@"<table>"];
		if(tables.count>5) {
			[self eraseAllData];
			int i=0;
			[self importDataForTable:@"PROFILE" data:[tables objectAtIndex:i++] keyTypes:[self keyTypesProfile]];
			[self importDataForTable:@"ITEM" data:[tables objectAtIndex:i++] keyTypes:[self keyTypesItem]];
			[self importDataForTable:@"INCOME" data:[tables objectAtIndex:i++] keyTypes:[self keyTypesIncome]];
			[self importDataForTable:@"VALUE_UPDATE" data:[tables objectAtIndex:i++] keyTypes:[self keyTypesValue]];
			[self importDataForTable:@"CREDIT_SCORE" data:[tables objectAtIndex:i++] keyTypes:[self keyTypesCredit]];
			[self importDataForTable:@"CASH_FLOW" data:[tables objectAtIndex:i++] keyTypes:[self keyTypesCashflow]];
			[self.managedObjectContext save:nil];
			[ObjectiveCScripts showAlertPopup:@"Success!" message:@""];
		} else
			[ObjectiveCScripts showAlertPopup:@"Error on Import" message:@"No data found"];
		
		
		[self.webServiceView stop];
	}
}

-(void)importData {
	[self.webServiceView startWithTitle:@"Working..."];
	[self performSelectorInBackground:@selector(importDataInBackground) withObject:nil];
	
}

-(void)importDataForTable:(NSString *)table data:(NSString *)data keyTypes:(NSArray *)keyTypes {
	int maxId=0;
	NSArray *rows = [data componentsSeparatedByString:@"<row>"];
	for(NSString *row in rows) {
		if(row.length>10) {
			NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:table inManagedObjectContext:self.managedObjectContext];
			NSArray *dataComponents = [row componentsSeparatedByString:@"|"];
			int i=0;
			for(NSString *keyType in keyTypes) {
				NSArray *components = [keyType componentsSeparatedByString:@"|"];
				if(components.count>1) {
					NSString *key = [components objectAtIndex:0];
					if(dataComponents.count<=i)
						continue;
					NSString *value = [dataComponents objectAtIndex:i];
					if([@"ITEM" isEqualToString:table] && [@"rowId" isEqualToString:key] && maxId<[value intValue])
						maxId=[value intValue];
					if([@"double" isEqualToString:[components objectAtIndex:1]])
						[mo setValue:[NSNumber numberWithDouble:[value doubleValue]] forKey:key];
					if([@"int" isEqualToString:[components objectAtIndex:1]])
						[mo setValue:[NSNumber numberWithInt:[value intValue]] forKey:key];
					if([@"text" isEqualToString:[components objectAtIndex:1]]) {
						[mo setValue:value forKey:key];
					}
					if([@"bool" isEqualToString:[components objectAtIndex:1]])
						[mo setValue:[NSNumber numberWithBool:[value boolValue]] forKey:key];
					if([@"date" isEqualToString:[components objectAtIndex:1]]) {
						[mo setValue:[value convertStringToDateWithFormat:nil] forKey:key];
					}
				} // if
				i++;
			} // keyTypes
		} // if
	} // for rows
	if([@"ITEM" isEqualToString:table])
		[ObjectiveCScripts setUserDefaultValue:[NSString stringWithFormat:@"%d", maxId+1] forKey:@"rowId"];
	NSLog(@"+++maxId: %d", maxId);
}

-(void)deleteServerData {
	[self.webServiceView startWithTitle:@"Working..."];
	[self performSelectorInBackground:@selector(deleteDataInBackground) withObject:nil];
	
}

-(void)deleteDataInBackground {
	@autoreleasepool {
		[NSThread sleepForTimeInterval:2];
		[self.webServiceView stop];
		[ObjectiveCScripts showAlertPopup:@"Success!" message:@""];
	}
}

-(void)exportData {
	[self.webServiceView startWithTitle:@"Working..."];
	[self performSelectorInBackground:@selector(exportDataInBackground) withObject:nil];
	
}


-(NSString *)encodeString:(NSString *)data {
	data = [data stringByReplacingOccurrencesOfString:@"&" withString:@"[amp]"];
	data = [data stringByReplacingOccurrencesOfString:@"?" withString:@"[que]"];
	data = [data stringByReplacingOccurrencesOfString:@"<" withString:@"[lt]"];
	data = [data stringByReplacingOccurrencesOfString:@">" withString:@"[gt]"];
	data = [data stringByReplacingOccurrencesOfString:@"#" withString:@"[pound]"];
	return data;
}

-(NSString *)decodeString:(NSString *)data {
	data = [data stringByReplacingOccurrencesOfString:@"[amp]" withString:@"&"];
	data = [data stringByReplacingOccurrencesOfString:@"[que]" withString:@"?"];
	data = [data stringByReplacingOccurrencesOfString:@"[lt]" withString:@"<"];
	data = [data stringByReplacingOccurrencesOfString:@"[gt]" withString:@">"];
	data = [data stringByReplacingOccurrencesOfString:@"[pound]" withString:@"#"];
	data = [data stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	data = [data stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
	return data;
}

-(void)sendExportedData:(NSString *)data
{
	NSArray *keys = [NSArray arrayWithObjects:@"Username", @"Password", @"data", nil];
	NSArray *values = [NSArray arrayWithObjects:[ObjectiveCScripts getUserDefaultValue:@"emailAddress"], [ObjectiveCScripts getUserDefaultValue:@"password"], [self encodeString:data], nil];
	
	NSString *response = [ObjectiveCScripts getResponseFromServerUsingPost:@"http://www.appdigity.com/poker/WTExportData.php" fieldList:keys valueList:values];
	
	NSLog(@"+++response: %@", response);
	if([ObjectiveCScripts validateStandardResponse:response delegate:self])
		[ObjectiveCScripts showAlertPopup:@"Success!" message:@""];
}

-(NSString *)dataForTable:(NSString *)table keyTypes:(NSArray *)keyTypes {
	NSMutableArray *rows = [[NSMutableArray alloc] init];
	NSMutableArray *singleRecord = [[NSMutableArray alloc] init];
	NSArray *items = [CoreDataLib selectRowsFromEntity:table predicate:nil sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
	for (NSManagedObject *mo in items) {
		[singleRecord removeAllObjects];
		for(NSString *keytype in keyTypes) {
			NSArray *components = [keytype componentsSeparatedByString:@"|"];
			if(components.count==2) {
				if([@"double" isEqualToString:[components objectAtIndex:1]])
					[singleRecord addObject:[NSString stringWithFormat:@"%g", [[mo valueForKey:[components objectAtIndex:0]] doubleValue]]];
				if([@"int" isEqualToString:[components objectAtIndex:1]])
					[singleRecord addObject:[NSString stringWithFormat:@"%d", [[mo valueForKey:[components objectAtIndex:0]] intValue]]];
				if([@"text" isEqualToString:[components objectAtIndex:1]]) {
					if([mo valueForKey:[components objectAtIndex:0]])
						[singleRecord addObject:[NSString stringWithFormat:@"%@", [mo valueForKey:[components objectAtIndex:0]]]];
					else
						[singleRecord addObject:@""];
				}
				if([@"bool" isEqualToString:[components objectAtIndex:1]])
					[singleRecord addObject:[NSString stringWithFormat:@"%d", [[mo valueForKey:[components objectAtIndex:0]] boolValue]]];
				if([@"date" isEqualToString:[components objectAtIndex:1]]) {
					NSDate *date = [NSDate date];
					if([mo valueForKey:[components objectAtIndex:0]]) {
						date = [mo valueForKey:[components objectAtIndex:0]];
					}
					[singleRecord addObject:[NSString stringWithFormat:@"%@", [date convertDateToStringWithFormat:nil]]];
				}
			} //<-- if
		} //<-- for keytype
		[rows addObject:[singleRecord componentsJoinedByString:@"|"]];
	} // <-- for mo
	return [rows componentsJoinedByString:@"<row>"]; 
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row==1)
		return 54;
	else
		return 44;
}

@end

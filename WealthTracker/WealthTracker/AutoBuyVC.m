//
//  AutoBuyVC.m
//  WealthTracker
//
//  Created by Rick Medved on 3/9/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "AutoBuyVC.h"
#import "TipsVC.h"
#import "ValueObj.h"

@interface AutoBuyVC ()

@end

@implementation AutoBuyVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Auto Purchase"];
	
	int monthlyIncome=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
	int annualIncome = monthlyIncome*12*1.2;
	if(annualIncome<=0)
		annualIncome=20000;
	
	int amount = (annualIncome/200)*100;
	self.topLabel.text = [NSString stringWithFormat:@"Note: The real-time value of your vehicles combined, should not exceed 50%% of your annual Income. So in your case, your vehicles should not exceed %@.", [ObjectiveCScripts convertNumberToMoneyString:amount]];

	int vehicleAmount = [self vehicleValueForMonth:[ObjectiveCScripts nowMonth] year:[ObjectiveCScripts nowYear] context:self.managedObjectContext tag:1];
	
	self.totalLabel.text = [ObjectiveCScripts convertNumberToMoneyString:vehicleAmount];
	self.percentLabel.text = [NSString stringWithFormat:@"%d%%", vehicleAmount*100/annualIncome];
	
	int amountRemaining = amount-vehicleAmount;
	if(amountRemaining<0)
		amountRemaining=0;
	
	self.availableLabel.text = [ObjectiveCScripts convertNumberToMoneyString:amountRemaining];
	if(amountRemaining>0)
		self.conclusionLabel.text = [NSString stringWithFormat:@"This means if you are going to buy another vehicle, your price should not exceed %@.", [ObjectiveCScripts convertNumberToMoneyString:amountRemaining]];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Strategy" style:UIBarButtonItemStyleBordered target:self action:@selector(tipsButtonPressed)];
}

-(void)tipsButtonPressed {
	TipsVC *detailViewController = [[TipsVC alloc] initWithNibName:@"TipsVC" bundle:nil];
	detailViewController.type=2;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(int)vehicleValueForMonth:(int)month year:(int)year context:(NSManagedObjectContext *)context tag:(int)tag {
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"ITEM" predicate:nil sortColumn:@"name" mOC:context ascendingFlg:NO];
	double totalAmount=0;
	for(NSManagedObject *mo in items) {
		ItemObject *obj = [ObjectiveCScripts itemObjectFromManagedObject:mo moc:context];
		ValueObj *valueObj = [self valueObjectForObjectId:[obj.rowId intValue] month:month year:year type:obj.type context:context];
		
		
		double amount=0;
		if(tag==1) {
			if(![@"Vehicle" isEqualToString:obj.type])
				continue;
			amount = valueObj.value;
		}
		
		totalAmount+=amount;
		
		
	}
	
	return totalAmount;
}

-(ValueObj *)valueObjectForObjectId:(int)rowId month:(int)month year:(int)year type:(NSString *)type context:(NSManagedObjectContext *)context {
	ValueObj *valueObj = [[ValueObj alloc] init];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"month = %d AND year = %d AND item_id = %d", month, year, rowId];
	NSArray *items2 = [CoreDataLib selectRowsFromEntity:@"VALUE_UPDATE" predicate:predicate sortColumn:nil mOC:context ascendingFlg:NO];
	if(items2.count>0) {
		NSManagedObject *mo2 = [items2 objectAtIndex:0];
		valueObj.balance = [[mo2 valueForKey:@"balance_owed"] intValue];
		valueObj.value = [[mo2 valueForKey:@"asset_value"] intValue];
		valueObj.interest = [[mo2 valueForKey:@"interest"] intValue];
		
		if(![@"Real Estate" isEqualToString:type])
			valueObj.badDebt = valueObj.balance;
		
	}
	return valueObj;
}




@end

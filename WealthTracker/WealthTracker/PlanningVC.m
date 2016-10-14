//
//  PlanningVC.m
//  WealthTracker
//
//  Created by Rick Medved on 3/11/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "PlanningVC.h"
#import "MyPlanVC.h"
#import "HomeBuyVC.h"
#import "RetirementVC.h"
#import "AutoBuyVC.h"
#import "EducationVC.h"
#import "FinancesVC.h"
#import "InAppPurchaseVC.h"

#define kMenu1	@"Education"
#define kMenu2	@"Finances"
#define kMenu3	@"Buy a Vehicle"
#define kMenu4	@"Buy a House"
#define kMenu5	@"Retirement"

@interface PlanningVC ()

@end

@implementation PlanningVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Planning"];
	
	NSArray *titles = [NSArray arrayWithObjects:
					   kMenu1,
					   kMenu2,
					   kMenu3,
					   kMenu4,
					   kMenu5,
					   nil];
	self.menuItems=[[NSArray alloc] initWithArray:titles];
	
	self.b2bButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20.f];
	[self.b2bButton setTitle:[NSString stringWithFormat:@"%@ Broke to Baron", [NSString fontAwesomeIconStringForEnum:FAStar]] forState:UIControlStateNormal];
	[self.b2bButton setBackgroundColor:[ObjectiveCScripts lightColor]];
	[self.b2bButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];


//	if([ObjectiveCScripts getUserDefaultValue:@"upgradeFlg"].length==0 && [ObjectiveCScripts getUserDefaultValue:@"upgradeFlgCheck"].length==0) {
//		[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"upgradeFlgCheck"];
//		[ObjectiveCScripts showAlertPopupWithDelegate:@"Thankyou for your business!" message:@"Please check out the upgrade features" /delegate:self tag:1];
//	}

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	InAppPurchaseVC *detailViewController = [[InAppPurchaseVC alloc] initWithNibName:@"InAppPurchaseVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%d", (long)indexPath.section, (int)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	
	cell.textLabel.text=[self.menuItems objectAtIndex:indexPath.row];
	
	NSArray *icons = [NSArray arrayWithObjects:
					  [NSString fontAwesomeIconStringForEnum:FAgraduationCap],
					  [NSString fontAwesomeIconStringForEnum:FAMoney],
					  [NSString fontAwesomeIconStringForEnum:FAautomobile],
					  [NSString fontAwesomeIconStringForEnum:FAHome],
					  [NSString fontAwesomeIconStringForEnum:FAlineChart],
					  nil];
	cell.textLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20.f];
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [icons objectAtIndex:indexPath.row], [self.menuItems objectAtIndex:indexPath.row]];
	
	cell.backgroundColor=[UIColor whiteColor];
	
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([kMenu1 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		EducationVC *detailViewController = [[EducationVC alloc] initWithNibName:@"EducationVC" bundle:nil];
		detailViewController.managedObjectContext=self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	if([kMenu2 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		FinancesVC *detailViewController = [[FinancesVC alloc] initWithNibName:@"FinancesVC" bundle:nil];
		detailViewController.managedObjectContext=self.managedObjectContext;
		detailViewController.title = @"Finances";
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	if([kMenu3 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		AutoBuyVC *detailViewController = [[AutoBuyVC alloc] initWithNibName:@"AutoBuyVC" bundle:nil];
		detailViewController.managedObjectContext=self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	if([kMenu4 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		HomeBuyVC *detailViewController = [[HomeBuyVC alloc] initWithNibName:@"HomeBuyVC" bundle:nil];
		detailViewController.managedObjectContext=self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	if([kMenu5 isEqualToString:[self.menuItems objectAtIndex:indexPath.row]]) {
		RetirementVC *detailViewController = [[RetirementVC alloc] initWithNibName:@"RetirementVC" bundle:nil];
		detailViewController.managedObjectContext=self.managedObjectContext;
		detailViewController.title = @"Retirement";
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.menuItems.count;
}


-(IBAction)myPlanButtonClicked:(id)sender {
	MyPlanVC *detailViewController = [[MyPlanVC alloc] initWithNibName:@"MyPlanVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

@end

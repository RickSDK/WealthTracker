//
//  StartupVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/10/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "StartupVC.h"
#import "ObjectiveCScripts.h"
#import "VehiclesVC.h"
#import "EditItemVC.h"
#import "UpdateSalaryVC.h"
#import "OptionsVC.h"

@interface StartupVC ()

@end

@implementation StartupVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
	[self setupButtons];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Manage"];

	if(![@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"assetsFlg"]]) {
		[self setTitle:@"Startup"];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:self action:@selector(optionsButtonPressed)];
		[ObjectiveCScripts showAlertPopup:@"Welcome to Wealth Tracker!" message:@"First let's get some data entered"];

		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Finished" style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed)];

	} else {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Salary" style:UIBarButtonItemStyleBordered target:self action:@selector(salaryButtonPressed)];
	}
	

}

-(void)optionsButtonPressed {
	OptionsVC *detailViewController = [[OptionsVC alloc] initWithNibName:@"OptionsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)salaryButtonPressed {
	UpdateSalaryVC *detailViewController = [[UpdateSalaryVC alloc] initWithNibName:@"UpdateSalaryVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


-(void)doneButtonPressed {
	if(self.profileFlg && self.housingFlg && self.vehiclesFlg && self.debtsFlg && self.assetsFlg) {
		[self.navigationController popViewControllerAnimated:YES];
	} else
		[ObjectiveCScripts showAlertPopup:@"Update all categories first" message:@""];
}


-(void)setupButtons {
	self.housingButton.enabled=NO;
	self.vehiclesButton.enabled=NO;
	self.debtsButton.enabled=NO;
	self.assetsButton.enabled=NO;
	
	if([@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"profileFlg"]]) {
		self.profileImageView.image=[UIImage imageNamed:@"green.png"];
		self.profileFlg=YES;
		self.housingButton.enabled=YES;
	}
	if([@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"housingFlg"]]) {
		self.housingImageView.image=[UIImage imageNamed:@"green.png"];
		self.housingFlg=YES;
		self.vehiclesButton.enabled=YES;
	}
	if([@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"vehiclesFlg"]]) {
		self.vehiclesImageView.image=[UIImage imageNamed:@"green.png"];
		self.vehiclesFlg=YES;
		self.debtsButton.enabled=YES;
	}
	if([@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"debtsFlg"]]) {
		self.debtsImageView.image=[UIImage imageNamed:@"green.png"];
		self.debtsFlg=YES;
		self.assetsButton.enabled=YES;
	}
	if([@"Y" isEqualToString:[ObjectiveCScripts getUserDefaultValue:@"assetsFlg"]]) {
		self.assetsImageView.image=[UIImage imageNamed:@"green.png"];
		self.assetsFlg=YES;
	}
}

-(IBAction)profileButtonClicked:(id)sender {
	
	EditItemVC *detailViewController = [[EditItemVC alloc] initWithNibName:@"EditItemVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.callbackController=self;
	detailViewController.sub_type=0;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)housingButtonClicked:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Housing"
													message:@"What is your current situation related to your primary home?"
												   delegate:self
										  cancelButtonTitle:@"I Rent"
										  otherButtonTitles: @"I Own", nil];
	alert.tag = 1;
	[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag==1 && buttonIndex==0) { // I rent
		EditItemVC *detailViewController = [[EditItemVC alloc] initWithNibName:@"EditItemVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.callbackController=self;
		detailViewController.sub_type=1;
		detailViewController.tagSelected=1;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	if(alertView.tag==1 && buttonIndex==1) { // I own
		VehiclesVC *detailViewController = [[VehiclesVC alloc] initWithNibName:@"VehiclesVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		detailViewController.callbackController=self;
		detailViewController.type=1;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(IBAction)vehiclesButtonClicked:(id)sender {
	VehiclesVC *detailViewController = [[VehiclesVC alloc] initWithNibName:@"VehiclesVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.callbackController=self;
	detailViewController.type=2;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
-(IBAction)debtsButtonClicked:(id)sender {
	VehiclesVC *detailViewController = [[VehiclesVC alloc] initWithNibName:@"VehiclesVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.callbackController=self;
	detailViewController.type=3;
	[self.navigationController pushViewController:detailViewController animated:YES];
}
-(IBAction)assetsButtonClicked:(id)sender {
	VehiclesVC *detailViewController = [[VehiclesVC alloc] initWithNibName:@"VehiclesVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.callbackController=self;
	detailViewController.type=4;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

@end

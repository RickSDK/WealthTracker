//
//  AdjustBudgetVC.m
//  BalanceApp
//
//  Created by Rick Medved on 4/12/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "AdjustBudgetVC.h"

@interface AdjustBudgetVC ()

@end

@implementation AdjustBudgetVC

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
	
	self.remainingBudget = self.totalBudget;
	
	self.sliders = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:self.budget0Slider, self.budget1Slider, self.budget2Slider, self.budget3Slider, self.budget4Slider, self.budget5Slider, nil]];

	self.labels = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:self.budget0Label, self.budget1Label, self.budget2Label, self.budget3Label, self.budget4Label, self.budget5Label, nil]];


	self.name0Label.text = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dName", 0]];
	self.name1Label.text = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dName", 1]];
	self.name2Label.text = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dName", 2]];
	self.name3Label.text = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dName", 3]];
	self.name4Label.text = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dName", 4]];
	self.name5Label.text = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dName", 5]];
	
	self.remainingBudget = self.totalBudget;
	int i=0;
	for (UISlider *slider in self.sliders) {
		int currentBudget = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", i]] intValue];
		self.remainingBudget -= currentBudget;
		UILabel *label = [self.labels objectAtIndex:i];
		label.text = [ObjectiveCScripts convertNumberToMoneyString:currentBudget];
		i++;
	}
	
	self.budgetRemainingLabel.text = [NSString stringWithFormat:@"%d", self.remainingBudget];
	i=0;
	for (UISlider *slider in self.sliders) {
		int currentBudget = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", i]] intValue];
		slider.maximumValue = currentBudget+self.remainingBudget;
		slider.minimumValue = 0;
		slider.value = currentBudget;
		i++;
	}
}

-(void)done {
	if(self.remainingBudget>10) {
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Keep adjusting until your surplus is down to zero."];
		return;
	}
	if(self.remainingBudget<0) {
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"You are over budget!"];
		return;
	}
	if(self.step==3) {
		self.step++;
		[ObjectiveCScripts setUserDefaultValue:[NSString stringWithFormat:@"%d", self.step] forKey:@"step"];
	}
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(IBAction)sliderMoved:(UISlider *)slider {
	self.selectedSlider = (int)slider.tag;
	UILabel *label = [self.labels objectAtIndex:self.selectedSlider];
	int value = slider.value/5;
	if(value<0)
		value=0;
	label.text = [ObjectiveCScripts convertNumberToMoneyString:value*5];
	[self displayAmountsForSlider:self.selectedSlider value:value*5];
	
}

-(void)displayAmountsForSlider:(int)number value:(int)value {
	self.remainingBudget = self.totalBudget;
	int i=0;
	for (UISlider *slider in self.sliders) {
		if(i==number) {
			int currentBudget=value;
			UILabel *label = [self.labels objectAtIndex:i];
			label.text = [ObjectiveCScripts convertNumberToMoneyString:currentBudget];
			self.remainingBudget -= value;
			if(value>=0 && value <= self.totalBudget)
				[ObjectiveCScripts setUserDefaultValue:[NSString stringWithFormat:@"%d", value] forKey:[NSString stringWithFormat:@"budget%dAmount", i]];
		} else  {
			int currentBudget = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", i]] intValue];
			
			self.remainingBudget -= currentBudget;
		}
		i++;
	}
	self.budgetRemainingLabel.text = [NSString stringWithFormat:@"%d", self.remainingBudget];
	
	i=0;
	for (UISlider *slider in self.sliders) {
		int currentBudget=value;
		if(i!=self.selectedSlider) {
			currentBudget = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", i]] intValue];
			slider.maximumValue = (float)self.remainingBudget+currentBudget;
		}
		i++;
	}
	
}

-(IBAction)exactButtonPressed:(UIButton *)button {
	self.selectedSlider=(int)button.tag;
	UISlider *slider = [self.sliders objectAtIndex:self.selectedSlider];
	self.amountTextField.text = [NSString stringWithFormat:@"%d", (int)slider.value];
	self.popupLabel.text = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dName", (int)button.tag]];
	self.popupView.hidden=NO;
}

-(IBAction)submitButtonPressed:(id)sender {
	UISlider *slider = [self.sliders objectAtIndex:self.selectedSlider];
	float value = [self.amountTextField.text floatValue];
	float max = slider.maximumValue;
	if(value>max)
		value=max;
	
	slider.value = value;
	UILabel *label = [self.labels objectAtIndex:self.selectedSlider];
	label.text = [ObjectiveCScripts convertNumberToMoneyString:value];
	[self displayAmountsForSlider:self.selectedSlider value:value];
	self.popupView.hidden=YES;
	[self.amountTextField resignFirstResponder];
}


@end

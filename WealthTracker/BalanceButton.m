//
//  BalanceButton.m
//  BalanceApp
//
//  Created by Rick Medved on 4/8/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "BalanceButton.h"
#import "ObjectiveCScripts.h"

#define kWidth	130
#define kHeight	85


@implementation BalanceButton

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
//	self.layer.cornerRadius = 5;
	self.layer.masksToBounds = YES;				// clips background images to rounded corners
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1].CGColor;
	self.layer.borderWidth = 1.;
	self.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1];
	
	
	self.budgetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWidth, 65)];
	self.budgetButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:22.f];
	NSString *title = [NSString stringWithFormat:@"%@ Button", [NSString fontAwesomeIconStringForEnum:FAShoppingCart]];
	[self.budgetButton setTitle:title forState:UIControlStateNormal];

	[self addSubview:self.budgetButton];
	
	self.barView = [[UIView alloc] initWithFrame:CGRectZero];
	self.barView.backgroundColor = [UIColor whiteColor];
	self.barView.layer.masksToBounds = YES;				// clips background images to rounded corners
	self.barView.layer.borderColor = [UIColor blackColor].CGColor;
	self.barView.layer.borderWidth = 1.;
	[self addSubview:self.barView];
	
	self.progressView = [[UIView alloc] initWithFrame:CGRectZero];
	self.progressView.backgroundColor = [UIColor greenColor];
	[self.barView addSubview:self.progressView];

	self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, kWidth, 22)];
	self.descriptionLabel.font = [UIFont boldSystemFontOfSize:14];	// label is 17, system is 14
	self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
	self.descriptionLabel.textColor = [UIColor colorWithWhite:.8 alpha:1];
	self.descriptionLabel.text = @"(Description)";
	[self addSubview:self.descriptionLabel];
	
	self.budgetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, kWidth, 22)];
	self.budgetLabel.font = [UIFont boldSystemFontOfSize:14];	// label is 17, system is 14
	self.budgetLabel.textAlignment = NSTextAlignmentCenter;
	self.budgetLabel.textColor = [UIColor blackColor];
	self.budgetLabel.text = @"$0";
	[self addSubview:self.budgetLabel];
	
}

-(void)setButtonTitleForType:(int)type delegate:(id)delegate sel:(SEL)sel {
	self.budgetButton.tag=type;
	int budget = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", (int)self.budgetButton.tag]] intValue];
	self.budgetLabel.text = [ObjectiveCScripts convertNumberToMoneyString:budget];
	[self.budgetButton addTarget:delegate action:sel forControlEvents:UIControlEventTouchDown];
	switch (type) {
  case 0: {
			NSString *title = [NSString stringWithFormat:@"%@ Snacks", [NSString fontAwesomeIconStringForEnum:FACoffee]];
			[self.budgetButton setTitle:title forState:UIControlStateNormal];
			self.descriptionLabel.hidden=NO;
		    self.descriptionLabel.text = @"(Coffee)";
			break;
  }
  case 1: {
			NSString *title = [NSString stringWithFormat:@"%@ Meals", [NSString fontAwesomeIconStringForEnum:FACutlery]];
			[self.budgetButton setTitle:title forState:UIControlStateNormal];
			self.descriptionLabel.hidden=NO;
		    self.descriptionLabel.text = @"(Restaurant)";
			break;
  }
  case 2: {
			NSString *title = [NSString stringWithFormat:@"%@ Groceries", [NSString fontAwesomeIconStringForEnum:FAShoppingCart]];
			[self.budgetButton setTitle:title forState:UIControlStateNormal];
			self.descriptionLabel.hidden=YES;
			break;
  }
  case 3: {
			NSString *title = [NSString stringWithFormat:@"%@ Shop", [NSString fontAwesomeIconStringForEnum:FABriefcase]];
			[self.budgetButton setTitle:title forState:UIControlStateNormal];
			self.descriptionLabel.hidden=YES;
			break;
  }
  case 4: {
			NSString *title = [NSString stringWithFormat:@"%@ Fun", [NSString fontAwesomeIconStringForEnum:FATicket]];
			[self.budgetButton setTitle:title forState:UIControlStateNormal];
			self.descriptionLabel.hidden=YES;
			break;
  }
  case 5: {
			NSString *title = [NSString stringWithFormat:@"%@ Other", [NSString fontAwesomeIconStringForEnum:FAUsd]];
			[self.budgetButton setTitle:title forState:UIControlStateNormal];
		    self.descriptionLabel.text = @"(Fuel/Misc)";
			self.descriptionLabel.hidden=NO;
			break;
  }
			
  default:
			break;
	}
}

-(double)updateBudgetAmount:(NSManagedObjectContext *)context {
	int budget = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", (int)self.budgetButton.tag]] intValue];
	self.budgetLabel.text = [ObjectiveCScripts convertNumberToMoneyString:budget];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"month = %d AND year = %d AND bucket = %d", [ObjectiveCScripts nowMonth], [ObjectiveCScripts nowYear], self.budgetButton.tag];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"PURCHASE" predicate:predicate sortColumn:@"dateStamp" mOC:context ascendingFlg:NO];
	double value=0;
	for(NSManagedObject *mo in items) {
		value += [[mo valueForKey:@"amount"] doubleValue];
	}
	[self setBarValue:budget-value max:budget];
	return value;
}

-(void)setBarValue:(float)value max:(float)max {
	float percent = 0;
	if(max>0)
		percent = value/max;
	float maxWidth = self.barView.frame.size.width;
	self.progressView.frame = CGRectMake(0, 0, maxWidth*percent, 20);
	self.progressView.backgroundColor = [UIColor greenColor];
	if(percent<=.5)
		self.progressView.backgroundColor = [UIColor yellowColor];
	if(percent<=.25)
		self.progressView.backgroundColor = [UIColor redColor];
	if(value<0) {
		self.progressView.frame = CGRectMake(0, 0, maxWidth, 20);
		self.progressView.backgroundColor = [UIColor orangeColor];
	}
	self.budgetLabel.text = [ObjectiveCScripts convertNumberToMoneyString:value];
}


@end

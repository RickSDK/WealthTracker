//
//  BalanceButton.m
//  BalanceApp
//
//  Created by Rick Medved on 4/8/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "BalanceButton.h"
#import "ObjectiveCScripts.h"

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
	float kWidth = [[UIScreen mainScreen] bounds].size.width/2;
	
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
	
	self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(kWidth-60, 0, 60, 30)];
	self.editButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:15.f];
	[self.editButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	[self.editButton setTitle:[NSString stringWithFormat:@"%@", [NSString fontAwesomeIconStringForEnum:FAPencilSquareO]] forState:UIControlStateNormal];
	[self addSubview:self.editButton];

	
}

-(void)setButtonTitleForType:(int)type delegate:(id)delegate sel:(SEL)sel editSel:(SEL)editSel {
	self.budgetButton.tag=type;
	int budget = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", (int)self.budgetButton.tag]] intValue];
	self.budgetLabel.text = [ObjectiveCScripts convertNumberToMoneyString:budget];
	[self.budgetButton addTarget:delegate action:sel forControlEvents:UIControlEventTouchDown];
	self.editButton.tag=type;
	[self.editButton addTarget:delegate action:editSel forControlEvents:UIControlEventTouchDown];
	
	NSString *name = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dName", type]];
	NSString *subName = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dSubName", type]];
	int iconNum = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dIcon", type]] intValue];
	
	[self.budgetButton setTitle:[NSString stringWithFormat:@"%@ %@", [ObjectiveCScripts fontAwesomeIconForNumber:iconNum], name] forState:UIControlStateNormal];
	self.descriptionLabel.hidden=subName.length==0;
	self.descriptionLabel.text = [NSString stringWithFormat:@"(%@)", subName];
	
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

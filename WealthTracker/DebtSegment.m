//
//  DebtSegment.m
//  BalanceApp
//
//  Created by Rick Medved on 4/7/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "DebtSegment.h"

@implementation DebtSegment

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit2];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit2];
	}
	return self;
}

- (void)commonInit2
{

	
	UIFont *font = [UIFont fontWithName:kFontAwesomeFamilyName size:15.f];
	NSMutableDictionary *attribsNormal;
	attribsNormal = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil];
	
	NSMutableDictionary *attribsSelected;
	attribsSelected = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
	
	[self setTitleTextAttributes:attribsNormal forState:UIControlStateNormal];
	[self setTitleTextAttributes:attribsSelected forState:UIControlStateSelected];
	
	int i=0;
	[self setTitle:[NSString stringWithFormat:@"%@ List", [NSString fontAwesomeIconStringForEnum:FAList]] forSegmentAtIndex:i++];
	[self setTitle:[NSString stringWithFormat:@"%@ Analysis", [NSString fontAwesomeIconStringForEnum:FAUser]] forSegmentAtIndex:i++];
	[self setTitle:[NSString stringWithFormat:@"%@ Stats", [NSString fontAwesomeIconStringForEnum:FABarChartO]] forSegmentAtIndex:i++];
	[self changeSegment];
}

@end

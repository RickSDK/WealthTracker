//
//  PieChartSegment.m
//  WealthTracker
//
//  Created by Rick Medved on 3/12/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "PieChartSegment.h"

@implementation PieChartSegment

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
	
	id pieChart  = [NSString fontAwesomeIconStringForEnum:FApieChart];
	id barChartO = [NSString fontAwesomeIconStringForEnum:FABarChartO];
	
	UIFont *font = [UIFont fontWithName:kFontAwesomeFamilyName size:17.f];
	NSMutableDictionary *attribsNormal;
	attribsNormal = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, nil];
	
	NSMutableDictionary *attribsSelected;
	attribsSelected = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil];
	
	[self setTitleTextAttributes:attribsNormal forState:UIControlStateNormal];
	[self setTitleTextAttributes:attribsSelected forState:UIControlStateSelected];
	
	int i=0;
	[self setTitle:[NSString stringWithFormat:@"%@ Net Change", barChartO] forSegmentAtIndex:i++];
	[self setTitle:[NSString stringWithFormat:@"%@ Totals", pieChart] forSegmentAtIndex:i++];
	[self changeSegment];
}


@end

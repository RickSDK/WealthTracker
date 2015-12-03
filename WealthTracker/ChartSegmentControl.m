//
//  ChartSegmentControl.m
//  WealthTracker
//
//  Created by Rick Medved on 12/1/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "ChartSegmentControl.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"

@implementation ChartSegmentControl

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
	id lineChart = [NSString fontAwesomeIconStringForEnum:FAlineChart];
	id barChartO = [NSString fontAwesomeIconStringForEnum:FABarChartO];
//	id areaChart = [NSString fontAwesomeIconStringForEnum:FAareaChart];

	UIFont *font = [UIFont fontWithName:kFontAwesomeFamilyName size:14.f];
	NSMutableDictionary *attribsNormal;
	attribsNormal = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, nil];
	
	NSMutableDictionary *attribsSelected;
	attribsSelected = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil];
	
	[self setTitleTextAttributes:attribsNormal forState:UIControlStateNormal];
	[self setTitleTextAttributes:attribsSelected forState:UIControlStateSelected];

	int i=0;
	[self setTitle:[NSString stringWithFormat:@"%@ Bars", barChartO] forSegmentAtIndex:i++];
	if(self.numberOfSegments>2)
		[self setTitle:[NSString stringWithFormat:@"%@ Lines", lineChart] forSegmentAtIndex:i++];
	[self setTitle:[NSString stringWithFormat:@"%@ Pie", pieChart] forSegmentAtIndex:i++];
	[self changeSegment];
}

@end

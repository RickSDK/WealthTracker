//
//  ListChartSegment.m
//  WealthTracker
//
//  Created by Rick Medved on 3/11/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "ListChartSegment.h"

@implementation ListChartSegment

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
	
	id listFont  = [NSString fontAwesomeIconStringForEnum:FAList];
	id barChartO = [NSString fontAwesomeIconStringForEnum:FABarChartO];
	
	UIFont *font = [UIFont fontWithName:kFontAwesomeFamilyName size:18.f];
	NSMutableDictionary *attribsNormal;
	attribsNormal = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor blackColor], UITextAttributeTextColor, nil];
	
	NSMutableDictionary *attribsSelected;
	attribsSelected = [NSMutableDictionary dictionaryWithObjectsAndKeys:font, UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil];
	
	[self setTitleTextAttributes:attribsNormal forState:UIControlStateNormal];
	[self setTitleTextAttributes:attribsSelected forState:UIControlStateSelected];
	
	int i=0;
	[self setTitle:[NSString stringWithFormat:@"%@ Details", listFont] forSegmentAtIndex:i++];
	[self setTitle:[NSString stringWithFormat:@"%@ Charts", barChartO] forSegmentAtIndex:i++];
	[self changeSegment];
}


@end

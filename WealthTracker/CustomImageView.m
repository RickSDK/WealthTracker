//
//  CustomImageView.m
//  WealthTracker
//
//  Created by Rick Medved on 7/30/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "CustomImageView.h"
#define CORNER_RADIUS          7.0

@implementation CustomImageView

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
	self.layer.cornerRadius = CORNER_RADIUS;
	self.layer.masksToBounds = YES;				// clips background images to rounded corners
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderWidth = 2.;
	
	// Default is white background and ATTBlue text color
	self.backgroundColor = [UIColor whiteColor];
}


@end

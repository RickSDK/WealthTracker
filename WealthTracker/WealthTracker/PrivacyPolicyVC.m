//
//  PrivacyPolicyVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/28/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "PrivacyPolicyVC.h"
#import "ObjectiveCScripts.h"

@interface PrivacyPolicyVC ()

@end

@implementation PrivacyPolicyVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setTitle:@"Privacy Policy"];
	
	self.mainTextView.text = [NSString stringWithFormat:@"%@ EULA\n\nPrivacy Guarantee: WT will never sell or share any information with any other third party vendor.\n\nEmail address is only used to reset lost passwords and is never shared with anyone.\n\nNo financial info or any info of any kind is ever shared with any party.", [ObjectiveCScripts appName]];
	
	// Do any additional setup after loading the view from its nib.
}


@end

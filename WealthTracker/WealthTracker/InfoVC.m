//
//  InfoVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/30/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "InfoVC.h"

@interface InfoVC ()

@end

@implementation InfoVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Info"];
    // Do any additional setup after loading the view from its nib.
}


@end

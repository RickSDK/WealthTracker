//
//  InfoVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/30/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "InfoVC.h"
#import "StartupVC.h"

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
	
}

-(void)manageButtonPressed {
	StartupVC *detailViewController = [[StartupVC alloc] initWithNibName:@"StartupVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}


@end

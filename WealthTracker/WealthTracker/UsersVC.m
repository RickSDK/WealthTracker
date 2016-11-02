//
//  UsersVC.m
//  WealthTracker
//
//  Created by Rick Medved on 11/2/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "UsersVC.h"

@interface UsersVC ()

@end

@implementation UsersVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Users!"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)emailButtonClicked:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", @"rickmedved@hotmail.com"]]];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

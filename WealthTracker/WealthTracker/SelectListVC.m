//
//  SelectListVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/11/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "SelectListVC.h"
#import "EditItemVC.h"

@interface SelectListVC ()

@end

@implementation SelectListVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Selection"];
	
	self.listArray = [[NSMutableArray alloc] init];
	
	self.titleLabel.text = self.titleString;
	
	if(self.listNumber==1) {
		[self.listArray addObject:@"Auto"];
		[self.listArray addObject:@"Motorcycle"];
		[self.listArray addObject:@"Boat"];
		[self.listArray addObject:@"RV"];
		[self.listArray addObject:@"ATV"];
		[self.listArray addObject:@"Jet Ski"];
		[self.listArray addObject:@"Snowmobile"];
		[self.listArray addObject:@"Other"];
	}
	if(self.listNumber==2) {
		[self.listArray addObject:@"Own outright"];
		[self.listArray addObject:@"Financing"];
		[self.listArray addObject:@"Leasing"];
	}
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	cell.textLabel.text=[self.listArray objectAtIndex:indexPath.row];
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.listArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[(EditItemVC *)self.callbackController updateValue:[self.listArray objectAtIndex:indexPath.row]];
	[self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}


@end

//
//  BudgetVC.m
//  WealthTracker
//
//  Created by Rick Medved on 5/5/16.
//  Copyright (c) 2016 Rick Medved. All rights reserved.
//

#import "BudgetVC.h"
#import "StatsPageVC.h"
#import "EditBudgetVC.h"
#import "FixedExpensesVC.h"
#import "CashFlowObj.h"
#import "CashFlowVC.h"
#import "IncomeVC.h"
#import "PurchaseCell.h"

@interface BudgetVC ()

@end

@implementation BudgetVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setTitle:@"Budget"];
	
	
	self.expenseView.backgroundColor = [ObjectiveCScripts darkColor];
	self.incomeView.backgroundColor = [ObjectiveCScripts darkColor];
	self.cashFlowView.backgroundColor = [ObjectiveCScripts mediumkColor];
	
	if([ObjectiveCScripts getUserDefaultValue:@"button0Name"].length==0)
		[self initialyzeButtonNames];

	self.iconButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:17.f];
	self.editView.hidden=YES;


	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editBUdget)];
	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self setupButtons];

	if(self.topSegment.selectedSegmentIndex!=0) {
		self.topSegment.selectedSegmentIndex=0;
		[self.topSegment changeSegment];
	}
	
	self.mainTableView.hidden=YES;
	[self layoutButtons];
	[self calcExpenses];
	
	self.monthlySpent=0;
	self.monthlySpent += [self.balButton1 updateBudgetAmount:self.managedObjectContext];
	self.monthlySpent += [self.balButton2 updateBudgetAmount:self.managedObjectContext];
	self.monthlySpent += [self.balButton3 updateBudgetAmount:self.managedObjectContext];
	self.monthlySpent += [self.balButton4 updateBudgetAmount:self.managedObjectContext];
	self.monthlySpent += [self.balButton5 updateBudgetAmount:self.managedObjectContext];
	self.monthlySpent += [self.balButton6 updateBudgetAmount:self.managedObjectContext];
	
	self.step=[[ObjectiveCScripts getUserDefaultValue:@"step"] intValue];
	
	self.monthlyBudget = 0;
	self.monthlyBudget += [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", 0]] intValue];
	self.monthlyBudget += [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", 1]] intValue];
	self.monthlyBudget += [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", 2]] intValue];
	self.monthlyBudget += [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", 3]] intValue];
	self.monthlyBudget += [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", 4]] intValue];
	self.monthlyBudget += [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"budget%dAmount", 5]] intValue];
	
	self.monthlyProjected = self.monthlySpent *30/[ObjectiveCScripts nowDay];
	
	self.titleStr = @"Monthly Budget";
	self.altStr = @"Spending Items";
	self.analysisStr = [self budgetAnalysis:@"discretionary" budget:self.monthlyBudget spent:self.monthlySpent];
	
	int monthlySavings = [[ObjectiveCScripts getUserDefaultValue:@"monthlySavings"] intValue];
	int balance = self.incomeTotal-monthlySavings-self.monthlyBudget-self.expensesTotal;
	if(abs(balance)>10 && self.incomeTotal>0 && self.expensesTotal>0)
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Your budget needs to be set. Click 'Edit' button above"];

	[self loadData];
	[self populateGraph];
}

-(void)setupButtons {
	[self.balButton1 setButtonTitleForType:0 delegate:self sel:@selector(mainButtonClicked:) editSel:@selector(editButtonClicked:)];
	[self.balButton2 setButtonTitleForType:1 delegate:self sel:@selector(mainButtonClicked:) editSel:@selector(editButtonClicked:)];
	[self.balButton3 setButtonTitleForType:2 delegate:self sel:@selector(mainButtonClicked:) editSel:@selector(editButtonClicked:)];
	[self.balButton4 setButtonTitleForType:3 delegate:self sel:@selector(mainButtonClicked:) editSel:@selector(editButtonClicked:)];
	[self.balButton5 setButtonTitleForType:4 delegate:self sel:@selector(mainButtonClicked:) editSel:@selector(editButtonClicked:)];
	[self.balButton6 setButtonTitleForType:5 delegate:self sel:@selector(mainButtonClicked:) editSel:@selector(editButtonClicked:)];
}

-(void)initialyzeButtonNames {
	[ObjectiveCScripts setUserDefaultValue:@"Snacks" forKey:@"button0Name"];
	[ObjectiveCScripts setUserDefaultValue:@"Meals" forKey:@"button1Name"];
	[ObjectiveCScripts setUserDefaultValue:@"Groceries" forKey:@"button2Name"];
	[ObjectiveCScripts setUserDefaultValue:@"Shop" forKey:@"button3Name"];
	[ObjectiveCScripts setUserDefaultValue:@"Fun" forKey:@"button4Name"];
	[ObjectiveCScripts setUserDefaultValue:@"Other" forKey:@"button5Name"];
	
	[ObjectiveCScripts setUserDefaultValue:@"Coffee" forKey:@"button0SubName"];
	[ObjectiveCScripts setUserDefaultValue:@"Restaurant" forKey:@"button1SubName"];
	[ObjectiveCScripts setUserDefaultValue:@"" forKey:@"button2SubName"];
	[ObjectiveCScripts setUserDefaultValue:@"" forKey:@"button3SubName"];
	[ObjectiveCScripts setUserDefaultValue:@"" forKey:@"button4SubName"];
	[ObjectiveCScripts setUserDefaultValue:@"Fuel/Misc" forKey:@"button5SubName"];
	
	[ObjectiveCScripts setUserDefaultValue:@"0" forKey:@"button0Icon"];
	[ObjectiveCScripts setUserDefaultValue:@"1" forKey:@"button1Icon"];
	[ObjectiveCScripts setUserDefaultValue:@"2" forKey:@"button2Icon"];
	[ObjectiveCScripts setUserDefaultValue:@"3" forKey:@"button3Icon"];
	[ObjectiveCScripts setUserDefaultValue:@"4" forKey:@"button4Icon"];
	[ObjectiveCScripts setUserDefaultValue:@"5" forKey:@"button5Icon"];
}

-(void)editButtonClicked:(UIButton *)button {
	self.editView.hidden=NO;
	self.editButton = (int)button.tag;
	NSString *name = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dName", self.editButton]];
	NSString *subName = [ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dSubName", self.editButton]];
	self.editIcon = [[ObjectiveCScripts getUserDefaultValue:[NSString stringWithFormat:@"button%dIcon", self.editButton]] intValue];
	
	self.nameTextField.text = name;
	self.subNameTextField.text = subName;
	[self.iconButton setTitle:[ObjectiveCScripts fontAwesomeIconForNumber:self.editIcon] forState:UIControlStateNormal];
}

-(void)resignKeyboard {
	[self.nameTextField resignFirstResponder];
	[self.subNameTextField resignFirstResponder];
}

-(IBAction)xButtonClicked:(id)sender {
	self.editView.hidden=YES;
	[self resignKeyboard];
}
-(IBAction)symbolButtonClicked:(id)sender {
	self.editIcon++;
	[self.iconButton setTitle:[ObjectiveCScripts fontAwesomeIconForNumber:self.editIcon] forState:UIControlStateNormal];
}
-(IBAction)submitButtonClicked:(id)sender {
	self.editView.hidden=YES;
	[ObjectiveCScripts setUserDefaultValue:self.nameTextField.text forKey:[NSString stringWithFormat:@"button%dName", self.editButton]];
	[ObjectiveCScripts setUserDefaultValue:self.subNameTextField.text forKey:[NSString stringWithFormat:@"button%dSubName", self.editButton]];
	[ObjectiveCScripts setUserDefaultValue:[NSString stringWithFormat:@"%d", self.editIcon] forKey:[NSString stringWithFormat:@"button%dIcon", self.editButton]];
	[self resignKeyboard];
	[self setupButtons];
}



-(void)populateGraph {
	int year = [ObjectiveCScripts nowYear];
	int month = [ObjectiveCScripts nowMonth];
	year--;
	[self.graphObjects removeAllObjects];
	for(int i=1; i<=12; i++) {
		month++;
		if(month>12) {
			month=1;
			year++;
		}
		BOOL displayFlg=NO;
		NSString *name = [NSString stringWithFormat:@"%@ %d", [ObjectiveCScripts monthNameForNum:month-1], year];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"month = %d AND year = %d", month, year];
		NSArray *items = [CoreDataLib selectRowsFromEntity:@"PURCHASE" predicate:predicate sortColumn:nil mOC:self.managedObjectContext ascendingFlg:NO];
		int totalSpent=0;
		for(NSManagedObject *mo in items) {
			totalSpent += [[mo valueForKey:@"amount"] floatValue];
			displayFlg=YES;
		}
		
		if(displayFlg)
			[self.graphObjects addObject:[GraphLib graphObjectWithName:name amount:totalSpent rowId:1 reverseColorFlg:NO currentMonthFlg:NO]];
	}
	self.chartImageView.image = [GraphLib graphBarsWithItems:self.graphObjects];
}


-(void)loadData {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"month = %d AND year = %d", [ObjectiveCScripts nowMonth], [ObjectiveCScripts nowYear]];
	NSArray *items = [CoreDataLib selectRowsFromEntity:@"PURCHASE" predicate:predicate sortColumn:@"dateStamp" mOC:self.managedObjectContext ascendingFlg:NO];
	
	[self.itemsArray removeAllObjects];
	for(NSManagedObject *mo in items) {
		PurchaseObj *item1 = [PurchaseObj objFromMO:mo];
		[self.itemsArray addObject:item1];
	}
	
}


-(void)calcExpenses {
	self.expensesTotal=[ObjectiveCScripts calculateExpenses:self.managedObjectContext];
	self.expenseTotalLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.expensesTotal];

	self.incomeTotal=[ObjectiveCScripts calculateIncome:self.managedObjectContext];
	self.incomeTotalLabel.text = [ObjectiveCScripts convertNumberToMoneyString:self.incomeTotal];

	self.arrowImageView.hidden=(self.expensesTotal>0 && self.incomeTotal>0);
	self.messageLabel.hidden=(self.expensesTotal>0 && self.incomeTotal>0);

	if(self.incomeTotal==0) {
		self.messageLabel.text = @"Update your monthly Income";
		self.arrowImageView.center = CGPointMake(self.screenWidth/2+self.incomeTotalLabel.center.x, self.screenHeight-180);
	}
	if(self.expensesTotal==0) {
		self.messageLabel.text = @"Update your monthly Expenses";
		self.arrowImageView.center = CGPointMake(self.expenseTotalLabel.center.x, self.screenHeight-180);
	}
	


}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint startTouchPosition = [touch locationInView:self.view];
	
	
	if(CGRectContainsPoint(self.expenseView.frame, startTouchPosition)) {
		FixedExpensesVC *detailViewController = [[FixedExpensesVC alloc] initWithNibName:@"FixedExpensesVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	if(CGRectContainsPoint(self.incomeView.frame, startTouchPosition)) {
		IncomeVC *detailViewController = [[IncomeVC alloc] initWithNibName:@"IncomeVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
	if(CGRectContainsPoint(self.cashFlowView.frame, startTouchPosition)) {
		CashFlowVC *detailViewController = [[CashFlowVC alloc] initWithNibName:@"CashFlowVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(void)editBUdget {
	if(self.expensesTotal==0 || self.incomeTotal==0)
		[ObjectiveCScripts showAlertPopup:@"Notice" message:@"Enter monthly expenses & income first"];
	else {
		EditBudgetVC *detailViewController = [[EditBudgetVC alloc] initWithNibName:@"EditBudgetVC" bundle:nil];
		detailViewController.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

-(IBAction)mainButtonClicked:(UIButton *)button {
	StatsPageVC *detailViewController = [[StatsPageVC alloc] initWithNibName:@"StatsPageVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	detailViewController.title = [button.titleLabel.text substringToIndex:1];
	detailViewController.bucket=(int)button.tag;
	[self.navigationController pushViewController:detailViewController animated:YES];	
}

-(void)layoutButtons {
	float top = 56;
	float bot = 77;
	float buttonHeight = ((self.screenHeight-top-bot-60)/3)-4;
	float buttonWidth = self.screenWidth/2-1;
	[self layoutFrameForButton:self.balButton1 x:0 y:top width:buttonWidth height:buttonHeight];
	[self layoutFrameForButton:self.balButton2 x:buttonWidth+1 y:top width:buttonWidth height:buttonHeight];
	[self layoutFrameForButton:self.balButton3 x:0 y:top+buttonHeight+2 width:buttonWidth height:buttonHeight];
	[self layoutFrameForButton:self.balButton4 x:buttonWidth+1 y:top+buttonHeight+2 width:buttonWidth height:buttonHeight];
	[self layoutFrameForButton:self.balButton5 x:0 y:top+buttonHeight+buttonHeight+4 width:buttonWidth height:buttonHeight];
	[self layoutFrameForButton:self.balButton6 x:buttonWidth+1 y:top+buttonHeight+buttonHeight+4 width:buttonWidth height:buttonHeight];
}

-(void)layoutFrameForButton:(BalanceButton *)button x:(float)x y:(float)y width:(float)width height:(float)height {
	button.frame = CGRectMake(x, y, width, height);
	button.budgetButton.frame = CGRectMake(0, 0, width, height-24);
	button.barView.frame = CGRectMake(3, height-24, width-6, 20);
	button.progressView.frame = CGRectMake(0, 0, width, 20);
	button.budgetLabel.frame = CGRectMake(0, height-24, width, 20);
	button.descriptionLabel.frame = CGRectMake(0, height-height/3-15, width, 20);
}

-(IBAction)cashFlowButtonClicked:(id)sender {
	CashFlowVC *detailViewController = [[CashFlowVC alloc] initWithNibName:@"CashFlowVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

-(IBAction)topSegmentChanged:(id)sender {
	[self.topSegment changeSegment];
	[self.mainTableView reloadData];
	self.mainTableView.hidden=self.topSegment.selectedSegmentIndex==0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(self.topSegment.selectedSegmentIndex==0)
		return 0;
	if(self.topSegment.selectedSegmentIndex==1)
		return 2;
	else
		return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(self.topSegment.selectedSegmentIndex==0)
		return 0;
	if(self.topSegment.selectedSegmentIndex==1) {
		if(section==0)
			return 1;
		else
			return self.itemsArray.count;
	} else
		return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	
	if(self.topSegment.selectedSegmentIndex==0) {
		return nil;
	}
	if(self.topSegment.selectedSegmentIndex==1) {
		if(indexPath.section==0) {
			MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:3 labelProportion:.5];
			
			cell.mainTitle = self.titleStr;
			cell.alternateTitle = self.altStr;
			UIColor *projectedColor = (self.monthlyProjected<=self.monthlyBudget)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
			
			cell.titleTextArray = [NSArray arrayWithObjects:@"Budget", @"Spent", @"Projected Spending", nil];
			cell.fieldTextArray = [NSArray arrayWithObjects:[ObjectiveCScripts convertNumberToMoneyString:self.monthlyBudget], [ObjectiveCScripts convertNumberToMoneyString:self.monthlySpent], [ObjectiveCScripts convertNumberToMoneyString:self.monthlyProjected], nil];
			cell.fieldColorArray = [NSArray arrayWithObjects:[UIColor blackColor], [UIColor blackColor], projectedColor, nil];
			
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		} else {
			PurchaseCell *cell = [[PurchaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			
			PurchaseObj *item = [self.itemsArray objectAtIndex:indexPath.row];
			[PurchaseCell populateCell:cell obj:item];
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
	} else {
		if(indexPath.row==0) {
			UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			
			cell.backgroundView = [[UIImageView alloc] initWithImage:self.chartImageView.image];
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		} else {
			MultiLineDetailCellWordWrap *cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withRows:12 labelProportion:.5];
			
			cell.mainTitle = self.titleStr;
			cell.alternateTitle = self.altStr;
			
			NSMutableArray *namesArray = [[NSMutableArray alloc] init];
			NSMutableArray *valuesArray = [[NSMutableArray alloc] init];
			NSMutableArray *colorsArray = [[NSMutableArray alloc] init];
			
			int prevAmount = 0;
			for(GraphObject *obj in self.graphObjects) {
				[namesArray addObject:obj.name];
				NSString *value = [ObjectiveCScripts convertNumberToMoneyString:obj.amount];
				NSString *sign = obj.amount-prevAmount>=0?@"+":@"";
				if(prevAmount>0)
					value = [NSString stringWithFormat:@"%@ (%@%@)", value, sign, [ObjectiveCScripts convertNumberToMoneyString:obj.amount-prevAmount]];
				[valuesArray addObject:value];
				UIColor *color = (obj.amount-prevAmount>=0)?[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]:[UIColor redColor];
				[colorsArray addObject:color];
				NSLog(@"%@ %d %d", obj.name, (int)obj.amount, prevAmount);
				prevAmount = (int)obj.amount;
			}
			
			cell.titleTextArray = namesArray;
			cell.fieldTextArray = valuesArray;
			cell.fieldColorArray = colorsArray;
			
			cell.accessoryType= UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.topSegment.selectedSegmentIndex==1 && indexPath.section==0)
		return 19*3+20;
	//		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:[NSArray arrayWithObject:self.analysisStr]
	//																   tableView:self.mainTableView
	//														labelWidthProportion:0]+20;
	if(self.topSegment.selectedSegmentIndex==1 && indexPath.section==1)
		return 44;
	if(self.topSegment.selectedSegmentIndex==2 && indexPath.row==0)
		return 200;
	if(self.topSegment.selectedSegmentIndex==2 && indexPath.row==1)
		return 18*12+20;
	
	return 44;
}







@end

//
//  InAppPurchaseVC.m
//  WealthTracker
//
//  Created by Rick Medved on 7/28/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import "InAppPurchaseVC.h"
#import "CoreDataLib.h"
#import "ObjectiveCScripts.h"

//#define kInAppPurchaseProUpgradeProductId @"proVersion"
#define kInAppPurchaseProUpgradeProductId @"B2BUpgrade"

@interface InAppPurchaseVC ()

@end

@implementation InAppPurchaseVC

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Pro Version"];
	
	int age = [CoreDataLib getNumberFromProfile:@"age" mOC:self.managedObjectContext];
	if(age==123) {
		[self unlockProVersion];
	}
	
	self.upgradeButton.hidden=([ObjectiveCScripts getUserDefaultValue:@"upgradeFlg"].length>0);
	
}

-(void)unlockProVersion {
	[ObjectiveCScripts setUserDefaultValue:@"Y" forKey:@"upgradeFlg"];
	[ObjectiveCScripts showAlertPopup:@"Congratulations!" message:@"Pro version has been unlocked!"];
}



//-----------In APP Purchase
#pragma mark - In App Purchase

-(IBAction)restorePurchaseButtonClicked:(id)sender {
	[self.webServiceView showCancelButton];
	[self.webServiceView startWithTitle:@"Working..."];
	[self restoreStore];
//	[self requestProUpgradeProductData];
//	NSSet *productIdentifiers = [NSSet setWithObject:kInAppPurchaseProUpgradeProductId];
//	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
//	request.delegate = self;
//	[request start];
//	self.productsRequest = request; // <<<--- This will retain the request object
}

- (void)restoreStore
{
	// restarts any purchases if they were interrupted last time the app was open
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	
	// get the product description (defined in early sections)
	[self requestProUpgradeProductData];
}



-(IBAction)upgradeButtonClicked:(id)sender {
	[self.webServiceView showCancelButton];
	[self.webServiceView startWithTitle:@"Working..."];
	[self loadStore];
}

- (void)loadStore
{
	// restarts any purchases if they were interrupted last time the app was open
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	
	// get the product description (defined in early sections)
	[self requestProUpgradeProductData];
}


- (void)requestProUpgradeProductData
{
	NSSet *productIdentifiers = [NSSet setWithObject:kInAppPurchaseProUpgradeProductId];
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	request.delegate = self;
	[request start];
	
	self.productsRequest = request; // <<<--- This will retain the request object

	// we will release the request object in the delegate callback
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	NSArray *products = response.products;
	self.proUpgradeProduct = [products count] == 1 ? [products firstObject] : nil;
	if (self.proUpgradeProduct)
	{
		NSLog(@"Product title: %@" , self.proUpgradeProduct.localizedTitle);
		NSLog(@"Product description: %@" , self.proUpgradeProduct.localizedDescription);
		NSLog(@"Product price: %@" , self.proUpgradeProduct.price);
		NSLog(@"Product id: %@" , self.proUpgradeProduct.productIdentifier);
	}
	
	for (NSString *invalidProductId in response.invalidProductIdentifiers)
	{
		NSLog(@"Invalid product id: %@" , invalidProductId);
		[self.webServiceView stop];
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];

	if([self canMakePurchases])
		[self purchaseProUpgrade];
}


-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	NSLog(@"didFailWithError: %@",error.description);
	[ObjectiveCScripts showAlertPopup:@"Error" message:@"Cannot connect to iTunes Store. Contact app admin."];
	_productsRequest = nil; // <<<--- This will release the request object
	[self.webServiceView stop];
}



//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
	NSLog(@"+++canMakePurchases");
	return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProUpgrade
{
	NSLog(@"+++purchaseProUpgrade");
	SKPayment *payment = [SKPayment paymentWithProduct:self.proUpgradeProduct];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
	NSLog(@"+++recordTransaction");
	if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId])
	{
		// save the transaction receipt to disk
		[[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
	NSLog(@"+++provideContent");
	if ([productId isEqualToString:kInAppPurchaseProUpgradeProductId])
	{
		// enable the pro features
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
	NSLog(@"+++finishTransaction");
	// remove the transaction from the payment queue.
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	[self.webServiceView stop];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
	if (wasSuccessful)
	{
		// send out a notification that we’ve finished the transaction
		[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
		[self unlockProVersion];
	}
	else
	{
		// send out a notification for the failed transaction
		[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
	}
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
	NSLog(@"+++completeTransaction");
	[self recordTransaction:transaction];
	[self provideContent:transaction.payment.productIdentifier];
	[self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
	[self recordTransaction:transaction.originalTransaction];
	[self provideContent:transaction.originalTransaction.payment.productIdentifier];
	[self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
	NSLog(@"+++failedTransaction");
	if (transaction.error.code != SKErrorPaymentCancelled)
	{
		// error!
		[self finishTransaction:transaction wasSuccessful:NO];
		NSLog(@"+++error");
	}
	else
	{
		// this is fine, the user just cancelled, so don’t notify
		[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
		[self.webServiceView stop];
		NSLog(@"+++stop");
	}
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	NSLog(@"+++paymentQueue");
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				[self completeTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed:
				[self failedTransaction:transaction];
				break;
			case SKPaymentTransactionStateRestored:
				[self restoreTransaction:transaction];
				break;
			default:
				break;
		}
	}
}




@end

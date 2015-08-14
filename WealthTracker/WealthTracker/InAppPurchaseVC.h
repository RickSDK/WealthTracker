//
//  InAppPurchaseVC.h
//  WealthTracker
//
//  Created by Rick Medved on 7/28/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "WebServiceView.h"

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

@interface InAppPurchaseVC : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UIButton *upgradeButton;

@property (strong, nonatomic) SKProduct *proUpgradeProduct;
@property (strong, nonatomic) SKProductsRequest *productsRequest;
@property (nonatomic, strong) IBOutlet WebServiceView *webServiceView;

-(IBAction)upgradeButtonClicked:(id)sender;

- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;

@end

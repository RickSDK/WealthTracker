//
//  CustomButton.h
//  PokerTracker
//
//  Created by Rick Medved on 6/26/15.
//
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton

@property (nonatomic) int mode;

-(void)assignMode:(int)mode;

@end

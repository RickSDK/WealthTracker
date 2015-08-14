//
//  ItemCellObj.h
//  WealthTracker
//
//  Created by Rick Medved on 7/11/15.
//  Copyright (c) 2015 Rick Medved. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemCellObj : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *flag;
@property (nonatomic) int fieldType;
//		0=string
//		1=money
//		2=int
//		3=float (%)
//		4=float (any type)
@property (nonatomic) int listNumber;



@end

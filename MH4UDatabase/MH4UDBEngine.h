//
//  MH4UDBEngine.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/5/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Armor;


@interface MH4UDBEngine : NSObject

-(NSArray *)populateArmorArray;
-(Armor *)populateArmor:(Armor *)armor;
@end


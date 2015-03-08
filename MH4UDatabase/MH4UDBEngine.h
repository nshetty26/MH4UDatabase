//
//  MH4UDBEngine.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/5/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Armor;
@class Item;

@interface MH4UDBEngine : NSObject

-(NSArray *)populateAllMonsterArray;

-(NSArray *)populateArmorArray;
-(Armor *)populateArmor:(Armor *)armor;

-(NSArray *)populateItemArray;
-(void)getCombiningItemsForItem:(Item*)item;
-(NSArray *)infoForCombinedTableCellItem:(NSNumber *)itemID;
@end


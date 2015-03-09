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
@class Monster;

@interface MH4UDBEngine : NSObject

-(NSArray *)populateAllMonsterArray;
-(void)getDamageForMonster:(Monster *)monster;

-(NSArray *)populateArmorArray;
-(Armor *)populateArmor:(Armor *)armor;

-(NSArray *)populateItemArray;
-(void)getCombiningItemsForItem:(Item*)item;
-(NSArray *)infoForCombinedTableCellforItemID:(NSNumber *)itemID;
-(void)getUsageItemsForItem:(Item*)item;
-(NSArray *)infoForUsageTableCellforItemID:(NSNumber *)itemID;
-(void)getMonsterDropsForItem:(Item*)item;
-(void)getQuestRewardsForItem:(Item*)item;
-(void)getLocationsForItem:(Item*)item;
@end


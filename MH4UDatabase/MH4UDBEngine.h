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
@class SkillCollection;

@interface MH4UDBEngine : NSObject

-(NSArray *)populateAllMonsterArray;
-(void)getDetailsForMonster:(Monster *)monster;

-(NSArray *)populateArmorArray;
-(Armor *)populateArmor:(Armor *)armor;

-(NSArray *)populateItemArray;
-(Item *)getItemForName:(NSString *)name;


-(void)getCombiningItemsForItem:(Item*)item;
-(NSArray *)infoForCombinedTableCellforItemID:(NSNumber *)itemID;
-(void)getUsageItemsForItem:(Item*)item;
-(NSArray *)infoForUsageTableCellforItemID:(NSNumber *)itemID;
-(void)getMonsterDropsForItem:(Item*)item;
-(void)getQuestRewardsForItem:(Item*)item;
-(void)getLocationsForItem:(Item*)item;

-(NSArray *)getCombiningItems;

-(NSArray *)getSkillTrees;
-(SkillCollection *)getSkillCollectionForSkillTreeID:(int)skillTreeID;

-(NSArray *)getAllDecorations;
-(NSArray *)getComponentsfor:(int)armorID;


@end


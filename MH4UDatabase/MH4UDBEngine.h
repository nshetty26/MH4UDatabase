//
//  MH4UDBEngine.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/5/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

/*
 select i1.name as 'In Item', i2.name as 'Out Item', quests.name as 'Unlock Quest' from wyporium inner join items as i1 on wyporium.item_in_id = i1._id inner join items as i2 on wyporium.item_out_id = i2._id inner join quests on wyporium.unlock_quest_id = quests._id
 */

#import <UIKit/UIKit.h>
@class Armor;
@class Quest;
@class Weapon;
@class Item;
@class Monster;
@class SkillTreeCollection;
@class Location;
@class ArmorSet;
@class Decoration;
@class Talisman;

@interface MH4UDBEngine : NSObject

-(NSArray *)getMonsters:(NSNumber *)monsterID;
-(void)getDetailsForMonster:(Monster *)monster;

-(NSArray *)getArmor:(NSNumber *)armorID;

-(Armor *)populateArmor:(Armor *)armor;

-(NSArray *)populateItemArray;
-(Item *)getItemForName:(NSString *)name;


-(void)getCombiningItemsForItem:(Item*)item;
//-(NSArray *)infoForCombinedTableCellforItemID:(NSNumber *)itemID;
-(void)getUsageItemsForItem:(Item*)item;
//-(NSArray *)infoForUsageTableCellforItemID:(NSNumber *)itemID;
-(void)getMonsterDropsForItem:(Item*)item;
-(void)getQuestRewardsForItem:(Item*)item;
-(void)getLocationsForItem:(Item*)item;

-(NSArray *)getCombiningItems;

-(NSArray *)getSkillTrees;
-(SkillTreeCollection *)getSkillCollectionForSkillTreeID:(int)skillTreeID;

-(NSArray *)getAllDecorations:(NSNumber *)decorationID;
-(NSArray *)getSkillTreesForDecorationID:(int)decorationID;
-(NSArray *)getComponentsfor:(int)armorID;

-(NSArray *)getAllQuests:(NSNumber *)questID;
-(void)getQuestInfoforQuest:(Quest*)quest;

-(NSArray *)getAllLocations:(NSNumber *)locationID;
-(void)getMonstersForLocation:(Location *)location;
-(void)getItemsForLocation:(Location *)location;

-(NSArray *)getWeaponTypes;
-(NSArray *)getWeaponsForWeaponType:(NSString *)weaponType;
-(Weapon *)getWeaponForWeaponID:(int)weaponID;
-(NSArray *)getHornSongsForHorn:(Weapon *)horn;

-(NSArray *) populateResultsWithSearch:(NSString *)searchString;

-(NSArray *)getAllArmorSets;
-(ArmorSet *)getArmorSetForSetID:(NSNumber *)setID;
-(BOOL)insertNewArmorSetWithName:(NSString *)name;
-(BOOL)deleteArmorSetWithID:(NSNumber *)setID;

-(BOOL)addSetItem:(Item *)setItem toArmorSetWithID:(NSNumber *)setID;
-(BOOL)checkSetItem:(Item *)setItem atArmorSetWithID:(NSNumber *)setID;

-(NSArray *)checkArmorSetForSlotsWithSetID:(NSNumber *)setID;
-(BOOL)cloneArmorSet:(ArmorSet *)armorSet withName:(NSString *)name;

-(BOOL)addDecoration:(Decoration *)decoration ToSlot:(NSString *)slot andArmorSetWithID:(NSNumber *)setID;
-(NSArray *)getDecorationsForArmorSet:(NSNumber *)setID andSetItem:(Item *)setItem;
-(BOOL)deleteDecoration:(Decoration *)decoration FromSetItemWithItemID:(Item *)setItem SetWithID:(NSNumber *)setID;
-(BOOL)deleteAllDecorationsForArmorSetWithID:(NSNumber *)setID andSetItem:(Item *)setItem;

-(NSArray *)getAllWyporiumTrades;
-(BOOL)insertNewTalismanIntoDatabase:(Talisman *)newTalisman;
-(BOOL)addTalisman:(Talisman *)talisman toArmorSet:(ArmorSet *)set;

@end


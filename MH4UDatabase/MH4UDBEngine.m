//
//  MH4UDBEngine.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/5/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MonsterDisplay.h"
#import "ArmorDisplay.h"
#import "ItemDisplay.h"
#import "MH4UDBEngine.h"
#import <FMDB.h>


@interface MH4UDBEngine ()
@property (nonatomic) NSString *mhDBPath;
@property (nonatomic) FMDatabase *mh4DB;
@end

@implementation MH4UDBEngine

-(FMResultSet *)DBquery:(NSString *)query
{
    _mhDBPath = [[NSBundle mainBundle] pathForResource:@"mh4u" ofType:@".db"];
    _mh4DB = [FMDatabase databaseWithPath:_mhDBPath];
    
    if (![_mh4DB open]) {
        return nil;
    } else {
        FMResultSet *s = [_mh4DB executeQuery:query];
        return s;
    }
}


#pragma mark Monster Queries
-(NSArray *)populateAllMonsterArray {
    NSMutableArray *allMonsterArray = [[NSMutableArray alloc] init];
    
    NSString *monsterQuery = [NSString stringWithFormat:@"SELECT * FROM Monsters"];
    
    FMResultSet *s = [self DBquery:monsterQuery];
    while ([s next]) {
        Monster *monster = [[Monster alloc] init];
        monster.monsterID = [s intForColumn:@"_id"];
        monster.monsterClass = [s stringForColumn:@"class"];
        monster.monsterName = [s stringForColumn:@"name"];
        monster.trait = [s stringForColumn:@"trait"];
        monster.iconName = [s stringForColumn:@"icon_name"];
        [allMonsterArray addObject:monster];
    }
    
    [allMonsterArray sortUsingComparator:^NSComparisonResult(id monster1, id monster2){
        Monster *mon1 = (Monster *)monster1;
        Monster *mon2 = (Monster *)monster2;
        return [(NSString *) mon1.monsterName compare:mon2.monsterName options:NSNumericSearch];
    }];
    
    return allMonsterArray;
}


#pragma mark Armor Queries
-(NSArray *)populateArmorArray {
    NSMutableArray *armorArray = [[NSMutableArray alloc] init];
    
    NSString *armorQuery = [NSString stringWithFormat:@"SELECT armor._id, items.name, armor.hunter_type from armor INNER JOIN items on armor._id = items._id"];
    FMResultSet *s = [self DBquery:armorQuery];
    
    if (s) {
        while ([s next]) {
            Armor *armor = [[Armor alloc] init];
            armor.armorID = [s intForColumn:@"_id"];
            armor.name = [s stringForColumn:@"name"];
            armor.hunterType = [s stringForColumn:@"hunter_type"];
            [armorArray addObject:armor];
            //NSLog(@"Armor %@ populated", armor.name);
        }
    }
    
    return armorArray;
    
    
}

-(Armor *)populateArmor:(Armor *)armor {
    
    NSString *armorQuery = [NSString stringWithFormat:@"SELECT armor.slot, armor.defense, armor.max_defense, items.rarity, items.buy, armor.fire_res, armor.thunder_res, armor.dragon_res, armor.water_res, armor.ice_res, armor.gender, armor.num_slots from armor INNER JOIN items on armor._id = items._id WHERE armor._id = %i", armor.armorID];
    FMResultSet *s = [self DBquery:armorQuery];
    if ([s next]) {
        armor.slot = [s stringForColumn:@"slot"];
        armor.rarity = [s intForColumn:@"rarity"];
        armor.price = [s intForColumn:@"buy"];
        armor.defense = [s intForColumn:@"defense"];
        armor.maxDefense = [s intForColumn:@"max_defense"];
        armor.fireResistance = [s intForColumn:@"fire_res"];
        armor.thunderResistance = [s intForColumn:@"thunder_res"];
        armor.dragonResistance = [s intForColumn:@"dragon_res"];
        armor.waterResistance = [s intForColumn:@"water_res"];
        armor.iceResistance = [s intForColumn:@"ice_res"];
        armor.gender = [s stringForColumn:@"gender"];
        armor.numSlots = [s intForColumn:@"num_slots"];
        armor.skillsArray = [self getArmorSkillsfor:armor.armorID];
        armor.componentArray = [self getComponentsfor:armor.armorID];
    }

    return armor;

}

-(NSArray *)getArmorSkillsfor:(int)armorID{
    NSString *skillQuery = [NSString stringWithFormat:@"SELECT skill_trees._id, skill_trees.name, item_to_skill_tree.point_value FROM items INNER JOIN item_to_skill_tree on items._id = item_to_skill_tree.item_id INNER JOIN skill_trees on item_to_skill_tree.skill_tree_id = skill_trees._id where items._id = %i", armorID];
    
    NSMutableArray *skillTreeArray = [[NSMutableArray alloc] init];
    FMResultSet *s = [self DBquery:skillQuery];
    if (s) {
        while ([s next]) {
            int skillTreeID = [s intForColumn:@"_id"];
            NSString *skillName = [s stringForColumn:@"name"];
            int value = [s intForColumn:@"point_value"];
            [skillTreeArray addObject:@[[NSNumber numberWithInt:skillTreeID], skillName, [NSNumber numberWithInt:value]]];
        }
    } else {
        return nil;
    }
    
    return skillTreeArray;
}

-(NSArray *)getComponentsfor:(int)armorID {
    NSString *componentQuery = [NSString stringWithFormat:@"Select components.component_item_id, items.name from components Inner JOIN items on components.component_item_id = items._id where created_item_id = %i", armorID];
    NSMutableArray *componentsArray = [[NSMutableArray alloc] init];
    FMResultSet *s = [self DBquery:componentQuery];
    if (s) {
        while ([s next]) {
            int componentID = [s intForColumn:@"component_item_id"];
            NSString *name = [s stringForColumn:@"name"];
            [componentsArray addObject:@[[NSNumber numberWithInt:componentID], name]];
        }
    } else {
        return nil;
    }
    
    return componentsArray;
}

#pragma - Item Queries
-(NSArray *)populateItemArray {
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    NSString *itemQuery = [NSString stringWithFormat:@"SELECT * From items WHERE items.type NOT IN ('Armor','Weapon')"];
    FMResultSet *s = [self DBquery:itemQuery];
    while ([s next]) {
        Item *item = [[Item alloc] init];
        item.itemID = [s intForColumn:@"_id"];
        item.name = [s stringForColumn:@"name"];
        item.type = [s stringForColumn:@"type"];
        item.rarity = [s intForColumn:@"rarity"];
        item.capacity = [s intForColumn:@"carry_capacity"];
        item.price = [s intForColumn:@"buy"];
        item.salePrice = [s intForColumn:@"sell"];
        item.itemDescription = [s stringForColumn:@"description"];
        item.icon = [s stringForColumn:@"icon_name"];
        [itemsArray addObject:item];
    }
    
    return itemsArray;
}

-(void)getCombiningItemsForItem:(Item*)item
{
    NSMutableArray *combinedItemsArray = [[NSMutableArray alloc] init];
    NSString *combinedItemsQuery = [NSString stringWithFormat:@"SELECT * FROM combining where combining.created_item_id = %i OR combining.item_1_id = %i OR combining.item_2_id = %i", item.itemID, item.itemID, item.itemID];
    FMResultSet *s = [self DBquery:combinedItemsQuery];
    while ([s next]) {
        int createdID = [s intForColumn:@"created_item_id"];
        int item_1_id = [s intForColumn:@"item_1_id"];
        int item_2_id = [s intForColumn:@"item_2_id"];
        int minimumMade = [s intForColumn:@"amount_made_min"];
        int maximumMade = [s intForColumn:@"amount_made_max"];
        int percentage = [s intForColumn:@"percentage"];
        [combinedItemsArray addObject:@[[NSNumber numberWithInt:createdID],[NSNumber numberWithInt:item_1_id], [NSNumber numberWithInt:item_2_id], [NSNumber numberWithInt:minimumMade], [NSNumber numberWithInt:maximumMade], [NSNumber numberWithInt:percentage]]];
                           
    }
    
    item.combinedItemsArray = combinedItemsArray;
}

-(NSArray *)infoForCombinedTableCellItem:(NSNumber *)itemID
{
    NSString *itemPartQuery = [NSString stringWithFormat:@"SELECT name, icon_name FROM items where _id = %@", itemID];
    NSArray *info;
    FMResultSet *s = [self DBquery:itemPartQuery];
    if ([s next]) {
        NSString *name = [s stringForColumn:@"name"];
        NSString *icon = [s stringForColumn:@"icon_name"];
        info = @[name, icon];
    }
    
    return info;

}


@end

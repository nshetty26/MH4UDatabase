//
//  MH4UDBEngine.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/5/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MonsterDisplay.h"

#import "ItemsViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"
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


#pragma mark - Monster Queries
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

-(void)getDetailsForMonster:(Monster *)monster {
    [self getDamageForMonster:monster];
    [self getStatusEffectsForMonster:monster];
    [self getHabitatsForMonster:monster];
    [self getHuntingDropsForMonster:monster];
    [self getQuestsForMonster:monster];
}

-(void)getDamageForMonster:(Monster *)monster {
    NSMutableArray *monsterDamageArray = [[NSMutableArray alloc] init];
    NSString *monsterDamageQuery = [NSString stringWithFormat:@"select monsters.name, monster_damage.body_part, monster_damage.cut, monster_damage.impact, monster_damage.shot, monster_damage.fire, monster_damage.water, monster_damage.ice, monster_damage.thunder, monster_damage.dragon, monster_damage.ko from monster_damage inner join monsters on monster_damage.monster_id = monsters._id where monsters._id = %i order by monster_damage.body_part", monster.monsterID];
    
    FMResultSet *s = [self DBquery:monsterDamageQuery];
    while ([s next]) {
        MonsterDamage *md = [[MonsterDamage alloc] init];
        md.bodyPart = [s stringForColumn:@"body_part"];
        md.cutDamage = [s intForColumn:@"cut"];
        md.impactDamage = [s intForColumn:@"impact"];
        md.shotDamage = [s intForColumn:@"shot"];
        md.fireDamage = [s intForColumn:@"fire"];
        md.waterDamage = [s intForColumn:@"water"];
        md.iceDamage = [s intForColumn:@"ice"];
        md.thunderDamage = md.cutDamage = [s intForColumn:@"thunder"];
        md.dragonDamage = [s intForColumn:@"dragon"];
        md.stun = [s intForColumn:@"ko"];
        [monsterDamageArray addObject:md];
    }
    
    [monsterDamageArray sortUsingComparator:^NSComparisonResult(id damage1, id damage2){
        MonsterDamage *dam1 = (MonsterDamage *) damage1;
        MonsterDamage *dam2 = (MonsterDamage *) damage2;
        return [(NSString *) dam1.bodyPart compare:dam2.bodyPart options:NSNumericSearch];
    }];
    
    monster.monsterDetailDamage = monsterDamageArray;
}

-(void)getStatusEffectsForMonster:(Monster *)monster {
    NSMutableArray *monsterEffects = [[NSMutableArray alloc] init];
    NSString *statusQuery = [NSString stringWithFormat:@"SELECT status, initial, increase, max, duration, damage FROM monster_status where monster_status.monster_id = %i", monster.monsterID];
    
    FMResultSet *s = [self DBquery:statusQuery];
    while ([s next]) {
        MonsterStatusEffect *mse = [[MonsterStatusEffect alloc] init];
        mse.status  = [s stringForColumn:@"status"];
        mse.initial = [s intForColumn:@"initial"];
        mse.increase = [s intForColumn:@"increase"];
        mse.max = [s intForColumn:@"max"];
        mse.duration = [s intForColumn:@"duration"];
        mse.damage = [s intForColumn:@"damage"];
        [monsterEffects addObject:mse];
    }
    
    monster.monsterStatusEffects = monsterEffects;
}

-(void)getHabitatsForMonster:(Monster *)monster {
    NSMutableArray *habitatArray = [[NSMutableArray alloc] init];
    NSString *habitatQuery = [NSString stringWithFormat:@" SELECT monster_habitat.location_id, locations.name, locations.map, monster_habitat.start_area, monster_habitat.move_area, monster_habitat.rest_area From monster_habitat INNER JOIN locations on monster_habitat.location_id = locations._id WHERE monster_habitat.monster_id = %i", monster.monsterID];
    
    FMResultSet *s = [self DBquery:habitatQuery];
    while ([s next]) {
        MonsterHabitat *mh = [[MonsterHabitat alloc] init];
        mh.locationID = [s intForColumn:@"location_id"];
        mh.locationName = [s stringForColumn:@"name"];
        mh.icon = [s stringForColumn:@"map"];
        mh.initial = [s intForColumn:@"start_area"];
        NSString *moveArea = [s stringForColumn:@"move_area"];
        mh.movePath = [moveArea stringByReplacingOccurrencesOfString:@"\\" withString:@", "];
        mh.restArea = [s intForColumn:@"rest_area"];
        mh.fullPath = [NSString stringWithFormat:@"%i -> %@-> %i", mh.initial, mh.movePath, mh.restArea];
        [habitatArray addObject:mh];
    }
    monster.monsterHabitats = habitatArray;
}

-(void)getHuntingDropsForMonster:(Monster *)monster {
    NSArray *ranks = @[@"LR", @"HR", @"G"];
    
    for (NSString *rank in ranks) {
        NSMutableArray *itemDrops = [[NSMutableArray alloc] init];
        NSString *rankQuery = [NSString stringWithFormat:@"SELECT items._id as itemID, items.icon_name, items.rarity, items.buy, items.sell, items.description, items.carry_capacity, items.name, hunting_rewards.condition, hunting_rewards.rank, hunting_rewards.stack_size, hunting_rewards.percentage from hunting_rewards inner join items on items._id = hunting_rewards.item_id where hunting_rewards.monster_id = %i and hunting_rewards.rank = '%@'", monster.monsterID, rank];
        
        FMResultSet *s = [self DBquery:rankQuery];
        
        while ([s next]) {
            Item *huntingDrop = [[Item alloc] init];
            huntingDrop.itemID = [s intForColumn:@"itemID"];
            huntingDrop.icon = [s stringForColumn:@"icon_name"];
            huntingDrop.name = [s stringForColumn:@"name"];
            huntingDrop.condition = [s stringForColumn:@"condition"];
            huntingDrop.rarity = [s intForColumn:@"rarity"];
            huntingDrop.capacity = [s intForColumn:@"carry_capacity"];
            huntingDrop.price = [s intForColumn:@"buy"];
            huntingDrop.salePrice = [s intForColumn:@"sell"];
            huntingDrop.itemDescription = [s stringForColumn:@"description"];
            huntingDrop.capacity = [s intForColumn:@"stack_size"];
            huntingDrop.percentage = [s intForColumn:@"percentage"];
            [itemDrops addObject:huntingDrop];
        }
        
        if ([rank isEqual:@"LR"]) {
            monster.lowRankDrops = itemDrops;
        } else if ([rank isEqualToString:@"HR"]) {
            monster.highRankDrops = itemDrops;
        } else if ([rank isEqualToString:@"G"]) {
            monster.gRankDrops = itemDrops;
        }
    }

}

-(void)getQuestsForMonster:(Monster *)monster {
    NSMutableArray *questArray = [[NSMutableArray alloc] init];
    NSString *questQuery = [NSString stringWithFormat:@"select quests._id as qID, quests.name, quests.hub, quests.stars, monster_to_quest.unstable from monster_to_quest inner join quests on quests._id = monster_to_quest.quest_id where monster_to_quest.monster_id = %i", monster.monsterID];
    
    FMResultSet *s = [self DBquery:questQuery];
    
    while ([s next]) {
        Quest *quest = [[Quest alloc] init];
        quest.questID = [s intForColumn:@"qID"];
        quest.name = [s stringForColumn:@"name"];
        quest.stars = [s intForColumn:@"stars"];
        quest.hub = [s stringForColumn:@"hub"];
        quest.fullHub = [NSString stringWithFormat:@"%@ %i", quest.hub, quest.stars];
        quest.unstable = [s stringForColumn:@"unstable"];
        [questArray addObject:quest];
    }
    monster.questInfos = questArray;
}

#pragma mark - Armor Queries
-(NSArray *)populateArmorArray {
    NSMutableArray *armorArray = [[NSMutableArray alloc] init];
    
    NSString *armorQuery = [NSString stringWithFormat:@"SELECT armor._id, items.name,items.rarity, armor.hunter_type, armor.slot from armor INNER JOIN items on armor._id = items._id"];
    FMResultSet *s = [self DBquery:armorQuery];
    
    if (s) {
        while ([s next]) {
            Armor *armor = [[Armor alloc] init];
            armor.armorID = [s intForColumn:@"_id"];
            armor.name = [s stringForColumn:@"name"];
            armor.hunterType = [s stringForColumn:@"hunter_type"];
            armor.slot = [s stringForColumn:@"slot"];
            armor.rarity = [s intForColumn:@"rarity"];
            [armorArray addObject:armor];
            //NSLog(@"Armor %@ populated", armor.name);
        }
    }
    
    return armorArray;
    
    
}

-(Armor *)getArmor:(int)armorID {
    NSString *armorQuery = [NSString stringWithFormat:@"SELECT armor._id, items.name,items.rarity, armor.hunter_type, armor.slot from armor INNER JOIN items on armor._id = items._id where armor._id = %i", armorID];
    FMResultSet *s = [self DBquery:armorQuery];
    
    if (s) {
        while ([s next]) {
            Armor *armor = [[Armor alloc] init];
            armor.armorID = [s intForColumn:@"_id"];
            armor.name = [s stringForColumn:@"name"];
            armor.hunterType = [s stringForColumn:@"hunter_type"];
            armor.slot = [s stringForColumn:@"slot"];
            armor.rarity = [s intForColumn:@"rarity"];
            return armor;
        }
    }
    
    return nil;
}

-(Armor *)populateArmor:(Armor *)armor {
    
    NSString *armorQuery = [NSString stringWithFormat:@"SELECT armor.slot, armor.defense, armor.max_defense, items.rarity, items.buy, armor.fire_res, armor.thunder_res, armor.dragon_res, armor.water_res, armor.ice_res, armor.gender, armor.num_slots from armor INNER JOIN items on armor._id = items._id WHERE armor._id = %i", armor.armorID];
    FMResultSet *s = [self DBquery:armorQuery];
    if ([s next]) {
        //armor.rarity = [s intForColumn:@"rarity"];
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
    NSString *skillQuery = [NSString stringWithFormat:@"SELECT items._id as itemID, skill_trees._id, skill_trees.name, item_to_skill_tree.point_value FROM items INNER JOIN item_to_skill_tree on items._id = item_to_skill_tree.item_id INNER JOIN skill_trees on item_to_skill_tree.skill_tree_id = skill_trees._id where items._id = %i", armorID];
    
    NSMutableArray *skillTreeArray = [[NSMutableArray alloc] init];
    FMResultSet *s = [self DBquery:skillQuery];
    if (s) {
        while ([s next]) {
            int skillTreeID = [s intForColumn:@"_id"];
            NSString *skillName = [s stringForColumn:@"name"];
            int value = [s intForColumn:@"point_value"];
            int armorID = [s intForColumn:@"itemID"];
            [skillTreeArray addObject:@[[NSNumber numberWithInt:skillTreeID], skillName, [NSNumber numberWithInt:value], [NSNumber numberWithInt:armorID]]];
        }
    } else {
        return nil;
    }
    
    return skillTreeArray;
}

-(NSArray *)getComponentsfor:(int)armorID {
    NSString *componentQuery = [NSString stringWithFormat:@"Select components.component_item_id, items.name, items.icon_name, components.quantity from components Inner JOIN items on components.component_item_id = items._id where created_item_id = %i", armorID];
    NSMutableArray *componentsArray = [[NSMutableArray alloc] init];
    FMResultSet *s = [self DBquery:componentQuery];
    if (s) {
        while ([s next]) {
            int componentID = [s intForColumn:@"component_item_id"];
            NSString *name = [s stringForColumn:@"name"];
            NSString *iconName = [s stringForColumn:@"icon_name"];
            int quantity = [s intForColumn:@"quantity"];
            [componentsArray addObject:@[[NSNumber numberWithInt:componentID], name, iconName, [NSNumber numberWithInt:quantity]]];
        }
    } else {
        return nil;
    }
    
    return componentsArray;
}

#pragma mark - Item Queries
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

-(Item *)getItemForID:(int)itemID {
    NSString *itemQuery = [NSString stringWithFormat:@"SELECT _id, name, type, sub_type, rarity, carry_capacity, buy, sell, description, icon_name FROM items where _id = %i", itemID];
    Item *item = [[Item alloc] init];
    FMResultSet *s = [_mh4DB executeQuery:itemQuery];
    if ([s next]) {
        item.itemID = [s intForColumn:@"_id"];
        item.name = [s stringForColumn:@"name"];
        item.type = [s stringForColumn:@"type"];
        item.rarity = [s intForColumn:@"rarity"];
        item.capacity = [s intForColumn:@"carry_capacity"];
        item.price = [s intForColumn:@"buy"];
        item.salePrice = [s intForColumn:@"sell"];
        item.icon = [s stringForColumn:@"icon_name"];
        item.itemDescription = [s stringForColumn:@"description"];
        return item;
    } else {
        return nil;
    }
}

-(Item *)getItemForName:(NSString *)name {
    NSString *itemQuery = [NSString stringWithFormat:@"SELECT _id, name, type, sub_type, rarity, carry_capacity, buy, sell, description, icon_name FROM items where name LIKE '%@'", name];
    Item *item = [[Item alloc] init];
    FMResultSet *s = [_mh4DB executeQuery:itemQuery];
    if ([s next]) {
        item.itemID = [s intForColumn:@"_id"];
        item.name = [s stringForColumn:@"name"];
        item.type = [s stringForColumn:@"type"];
        item.rarity = [s intForColumn:@"rarity"];
        item.capacity = [s intForColumn:@"carry_capacity"];
        item.price = [s intForColumn:@"buy"];
        item.salePrice = [s intForColumn:@"sell"];
        item.icon = [s stringForColumn:@"icon_name"];
        item.itemDescription = [s stringForColumn:@"description"];
        return item;
    } else {
        return nil;
    }
}

-(NSArray *)getCombiningItems {
    NSMutableArray *combiningArray = [[NSMutableArray alloc] init];
    NSString *combiningQuery = @"SELECT created_item_id, item_1_id, item_2_id, amount_made_min, amount_made_max, percentage from combining";
    FMResultSet *s = [self DBquery:combiningQuery];
    if (s) {
        while ([s next]) {
            Combining *combiningCombo = [[Combining alloc] init];
            combiningCombo.combinedItem = [self getItemForID:[s intForColumn:@"created_item_id"]];
            combiningCombo.item1 = [self getItemForID:[s intForColumn:@"item_1_id"]];
            combiningCombo.item2 = [self getItemForID:[s intForColumn:@"item_2_id"]];
            combiningCombo.minMade = [s intForColumn:@"amount_made_min"];
            combiningCombo.maxMade = [s intForColumn:@"amount_made_max"];
            combiningCombo.percentage = [s intForColumn:@"percentage"];
            [combiningArray addObject:combiningCombo];
        }
    }
    
    return combiningArray;
}

-(void)getCombiningItemsForItem:(Item*)item
{
    NSMutableArray *combinedItemsArray = [[NSMutableArray alloc] init];
    NSString *combinedItemsQuery = [NSString stringWithFormat:@"SELECT * FROM combining where combining.created_item_id = %i OR combining.item_1_id = %i OR combining.item_2_id = %i", item.itemID, item.itemID, item.itemID];
    FMResultSet *s = [self DBquery:combinedItemsQuery];
    while ([s next]) {
        Combining *combiningCombo = [[Combining alloc] init];
        combiningCombo.combinedItem = [self getItemForID:[s intForColumn:@"created_item_id"]];
        combiningCombo.item1 = [self getItemForID:[s intForColumn:@"item_1_id"]];
        combiningCombo.item2 = [self getItemForID:[s intForColumn:@"item_2_id"]];
        combiningCombo.minMade = [s intForColumn:@"amount_made_min"];
        combiningCombo.maxMade = [s intForColumn:@"amount_made_max"];
        combiningCombo.percentage = [s intForColumn:@"percentage"];
        [combinedItemsArray addObject:combiningCombo];
                           
    }
    
    item.combinedItemsArray = combinedItemsArray;
}

-(NSArray *)infoForCombinedTableCellforItemID:(NSNumber *)itemID
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

-(void)getUsageItemsForItem:(Item*)item
{
    NSMutableArray *usageItemsArray = [[NSMutableArray alloc] init];
    NSString *usageQuery = [NSString stringWithFormat:@"select components.created_item_id, items.name, components.type, components.quantity, items.icon_name, items.type as iType, items.rarity, armor.slot,  weapons.wtype from components inner join items on items._id = components.created_item_id LEFT OUTER join armor on items._id = armor._id LEFT OUTER JOIN weapons on items._id = weapons._id where components.component_item_id = %i", item.itemID];;
    FMResultSet *s = [self DBquery:usageQuery];
    while ([s next]) {
        NSString *itemName = [s stringForColumn:@"name"];
        NSString *type =[s stringForColumn:@"type"];
        int quantity = [s intForColumn:@"quantity"];
        NSString *icon = [s stringForColumn:@"icon_name"];
        NSString *itemType = [s stringForColumn:@"iType"];
        NSString *armorSlot = [s stringForColumn:@"slot"];
        int rarity = [s intForColumn:@"rarity"];
        NSString *weaponType = [[s stringForColumn:@"wtype"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *armorImageString = [NSString stringWithFormat:@"%@%i.png",armorSlot, rarity];
        NSString *weaponImageString = [NSString stringWithFormat:@"%@%i.png",weaponType, rarity];
        int itemID = [s intForColumn:@"created_item_id"];
    
        [usageItemsArray addObject:@[itemName, type, [NSNumber numberWithInt:quantity], icon, itemType, armorImageString, weaponImageString, [NSNumber numberWithInt:itemID]]];
        
    }

    item.usageItemsArray = usageItemsArray;
}

-(void)getMonsterDropsForItem:(Item*)item
{
    NSMutableArray *monsterDropArray = [[NSMutableArray alloc] init];
    NSString *monsterQuery = [NSString stringWithFormat:@"SELECT items.name, condition, monsters.name as mName, monsters._id as mID, rank, stack_size, percentage, monsters.icon_name from hunting_rewards inner join monsters on monsters._id = hunting_rewards.monster_id inner join items on items._id = hunting_rewards.item_id where hunting_rewards.item_id = %i", item.itemID];;
    FMResultSet *s = [self DBquery:monsterQuery];
    while ([s next]) {
        NSString *monsterName = [s stringForColumn:@"mName"];
        NSString *rank = [s stringForColumn:@"rank"];
        NSString *condition = [s stringForColumn:@"condition"];
        int stackSize = [s intForColumn:@"stack_size"];
        int percentage = [s intForColumn:@"percentage"];
        NSString *icon = [s stringForColumn:@"icon_name"];
        int monsterID = [s intForColumn:@"mID"];
        
        [monsterDropArray addObject:@[monsterName, rank, condition, [NSNumber numberWithInt:stackSize],[NSNumber numberWithInt:percentage], icon, [NSNumber numberWithInt:monsterID]]];
        
    }
    
    item.monsterDropsArray = monsterDropArray;
}

-(void)getQuestRewardsForItem:(Item*)item
{
    NSMutableArray *questRewardArray = [[NSMutableArray alloc] init];
    NSString *questRewardQuery = [NSString stringWithFormat:@"select quests.name as qName, quests.hub, quests._id, quests.stars, items.name, reward_slot, percentage, stack_size from quest_rewards inner join quests on quest_rewards.quest_id = quests._id inner join items on quest_rewards.item_id = items._id where items._id = %i ORDER BY  percentage Desc", item.itemID];
    FMResultSet *s = [self DBquery:questRewardQuery];
    while ([s next]) {
        NSString *questName = [s stringForColumn:@"qName"];
        NSString *hub = [s stringForColumn:@"hub"];
        int stars = [s intForColumn:@"stars"];
        NSString *rewardSlot = [s stringForColumn:@"reward_slot"];
        int stackSize = [s intForColumn:@"stack_size"];
        int percentage = [s intForColumn:@"percentage"];
        int questID = [s intForColumn:@"_id"];
        
        
        [questRewardArray addObject:@[questName, hub, [NSNumber numberWithInt:stars],rewardSlot, [NSNumber numberWithInt:stackSize], [NSNumber numberWithInt:percentage], [NSNumber numberWithInt:questID]]];
        
    }
    
    item.questRewardsArray = questRewardArray;
}

-(void)getLocationsForItem:(Item*)item
{
    NSMutableArray *locationsArray = [[NSMutableArray alloc] init];
    NSString *locationsQuery = [NSString stringWithFormat:@"SELECT item_id, locations.name as lName, locations._id as lID, locations.map, area, site, rank, quantity, percentage from gathering INNER JOIN locations ON gathering.location_id = locations._id where gathering.item_id = %i order by percentage desc", item.itemID];
    FMResultSet *s = [self DBquery:locationsQuery];
    while ([s next]) {
        NSString *locationName = [s stringForColumn:@"lName"];
        NSString *rank = [s stringForColumn:@"rank"];
        NSString *area = [s stringForColumn:@"area"];
        NSString *site = [s stringForColumn:@"site"];
        int quantity = [s intForColumn:@"quantity"];
        int percentage = [s intForColumn:@"percentage"];
        int locationID = [s intForColumn:@"lID"];
        NSString *locationIcon = [s stringForColumn:@"map"];
        
        [locationsArray addObject:@[locationName, rank, area, site, [NSNumber numberWithInt:quantity], [NSNumber numberWithInt:percentage],[NSNumber numberWithInt:locationID], locationIcon]];
        
    }
    
    item.locationsArray = locationsArray;
}

-(NSArray *)infoForUsageTableCellforItemID:(NSNumber *)itemID
{
    NSString * usageQuery = [NSString stringWithFormat:@"select components.created_item_id, i2.name, i1.name, components.quantity, components.type from components inner join items as i1 on i1._id = components.component_item_id inner join items as i2 on i2._id = components.created_item_id where i1._id = %i", itemID.intValue];
    NSArray *usageInfo;
    
    FMResultSet *s = [self DBquery:usageQuery];
    if ([s next]) {
        int createdID = [s intForColumn:@"components.created_item_id"];
        NSString *name = [s stringForColumn:@"i2.name"];
        usageInfo = @[[NSNumber numberWithInt:createdID], name];
    }
    
    return usageInfo;
}

#pragma mark - Skill Queries

-(NSArray *)getSkillTrees {
    NSMutableArray *skillTrees = [[NSMutableArray alloc] init];
    NSString *skillTreeQuery = @"select * from skill_trees";
    
    FMResultSet *s = [self DBquery:skillTreeQuery];
    
    while ([s next]) {
        int skillTreeID = [s intForColumn:@"_id"];
        NSString *skillTreeName = [s stringForColumn:@"name"];
        [skillTrees addObject:@[[NSNumber numberWithInt:skillTreeID], skillTreeName]];
    }
    
    [skillTrees sortUsingComparator:^NSComparisonResult(id tree1, id tree2){
        NSArray *skillTree1 = (NSArray *)tree1;
        NSArray *skillTree2 = (NSArray *)tree2;
        NSString *skillTree1Name = skillTree1[1];
        NSString  *skillTree2Name = skillTree2[1];
        return [(NSString *) skillTree1Name compare:skillTree2Name options:NSNumericSearch];
    }];
    
    return skillTrees;
        
        
}

-(SkillCollection *)getSkillCollectionForSkillTreeID:(int)skillTreeID {
    NSMutableArray *skillsArray = [[NSMutableArray alloc] init];
    SkillCollection *skillCollection = [[SkillCollection alloc] init];
    NSString *skillsQuery = [NSString stringWithFormat:@"SELECT required_skill_tree_points, name, description from skills where skills.skill_tree_id = %i", skillTreeID];
    
    FMResultSet *s = [self DBquery:skillsQuery];

    while ([s next]) {
        int pointsNeeded = [s intForColumn:@"required_skill_tree_points"];
        NSString *name = [s stringForColumn:@"name"];
        NSString *skillDescription = [s stringForColumn:@"description"];
        [skillsArray addObject:@[[NSNumber numberWithInt:pointsNeeded], name, skillDescription]];
    }
    
    [skillsArray sortUsingComparator:^NSComparisonResult(id skill1, id skill2){
        NSArray *skillArray1 = (NSArray *)skill1;
        NSArray *skillArray2 = (NSArray *)skill2;
        NSNumber *pointsNeeded1 = skillArray1[0];
        NSNumber *pointsNeeded2 = skillArray2[0];
        return [(NSNumber *) pointsNeeded1 compare:pointsNeeded2];
    }];
    skillCollection.skillArray = skillsArray;
    [self getEquipmentForSkillCollection:skillCollection andSkillTreeID:skillTreeID];
    [self getDecorationsForSkillCollection:skillCollection andSkillTreeID:skillTreeID];
    return skillCollection;
}

-(void)getEquipmentForSkillCollection:(SkillCollection *)skillCollection andSkillTreeID:(int)skillTreeID{
    
    NSArray *equipmentParts = @[@"Head", @"Body", @"Arms", @"Waist", @"Legs"];
    for (NSString *part in equipmentParts) {
        NSString *equipmentQuery = [NSString stringWithFormat:@"SELECT items._id as itemID, items.name as itemName, items.rarity, armor.slot, skill_trees._id, skill_trees.name, item_to_skill_tree.point_value FROM items INNER JOIN item_to_skill_tree on items._id = item_to_skill_tree.item_id INNER JOIN skill_trees on item_to_skill_tree.skill_tree_id = skill_trees._id inner join armor on armor._id = items._id where skill_trees._id = %i and armor.slot = '%@'", skillTreeID, part];
        NSMutableArray *equipmentArray = [[NSMutableArray alloc] init];
        
        FMResultSet *s = [self DBquery:equipmentQuery];
        
        while ([s next]) {
            Armor *armor = [[Armor alloc] init];
            armor.armorID = [s intForColumn:@"itemID"];
            armor.name = [s stringForColumn:@"itemName"];
            armor.slot = [s stringForColumn:@"slot"];
            armor.rarity = [s intForColumn:@"rarity"];
            armor.skillsArray = @[[NSNumber numberWithInt:[s intForColumn:@"point_value"]]];
            [equipmentArray addObject:armor];
        }
        
        if ([part isEqualToString:@"Head"]) {
            skillCollection.headArray = equipmentArray;
        } else if ([part isEqualToString:@"Body"]) {
            skillCollection.bodyArray = equipmentArray;
        } else if ([part isEqualToString:@"Arms"]) {
            skillCollection.armArray = equipmentArray;
        } else if ([part isEqualToString:@"Waist"]) {
            skillCollection.waistArray = equipmentArray;
        } else if ([part isEqualToString:@"Legs"]) {
            skillCollection.legArray = equipmentArray;
        }
    }

}

-(void)getDecorationsForSkillCollection:(SkillCollection *)skillCollection andSkillTreeID:(int)skillTreeID{
    NSString *jewelQuery = [NSString stringWithFormat:@" SELECT items._id as itemID, items.name as itemName, items.icon_name, items.type, skill_trees._id, skill_trees.name, item_to_skill_tree.point_value FROM items INNER JOIN item_to_skill_tree on items._id = item_to_skill_tree.item_id INNER JOIN skill_trees on item_to_skill_tree.skill_tree_id = skill_trees._id where skill_trees._id = %i and type = 'Decoration'", skillTreeID];
    NSMutableArray *decorationArray = [[NSMutableArray alloc] init];
    FMResultSet *s = [self DBquery:jewelQuery];
    
    while ([s next]) {
        Decoration *decoration = [[Decoration alloc] init];
        decoration.itemID = [s intForColumn:@"itemID"];
        decoration.name = [s stringForColumn:@"itemName"];
        decoration.icon = [s stringForColumn:@"icon_name"];
        decoration.skillValue = [s intForColumn:@"point_value"];
        decoration.skillArray = [self getSkillTreesForDecorationID:decoration.itemID];
        [decorationArray addObject:decoration];
    }
    
    skillCollection.decorationArray = decorationArray;
    
}

-(NSArray *)getAllDecorations {
    NSString *decorationQuery = @"select items._id as itemID, items.rarity, items.buy, items.description, items.carry_capacity, items.sell, items.name, item_to_skill_tree._id,  items.icon_name from items inner join decorations on items._id = decorations._id inner join item_to_skill_tree on item_to_skill_tree.item_id = items._id";
    NSMutableArray *decorationArray = [[NSMutableArray alloc] init];
    
    FMResultSet *s = [self DBquery:decorationQuery];
    while ([s next]) {
        Decoration *decoration = [[Decoration alloc] init];
        decoration.itemID = [s intForColumn:@"itemID"];
        decoration.itemDescription = [s stringForColumn:@"description"];
        decoration.price = [s intForColumn:@"buy"];
        decoration.salePrice = [s intForColumn:@"sell"];
        decoration.rarity = [s intForColumn:@"rarity"];
        decoration.name = [s stringForColumn:@"name"];
        decoration.icon = [s stringForColumn:@"icon_name"];
        decoration.skillArray = [self getSkillTreesForDecorationID:decoration.itemID];
        [decorationArray addObject:decoration];
    }
    
    return decorationArray;
}

-(NSArray *)getSkillTreesForDecorationID:(int)decorationID {
    NSString *skillTreeQuery = [NSString stringWithFormat:@"SELECT skill_trees._id, skill_trees.name, item_to_skill_tree.point_value from item_to_skill_tree inner join skill_trees on skill_trees._id = item_to_skill_tree.skill_tree_id where item_to_skill_tree.item_id = %i", decorationID];
    NSMutableArray *skillsArray = [[NSMutableArray alloc] init];
    FMResultSet *s = [_mh4DB executeQuery:skillTreeQuery];
    while ([s next]) {
        int skillTreeID = [s intForColumn:@"_id"];
        NSString *skillTreeName = [s stringForColumn:@"name"];
        int pointValue = [s intForColumn:@"point_value"];
        [skillsArray addObject:@[[NSNumber numberWithInt:skillTreeID], skillTreeName, [NSNumber numberWithInt:pointValue]]];
    }
    
    return skillsArray;
}

#pragma mark - Quest Queries

-(NSArray *)getAllQuests {
    NSMutableArray *questArray = [[NSMutableArray alloc] init];
    NSString *questsQuery = @"select quests._id, quests.name, quests.hub, quests.type, quests.stars, locations.name as locationName from quests inner join locations on locations._id = quests.location_id";
    FMResultSet *s = [self DBquery:questsQuery];
    while ([s next]) {
        Quest *quest = [[Quest alloc] init];
        quest.questID = [s intForColumn:@"_id"];
        quest.name = [s stringForColumn:@"name"];
        quest.hub = [s stringForColumn:@"hub"];
        quest.type = [s stringForColumn:@"type"];
        quest.stars = [s intForColumn:@"stars"];
        quest.location = [s stringForColumn:@"locationName"];
        [questArray addObject:quest];
    }
    return questArray;
}



-(void)getQuestInfoforQuest:(Quest*)quest {
    NSString *questInfoQuery = [NSString stringWithFormat:@"select quests.hrp, quests.reward, quests.fee, quests.goal, quests.sub_goal, quests.sub_hrp, quests.sub_reward from quests inner join locations on locations._id = quests.location_id where quests._id = %i", quest.questID];
    FMResultSet *s = [self DBquery:questInfoQuery];
    if ([s next]) {
        quest.hrp = [s intForColumn:@"hrp"];
        quest.reward = [s intForColumn:@"reward"];
        quest.fee = [s intForColumn:@"fee"];
        quest.goal = [s stringForColumn:@"goal"];
        quest.subQuest = [s stringForColumn:@"sub_goal"];
        quest.subHRP = [s intForColumn:@"sub_hrp"];
        quest.subQuestReward = [s intForColumn:@"sub_reward"];
        quest.monsters = [self getMonstersForQuestID:quest.questID];
        quest.rewards = [self getRewardsForQuestID:quest.questID];
    }
}

-(NSArray *)getMonstersForQuestID:(int)questID {
    NSMutableArray *monsterArray = [[NSMutableArray alloc] init];
    NSString *monsterQuestQuery = [NSString stringWithFormat: @"select monsters._id, monsters.name, monsters.icon_name from monster_to_quest inner join quests on quests._id = monster_to_quest.quest_id inner join monsters on monsters._id = monster_to_quest.monster_id where quests._id = %i", questID];
    
    FMResultSet *s = [_mh4DB executeQuery:monsterQuestQuery];
    while ([s next]) {
        Monster *monster = [[Monster alloc] init];
        monster.monsterID = [s intForColumn:@"_id"];
        monster.monsterName = [s stringForColumn:@"name"];
        monster.iconName = [s stringForColumn:@"icon_name"];
        [monsterArray addObject:monster];
    }
    [monsterArray sortUsingComparator:^NSComparisonResult(id monster1, id monster2){
        Monster *mon1 = (Monster *)monster1;
        Monster *mon2 = (Monster *)monster2;
        return [(NSString *) mon1.monsterName compare:mon2.monsterName options:NSNumericSearch];
    }];

    return monsterArray;
}

-(NSArray *)getRewardsForQuestID:(int)questID {
    NSMutableArray *rewardArray = [[NSMutableArray alloc] init];
    NSString *questRewards = [NSString stringWithFormat:@"SELECT quest_rewards.item_id, items.name, items.icon_name, items.rarity, items.type, items.carry_capacity, items.buy, items.sell, items.description, quest_rewards.reward_slot, quest_rewards.percentage from quest_rewards inner join items on items._id = quest_rewards.item_id where quest_rewards.quest_id = %i order by percentage desc", questID];
    FMResultSet *s = [_mh4DB executeQuery:questRewards];
    while ([s next]) {
        Item *item = [[Item alloc] init];
        item.itemID = [s intForColumn:@"item_id"];
        item.name = [s stringForColumn:@"name"];
        item.type = [s stringForColumn:@"type"];
        item.rarity = [s intForColumn:@"rarity"];
        item.capacity = [s intForColumn:@"carry_capacity"];
        item.price = [s intForColumn:@"buy"];
        item.salePrice = [s intForColumn:@"sell"];
        item.itemDescription = [s stringForColumn:@"description"];
        item.icon = [s stringForColumn:@"icon_name"];
        item.percentage = [s intForColumn:@"percentage"];
        NSString *rewardType = [s stringForColumn:@"reward_slot"];
        if ([rewardType isEqualToString:@"A"]) {
            rewardType = @"Main Quest";
        } else {
            rewardType = @"Sub Quest";
        }
        [rewardArray addObject:@[rewardType, item]];
    }
    
    [rewardArray sortUsingComparator:^NSComparisonResult(id i1, id i2){
        NSArray *itemArray1 = (NSArray *)i1;
        NSArray *itemArray2 = (NSArray *)i2;
        Item *item1 = (Item *)itemArray1[1];
        Item *item2 = (Item *)itemArray2[1];
        if (item1.percentage < item2.percentage) {
            return 1;
        } else if (item1.percentage > item2.percentage) {
            return -1;
        } else {
            return 0;
        }
    }];

    
    return rewardArray;
}

#pragma mark - Location Queries
-(NSArray *)getAllLocations {
    NSMutableArray *locationArray = [[NSMutableArray alloc] init];
    NSString *locationQuery = @"SELECT _id, name, map as mapIcon from locations";
    FMResultSet *s = [self DBquery:locationQuery];
    while ([s next]) {
        Location *location = [[Location alloc] init];
        location.locationID = [s intForColumn:@"_id"];
        location.locationName = [s stringForColumn:@"name"];
        location.locationIcon = [s stringForColumn:@"mapIcon"];
        [locationArray addObject:location];
    }
    return locationArray;
}

-(void)monstersForLocationID:(Location *)location {
    NSString *monsterLocationQuery = [NSString stringWithFormat:@"SELECT monster_habitat.location_id,monsters._id as monsterID, monsters.name as monName, monsters.icon_name , monster_habitat.start_area, monster_habitat.move_area, monster_habitat.rest_area From monster_habitat INNER JOIN locations on monster_habitat.location_id = locations._id inner join monsters on monsters._id = monster_habitat.monster_id where monster_habitat.location_id = %i", location.locationID];
    NSMutableArray *monsterArray = [[NSMutableArray alloc] init];
    FMResultSet *s = [self DBquery:monsterLocationQuery];
    while ([s next]) {
        Monster *monster = [[Monster alloc] init];
        MonsterHabitat *mh = [[MonsterHabitat alloc] init];
        monster.monsterID = [s intForColumn:@"monsterID"];
        monster.monsterName = [s stringForColumn:@"monName"];
        monster.iconName = [s stringForColumn:@"icon_name"];

        mh.locationID = [s intForColumn:@"location_id"];
        mh.initial = [s intForColumn:@"start_area"];
        NSString *moveArea = [s stringForColumn:@"move_area"];
        mh.movePath = [moveArea stringByReplacingOccurrencesOfString:@"\\" withString:@", "];
        mh.restArea = [s intForColumn:@"rest_area"];
        mh.fullPath = [NSString stringWithFormat:@"%i -> %@-> %i", mh.initial, mh.movePath, mh.restArea];
        [monsterArray addObject:@[monster, mh]];
    }
    location.monsterArray = monsterArray;
}

-(void)itemsForLocationID:(Location *)location {
    NSArray *ranks = @[@"LR", @"HR", @"G"];
    
    for (NSString *rank in ranks) {
        NSMutableArray *itemDrops = [[NSMutableArray alloc] init];

        NSString *itemLocationQuery = [NSString stringWithFormat:@"SELECT gathering.item_id as itemID, items.name as itemName, items.type, items.rarity, items.carry_capacity, items.buy, items.sell, items.icon_name, locations.name as lName, area, site, rank, quantity, percentage from gathering INNER JOIN locations ON gathering.location_id = locations._id inner join items on gathering.item_id = items._id where gathering.location_id = %i AND gathering.rank = '%@' order by percentage desc", location.locationID, rank];
        FMResultSet *s = [_mh4DB executeQuery:itemLocationQuery];
        while ([s next]) {
            GatheredResource *gatheredResource = [[GatheredResource alloc] init];
            gatheredResource.locationName = [s stringForColumn:@"lName"];
            gatheredResource.rank = [s stringForColumn:@"rank"];
            gatheredResource.area = [s stringForColumn:@"area"];
            gatheredResource.site = [s stringForColumn:@"site"];
            gatheredResource.quantity = [s intForColumn:@"quantity"];
            gatheredResource.percentage = [s intForColumn:@"percentage"];
            gatheredResource.itemID = [s intForColumn:@"itemID"];
            gatheredResource.name = [s stringForColumn:@"itemName"];
            gatheredResource.icon = [s stringForColumn:@"icon_name"];
            [itemDrops addObject:gatheredResource];
        }
    
        if ([rank isEqual:@"LR"]) {
            location.lowRankItemsArray = itemDrops;
        } else if ([rank isEqualToString:@"HR"]) {
            location.highRankItemsArray = itemDrops;
        } else if ([rank isEqualToString:@"G"]) {
            location.gRankItemsArray = itemDrops;
        }
    }
}

-(NSArray *)getWeaponTypes {
    NSString *weaponTypeQuery = @"SELECT DISTINCT(wtype) as Weapon FROM weapons";
    NSMutableArray *weaponTypes = [[NSMutableArray alloc] init];
    
    FMResultSet *s = [self DBquery:weaponTypeQuery];
    while ([s next]) {
        NSString *weaponType = [s stringForColumn:@"Weapon"];
        [weaponTypes addObject:weaponType];
    }
    
    return weaponTypes;
}

-(NSArray *)getWeaponsForWeaponType:(NSString *)weaponType {
    NSMutableArray *weaponArray = [[NSMutableArray alloc] init];
    NSString *weaponQuery =  [NSString stringWithFormat:@"select weapons._id, weapons.wType, weapons.parent_id, items.name, items.rarity, weapons.wtype, weapons.attack, weapons.awaken, weapons.awaken_attack, weapons.element, weapons.element_attack, weapons.element_2, weapons.element_2_attack, weapons.num_slots, weapons.affinity, weapons.defense, weapons.sharpness, weapons.final, weapons.phial, weapons.horn_notes, weapons.reload_speed, weapons.recoil, weapons.deviation, weapons.tree_depth, weapons.creation_cost, weapons.upgrade_cost, weapons.charges, weapons.coatings from weapons inner join items on items._id = weapons._id where weapons.wtype = '%@'", weaponType];
    FMResultSet *s = [self DBquery:weaponQuery];
    while ([s next]) {
        Weapon *weapon = [[Weapon alloc] init];
        weapon.name = [s stringForColumn:@"name"];
        weapon.itemID = [s intForColumn:@"_id"];
        weapon.creationCost = [s intForColumn:@"creation_cost"];
        weapon.upgradeCost = [s intForColumn:@"upgrade_cost"];
        weapon.type = [s stringForColumn:@"wType"];
        weapon.parentID = [s intForColumn:@"parent_id"];
        weapon.rarity = [s intForColumn:@"rarity"];
        weapon.weaponType = [s stringForColumn:@"wtype"];
        weapon.attack = [s intForColumn:@"attack"];
        weapon.awaken_type = [s stringForColumn:@"awaken"];
        weapon.awakenDamage = [s intForColumn:@"awaken_attack"];
        weapon.elementalDamageType_1 = [s stringForColumn:@"element"];;
        weapon.elementalDamage_1 = [s intForColumn:@"element_attack"];;
        weapon.elementalDamageType_2 = [s stringForColumn:@"element_2"];;
        weapon.elementalDamage_2 = [s intForColumn:@"element_2_attack"];
        weapon.num_slots = [s intForColumn:@"num_slots"];
        weapon.affinity = [s intForColumn:@"affinity"];
        weapon.defense = [s intForColumn:@"defense"];
        weapon.sharpness = [s stringForColumn:@"sharpness"];
        weapon.phial = [s stringForColumn:@"phial"];
        weapon.hornNotes = [s stringForColumn:@"horn_notes"];
        weapon.tree_depth = [s intForColumn:@"tree_depth"];
        weapon.final = [s intForColumn:@"final"];
        weapon.recoil = [s stringForColumn:@"recoil"];
        weapon.reloadSpeed = [s stringForColumn:@"reload_speed"];
        weapon.deviation = [s stringForColumn:@"deviation"];
        weapon.charges = [s stringForColumn:@"charges"];
        weapon.coatings = [s stringForColumn:@"coatings"];
        [weaponArray addObject:weapon];
    }
    return weaponArray;
}

-(Weapon *)getWeaponForWeaponID:(int)weaponID {
    NSString *weaponQuery =  [NSString stringWithFormat:@"select weapons._id, weapons.wType, weapons.parent_id, items.name, items.rarity, weapons.wtype, weapons.attack, weapons.awaken, weapons.awaken_attack, weapons.element, weapons.element_attack, weapons.element_2, weapons.element_2_attack, weapons.num_slots, weapons.affinity, weapons.defense, weapons.sharpness, weapons.final, weapons.phial, weapons.horn_notes, weapons.reload_speed, weapons.recoil, weapons.deviation, weapons.tree_depth, weapons.creation_cost, weapons.upgrade_cost, weapons.charges, weapons.coatings from weapons inner join items on items._id = weapons._id where weapons._id = %i", weaponID];
    FMResultSet *s = [self DBquery:weaponQuery];
    while ([s next]) {
        Weapon *weapon = [[Weapon alloc] init];
        weapon.name = [s stringForColumn:@"name"];
        weapon.itemID = [s intForColumn:@"_id"];
        weapon.creationCost = [s intForColumn:@"creation_cost"];
        weapon.upgradeCost = [s intForColumn:@"upgrade_cost"];
        weapon.type = [s stringForColumn:@"wType"];
        weapon.parentID = [s intForColumn:@"parent_id"];
        weapon.rarity = [s intForColumn:@"rarity"];
        weapon.weaponType = [s stringForColumn:@"wtype"];
        weapon.attack = [s intForColumn:@"attack"];
        weapon.awaken_type = [s stringForColumn:@"awaken"];
        weapon.awakenDamage = [s intForColumn:@"awaken_attack"];
        weapon.elementalDamageType_1 = [s stringForColumn:@"element"];;
        weapon.elementalDamage_1 = [s intForColumn:@"element_attack"];;
        weapon.elementalDamageType_2 = [s stringForColumn:@"element_2"];;
        weapon.elementalDamage_2 = [s intForColumn:@"element_2_attack"];
        weapon.num_slots = [s intForColumn:@"num_slots"];
        weapon.affinity = [s intForColumn:@"affinity"];
        weapon.defense = [s intForColumn:@"defense"];
        weapon.sharpness = [s stringForColumn:@"sharpness"];
        weapon.phial = [s stringForColumn:@"phial"];
        weapon.hornNotes = [s stringForColumn:@"horn_notes"];
        weapon.tree_depth = [s intForColumn:@"tree_depth"];
        weapon.final = [s intForColumn:@"final"];
        weapon.recoil = [s stringForColumn:@"recoil"];
        weapon.reloadSpeed = [s stringForColumn:@"reload_speed"];
        weapon.deviation = [s stringForColumn:@"deviation"];
        weapon.charges = [s stringForColumn:@"charges"];
        weapon.coatings = [s stringForColumn:@"coatings"];
        return weapon;
    }
    return nil;
}

-(NSArray *)getHornSongsForHorn:(Weapon *)horn {
    NSMutableArray *hornMelodies = [[NSMutableArray alloc] init];
    NSString *hornQuery = [NSString stringWithFormat:@"SELECT horn_melodies.song, horn_melodies.effect1, horn_melodies.effect2, horn_melodies.duration, horn_melodies.extension from horn_melodies inner join weapons on weapons.horn_notes = horn_melodies.notes where weapons._id = %i", horn.itemID];
    
    FMResultSet *s = [self DBquery:hornQuery];
    
    while ([s next]) {
        NSString *song = [s stringForColumn:@"song"];
        NSString *effect1 = [s stringForColumn:@"effect1"];
        NSString *effect2 = [s stringForColumn:@"effect2"];
        int duration = [s intForColumn:@"duration"];
        int extension = [s intForColumn:@"extension"];
        [hornMelodies addObject:@[song, effect1, effect2, [NSNumber numberWithInt:duration], [NSNumber numberWithInt:extension]]];
    }
    
    return hornMelodies;
}

@end

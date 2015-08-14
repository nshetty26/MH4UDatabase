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
@property (nonatomic) NSString *asbDBPath;
@property (nonatomic) BOOL talismanCreated;
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
-(NSArray *)getMonsters:(NSNumber *)monsterID {
    NSMutableArray *allMonsterArray = [[NSMutableArray alloc] init];
    
    NSString *monsterQuery;
    
    if (!monsterID) {
        monsterQuery = [NSString stringWithFormat:@"SELECT * FROM Monsters"];
    } else {
        monsterQuery = [NSString stringWithFormat:@"SELECT * FROM Monsters where monsters._id = %@", monsterID];
    }
    
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

-(void)getDetailsForMonster:(Monster *)monster {
    [self getDamageForMonster:monster];
    [self getStatusEffectsForMonster:monster];
    [self getHabitatsForMonster:monster];
    [self getHuntingDropsForMonster:monster];
    [self getQuestsForMonster:monster];
}

#pragma mark - Armor Queries
-(NSArray *)getArmor:(NSNumber *)armorID {
    NSMutableArray *armorArray = [[NSMutableArray alloc] init];
    
    NSString *armorQuery;
    if (!armorID) {
        armorQuery = [NSString stringWithFormat:@"SELECT armor._id, items.name,items.rarity, armor.hunter_type, armor.slot from armor INNER JOIN items on armor._id = items._id"];
    } else {
        armorQuery = [NSString stringWithFormat:@"SELECT armor._id, items.name,items.rarity, armor.hunter_type, armor.num_slots, armor.slot from armor INNER JOIN items on armor._id = items._id where armor._id = %@", armorID];
    }

    FMResultSet *s = [self DBquery:armorQuery];
    
    if (s) {
        while ([s next]) {
            Armor *armor = [[Armor alloc] init];
            armor.itemID = [s intForColumn:@"_id"];
            armor.name = [s stringForColumn:@"name"];
            armor.hunterType = [s stringForColumn:@"hunter_type"];
            armor.slot = [s stringForColumn:@"slot"];
            if (armorID) {
                armor.numSlots = [s intForColumn:@"num_slots"];
            }
            
            armor.rarity = [s intForColumn:@"rarity"];
            armor.icon = [NSString stringWithFormat:@"%@%i.png", armor.slot, armor.rarity].lowercaseString;
            [armorArray addObject:armor];
        }
    }
    
    return armorArray;
    
    
}

-(Armor *)populateArmor:(Armor *)armor {
    
    NSString *armorQuery = [NSString stringWithFormat:@"SELECT armor.slot, armor.defense, armor.max_defense, items.rarity, items.buy, armor.fire_res, armor.thunder_res, armor.dragon_res, armor.water_res, armor.ice_res, armor.gender, armor.num_slots from armor INNER JOIN items on armor._id = items._id WHERE armor._id = %i", armor.itemID];
    FMResultSet *s = [self DBquery:armorQuery];
    if ([s next]) {
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
        armor.skillsArray = [self getArmorSkillsfor:armor.itemID];
        armor.componentArray = [self getComponentsfor:armor.itemID];
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
            NSString *skillTreeName = [s stringForColumn:@"name"];
            int pointValue = [s intForColumn:@"point_value"];
            [skillTreeArray addObject:@{@"skillTreeID" : [NSNumber numberWithInt:skillTreeID], @"skillTreeName" : skillTreeName, @"skillTreePointValue" : [NSNumber numberWithInt:pointValue]}];
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
            Item *item = [[Item alloc] init];
            item.name = name;
            item.icon = iconName;
            item.itemID = componentID;
            item.capacity = quantity;
            [componentsArray addObject:item];
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

-(void)getUsageItemsForItem:(Item*)item
{
    NSMutableArray *usageItemsArray = [[NSMutableArray alloc] init];
    NSString *usageQuery = [NSString stringWithFormat:@"select components.created_item_id, items.name, components.type, components.quantity, items.icon_name, items.type as iType, items.rarity, armor.slot,  weapons.wtype from components inner join items on items._id = components.created_item_id LEFT OUTER join armor on items._id = armor._id LEFT OUTER JOIN weapons on items._id = weapons._id where components.component_item_id = %i", item.itemID];;
    FMResultSet *s = [self DBquery:usageQuery];
    
    while ([s next]) {
        NSString *itemType = [s stringForColumn:@"iType"];
        Item *item = [[Item alloc] init];
        item.itemID = [s intForColumn:@"created_item_id"];
        item.name = [s stringForColumn:@"name"];
        item.capacity = [s intForColumn:@"quantity"];
        item.rarity = [s intForColumn:@"rarity"];
        item.type = [s stringForColumn:@"iType"];
        item.componentType = [s stringForColumn:@"type"];
        
        if ([itemType isEqualToString:@"Decoration"]) {
            Decoration *decoration = (Decoration *)item;
            decoration.itemID = [s intForColumn:@"created_item_id"];
            decoration.icon = [s stringForColumn:@"icon_name"];
            [usageItemsArray addObject:decoration];
        } else if ([itemType isEqualToString:@"Weapon"]) {
            Weapon *weapon = (Weapon *)item;
            NSString *weaponImage = [[s stringForColumn:@"wtype"]  stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            weapon.icon = [NSString stringWithFormat:@"%@%i.png",weaponImage, weapon.rarity].lowercaseString;
            [usageItemsArray addObject:weapon];

        } else if ([itemType isEqualToString:@"Armor"]) {
            Armor *armor = (Armor *)item;
            armor.icon = [NSString stringWithFormat:@"%@%i.png",[s stringForColumn:@"slot"], armor.rarity].lowercaseString;
            [usageItemsArray addObject:armor];
        }
        
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
        
        [monsterDropArray addObject:@{@"monsterName" : monsterName, @"rank": rank, @"condition" : condition, @"stackSize" : [NSNumber numberWithInt:stackSize], @"percentage" : [NSNumber numberWithInt:percentage], @"icon" : icon, @"monsterID" : [NSNumber numberWithInt:monsterID]}];
        
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
        
        
        [questRewardArray addObject:@{@"questName" : questName, @"hub" : hub, @"stars" : [NSNumber numberWithInt:stars], @"rewardSlot" : rewardSlot, @"stackSize" : [NSNumber numberWithInt:stackSize], @"percentage" : [NSNumber numberWithInt:percentage], @"questID" : [NSNumber numberWithInt:questID]}];
        
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
        
        [locationsArray addObject:@{@"locationName" : locationName, @"rank": rank, @"area": area, @"site": site, @"quantity" : [NSNumber numberWithInt:quantity], @"percentage" : [NSNumber numberWithInt:percentage], @"locationID" : [NSNumber numberWithInt:locationID], @"locationIcon" : locationIcon}];
        
    }
    
    item.locationsArray = locationsArray;
}

#pragma mark - Skill Queries

-(NSArray *)getSkillTrees {
    NSMutableArray *skillTrees = [[NSMutableArray alloc] init];
    NSString *skillTreeQuery = @"select * from skill_trees";
    
    FMResultSet *s = [self DBquery:skillTreeQuery];
    
    while ([s next]) {
        int skillTreeID = [s intForColumn:@"_id"];
        NSString *skillTreeName = [s stringForColumn:@"name"];
        [skillTrees addObject:@{@"skillTreeID" : [NSNumber numberWithInt:skillTreeID], @"skillTreeName" : skillTreeName}];
    }
    
    [skillTrees sortUsingComparator:^NSComparisonResult(id tree1, id tree2){
        NSDictionary *skillTree1 = (NSDictionary *)tree1;
        NSDictionary *skillTree2 = (NSDictionary *)tree2;
        NSString *skillTree1Name = [skillTree1 valueForKey:@"skillTreeName"];
        NSString  *skillTree2Name = [skillTree2 valueForKey:@"skillTreeName"];
        return [(NSString *) skillTree1Name compare:skillTree2Name options:NSNumericSearch];
    }];
    
    return skillTrees;
        
        
}

-(SkillTreeCollection *)getSkillCollectionForSkillTreeID:(int)skillTreeID {
    NSMutableArray *skillsArray = [[NSMutableArray alloc] init];
    SkillTreeCollection *skillCollection = [[SkillTreeCollection alloc] init];
    NSString *skillsQuery = [NSString stringWithFormat:@"SELECT required_skill_tree_points, name, description from skills where skills.skill_tree_id = %i", skillTreeID];
    
    FMResultSet *s = [self DBquery:skillsQuery];

    while ([s next]) {
        int pointsNeeded = [s intForColumn:@"required_skill_tree_points"];
        NSString *name = [s stringForColumn:@"name"];
        NSString *skillDescription = [s stringForColumn:@"description"];
        [skillsArray addObject:@{@"skillPointsNeeded" : [NSNumber numberWithInt:pointsNeeded], @"skillName" : name, @"skillDecription" :skillDescription}];
         }
    
    [skillsArray sortUsingComparator:^NSComparisonResult(id skill1, id skill2){
        NSDictionary *skillDict1 = (NSDictionary *)skill1;
        NSDictionary *skillDict2 = (NSDictionary *)skill2;
        NSNumber *pointsNeeded1 = [skillDict1 valueForKey:@"skillPointsNeeded"];
        NSNumber *pointsNeeded2 = [skillDict2 valueForKey:@"skillPointsNeeded"];
        return [(NSNumber *) pointsNeeded1 compare:pointsNeeded2];
    }];
    
    skillCollection.skillDescriptionArray = skillsArray;
    [self getEquipmentForSkillCollection:skillCollection andSkillTreeID:skillTreeID];
    [self getDecorationsForSkillCollection:skillCollection andSkillTreeID:skillTreeID];
    return skillCollection;
}

-(void)getEquipmentForSkillCollection:(SkillTreeCollection *)skillCollection andSkillTreeID:(int)skillTreeID{
    
    NSArray *equipmentParts = @[@"Head", @"Body", @"Arms", @"Waist", @"Legs"];
    for (NSString *part in equipmentParts) {
        NSString *equipmentQuery = [NSString stringWithFormat:@"SELECT items._id as itemID, items.name as itemName, items.rarity, armor.slot, skill_trees._id, skill_trees.name as skillTreeName, item_to_skill_tree.point_value FROM items INNER JOIN item_to_skill_tree on items._id = item_to_skill_tree.item_id INNER JOIN skill_trees on item_to_skill_tree.skill_tree_id = skill_trees._id inner join armor on armor._id = items._id where skill_trees._id = %i and armor.slot = '%@'", skillTreeID, part];
        NSMutableArray *equipmentArray = [[NSMutableArray alloc] init];
        
        FMResultSet *s = [self DBquery:equipmentQuery];
        
        while ([s next]) {
            Armor *armor = [[Armor alloc] init];
            armor.itemID = [s intForColumn:@"itemID"];
            armor.name = [s stringForColumn:@"itemName"];
            armor.slot = [s stringForColumn:@"slot"];
            armor.rarity = [s intForColumn:@"rarity"];
            armor.icon = [NSString stringWithFormat:@"%@%i.png",[s stringForColumn:@"slot"], armor.rarity].lowercaseString;
            armor.type = @"Armor";
            armor.skillsArray = @[@{@"skillTreeName" : [s stringForColumn:@"skillTreeName"], @"skillTreePointValue" : [NSNumber numberWithInt:[s intForColumn:@"point_value"]]}];
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

#pragma mark - Decoration Queries

-(void)getDecorationsForSkillCollection:(SkillTreeCollection *)skillCollection andSkillTreeID:(int)skillTreeID{
    NSString *jewelQuery = [NSString stringWithFormat:@" SELECT items._id as itemID, items.name as itemName, items.icon_name, items.type, skill_trees._id, skill_trees.name, item_to_skill_tree.point_value FROM items INNER JOIN item_to_skill_tree on items._id = item_to_skill_tree.item_id INNER JOIN skill_trees on item_to_skill_tree.skill_tree_id = skill_trees._id where skill_trees._id = %i and type = 'Decoration'", skillTreeID];
    NSMutableArray *decorationArray = [[NSMutableArray alloc] init];
    FMResultSet *s = [self DBquery:jewelQuery];
    
    while ([s next]) {
        Decoration *decoration = [[Decoration alloc] init];
        decoration.itemID = [s intForColumn:@"itemID"];
        decoration.type = @"Decoration";
        decoration.name = [s stringForColumn:@"itemName"];
        decoration.icon = [s stringForColumn:@"icon_name"];
        decoration.skillValue = [s intForColumn:@"point_value"];
        decoration.skillArray = [self getSkillTreesForDecorationID:decoration.itemID];
        [decorationArray addObject:decoration];
    }
    
    skillCollection.decorationArray = decorationArray;
    
}


/*
 
 select items._id as itemID, items.rarity, items.buy, items.description, items.carry_capacity, items.sell, items.name, item_to_skill_tree._id,  items.icon_name, skill_trees.name, item_to_skill_tree.point_value from items inner join decorations on items._id = decorations._id inner join item_to_skill_tree on item_to_skill_tree.item_id = items._id inner join skill_trees on skill_trees._id = item_to_skill_tree.skill_tree_id

 */
-(NSArray *)getAllDecorations:(NSNumber *)decorationID {
    NSString *decorationQuery;
    if (!decorationID) {
        decorationQuery = @"select items._id as itemID, items.rarity, items.buy, items.description, items.carry_capacity, items.sell, items.name, items.icon_name, decorations.num_slots from items inner join decorations on items._id = decorations._id ";
    } else {
        decorationQuery = [NSString stringWithFormat:@"select items._id as itemID, items.rarity, items.buy, items.description, items.carry_capacity, items.sell, items.name, items.icon_name, decorations.num_slots from items inner join decorations on items._id = decorations._id where items._id = %@", decorationID];
    }
   
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
        decoration.slotsRequired = [s intForColumn:@"num_slots"];
        //decoration.skillArray = [self getSkillTreesForDecorationID:decoration.itemID];
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
        [skillsArray addObject:@{@"skillTreeID" : [NSNumber numberWithInt:skillTreeID], @"skillTreeName" : skillTreeName, @"skillTreePointValue" : [NSNumber numberWithInt:pointValue]}];
    }
    
    return skillsArray;
}

#pragma mark - Quest Queries

-(NSArray *)getAllQuests:(NSNumber *)questID {
    NSMutableArray *questArray = [[NSMutableArray alloc] init];
    NSString *questQuery;
    if (!questID) {
        questQuery = @"select quests._id, quests.name, quests.hub, quests.type, quests.stars, locations.name as locationName from quests inner join locations on locations._id = quests.location_id where quests.name NOT LIKE ''";
    } else {
        questQuery = [NSString stringWithFormat:@"select quests._id, quests.name, quests.hub, quests.type, quests.stars, locations.name as locationName from quests inner join locations on locations._id = quests.location_id where quests.name NOT LIKE '' and quests._id = %i", [questID intValue]];
    }
    FMResultSet *s = [self DBquery:questQuery];
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
        item.condition = rewardType;
        [rewardArray addObject:item];
    }
    
    [rewardArray sortUsingComparator:^NSComparisonResult(id i1, id i2){
        Item *item1 = (Item *)i1;
        Item *item2 = (Item *)i2;
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
-(NSArray *)getAllLocations:(NSNumber *)locationID {
    NSMutableArray *locationArray = [[NSMutableArray alloc] init];
    NSString *locationQuery;
    if (!locationID) {
        locationQuery = @"SELECT _id, name, map as mapIcon from locations";
    } else {
        locationQuery = [NSString stringWithFormat:@"SELECT _id, name, map as mapIcon from locations where _id = %i", [locationID intValue]] ;
    }
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

-(void)getMonstersForLocation:(Location *)location {
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

-(void)getItemsForLocation:(Location *)location {
    NSArray *ranks = @[@"LR", @"HR", @"G"];
    
    for (NSString *rank in ranks) {
        NSMutableArray *itemDrops = [[NSMutableArray alloc] init];

        NSString *itemLocationQuery = [NSString stringWithFormat:@"SELECT gathering.item_id as itemID, items.name as itemName, items.type, items.rarity, items.carry_capacity, items.buy, items.sell, items.icon_name, locations.name as lName, area, site, rank, quantity, percentage from gathering INNER JOIN locations ON gathering.location_id = locations._id inner join items on gathering.item_id = items._id where gathering.location_id = %i AND gathering.rank = '%@' order by percentage desc", location.locationID, rank];
        FMResultSet *s = [_mh4DB executeQuery:itemLocationQuery];
        while ([s next]) {
            Item *gatheredResource = [[Item alloc] init];
            gatheredResource.locationName = [s stringForColumn:@"lName"];
            gatheredResource.rank = [s stringForColumn:@"rank"];
            gatheredResource.area = [s stringForColumn:@"area"];
            gatheredResource.site = [s stringForColumn:@"site"];
            gatheredResource.capacity = [s intForColumn:@"quantity"];
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

#pragma mark - Weapon Queries

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

-(NSArray *)getAllWyporiumTrades {
    NSMutableArray *wyporiumTrades = [[NSMutableArray alloc] init];
    
    NSString *wyporiumQuery = @"SELECT wyporium._id, i1._id as item1ID, i1.name,i2._id as item2ID, i2.name, quests._id as questID, quests.name FROM wyporium inner join items i1 on wyporium.item_in_id = i1._id inner join items i2 on wyporium.item_out_id = i2._id inner join quests on wyporium.unlock_quest_id = quests._id";
    
    FMResultSet *s = [self DBquery:wyporiumQuery];
    
    while ([s next]) {
        Item *itemOut = [self getItemForID:[s intForColumn:@"item1ID"]];
        Item *itemIn = [self getItemForID:[s intForColumn:@"item2ID"]];
        Quest *unlockQuest = [[self getAllQuests:[NSNumber numberWithInt:[s intForColumn:@"questID"]]] firstObject];
        [wyporiumTrades addObject:@[itemIn, itemOut, unlockQuest]];
    }
    
    return wyporiumTrades;
}

-(NSArray *)getWeaponsForWeaponType:(NSString *)weaponType {
    NSMutableArray *weaponArray = [[NSMutableArray alloc] init];
    NSString *weaponQuery =  [NSString stringWithFormat:@"select weapons._id, weapons.wType, weapons.parent_id, items.name, items.rarity, weapons.wtype, weapons.attack, weapons.awaken, weapons.awaken_attack, weapons.element, weapons.element_attack, weapons.element_2, weapons.element_2_attack, weapons.num_slots, weapons.affinity, weapons.defense, weapons.shelling_type, weapons.sharpness, weapons.final, weapons.phial, weapons.horn_notes, weapons.reload_speed, weapons.recoil, weapons.ammo, weapons.deviation, weapons.tree_depth, weapons.creation_cost, weapons.upgrade_cost, weapons.charges, weapons.coatings from weapons inner join items on items._id = weapons._id where weapons.wtype = '%@'", weaponType];
    FMResultSet *s = [self DBquery:weaponQuery];
    while ([s next]) {
        Weapon *weapon = [[Weapon alloc] init];
        weapon.name = [s stringForColumn:@"name"];
        weapon.itemID = [s intForColumn:@"_id"];
        weapon.slot = @"Weapon";
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
        weapon.numSlots = [s intForColumn:@"num_slots"];
        weapon.affinity = [s intForColumn:@"affinity"];
        weapon.defense = [s intForColumn:@"defense"];
        weapon.sharpness = [s stringForColumn:@"sharpness"];
        weapon.phial = [s stringForColumn:@"phial"];
        weapon.hornNotes = [s stringForColumn:@"horn_notes"];
        weapon.shellingType = [s stringForColumn:@"shelling_type"];
        weapon.tree_depth = [s intForColumn:@"tree_depth"];
        weapon.final = [s intForColumn:@"final"];
        weapon.recoil = [s stringForColumn:@"recoil"];
        weapon.ammo = [s stringForColumn:@"ammo"];
        weapon.reloadSpeed = [s stringForColumn:@"reload_speed"];
        weapon.deviation = [s stringForColumn:@"deviation"];
        weapon.charges = [s stringForColumn:@"charges"];
        weapon.coatings = [s stringForColumn:@"coatings"];
        NSString *weaponImage = [[s stringForColumn:@"wtype"]  stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        weapon.icon = [NSString stringWithFormat:@"%@%i.png",weaponImage, weapon.rarity].lowercaseString;
        [weaponArray addObject:weapon];
    }
    return weaponArray;
}

-(Weapon *)getWeaponForWeaponID:(int)weaponID {
    NSString *weaponQuery =  [NSString stringWithFormat:@"select weapons._id, weapons.wType, weapons.parent_id, items.name, items.rarity, weapons.wtype, weapons.attack, weapons.awaken, weapons.awaken_attack, weapons.element, weapons.element_attack, weapons.element_2, weapons.element_2_attack, weapons.num_slots, weapons.affinity, weapons.defense, weapons.sharpness, weapons.shelling_type, weapons.final, weapons.phial, weapons.horn_notes, weapons.reload_speed, weapons.recoil, weapons.ammo, weapons.deviation, weapons.tree_depth, weapons.creation_cost, weapons.upgrade_cost, weapons.charges, weapons.coatings from weapons inner join items on items._id = weapons._id where weapons._id = %i", weaponID];
    FMResultSet *s = [self DBquery:weaponQuery];
    while ([s next]) {
        Weapon *weapon = [[Weapon alloc] init];
        weapon.name = [s stringForColumn:@"name"];
        weapon.slot = @"Weapon";
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
        weapon.numSlots = [s intForColumn:@"num_slots"];
        weapon.affinity = [s intForColumn:@"affinity"];
        weapon.defense = [s intForColumn:@"defense"];
        weapon.sharpness = [s stringForColumn:@"sharpness"];
        weapon.shellingType = [s stringForColumn:@"shelling_type"];
        weapon.phial = [s stringForColumn:@"phial"];
        weapon.hornNotes = [s stringForColumn:@"horn_notes"];
        weapon.tree_depth = [s intForColumn:@"tree_depth"];
        weapon.final = [s intForColumn:@"final"];
        weapon.recoil = [s stringForColumn:@"recoil"];
        weapon.reloadSpeed = [s stringForColumn:@"reload_speed"];
        weapon.ammo = [s stringForColumn:@"ammo"];
        weapon.deviation = [s stringForColumn:@"deviation"];
        weapon.charges = [s stringForColumn:@"charges"];
        weapon.coatings = [s stringForColumn:@"coatings"];
        NSString *weaponImage = [[s stringForColumn:@"wtype"]  stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        weapon.icon = [NSString stringWithFormat:@"%@%i.png",weaponImage, weapon.rarity].lowercaseString;
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
        [hornMelodies addObject:@{@"song" : song, @"effect1" : effect1, @"effect2" : effect2, @"duration" : [NSNumber numberWithInt:duration], @"extension" : [NSNumber numberWithInt:extension]}];
    }
    
    return hornMelodies;
}

#pragma mark - Universal Search
-(NSArray *) populateResultsWithSearch:(NSString *)searchString {
    NSMutableArray *everythingArray = [[NSMutableArray alloc] init];
    
    FMResultSet *monsters = [self DBquery:
                     [NSString stringWithFormat:@"SELECT _id, name, icon_name FROM monsters"
                      " WHERE name LIKE '%%%@%%'", searchString]];
    
    FMResultSet *weapons = [self DBquery:
                    [NSString stringWithFormat:@"SELECT  weapons._id as weaponID, name, rarity, wtype FROM weapons"
                     " LEFT JOIN items on weapons._id = items._id"
                     " WHERE name LIKE '%%%@%%'", searchString]];
    
    FMResultSet *armor = [self DBquery:
                  [NSString stringWithFormat:@"SELECT armor._id as armorID, name, rarity, slot FROM armor"
                   " LEFT JOIN items on armor._id = items._id"
                   " WHERE name LIKE '%%%@%%'", searchString]];
    
    FMResultSet *quests = [self DBquery:
                   [NSString stringWithFormat:@"SELECT _id, name, hub, type, stars FROM quests"
                    " WHERE name LIKE '%%%@%%'", searchString]];
    
    FMResultSet *items = [self DBquery:
                  [NSString stringWithFormat:@"SELECT _id, name, icon_name, type FROM items"
                   " WHERE sub_type == '' AND name LIKE '%%%@%%'", searchString]];
    
    FMResultSet *locations = [self DBquery:
                      [NSString stringWithFormat:@"SELECT _id, name, map as mapIcon FROM locations"
                       " WHERE name LIKE '%%%@%%'", searchString]];
    
    FMResultSet *skillSets = [self DBquery:
                              [NSString stringWithFormat:@"SELECT * FROM skill_trees"
                               " WHERE name LIKE '%%%@%%'", searchString]];

    
    while ([monsters next]) {
        NSNumber *monsterID = [NSNumber numberWithInt:[monsters intForColumn:@"_id"]];
        NSString *type = @"Monster";
        NSString *name = [monsters stringForColumn:@"name"];
        NSString *icon = [monsters stringForColumn:@"icon_name"];
        [everythingArray addObject:@[monsterID, type, name, icon]];
    }
    
    while ([weapons next]) {
        NSNumber *weaponID = [NSNumber numberWithInt:[weapons intForColumn:@"weaponID"]];
        NSString *type = @"Weapon";
        NSString *name = [weapons stringForColumn:@"name"];
        NSString *imageString = [[weapons stringForColumn:@"wtype"]  stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *icon = [NSString stringWithFormat:@"%@%i.png",imageString, [weapons intForColumn:@"rarity"]].lowercaseString;
        [everythingArray addObject:@[weaponID, type, name, icon]];
    }
    
    while ([armor next]) {
        NSNumber *armorID = [NSNumber numberWithInt:[armor intForColumn:@"armorID"]];
        NSString *type = @"Armor";
        NSString *name = [armor stringForColumn:@"name"];
        NSString *icon = [NSString stringWithFormat:@"%@%i.png",[armor stringForColumn:@"slot"], [armor intForColumn:@"rarity"]].lowercaseString;
        [everythingArray addObject:@[armorID, type, name, icon]];
    }
    
    while ([quests next]) {
        NSNumber *questID = [NSNumber numberWithInt:[quests intForColumn:@"_id"]];
        NSString *type = @"Quest";
        NSString *name = [quests stringForColumn:@"name"];
        NSString *questType = [NSString stringWithFormat:@"%@ %i",[quests stringForColumn:@"hub"], [quests intForColumn:@"stars"]];
        [everythingArray addObject:@[questID, type, name, questType]];
    }
    
    while ([items next]) {
        NSNumber *itemID = [NSNumber numberWithInt:[items intForColumn:@"_id"]];
        NSString *type = [items stringForColumn:@"type"];
        NSString *name = [items stringForColumn:@"name"];
        NSString *icon = [items stringForColumn:@"icon_name"];
        [everythingArray addObject:@[itemID, type, name, icon]];
    }
    
    while ([locations next]) {
        NSNumber *locationID = [NSNumber numberWithInt:[locations intForColumn:@"_id"]];
        NSString *type = @"Location";
        NSString *name = [locations stringForColumn:@"name"];
        NSString *icon = [locations stringForColumn:@"mapIcon"];
        [everythingArray addObject:@[locationID, type, name, icon]];
    }
    
    while ([skillSets next]) {
        NSNumber *skillID = [NSNumber numberWithInt:[skillSets intForColumn:@"_id"]];
        NSString *type = @"Skill Tree";
        NSString *name = [skillSets stringForColumn:@"name"];
        [everythingArray addObject:@[skillID, type, name, type]];
    }
    
    return everythingArray;
}

#pragma mark - Armor Set Builder Queries
#pragma mark Pulling / Adding / Deleting The Whole Armor Set
-(NSArray *)getAllArmorSets {
    NSMutableArray *allSets = [[NSMutableArray alloc] init];
    [self checkTalismanTable];
    //FMDatabase *armorDatabase = [self openDatabase];
    [self openDatabase];
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:_asbDBPath];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *query = @"SELECT * from ArmorSet";
        FMResultSet *s = [db executeQuery:query];
        while ([s next]) {
            NSNumber *setID = [NSNumber numberWithInt:[s intForColumn:@"_id"]];
            NSString *setName = [s stringForColumn:@"name"];
            [allSets addObject:@{@"setID" : setID, @"setName" : setName}];
        }
    }];
        
        return allSets;
    
//    if (![armorDatabase open]) {
//        return nil;
//    } else {
//        NSString *query = @"SELECT * from ArmorSet";
//        FMResultSet *s = [armorDatabase executeQuery:query];
//        while ([s next]) {
//            NSNumber *setID = [NSNumber numberWithInt:[s intForColumn:@"_id"]];
//            NSString *setName = [s stringForColumn:@"name"];
//            [allSets addObject:@{@"setID" : setID, @"setName" : setName}];
//            
//        }
//        return allSets;
//    }
}

-(ArmorSet *)getArmorSetForSetID:(NSNumber *)setID {
    ArmorSet *armorSet = [[ArmorSet alloc] init];
    //FMDatabase *armorDatabase = [self openDatabase];
    
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:_asbDBPath];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *query = [NSString stringWithFormat:@"SELECT * from ArmorSet where _id = %i", [setID intValue]];
        FMResultSet *s = [db executeQuery:query];
        if ([s next]) {
            if (![s columnIsNull:@"weapon_id"]) {
                armorSet.weapon = [self getWeaponForWeaponID:[s intForColumn:@"weapon_id"]];
            }
            if (![s columnIsNull:@"head_id"]) {
                armorSet.helm = [[self getArmor:[NSNumber numberWithInt:[s intForColumn:@"head_id"]]] firstObject];
            }
            if (![s columnIsNull:@"body_id"]) {
                armorSet.chest = [[self getArmor:[NSNumber numberWithInt:[s intForColumn:@"body_id"]]] firstObject];
            }
            if (![s columnIsNull:@"arms_id"]) {
                armorSet.arms = [[self getArmor:[NSNumber numberWithInt:[s intForColumn:@"arms_id"]]] firstObject];
            }
            if (![s columnIsNull:@"waist_id"]) {
                armorSet.waist = [[self getArmor:[NSNumber numberWithInt:[s intForColumn:@"waist_id"]]] firstObject];
            }
            if (![s columnIsNull:@"legs_id"]) {
                armorSet.legs = [[self getArmor:[NSNumber numberWithInt:[s intForColumn:@"legs_id"]]] firstObject];
            }
            if (![s columnIsNull:@"talisman_id"]) {
                armorSet.talisman = [self getTalismanForID:[s intForColumn:@"talisman_id"]];
            }
            
            [s close];
            
        }
    }];
    
    return armorSet;
}

-(BOOL)insertNewArmorSetWithName:(NSString *)name {
    FMDatabase *armorDatabase = [self openDatabase];
    
    if (![armorDatabase open]) {
        return FALSE;
    } else {
        NSString *query = [NSString stringWithFormat:@"insert into ArmorSet (name) Values ('%@')", name];
        return [armorDatabase executeUpdate:query];
    }
}

-(BOOL)deleteArmorSetWithID:(NSNumber *)setID {
    FMDatabase *armorDatabase = [self openDatabase];
    
    if (![armorDatabase open]) {
        return FALSE;
    } else {
        NSString *query = [NSString stringWithFormat:@"delete from ArmorSet where _id = %i", [setID intValue]];
        return [armorDatabase executeUpdate:query];
    }
}

-(BOOL)cloneArmorSet:(ArmorSet *)armorSet withName:(NSString *)name{
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];;
    FMDatabase *armorDatabase = [self openDatabase];
    if (armorSet.weapon) {
        [columns addObject:[self returnDBTypeForArmorSlot:@"Weapon"]];
        [values addObject:[NSNumber numberWithInt:armorSet.weapon.itemID]];
    }
    
    for (Armor *armor in [armorSet returnNonNullSetItems]) {
        [columns addObject:[self returnDBTypeForArmorSlot:armor.slot]];
        [values addObject:[NSNumber numberWithInt:armor.itemID]];
    }
    
    if (![armorDatabase open]) {
        return FALSE;
    } else {
        NSString *columnString;
        NSString *valuesString;
        
        if (columns.count > 0) {
            columnString = [self returnProperQueryStringForCompnents:columns];
        } else {
            columnString = @"";
        }
        
        if (values.count > 0) {
            valuesString = [self returnProperQueryStringForCompnents:values];
        } else {
            valuesString = @"";
        }
        
        NSString *query = [NSString stringWithFormat:@"insert into ArmorSet (name%@) Values ('%@'%@)",columnString, name, valuesString];
        return [armorDatabase executeUpdate:query];
    }
    
}

#pragma mark Pulling / Checking / Deleting Individual Set Items
-(BOOL)checkSetItem:(Item *)setItem atArmorSetWithID:(NSNumber *)setID {
    FMDatabase *armorDatabase = [self openDatabase];
    
    NSString *armorType;
    
    if ([setItem.slot isEqualToString:@"Head"]) {
        armorType = @"head_id";
    } else if ([setItem.slot isEqualToString:@"Body"]) {
        armorType = @"body_id";
    } else if ([setItem.slot isEqualToString:@"Arms"]) {
        armorType = @"arms_id";
    } else if ([setItem.slot isEqualToString:@"Waist"]) {
        armorType = @"waist_id";
    } else if ([setItem.slot isEqualToString:@"Legs"]) {
        armorType = @"legs_id";
    } else if ([setItem.slot isEqualToString:@"Weapon"]) {
        armorType = @"weapon_id";
    } else if ([setItem.slot isEqualToString:@"Talisman"]) {
        armorType = @"talisman_id";
    } else {
        armorType = @"";
    }
    
    if (![armorDatabase open]) {
        return FALSE;
    } else {
        NSString *query = [NSString stringWithFormat:@"select %@ from ArmorSet where _id = %i", armorType, [setID intValue]];
        FMResultSet *s = [armorDatabase executeQuery:query];
        
        while ([s next]) {
            if ([s columnIsNull:armorType]) {
                [armorDatabase close]; //required so when we do the insert the DB isnt locked up
                return FALSE;
                
            } else {
                [armorDatabase close];
                return TRUE;
            }
        }
    }
    
    [armorDatabase close];
    return FALSE;
}



-(BOOL)addSetItem:(Item *)setItem toArmorSetWithID:(NSNumber *)setID {
    FMDatabase *armorDatabase = [self openDatabase];
    
    NSString *armorType = [self returnDBTypeForArmorSlot:setItem.slot];
    
    if (![armorDatabase open]) {
        return FALSE;
    } else {
        NSString *query = [NSString stringWithFormat:@"UPDATE ArmorSet SET %@ = '%i' where _id = %i", armorType, setItem.itemID, [setID intValue]];
        return [armorDatabase executeUpdate:query];
    }

}

#pragma mark Pulling / Adding / Deleting Decorations from Set Items
-(NSArray *)checkArmorSetForSlotsWithSetID:(NSNumber *)setID {
    NSMutableArray *availableSlotsInEquipment = [[NSMutableArray alloc] init];
    
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:_asbDBPath];
    
    ArmorSet *armorSet = [self getArmorSetForSetID:setID];
    
    [queue inDatabase:^(FMDatabase *db) {
        for (Item *setItem in [armorSet returnNonNullSetItems]) {
            if (setItem.numSlots > 0) {
                NSString *query = [NSString stringWithFormat:@"select * from Decorations where ArmorSet_id = %i and item_id = %i" , [setID intValue], setItem.itemID];
                FMResultSet *s = [db executeQuery:query];
                int slotsUsed = 0;
                while ([s next]) {
                    Decoration *decoration = [[self getAllDecorations:[NSNumber numberWithInt:[s intForColumn:@"decoration_id"]]] firstObject];
                    slotsUsed += decoration.slotsRequired;
                        
                    }
                setItem.slotsUsed = slotsUsed;
                    
                }
            int availableSlots = setItem.numSlots - setItem.slotsUsed;
            [availableSlotsInEquipment addObject:@[setItem.slot, [NSNumber numberWithInt:availableSlots], [NSNumber numberWithInt:setItem.numSlots]]];
            }
    }];
    
    return availableSlotsInEquipment;

}

-(BOOL)addDecoration:(Decoration *)decoration ToSlot:(NSString *)slot andArmorSetWithID:(NSNumber *)setID {
    ArmorSet *armorSet = [self getArmorSetForSetID:setID];
    
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:_asbDBPath];
    __block BOOL successful = false;
    
    [queue inDatabase:^(FMDatabase *db) {
        Item *setItem;
            if ([slot isEqualToString:@"Talisman"]) {
                setItem = armorSet.talisman;
            } else {
               setItem = [armorSet returnItemForSlot:slot];
            }
        
            NSString *query = [NSString stringWithFormat:@"insert into Decorations (ArmorSet_id, item_id, decoration_id) Values (%i, %i, %i)", [setID intValue], setItem.itemID, decoration.itemID];
           successful = [db executeUpdate:query];
    }];
    
    return successful;

}
    
    
//    FMDatabase *armorDatabase = [self openDatabase];
//    
//    Item *setItem;
//    if ([slot isEqualToString:@"Talisman"]) {
//        setItem = armorSet.talisman;
//    } else {
//       setItem = [armorSet returnItemForSlot:slot];
//    }
//    
//    
//    if (![armorDatabase open]) {
//        return FALSE;
//    } else {
//         NSString *query = [NSString stringWithFormat:@"insert into Decorations (ArmorSet_id, item_id, decoration_id) Values (%i, %i, %i)", [setID intValue], setItem.itemID, decoration.itemID];
//        return [armorDatabase executeUpdate:query];
//    }
//
//    return FALSE;
//}

-(NSArray *)getDecorationsForArmorSet:(NSNumber *)setID andSetItem:(Item *)setItem {
    NSMutableArray *decorations = [[NSMutableArray alloc] init];
    
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:_asbDBPath];
    //__block BOOL successful = false;
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *query = [NSString stringWithFormat:@"select _id, ArmorSet_id, item_id, decoration_id from Decorations where ArmorSet_id = %i and item_id = %i" , [setID intValue], setItem.itemID];
        FMResultSet *s = [db executeQuery:query];
        while ([s next]) {
            int decorationID = [s intForColumn:@"decoration_id"];
            Decoration *decoration = [[self getAllDecorations:[NSNumber numberWithInt:decorationID]]  firstObject];
            decoration.skillArray = [self getSkillTreesForDecorationID:decoration.itemID];
            [decorations addObject:decoration];
        }

    }];
    
//    FMDatabase *armorDatabase = [self openDatabase];
//    if (![armorDatabase open]) {
//        return FALSE;
//    } else {
//        NSString *query = [NSString stringWithFormat:@"select _id, ArmorSet_id, item_id, decoration_id from Decorations where ArmorSet_id = %i and item_id = %i" , [setID intValue], setItem.itemID];
//        FMResultSet *s = [armorDatabase executeQuery:query];
//        while ([s next]) {
//            int decorationID = [s intForColumn:@"decoration_id"];
//            Decoration *decoration = [[self getAllDecorations:[NSNumber numberWithInt:decorationID]]  firstObject];
//            [decorations addObject:decoration];
//        }
//        
//    }
    
    return decorations;

}

-(BOOL)deleteDecoration:(Decoration *)decoration FromSetItemWithItemID:(Item *)setItem SetWithID:(NSNumber *)setID {
    FMDatabase *armorDatabase = [self openDatabase];
    
    if (![armorDatabase open]) {
        return FALSE;
    } else {
        NSString *query = [NSString stringWithFormat:@"delete from Decorations where ArmorSet_id = %i and item_id = %i and decoration_id = %i", [setID intValue], setItem.itemID , decoration.itemID];
        return [armorDatabase executeUpdate:query];
    }
}

-(BOOL)deleteAllDecorationsForArmorSetWithID:(NSNumber *)setID andSetItem:(Item *)setItem {
    FMDatabase *armorDatabase = [self openDatabase];
    
    if (![armorDatabase open]) {
        return FALSE;
    } else {
        NSString *query = [NSString stringWithFormat:@"DELETE FROM Decorations where ArmorSet_id = %i and item_id = %i", [setID intValue], setItem.itemID];
        return [armorDatabase executeUpdate:query];
    }
}

#pragma mark - Talisman Queries

-(BOOL)insertNewTalismanIntoDatabase:(Talisman *)newTalisman {
    FMDatabase *armorDatabase = [self openDatabase];
    
    if (![armorDatabase open]) {
        return false;
    } else {
        NSString *query = [NSString stringWithFormat:@"INSERT INTO CHARMS (num_slots,talisman_name, talisman_type, skill_tree_1_id, skill_tree_1_amount, skill_tree_2_id, skill_tree_2_amount) values (%i, '%@', '%@', %i, %i, %i, %i)", newTalisman.numSlots, newTalisman.name, newTalisman.talismanType, newTalisman.skill1ID, newTalisman.skill1Value, newTalisman.skill2ID, newTalisman.skill2Value];
        return [armorDatabase executeUpdate:query];
    }
}

-(BOOL)addTalisman:(Talisman *)newTalisman toArmorSet:(ArmorSet *)set {
    FMDatabase *armorDatabase = [self openDatabase];
    
    if (![armorDatabase open]) {
        return false;
    } else {
        NSString *query = [NSString stringWithFormat:@"UPDATE ArmorSet SET %@ = '%i' where _id = %i", @"talisman_id", newTalisman.itemID, set.setID];
        return [armorDatabase executeUpdate:query];
    }

}

-(NSArray *)getAllTalismans {
    FMDatabase *armorDatabase = [self openDatabase];
    NSMutableArray *talismanArray = [[NSMutableArray alloc] init];
    if (![armorDatabase open]) {
        return NULL;
    } else {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM charms"];
        FMResultSet *s = [armorDatabase executeQuery:query];
        
        while ([s next]) {
            Talisman *talisman = [[Talisman alloc] init];
            talisman.itemID = [s intForColumn:@"_id"];
            talisman.numSlots = [s intForColumn:@"num_slots"];
            talisman.name = [s stringForColumn:@"talisman_name"];
            talisman.talismanType = [s stringForColumn:@"talisman_type"];
            talisman.skill1ID = [s intForColumn:@"skill_tree_1_id"];
            talisman.skill1Value = [s intForColumn:@"skill_tree_1_amount"];
            talisman.skill2ID = [s intForColumn:@"skill_tree_2_id"];
            talisman.skill2Value = [s intForColumn:@"skill_tree_2_amount"];
            talisman.slot = @"Talisman";
            
            NSMutableArray *skillArray = [[NSMutableArray alloc] init];
            
            if (talisman.skill1ID != 0) {
                FMResultSet *s = [self DBquery:[NSString stringWithFormat:@"select name from skill_trees where _id = %i", talisman.skill1ID]];
                if ([s next]){
                    talisman.skill1Name = [s stringForColumn:@"name"];
                    [skillArray addObject:@{@"skillTreeID" : [NSNumber numberWithInt:talisman.skill1ID], @"skillTreeName" : talisman.skill1Name, @"skillTreePointValue" : [NSNumber numberWithInt:talisman.skill1Value]}];
                }
                
            }
            
            if (talisman.skill2ID != 0) {
                FMResultSet *s = [self DBquery:[NSString stringWithFormat:@"select name from skill_trees where _id = %i", talisman.skill2ID]];
                if ([s next]){
                    talisman.skill2Name = [s stringForColumn:@"name"];
                    [skillArray addObject:@{@"skillTreeID" : [NSNumber numberWithInt:talisman.skill2ID], @"skillTreeName" : talisman.skill2Name, @"skillTreePointValue" : [NSNumber numberWithInt:talisman.skill2Value]}];
                }
                
            }
            talisman.skillsArray = skillArray;
            [talismanArray addObject:talisman];
        }
    }
    return talismanArray;
}


-(Talisman *)getTalismanForID:(int)talismanID {
    //FMDatabase *armorDatabase = [self openDatabase];
    
    FMDatabaseQueue *queue = [[FMDatabaseQueue alloc] initWithPath:_asbDBPath];
    Talisman *talisman = [[Talisman alloc] init];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM charms where _id = %i", talismanID];
        FMResultSet *s = [db executeQuery:query];
        
        if ([s next]) {
            talisman.itemID = talismanID;
            talisman.numSlots = [s intForColumn:@"num_slots"];
            talisman.name = [s stringForColumn:@"talisman_name"];
            talisman.talismanType = [s stringForColumn:@"talisman_type"];
            talisman.skill1ID = [s intForColumn:@"skill_tree_1_id"];
            talisman.skill1Value = [s intForColumn:@"skill_tree_1_amount"];
            talisman.skill2ID = [s intForColumn:@"skill_tree_2_id"];
            talisman.skill2Value = [s intForColumn:@"skill_tree_2_amount"];
            talisman.slot = @"Talisman";
            
            NSMutableArray *skillArray = [[NSMutableArray alloc] init];
            
            if (talisman.skill1ID != 0) {
                FMResultSet *s = [self DBquery:[NSString stringWithFormat:@"select name from skill_trees where _id = %i", talisman.skill1ID]];
                if ([s next]){
                    [skillArray addObject:@{@"skillTreeID" : [NSNumber numberWithInt:talisman.skill1ID], @"skillTreeName" : [s stringForColumn:@"name"], @"skillTreePointValue" : [NSNumber numberWithInt:talisman.skill1Value]}];
                }
                
            }
            
            if (talisman.skill2ID != 0) {
                FMResultSet *s = [self DBquery:[NSString stringWithFormat:@"select name from skill_trees where _id = %i", talisman.skill1ID]];
                if ([s next]){
                    [skillArray addObject:@{@"skillTreeID" : [NSNumber numberWithInt:talisman.skill2ID], @"skillTreeName" : [s stringForColumn:@"name"], @"skillTreePointValue" : [NSNumber numberWithInt:talisman.skill2Value]}];
                }
                
            }
            talisman.skillsArray = skillArray;
            [s close];
        }

        }];
    
    return talisman;
}
//
//    if (![armorDatabase open]) {
//        return NULL;
//    } else {
//        NSString *query = [NSString stringWithFormat:@"SELECT * FROM charms where _id = %i", talismanID];
//        FMResultSet *s = [armorDatabase executeQuery:query];
//        
//        if ([s next]) {
//            Talisman *talisman = [[Talisman alloc] init];
//            talisman.itemID = talismanID;
//            talisman.numSlots = [s intForColumn:@"num_slots"];
//            talisman.name = [s stringForColumn:@"talisman_name"];
//            talisman.talismanType = [s stringForColumn:@"talisman_type"];
//            talisman.skill1ID = [s intForColumn:@"skill_tree_1_id"];
//            talisman.skill1Value = [s intForColumn:@"skill_tree_1_amount"];
//            talisman.skill2ID = [s intForColumn:@"skill_tree_2_id"];
//            talisman.skill2Value = [s intForColumn:@"skill_tree_2_amount"];
//            talisman.slot = @"Talisman";
//            
//            NSMutableArray *skillArray = [[NSMutableArray alloc] init];
//            
//            if (talisman.skill1ID != 0) {
//                FMResultSet *s = [self DBquery:[NSString stringWithFormat:@"select name from skill_trees where _id = %i", talisman.skill1ID]];
//                if ([s next]){
//                    [skillArray addObject:@{@"skillTreeID" : [NSNumber numberWithInt:talisman.skill1ID], @"skillTreeName" : [s stringForColumn:@"name"], @"skillTreePointValue" : [NSNumber numberWithInt:talisman.skill1Value]}];
//                }
//                
//            }
//            
//            if (talisman.skill2ID != 0) {
//                FMResultSet *s = [self DBquery:[NSString stringWithFormat:@"select name from skill_trees where _id = %i", talisman.skill1ID]];
//                if ([s next]){
//                    [skillArray addObject:@{@"skillTreeID" : [NSNumber numberWithInt:talisman.skill2ID], @"skillTreeName" : [s stringForColumn:@"name"], @"skillTreePointValue" : [NSNumber numberWithInt:talisman.skill2Value]}];
//                }
//
//            }
//            talisman.skillsArray = skillArray;
//            
//            return talisman;
//        }
//    }


-(BOOL)deleteTalisman:(Talisman *)talisman {
    FMDatabase *armorDatabase = [self openDatabase];
    
    if (![armorDatabase open]) {
        return false;
    } else {
        NSString *selectQuery = [NSString stringWithFormat:@"Select _id from ArmorSet where talisman_id = %i", talisman.itemID];
        
        FMResultSet *s = [armorDatabase executeQuery:selectQuery];
        NSMutableArray *setIDs = [[NSMutableArray alloc] init];
        while ([s next]) {
            [setIDs addObject:[NSNumber numberWithInt:[s intForColumn:@"_id"]]];
        }
        
        [armorDatabase close];
        
        for (int i = 0; i < setIDs.count; i++) {
            [self deleteAllDecorationsForArmorSetWithID:setIDs[i] andSetItem:talisman];
        }
        
        [armorDatabase open];
        
        
        NSString *updateQuery = [NSString stringWithFormat:@"Update ArmorSet set talisman_id = NULL where talisman_id = %i", talisman.itemID];
        
        [armorDatabase executeUpdate:updateQuery];
        
        NSString *deleteQuery = [NSString stringWithFormat:@"DELETE FROM charms where _id = %i", talisman.itemID];
        
        return [armorDatabase executeUpdate:deleteQuery];
    }
    
    return false;
}

-(BOOL)checkTalismanTable {
    
    if (_talismanCreated) {
        return YES;
    }
    
    FMDatabase *armorDatabase = [self openDatabase];
    
    if (![armorDatabase open]) {
        return false;
    } else {
        FMResultSet *tableCheck = [armorDatabase executeQuery:@"SELECT name FROM sqlite_master WHERE type='table' AND name='charms'"];
        if ([tableCheck next]) {
            [armorDatabase close];
            _talismanCreated = YES;
            return TRUE;
        } else {
           BOOL createTable = [armorDatabase executeUpdate:@"CREATE TABLE `charms` (`_id` integer primary key autoincrement,`num_slots` integer NOT NULL,`talisman_name` TEXT, `talisman_type` TEXT,`skill_tree_1_id` integer NOT NULL,`skill_tree_1_amount` integer NOT NULL,`skill_tree_2_id` integer DEFAULT NULL,`skill_tree_2_amount` integer DEFAULT NULL)"];
            BOOL addTestTalisman;
            if (createTable) {
                addTestTalisman = [armorDatabase executeUpdate:[NSString stringWithFormat:@"INSERT INTO CHARMS (_id, num_slots,talisman_name, talisman_type, skill_tree_1_id, skill_tree_1_amount, skill_tree_2_id, skill_tree_2_amount) values (%i, %i,'%@', '%@', %i, %i, %i, %i)",300000, 3, @"Test Talisman", @"Pawn", 3, 10, 20, -5]];
            }

            [armorDatabase close];
            _talismanCreated = YES;
            return addTestTalisman;
        }
    }
}

#pragma mark - Helper Methods
- (FMDatabase *)openDatabase //This method is required to do a check to see if the DB is not in the main bundle (which is read only)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documents_dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *db_path = [documents_dir stringByAppendingPathComponent:[NSString stringWithFormat:@"ArmorBuilder.db"]];
    NSString *template_path = [[NSBundle mainBundle] pathForResource:@"ArmorBuilder" ofType:@"db"];
    
    if (![fm fileExistsAtPath:db_path])
        [fm copyItemAtPath:template_path toPath:db_path error:nil];
    else {
        NSDictionary *bundleDBAttributes = [fm attributesOfItemAtPath:template_path error:nil];
        NSDictionary *documentDBAttributes = [fm attributesOfItemAtPath:db_path error:nil];
        NSDate *bundleModifiedDate = [bundleDBAttributes objectForKey:NSFileModificationDate];
        NSDate *dbModifiedDate = [documentDBAttributes objectForKey:NSFileModificationDate];
        
        if ([bundleModifiedDate compare:dbModifiedDate] == NSOrderedDescending) {
            [fm removeItemAtPath:db_path error:nil];
            [fm copyItemAtPath:template_path toPath:db_path error:nil];
        }
    }
    
    _asbDBPath = db_path;
    FMDatabase *db = [FMDatabase databaseWithPath:db_path];
    //if (![db open])
    //    NSLog(@"Failed to open database!");
    return db;
}

-(NSString *)returnDBTypeForArmorSlot:(NSString *)slot {
    if ([slot isEqualToString:@"Head"]) {
        return @"head_id";
    } else if ([slot isEqualToString:@"Body"]) {
        return @"body_id";
    } else if ([slot isEqualToString:@"Arms"]) {
        return @"arms_id";
    } else if ([slot isEqualToString:@"Waist"]) {
        return @"waist_id";
    } else if ([slot isEqualToString:@"Legs"]) {
        return @"legs_id";
    } else if ([slot isEqualToString:@"Weapon"]){
        return @"weapon_id";
    } else {
        return @"";
    }
}

-(NSString *)returnProperQueryStringForCompnents:(NSArray *)components {
    NSString *query = @", ";
    for (int i = 0; i < components.count; i++) {
        NSString *component = components[i];
        if (i < (components.count - 1)) {
            query = [query stringByAppendingString:[NSString stringWithFormat:@"%@, ", component]];
        } else {
            query = [query stringByAppendingString:[NSString stringWithFormat:@"%@", component]];
        }
    }
    
    return query;
}



@end

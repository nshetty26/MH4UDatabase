//
//  MH4UDBEntity.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface Armor : NSObject
@property (nonatomic) int armorID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *slot;
@property (nonatomic) int rarity;
@property (nonatomic) int price;
@property (nonatomic) int defense;
@property (nonatomic) int maxDefense;
@property (nonatomic) int fireResistance;
@property (nonatomic) int thunderResistance;
@property (nonatomic) int dragonResistance;
@property (nonatomic) int waterResistance;
@property (nonatomic) int iceResistance;
@property (nonatomic) NSString *gender;
@property (nonatomic) NSString *hunterType;
@property (nonatomic) int numSlots;
@property (nonatomic) NSArray *skillsArray;
@property (nonatomic) NSArray *componentArray;

@end

@interface Item : NSObject
@property (nonatomic) int itemID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *type;
@property (nonatomic) int rarity;
@property (nonatomic) int capacity;
@property (nonatomic) int price;
@property (nonatomic) int salePrice;
@property (nonatomic) NSString *condition;
@property (nonatomic) int stackSize;
@property (nonatomic) int percentage;
@property (nonatomic) NSString *itemDescription;
@property (nonatomic) NSString *icon;
@property (nonatomic) NSArray *combinedItemsArray;
@property (nonatomic) NSArray *usageItemsArray;
@property (nonatomic) NSArray *monsterDropsArray;
@property (nonatomic) NSArray *questRewardsArray;
@property (nonatomic) NSArray *locationsArray;
@end

@interface Monster : NSObject

@property (nonatomic) int monsterID;
@property (nonatomic) NSString *monsterClass;
@property (nonatomic) NSString *monsterName;
@property (nonatomic) NSString *trait;
@property (nonatomic) NSString *iconName;
@property (nonatomic) NSArray *monsterDetailDamage;
@property (nonatomic) NSArray *monsterStatusEffects;
@property (nonatomic) NSArray *monsterHabitats;
@property (nonatomic) NSArray *lowRankDrops;
@property (nonatomic) NSArray *highRankDrops;
@property (nonatomic) NSArray *gRankDrops;
@property (nonatomic) NSArray *questInfos;
@end

@interface MonsterDamage : NSObject
@property (nonatomic) NSString *bodyPart;
@property (nonatomic) int cutDamage;
@property (nonatomic) int impactDamage;
@property (nonatomic) int shotDamage;
@property (nonatomic) int fireDamage;
@property (nonatomic) int waterDamage;
@property (nonatomic) int iceDamage;
@property (nonatomic) int thunderDamage;
@property (nonatomic) int dragonDamage;
@property (nonatomic) int stun;

@end

@interface MonsterStatusEffect : NSObject
@property (nonatomic) NSString *status;
@property (nonatomic) int initial;
@property (nonatomic) int increase;
@property (nonatomic) int max;
@property (nonatomic) int duration;
@property (nonatomic) int damage;

@end

@interface MonsterHabitat : NSObject
@property (nonatomic) int locationID;
@property (nonatomic) NSString *locationName;
@property (nonatomic) int initial;
@property (nonatomic) NSString *movePath;
@property (nonatomic) int restArea;
@property (nonatomic) NSString *fullPath;

@end

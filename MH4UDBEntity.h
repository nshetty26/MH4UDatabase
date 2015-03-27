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
@property (nonatomic) int skillValue;
@property (nonatomic) int percentage;
@property (nonatomic) NSString *itemDescription;
@property (nonatomic) NSString *icon;
@property (nonatomic) NSArray *combinedItemsArray;
@property (nonatomic) NSArray *usageItemsArray;
@property (nonatomic) NSArray *monsterDropsArray;
@property (nonatomic) NSArray *questRewardsArray;
@property (nonatomic) NSArray *locationsArray;
@end

@interface Combining : NSObject
@property (nonatomic) Item *combinedItem;
@property (nonatomic) Item *item1;
@property (nonatomic) Item *item2;
@property (nonatomic) int minMade;
@property (nonatomic) int maxMade;
@property (nonatomic) int percentage;

@end

@interface Quest : NSObject
@property (nonatomic) int questID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *goal;
@property (nonatomic) NSString *hub;
@property (nonatomic) NSString *fullHub;
@property (nonatomic) NSString *unstable;
@property (nonatomic) NSString *type;
@property (nonatomic) int stars;
@property (nonatomic) NSString *location;
@property (nonatomic) int fee;
@property (nonatomic) int reward;
@property (nonatomic) int hrp;
@property (nonatomic) NSString *subQuest;
@property (nonatomic) int subQuestReward;
@property (nonatomic) int subHRP;
@property (nonatomic) NSArray *monsters;
@property (nonatomic) NSArray *rewards;
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
@property (nonatomic) NSString *icon;

@end

@interface SkillCollection : NSObject
@property (nonatomic) NSArray *skillArray;
@property (nonatomic) NSArray *headArray;
@property (nonatomic) NSArray *bodyArray;
@property (nonatomic) NSArray *armArray;
@property (nonatomic) NSArray *waistArray;
@property (nonatomic) NSArray *legArray;
@property (nonatomic) NSArray *decorationArray;

@end

@interface Decoration : Item
@property (nonatomic) NSArray *skillArray;
@property (nonatomic) NSArray *componentArray;

@end

@interface Location : NSObject
@property (nonatomic) int locationID;
@property (nonatomic) NSString *locationName;
@property (nonatomic) NSString *locationIcon;
@property (nonatomic) NSArray *monsterArray;
@property (nonatomic) NSArray *lowRankItemsArray;
@property (nonatomic) NSArray *highRankItemsArray;
@property (nonatomic) NSArray *gRankItemsArray;

@end

@interface GatheredResource : Item
@property (nonatomic) NSString *locationName;
@property (nonatomic) NSString *rank;
@property (nonatomic) NSString *area;
@property (nonatomic) NSString *site;
@property (nonatomic) int quantity;
@property (nonatomic) int percentage;
@end

@interface Weapon : Item
@property (nonatomic) NSString *weaponType;
@property (nonatomic) int parentID;
@property (nonatomic) int creationCost;
@property (nonatomic) int upgradeCost;
@property (nonatomic) int attack;
@property (nonatomic) int maxAttack;
@property (nonatomic) NSString *elementalDamageType_1;
@property (nonatomic) int elementalDamage_1;
@property (nonatomic) NSString *elementalDamageType_2;
@property (nonatomic) int elementalDamage_2;
@property (nonatomic) NSString *awaken_type;
@property (nonatomic) int awakenDamage;
@property (nonatomic) int defense;
@property (nonatomic) NSString *sharpness;
@property (nonatomic) int affinity;
@property (nonatomic) NSString *hornNotes;
@property (nonatomic) NSString *shellingType;
@property (nonatomic) NSString *phial;
@property (nonatomic) NSString *charges;
@property (nonatomic) NSString *coatings;
@property (nonatomic) NSString *recoil;
@property (nonatomic) NSString *reloadSpeed;
@property (nonatomic) NSString *rapidFire;
@property (nonatomic) NSString *deviation;
@property (nonatomic) NSString *ammo;
@property (nonatomic) NSString *sharpnessFile;
@property (nonatomic) int num_slots;
@property (nonatomic) int tree_depth;
@property (nonatomic) int final;


@end

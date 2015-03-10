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
@property (nonatomic) NSString *itemDescription;
@property (nonatomic) NSString *icon;
@property (nonatomic) NSArray *combinedItemsArray;
@property (nonatomic) NSArray *usageItemsArray;
@property (nonatomic) NSArray *monsterDropsArray;
@property (nonatomic) NSArray *questRewardsArray;
@property (nonatomic) NSArray *locationsArray;
@end
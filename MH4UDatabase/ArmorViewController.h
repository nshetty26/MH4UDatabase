//
//  ArmorViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/4/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArmorViewController : UIViewController <UITableViewDataSource, UITabBarDelegate>

@end

@interface Armor : NSObject

@property (nonatomic) int armorID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *slot;
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

@end

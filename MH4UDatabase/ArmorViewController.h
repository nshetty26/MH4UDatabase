//
//  ArmorViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/4/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MH4UDBEngine;

@interface ArmorViewController : UIViewController <UITableViewDataSource, UITabBarDelegate, UITableViewDelegate>
@property (strong, nonatomic) NSArray *allArmorArray;
@property (strong, nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) CGRect tabBarFrame;
@property (nonatomic) CGRect tableFrame;
@end

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

@interface ArmorView : UIView
@property (weak, nonatomic) IBOutlet UILabel *armorName;
@property (weak, nonatomic) IBOutlet UIImageView *IconImageView;
@property (weak, nonatomic) IBOutlet UILabel *armorPart;
@property (weak, nonatomic) IBOutlet UILabel *armorSlots;
@property (weak, nonatomic) IBOutlet UILabel *armorRarity;
@property (weak, nonatomic) IBOutlet UILabel *armorPrice;
@property (weak, nonatomic) IBOutlet UILabel *armorFR;
@property (weak, nonatomic) IBOutlet UILabel *armorWR;
@property (weak, nonatomic) IBOutlet UILabel *armorIR;
@property (weak, nonatomic) IBOutlet UILabel *armorTR;
@property (weak, nonatomic) IBOutlet UILabel *armorDR;

-(void)populateArmor:(Armor *)armor;
@end

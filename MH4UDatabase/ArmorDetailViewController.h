//
//  ArmorDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Armor;

@interface ArmorDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>

@property (nonatomic) Armor *selectedArmor;
@property (nonatomic) int heightDifference;

@end

@interface ArmorView : UIView
@property (weak, nonatomic) IBOutlet UILabel *armorName;
@property (weak, nonatomic) IBOutlet UIImageView *IconImageView;
@property (weak, nonatomic) IBOutlet UILabel *armorPart;
@property (weak, nonatomic) IBOutlet UILabel *armorDefense;
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

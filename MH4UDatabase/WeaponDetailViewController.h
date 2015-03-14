//
//  WeaponDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Weapon;

@interface WeaponDetailViewController : UIViewController
@property (nonatomic) Weapon *selectedWeapon;
@end

@interface DetailedWeaponView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *attackLabel;
@property (weak, nonatomic) IBOutlet UILabel *elementLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sharpnessImage;
@property (weak, nonatomic) IBOutlet UILabel *rarityLabel;
@property (weak, nonatomic) IBOutlet UILabel *numSlotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *defenseLabel;
@property (weak, nonatomic) IBOutlet UILabel *creationCostLabel;
@property (weak, nonatomic) IBOutlet UILabel *upgradeCostLabel;

-(void)populateWeapon:(Weapon *)weapon;

@end

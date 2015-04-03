//
//  WeaponDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Weapon;
@class MH4UDBEngine;

@interface WeaponDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>
@property (nonatomic) Weapon *selectedWeapon;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) int heightDifference;
@end

@interface DetailedWeaponView : UIView
@property (weak, nonatomic) IBOutlet UIView *sharpnessBackground;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *attackLabel;
@property (weak, nonatomic) IBOutlet UILabel *elementLabel;
@property (weak, nonatomic) IBOutlet UILabel *rarityLabel;
@property (weak, nonatomic) IBOutlet UILabel *numSlotsLabel;
@property (weak, nonatomic) IBOutlet UILabel *defenseLabel;
@property (weak, nonatomic) IBOutlet UILabel *creationCostLabel;
@property (weak, nonatomic) IBOutlet UILabel *upgradeCostLabel;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryLabel1;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryValue1;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryLabel2;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryValue2;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryLabel3;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryValue3;
@property (weak, nonatomic) IBOutlet UIImageView *hornNote1;
@property (weak, nonatomic) IBOutlet UIImageView *hornNote2;
@property (weak, nonatomic) IBOutlet UIImageView *hornNote3;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryLabel4;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryLabel5;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryLabel6;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryValue4;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryValue5;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryValue6;

-(void)populateWeapon:(Weapon *)weapon;
@property (weak, nonatomic) IBOutlet UIView *sharpnessView1;
@property (weak, nonatomic) IBOutlet UIView *sharpnessView2;

@end

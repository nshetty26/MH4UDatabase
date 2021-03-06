//
//  ArmorDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"

@class Armor;
@class MH4UDBEngine;
@class BaseViewController;

@interface ArmorDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) BaseViewController *baseViewController;
@property (nonatomic) Armor *selectedArmor;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) int heightDifference;

@end

@interface DetailedArmorView : UIView
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

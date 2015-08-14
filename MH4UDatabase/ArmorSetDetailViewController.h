//
//  ArmorSetViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/17/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"

@class ArmorSet;
@class MH4UDBEngine;
@class BaseViewController;
@class ArmorSetTableViewController;

@interface ArmorSetDetailViewController : UIViewController <UITabBarDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) MH4UDBEngine *dbEngine;
@property (strong, nonatomic) BaseViewController *baseVC;
@property (strong, nonatomic) ArmorSet *armorSet;
@property (strong, nonatomic) NSString *setName;
@property (strong, nonatomic) NSNumber *setID;
@property (strong, nonatomic) ArmorSetTableViewController *armorTVC;

@property (weak, nonatomic) IBOutlet UIImageView *weaponSlot1;
@property (weak, nonatomic) IBOutlet UIImageView *weaponSlot2;
@property (weak, nonatomic) IBOutlet UIImageView *weaponSlot3;
@property (weak, nonatomic) IBOutlet UIImageView *helmSlot1;
@property (weak, nonatomic) IBOutlet UIImageView *helmSlot2;
@property (weak, nonatomic) IBOutlet UIImageView *helmSlot3;
@property (weak, nonatomic) IBOutlet UIImageView *bodySlot1;
@property (weak, nonatomic) IBOutlet UIImageView *bodySlot2;
@property (weak, nonatomic) IBOutlet UIImageView *bodySlot3;
@property (weak, nonatomic) IBOutlet UIImageView *armsSlot1;
@property (weak, nonatomic) IBOutlet UIImageView *armsSlot2;
@property (weak, nonatomic) IBOutlet UIImageView *armsSlot3;
@property (weak, nonatomic) IBOutlet UIImageView *waistSlot1;
@property (weak, nonatomic) IBOutlet UIImageView *waistSlot2;
@property (weak, nonatomic) IBOutlet UIImageView *waistSlot3;
@property (weak, nonatomic) IBOutlet UIImageView *legsSlot1;
@property (weak, nonatomic) IBOutlet UIImageView *legsSlot2;
@property (weak, nonatomic) IBOutlet UIImageView *legsSlot3;
@property (weak, nonatomic) IBOutlet UIImageView *talismanSlot1;
@property (weak, nonatomic) IBOutlet UIImageView *talismanSlot2;
@property (weak, nonatomic) IBOutlet UIImageView *talismanSlot3;
@property (nonatomic) BOOL leftASDVC;


-(void)calculateSkillsForSelectedArmorSet;
-(void)setTabBarItemsForEquipmentTabBar;
-(void)populateArmorSet;

@end

@interface ArmorStatSheetView : UIView
@property (nonatomic, strong) ArmorSetDetailViewController *aSVC;
@property (weak, nonatomic) IBOutlet UIView *sharpnessView1;
@property (weak, nonatomic) IBOutlet UIView *sharpnessView2;
@property (weak, nonatomic) IBOutlet UIView *sharpnessBackground;
@property (nonatomic) int numSlots;
@property (weak, nonatomic) IBOutlet UITableView *statTableView;
-(void)populateStatsWithArmorSet:(ArmorSet *)armorSet;
@end
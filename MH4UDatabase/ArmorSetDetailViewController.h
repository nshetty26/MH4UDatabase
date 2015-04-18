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

@interface ArmorSetDetailViewController : UIViewController <UITabBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) MH4UDBEngine *dbEngine;
@property (strong, nonatomic) ArmorSet *armorSet;
@property (strong, nonatomic) NSString *setName;
-(void)combineSkillsArray:(NSArray *)skillArray;
@end

@interface ArmorStatSheetView : UIView
@property (nonatomic, strong) ArmorSetDetailViewController *aSVC;
@property (weak, nonatomic) IBOutlet UITableView *statTableView;
-(void)populateStatsWithArmorSet:(ArmorSet *)armorSet;
@end
//
//  WeaponFamilyTable.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/2/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MH4UDBEngine;
@class Weapon;

@interface WeaponUpgradeTable : UITableView <UITableViewDataSource, UITableViewDelegate>

-(id)initWithFrame:(CGRect)frame andNavigationController:(UINavigationController *)navigationController andDBEngine:(MH4UDBEngine *)dbEngine andWeapon:(Weapon *)weapon;
@end

//
//  WeaponTypeTableViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"
@class MH4UDBEngine;
@class BaseViewController;

@interface WeaponTypeTableViewController : UITableViewController

@property (nonatomic) BaseViewController *baseViewController;
@property (nonatomic) NSArray *allWeaponTypes;
@property (nonatomic) int heightDifference;
@property (nonatomic) MH4UDBEngine *dbEngine;
@end

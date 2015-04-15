//
//  WeaponsTableViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"
@class MH4UDBEngine;
@class BaseViewController;

@interface WeaponsTableViewController : UITableViewController <UISearchBarDelegate>

@property (nonatomic) NSArray *weaponsArray;
@property (strong, nonatomic) BaseViewController *baseViewController;
@property (nonatomic) NSString *imageString;
@property (nonatomic) NSString *weaponFamily;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) int heightDifference;
@end

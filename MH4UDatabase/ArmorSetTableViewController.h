//
//  ArmorSetTableViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/17/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"

@class MH4UDBEngine;

@interface ArmorSetTableViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) MH4UDBEngine *dbEngine;

@end

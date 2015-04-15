//
//  QuestsViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"

@class MH4UDBEngine;
@class BaseViewController;

@interface QuestsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UISearchBarDelegate>

@property (strong, nonatomic) BaseViewController *baseViewController;
@property (nonatomic) int heightDifference;
@property (nonatomic) NSArray *allQuestsArray;
@property (nonatomic) MH4UDBEngine *dbEngine;

@end

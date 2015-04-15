//
//  SkillDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"

@class BaseViewController;
@class SkillCollection;
@class MH4UDBEngine;

@interface SkillDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>

@property (strong, nonatomic) BaseViewController *baseViewController;
@property (nonatomic) int heightDifference;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) int skillTreeID;
@property (nonatomic) NSString *skilTreeName;

@end

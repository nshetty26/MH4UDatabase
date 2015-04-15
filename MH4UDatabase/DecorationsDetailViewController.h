//
//  DecorationsDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"

@class BaseViewController;
@class Decoration;
@class MH4UDBEngine;

@interface DecorationsDetailViewController : UIViewController <UITabBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) BaseViewController *baseViewController;
@property (nonatomic) Decoration *selectedDecoration;
@property (nonatomic) int heightDifference;
@property (nonatomic) MH4UDBEngine *dbEngine;

@end

//
//  CombiningViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"

@class BaseViewController;
@class MH4UDBEngine;

@interface CombiningViewController : UIViewController

@property (strong, nonatomic) BaseViewController *baseViewController;
@property (nonatomic) NSArray *allCombined;
@property (nonatomic) int heightDifference;
@property (nonatomic) MH4UDBEngine *dbEngine;
@end

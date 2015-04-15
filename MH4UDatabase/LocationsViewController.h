//
//  LocationsViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"

@class BaseViewController;
@class MH4UDBEngine;

@interface LocationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) BaseViewController *baseViewController;
@property (nonatomic) int heightDifference;
@property (nonatomic) NSArray *allLocations;
@property (nonatomic) MH4UDBEngine *dbEngine;

@end

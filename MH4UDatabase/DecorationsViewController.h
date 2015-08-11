//
//  JewelsViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"

@class BaseViewController;
@class  MH4UDBEngine;

@interface DecorationsViewController : UIViewController <UISearchBarDelegate>

@property (strong, nonatomic) BaseViewController *baseViewController;
@property (nonatomic) NSArray *allDecorations;
@property (nonatomic) int heightDifference;
@property (nonatomic) MH4UDBEngine *dbEngine;
@end

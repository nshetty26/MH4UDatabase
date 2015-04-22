//
//  UIViewController+UIViewController_MenuButton.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/15/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BaseViewController;

@interface UIViewController (UIViewController_MenuButton)

-(void)setUpMenuButton;
-(void)setUpMenuButtonWithBaseVC:(BaseViewController *)baseVC;

-(CGFloat)returnHeightDifference;

@end

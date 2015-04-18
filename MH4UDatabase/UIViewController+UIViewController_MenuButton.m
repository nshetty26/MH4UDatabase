//
//  UIViewController+UIViewController_MenuButton.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/15/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "UIViewController+UIViewController_MenuButton.h"
#import <MMDrawerBarButtonItem.h>

@implementation UIViewController (UIViewController_MenuButton)

-(void)setUpMenuButton {
    MMDrawerBarButtonItem *leftButton = [[MMDrawerBarButtonItem alloc] initWithTarget:nil action:@selector(openMenu)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    [self.navigationItem  setLeftBarButtonItems:@[leftButton] animated:YES];
    
    self.navigationItem.rightBarButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:nil action:@selector(openArmorBuilder)];
}

-(CGFloat)returnHeightDifference {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    return navBar.frame.size.height + statusBar.size.height;
}

- (void)backButtonPressed
{
    // write your code to prepare popview
    [self.navigationController popViewControllerAnimated:YES];
}
@end

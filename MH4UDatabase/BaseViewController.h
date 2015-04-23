//
//  BaseViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/15/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MMDrawerController.h"
#import "ArmorSetDetailViewController.h"

@interface BaseViewController : MMDrawerController <UINavigationControllerDelegate>

@property (strong, nonatomic) ArmorSetDetailViewController *aSDVC;

-(void)openMenu;
-(void)openArmorBuilder;

@end

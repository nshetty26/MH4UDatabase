//
//  BaseViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/15/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "BaseViewController.h"
#import "ArmorSetDetailViewController.h"
#import "ArmorSetTableViewController.h"
#import "UniversalSearchTableViewController.h"
#import "MenuViewController.h"
#import "MonstersViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"
#import <MMDrawerBarButtonItem.h>

@interface BaseViewController ()

@property (strong, nonatomic) MenuViewController *menuVC;
@property (strong, nonatomic) ArmorSetTableViewController *aSTVC;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UniversalSearchTableViewController *uSTC = [[UniversalSearchTableViewController alloc] init];
    uSTC.dbEngine = [[MH4UDBEngine alloc] init];
    uSTC.baseVC = self;
    self.centerViewController = [[UINavigationController alloc] initWithRootViewController:uSTC];

    
    _aSTVC = [[ArmorSetTableViewController alloc] init];
    _aSTVC.dbEngine = uSTC.dbEngine;
    _aSTVC.baseVC = self;
    UINavigationController *nC = [[UINavigationController alloc] initWithRootViewController:_aSTVC];
    nC.delegate = self;
    self.rightDrawerViewController = nC;
  
    _menuVC = [[MenuViewController alloc] init];

    self.leftDrawerViewController = [[UINavigationController alloc] initWithRootViewController:_menuVC];
    [self setMaximumLeftDrawerWidth:180];
    [self setMaximumRightDrawerWidth:300];
    
    self.closeDrawerGestureModeMask = MMCloseDrawerGestureModeTapCenterView;
    
}

-(void)openMenu {
    _menuVC.baseViewController = self;
    [self toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)openArmorBuilder {
    UINavigationController *nC = (UINavigationController *)self.rightDrawerViewController;
    UIViewController *vC = nC.visibleViewController;
    if ([vC isEqual:_aSDVC]) {
        _aSDVC.armorSet = [_aSDVC.dbEngine getArmorSetForSetID:_aSDVC.setID];
        [_aSDVC reDrawEverything];
        [_aSDVC calculateSkillsForSelectedArmorSet];
    } else if ([vC isEqual:_aSTVC]) {
        [_aSTVC refreshTableView];
    }
    [self toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isEqual:_aSTVC]) {
        [_aSTVC refreshTableView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

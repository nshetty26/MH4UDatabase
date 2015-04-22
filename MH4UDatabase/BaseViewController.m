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
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    MonstersViewController *mVC = [[MonstersViewController alloc] init];
//    mVC.dbEngine = [[MH4UDBEngine alloc] init];
//    self.centerViewController = [[UINavigationController alloc] initWithRootViewController:mVC];
    
    UniversalSearchTableViewController *uSTC = [[UniversalSearchTableViewController alloc] init];
    uSTC.dbEngine = [[MH4UDBEngine alloc] init];
    uSTC.baseVC = self;
    
    self.centerViewController = [[UINavigationController alloc] initWithRootViewController:uSTC];
    
    ArmorSetTableViewController *aSTVC = [[ArmorSetTableViewController alloc] init];
    self.rightDrawerViewController = [[UINavigationController alloc] initWithRootViewController:aSTVC];
    aSTVC.dbEngine = uSTC.dbEngine;
    aSTVC.baseVC = self;
    
    
    _menuVC = [[MenuViewController alloc] init];

    self.leftDrawerViewController = [[UINavigationController alloc] initWithRootViewController:_menuVC];
    [self setMaximumLeftDrawerWidth:180];
    [self setMaximumRightDrawerWidth:300];
    
    self.closeDrawerGestureModeMask = MMCloseDrawerGestureModeTapCenterView;
    //MMDrawerBarButtonItem *leftButton = [[MMDrawerBarButtonItem alloc] initWithTarget:nil action:@selector(openMenu)];
    //[self.navigationItem setLeftBarButtonItem:leftButton];
    //[mVC.navigationItem setLeftBarButtonItem:leftButton];
    
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
    }
    [self toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

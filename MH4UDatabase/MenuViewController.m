//
//  MasterViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/3/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MenuViewController.h"
#import "ArmorSetTableViewController.h"
#import "QuestsViewController.h"
#import "LocationsViewController.h"
#import "DecorationsViewController.h"
#import "SkillTreeViewController.h"
#import "ItemsViewController.h"
#import "ItemDetailViewController.h"
#import "MonstersViewController.h"
#import "ArmorsViewController.h"
#import "WeaponTypeTableViewController.h"
#import "CombiningViewController.h"
#import "UniversalSearchTableViewController.h"
#import "WyporiumTableViewController.h"
#import "MH4UDBEngine.h"
#import <MMDrawerBarButtonItem.h>

@interface MenuViewController ()

@property NSMutableArray *objects;
@property (strong, nonatomic) NSArray  *menuOptions;
@property (strong, nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) CGRect *tabBarFrame;
@property (nonatomic) CGRect *searchBarFrame;
@property (nonatomic) int heightDifference;
@end

@implementation MenuViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Menu", @"Menu");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(presentUniversalSearch)];

    _dbEngine = [[MH4UDBEngine alloc] init];
    if (!_menuOptions) {
        _menuOptions = [NSArray arrayWithObjects:@"Monsters", @"Weapons", @"Armor", @"Quests", @"Items", @"Combining", @"Locations", @"Decorations", @"Skill Tree",@"Wyporium", nil];
    }
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 80)];
    logo.backgroundColor = [UIColor grayColor];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.image = [UIImage imageNamed:@"MH4ULogo.png"];
    self.navigationController.navigationItem.title = @"Menu";
    self.tableView.tableHeaderView = logo;
    
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navigationBar = self.navigationController.navigationBar.frame;
    _heightDifference = statusBar.size.height + navigationBar.size.height;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menuOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *menuOption = [_menuOptions objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    UIFont *font = [cell.textLabel.font fontWithSize:15];
    cell.textLabel.font = font;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", menuOption]];
    cell.imageView.tintColor = [UIColor grayColor];
    cell.textLabel.text = menuOption;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *nC = (UINavigationController *)_baseViewController.centerViewController;
    NSString *menuOption = _menuOptions[indexPath.row];
    
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navigationBar = nC.navigationBar.frame;
    int heightDifference = statusBar.size.height + navigationBar.size.height;
    
    
    if ([menuOption isEqualToString:@"Monsters"]) {
        MonstersViewController *mVC = [[MonstersViewController alloc] init];
        mVC.dbEngine = _dbEngine;
        mVC.heightDifference = heightDifference;
        mVC.baseViewController = _baseViewController;
        [nC setViewControllers:@[mVC]];
        
    } else if ([menuOption isEqualToString:@"Weapons"]) {
        WeaponTypeTableViewController *wc = [[WeaponTypeTableViewController alloc] init];
        wc.heightDifference = heightDifference;
        wc.dbEngine = _dbEngine;
        [nC setViewControllers:@[wc]];
        
    } else if ([menuOption isEqualToString:@"Armor"]){
        ArmorsViewController *aVC = [[ArmorsViewController alloc] init];
        aVC.dbEngine = _dbEngine;
        aVC.heightDifference = heightDifference;
        aVC.baseViewController = _baseViewController;
        [nC setViewControllers:@[aVC]];
        
    } else if ([menuOption isEqualToString:@"Quests"]) {
        QuestsViewController *qVC = [[QuestsViewController alloc] init];
        qVC.heightDifference = heightDifference;
        qVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[qVC]];
        
    } else if ([menuOption isEqualToString:@"Items"]) {
        ItemsViewController *iVC = [[ItemsViewController alloc] init];
        iVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[iVC]];
        
    } else if ([menuOption isEqualToString:@"Combining"]) {
        CombiningViewController *cVC = [[CombiningViewController alloc] init];
        cVC.dbEngine = _dbEngine;
        cVC.heightDifference = heightDifference;
        [nC setViewControllers:@[cVC]];
        
    } else if ([menuOption isEqualToString:@"Locations"]) {
        LocationsViewController *lVC = [[LocationsViewController alloc] init];
        lVC.heightDifference = heightDifference;
        lVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[lVC]];
    } else if ([menuOption isEqualToString:@"Decorations"]) {
        DecorationsViewController *dVC = [[DecorationsViewController   alloc] init];
        dVC.heightDifference = heightDifference;
        dVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[dVC]];
    } else if ([menuOption isEqualToString:@"Skill Tree"]) {
        SkillTreeViewController *stVC = [[SkillTreeViewController   alloc] init];
        stVC.heightDifference = heightDifference;
        stVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[stVC]];
    } else if ([menuOption isEqualToString:@"Wyporium"]) {
        WyporiumTableViewController *wTC = [[WyporiumTableViewController alloc] init];
        wTC.dbEngine = _dbEngine;
        [nC setViewControllers:@[wTC]];
    }
    
}

-(void)presentUniversalSearch {
    UINavigationController *nC = (UINavigationController *)_baseViewController.centerViewController;
    UniversalSearchTableViewController *uSTC = [[UniversalSearchTableViewController alloc] init];
    uSTC.dbEngine = _dbEngine;
    [nC setViewControllers:@[uSTC]];
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the specified item to be editable.
//    return NO;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

@end


@implementation ItemTableCell

@end

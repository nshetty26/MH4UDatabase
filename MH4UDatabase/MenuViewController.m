//
//  MasterViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/3/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MenuViewController.h"
#import "QuestsViewController.h"
#import "LocationsViewController.h"
#import "DecorationsViewController.h"
#import "SkillTreeViewController.h"
#import "ItemsViewController.h"
#import "ItemDetailViewController.h"
#import "MonstersViewController.h"
#import "ArmorsViewController.h"
#import "DetailViewController.h"
#import "WeaponTypeTableViewController.h"
#import "CombiningViewController.h"
#import "UniversalSearchTableViewController.h"
#import "MH4UDBEngine.h"

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
    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:menu];
    self.title = NSLocalizedString(@"Menu", @"Menu");

    _dbEngine = [[MH4UDBEngine alloc] init];
    if (!_menuOptions) {
        _menuOptions = [NSArray arrayWithObjects:@"Monsters", @"Weapon", @"Armor", @"Quest", @"Item", @"Combining", @"Location", @"Decorations", @"Skill Tree", nil];
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
    
    UINavigationController *nC = (UINavigationController *)[self.splitViewController.viewControllers lastObject];
//    UniversalSearchTableViewController *uSTC = [[UniversalSearchTableViewController alloc] init];
//    [nC setViewControllers:@[uSTC]];
//    uSTC.dbEngine = _dbEngine;
    MonstersViewController *mVC = [[MonstersViewController alloc] init];
    mVC.dbEngine = _dbEngine;
    mVC.heightDifference = _heightDifference;
    [nC setViewControllers:@[mVC]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *nC = [segue destinationViewController];
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navigationBar = nC.navigationBar.frame;
    int heightDifference = statusBar.size.height + navigationBar.size.height;

    
    if ([[segue identifier] isEqualToString:@"showMonster"]) {
        MonstersViewController *mVC = [[MonstersViewController alloc] init];
        mVC.dbEngine = _dbEngine;
        mVC.heightDifference = heightDifference;
        [nC setViewControllers:@[mVC]];

    } else if ([[segue identifier] isEqualToString:@"showWeapon"]) {
        WeaponTypeTableViewController *wc = [[WeaponTypeTableViewController alloc] init];
        wc.heightDifference = heightDifference;
        wc.dbEngine = _dbEngine;
        [nC setViewControllers:@[wc]];
        
    } else if ([[segue identifier] isEqualToString:@"showArmor"]){
        ArmorsViewController *aVC = [[ArmorsViewController alloc] init];
        aVC.dbEngine = _dbEngine;
        aVC.heightDifference = heightDifference;
        [nC setViewControllers:@[aVC]];
        
    } else if ([[segue identifier] isEqualToString:@"showQuests"]) {
        QuestsViewController *qVC = [[QuestsViewController alloc] init];
        qVC.heightDifference = heightDifference;
        qVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[qVC]];
    } else if ([[segue identifier] isEqualToString:@"showItem"]) {
        ItemsViewController *iVC = [[ItemsViewController alloc] init];
        iVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[iVC]];

    } else if ([[segue identifier] isEqualToString:@"showCombined"]) {
        CombiningViewController *cVC = [[CombiningViewController alloc] init];
        cVC.dbEngine = _dbEngine;
        cVC.heightDifference = heightDifference;
        [nC setViewControllers:@[cVC]];
        
    } else if ([[segue identifier] isEqualToString:@"showLocation"]) {
        LocationsViewController *lVC = [[LocationsViewController alloc] init];
        lVC.heightDifference = heightDifference;
        lVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[lVC]];
    } else if ([[segue identifier] isEqualToString:@"showDecorations"]) {
        DecorationsViewController *dVC = [[DecorationsViewController   alloc] init];
        dVC.heightDifference = heightDifference;
        dVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[dVC]];
    } else if ([[segue identifier] isEqualToString:@"showSkillTree"]) {
        SkillTreeViewController *stVC = [[SkillTreeViewController   alloc] init];
        stVC.heightDifference = heightDifference;
        stVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[stVC]];
    }
   
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
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%@Cell", [menuOption stringByReplacingOccurrencesOfString:@" " withString:@""]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", menuOption]];
    cell.imageView.tintColor = [UIColor grayColor];
    cell.textLabel.text = menuOption;
    return cell;
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

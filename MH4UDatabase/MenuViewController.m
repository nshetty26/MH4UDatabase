//
//  MasterViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/3/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MenuViewController.h"
#import "DecorationsViewController.h"
#import "SkillTreeViewController.h"
#import "ItemsViewController.h"
#import "ItemDetailViewController.h"
#import "MonstersViewController.h"
#import "ArmorsViewController.h"
#import "DetailViewController.h"
#import "WeaponViewController.h"
#import "CombiningViewController.h"
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

    _dbEngine = [[MH4UDBEngine alloc] init];
    if (!_menuOptions) {
        _menuOptions = [NSArray arrayWithObjects:@"Monsters", @"Weapon", @"Armor", @"Quest", @"Item", @"Combining", @"Location", @"Decorations", @"Skill Tree", nil];
    }
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navigationBar = self.navigationController.view.frame;
    _heightDifference = statusBar.size.height + navigationBar.size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *nC = [segue destinationViewController];
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navigationBar = nC.navigationBar.frame;
    int heightDifference = statusBar.size.height + navigationBar.size.height;

    
    if ([[segue identifier] isEqualToString:@"showMonster"]) {
        MonstersViewController *mVC = [[MonstersViewController alloc] init];
        mVC.allMonstersArray = [_dbEngine populateAllMonsterArray];
        mVC.dbEngine = _dbEngine;
        mVC.heightDifference = heightDifference;
        [nC setViewControllers:@[mVC]];

    } else if ([[segue identifier] isEqualToString:@"showArmor"]){
        ArmorsViewController *aVC = [[ArmorsViewController alloc] init];
        aVC.allArmorArray = [_dbEngine populateArmorArray];
        aVC.dbEngine = _dbEngine;
        aVC.heightDifference = heightDifference;
        [nC setViewControllers:@[aVC]];
        

        
    } else if ([[segue identifier] isEqualToString:@"showItem"]) {
        ItemsViewController *iVC = [[ItemsViewController alloc] init];
        iVC.allItems = [_dbEngine populateItemArray];
        iVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[iVC]];
        //controller.dbEngine = _dbEngine;
        //[controller setDetailItem:@"Item"];

    } else if ([[segue identifier] isEqualToString:@"showWeapon"]) {
        
        WeaponViewController *wc = [[WeaponViewController alloc] init];
        [nC setViewControllers:@[wc]];
        NSLog(@"Pause");

    } else if ([[segue identifier] isEqualToString:@"showCombined"]) {
        CombiningViewController *cVC = [[CombiningViewController alloc] init];
        cVC.allCombined = [_dbEngine getCombiningItems];
        cVC.dbEngine = _dbEngine;
        cVC.heightDifference = heightDifference;
        [nC setViewControllers:@[cVC]];
        
    } else if ([[segue identifier] isEqualToString:@"showDecorations"]) {
        DecorationsViewController *dVC = [[DecorationsViewController   alloc] init];
        dVC.allDecorations = [_dbEngine getAllDecorations];
        dVC.heightDifference = heightDifference;
        dVC.dbEngine = _dbEngine;
        [nC setViewControllers:@[dVC]];
    } else if ([[segue identifier] isEqualToString:@"showSkillTree"]) {
        SkillTreeViewController *stVC = [[SkillTreeViewController   alloc] init];
        stVC.allSkillTrees = [_dbEngine getSkillTrees];
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

@implementation CombiningCell


- (IBAction)launchDetailItem:(id)sender {
    ItemDetailViewController *iDVC = [[ItemDetailViewController alloc] init];
    UIButton *button = (UIButton *)sender;
    Item *selectedItem = [_dbEngine getItemForName:button.titleLabel.text];
    iDVC.selectedItem = selectedItem;
    iDVC.dbEngine = _dbEngine;
    iDVC.heightDifference = _heightDifference;
    [_nC pushViewController:iDVC animated:YES];
    
}
@end

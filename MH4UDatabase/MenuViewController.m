//
//  MasterViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/3/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MenuViewController.h"
#import "DetailViewController.h"
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

    _dbEngine = [[MH4UDBEngine alloc] init];
    if (!_menuOptions) {
        _menuOptions = [NSArray arrayWithObjects:@"Monster", @"Weapon", @"Armor", @"Quest", @"Item", @"Combining", @"Location", @"Decoration", nil];
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

    if ([[segue identifier] isEqualToString:@"showMonsters"]) {
        //MonsterViewController *mVC = (MonsterViewController *)[segue destinationViewController];
        //mVC.navigationItem.leftItemsSupplementBackButton = YES;
    } else if ([[segue identifier] isEqualToString:@"showArmor"]){
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        controller.dbEngine = _dbEngine;
        [controller setDetailItem:@"Armor"];
        
    } else if ([[segue identifier] isEqualToString:@"showItem"]) {
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        controller.dbEngine = _dbEngine;
        [controller setDetailItem:@"Item"];

    } else if ([[segue identifier] isEqualToString:@"showWeapon"]) {
    }
//    } else if ([[segue identifier] isEqualToString:@"showWeapons"]) {
//        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
//        controller.detailDescriptionLabel.text = @"Weapon View";
//        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;

//    }
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
    NSString *reuseIdentifier = [NSString stringWithFormat:@"%@Cell", menuOption];
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

@end

//
//  WyporiumTableViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/26/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "WyporiumTableViewController.h"
#import "UIViewController+UIViewController_MenuButton.h"
#import "QuestDetailViewController.h"
#import "ItemDetailViewController.h"
#import "LocationDetailViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface WyporiumTableViewController ()
@property (nonatomic ,strong) NSArray *allTrades;
@property (nonatomic, strong) NSArray *displayedTrades;
@end

@implementation WyporiumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.title = @"Wyporium Trades";
    _allTrades = [_dbEngine getAllWyporiumTrades];
    _displayedTrades = _allTrades;
    CGRect searchBar = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 38);
    UISearchBar *wyporiumSearch = [[UISearchBar alloc] initWithFrame:searchBar];
    wyporiumSearch.delegate = self;
    self.tableView.tableHeaderView = wyporiumSearch;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Bar Delegate Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [searchBar setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showAllTrades];
        return;
    }
    NSArray *searchedTrades = [_displayedTrades filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        NSArray *trade = (NSArray *)evaluatedObjected;
        Item *itemIn = trade[0];
        Item *itemOut = trade[1];
        Item *unlockQuest = trade[2];
        BOOL shouldBeDisplayed = false;
        if (!([itemIn.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
            shouldBeDisplayed = true;
        }
        if (!([itemOut.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
            shouldBeDisplayed = true;
        }
        if (!([unlockQuest.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
            shouldBeDisplayed = true;
        }
        if (shouldBeDisplayed) {
            return YES;
        } else {
            return NO;
        }
        
    }]];
    
    _displayedTrades = searchedTrades;
    [self.tableView reloadData];
}

-(void)showAllTrades {
    _displayedTrades = _allTrades;
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO];
    [self showAllTrades];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _displayedTrades.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wyporiumCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"WyporiumCell"  bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"wyporiumCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"wyporiumCell"];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(WyporiumTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *singleTrade = _displayedTrades[indexPath.row];
    cell.itemIn = singleTrade[0];
    cell.itemOut = singleTrade[1];
    cell.unlockQuest = singleTrade[2];
    cell.dbEngine = _dbEngine;
    cell.navigationController = self.navigationController;
    cell.heightDifference = [self returnHeightDifference];
    //cell.dbEngine = _dbEngine;
    //cell.nC = _navigationController;
    //cell.heightDifference = [self returnHeightDifference];
    cell.questLabel.text = cell.unlockQuest.name;
    cell.inItemLabel.text = cell.itemIn.name;
    cell.inItemImage.image = [UIImage imageNamed:cell.itemIn.icon];
    cell.outItemLabel.text = cell.itemOut.name;
    cell.outItemImage.image = [UIImage imageNamed:cell.itemOut.icon];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


@implementation WyporiumTableViewCell

- (IBAction)launchDetailedVC:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([button isEqual:_questButton]) {
        if (_unlockQuest) {
            QuestDetailViewController *qDVC = [[QuestDetailViewController alloc] init];
            qDVC.dbEngine = _dbEngine;
            qDVC.heightDifference = _heightDifference;
            qDVC.selectedQuest = _unlockQuest;
            [_navigationController pushViewController:qDVC animated:YES];
        } else if (_tradeLocation) {
            LocationDetailViewController *lDVC = [[LocationDetailViewController alloc] init];
            lDVC.dbEngine = _dbEngine;
            lDVC.heightDifference = _heightDifference;
            lDVC.selectedLocation = _tradeLocation;
            [_navigationController pushViewController:lDVC animated:YES];
        }

    } else {
        Item *item;
        if ([button isEqual:_inButton]) {
            item  = _itemIn;
        } else {
            item = _itemOut;
        }
        
        ItemDetailViewController *itemDetailVC = [[ItemDetailViewController alloc] init];
        itemDetailVC.selectedItem = [_dbEngine getItemForName:item.name];
        itemDetailVC.dbEngine = _dbEngine;
        itemDetailVC.heightDifference =  _heightDifference;
        [_navigationController pushViewController:itemDetailVC animated:YES];
    }
}
@end

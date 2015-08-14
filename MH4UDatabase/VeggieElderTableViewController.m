//
//  VeggieElderTableViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 8/14/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "VeggieElderTableViewController.h"
#import "WyporiumTableViewController.h"
#import "QuestDetailViewController.h"
#import "ItemDetailViewController.h"
#import "UIViewController+UIViewController_MenuButton.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface VeggieElderTableViewController ()

@property (nonatomic) NSArray *allTrades;
@property (nonatomic) NSArray *displayedTrades;

@end

@implementation VeggieElderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.title = @"Veggie Elder Trades";
    _allTrades = [_dbEngine getAllVeggieElderTrades];
    _displayedTrades = _allTrades;
    CGRect searchBar = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 38);
    UISearchBar *veggieSearch = [[UISearchBar alloc] initWithFrame:searchBar];
    veggieSearch.delegate = self;
    self.tableView.tableHeaderView = veggieSearch;
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
        NSDictionary *trade = (NSDictionary *)evaluatedObjected;
        Item *offerItem = [trade objectForKey:@"offerItem"];
        Item *receiveItem = [trade objectForKey:@"receiveItem"];
        Location *location = [trade objectForKey:@"@location"];
        BOOL shouldBeDisplayed = false;
        if (!([offerItem.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
            shouldBeDisplayed = true;
        }
        if (!([receiveItem.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
            shouldBeDisplayed = true;
        }
        if (!([location.locationName.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
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
    
    NSDictionary *singleTrade = _displayedTrades[indexPath.row];
    cell.itemIn = [singleTrade objectForKey:@"offerItem"];
    cell.itemOut = [singleTrade objectForKey:@"receiveItem"];
    cell.tradeLocation = [singleTrade objectForKey:@"location"];
    cell.dbEngine = _dbEngine;
    cell.navigationController = self.navigationController;
    cell.heightDifference = [self returnHeightDifference];
    //cell.dbEngine = _dbEngine;
    //cell.nC = _navigationController;
    //cell.heightDifference = [self returnHeightDifference];
    cell.questLabel.text = cell.tradeLocation.locationName;
    cell.inItemLabel.text = cell.itemIn.name;
    cell.inItemImage.image = [UIImage imageNamed:cell.itemIn.icon];
    cell.outItemLabel.text = [NSString stringWithFormat:@"%@ %@", [singleTrade objectForKey:@"quantity"],cell.itemOut.name];
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


//@implementation WyporiumTableViewCell
//
//- (IBAction)launchDetailedVC:(id)sender {
//    UIButton *button = (UIButton *)sender;
//    if ([button isEqual:_questButton]) {
//        Quest *quest = _unlockQuest;
//        QuestDetailViewController *qDVC = [[QuestDetailViewController alloc] init];
//        qDVC.dbEngine = _dbEngine;
//        qDVC.heightDifference = _heightDifference;
//        qDVC.selectedQuest = quest;
//        [_navigationController pushViewController:qDVC animated:YES];
//    } else {
//        Item *item;
//        if ([button isEqual:_inButton]) {
//            item  = _itemIn;
//        } else {
//            item = _itemOut;
//        }
//        
//        ItemDetailViewController *itemDetailVC = [[ItemDetailViewController alloc] init];
//        itemDetailVC.selectedItem = [_dbEngine getItemForName:item.name];
//        itemDetailVC.dbEngine = _dbEngine;
//        itemDetailVC.heightDifference =  _heightDifference;
//        [_navigationController pushViewController:itemDetailVC animated:YES];
//    }
//}
//@end

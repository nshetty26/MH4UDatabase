//
//  UniversalSearchTableViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/7/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "UniversalSearchTableViewController.h"
#import "ArmorDetailViewController.h"
#import "WeaponDetailViewController.h"
#import "DecorationsDetailViewController.h"
#import "ItemDetailViewController.h"
#import "QuestDetailViewController.h"
#import "LocationDetailViewController.h"
#import "MH4UDBEngine.h"

@interface UniversalSearchTableViewController ()
@property (strong, nonatomic) NSArray *everythingArray;
@end

@implementation UniversalSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Universal Search";
    CGRect searchBar = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 38);
    UISearchBar *mhSearch = [[UISearchBar alloc] initWithFrame:searchBar];
    mhSearch.delegate = self;
    self.tableView.tableHeaderView = mhSearch;

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [searchBar setShowsCancelButton:YES];
    if (searchText.length == 0) {
        _everythingArray = nil;
        [self.tableView reloadData];
        return;
    }
    _everythingArray = [_dbEngine populateResultsWithSearch:searchText];
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO];
    searchBar.text = @"";
    _everythingArray = nil;
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _everythingArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *MHObject = _everythingArray[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MHObject[1]];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MHObject[1]];
    }
    

    if ([MHObject[1] isEqualToString:@"Quest"]) {
        cell.detailTextLabel.text = MHObject[3];
    } else {
        cell.imageView.image = [UIImage imageNamed:MHObject[3]];
        cell.detailTextLabel.text = MHObject[1];
    }
    cell.textLabel.text = MHObject[2];
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSArray *mhObject = _everythingArray[indexPath.row];
//    if ([mhObject[1] isEqualToString:@"Monster"]) {
//        NSString *string;
//    } else if ([mhObject[1] isEqualToString:@"Weapon"]){
//        NSNumber *weaponID = mhObject[0];
//        Weapon *weapon = [_dbEngine getWeaponForWeaponID:[weaponID intValue]];
//        WeaponDetailViewController *wDVC = [[WeaponDetailViewController alloc] init];
//        wDVC.selectedWeapon = weapon;
//        wDVC.dbEngine = _dbEngine;
//        wDVC.heightDifference = [self returnHeightDifference];
//        [self.navigationController pushViewController:wDVC animated:YES];
//        
//    } else if ([mhObject[1] isEqualToString:@"Armor"]){
//        Armor *armor = [[_dbEngine retrieveArmor: mhObject[0]] firstObject];
//        ArmorDetailViewController *aDVC = [[ArmorDetailViewController alloc] init];
//        aDVC.heightDifference = [self returnHeightDifference];
//        aDVC.selectedArmor = armor;
//        aDVC.dbEngine = _dbEngine;
//        [self.navigationController pushViewController:aDVC animated:YES];
//        
//    } else if ([mhObject[1] isEqualToString:@"Quest"]){
//        
//    } else if ([mhObject[1] isEqualToString:@"Location"]){
//        
//    } else if ([mhObject[1] isEqualToString:@"Decoration"]){
//        Decoration *decoration = [[_dbEngine getAllDecorations:[NSNumber numberWithInt:item.itemID]] firstObject];
//        decoration.componentArray = [_dbEngine getComponentsfor:decoration.itemID];
//        DecorationsDetailViewController *dDVC = [[DecorationsDetailViewController alloc] init];
//        dDVC.heightDifference = [self returnHeightDifference];
//        dDVC.dbEngine = _dbEngine;
//        dDVC.selectedDecoration = decoration;
//        [self.navigationController pushViewController:dDVC animated:YES];
//        
//    } else {
//        ItemDetailViewController *itemDetailVC = [[ItemDetailViewController alloc] init];
//        itemDetailVC.selectedItem = item;
//        itemDetailVC.dbEngine = _dbEngine;
//        itemDetailVC.heightDifference = [self returnHeightDifference];
//        [self.navigationController pushViewController:itemDetailVC animated:YES];
//        
//    }
}

-(CGFloat)returnHeightDifference {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    return navBar.frame.size.height + statusBar.size.height;
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

//
//  WeaponsTableViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "WeaponsTableViewController.h"
#import "WeaponDetailViewController.h"
#import "MH4UDBEntity.h"

@interface WeaponsTableViewController ()
@property (nonatomic) NSArray *displayedWeapons;
@end

@implementation WeaponsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:_weaponFamily style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    _displayedWeapons = _weaponsArray;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    CGRect searchBar = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 38);
    UISearchBar *weaponSearch = [[UISearchBar alloc] initWithFrame:searchBar];
    weaponSearch.delegate = self;
    self.tableView.tableHeaderView = weaponSearch;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [searchBar setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showallWeapons];
        return;
    }
    NSArray *searchedWeapons = [_displayedWeapons filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        Weapon *weapon = (Weapon *)evaluatedObjected;
        if ([weapon.name.lowercaseString containsString:searchText.lowercaseString]) {
            return YES;
        } else {
            return NO;
        }
        
    }]];
    
    _displayedWeapons = searchedWeapons;
    [self.tableView reloadData];
}

-(void)showallWeapons {
    _displayedWeapons = _weaponsArray;
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO];
    [self showallWeapons];
    searchBar.text = @"";
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
    return _displayedWeapons.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weaponCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"weaponCell"];
    }
    
    // Configure the cell...
    Weapon *weapon = _displayedWeapons[indexPath.row];
    cell.indentationWidth = 3;
    cell.textLabel.text = weapon.name;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",_imageString, weapon.rarity]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i Atk %i%@ Aff", weapon.attack, weapon.affinity, @"%"];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    Weapon *weapon = _displayedWeapons[indexPath.row];
    return weapon.tree_depth;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Weapon *weapon = _displayedWeapons[indexPath.row];
    NSMutableArray *parentWeapons = [[NSMutableArray alloc] init];
    NSMutableArray *upgradeWeapons = [[NSMutableArray alloc] init];
    [self getParentWeapons:weapon inArray:parentWeapons];
    [self getUpgradedWeapons:weapon inArray:upgradeWeapons];
    [parentWeapons addObjectsFromArray:upgradeWeapons];
    [parentWeapons addObject:weapon];
    [parentWeapons sortUsingComparator:^NSComparisonResult(id w1, id w2){
        Weapon *weapon1 = (Weapon *)w1;
        Weapon *weapon2 = (Weapon *)w2;
        if (weapon1.itemID > weapon2.itemID) {
            return 1;
        } else if (weapon1.itemID < weapon2.itemID) {
            return -1;
        } else {
            return 0;
        }
    }];

    WeaponDetailViewController *wDVC = [[WeaponDetailViewController alloc] init];
    wDVC.selectedWeapon = weapon;
    wDVC.weaponFamily = parentWeapons;
    wDVC.imageString = _imageString;
    wDVC.dbEngine = _dbEngine;
    wDVC.heightDifference = _heightDifference;
    [self.navigationController pushViewController:wDVC animated:YES];
}

-(void)getParentWeapons:(Weapon *)weapon inArray:(NSMutableArray *)parentWeaponArray {
    NSArray *weaponArray = [_weaponsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        Weapon *arrayWeapon = (Weapon *)evaluatedObjected;
        if (arrayWeapon.itemID == weapon.parentID) {
            return YES;
        } else {
            return NO;
        }
        
    }]];

    Weapon *parentWeapon = [weaponArray firstObject];
    if (parentWeapon.parentID != 0) {
        [parentWeaponArray addObject:parentWeapon];
        [self getParentWeapons:parentWeapon inArray:parentWeaponArray];
    } else {
        [parentWeaponArray addObject:parentWeapon];
        return;
    }
}

-(void)getUpgradedWeapons:(Weapon *)weapon inArray:(NSMutableArray *)upgradedWeaponArray {
    NSArray *weaponArray = [_weaponsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        Weapon *arrayWeapon = (Weapon *)evaluatedObjected;
        if (arrayWeapon.parentID == weapon.itemID) {
            return YES;
        } else {
            return NO;
        }
        
    }]];
    
    
    if (weaponArray.count == 1) {
        Weapon *upgradedWeapon = [weaponArray firstObject];
        [upgradedWeaponArray addObject:upgradedWeapon];
        [self getUpgradedWeapons:upgradedWeapon inArray:upgradedWeaponArray];
    } else if (weaponArray.count > 1) {
        for (Weapon *upgrade in weaponArray) {
            [upgradedWeaponArray addObject:upgrade];
            [self getUpgradedWeapons:upgrade inArray:upgradedWeaponArray];
        }
    }
    else {
        return;
    }
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

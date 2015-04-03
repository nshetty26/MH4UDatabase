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
#import "MH4UDBEngine.h"

@interface WeaponsTableViewController ()
@property (nonatomic) NSArray *displayedWeapons;
@end

@implementation WeaponsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(_weaponFamily, _weaponFamily);
    _weaponsArray = [_dbEngine getWeaponsForWeaponType:_weaponFamily];
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
    WeaponDetailViewController *wDVC = [[WeaponDetailViewController alloc] init];
    wDVC.selectedWeapon = weapon;
    wDVC.dbEngine = _dbEngine;
    wDVC.heightDifference = _heightDifference;
    [self.navigationController pushViewController:wDVC animated:YES];
}




@end

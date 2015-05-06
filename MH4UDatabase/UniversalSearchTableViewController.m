//
//  UniversalSearchTableViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/7/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "UniversalSearchTableViewController.h"
#import "SkillDetailViewController.h"
#import "MonsterDetailViewController.h"
#import "UIViewController+UIViewController_MenuButton.h"
#import "ArmorDetailViewController.h"
#import "WeaponDetailViewController.h"
#import "DecorationsDetailViewController.h"
#import "ItemDetailViewController.h"
#import "QuestDetailViewController.h"
#import "LocationDetailViewController.h"
#import "BaseViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface UniversalSearchTableViewController ()
@property (strong, nonatomic) NSArray *everythingArray;
@end

@implementation UniversalSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButtonWithBaseVC:_baseVC];
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

#pragma mark - Search Bar Delegate Methods
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
    

    if ([MHObject[1] isEqualToString:@"Quest"] || [MHObject[1] isEqualToString:@"Skill Tree"]) {
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
    
    NSArray *mhObject = _everythingArray[indexPath.row];
    if ([mhObject[1] isEqualToString:@"Monster"]) {
        Monster *monster = [[_dbEngine getMonsters:mhObject[0]] firstObject];
        MonsterDetailViewController *mDVC = [[MonsterDetailViewController alloc] init];
        mDVC.selectedMonster = monster;
        mDVC.heightDifference = [self returnHeightDifference];
        mDVC.dbEngine = _dbEngine;
        [self.navigationController pushViewController:mDVC animated:YES];
    } else if ([mhObject[1] isEqualToString:@"Weapon"]){
        NSNumber *weaponID = mhObject[0];
        Weapon *weapon = [_dbEngine getWeaponForWeaponID:[weaponID intValue]];
        WeaponDetailViewController *wDVC = [[WeaponDetailViewController alloc] init];
        wDVC.selectedWeapon = weapon;
        wDVC.dbEngine = _dbEngine;
        wDVC.heightDifference = [self returnHeightDifference];
        [self.navigationController pushViewController:wDVC animated:YES];
        
    } else if ([mhObject[1] isEqualToString:@"Armor"]){
        Armor *armor = [[_dbEngine getArmor: mhObject[0]] firstObject];
        ArmorDetailViewController *aDVC = [[ArmorDetailViewController alloc] init];
        aDVC.heightDifference = [self returnHeightDifference];
        aDVC.selectedArmor = armor;
        aDVC.dbEngine = _dbEngine;
        [self.navigationController pushViewController:aDVC animated:YES];
        
    } else if ([mhObject[1] isEqualToString:@"Quest"]){
        Quest *quest = [[_dbEngine getAllQuests:mhObject[0]] firstObject];
        QuestDetailViewController *qDVC = [[QuestDetailViewController alloc] init];
        qDVC.dbEngine = _dbEngine;
        qDVC.heightDifference = [self returnHeightDifference];
        qDVC.selectedQuest = quest;
        [self.navigationController pushViewController:qDVC animated:YES];
        
    } else if ([mhObject[1] isEqualToString:@"Location"]){
        Location *location = [[_dbEngine getAllLocations:mhObject[0]] firstObject] ;
        LocationDetailViewController *lDVC = [[LocationDetailViewController alloc] init];
        lDVC.heightDifference = [self returnHeightDifference];
        lDVC.selectedLocation = location;
        lDVC.dbEngine = _dbEngine;
        [self.navigationController pushViewController:lDVC animated:YES];
        
    } else if ([mhObject[1] isEqualToString:@"Decoration"]){
        NSNumber *decorationID = mhObject[0];
        Decoration *decoration = [[_dbEngine getAllDecorations:decorationID] firstObject];
        decoration.componentArray = [_dbEngine getComponentsfor:decoration.itemID];
        DecorationsDetailViewController *dDVC = [[DecorationsDetailViewController alloc] init];
        dDVC.heightDifference = [self returnHeightDifference];
        dDVC.dbEngine = _dbEngine;
        dDVC.selectedDecoration = decoration;
        [self.navigationController pushViewController:dDVC animated:YES];
        
    } else if ([mhObject[1] isEqualToString:@"Skill Tree"]) {
        SkillDetailViewController *sdVC = [[SkillDetailViewController alloc] init];
        sdVC.heightDifference = [self returnHeightDifference];
        sdVC.dbEngine = _dbEngine;
        sdVC.skilTreeName = mhObject[2];
        NSNumber *skillTreeID = mhObject[0];
        sdVC.skillTreeID = [skillTreeID intValue];
        [self.navigationController pushViewController:sdVC animated:YES];
    }else {
        ItemDetailViewController *itemDetailVC = [[ItemDetailViewController alloc] init];
        itemDetailVC.selectedItem = [_dbEngine getItemForName:mhObject[2]];
        itemDetailVC.dbEngine = _dbEngine;
        itemDetailVC.heightDifference = [self returnHeightDifference];
        [self.navigationController pushViewController:itemDetailVC animated:YES];
        
    }
}  


@end

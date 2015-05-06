//
//  MonstersViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MH4UDBEntity.h"
#import "MH4UDBEngine.h"
#import "MonstersViewController.h"
#import "MonsterDetailViewController.h"

@interface MonstersViewController ()
@property (nonatomic) NSArray *displayedMonsters;
@property (nonatomic) NSArray *smallMonsters;
@property (nonatomic) NSArray *bigMonsters;
@property (nonatomic) UITableView *monsterTable;
@property (nonatomic) UITabBar *monstersTab;
@property (nonatomic) Monster *selectedMonster;
@property (nonatomic) UISearchBar *monsterSearch;

@end

@implementation MonstersViewController

#pragma mark - Setup Views
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    _allMonstersArray = [_dbEngine getMonsters:nil];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Monsters", @"Monsters");
    _displayedMonsters = _allMonstersArray;
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    [self setUpTabBarWithFrame:tabBarFrame];
    
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference + tabBarFrame.size.height, vcFrame.size.width, 44);
    _monsterSearch = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _monsterSearch.delegate = self;
    
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height + tabBarFrame.size.height + _heightDifference, vcFrame.size.width, vcFrame.size.height - (searchBarFrame.size.height + tabBarFrame.size.height));
    [self setUpTableWithFrame:tableWithSearch];
    
    [self.view addSubview:_monsterTable];
    [self.view addSubview:_monstersTab];
    [self.view addSubview:_monsterSearch];
}

-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_monstersTab) {
        _monstersTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
        _monstersTab.delegate = self;
        
        UITabBarItem *allMonsters = [[UITabBarItem alloc] initWithTitle:@"All" image:nil tag:1];
        UITabBarItem *largeMonsters = [[UITabBarItem alloc] initWithTitle:@"Large" image:nil tag:2];
        UITabBarItem *smallMonsters = [[UITabBarItem alloc] initWithTitle:@"Small" image:nil tag:3];
        
        [_monstersTab setItems:@[allMonsters, largeMonsters, smallMonsters]];
        [_monstersTab setSelectedItem:allMonsters];
    }

}

-(void)setUpTableWithFrame:(CGRect)tableFrame {
    if (!_monsterTable) {
        _monsterTable = [[UITableView alloc] initWithFrame:tableFrame];
        _monsterTable.dataSource = self;
        _monsterTable.delegate = self;
    }
}


#pragma mark - Search Bar Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_monsterSearch setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showMonsters];
    }
    else {
        NSArray *searchedMonsters = [_displayedMonsters filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
            Monster *monster = (Monster*)evaluatedObjected;
            if (!([monster.monsterName.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
                return YES;
            } else {
                return NO;
            }
            
        }]];
        
        _displayedMonsters = searchedMonsters;
        [_monsterTable reloadData];
    }
}

-(void)showMonsters {
    if ([_monstersTab selectedItem].tag == 1) {
        _displayedMonsters = _allMonstersArray;
    } else if ([_monstersTab selectedItem].tag == 2) {
        _displayedMonsters = _bigMonsters;
    } else if ([_monstersTab selectedItem].tag == 3) {
        _displayedMonsters = _smallMonsters;
    }
    
    [_monsterTable reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO];
    [self showMonsters];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Tab Bar Methods
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 1:
            _displayedMonsters = _allMonstersArray;
            break;
        case 2:
            _bigMonsters = [_allMonstersArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                Monster *mon = (Monster *)evaluatedObject;
                return [mon.monsterClass isEqualToString:@"Boss"];}]];
            _displayedMonsters = _bigMonsters;
            break;
        case 3:
            _smallMonsters = [_allMonstersArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                Monster *mon = (Monster *)evaluatedObject;
                return [mon.monsterClass isEqualToString:@"Minion"];}]];
            _displayedMonsters = _smallMonsters;
            break;
        default:
            break;
    }
    
    [_monsterTable reloadData];
}

#pragma mark - Table View Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_monsterTable]) {
        return _displayedMonsters.count;
    } else {
        return 0;
    }
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterTable]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monsterCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"monsterCell"];
        }
        
        Monster *monster = [_displayedMonsters objectAtIndex:indexPath.row];
        cell.textLabel.text = monster.monsterName;
        cell.imageView.image = [UIImage imageNamed:monster.iconName];
        return cell;
    } else {
        return nil;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterTable]) {
        Monster *monster = _displayedMonsters[indexPath.row];
        _selectedMonster = monster;
        MonsterDetailViewController *mDVC = [[MonsterDetailViewController alloc] init];
        mDVC.selectedMonster = _selectedMonster;
        mDVC.heightDifference = _heightDifference;
        mDVC.dbEngine = _dbEngine;
        [self.navigationController pushViewController:mDVC animated:YES];
        
    }
}

#pragma mark - Helper Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews {
    CGRect vcFrame = self.view.frame;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    int heightdifference = navBar.frame.size.height + statusBar.size.height;

    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference, vcFrame.size.width, 49);
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference + tabBarFrame.size.height, vcFrame.size.width, 44);
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - (searchBarFrame.size.height + tabBarFrame.size.height + statusBar.size.height));

    _monstersTab.frame = tabBarFrame;
    _monsterSearch.frame = searchBarFrame;
    _monsterTable.frame = tableWithSearch;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

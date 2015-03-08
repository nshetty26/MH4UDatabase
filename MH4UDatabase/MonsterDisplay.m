//
//  MonsterDisplay.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/7/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "DetailViewController.h"
#import "MonsterDisplay.h"

@interface MonsterDisplay()
@property (nonatomic) NSArray *displayedMonsters;
@property (nonatomic) UITableView *monsterTable;
@end

@implementation MonsterDisplay

-(void)setupMonsterDisplay {
    _displayedMonsters = _allMonstersArray;
    UITabBar *monstersTab = [[UITabBar alloc] initWithFrame:_dVC.tabBarFrame];
    UITabBarItem *largeMonsters = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:2];
    UITabBarItem *smallMonsters = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:3];
    UITabBarItem *allMonsters = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    monstersTab.delegate = self;
    [monstersTab setItems:@[allMonsters, largeMonsters, smallMonsters]];
    [monstersTab setSelectedItem:allMonsters];
    _monsterTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _monsterTable.dataSource = self;
    [_dVC.view addSubview:_monsterTable];
    [_dVC.view addSubview:monstersTab];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 1:
            _displayedMonsters = _allMonstersArray;
            break;
        case 2:
            _displayedMonsters = [_allMonstersArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                Monster *mon = (Monster *)evaluatedObject;
                return [mon.monsterClass isEqualToString:@"Boss"];}]];
            break;
        case 3:
            _displayedMonsters = [_allMonstersArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                Monster *mon = (Monster *)evaluatedObject;
                return [mon.monsterClass isEqualToString:@"Minion"];}]];
            break;
        default:
            break;
    }
    
    [_monsterTable reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _displayedMonsters.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"monsterCell"];
    Monster *monster = [_displayedMonsters objectAtIndex:indexPath.row];
    cell.textLabel.text = monster.monsterName;
    return cell;
}

@end

@implementation Monster

@end

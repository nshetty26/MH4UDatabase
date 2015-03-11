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
@property (nonatomic) UITableView *monsterTable;
@property (nonatomic) UITableView *monsterDetailTable;
@property (nonatomic) UITabBar *monstersTab;
@property (nonatomic) Monster *selectedMonster;

@end

@implementation MonstersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _displayedMonsters = _allMonstersArray;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Monsters" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference + tabBarFrame.size.height, vcFrame.size.width, 44);
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    
    _monstersTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
    
    
    UITabBarItem *allMonsters = [[UITabBarItem alloc] initWithTitle:@"All" image:nil tag:1];
    UITabBarItem *largeMonsters = [[UITabBarItem alloc] initWithTitle:@"Large" image:nil tag:2];
    UITabBarItem *smallMonsters = [[UITabBarItem alloc] initWithTitle:@"Small" image:nil tag:3];
    
    _monstersTab.delegate = self;
    [_monstersTab setItems:@[allMonsters, largeMonsters, smallMonsters]];
    [_monstersTab setSelectedItem:allMonsters];
    _monsterTable = [[UITableView alloc] initWithFrame:tableWithSearch];
    _monsterTable.dataSource = self;
    _monsterTable.delegate = self;

    _monsterDetailTable.dataSource = self;
    _monsterDetailTable.delegate = self;
    
    [self.view addSubview:_monsterTable];
    [self.view addSubview:_monstersTab];
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
    if ([tableView isEqual:_monsterTable]) {
        return _displayedMonsters.count;
    } else if ([tableView isEqual:_monsterDetailTable]){
        return _selectedMonster.monsterDetailDamage.count;
    } else {
        return 0;
    }
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterTable]) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"monsterCell"];
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
        [self populateDetailForMonster:monster];
        _selectedMonster = monster;
        MonsterDetailViewController *mDVC = [[MonsterDetailViewController alloc] init];
        mDVC.selectedMonster = _selectedMonster;
        mDVC.heightDifference = _heightDifference;
        [self.navigationController pushViewController:mDVC animated:YES];
        
    }
}

-(void)populateDetailForMonster:(Monster*) monster {
    [_dbEngine getDetailsForMonster:monster];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

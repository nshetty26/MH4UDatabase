//
//  MonsterViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/3/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MonsterViewController.h"
#import <FMDB.h>

@interface MonsterViewController ()
@property (nonatomic) NSString *mhDBPath;
@property (nonatomic) FMDatabase *mh4DB;
@property (nonatomic) NSArray *displayedMonsters;
@property (nonatomic) UITableView *monsterTable;
@property (nonatomic) NSMutableArray *allMonsterArray;

@end

@implementation MonsterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITabBar *monstersTab = [[UITabBar alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 49)];
    UITabBarItem *largeMonsters = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:2];
    UITabBarItem *smallMonsters = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:3];
    UITabBarItem *allMonsters = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    monstersTab.delegate = self;
    [monstersTab setItems:@[allMonsters, largeMonsters, smallMonsters]];
    [monstersTab setSelectedItem:allMonsters];
    _monsterTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 49, self.view.frame.size.width, self.view.frame.size.height)];
    //[self databaseOperationWithWhereClause:@"1=1"];
    [self populateAllMonsters];
    _monsterTable.dataSource = self;
    [self.view addSubview:_monsterTable];
    [self.view addSubview:monstersTab];
    // Do any additional setup after loading the view.
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 1:
            _displayedMonsters = _allMonsterArray;
            break;
        case 2:
            _displayedMonsters = [_allMonsterArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                Monster *mon = (Monster *)evaluatedObject;
                return [mon.monsterClass isEqualToString:@"Boss"];}]];
            break;
        case 3:
            _displayedMonsters = [_allMonsterArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                Monster *mon = (Monster *)evaluatedObject;
                return [mon.monsterClass isEqualToString:@"Minion"];}]];
            break;
        default:
            break;
    }
    
    [_monsterTable reloadData];
}
-(void)populateAllMonsters {
    if (_allMonsterArray == nil) {
        _allMonsterArray = [[NSMutableArray alloc] init];
    }
    
    
    NSString *monsterQuery = [NSString stringWithFormat:@"SELECT * FROM Monsters"];
    _mhDBPath = [[NSBundle mainBundle] pathForResource:@"mh4u" ofType:@".db"];
    _mh4DB = [FMDatabase databaseWithPath:_mhDBPath];
    
    if (![_mh4DB open]) {
        return;
    } else {
        FMResultSet *s = [_mh4DB executeQuery:monsterQuery];
        while ([s next]) {
            Monster *monster = [[Monster alloc] init];
            monster.monsterID = [s intForColumn:@"_id"];
            monster.monsterClass = [s stringForColumn:@"class"];
            monster.monsterName = [s stringForColumn:@"name"];
            monster.trait = [s stringForColumn:@"trait"];
            monster.iconName = [s stringForColumn:@"icon_name"];
            [_allMonsterArray addObject:monster];
        }
    }
    [_allMonsterArray sortUsingComparator:^NSComparisonResult(id monster1, id monster2){
        Monster *mon1 = (Monster *)monster1;
        Monster *mon2 = (Monster *)monster2;
        return [(NSString *) mon1.monsterName compare:mon2.monsterName options:NSNumericSearch];
    }];
    
    _displayedMonsters = _allMonsterArray;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _allMonsterArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"monsterCell"];
    Monster *monster = [_displayedMonsters objectAtIndex:indexPath.row];
    cell.textLabel.text = monster.monsterName;
    return cell;
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

@implementation Monster

@end

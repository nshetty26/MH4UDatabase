//
//  ArmorViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/4/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ArmorViewController.h"
#import <FMDB.h>

@interface ArmorViewController ()
@property (nonatomic) NSString *mhDBPath;
@property (nonatomic) FMDatabase *mh4DB;
@property (nonatomic) NSArray *displayedArmor;
@property (nonatomic) UITableView *armorTable;
@property (nonatomic) NSMutableArray *allArmorArray;
@end

@implementation ArmorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITabBar *monstersTab = [[UITabBar alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 49)];
    UITabBarItem *blade = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:2];
    UITabBarItem *gunner = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:3];
    UITabBarItem *allArmor = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    monstersTab.delegate = self;
    [monstersTab setItems:@[allArmor, blade, gunner]];
    [monstersTab setSelectedItem:allArmor];
    _armorTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 49, self.view.frame.size.width, self.view.frame.size.height)];
    [self populateAllMonsters];
    _armorTable.dataSource = self;
    [self.view addSubview:_armorTable];
    [self.view addSubview:monstersTab];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 1:
            _displayedArmor = _allArmorArray;
            break;
        case 2:
            _displayedArmor = [_allArmorArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                Armor *armor = (Armor *)evaluatedObject;
                return [armor.hunterType isEqualToString:@"Blade"];}]];
            break;
        case 3:
            _displayedArmor = [_allArmorArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                Armor *armor = (Armor *)evaluatedObject;
                return [armor.hunterType isEqualToString:@"Gunner"];}]];
            break;
        default:
            break;
    }
    
    [_armorTable reloadData];
}
-(void)populateAllMonsters {
    if (_allArmorArray == nil) {
        _allArmorArray = [[NSMutableArray alloc] init];
    }
    
    
    NSString *monsterQuery = [NSString stringWithFormat:@"SELECT armor._id, items.name, armor.slot, armor.defense, armor.max_defense, armor.fire_res, armor.thunder_res, armor.dragon_res, armor.water_res, armor.ice_res, armor.gender, armor.hunter_type, armor.num_slots from armor INNER JOIN items on armor._id = items._id"];
    _mhDBPath = [[NSBundle mainBundle] pathForResource:@"mh4u" ofType:@".db"];
    _mh4DB = [FMDatabase databaseWithPath:_mhDBPath];
    
    if (![_mh4DB open]) {
        return;
    } else {
        FMResultSet *s = [_mh4DB executeQuery:monsterQuery];
        while ([s next]) {
            Armor *armor = [[Armor alloc] init];
            armor.armorID = [s intForColumn:@"_id"];
            armor.name = [s stringForColumn:@"name"];
            armor.slot = [s stringForColumn:@"slot"];
            armor.defense = [s intForColumn:@"defense"];
            armor.maxDefense = [s intForColumn:@"max_defense"];
            armor.fireResistance = [s intForColumn:@"fire_res"];
            armor.thunderResistance = [s intForColumn:@"thunder_res"];
            armor.dragonResistance = [s intForColumn:@"dragon_res"];
            armor.waterResistance = [s intForColumn:@"water_res"];
            armor.iceResistance = [s intForColumn:@"ice_res"];
            armor.gender = [s stringForColumn:@"gender"];
            armor.hunterType = [s stringForColumn:@"hunter_type"];
            armor.numSlots = [s intForColumn:@"num_slots"];
            
//            Monster *monster = [[Monster alloc] init];
//            monster.monsterID = [s intForColumn:@"_id"];
//            monster.monsterClass = [s stringForColumn:@"class"];
//            monster.monsterName = [s stringForColumn:@"name"];
//            monster.trait = [s stringForColumn:@"trait"];
//            monster.iconName = [s stringForColumn:@"icon_name"];
            [_allArmorArray addObject:armor];
        }
    }
//    [_allArmorArray sortUsingComparator:^NSComparisonResult(id monster1, id monster2){
//        Monster *mon1 = (Monster *)monster1;
//        Monster *mon2 = (Monster *)monster2;
//        return [(NSString *) mon1.monsterName compare:mon2.monsterName options:NSNumericSearch];
//    }];
    
    _displayedArmor = _allArmorArray;
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _allArmorArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"armorCell"];
    Armor *armor = [_displayedArmor objectAtIndex:indexPath.row];
    //cell.textLabel.text = monster.monsterName;
    cell.textLabel.text = armor.name;
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

@implementation Armor

@end

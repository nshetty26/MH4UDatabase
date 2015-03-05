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
@property (nonatomic) ArmorStats *statView;
@property (nonatomic) UITabBar *armorTab;
@end

@implementation ArmorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _armorTab = [[UITabBar alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 49)];
    UITabBarItem *blade = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:2];
    UITabBarItem *gunner = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:3];
    UITabBarItem *allArmor = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    _armorTab.delegate = self;
    [_armorTab setItems:@[allArmor, blade, gunner]];
    [_armorTab setSelectedItem:allArmor];
    _armorTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 49, self.view.frame.size.width, self.view.frame.size.height)];
    [self populateAllMonsters];
    _armorTable.dataSource = self;
    _armorTable.delegate = self;

    [self.view addSubview:_armorTable];
    [self.view addSubview:_armorTab];


}

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

-(FMResultSet *)DBquery:(NSString *)query
{
    _mhDBPath = [[NSBundle mainBundle] pathForResource:@"mh4u" ofType:@".db"];
    _mh4DB = [FMDatabase databaseWithPath:_mhDBPath];
    
    if (![_mh4DB open]) {
        return nil;
    } else {
        FMResultSet *s = [_mh4DB executeQuery:query];
        return s;
    }
}
-(void)populateAllMonsters {
    if (_allArmorArray == nil) {
        _allArmorArray = [[NSMutableArray alloc] init];
    }

    NSString *monsterQuery = [NSString stringWithFormat:@"SELECT armor._id, items.name, armor.slot, armor.defense, armor.max_defense, items.rarity, items.buy, armor.fire_res, armor.thunder_res, armor.dragon_res, armor.water_res, armor.ice_res, armor.gender, armor.hunter_type, armor.num_slots from armor INNER JOIN items on armor._id = items._id"];
        FMResultSet *s = [self DBquery:monsterQuery];
    
    if (s) {
        while ([s next]) {
            Armor *armor = [[Armor alloc] init];
            armor.armorID = [s intForColumn:@"_id"];
            armor.name = [s stringForColumn:@"name"];
            armor.slot = [s stringForColumn:@"slot"];
            armor.rarity = [s intForColumn:@"rarity"];
            armor.price = [s intForColumn:@"buy"];
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
            [_allArmorArray addObject:armor];
        }
    }
    
    _displayedArmor = _allArmorArray;
    
    
}

-(void)closeDB
{
    if (_mh4DB) {
        _mh4DB = nil;
    }
}

-(NSDictionary *)getArmorSkillsfor:(int)armorID{
    NSString *skillQuery = [NSString stringWithFormat:@"SELECT skill_trees._id, skill_trees.name, item_to_skill_tree.point_value FROM items INNER JOIN item_to_skill_tree on items._id = item_to_skill_tree.item_id INNER JOIN skill_trees on item_to_skill_tree.skill_tree_id = skill_trees._id where items._id = %i", armorID];

    NSMutableDictionary *skillTreeDictionary = [[NSMutableDictionary alloc] init];
    FMResultSet *s = [self DBquery:skillQuery];
    if (s) {
        while ([s next]) {
            int skillTreeID = [s intForColumn:@"_id"];
            NSString *skillName = [s stringForColumn:@"name"];
            int value = [s intForColumn:@"point_value"];
            [skillTreeDictionary setObject:@[skillName, [NSNumber numberWithInt:value]] forKey:[NSNumber numberWithInt:skillTreeID]];
        }
    } else {
        return nil;
    }
    
    return skillTreeDictionary;
}

-(NSDictionary *)getComponentsfor:(int)armorID {
    //TODO: Work out duplicate components
    NSString *componentQuery = [NSString stringWithFormat:@"Select components.component_item_id, items.name from components Inner JOIN items on components.component_item_id = items._id where created_item_id = %i", armorID];
    NSMutableDictionary *componentDictionary = [[NSMutableDictionary alloc] init];
    FMResultSet *s = [self DBquery:componentQuery];
    if (s) {
        while ([s next]) {
            int componentID = [s intForColumn:@"component_item_id"];
            NSString *name = [s stringForColumn:@"name"];
            [componentDictionary setObject:@[name] forKey:[NSNumber numberWithInt:componentID]];
        }
    } else {
        return nil;
    }
    
    return componentDictionary;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _allArmorArray.count;
}

-(void)closeArmorStats {
    [_statView removeFromSuperview];
    _statView = nil;
    [self.view addSubview:_armorTable];
    [self.view addSubview:_armorTab];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"armorCell"];
    Armor *armor = [_displayedArmor objectAtIndex:indexPath.row];
    //cell.textLabel.text = monster.monsterName;
    cell.textLabel.text = armor.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_armorTable removeFromSuperview];
    Armor *armor = _displayedArmor[indexPath.row];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeArmorStats)];
    self.navigationItem.rightBarButtonItem = close;
    _statView = [[[NSBundle mainBundle] loadNibNamed:@"ArmorView" owner:self options:nil] lastObject];
    NSDictionary *skillDictionary = [self getArmorSkillsfor:armor.armorID];
    NSDictionary *componentDictionary = [self getComponentsfor:armor.armorID];
    [_statView populateArmor:armor];
    [self.view addSubview:_statView];
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

@implementation ArmorStats

-(void)populateArmor:(Armor *)armor
{
    _armorName.text = armor.name;
    _IconImageView = nil;
    _armorPart.text = armor.slot;
    _armorSlots.text = [NSString stringWithFormat:@"%i", armor.numSlots];
    _armorRarity.text = [NSString stringWithFormat:@"%i", armor.rarity];
    _armorPrice.text = [NSString stringWithFormat:@"%i", armor.price];;
    _armorFR.text = [NSString stringWithFormat:@"%i", armor.fireResistance];
    _armorWR.text= [NSString stringWithFormat:@"%i", armor.waterResistance];
    _armorIR.text = [NSString stringWithFormat:@"%i", armor.iceResistance];
    _armorTR.text =[NSString stringWithFormat:@"%i", armor.thunderResistance];
    _armorDR.text = [NSString stringWithFormat:@"%i", armor.dragonResistance];
}

@end

@implementation Armor

@end

//
//  MonsterDisplay.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/7/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "DetailViewController.h"
#import "MH4UDBEngine.h"
#import "MonsterDisplay.h"

@interface MonsterDisplay()
@property (nonatomic) NSArray *displayedMonsters;
@property (nonatomic) UITableView *monsterTable;
@property (nonatomic) UITableView *monsterDetailTable;
@property (nonatomic) UITabBar *monstersTab;
@property (nonatomic) MonsterDetailView *monsterDetailView;
@property (nonatomic) Monster *selectedMonster;
@end

@implementation MonsterDisplay

-(void)setupMonsterDisplay {
    _displayedMonsters = _allMonstersArray;
    _monstersTab = [[UITabBar alloc] initWithFrame:_dVC.tabBarFrame];
    UITabBarItem *allMonsters = [[UITabBarItem alloc] initWithTitle:@"All" image:nil tag:1];
    UITabBarItem *largeMonsters = [[UITabBarItem alloc] initWithTitle:@"Large" image:nil tag:2];
    UITabBarItem *smallMonsters = [[UITabBarItem alloc] initWithTitle:@"Small" image:nil tag:3];
    _monstersTab.delegate = self;
    [_monstersTab setItems:@[allMonsters, largeMonsters, smallMonsters]];
    [_monstersTab setSelectedItem:allMonsters];
    _monsterTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _monsterTable.dataSource = self;
    _monsterTable.delegate = self;
    
    //_monsterDetailView = [[[NSBundle mainBundle] loadNibNamed:@"MonsterDetail" owner:self options:nil] lastObject];
    _monsterDetailTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _monsterDetailTable.dataSource = self;
    _monsterDetailTable.delegate = self;
    
    [_dVC.view addSubview:_monsterTable];
    [_dVC.view addSubview:_monstersTab];
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
        return cell;
    } else if ([tableView isEqual:_monsterDetailTable]) {
        MonsterDetailCell *mDC = [tableView dequeueReusableCellWithIdentifier:@"monsterDetailCell"];
        if (!mDC) {
            [tableView registerNib:[UINib nibWithNibName:@"MonsterDetailCell"  bundle:nil] forCellReuseIdentifier:@"monsterDetailCell"];
            mDC = [tableView dequeueReusableCellWithIdentifier:@"monsterDetailCell"];
        }
        return mDC;
    } else {
        return nil;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterTable]) {
        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeDetailedView)];
        _dVC.navigationItem.rightBarButtonItem = close;
        Monster *monster = _displayedMonsters[indexPath.row];
        [self populateDetailForMonster:monster];
        _selectedMonster = monster;
        [_dVC.view addSubview:_monsterDetailTable];
       
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(MonsterDetailCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterDetailTable]) {
        MonsterDamage *md = _selectedMonster.monsterDetailDamage[indexPath.row];
        cell.bodyPart.text = [NSString stringWithFormat:@"%@", md.bodyPart];
        cell.cutLabel.text = [NSString stringWithFormat:@"%i", md.cutDamage];
        cell.impactLabel.text = [NSString stringWithFormat:@"%i", md.impactDamage];
        cell.shotLabel.text = [NSString stringWithFormat:@"%i", md.shotDamage];
        cell.stunLabel.text = [NSString stringWithFormat:@"%i", md.stun];
        cell.fireLabel.text = [NSString stringWithFormat:@"%i", md.fireDamage];
        cell.waterLabel.text = [NSString stringWithFormat:@"%i", md.waterDamage];
        cell.iceLabel.text = [NSString stringWithFormat:@"%i", md.iceDamage];
        cell.thunderLabel.text = [NSString stringWithFormat:@"%i", md.thunderDamage];
        cell.dragonLabel.text = [NSString stringWithFormat:@"%i", md.dragonDamage];
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterDetailTable]) {
        return 70;
    } else {
        return 45;
    }
}

-(void)closeDetailedView {
    [self removeViewsFromDetail];
    [_dVC.view addSubview:_monsterTable];
    [_dVC.view addSubview:_monstersTab];
}

-(void)removeViewsFromDetail {
    NSArray *allViews = @[_monsterDetailTable, _monstersTab, _monsterTable];
    
    for (UIView *view in allViews) {
        if (view.superview) {
            [view removeFromSuperview];
        }
    }
}



@end

@implementation Monster

@end

@implementation MonsterDamage

@end

@implementation MonsterDetailView

@end

@implementation MonsterDetailCell

@end

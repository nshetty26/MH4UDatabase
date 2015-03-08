//
//  ArmorDisplay.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/7/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ArmorDisplay.h"
#import "MH4UDBEngine.h"
#import "DetailViewController.h"

@interface ArmorDisplay ()
@property (strong, nonatomic) NSArray *displayedArmor;
@property (strong, nonatomic) UITableView *armorTable;
@property (strong, nonatomic) ArmorView *statView;
@property (strong, nonatomic) UITabBar *armorFilterTab;
@property (strong, nonatomic) UITabBar *armorDetailTab;
@property (strong, nonatomic) UITableView *skillTable;
@property (strong, nonatomic) UITableView *componentTable;
@property (strong, nonatomic) Armor *selectedArmor;
@end

@implementation ArmorDisplay

- (void)setupArmorView{
    _displayedArmor = _allArmorArray;
    _armorFilterTab = [[UITabBar alloc] initWithFrame:_dVC.tabBarFrame];
    UITabBarItem *blade = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:2];
    UITabBarItem *gunner = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:3];
    UITabBarItem *allArmor = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    _armorFilterTab.delegate = self;
    [_armorFilterTab setItems:@[allArmor, blade, gunner]];
    [_armorFilterTab setSelectedItem:allArmor];
    
    _armorDetailTab = [[UITabBar alloc] initWithFrame:_dVC.tabBarFrame];
    UITabBarItem *statSheet = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:4];
    UITabBarItem *skillSheet = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:5];
    UITabBarItem *componentSheet = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:6];
    _armorDetailTab.delegate = self;
    [_armorDetailTab setItems:@[statSheet, skillSheet, componentSheet]];
    [_armorDetailTab setSelectedItem:statSheet];
    
    
    
    _armorTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _armorTable.dataSource = self;
    _armorTable.delegate = self;
    
    _skillTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _skillTable.dataSource = self;
    _skillTable.delegate = self;
    _skillTable.frame = _dVC.tableFrame;
    
    _componentTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _componentTable.delegate = self;
    _componentTable.dataSource = self;
    
    [_dVC.view addSubview:_armorTable];
    [_dVC.view addSubview:_armorFilterTab];
    
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
        case 4:
            if (_componentTable.superview != nil) {
                [_componentTable removeFromSuperview];
            }
            
            if (_skillTable.superview != nil) {
                [_skillTable removeFromSuperview];
            }
            
            [_dVC.view addSubview:_statView];
            [_dVC.view addSubview:_armorDetailTab];
            break;
        case 5:
            if (_componentTable.superview != nil) {
                [_componentTable removeFromSuperview];
            }
            
            if (_statView.superview != nil) {
                [_statView removeFromSuperview];
            }
            [_dVC.view addSubview:_skillTable];
            [_dVC.view addSubview:_armorDetailTab];
            break;
        case 6:
            if (_skillTable.superview != nil) {
                [_skillTable removeFromSuperview];
            }
            if (_statView.superview != nil) {
                [_statView removeFromSuperview];
            }
            [_dVC.view addSubview:_componentTable];
            [_dVC.view addSubview:_armorDetailTab];
            break;
        default:
            break;
    }
    [tabBar setSelectedItem:item];
    if ([tabBar isEqual:_armorFilterTab]) {
        [_armorTable reloadData];
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_armorTable]) {
        return _displayedArmor.count;
    } else if ([tableView isEqual:_componentTable]) {
        return _selectedArmor.componentArray.count;
    } else if ([tableView isEqual:_skillTable]) {
        return _selectedArmor.skillsArray.count;
    } else  {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"armorCell"];
    if ([tableView isEqual:_armorTable]) {
        Armor *armor = [_displayedArmor objectAtIndex:indexPath.row];
        cell.textLabel.text = armor.name;
    } else if ([tableView isEqual:_skillTable]) {
        NSArray *skillArray = _selectedArmor.skillsArray[indexPath.row];
        cell.textLabel.text = [skillArray objectAtIndex:1];
    } else if ([tableView isEqual:_componentTable]) {
        NSArray *componentArray = _selectedArmor.componentArray[indexPath.row];
        cell.textLabel.text = [componentArray objectAtIndex:1];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_armorTable]) {
        [_armorTable removeFromSuperview];
        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeArmorStats)];
        Armor *armor = _displayedArmor[indexPath.row];
        _selectedArmor = armor;
        [_dbEngine populateArmor:armor];
        _dVC.navigationItem.rightBarButtonItem = close;
        _statView = [[[NSBundle mainBundle] loadNibNamed:@"ArmorView" owner:self options:nil] lastObject];
        [_statView populateArmor:armor];
        [_dVC.view addSubview:_statView];
        _statView.frame = _dVC.tableFrame;
        [_armorDetailTab setSelectedItem:[_armorDetailTab.items firstObject]];
        [_dVC.view addSubview:_armorDetailTab];
    }
    
}

-(void)closeArmorStats {
    [_statView removeFromSuperview];
    _statView = nil;
    [_dVC.view addSubview:_armorTable];
    [_dVC.view addSubview:_armorFilterTab];
    _dVC.navigationItem.rightBarButtonItems = nil;
}

@end

@implementation ArmorView

-(void)populateArmor:(Armor *)armor
{
    _armorName.text = armor.name;
    _IconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png", armor.slot, armor.rarity]];
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
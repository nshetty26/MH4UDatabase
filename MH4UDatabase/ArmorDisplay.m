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
@property (strong, nonatomic) NSArray *headArray;
@property (strong, nonatomic) NSArray *bodyArray;
@property (strong, nonatomic) NSArray *armArray;
@property (strong, nonatomic) NSArray *waitArray;
@property (strong, nonatomic) NSArray *legArray;
@property (strong, nonatomic) UITableView *armorTable;
@property (strong, nonatomic) ArmorView *statView;
@property (strong, nonatomic) UITabBar *armorFilterTab;
@property (strong, nonatomic) UITabBar *armorDetailTab;
@property (strong, nonatomic) UITableView *skillTable;
@property (strong, nonatomic) UITableView *componentTable;
@property (strong, nonatomic) Armor *selectedArmor;
@property (strong, nonatomic) UISearchBar *armorSearch;
@end

@implementation ArmorDisplay

- (void)setupArmorView{
    _displayedArmor = _allArmorArray;
    _armorFilterTab = [[UITabBar alloc] initWithFrame:_dVC.tabBarFrame];
    UITabBarItem *allArmor = [[UITabBarItem alloc] initWithTitle:@"Both" image:nil tag:1];
    UITabBarItem *blade = [[UITabBarItem alloc] initWithTitle:@"Blademaster" image:nil tag:2];
    UITabBarItem *gunner = [[UITabBarItem alloc] initWithTitle:@"Gunner" image:nil tag:3];
    _armorFilterTab.delegate = self;
    [_armorFilterTab setItems:@[allArmor, blade, gunner]];
    [_armorFilterTab setSelectedItem:allArmor];
    
    _armorDetailTab = [[UITabBar alloc] initWithFrame:_dVC.tabBarFrame];
    UITabBarItem *statSheet = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:4];
    UITabBarItem *skillSheet = [[UITabBarItem alloc] initWithTitle:@"Skills" image:nil tag:5];
    UITabBarItem *componentSheet = [[UITabBarItem alloc] initWithTitle:@"Components" image:nil tag:6];
    
    _armorDetailTab.delegate = self;
    [_armorDetailTab setItems:@[statSheet, skillSheet, componentSheet]];
    [_armorDetailTab setSelectedItem:statSheet];
    
    CGRect vcFrame = _dVC.view.frame;
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _dVC.heightDifference + _armorFilterTab.frame.size.height, vcFrame.size.width, 44);
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _armorFilterTab.frame.size.height + _dVC.heightDifference + 44, vcFrame.size.width, vcFrame.size.height);
    
    _armorSearch = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _armorSearch.delegate = self;
    
    _armorTable = [[UITableView alloc] initWithFrame:tableWithSearch];
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
    [_dVC.view addSubview:_armorSearch];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        _displayedArmor = _allArmorArray;
        [_armorTable reloadData];
        return;
    }
    NSArray *searchedArmor = [_allArmorArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        Armor *armor = (Armor*)evaluatedObjected;
        if ([armor.name.lowercaseString containsString:searchText.lowercaseString]) {
            return YES;
        } else {
            return NO;
        }
        
    }]];
    
    _displayedArmor = searchedArmor;
    [_armorTable reloadData];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([tabBar isEqual:_armorFilterTab]) {
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
        
    } else if ([tabBar isEqual:_armorDetailTab]) {
        [self removeViewsFromDetail];
        switch (item.tag) {
            case 4:
                [_dVC.view addSubview:_statView];
                break;
            case 5:
                [_dVC.view addSubview:_skillTable];
                break;
            case 6:
                [_dVC.view addSubview:_componentTable];
                break;
            default:
                break;
        }
        
        [_dVC.view addSubview:_armorDetailTab];

    }
    [tabBar setSelectedItem:item];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:_armorTable]) {
        return 5;
    } else {
        return 1;
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_armorTable]) {
        switch (section) {
            case 1:
                return @"Head";
                break;
            case 2:
                return @"Body";
                break;
            case 3:
                return @"Arms";
                break;
            case 4:
                return @"Waist";
                break;
            case 5:
                return @"Legs";
                break;
            default:
                break;
        }
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([tableView isEqual:_armorTable]) {
        NSString *type;
        switch (section) {
            case 1:
                type = @"Head";
                break;
            case 2:
                type = @"Body";
                break;
            case 3:
                type = @"Arms";
                break;
            case 4:
                type = @"Waist";
                break;
            case 5:
                type = @"Legs";
                break;
            default:
                break;
        }

        
        NSArray *typeArray = [_displayedArmor filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                Armor *armor = (Armor *)evaluatedObject;
                return [armor.slot isEqualToString:type];}]];
        
        switch (section) {
            case 1:
                _headArray = typeArray;
                break;
            case 2:
                _bodyArray = typeArray;
                break;
            case 3:
                _armArray = typeArray;
                break;
            case 4:
                _waitArray = typeArray;
                break;
            case 5:
                _legArray = typeArray;
                break;
            default:
                break;
        }
        
        return typeArray.count;
    }
    
    else if ([tableView isEqual:_componentTable]) {
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
        //Armor *armor = [_displayedArmor objectAtIndex:indexPath.row];
        Armor *armor = [self returnArmorAtIndexPath:indexPath];
        cell.textLabel.text = armor.name;
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",armor.slot, armor.rarity]];
        
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

        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeArmorStats)];
        Armor *armor = [self returnArmorAtIndexPath:indexPath];
        _selectedArmor = armor;
        [_dbEngine populateArmor:armor];
        _dVC.navigationItem.rightBarButtonItem = close;
        _statView = [[[NSBundle mainBundle] loadNibNamed:@"ArmorView" owner:self options:nil] lastObject];
        _statView.frame = _dVC.tableFrame;
        [_statView populateArmor:armor];
        [self removeViewsFromDetail];
        [_dVC.view addSubview:_statView];
       // [_armorDetailTab setSelectedItem:[_armorDetailTab.items firstObject]];
        [_dVC.view addSubview:_armorDetailTab];
    }
    
}

-(Armor *)returnArmorAtIndexPath:(NSIndexPath *)indexPath {
    Armor *armor;
    switch (indexPath.section) {
        case 1:
            armor = [_headArray objectAtIndex:indexPath.row];
            break;
        case 2:
            armor = [_bodyArray objectAtIndex:indexPath.row];
            break;
        case 3:
            armor = [_armArray objectAtIndex:indexPath.row];
            break;
        case 4:
            armor = [_waitArray objectAtIndex:indexPath.row];
            break;
        case 5:
            armor = [_legArray objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
    return armor;

}

-(void)closeArmorStats {
    [self removeViewsFromDetail];
    _statView = nil;
    [_dVC.view addSubview:_armorTable];
    [_dVC.view addSubview:_armorFilterTab];
    [_dVC.view addSubview:_armorSearch];
    _dVC.navigationItem.rightBarButtonItems = nil;
}

-(void)removeViewsFromDetail {
    NSArray *allTables = @[_statView, _skillTable, _componentTable, _armorTable, _armorSearch];
    for (UIView *view in allTables) {
        if (view.superview != nil) {
            [view removeFromSuperview];
        }
    }
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
    _armorDefense.text = [NSString stringWithFormat:@"(min) %i - %i (max)", armor.defense, armor.maxDefense];
    _armorFR.text = [NSString stringWithFormat:@"%i", armor.fireResistance];
    _armorWR.text= [NSString stringWithFormat:@"%i", armor.waterResistance];
    _armorIR.text = [NSString stringWithFormat:@"%i", armor.iceResistance];
    _armorTR.text =[NSString stringWithFormat:@"%i", armor.thunderResistance];
    _armorDR.text = [NSString stringWithFormat:@"%i", armor.dragonResistance];
    
    
}

@end

@implementation Armor

@end
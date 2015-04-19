//
//  ArmorsViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ArmorsViewController.h"
#import "ArmorSetDetailViewController.h"
#import "ArmorDetailViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface ArmorsViewController ()
@property (strong, nonatomic) UITableView *armorTable;
@property (strong, nonatomic) UITabBar *armorFilterTab;
@property (strong, nonatomic) NSArray *displayedArmor;
@property (strong, nonatomic) NSArray *headArray;
@property (strong, nonatomic) NSArray *bodyArray;
@property (strong, nonatomic) NSArray *armArray;
@property (strong, nonatomic) NSArray *waitArray;
@property (strong, nonatomic) NSArray *legArray;
@property (strong, nonatomic) Armor *selectedArmor;
@property (strong, nonatomic) UISearchBar *armorSearch;
@end

@implementation ArmorsViewController

#pragma mark - Setup Views
-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_armorFilterTab) {
        _armorFilterTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
        UITabBarItem *allArmor = [[UITabBarItem alloc] initWithTitle:@"Both" image:nil tag:1];
        UITabBarItem *blade = [[UITabBarItem alloc] initWithTitle:@"Blademaster" image:nil tag:2];
        UITabBarItem *gunner = [[UITabBarItem alloc] initWithTitle:@"Gunner" image:nil tag:3];
        
        _armorFilterTab.delegate = self;
        [_armorFilterTab setItems:@[allArmor, blade, gunner]];
        [_armorFilterTab setSelectedItem:allArmor];
    }
}

-(void)setUpViewsWithFrame:(CGRect)tableFrame {
    _armorTable = [[UITableView alloc] initWithFrame:tableFrame];
    _armorTable.dataSource = self;
    _armorTable.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.title = NSLocalizedString(@"Armor", @"Armor");
    
    _allArmorArray = [_dbEngine retrieveArmor:nil];
    _displayedArmor = _allArmorArray;
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference + tabBarFrame.size.height, vcFrame.size.width, 44);
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    
    [self setUpTabBarWithFrame:tabBarFrame];
    [self setUpViewsWithFrame:tableWithSearch];
    
    _armorSearch = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _armorSearch.delegate = self;
    
    [self.view addSubview:_armorTable];
    [self.view addSubview:_armorFilterTab];
    [self.view addSubview:_armorSearch];


    // Do any additional setup after loading the view.
}

#pragma mark - Search Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_armorSearch setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showallArmor];
        return;
    }
    NSArray *searchedArmor = [_allArmorArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        Armor *armor = (Armor*)evaluatedObjected;
        if (!([armor.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
            return YES;
        } else {
            return NO;
        }
        
    }]];
    
    _displayedArmor = searchedArmor;
    [_armorTable reloadData];
}

-(void)showallArmor {
    _displayedArmor = _allArmorArray;
    [_armorTable reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO];
    [self showallArmor];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

#pragma mark - Tab Bar Methods
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
    }
}

#pragma - Mark Tableview Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:_armorTable]) {
        return 5;
    } else {
        return 0;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_armorTable]) {
        switch (section) {
            case 0:
                return @"Head";
                break;
            case 1:
                return @"Body";
                break;
            case 2:
                return @"Arms";
                break;
            case 3:
                return @"Waist";
                break;
            case 4:
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
            case 0:
                type = @"Head";
                break;
            case 1:
                type = @"Body";
                break;
            case 2:
                type = @"Arms";
                break;
            case 3:
                type = @"Waist";
                break;
            case 4:
                type = @"Legs";
                break;
            default:
                break;
        }
        
        
        NSArray *typeArray = [_displayedArmor filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
            Armor *armor = (Armor *)evaluatedObject;
            return [armor.slot isEqualToString:type];}]];
        
        switch (section) {
            case 0:
                _headArray = typeArray;
                break;
            case 1:
                _bodyArray = typeArray;
                break;
            case 2:
                _armArray = typeArray;
                break;
            case 3:
                _waitArray = typeArray;
                break;
            case 4:
                _legArray = typeArray;
                break;
            default:
                break;
        }
        
        return typeArray.count;
    } else {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"armorCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"armorCell"];
    }

    if ([tableView isEqual:_armorTable]) {
        Armor *armor = [self returnArmorAtIndexPath:indexPath];
        cell.textLabel.text = armor.name;
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",[armor.slot lowercaseString], armor.rarity]];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        return cell;
    } else {
        return nil;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_armorTable]) {
        Armor *armor = [self returnArmorAtIndexPath:indexPath];
        _selectedArmor = armor;
        ArmorDetailViewController *aDVC = [[ArmorDetailViewController alloc] init];
        aDVC.heightDifference = _heightDifference;
        aDVC.selectedArmor = armor;
        aDVC.dbEngine = _dbEngine;
        [_armorSearch resignFirstResponder];
        [self.navigationController pushViewController:aDVC animated:YES];
        
    }
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Armor *armor = [self returnArmorAtIndexPath:indexPath];
    ArmorSet *armorSet = [[ArmorSet alloc] init];
    if ([armor.slot isEqualToString:@"Head"]) {
        armorSet.helm = armor;
        armorSet.chest = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + 1]] firstObject];
        armorSet.arms = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + 2]] firstObject];
        armorSet.waist = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + 3]] firstObject];
        armorSet.legs = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + 4]] firstObject];
    } else if ([armor.slot isEqualToString:@"Body"]) {
        armorSet.helm = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + -1]] firstObject];
        armorSet.chest = armor;
        armorSet.arms = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + 1]] firstObject];
        armorSet.waist = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + 2]] firstObject];
        armorSet.legs = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + 3]] firstObject];
    } else if ([armor.slot isEqualToString:@"Arms"]) {
        armorSet.helm = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + -2]] firstObject];
        armorSet.chest = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + -1]] firstObject];
        armorSet.arms = armor;
        armorSet.waist = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + 1]] firstObject];
        armorSet.legs = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + 2]] firstObject];
    } else if ([armor.slot isEqualToString:@"Waist"]) {
        armorSet.helm = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + -3]] firstObject];
        armorSet.chest = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + -2]] firstObject];
        armorSet.arms = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + -1]] firstObject];
        armorSet.waist = armor;
        armorSet.legs = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + 1]] firstObject];
    } else if ([armor.slot isEqualToString:@"legs"]) {
        armorSet.helm = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + -4]] firstObject];
        armorSet.chest = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + -3]] firstObject];
        armorSet.arms = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + -2]] firstObject];
        armorSet.waist = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:armor.itemID + -1]] firstObject];
        armorSet.legs = armor;
    }
    
    ArmorSetDetailViewController *aSVC = [[ArmorSetDetailViewController alloc] init];
    aSVC.dbEngine = _dbEngine;
    aSVC.armorSet = armorSet;
    aSVC.setName = [[armor.name componentsSeparatedByString:@" "] firstObject];
    [self.navigationController pushViewController:aSVC animated:YES];
    
    
}

#pragma mark - Helper Methods

-(Armor *)returnArmorAtIndexPath:(NSIndexPath *)indexPath {
    Armor *armor;
    switch (indexPath.section) {
        case 0:
            armor = [_headArray objectAtIndex:indexPath.row];
            break;
        case 1:
            armor = [_bodyArray objectAtIndex:indexPath.row];
            break;
        case 2:
            armor = [_armArray objectAtIndex:indexPath.row];
            break;
        case 3:
            armor = [_waitArray objectAtIndex:indexPath.row];
            break;
        case 4:
            armor = [_legArray objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
    return armor;
    
}


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
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - (searchBarFrame.size.height + tabBarFrame.size.height));
    
    _armorFilterTab.frame = tabBarFrame;
    _armorSearch.frame = searchBarFrame;
    _armorTable.frame = tableWithSearch;
    
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

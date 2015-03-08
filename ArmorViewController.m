//
//  ArmorViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/4/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ArmorViewController.h"
#import "MH4UDBEngine.h"
#import <FMDB.h>

@interface ArmorViewController ()
@property (nonatomic) NSArray *displayedArmor;
@property (nonatomic) UITableView *armorTable;
@property (nonatomic) ArmorView *statView;
@property (nonatomic) UITabBar *armorFilterTab;
@property (nonatomic) UITabBar *armorDetailTab;
@property (nonatomic) UITableView *skillTable;
@property (nonatomic) UITableView *componentTable;
@property (nonatomic) Armor *selectedArmor;
@property (nonatomic) CGRect properFrame;
@end

@implementation ArmorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _displayedArmor = _allArmorArray;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navigationBar = self.navigationController.navigationBar.frame;
    int heightDifference = statusBar.size.height + navigationBar.size.height;
    _tabBarFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + heightDifference, self.view.frame.size.width, 49);
    _tableFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + heightDifference + 49, self.view.frame.size.width, self.view.frame.size.height);
    _armorFilterTab = [[UITabBar alloc] initWithFrame:_tabBarFrame];
    UITabBarItem *blade = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:2];
    UITabBarItem *gunner = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:3];
    UITabBarItem *allArmor = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    _armorFilterTab.delegate = self;
    [_armorFilterTab setItems:@[allArmor, blade, gunner]];
    [_armorFilterTab setSelectedItem:allArmor];
    
    _armorDetailTab = [[UITabBar alloc] initWithFrame:_tabBarFrame];
    UITabBarItem *statSheet = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:4];
    UITabBarItem *skillSheet = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:5];
    UITabBarItem *componentSheet = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:6];
    _armorDetailTab.delegate = self;
    [_armorDetailTab setItems:@[statSheet, skillSheet, componentSheet]];
    [_armorDetailTab setSelectedItem:statSheet];



    _armorTable = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 49, self.view.frame.size.width, self.view.frame.size.height)];
    _armorTable.dataSource = self;
    _armorTable.delegate = self;
    
    _properFrame = CGRectMake(_armorTable.frame.origin.x, _armorTable.frame.origin.y + 52, _armorTable.frame.size.width, _armorTable.frame.size.height);
    
    _skillTable = [[UITableView alloc] initWithFrame:_tableFrame];
    _skillTable.dataSource = self;
    _skillTable.delegate = self;
    _skillTable.frame = _properFrame;
    
    _componentTable = [[UITableView alloc] initWithFrame:_tableFrame];
    _componentTable.delegate = self;
    _componentTable.dataSource = self;

    [self.view addSubview:_armorTable];
    [self.view addSubview:_armorFilterTab];


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
        case 4:
            if (_componentTable.superview != nil) {
                [_componentTable removeFromSuperview];
            }
            
            if (_skillTable.superview != nil) {
                [_skillTable removeFromSuperview];
            }
            
            [self.view addSubview:_statView];
            [self.view addSubview:_armorDetailTab];
            break;
        case 5:
            if (_componentTable.superview != nil) {
                [_componentTable removeFromSuperview];
            }
            
            if (_statView.superview != nil) {
                [_statView removeFromSuperview];
            }
            [self.view addSubview:_skillTable];
            [self.view addSubview:_armorDetailTab];
            break;
        case 6:
            if (_skillTable.superview != nil) {
                [_skillTable removeFromSuperview];
            }
            if (_statView.superview != nil) {
                [_statView removeFromSuperview];
            }
            [self.view addSubview:_componentTable];
            [self.view addSubview:_armorDetailTab];
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

-(void)closeArmorStats {
    [_statView removeFromSuperview];
    _statView = nil;
    [self.view addSubview:_armorTable];
    [self.view addSubview:_armorFilterTab];
    self.navigationItem.rightBarButtonItems = nil;
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
        self.navigationItem.rightBarButtonItem = close;
        _statView = [[[NSBundle mainBundle] loadNibNamed:@"ArmorView" owner:self options:nil] lastObject];
        [_statView populateArmor:armor];
        [self.view addSubview:_statView];
        _statView.frame = _properFrame;
        [_armorDetailTab setSelectedItem:[_armorDetailTab.items firstObject]];
        [self.view addSubview:_armorDetailTab];
    }

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

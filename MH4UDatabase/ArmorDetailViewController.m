//
//  ArmorDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ArmorDetailViewController.h"
#import "MH4UDBEntity.h"

@interface ArmorDetailViewController ()
@property (strong, nonatomic) DetailedArmorView *statView;
@property (strong, nonatomic) UITabBar *armorDetailTab;
@property (strong, nonatomic) UITableView *skillTable;
@property (strong, nonatomic) UITableView *componentTable;
@end

@implementation ArmorDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);

    _armorDetailTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
    UITabBarItem *statSheet = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:4];
    UITabBarItem *skillSheet = [[UITabBarItem alloc] initWithTitle:@"Skills" image:nil tag:5];
    UITabBarItem *componentSheet = [[UITabBarItem alloc] initWithTitle:@"Components" image:nil tag:6];
    
    _armorDetailTab.delegate = self;
    [_armorDetailTab setItems:@[statSheet, skillSheet, componentSheet]];
    [_armorDetailTab setSelectedItem:statSheet];
    
    _skillTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _skillTable.dataSource = self;
    _skillTable.delegate = self;
    
    _componentTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _componentTable.delegate = self;
    _componentTable.dataSource = self;
    
    _statView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedArmorView" owner:self options:nil] lastObject];
    _statView.frame = tablewithTabbar;
    [_statView populateArmor:_selectedArmor];
    [self.view addSubview:_statView];
    [_armorDetailTab setSelectedItem:[_armorDetailTab.items firstObject]];
    [self.view addSubview:_armorDetailTab];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_componentTable]) {
        return _selectedArmor.componentArray.count;
    } else if ([tableView isEqual:_skillTable]) {
        return _selectedArmor.skillsArray.count;
    } else  {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"armorCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"armorCell"];
    }

    if ([tableView isEqual:_skillTable]) {
        NSArray *skillArray = _selectedArmor.skillsArray[indexPath.row];
        NSString *detailLabel = [NSString stringWithFormat:@"%@: %@", [skillArray objectAtIndex:1], [skillArray objectAtIndex:2]];
        cell.textLabel.text = detailLabel;
    } else if ([tableView isEqual:_componentTable]) {
        NSArray *componentArray = _selectedArmor.componentArray[indexPath.row];
        cell.textLabel.text = [componentArray objectAtIndex:1];
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([tabBar isEqual:_armorDetailTab]) {
        [self removeViewsFromDetail];
        switch (item.tag) {
            case 4:
                [self.view addSubview:_statView];
                break;
            case 5:
                [self.view addSubview:_skillTable];
                break;
            case 6:
                [self.view addSubview:_componentTable];
                break;
            default:
                break;
        }
        
    }
    [tabBar setSelectedItem:item];
    
}

-(void)removeViewsFromDetail {
    NSArray *allTables = @[_statView, _skillTable, _componentTable];
    for (UIView *view in allTables) {
        if (view.superview != nil) {
            [view removeFromSuperview];
        }
    }
}

@end

@implementation DetailedArmorView

-(void)populateArmor:(Armor *)armor
{
    _armorName.text = armor.name;
    _IconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png", [armor.slot lowercaseString], armor.rarity]];
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

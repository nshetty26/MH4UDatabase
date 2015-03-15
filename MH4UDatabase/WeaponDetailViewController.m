//
//  WeaponDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "WeaponDetailViewController.h"
#import "ItemDetailViewController.h"
#import "MH4UDBEntity.h"
#import "MH4UDBEngine.h"

@interface WeaponDetailViewController ()
@property (nonatomic) DetailedWeaponView *detailedView;
@property (nonatomic) UITabBar *weaponDetailTab;
@property (nonatomic) UITableView *componentTable;
@property (nonatomic) UITableView *weaponFamilyTable;
@property (nonatomic) NSArray *weaponComponents;

@end

@implementation WeaponDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _selectedWeapon.icon = [NSString stringWithFormat:@"%@%i.png",_imageString, _selectedWeapon.rarity];
    CGRect vcFrame = self.view.frame;
    
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + tabBarFrame.size.height + _heightDifference, vcFrame.size.width, vcFrame.size.height - _heightDifference - tabBarFrame.size.height);

    
    UITabBarItem *statSheet = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:4];
    UITabBarItem *fTree = [[UITabBarItem alloc] initWithTitle:@"Family Tree" image:nil tag:5];
    UITabBarItem *componentSheet = [[UITabBarItem alloc] initWithTitle:@"Components" image:nil tag:6];
    
    _weaponDetailTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
    _weaponDetailTab.delegate = self;
    [_weaponDetailTab setItems:@[statSheet, fTree, componentSheet]];
    _detailedView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedWeaponView" owner:self options:nil] firstObject];
    [_detailedView populateWeapon:_selectedWeapon];
        _detailedView.frame = tablewithTabbar;
    
    _weaponComponents = [_dbEngine getComponentsfor:_selectedWeapon.itemID];
    
    [_weaponDetailTab setSelectedItem:statSheet];
    
    _componentTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _componentTable.delegate = self;
    _componentTable.dataSource = self;
    
    _weaponFamilyTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _weaponFamilyTable.delegate = self;
    _weaponFamilyTable.dataSource = self;
    
    [self.view addSubview:_weaponDetailTab];
    [self.view addSubview:_detailedView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_componentTable]) {
        return _weaponComponents.count;
    } else if ([tableView isEqual:_weaponFamilyTable]) {
        return _weaponFamily.count;
    } else  {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *itemName = cell.textLabel.text;
    if ([tableView isEqual:_componentTable]) {
        ItemDetailViewController *iDVC = [[ItemDetailViewController alloc] init];
        
        iDVC.selectedItem = [_dbEngine getItemForName:itemName];
        iDVC.dbEngine = _dbEngine;
        iDVC.heightDifference = _heightDifference;
        [self.navigationController pushViewController:iDVC animated:YES];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"componentCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"componentCell"];
    }
    
    if ([tableView isEqual:_componentTable]) {
        NSArray *componentArray = _weaponComponents[indexPath.row];
        cell.textLabel.text = [componentArray objectAtIndex:1];
        cell.imageView.image = [UIImage imageNamed:componentArray[2]];
        if (cell.imageView.image == nil) {
            cell.imageView.image = [UIImage imageNamed:_selectedWeapon.icon];
        }
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 50, cellFrame.size.height - 10, 30, 20);
        UILabel *acessoryText = [[UILabel alloc] initWithFrame:textView];
        [cell addSubview:acessoryText];
        acessoryText.textAlignment =  NSTextAlignmentRight;
        acessoryText.text = [NSString stringWithFormat:@"%@", componentArray[3]];
        [cell setAccessoryView: acessoryText];
        
    } else if ([tableView isEqual:_weaponFamilyTable]) {
        Weapon *weapon = _weaponFamily[indexPath.row];
        cell.indentationWidth = 3;
        cell.textLabel.text = [NSString stringWithFormat:@"%@", weapon.name];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",_imageString, weapon.rarity]];
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([tabBar isEqual:_weaponDetailTab]) {
        [self removeViewsFromDetail];
        switch (item.tag) {
            case 4:
                [self.view addSubview:_detailedView];
                break;
            case 5:
                [self.view addSubview:_weaponFamilyTable];
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
    NSArray *allTables = @[_detailedView, _weaponFamilyTable, _componentTable];
    for (UIView *view in allTables) {
        if (view.superview != nil) {
            [view removeFromSuperview];
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    Weapon *weapon = _weaponFamily[indexPath.row];
    return weapon.tree_depth;
}

@end

@implementation DetailedWeaponView

-(void)populateWeapon:(Weapon *)weapon {
    _icon.image = [UIImage imageNamed:weapon.icon];
    _nameLabel.text = weapon.name;
    _attackLabel.text = [NSString stringWithFormat:@"%i", weapon.attack];
    //_elementLabel.text = @"ELEMENTAL DAMAGE";
    _sharpnessImage.image = [UIImage imageNamed:weapon.sharpnessFile];
    [self drawSharpnessRectWithWeapon:weapon];
    _rarityLabel.text = [NSString stringWithFormat:@"%i", weapon.rarity];
    _numSlotsLabel.text = [NSString stringWithFormat:@"%i", weapon.num_slots];
    _defenseLabel.text = [NSString stringWithFormat:@"%i", weapon.defense];
    _creationCostLabel.text = [NSString stringWithFormat:@"%i", weapon.creationCost];
    _upgradeCostLabel.text = [NSString stringWithFormat:@"%i", weapon.upgradeCost];
}

-(void)drawSharpnessRectWithWeapon:(Weapon *)weapon {
    NSArray *sharpnessStringArray = [weapon.sharpness componentsSeparatedByString:@" "];
    int sharpnessCount = 0;
    for (NSString *sharpnessString in sharpnessStringArray) {
        sharpnessCount++;
        int frameWidth = 0;
        UIView *sharpnessView = (sharpnessCount == 1) ? _sharpnessView1 : _sharpnessView2;
        
        [sharpnessView setBackgroundColor:[UIColor clearColor]];
        NSArray *sharpness = [sharpnessString componentsSeparatedByString:@"."];
        
        int mRed1 = (int)[sharpness[0] integerValue];
        int mOrange1 = (int)[sharpness[1] integerValue];
        int mYellow1 = (int)[sharpness[2] integerValue];
        int mGreen1 = (int)[sharpness[3] integerValue];
        int mBlue1 = (int)[sharpness[4] integerValue];
        int mWhite1 = (int)[sharpness[5] integerValue];
        int mPurple1 = (int)[sharpness[6] integerValue];
        
        int widthMultiplier = sharpnessView.bounds.size.width / (mRed1 + mOrange1 + mYellow1 + mGreen1 + mBlue1 + mWhite1 + mPurple1);
        
        CGRect sharpnessRect = sharpnessView.bounds;
        
        CGRect red = CGRectMake(sharpnessRect.origin.x, sharpnessRect.origin.y, mRed1 * widthMultiplier, sharpnessRect.size.height);
        UIView *redView = [[UIView alloc] initWithFrame:red];
        frameWidth += red.size.width;
        [redView setBackgroundColor:[UIColor redColor]];
        [sharpnessView addSubview:redView];
        
        CGRect orange = CGRectMake(red.size.width, red.origin.y, mOrange1 * widthMultiplier, sharpnessRect.size.height);
        UIView *orangeView = [[UIView alloc] initWithFrame:orange];
        frameWidth += orange.size.width;
        [orangeView setBackgroundColor:[UIColor orangeColor]];
        [sharpnessView addSubview:orangeView];
        
        CGRect yellow = CGRectMake(red.size.width + orange.size.width, orange.origin.y, mYellow1 * widthMultiplier, sharpnessRect.size.height);
        UIView *yellowView = [[UIView alloc] initWithFrame:yellow];
        frameWidth += yellow.size.width;
        [yellowView setBackgroundColor:[UIColor yellowColor]];
        [sharpnessView addSubview:yellowView];
        
        CGRect green = CGRectMake(red.size.width+yellow.size.width+orange.size.width, yellow.origin.y, mGreen1 * widthMultiplier, sharpnessRect.size.height);
        UIView *greenView = [[UIView alloc] initWithFrame:green];
        frameWidth += green.size.width;
        [greenView setBackgroundColor:[UIColor greenColor]];
        [sharpnessView addSubview:greenView];
        
        CGRect blue = CGRectMake(red.size.width+yellow.size.width+orange.size.width+green.size.width, green.origin.y, mBlue1 * widthMultiplier, sharpnessRect.size.height);
        frameWidth += blue.size.width;
        UIView *blueView = [[UIView alloc] initWithFrame:blue];
        [blueView setBackgroundColor:[UIColor blueColor]];
        [sharpnessView addSubview:blueView];
        
        CGRect white = CGRectMake(red.size.width+yellow.size.width+orange.size.width+green.size.width+blue.size.width, blue.origin.y, mWhite1 * widthMultiplier, sharpnessRect.size.height);
        frameWidth += white.size.width;
        UIView *whiteView = [[UIView alloc] initWithFrame:white];
        [whiteView setBackgroundColor:[UIColor whiteColor]];
        [sharpnessView addSubview:whiteView];
        
        CGRect purple = CGRectMake(red.size.width+yellow.size.width+orange.size.width+green.size.width+blue.size.width+white.size.width, white.origin.y, mPurple1 * widthMultiplier, sharpnessRect.size.height);
        UIView *purpleView = [[UIView alloc] initWithFrame:purple];
        frameWidth += purple.size.width;
        [purpleView setBackgroundColor:[UIColor purpleColor]];
        [sharpnessView addSubview:purpleView];
        
        [sharpnessView setFrame:CGRectMake(sharpnessView.frame.origin.x, sharpnessView.frame.origin.x, frameWidth, sharpnessView.frame.size.height)];
        
    }
}

@end

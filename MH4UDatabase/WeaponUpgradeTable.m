//
//  WeaponFamilyTable.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/2/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "WeaponUpgradeTable.h"
#import "WeaponDetailViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface WeaponUpgradeTable()
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) MH4UDBEngine *dbEngine;
@property (strong, nonatomic) Weapon *selectedWeapon;
@property (strong, nonatomic) NSArray *weaponUpgradeTree;

@end

@implementation WeaponUpgradeTable

-(id)initWithFrame:(CGRect)frame andNavigationController:(UINavigationController *)navigationController andDBEngine:(MH4UDBEngine *)dbEngine andWeapon:(Weapon *)weapon{
    if (self = [super init]) {
        self.frame = frame;
        
        if (navigationController && dbEngine) {
            _navigationController = navigationController;
            _dbEngine = dbEngine;
            _selectedWeapon = weapon;
            self.delegate = self;
            self.dataSource = self;
            [self populateWeaponUpgradeTree];
            return self;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _weaponUpgradeTree.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Weapon *weapon = _weaponUpgradeTree[indexPath.row];
    UITableViewCell *cell;
    
    if (weapon.itemID == _selectedWeapon.itemID) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"selectedWeaponCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"selectedWeaponCell"];
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"weaponCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"weaponCell"];
        }
    }
    
    
    cell.indentationWidth = 3;
    cell.textLabel.text = [NSString stringWithFormat:@"%@", weapon.name];
    if ( weapon.itemID == _selectedWeapon.itemID) {
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize]];
    }
    
    if (weapon.final == 1) {
        cell.detailTextLabel.text = @"Final";
    } else if (weapon.parentID == _selectedWeapon.itemID) {
        cell.detailTextLabel.text = @"Next Upgrade";
    }
    cell.imageView.image = [UIImage imageNamed:weapon.icon];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Weapon *weapon = _weaponUpgradeTree[indexPath.row];
    WeaponDetailViewController *wDVC = [[WeaponDetailViewController alloc] init];
    wDVC.selectedWeapon = weapon;
    wDVC.dbEngine = _dbEngine;
    wDVC.heightDifference = [self returnHeightDifference];
    [self.navigationController pushViewController:wDVC animated:YES];

}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    Weapon *weapon = _weaponUpgradeTree[indexPath.row];
    return weapon.tree_depth;

}


-(void)populateWeaponUpgradeTree {
    NSArray *weaponFamily = [_dbEngine getWeaponsForWeaponType:_selectedWeapon.weaponType];
    NSMutableArray *parentWeapons = [[NSMutableArray alloc] init];
    NSMutableArray *upgradeWeapons = [[NSMutableArray alloc] init];
    [self getParentWeapons:_selectedWeapon inArray:parentWeapons withArray:weaponFamily];
    [self getUpgradedWeapons:_selectedWeapon inArray:upgradeWeapons withArray:weaponFamily];
    
    [parentWeapons addObjectsFromArray:upgradeWeapons];
    [parentWeapons addObject:_selectedWeapon];
    [parentWeapons sortUsingComparator:^NSComparisonResult(id w1, id w2){
        Weapon *weapon1 = (Weapon *)w1;
        Weapon *weapon2 = (Weapon *)w2;
        if (weapon1.itemID > weapon2.itemID) {
            return 1;
        } else if (weapon1.itemID < weapon2.itemID) {
            return -1;
        } else {
            return 0;
        }
    }];
    
    _weaponUpgradeTree = parentWeapons;

    
}

-(void)getParentWeapons:(Weapon *)weapon inArray:(NSMutableArray *)parentWeaponArray withArray:(NSArray *)weaponsArray {
    NSArray *weaponArray = [weaponsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        Weapon *arrayWeapon = (Weapon *)evaluatedObjected;
        if (arrayWeapon.itemID == weapon.parentID) {
            return YES;
        } else {
            return NO;
        }
        
    }]];
    
    if (weaponArray.count > 0) {
        Weapon *parentWeapon = [weaponArray firstObject];
        if (parentWeapon.parentID != 0) {
            [parentWeaponArray addObject:parentWeapon];
            [self getParentWeapons:parentWeapon inArray:parentWeaponArray withArray:weaponsArray];
        } else {
            [parentWeaponArray addObject:parentWeapon];
            return;
        }
    } else {
        return;
    }
    
}

-(void)getUpgradedWeapons:(Weapon *)weapon inArray:(NSMutableArray *)upgradedWeaponArray withArray:(NSArray *) weaponsArray {
    NSArray *weaponArray = [weaponsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        Weapon *arrayWeapon = (Weapon *)evaluatedObjected;
        if (arrayWeapon.parentID == weapon.itemID) {
            return YES;
        } else {
            return NO;
        }
        
    }]];
    
    
    if (weaponArray.count == 1) {
        Weapon *upgradedWeapon = [weaponArray firstObject];
        [upgradedWeaponArray addObject:upgradedWeapon];
        [self getUpgradedWeapons:upgradedWeapon inArray:upgradedWeaponArray withArray:weaponsArray];
    } else if (weaponArray.count > 1) {
        for (Weapon *upgrade in weaponArray) {
            [upgradedWeaponArray addObject:upgrade];
            [self getUpgradedWeapons:upgrade inArray:upgradedWeaponArray withArray:weaponsArray];
        }
    }
    else {
        return;
    }
}

-(CGFloat)returnHeightDifference {
    UINavigationBar *navBar = _navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    return navBar.frame.size.height + statusBar.size.height;
}

@end

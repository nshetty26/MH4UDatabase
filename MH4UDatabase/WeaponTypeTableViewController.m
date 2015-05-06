//
//  WeaponTypeTableViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "WeaponTypeTableViewController.h"
#import "WeaponsTableViewController.h"
#import "MH4UDBEngine.h"

@interface WeaponTypeTableViewController ()

@end

@implementation WeaponTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.title = NSLocalizedString(@"Weapons", @"Weapons");
    _allWeaponTypes = [_dbEngine getWeaponTypes];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _allWeaponTypes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weaponTypeCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"weaponTypeCell"];
    }
    
    // Configure the cell...
    NSString *weaponName = _allWeaponTypes[indexPath.row];
    cell.textLabel.text = weaponName;
    NSString *imageString = [weaponName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@1.png",imageString.lowercaseString]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *weaponName = _allWeaponTypes[indexPath.row];
    NSString *imageString = [weaponName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    WeaponsTableViewController *wTVC = [[WeaponsTableViewController alloc] init];

    wTVC.dbEngine = _dbEngine;
    wTVC.imageString = imageString.lowercaseString;
    wTVC.weaponFamily = weaponName;
    wTVC.heightDifference = _heightDifference;
    [self.navigationController pushViewController:wTVC animated:YES];
}


@end

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
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@1.png",imageString]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *weaponName = _allWeaponTypes[indexPath.row];
    NSString *imageString = [weaponName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    WeaponsTableViewController *wTVC = [[WeaponsTableViewController alloc] init];
    
    wTVC.weaponsArray = [_dbEngine getWeaponsForWeaponType:weaponName];
    wTVC.dbEngine = _dbEngine;
    wTVC.imageString = imageString;
    wTVC.weaponFamily = weaponName;
    wTVC.heightDifference = _heightDifference;
    [self.navigationController pushViewController:wTVC animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

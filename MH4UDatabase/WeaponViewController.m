//
//  WeaponViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/9/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

/*
 SELECT weapons._id, items.name, wtype, creation_cost, upgrade_cost, attack, max_attack, element, element_attack, element_2, element_2_attack, awaken, awaken_attack, defense, sharpness, affinity, horn_notes, shelling_type, phial, charges, coatings, recoil, reload_speed, rapid_fire, deviation, ammo, sharpness_file, num_slots, tree_depth, final from weapons inner join items on items._id = weapons._id
 */

#import "WeaponViewController.h"

@interface WeaponViewController ()

@end

@implementation WeaponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//
//  WeaponDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "WeaponDetailViewController.h"
#import "MH4UDBEntity.h"

@interface WeaponDetailViewController ()
@property (nonatomic) DetailedWeaponView *detailedView;

@end

@implementation WeaponDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _detailedView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedWeaponView" owner:self options:nil] firstObject];
    [_detailedView populateWeapon:_selectedWeapon];
    _detailedView.frame = self.view.frame;
    [self.view addSubview:_detailedView];
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

@implementation DetailedWeaponView

-(void)populateWeapon:(Weapon *)weapon {
    _icon.image = [UIImage imageNamed:weapon.icon];
    _nameLabel.text = weapon.name;
    _attackLabel.text = [NSString stringWithFormat:@"%i", weapon.attack];
    //_elementLabel.text = @"ELEMENTAL DAMAGE";
    _sharpnessImage.image = [UIImage imageNamed:weapon.sharpnessFile];
    _rarityLabel.text = [NSString stringWithFormat:@"%i", weapon.rarity];
    _numSlotsLabel.text = [NSString stringWithFormat:@"%i", weapon.num_slots];
    _defenseLabel.text = [NSString stringWithFormat:@"%i", weapon.defense];
    _creationCostLabel.text = [NSString stringWithFormat:@"%i", weapon.creationCost];
    _upgradeCostLabel.text = [NSString stringWithFormat:@"%i", weapon.upgradeCost];
}

@end

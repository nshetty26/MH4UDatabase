//
//  ArmorSetViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/17/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MH4UDBEntity.h"
#import "MH4UDBEngine.h"
#import "ArmorSetDetailViewController.h"
#import "SkillDetailViewController.h"

@interface ArmorSetDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *weaponImage;
@property (weak, nonatomic) IBOutlet UILabel *weaponLabel;

@property (weak, nonatomic) IBOutlet UIImageView *helmImage;
@property (weak, nonatomic) IBOutlet UILabel *helmLabel;

@property (weak, nonatomic) IBOutlet UIImageView *chestImage;
@property (weak, nonatomic) IBOutlet UILabel *chestLabel;

@property (weak, nonatomic) IBOutlet UIImageView *armImage;
@property (weak, nonatomic) IBOutlet UILabel *armLabel;

@property (weak, nonatomic) IBOutlet UIImageView *waistImage;
@property (weak, nonatomic) IBOutlet UILabel *waistLabel;


@property (weak, nonatomic) IBOutlet UIImageView *legImage;
@property (weak, nonatomic) IBOutlet UILabel *legLabel;

@property (weak, nonatomic) IBOutlet UILabel *talismanLabel;
@property (weak, nonatomic) IBOutlet UIImageView *talismanImage;

@property (strong, nonatomic) ArmorStatSheetView *armorStatSheet;
@property (strong, nonatomic) NSMutableDictionary *skillDictionary;
@property (strong, nonatomic) UITabBar *armorSetTab;
@property (strong, nonatomic) NSArray *weaponDecorations;
@property (strong, nonatomic) NSArray *headDecorations;
@property (strong, nonatomic) NSArray *bodyDecorations;
@property (strong, nonatomic) NSArray *armsDecorations;
@property (strong, nonatomic) NSArray *waistDecorations;
@property (strong, nonatomic) NSArray *legsDecorations;

@end

@implementation ArmorSetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _setName;
    _skillDictionary = [[NSMutableDictionary alloc] init];
    
    _weaponDecorations = @[_weaponSlot1, _weaponSlot2, _weaponSlot3];
    _headDecorations = @[_helmSlot1, _helmSlot2, _helmSlot3];
    _bodyDecorations = @[_bodySlot1, _bodySlot2, _bodySlot3];
    _armsDecorations = @[_armsSlot1, _armsSlot2, _armsSlot3];
    _waistDecorations = @[_waistSlot1, _waistSlot2, _waistSlot3];
    _legsDecorations = @[_legsSlot1, _legsSlot2, _legsSlot3];
    
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + [self returnHeightDifference], vcFrame.size.width, 49);
    _armorStatSheet = [[[NSBundle mainBundle] loadNibNamed:@"ArmorStatSheetView" owner:self options:nil] lastObject];
    _armorStatSheet.aSVC = self;
    [self setUpTabBarWithFrame:tabBarFrame];
    // Do any additional setup after loading the view from its nib.
    [self populateArmorSet];
    [self setUpArmorSetView];
}

-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_armorSetTab) {
        NSMutableArray *tabItems = [[NSMutableArray alloc] init];
        
        UITabBarItem *armorSet = [[UITabBarItem alloc] initWithTitle:@"Set" image:nil tag:1];
        UITabBarItem *armorStats = [[UITabBarItem alloc] initWithTitle:@"Stats" image:nil tag:2];
        [tabItems addObject:armorSet];
        [tabItems addObject:armorStats];
        
        _armorSetTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
        _armorSetTab.delegate = self;
        [_armorSetTab setSelectedItem:armorSet];
        [_armorSetTab setItems:tabItems];
        [self.view addSubview:_armorSetTab];
    }
}

-(void)populateArmorSet {
    if (!_armorSet) {
        _dbEngine = [[MH4UDBEngine alloc] init];
        _armorSet = [[ArmorSet alloc] init];
        _armorSet.weapon = [_dbEngine getWeaponForWeaponID:5002];
        _armorSet.helm = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:1914]] firstObject];
        _armorSet.chest = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:1915]] firstObject];
        _armorSet.arms = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:1916]] firstObject];
        _armorSet.waist = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:1917]] firstObject];
        _armorSet.legs = [[_dbEngine retrieveArmor:[NSNumber numberWithInt:1918]] firstObject];
    }
    
    [_dbEngine populateArmor:_armorSet.helm];
    
    [_dbEngine populateArmor:_armorSet.chest];
    
    [_dbEngine populateArmor:_armorSet.arms];
    
    [_dbEngine populateArmor:_armorSet.waist];
    
    [_dbEngine populateArmor:_armorSet.legs];
    
    [self drawDecorationForArmorSet];

}

-(void)drawDecorationForArmorSet {
    
    for (int i = 0; i < _armorSet.weapon.num_slots; i++) {
        UIImageView *decorationView = _weaponDecorations[i];
        decorationView.image = [UIImage imageNamed:@"circle.png"];
    }
    
    for (Armor *armor in [_armorSet returnNonNullArmor]) {
        for (int i = 0; i < armor.numSlots; i++) {
            if ([armor.slot isEqualToString:@"Head"]) {
                UIImageView *headSlot = _headDecorations[i];
                headSlot.image = [UIImage imageNamed:@"circle.png"];
            } else if ([armor.slot isEqualToString:@"Body"]) {
                UIImageView *bodySlot = _bodyDecorations[i];
                bodySlot.image = [UIImage imageNamed:@"circle.png"];
            } else if ([armor.slot isEqualToString:@"Arms"]) {
                UIImageView *armsSlot = _armsDecorations[i];
                armsSlot.image = [UIImage imageNamed:@"circle.png"];
            } else if ([armor.slot isEqualToString:@"Waist"]) {
                UIImageView *waistSlot = _waistDecorations[i];
                waistSlot.image = [UIImage imageNamed:@"circle.png"];
            } else if ([armor.slot isEqualToString:@"Legs"]) {
                UIImageView *legSlot = _legsDecorations[i];
                legSlot.image = [UIImage imageNamed:@"circle.png"];
            }
        }
    }
}

-(void)combineSkillsArray:(NSArray *)skillArray {
    for (NSArray *skill in skillArray) {
        if (![_skillDictionary objectForKey:skill[0]]) {
            [_skillDictionary setObject:[[NSMutableArray alloc] initWithArray:@[skill[1], skill[2]]] forKey:skill[0]];
        } else {
            NSMutableArray *nameAndValue = [_skillDictionary objectForKey:skill[0]];
            NSNumber *originalValue = nameAndValue[1];
            NSNumber *newSkillValue = skill[2];
            int newValue = [originalValue intValue] + [newSkillValue intValue];
            nameAndValue[1] = [NSNumber numberWithInt:newValue];
        }
    }
}

-(void)setUpArmorSetView {
    _weaponImage.image = [UIImage imageNamed:_armorSet.weapon.icon];
    _weaponLabel.text = _armorSet.weapon.name;
    
    _helmImage.image = [UIImage imageNamed:_armorSet.helm.icon];
    _helmLabel.text = _armorSet.helm.name;
    
    _chestImage.image = [UIImage imageNamed:_armorSet.chest.icon];
    _chestLabel.text = _armorSet.chest.name;
    
    _armImage.image = [UIImage imageNamed:_armorSet.arms.icon];
    _armLabel.text = _armorSet.arms.name;
    
    _waistImage.image = [UIImage imageNamed:_armorSet.waist.icon];
    _waistLabel.text = _armorSet.waist.name;
    
    _legImage.image = [UIImage imageNamed:_armorSet.legs.icon];
    _legLabel.text = _armorSet.legs.name;
    
    [_armorStatSheet populateStatsWithArmorSet:_armorSet];
    _armorStatSheet.numSlots += _armorSet.weapon.num_slots;
    _armorSet.totalSlots = _armorStatSheet.numSlots;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 1:
            [_armorStatSheet removeFromSuperview];
            break;
        case 2:
            [self.view addSubview:_armorStatSheet];
            break;
        default:
            break;
        }
    [tabBar setSelectedItem:item];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _skillDictionary.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *allNameAndValues = [_skillDictionary allValues];
    NSArray *nameAndValue = allNameAndValues[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = nameAndValue[0];
    CGRect cellFrame = cell.frame;
    CGRect textView = CGRectMake(cellFrame.size.width - 50, cellFrame.size.height - 10, 50, 20);
    UILabel *acessoryText = [[UILabel alloc] initWithFrame:textView];
    acessoryText.textAlignment =  NSTextAlignmentRight;
    
    
    acessoryText.text = [NSString stringWithFormat:@"%@", nameAndValue[1]];
    [cell addSubview:acessoryText];
    [cell setAccessoryView: acessoryText];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *allNameAndValues = [_skillDictionary allValues];
    NSArray *nameAndValue = allNameAndValues[indexPath.row];
    NSNumber *skillID = [[_skillDictionary allKeysForObject:nameAndValue] firstObject];
    SkillDetailViewController *sdVC = [[SkillDetailViewController alloc] init];
    sdVC.heightDifference = [self returnHeightDifference];
    sdVC.dbEngine = _dbEngine;
    sdVC.skilTreeName = nameAndValue[0];
    sdVC.skillTreeID = [skillID intValue];
    [self.navigationController pushViewController:sdVC animated:YES];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)viewDidLayoutSubviews {
    CGRect vcFrame = self.view.frame;
    _armorSetTab.frame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + [self returnHeightDifference], vcFrame.size.width, 49);
    _armorStatSheet.frame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _armorSetTab.frame.size.height + [self returnHeightDifference], vcFrame.size.width, vcFrame.size.height - [self returnHeightDifference] - _armorSetTab.frame.size.height);
    CGRect skillFrame = _armorStatSheet.statTableView.frame;
    _armorStatSheet.statTableView.frame = CGRectMake(skillFrame.origin.x, skillFrame.origin.y, vcFrame.size.width, skillFrame.size.height);
}

@end


@interface ArmorStatSheetView()
@property (weak, nonatomic) IBOutlet UILabel *healthValue;
@property (weak, nonatomic) IBOutlet UILabel *staminaValue;
@property (weak, nonatomic) IBOutlet UILabel *attackValue;
@property (weak, nonatomic) IBOutlet UILabel *elementValue;
@property (weak, nonatomic) IBOutlet UILabel *minDefenseValue;
@property (weak, nonatomic) IBOutlet UILabel *maxDefenseValue;
@property (weak, nonatomic) IBOutlet UILabel *fireResValue;
@property (weak, nonatomic) IBOutlet UILabel *waterResValue;
@property (weak, nonatomic) IBOutlet UILabel *thunderResValue;
@property (weak, nonatomic) IBOutlet UILabel *iceResValue;
@property (weak, nonatomic) IBOutlet UILabel *dragonResValue;
@property (weak, nonatomic) IBOutlet UITableView *skillTableView;

@property (nonatomic) int minDefense;
@property (nonatomic) int maxDefense;
@property (nonatomic) int fireRes;
@property (nonatomic) int waterRes;
@property (nonatomic) int thunderRes;
@property (nonatomic) int iceRes;
@property (nonatomic) int dragonRes;

@property (nonatomic, strong) NSMutableDictionary *skillDictionary;

@end

@implementation ArmorStatSheetView

-(void)populateStatsWithArmorSet:(ArmorSet *)armorSet {
    [self sumAllStats:[armorSet returnNonNullArmor]];
    _attackValue.text = [NSString stringWithFormat:@"%i", armorSet.weapon.attack];
    
    _elementValue.text = [armorSet.weapon getElementalDescription];
    
    _minDefenseValue.text = [NSString stringWithFormat:@"%i - %i", _minDefense, _maxDefense];
    _fireResValue.text = [NSString stringWithFormat:@"%i", _fireRes];
    _waterResValue.text = [NSString stringWithFormat:@"%i",_waterRes];
    _thunderResValue.text = [NSString stringWithFormat:@"%i", _thunderRes];
    _iceResValue.text = [NSString stringWithFormat:@"%i", _iceRes];
    _dragonResValue.text = [NSString stringWithFormat:@"%i", _dragonRes];
}

-(void)sumAllStats:(NSArray *)armorArray {
    for (Armor *armor in armorArray) {
        _minDefense += armor.defense;
        _maxDefense += armor.maxDefense;
        _fireRes += armor.fireResistance;
        _waterRes += armor.waterResistance;
        _thunderRes += armor.thunderResistance;
        _iceRes += armor.iceResistance;
        _dragonRes += armor.dragonResistance;
        _numSlots += armor.numSlots;
        [_aSVC combineSkillsArray:armor.skillsArray];
    }
    
}


@end

//
//  ArmorSetViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/17/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "MH4UDBEntity.h"
#import "MenuViewController.h"
#import "MH4UDBEngine.h"
#import "ArmorSetDetailViewController.h"
#import "SkillDetailViewController.h"
#import "DecorationsDetailViewController.h"
#import "ItemDetailViewController.h"

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

@property (strong, nonatomic) UITableView *statTableView;
@property (strong, nonatomic) UITableView *socketedTable;

@property (strong, nonatomic) ArmorStatSheetView *armorStatSheet;
@property (strong, nonatomic) NSMutableDictionary *skillDictionary;
@property (strong, nonatomic) UITabBar *armorSetTab;
@property (strong, nonatomic) UITabBar *equipmentSocketTab;
@property (strong, nonatomic) NSArray *weaponDecorationViews;
@property (strong, nonatomic) NSArray *headDecorationViews;
@property (strong, nonatomic) NSArray *bodyDecorationViews;
@property (strong, nonatomic) NSArray *armsDecorationViews;
@property (strong, nonatomic) NSArray *waistDecorationViews;
@property (strong, nonatomic) NSArray *legsDecorationViews;

@property (strong, nonatomic) NSMutableArray *allDecorations;
@property (strong, nonatomic) NSArray *displayedDecorations;



@end

@implementation ArmorSetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _baseVC.aSDVC = self;
    self.title = _setName;
    _skillDictionary = [[NSMutableDictionary alloc] init];
    _allDecorations = [[NSMutableArray alloc] init];
    
    _weaponDecorationViews = @[_weaponSlot1, _weaponSlot2, _weaponSlot3];
    _headDecorationViews = @[_helmSlot1, _helmSlot2, _helmSlot3];
    _bodyDecorationViews = @[_bodySlot1, _bodySlot2, _bodySlot3];
    _armsDecorationViews = @[_armsSlot1, _armsSlot2, _armsSlot3];
    _waistDecorationViews = @[_waistSlot1, _waistSlot2, _waistSlot3];
    _legsDecorationViews = @[_legsSlot1, _legsSlot2, _legsSlot3];
    
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + [self returnHeightDifference], vcFrame.size.width, 49);
    _armorStatSheet = [[[NSBundle mainBundle] loadNibNamed:@"ArmorStatSheetView" owner:self options:nil] lastObject];
    _armorStatSheet.aSVC = self;
    [self setUpTabBarWithFrame:tabBarFrame];
    _statTableView = [[UITableView alloc] init];
    _statTableView.delegate = self;
    _statTableView.dataSource = self;
    
    // Do any additional setup after loading the view from its nib.
    [self populateArmorSet];
    [self drawDecorationForArmorSet];
    [self setUpArmorSetView];
    [self setUpEquipmentTabBar];
    [self.view addSubview:_socketedTable];
    if (_allDecorations.count > 0) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        NSArray *firstItemWithDecorations = [[_armorSet returnItemsWithDecorations] firstObject];
        _displayedDecorations = firstItemWithDecorations[1];
        _socketedTable = [[UITableView alloc] init];
        _socketedTable.delegate = self;
        _socketedTable.dataSource = self;
        
    }
    
    [self calculateSkillsForSelectedArmorSet];
}

-(void)setUpEquipmentTabBar {
    CGRect tabBarFrame = CGRectMake(self.view.frame.origin.x, _socketedTable.frame.origin.y - 49, _baseVC.rightDrawerViewController.view.frame.size.width, 49);
    _equipmentSocketTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
    _equipmentSocketTab.delegate = self;
    [self setTabBarItemsForEquipmentTabBar];
    [self.view addSubview:_socketedTable];
    [self.view addSubview:_equipmentSocketTab];
}

-(void)setTabBarItemsForEquipmentTabBar {
    NSMutableArray *equipmentTabs = [[NSMutableArray alloc] init];
    NSArray *itemswithDecorations = [_armorSet returnItemsWithDecorations];

    for (int i = 0; i < itemswithDecorations.count; i++) {
        int tag = i+1;
        NSArray *itemWithDecoration = itemswithDecorations[i];
        [equipmentTabs addObject:[[UITabBarItem alloc] initWithTitle:itemWithDecoration[0] image:nil tag:tag]];
    }
    
    [_equipmentSocketTab setItems:equipmentTabs];
    [_equipmentSocketTab setSelectedItem:[equipmentTabs firstObject]];
    
}

-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_armorSetTab) {
        NSMutableArray *tabItems = [[NSMutableArray alloc] init];
        
        UITabBarItem *armorSet = [[UITabBarItem alloc] initWithTitle:@"Set" image:nil tag:1];
        UITabBarItem *armorStats = [[UITabBarItem alloc] initWithTitle:@"Stats" image:nil tag:2];
        UITabBarItem *skillsTable = [[UITabBarItem alloc] initWithTitle:@"Skills" image:nil tag:3];
        [tabItems addObject:armorSet];
        [tabItems addObject:armorStats];
        [tabItems addObject:skillsTable];
        
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
}

-(void)drawDecorationForArmorSet {
    
    if (_armorSet.weapon.num_slots > 0) {
        NSArray *decorations = [_dbEngine getDecorationsForArmorSet:[NSNumber numberWithInt:_armorSet.setID] andSetItem:_armorSet.weapon];
        _armorSet.weapon.decorationsArray = decorations;
        for (int i = 0; i < _armorSet.weapon.num_slots; i++) {
            UIImageView *decorationView = _weaponDecorationViews[i];
            if (decorations.count >= i+1) {
                Decoration *decoration = decorations[i];
                [_allDecorations addObject:decoration];
                decorationView.image = [UIImage imageNamed:decoration.icon];
            } else {
                decorationView.image = [UIImage imageNamed:@"circle.png"];
            }
        }
    }
    
    NSArray *armorArray = [_armorSet returnNonNullArmor];
    for (int i = 0; i < armorArray.count; i++) {
        Armor *armor = armorArray[i];
        if (armor.numSlots > 0) {
            NSArray *decorations = [_dbEngine getDecorationsForArmorSet:_setID andSetItem:armor];
            if (armor.decorationsArray) {
                armor.decorationsArray = nil;
            }
            armor.decorationsArray = decorations;
            for (int i = 0; i < armor.numSlots; i++) {
                UIImageView *decorationView;
                if ([armor.slot isEqualToString:@"Head"]) {
                    decorationView = _headDecorationViews[i];
                } else if ([armor.slot isEqualToString:@"Body"]) {
                    decorationView = _bodyDecorationViews[i];
                } else if ([armor.slot isEqualToString:@"Arms"]) {
                    decorationView = _armsDecorationViews[i];
                } else if ([armor.slot isEqualToString:@"Waist"]) {
                    decorationView = _waistDecorationViews[i];
                } else if ([armor.slot isEqualToString:@"Legs"]) {
                    decorationView = _legsDecorationViews[i];
                }
                if (decorations.count >= i+1) {
                    
                    Decoration *decoration = decorations[i];
                    [_allDecorations addObject:decoration];
                    decorationView.image = [UIImage imageNamed:decoration.icon];
                } else {
                    decorationView.image = [UIImage imageNamed:@"circle.png"];
                }

                
            }
        }

    }
}

-(void)calculateSkillsForSelectedArmorSet {
    _skillDictionary = [[NSMutableDictionary alloc] init];
    if (_armorSet.weapon) {
        if (_armorSet.weapon.decorationsArray.count > 0) {
            for (Decoration *decoration in _armorSet.weapon.decorationsArray) {
                [self combineSkillsArray:decoration.skillArray];
            }
        }
    }
    
    for (Armor *armor in [_armorSet returnNonNullArmor]) {
        if (!armor.skillsArray) {
            [_dbEngine populateArmor:armor];
        }
        [self combineSkillsArray:armor.skillsArray];
        if (armor.decorationsArray.count > 0) {
            for (Decoration *decoration in armor.decorationsArray) {
                [self combineSkillsArray:decoration.skillArray];
            }
        }
    }
    
    [_statTableView reloadData];
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
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([tabBar isEqual:_armorSetTab]) {
        switch (item.tag) {
            case 1:
                [_armorStatSheet removeFromSuperview];
                [_statTableView removeFromSuperview];
                break;
            case 2:
                [self.view addSubview:_armorStatSheet];
                break;
            case 3:
                if (_armorStatSheet.superview != nil) {
                    [_armorStatSheet removeFromSuperview];
                }
                [self.view addSubview:_statTableView];
                break;
            default:
                break;
        }
    } else if ([tabBar isEqual:_equipmentSocketTab]) {
        NSArray *equipmentWithDecoration = [[_armorSet returnItemsWithDecorations] objectAtIndex:item.tag - 1];
        _displayedDecorations = equipmentWithDecoration[1];
        [_socketedTable reloadData];
    }

    [tabBar setSelectedItem:item];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_statTableView]) {
        return _skillDictionary.count;
    } else if ([tableView isEqual:_socketedTable]){
        return _displayedDecorations.count;
    } else {
        return 0;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([tableView isEqual:_statTableView]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        }

        NSArray *allNameAndValues = [_skillDictionary allValues];
        NSArray *sortedValuesArray = [allNameAndValues sortedArrayUsingComparator:^NSComparisonResult(id one, id two){
            NSArray *nameAndValueOne = (NSArray *)one;
            NSArray *nameAndValueTwo = (NSArray *)two;
            NSNumber *valueOne = nameAndValueOne[1];
            NSNumber *valueTwo = nameAndValueTwo[1];
            return [valueTwo compare:valueOne];
        }];

        NSArray *nameAndValue = sortedValuesArray[indexPath.row];
        
        cell.textLabel.text = nameAndValue[0];
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 50, cellFrame.size.height - 10, 50, 20);
        UILabel *acessoryText = [[UILabel alloc] initWithFrame:textView];
        acessoryText.textAlignment =  NSTextAlignmentRight;
        
        
        acessoryText.text = [NSString stringWithFormat:@"%@", nameAndValue[1]];
        [cell addSubview:acessoryText];
        [cell setAccessoryView: acessoryText];
        return cell;
    } else if ([tableView isEqual:_socketedTable]){
        ItemTableCell *itemCell = [tableView dequeueReusableCellWithIdentifier:@"itemCell"];
        
        if (!itemCell) {
            [tableView registerNib:[UINib nibWithNibName:@"ItemTableCell"  bundle:nil] forCellReuseIdentifier:@"itemCell"];
            itemCell = [tableView dequeueReusableCellWithIdentifier:@"itemCell"];
        }
        return itemCell;

    } else {
        return nil;
    }

}
-(void)tableView:(UITableView *)tableView willDisplayCell:(ItemTableCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_socketedTable]) {
        Decoration *decoration = _displayedDecorations[indexPath.row];
        cell.itemImageView.image = [UIImage imageNamed:decoration.icon];
        cell.itemLabel.text = decoration.name;
        UIFont *font = [cell.itemLabel.font fontWithSize:14];
        cell.itemLabel.font = font;
        
        if (decoration.skillArray.count == 1) {
            cell.itemAccessoryLabel1.hidden = YES;
            cell.itemAccessoryLabel3.hidden = YES;
            cell.itemAccessoryLabel2.hidden = NO;
            NSArray *skill1 = decoration.skillArray[0];
            cell.itemAccessoryLabel2.text = [NSString stringWithFormat:@"%@ %@", skill1[1], skill1[2]];
        } else if (decoration.skillArray.count == 2) {
            cell.itemAccessoryLabel1.hidden = NO;
            cell.itemAccessoryLabel3.hidden = NO;
            cell.itemAccessoryLabel2.hidden = YES;
            NSArray *skill1 = decoration.skillArray[0];
            NSArray *skill2 = decoration.skillArray[1];
            cell.itemAccessoryLabel1.text = [NSString stringWithFormat:@"%@ %@", skill1[1], skill1[2]];
            cell.itemAccessoryLabel3.text = [NSString stringWithFormat:@"%@ %@", skill2[1], skill2[2]];
        }
        
        
        cell.itemSubLabel.hidden = YES;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UINavigationController *nC = (UINavigationController *)_baseVC.centerViewController;
    if ([tableView isEqual:_statTableView]) {
        NSArray *allNameAndValues = [_skillDictionary allValues];
        NSArray *sortedValuesArray = [allNameAndValues sortedArrayUsingComparator:^NSComparisonResult(id one, id two){
            NSArray *nameAndValueOne = (NSArray *)one;
            NSArray *nameAndValueTwo = (NSArray *)two;
            NSNumber *valueOne = nameAndValueOne[1];
            NSNumber *valueTwo = nameAndValueTwo[1];
            return [valueTwo compare:valueOne];
        }];
        
        NSArray *nameAndValue = sortedValuesArray[indexPath.row];
        NSNumber *skillID = [[_skillDictionary allKeysForObject:nameAndValue] firstObject];
        SkillDetailViewController *sdVC = [[SkillDetailViewController alloc] init];
        sdVC.heightDifference = [self returnHeightDifference];
        sdVC.dbEngine = _dbEngine;
        sdVC.skilTreeName = nameAndValue[0];
        sdVC.skillTreeID = [skillID intValue];
        [self.navigationController pushViewController:sdVC animated:YES];
    } else if ([tableView isEqual:_socketedTable]){
        Decoration *decoration= _displayedDecorations[indexPath.row];
        decoration.componentArray = [_dbEngine getComponentsfor:decoration.itemID];
        DecorationsDetailViewController *dDVC = [[DecorationsDetailViewController alloc] init];
        dDVC.heightDifference = [self returnHeightDifference];
        dDVC.dbEngine = _dbEngine;
        dDVC.selectedDecoration = decoration;
        [nC pushViewController:dDVC animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if ([tableView isEqual:_socketedTable]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Decoration *decoration = _displayedDecorations[indexPath.row];
        Item *setItem = [_armorSet returnItemForSlot:_equipmentSocketTab.selectedItem.title];
        
        BOOL successful = [_dbEngine deleteDecoration:decoration FromSetItemWithItemID:setItem SetWithID:_setID];

        [self drawDecorationForArmorSet];
        [self calculateSkillsForSelectedArmorSet];
        [_statTableView reloadData];
        _displayedDecorations = [_armorSet returnItemForSlot:_equipmentSocketTab.selectedItem.title].decorationsArray;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)setEditing:(BOOL)flag animated:(BOOL)animated
{
    [super setEditing:flag animated:animated];
    [_socketedTable setEditing:flag animated:animated];
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
    _statTableView.frame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _armorSetTab.frame.size.height + [self returnHeightDifference], vcFrame.size.width, vcFrame.size.height - (_armorSetTab.frame.size.height + [self returnHeightDifference]));
    _equipmentSocketTab.frame = CGRectMake(self.view.frame.origin.x, _legImage.frame.origin.y + _legImage.frame.size.height + 10, _baseVC.rightDrawerViewController.view.frame.size.width, 49);
    _socketedTable.frame = CGRectMake(vcFrame.origin.x, _equipmentSocketTab.frame.origin.y + _equipmentSocketTab.frame.size.height, _baseVC.rightDrawerViewController.view.frame.size.width, vcFrame.size.height - (_armorSetTab.frame.size.height + [self returnHeightDifference]));
    
    if (_armorStatSheet.superview || _statTableView.superview) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    
    [self setUpArmorSetView];
    [self drawDecorationForArmorSet];
    
}

-(void)reDrawEverything {
    [self viewDidLayoutSubviews];
    
    if (_equipmentSocketTab.selectedItem) {
        NSArray *itemsWithDecorations = [_armorSet returnItemsWithDecorations];
        NSArray *itemWithDecoration = itemsWithDecorations[_equipmentSocketTab.selectedItem.tag - 1];
        _displayedDecorations = itemWithDecoration[1];
        [_socketedTable reloadData];
    } else {
        [self setTabBarItemsForEquipmentTabBar];
    }

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
    _minDefense = 0;
    _maxDefense = 0;
    _fireRes = 0;
    _waterRes = 0;
    _thunderRes = 0;
    _iceRes = 0;
    _dragonRes = 0;
    _numSlots = 0;
    
    for (Armor *armor in armorArray) {
        _minDefense += armor.defense;
        _maxDefense += armor.maxDefense;
        _fireRes += armor.fireResistance;
        _waterRes += armor.waterResistance;
        _thunderRes += armor.thunderResistance;
        _iceRes += armor.iceResistance;
        _dragonRes += armor.dragonResistance;
        _numSlots += armor.numSlots;
    }
    
}


@end

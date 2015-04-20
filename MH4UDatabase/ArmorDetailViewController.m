//
//  ArmorDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ArmorDetailViewController.h"
#import "ItemDetailViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"
#import "SkillDetailViewController.h"
#import "ItemTableView.h"

@interface ArmorDetailViewController ()
@property (strong, nonatomic) DetailedArmorView *statView;
@property (strong, nonatomic) NSArray *allViews;
@property (strong, nonatomic) UITabBar *armorDetailTab;
@property (strong, nonatomic) UITableView *skillTable;
@property (strong, nonatomic) ItemTableView *componentTable;
@property (strong, nonatomic) UIAlertView *doubleCheckAlert;
@property (strong, nonatomic) NSArray *selectedSet;
@end


@implementation ArmorDetailViewController

#pragma mark - Setup Views
-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_armorDetailTab) {
        _armorDetailTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
        UITabBarItem *statSheet = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:4];
        UITabBarItem *skillSheet = [[UITabBarItem alloc] initWithTitle:@"Skills" image:nil tag:5];
        UITabBarItem *componentSheet = [[UITabBarItem alloc] initWithTitle:@"Components" image:nil tag:6];
        
        _armorDetailTab.delegate = self;
        [_armorDetailTab setItems:@[statSheet, skillSheet, componentSheet]];
        [_armorDetailTab setSelectedItem:statSheet];
    }
}

-(void)setUpViewsWithFrame:(CGRect)tableFrame {
    _skillTable = [[UITableView alloc] initWithFrame:tableFrame];
    _skillTable.dataSource = self;
    _skillTable.delegate = self;
    
    _componentTable = [[ItemTableView alloc] initWithFrame:tableFrame andNavigationController:self.navigationController andDBEngine:_dbEngine];
    _componentTable.allItems = _selectedArmor.componentArray;
    _componentTable.accessoryType = @"Quantity";
    
    
    _statView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedArmorView" owner:self options:nil] lastObject];
    _statView.frame = tableFrame;
    
    _allViews = @[_statView, _skillTable, _componentTable];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem , [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addArmorToArmorBuilder)]];
    [_dbEngine populateArmor:_selectedArmor];
    self.title = NSLocalizedString(_selectedArmor.name, _selectedArmor.name);

    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    
    [self setUpTabBarWithFrame:tabBarFrame];
    [self setUpViewsWithFrame:tablewithTabbar];

    [_statView populateArmor:_selectedArmor];
    [self.view addSubview:_statView];
    [self.view addSubview:_armorDetailTab];
}

#pragma mark - Tab Bar Methods
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

#pragma mark - Tableview Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_skillTable]) {
        return _selectedArmor.skillsArray.count;
    } else  {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_skillTable]) {
        NSArray *skillArray = _selectedArmor.skillsArray[indexPath.row];
        SkillDetailViewController *sdVC = [[SkillDetailViewController alloc] init];
        sdVC.heightDifference = _heightDifference;
        sdVC.dbEngine = _dbEngine;
        sdVC.skilTreeName = [skillArray objectAtIndex:1];
        NSNumber *skillTreeID = [skillArray objectAtIndex:0];
        sdVC.skillTreeID = [skillTreeID intValue];
        [self.navigationController pushViewController:sdVC animated:YES];
            
        }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"armorCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"armorCell"];
    }

    if ([tableView isEqual:_skillTable]) {
        NSArray *skillArray = _selectedArmor.skillsArray[indexPath.row];
        NSString *detailLabel = [NSString stringWithFormat:@"%@", [skillArray objectAtIndex:1]];
        cell.textLabel.text = detailLabel;
        
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 50, cellFrame.size.height - 10, 50, 20);
        UILabel *acessoryText = [[UILabel alloc] initWithFrame:textView];
        acessoryText.textAlignment =  NSTextAlignmentRight;
        
        
        acessoryText.text = [NSString stringWithFormat:@"%@",[skillArray objectAtIndex:2]];
        [cell addSubview:acessoryText];
        [cell setAccessoryView: acessoryText];
    }
    
    return cell;
}

#pragma mark - Helper Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeViewsFromDetail {
    for (UIView *view in _allViews) {
        if (view.superview != nil) {
            [view removeFromSuperview];
        }
    }
}

-(void)viewWillLayoutSubviews {
    CGRect vcFrame = self.view.frame;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    int heightdifference = navBar.frame.size.height + statusBar.size.height;
    
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference, vcFrame.size.width, 49);
    _armorDetailTab.frame = tabBarFrame;
    
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - (heightdifference + tabBarFrame.size.height));
    
    for (UIView *view in _allViews) {
        view.frame = tablewithTabbar;
    }
}

-(void)addArmorToArmorBuilder{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_selectedArmor.name message:[NSString stringWithFormat:@"Would you like to add %@ to a custom armor set?", _selectedArmor.name] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:_doubleCheckAlert]) {
        if (buttonIndex == 1) {
            BOOL successful = [_dbEngine addArmor:_selectedArmor toArmorSetWithID:_selectedSet[0]];
            [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Your update was %@",successful ? @"Successful" : @"Failed"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    } else {
        if (buttonIndex == 1) {
            NSArray *allSets = [_dbEngine getAllArmorSets];
            if (allSets.count <= 0) {
                [[[UIAlertView alloc] initWithTitle:@"No Custom Sets" message:@"Please add a custom set before trying to add items to it" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                return;
            }
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Which Armor Set Would You Like to Add to?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
            
            for (NSArray *set in allSets) {
                [actionSheet addButtonWithTitle:set[1]];
            }
            
            actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
            [actionSheet showInView:self.view];
        }
    }

    
    
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger cancelIndex = [actionSheet cancelButtonIndex];
    if (buttonIndex != cancelIndex) {
        NSArray *allSets = [_dbEngine getAllArmorSets];
        _selectedSet = allSets[buttonIndex];
        
        BOOL exists = [_dbEngine checkArmor:_selectedArmor atArmorSetWithID:_selectedSet[0]];
        
        if (!exists) {
            BOOL successful = [_dbEngine addArmor:_selectedArmor toArmorSetWithID:_selectedSet[0]];
            [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Your update was %@",successful ? @"Successful" : @"Failed"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            _doubleCheckAlert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:[NSString stringWithFormat:@"This Set Already Has a Piece in the %@ Slot", _selectedArmor.slot] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
            [_doubleCheckAlert show];
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

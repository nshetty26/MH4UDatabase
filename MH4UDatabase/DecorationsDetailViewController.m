//
//  DecorationsDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "DecorationsDetailViewController.h"
#import "ItemTableView.h"
#import "MH4UDBEntity.h"
#import "ItemDetailViewController.h"
#import "SkillDetailViewController.h"
#import "MH4UDBEngine.h"

@interface DecorationsDetailViewController ()
@property (nonatomic) UITableView *skillTable;
@property (nonatomic) ItemTableView *componentTable;
@property (nonatomic) UITabBar *decorationDetailTab;
@property (nonatomic) DetailedItemView *detailItemView;
@property (nonatomic) NSArray *allViews;
@property (nonatomic) NSArray *selectedSet;
@property (nonatomic) UIAlertView *doubleCheckAlert;
@property (nonatomic) UIActionSheet *armorSelectSheet;

@end

@implementation DecorationsDetailViewController

#pragma mark - Setup Views
-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_decorationDetailTab) {
        _decorationDetailTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
        UITabBarItem *statSheet = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:4];
        UITabBarItem *skillSheet = [[UITabBarItem alloc] initWithTitle:@"Skills" image:nil tag:5];
        UITabBarItem *componentSheet = [[UITabBarItem alloc] initWithTitle:@"Components" image:nil tag:6];
        
        _decorationDetailTab.delegate = self;
        [_decorationDetailTab setItems:@[statSheet, skillSheet, componentSheet]];
        [_decorationDetailTab setSelectedItem:statSheet];
    }
}

-(void)setUpViewsWithFrame:(CGRect)tableFrame {
    _detailItemView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedItemView" owner:self options:nil] lastObject];
    _detailItemView.frame = tableFrame;
    [_detailItemView populateViewWithItem:(Item *)_selectedDecoration];
    
    _skillTable = [[UITableView alloc] initWithFrame:tableFrame];
    _skillTable.dataSource = self;
    _skillTable.delegate = self;
    
    _componentTable = [[ItemTableView alloc] initWithFrame:tableFrame andNavigationController:self.navigationController andDBEngine:_dbEngine];
    _componentTable.allItems = _selectedDecoration.componentArray;
    _componentTable.accessoryType = @"Quantity";
    
    _allViews = @[_detailItemView, _skillTable, _componentTable];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem , [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDecorationToArmorSet)]];
    self.title = NSLocalizedString(_selectedDecoration.name, _selectedDecoration.name);
    [self populateDecorationComponent];
    // Do any additional setup after loading the view.
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    [self setUpTabBarWithFrame:tabBarFrame];
    
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    [self setUpViewsWithFrame:tablewithTabbar];

    [self.view addSubview:_decorationDetailTab];
    [self.view addSubview:_detailItemView];

}

#pragma mark - Tab Bar Methods
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([tabBar isEqual:_decorationDetailTab]) {
        [self removeViewsFromDetail];
        switch (item.tag) {
            case 4:
                [self.view addSubview:_detailItemView];
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

#pragma mark - Table View Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_skillTable]) {
        return _selectedDecoration.skillArray.count;
    } else  {
        return 0;
    }
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if ([tableView isEqual:_skillTable]) {
        NSArray *skillArray = _selectedDecoration.skillArray[indexPath.row];
        NSString *detailLabel = [NSString stringWithFormat:@"%@", [skillArray objectAtIndex:1]];
        cell.textLabel.text = detailLabel;
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 50, cellFrame.size.height - 10, 30, 20);
        UILabel *acessoryText = [[UILabel alloc] initWithFrame:textView];
        [cell addSubview:acessoryText];
        acessoryText.textAlignment =  NSTextAlignmentRight;
        acessoryText.text = [NSString stringWithFormat:@"%@", skillArray[2]];
        [cell setAccessoryView: acessoryText];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_skillTable]) {
        NSArray *skillArray = _selectedDecoration.skillArray[indexPath.row];
        SkillDetailViewController *sdVC = [[SkillDetailViewController alloc] init];
        sdVC.heightDifference = _heightDifference;
        sdVC.dbEngine = _dbEngine;
        sdVC.skilTreeName = skillArray[1];
        NSNumber *skillTreeID = skillArray[0];
        sdVC.skillTreeID = [skillTreeID intValue];
        [self.navigationController pushViewController:sdVC animated:YES];
    }
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
    _decorationDetailTab.frame = tabBarFrame;
    
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - (heightdifference + tabBarFrame.size.height));
    
    for (UIView *view in _allViews) {
        view.frame = tablewithTabbar;
    }
}

-(void)populateDecorationComponent {
    NSArray *componentArray = [_dbEngine getComponentsfor:_selectedDecoration.itemID];
    _selectedDecoration.componentArray = componentArray;
}

-(void)addDecorationToArmorSet {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_selectedDecoration.name message:[NSString stringWithFormat:@"Would you like to add %@ to a custom armor set?", _selectedDecoration.name] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:_doubleCheckAlert]) {
        if (buttonIndex == 1) {
//            BOOL successful = [_dbEngine addArmor:_selectedArmor toArmorSetWithID:_selectedSet[0]];
//            [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Your update was %@",successful ? @"Successful" : @"Failed"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    } else {
        if (buttonIndex == 1) {
            NSArray *allSets = [_dbEngine getAllArmorSets];
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
        if ([actionSheet isEqual:_armorSelectSheet]) {
            NSArray *titleComponents = [[actionSheet buttonTitleAtIndex:buttonIndex] componentsSeparatedByString:@" "];
            
            NSString *armorSlots = titleComponents[1];
            armorSlots = [armorSlots stringByReplacingOccurrencesOfString:@"[" withString:@""];
            armorSlots = [armorSlots stringByReplacingOccurrencesOfString:@"]" withString:@""];
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            
            NSString *armorSetSlot = titleComponents[0];
            NSNumber *availableSlots = [f numberFromString:armorSlots];
            
            if (availableSlots > 0) {
                BOOL successful = [_dbEngine addDecoration:_selectedDecoration ToSlot:armorSetSlot andArmorSetWithID:_selectedSet[0]];
                [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Your update was %@",successful ? @"Successful" : @"Failed"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
        } else {
            NSArray *allSets = [_dbEngine getAllArmorSets];
            _selectedSet = allSets[buttonIndex];
            
            NSArray *availableEquipment = [_dbEngine checkArmorSetForSlotsWithSetID:_selectedSet[0]];
            
            if (availableEquipment.count > 0) {
                _armorSelectSheet = [[UIActionSheet alloc] initWithTitle:@"Which Slot Would You Like to Add To?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
                
                for (NSArray *equipment in availableEquipment) {
                    [_armorSelectSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ [%@]", equipment[0], equipment[1]]];
                }
                
                _armorSelectSheet.cancelButtonIndex = [_armorSelectSheet addButtonWithTitle:@"Cancel"];
                [_armorSelectSheet showInView:self.view];
            }
        }

//        
//        BOOL exists = [_dbEngine checkArmor:_selectedArmor atArmorSetWithID:_selectedSet[0]];
//        
//        if (!exists) {
//            BOOL successful = [_dbEngine addArmor:_selectedArmor toArmorSetWithID:_selectedSet[0]];
//            [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Your update was %@",successful ? @"Successful" : @"Failed"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        } else {
//            _doubleCheckAlert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:[NSString stringWithFormat:@"This Set Already Has a Piece in the %@ Slot", _selectedArmor.slot] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
//            [_doubleCheckAlert show];
//        }
        
    }
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

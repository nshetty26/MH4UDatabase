//
//  ItemDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/9/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

/*
 SELECT items.name, skill_trees.name, point_value FROM item_to_skill_tree inner join skill_trees on skill_trees._id = item_to_skill_tree.skill_tree_id inner join items on items._id = item_to_skill_tree.item_id 
 */

#import "ItemDetailViewController.h"
#import "CombiningViewController.h"
#import "MenuViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"
#import "MenuViewController.h"
#import "ItemsViewController.h"
#import "LocationDetailViewController.h"
#import "ArmorDetailViewController.h"
#import "MonsterDetailViewController.h"
#import "QuestDetailViewController.h"
#import "WeaponDetailViewController.h"
#import "DecorationsDetailViewController.h"
#import "CombiningTableView.h"
#import "ItemTableView.h"

@interface ItemDetailViewController ()
@property (nonatomic) DetailedItemView *detailItemView;
@property (nonatomic) NSArray *allViews;
@property (nonatomic) UITabBarItem *itemDetail;
@property (nonatomic) UITabBarItem *combining;
@property (nonatomic) UITabBarItem *usage;
@property (nonatomic) UITabBarItem *monster;
@property (nonatomic) UITabBarItem *quest;
@property (nonatomic) UITabBarItem *location;
@property (nonatomic) CombiningTableView *combiningTable;
@property (nonatomic) ItemTableView *usageTable;
@property (nonatomic) UITableView *monsterDropTable;
@property (nonatomic) UITableView *questRewardTable;
@property (nonatomic) UITableView *locationTable;
@property (nonatomic) UITableView *skillsTable;
@property (nonatomic) UITableView *componentTable;
@property (nonatomic) UITabBar *itemDetailBar;
@end

@implementation ItemDetailViewController

#pragma mark - Setup Views
-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_itemDetailBar) {
        _itemDetailBar = [[UITabBar alloc] initWithFrame:tabBarFrame];
        _itemDetailBar.delegate = self;
        
        [self setDetailTabBarforItem:_selectedItem];
        [_itemDetailBar setSelectedItem:_itemDetail];
    }
}

-(void)setUpViewsWithFrame:(CGRect)tableFrame {
    NSMutableArray *allViews = [[NSMutableArray alloc] init];
    
    _detailItemView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedItemView" owner:self options:nil] lastObject];
    _detailItemView.frame = tableFrame;
    [_detailItemView populateViewWithItem:_selectedItem];
    [allViews addObject:_detailItemView];
    
    if (_combining) {
        _combiningTable = [[CombiningTableView alloc] initWithFrame:tableFrame andNavigationController:self.navigationController andDBEngine:_dbEngine];
        _combiningTable.allCombined = _selectedItem.combinedItemsArray;
        [allViews addObject:_combiningTable];
    }

    if (_usage) {
        _usageTable = [[ItemTableView alloc] initWithFrame:tableFrame andNavigationController:self.navigationController andDBEngine:_dbEngine];
        _usageTable.accessoryType = @"Quantity";
        _usageTable.allItems = _selectedItem.usageItemsArray;
        [allViews addObject:_usageTable];
    }

    if (_monster) {
        _monsterDropTable = [[UITableView alloc] initWithFrame:tableFrame];
        _monsterDropTable.dataSource = self;
        _monsterDropTable.delegate = self;
        [allViews addObject:_monsterDropTable];
    }

    if (_quest) {
        _questRewardTable = [[UITableView alloc] initWithFrame:tableFrame];
        _questRewardTable.dataSource = self;
        _questRewardTable.delegate = self;
        [allViews addObject:_questRewardTable];
    }

    if (_location) {
        _locationTable = [[UITableView alloc] initWithFrame:tableFrame];
        _locationTable.dataSource = self;
        _locationTable.delegate = self;
        [allViews addObject:_locationTable];
    }
    
    _allViews = allViews;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(_selectedItem.name, _selectedItem.name);
    [self populateDetailsforItem:_selectedItem];
    
    CGRect tabBarFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + _heightDifference , self.view.frame.size.width, 49);
    [self setUpTabBarWithFrame:tabBarFrame];
    
    CGRect vcFrame = CGRectMake(self.view.frame.origin.x, tabBarFrame.origin.y + tabBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [self setUpViewsWithFrame:vcFrame];

    [self.view addSubview:_detailItemView];
    [self.view addSubview:_itemDetailBar];


}

#pragma mark - Tab Bar Methods
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self removeTableViewsFromDetail];
    switch (item.tag) {
        case 1:
            [self.view addSubview:_detailItemView];
            break;
        case 2:
            
            [self.view addSubview:_combiningTable];
            break;
        case 3:
            [self.view addSubview:_usageTable];
            break;
        case 4:
            [self.view addSubview:_monsterDropTable];
            break;
        case 5:
            [self.view addSubview:_questRewardTable];
            break;
        case 6:
            [self.view addSubview:_locationTable];
            break;
        default:
            break;
    }
    [self.view addSubview:_itemDetailBar];
}

#pragma mark - Table View Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_usageTable]) {
        return _selectedItem.usageItemsArray.count;
    } else if ([tableView isEqual:_monsterDropTable]) {
        return _selectedItem.monsterDropsArray.count;
    } else if ([tableView isEqual:_questRewardTable]) {
        return _selectedItem.questRewardsArray.count;
    } else if ([tableView isEqual:_locationTable]) {
        return _selectedItem.locationsArray.count;
    } else {
        return 0;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"itemIdentifier"];
    }
    
   if ([tableView isEqual:_monsterDropTable]){
        NSArray *monsterDropArray = _selectedItem.monsterDropsArray[indexPath.row];
        NSString *label = [NSString stringWithFormat:@"%@", monsterDropArray[0]];
        cell.textLabel.text = label;
        NSString *detailLabel = [NSString stringWithFormat:@"%@ %@", monsterDropArray[1], monsterDropArray[2]];
        cell.textLabel.text = label;
        cell.detailTextLabel.text = detailLabel;
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 60, cellFrame.size.height - 10, 30, 20);
        UILabel *acessoryText = [[UILabel alloc] initWithFrame:textView];
        [cell addSubview:acessoryText];
        acessoryText.textAlignment =  NSTextAlignmentRight;
        acessoryText.text = [NSString stringWithFormat:@"%@%@",monsterDropArray[4], @"%"];
        UIFont *font = [acessoryText.font fontWithSize:11];
        acessoryText.font = font;
        cell.accessoryView = acessoryText;
        cell.imageView.image = [UIImage imageNamed:monsterDropArray[5]];

        return cell;
    }
    
    else if ([tableView isEqual:_questRewardTable]){
        NSArray *questRewardArray = _selectedItem.questRewardsArray[indexPath.row];
        NSString *label = [NSString stringWithFormat:@"%@", questRewardArray[0]];
        NSString *quest = [questRewardArray[3] isEqualToString:@"A"] ? @"Main" : @"Sub";
        NSString *detailLabel = [NSString stringWithFormat:@"%@ %@ %@ Quest", questRewardArray[1], questRewardArray[2], quest];
        cell.textLabel.text = label;
        cell.detailTextLabel.text = detailLabel;
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 65, cellFrame.size.height - 10, 35, 20);
        UILabel *accessoryText = [[UILabel alloc] initWithFrame:textView];
        [cell addSubview:accessoryText];
        accessoryText.textAlignment =  NSTextAlignmentRight;
        accessoryText.text = [NSString stringWithFormat:@"%@%@",questRewardArray[5], @"%"];
        UIFont *font = [accessoryText.font fontWithSize:11];
        accessoryText.font = font;
        cell.accessoryView = accessoryText;

        return cell;
    }
    
    else if ([tableView isEqual:_locationTable]){
        NSArray *locationArray = _selectedItem.locationsArray[indexPath.row];
        NSString *label = [NSString stringWithFormat:@"%@", locationArray[0]];
        NSString *detailLabel = [NSString stringWithFormat:@"%@ %@", locationArray[1], locationArray[2]];
        cell.textLabel.text = label;
        cell.detailTextLabel.text = detailLabel;
        cell.imageView.image = [UIImage imageNamed:locationArray[7]];
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 80, cellFrame.size.height - 10, 70, 20);
        UILabel *accessoryText = [[UILabel alloc] initWithFrame:textView];
        [cell addSubview:accessoryText];
        accessoryText.textAlignment =  NSTextAlignmentRight;
        accessoryText.text = [NSString stringWithFormat:@"%@ %@%@",locationArray[3], locationArray[5], @"%"];
        UIFont *font = [accessoryText.font fontWithSize:11];
        accessoryText.font = font;
        cell.accessoryView = accessoryText;
        return cell;
    }
    
    else {
        return nil;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"itemIdentifier"];
    }
    
    if ([tableView isEqual:_monsterDropTable]){
        NSArray *monsterDropArray = _selectedItem.monsterDropsArray[indexPath.row];
        Monster *monster = [[_dbEngine retrieveMonsters:monsterDropArray[6]] firstObject];
        MonsterDetailViewController *mDVC = [[MonsterDetailViewController alloc] init];
        mDVC.selectedMonster = monster;
        mDVC.heightDifference = _heightDifference;
        mDVC.dbEngine = _dbEngine;
        [self.navigationController pushViewController:mDVC animated:YES];
    }
    
    else if ([tableView isEqual:_questRewardTable]){
        NSArray *questRewardArray = _selectedItem.questRewardsArray[indexPath.row];
        Quest *quest = [[Quest alloc] init];
        quest.questID = [questRewardArray[6] intValue];
        quest.name = questRewardArray[0];
        quest.hub = questRewardArray[1];
        quest.stars = [questRewardArray[2] intValue];
        
        QuestDetailViewController *qDVC = [[QuestDetailViewController alloc] init];
        qDVC.dbEngine = _dbEngine;
        qDVC.heightDifference = _heightDifference;
        qDVC.selectedQuest = quest;
        [self.navigationController pushViewController:qDVC animated:YES];
    }
    
    else if ([tableView isEqual:_locationTable]){
        NSArray *locationArray = _selectedItem.locationsArray[indexPath.row];
        Location *location = [[Location alloc] init];
        location.locationID = [locationArray[6] intValue];
        location.locationName = locationArray[0];
        location.locationIcon = locationArray[7];
        LocationDetailViewController *lDVC = [[LocationDetailViewController alloc] init];
        lDVC.heightDifference = _heightDifference;
        lDVC.selectedLocation = location;
        lDVC.dbEngine = _dbEngine;
        [self.navigationController pushViewController:lDVC animated:YES];
    }
}


#pragma mark - Helper Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setDetailTabBarforItem:(Item *)item {
    _itemDetail = [[UITabBarItem alloc] initWithTitle:@"Item Detail" image:nil tag:1];
    [_itemDetailBar setSelectedItem:_itemDetail];
    NSMutableArray *tabItems = [[NSMutableArray alloc] initWithObjects:_itemDetail  , nil];
    


    if (item.combinedItemsArray.count > 0) {
        _combining = [[UITabBarItem alloc] initWithTitle:@"Combining" image:nil tag:2];
        [tabItems addObject:_combining];
    }
    
    if (item.usageItemsArray.count > 0) {
        _usage = [[UITabBarItem alloc] initWithTitle:@"Usage" image:nil tag:3];
        [tabItems addObject:_usage];
    }
    
    if (item.monsterDropsArray.count > 0) {
        _monster = [[UITabBarItem alloc] initWithTitle:@"Monster Drop" image:nil tag:4];
        [tabItems addObject:_monster];
    }
    
    if (item.questRewardsArray.count > 0) {
        _quest = [[UITabBarItem alloc] initWithTitle:@"Quest Reward" image:nil tag:5];
        [tabItems addObject:_quest];
    }
    
    if (item.locationsArray.count > 0) {
        _location = [[UITabBarItem alloc] initWithTitle:@"Location" image:nil tag:6];
        [tabItems addObject:_location];
    }
    
    _itemDetailBar.items = tabItems;
}

-(void)removeTableViewsFromDetail {
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
    _itemDetailBar.frame = tabBarFrame;
    
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - (heightdifference + tabBarFrame.size.height));
    
    for (UIView *view in _allViews) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            [tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        view.frame = tablewithTabbar;
    }
}

-(void)populateDetailsforItem:(Item*)item{
    [_dbEngine getCombiningItemsForItem:item];
    [_dbEngine getUsageItemsForItem:item];
    [_dbEngine getMonsterDropsForItem:item];
    [_dbEngine getQuestRewardsForItem:item];
    [_dbEngine getLocationsForItem:item];
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

@implementation DetailedItemView

-(void)populateViewWithItem:(Item *)item {
    _iconImageView.image = [UIImage imageNamed:item.icon];
    _itemName.text = item.name;
    _rareLabel.text = [NSString stringWithFormat:@"%i", item.rarity];
    _capacityLabel.text = [NSString stringWithFormat:@"%i", item.capacity];
    _priceLabel.text = [NSString stringWithFormat:@"%i", item.price];
    _salePriceLabel.text = [NSString stringWithFormat:@"%i", item.salePrice];
    _itemDescription.text = [NSString stringWithFormat:@"%@", item.itemDescription];;
    
}

@end

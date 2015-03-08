//
//  ItemDisplay.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/7/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//


/*
 Location
 SELECT item_id, locations.name, area, site, rank, quantity, percentage from gathering
 INNER JOIN locations
 ON gathering.location_id = locations._id
 
 Quest
 select quests.name, items.name, reward_slot, percentage, stack_size from quest_rewards
 inner join quests
 on quest_rewards.quest_id = quests._id
 inner join items
 on quest_rewards.item_id = items._id
 
 Monster
 SELECT items.name, condition, monsters.name, rank, stack_size, percentage from hunting_rewards
 inner join monsters
 on monsters._id = hunting_rewards.monster_id
 inner join items
 on items._id = hunting_rewards.item_id
 
 Usage
 
 select i2.name, i1.name, components.quantity, components.type from components
 inner join items as i1
 on i1._id = components.component_item_id
 inner join items as i2
 on i2._id = components.created_item_id
 where i1.name = 'Iron Ore'
 
 */

#import "ItemDisplay.h"
#import "DetailViewController.h"
#import "MenuViewController.h"
#import "MH4UDBEngine.h"

@interface ItemDisplay ()
@property (nonatomic) NSArray *displayedItems;
@property (nonatomic) UITableView *itemTable;
@property (nonatomic) UITableView *combiningTable;
@property (nonatomic) UITableView *usageTable;
@property (nonatomic) UITableView *monsterDropTable;
@property (nonatomic) UITableView *questRewardTable;
@property (nonatomic) UITableView *locationTable;
@property (nonatomic) Item *selectedItem;
@property (nonatomic) ItemView *detailItemView;
@property (nonatomic) CGRect properFrame;
@property (nonatomic) UISearchBar *itemSearch;
@property (nonatomic) UITabBar *itemDetailBar;
@property (nonatomic) UITabBarItem *itemDetail;
@property (nonatomic) UITabBarItem *combining;
@property (nonatomic) UITabBarItem *usage;
@property (nonatomic) UITabBarItem *monster;
@property (nonatomic) UITabBarItem *quest;
@property (nonatomic) UITabBarItem *location;
@end

@implementation ItemDisplay

-(void)setupItemDisplay {
    _displayedItems = _allItems;
    CGRect vcFrame = _dVC.view.frame;
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _dVC.heightDifference, vcFrame.size.width, 44);
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _dVC.heightDifference + 44, vcFrame.size.width, vcFrame.size.height);
    _itemTable = [[UITableView alloc] initWithFrame:tableWithSearch];
    _itemTable.dataSource = self;
    _itemTable.delegate = self;
    
    _itemSearch = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _itemSearch.delegate = self;
    
    _combiningTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _combiningTable.dataSource = self;
    _combiningTable.delegate = self;
    
    _usageTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _usageTable.dataSource = self;
    _usageTable.delegate = self;
    
    _monsterDropTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _monsterDropTable.dataSource = self;
    _monsterDropTable.delegate = self;
    
    _questRewardTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _questRewardTable.dataSource = self;
    _questRewardTable.delegate = self;
    
    _locationTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
    _locationTable.dataSource = self;
    _locationTable.delegate = self;
    
    _itemDetailBar = [[UITabBar alloc] initWithFrame:_dVC.tabBarFrame];
    
    _itemDetail = [[UITabBarItem alloc] initWithTitle:@"Item Detail" image:nil tag:1];
    _combining = [[UITabBarItem alloc] initWithTitle:@"Combining" image:nil tag:2];
    _usage = [[UITabBarItem alloc] initWithTitle:@"Usage" image:nil tag:3];
    _monster = [[UITabBarItem alloc] initWithTitle:@"Monster Drop" image:nil tag:4];
    _quest = [[UITabBarItem alloc] initWithTitle:@"Quest Reward" image:nil tag:5];
    _location = [[UITabBarItem alloc] initWithTitle:@"Location" image:nil tag:6];
    
    [_itemDetailBar setItems:@[_itemDetail, _combining, _usage, _monster, _quest, _location]];
    _itemDetailBar.delegate = self;
    
    [_dVC.view addSubview:_itemTable];
    [_dVC.view addSubview:_itemSearch];
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self removeTableViewsFromDetail];
    switch (item.tag) {
        case 1:
            [_dVC.view addSubview:_detailItemView];
            break;
        case 2:

            [_dVC.view addSubview:_combiningTable];
            break;
        case 3:
            [_dVC.view addSubview:_usageTable];
            break;
        case 4:
            [_dVC.view addSubview:_monsterDropTable];
            break;
        case 5:
            [_dVC.view addSubview:_questRewardTable];
            break;
        case 6:
            [_dVC.view addSubview:_locationTable];
            break;
        default:
            break;
    }
    [_dVC.view addSubview:_itemDetailBar];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        _displayedItems = _allItems;
        [_itemTable reloadData];
        return;
    }
    NSArray *searchedItems = [_allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        Item *item = (Item*)evaluatedObjected;
        if ([item.name.lowercaseString containsString:searchText.lowercaseString]) {
            return YES;
        } else {
            return NO;
        }
        
    }]];
    
    _displayedItems = searchedItems;
    [_itemTable reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_itemTable]) {
        return _displayedItems.count;
    } else if ([tableView isEqual:_combiningTable]) {
        return _selectedItem.combinedItemsArray.count;
    } else if ([tableView isEqual:_usageTable]) {
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
    if ([tableView isEqual:_itemTable]) {
        Item *item = _displayedItems[indexPath.row];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemIdentifier"];
        cell.imageView.image = [UIImage imageNamed:item.icon];
        cell.textLabel.text = item.name;
        return cell;
    }
    
    else if ([tableView isEqual:_combiningTable]) {
        CombiningCell *combiningCell = [tableView dequeueReusableCellWithIdentifier:@"combiningCell"];
        
        if (!combiningCell) {
            [tableView registerNib:[UINib nibWithNibName:@"UICombiningTableCell"  bundle:nil] forCellReuseIdentifier:@"combiningCell"];
            combiningCell = [tableView dequeueReusableCellWithIdentifier:@"combiningCell"];
        }
        return combiningCell;
    }
    
    else if ([tableView isEqual:_usageTable]){
        NSArray *usageArray = _selectedItem.usageItemsArray[indexPath.row];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemIdentifier"];
        NSString *label = [NSString stringWithFormat:@"%@: %@ %@", usageArray[0], usageArray[1], usageArray[2]];
        cell.textLabel.text = label;
        return cell;
    }
    
    else if ([tableView isEqual:_monsterDropTable]){
        NSArray *monsterDropArray = _selectedItem.monsterDropsArray[indexPath.row];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemIdentifier"];
        NSString *label = [NSString stringWithFormat:@" %@: %@ %@, %@ %@%@", monsterDropArray[0], monsterDropArray[1], monsterDropArray[2], monsterDropArray[3], monsterDropArray[4], @"%"];
        cell.textLabel.text = label;
        return cell;
    }
    
    else if ([tableView isEqual:_questRewardTable]){
        NSArray *questRewardArray = _selectedItem.questRewardsArray[indexPath.row];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemIdentifier"];
        NSString *label = [NSString stringWithFormat:@" %@: %@ %@, %@ %@ %@%@", questRewardArray[0], questRewardArray[1], questRewardArray[2], questRewardArray[3], questRewardArray[4], questRewardArray[5], @"%"];
        cell.textLabel.text = label;
        return cell;
    }
    
    else if ([tableView isEqual:_locationTable]){
        NSArray *locationArray = _selectedItem.locationsArray[indexPath.row];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemIdentifier"];
        NSString *label = [NSString stringWithFormat:@" %@: %@ %@, %@ %@ %@%@", locationArray[0], locationArray[1], locationArray[2], locationArray[3], locationArray[4], locationArray[5], @"%"];
        cell.textLabel.text = label;
        return cell;
    }
    
    else {
        return nil;
    }
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(CombiningCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_combiningTable]) {
        NSArray *combiningArray = _selectedItem.combinedItemsArray[indexPath.row];
        NSArray *combinedItemInfo = [_dbEngine infoForCombinedTableCellforItemID:combiningArray[0]];
        NSArray *item1Info = [_dbEngine infoForCombinedTableCellforItemID:combiningArray[1]];
        NSArray *item2Info = [_dbEngine infoForCombinedTableCellforItemID:combiningArray[2]];
        
        cell.combinedItemName.text = combinedItemInfo[0];
        cell.combinedImageView.image = [UIImage imageNamed:combinedItemInfo[1]];
        
        cell.item1Name.text = item1Info[0];
        cell.item2Name.text = item2Info[0];
        cell.maxCombined.text = [NSString stringWithFormat:@"Max: %@", combiningArray[4]];
        cell.percentageCombined.text = [NSString stringWithFormat:@"%@%@", combiningArray[5], @"%"];
        cell.item1ImageView.image = [UIImage imageNamed:item1Info[1]];
        cell.item2ImageView.image = [UIImage imageNamed:item2Info[1]];
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_itemTable]) {
        Item *item = _displayedItems[indexPath.row];
        [self populateDetailsforItem:item];
        _detailItemView = [[[NSBundle mainBundle] loadNibNamed:@"ItemView" owner:self options:nil] lastObject];
        [_detailItemView populateViewWithItem:item];
        _detailItemView.frame = _dVC.tableFrame;
        _selectedItem = item;
        [_itemTable removeFromSuperview];
        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeItemDetail)];
        _dVC.navigationItem.rightBarButtonItems = @[close];
        [self setDetailTabBarforItem:item];
        [_dVC.view addSubview:_detailItemView];
        [_dVC.view addSubview:_itemDetailBar];
        
        [_combiningTable reloadData];
    }

}

-(void)closeItemDetail
{
    [_itemDetailBar removeFromSuperview];
    [_detailItemView removeFromSuperview];
    [_combiningTable removeFromSuperview];
    
    [_dVC.view addSubview:_itemTable];
    [_dVC.view addSubview:_itemSearch];
    
    _dVC.navigationItem.rightBarButtonItems = nil;
}

-(void)populateDetailsforItem:(Item*)item{
    [_dbEngine getCombiningItemsForItem:item];
    [_dbEngine getUsageItemsForItem:item];
    [_dbEngine getMonsterDropsForItem:item];
    [_dbEngine getQuestRewardsForItem:item];
    [_dbEngine getLocationsForItem:item];
}

-(void)removeTableViewsFromDetail {
    NSArray *allTableViews = @[_itemTable, _combiningTable, _usageTable, _monsterDropTable, _questRewardTable, _locationTable];
    
    for (UITableView *tableView in allTableViews) {
        if (tableView.superview != nil) {
            [tableView removeFromSuperview];
        }
    }
}

-(void)setDetailTabBarforItem:(Item *)item {
    
    NSMutableArray *tabItems = [[NSMutableArray alloc] initWithObjects:_itemDetail, nil];
    [_itemDetailBar setSelectedItem:[_itemDetailBar.items firstObject]];
    
    if (item.combinedItemsArray.count > 0) {
        [tabItems addObject:_combining];
    }
    
    if (item.usageItemsArray.count > 0) {
        [tabItems addObject:_usage];
    }
    
    if (item.monsterDropsArray.count > 0) {
        [tabItems addObject:_monster];
    }
    
    if (item.questRewardsArray.count > 0) {
        [tabItems addObject:_quest];
    }
    
    if (item.locationsArray.count > 0) {
        [tabItems addObject:_location];
    }
    
    _itemDetailBar.items = tabItems;
}

@end

@implementation Item

@end

@implementation ItemView

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
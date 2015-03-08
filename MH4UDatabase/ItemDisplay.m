//
//  ItemDisplay.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/7/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ItemDisplay.h"
#import "DetailViewController.h"
#import "MenuViewController.h"
#import "MH4UDBEngine.h"

@interface ItemDisplay ()
@property (nonatomic) NSArray *displayedItems;
@property (nonatomic) UITableView *itemTable;
@property (nonatomic) UITableView *combiningTable;
@property (nonatomic) Item *selectedItem;
@property (nonatomic) ItemView *detailItemView;
@property (nonatomic) CGRect properFrame;
@property (nonatomic) UISearchBar *itemSearch;
@property (nonatomic) UITabBar *itemDetailBar;
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
    
    _itemDetailBar = [[UITabBar alloc] initWithFrame:_dVC.tabBarFrame];
    UITabBarItem *itemDetail = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:1];
    UITabBarItem *combining = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:2];
    [_itemDetailBar setItems:@[itemDetail, combining]];
    _itemDetailBar.delegate = self;
    
    [_dVC.view addSubview:_itemTable];
    [_dVC.view addSubview:_itemSearch];
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 1:
            if (_combiningTable.superview != nil) {
                [_combiningTable removeFromSuperview];
            }
            [_dVC.view addSubview:_detailItemView];
            [_dVC.view addSubview:_itemDetailBar];
            break;
        case 2:
            if (_detailItemView.superview != nil) {
                [_detailItemView removeFromSuperview];
            }
            [_dVC.view addSubview:_combiningTable];
            [_dVC.view addSubview:_itemDetailBar];
            break;
        default:
            break;
    }
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
    } else if ([tableView isEqual:_combiningTable]) {
        CombiningCell *combiningCell = [tableView dequeueReusableCellWithIdentifier:@"combiningCell"];
        
        if (!combiningCell) {
            [tableView registerNib:[UINib nibWithNibName:@"UICombiningTableCell"  bundle:nil] forCellReuseIdentifier:@"combiningCell"];
            combiningCell = [tableView dequeueReusableCellWithIdentifier:@"combiningCell"];
        }
        
        NSArray *combiningArray = _selectedItem.combinedItemsArray[indexPath.row];
        NSArray *combinedItemInfo = [_dbEngine infoForCombinedTableCellItem:combiningArray[0]];
        NSArray *item1Info = [_dbEngine infoForCombinedTableCellItem:combiningArray[1]];
        NSArray *item2Info = [_dbEngine infoForCombinedTableCellItem:combiningArray[2]];
        
        combiningCell.combinedItemName.text = combinedItemInfo[0];
        combiningCell.combinedImageView.image = [UIImage imageNamed:combinedItemInfo[1]];
        
        combiningCell.item1Name.text = item1Info[0];
        combiningCell.item2Name.text = item2Info[0];
        combiningCell.maxCombined.text = [NSString stringWithFormat:@"Max: %@", combiningArray[4]];
        combiningCell.percentageCombined.text = [NSString stringWithFormat:@"%@%@", combiningArray[5], @"%"];
        combiningCell.item1ImageView.image = [UIImage imageNamed:item1Info[1]];
        combiningCell.item2ImageView.image = [UIImage imageNamed:item2Info[1]];
        return combiningCell;
    }
    else {
        return nil;
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_combiningTable != nil) {
        _combiningTable = [[UITableView alloc] initWithFrame:_dVC.tableFrame];
        _combiningTable.dataSource = self;
        _combiningTable.delegate = self;
    }
    
    Item *item = _displayedItems[indexPath.row];
    _detailItemView = [[[NSBundle mainBundle] loadNibNamed:@"ItemView" owner:self options:nil] lastObject];
    [_detailItemView populateViewWithItem:item];
    _detailItemView.frame = _dVC.tableFrame;
    [_dbEngine getCombiningItemsForItem:item];
    _selectedItem = item;
    [_itemTable removeFromSuperview];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeItemDetail)];
    _dVC.navigationItem.rightBarButtonItems = @[close];
    [_dVC.view addSubview:_detailItemView];
    [_dVC.view addSubview:_itemDetailBar];
    [_itemDetailBar setSelectedItem:[_itemDetailBar.items firstObject]];
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
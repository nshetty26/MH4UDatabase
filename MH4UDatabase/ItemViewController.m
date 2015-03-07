//
//  ItemViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/5/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ItemViewController.h"
#import "MenuViewController.h"
#import "MH4UDBEngine.h"

@interface ItemViewController ()
@property (nonatomic) NSArray *displayedItems;
@property (nonatomic) UITableView *itemTable;
@property (nonatomic) UITableView *combiningTable;
@property (nonatomic) Item *selectedItem;
@property (nonatomic) ItemView *detailItemView;
@property (nonatomic) CGRect properFrame;
@property (nonatomic) UISearchBar *itemSearch;
@property (nonatomic) UITabBar *itemDetailBar;
@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _displayedItems = _allItems;
    _itemTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
    _itemTable.dataSource = self;
    _itemTable.delegate = self;
    _combiningTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height)];
    _combiningTable.dataSource = self;
    _combiningTable.delegate = self;
    
    _itemSearch = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44)];
    _itemSearch.delegate = self;
    
    _itemDetailBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 49)];
    UITabBarItem *itemDetail = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:1];
    UITabBarItem *combining = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:2];
    [_itemDetailBar setItems:@[itemDetail, combining]];
    _itemDetailBar.delegate = self;
    
    [self.view addSubview:_itemTable];
    [self.view addSubview:_itemSearch];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 1:
            if (_combiningTable.superview != nil) {
                [_combiningTable removeFromSuperview];
            }
            [self.view addSubview:_detailItemView];
            [self.view addSubview:_itemDetailBar];
            break;
        case 2:
            if (_detailItemView.superview != nil) {
                [_detailItemView removeFromSuperview];
            }
            [self.view addSubview:_combiningTable];
            [self.view addSubview:_itemDetailBar];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        CombiningCell *combiningCell = [[[NSBundle mainBundle] loadNibNamed:@"UICombiningTableCell" owner:self options:nil] lastObject];
        NSArray *combiningArray = _selectedItem.combinedItemsArray[indexPath.row];
        NSArray *combinedItemInfo = [_dbEngine infoForCombinedTableCellItem:combiningArray[0]];
        NSArray *item1Info = [_dbEngine infoForCombinedTableCellItem:combiningArray[1]];
        NSArray *item2Info = [_dbEngine infoForCombinedTableCellItem:combiningArray[2]];
        
        combiningCell.combinedItemName.text = combinedItemInfo[0];
        combiningCell.combinedImageView.image = [UIImage imageNamed:combinedItemInfo[1]];

        combiningCell.item1Name.text = item1Info[0];
        combiningCell.item2Name.text = item2Info[0];
        combiningCell.maxCombined.text = [NSString stringWithFormat:@"%@", combiningArray[4]];
        combiningCell.percentageCombined.text = [NSString stringWithFormat:@"%@%", combiningArray[5]];
        combiningCell.item1ImageView.image = [UIImage imageNamed:item1Info[1]];
        combiningCell.item2ImageView.image = [UIImage imageNamed:item2Info[1]];
        return combiningCell;
    }
    else {
        return nil;
    }

    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = _displayedItems[indexPath.row];
    _detailItemView = [[[NSBundle mainBundle] loadNibNamed:@"ItemView" owner:self options:nil] lastObject];
    [_detailItemView populateViewWithItem:item];
    _detailItemView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    [_dbEngine getCombiningItemsForItem:item];
    _selectedItem = item;
    [_itemTable removeFromSuperview];
    [self.view addSubview:_detailItemView];
    [self.view addSubview:_itemDetailBar];
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
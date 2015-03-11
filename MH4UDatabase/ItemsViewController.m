//
//  ItemViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/9/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "DetailViewController.h"
#import "MenuViewController.h"
#import "MH4UDBEngine.h"
#import "ItemsViewController.h"
#import "ItemDetailViewController.h"
#import "MH4UDBEntity.h"

@interface ItemsViewController ()
@property (nonatomic) NSArray *displayedItems;
@property (nonatomic) ItemDetailViewController *itemDetailVC;
@property (nonatomic) UITableView *itemTable;
@property (nonatomic) Item *selectedItem;
@property (nonatomic) UISearchBar *itemSearch;
@property (nonatomic) int heightDifference;
@end

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Items" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    _displayedItems = _allItems;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navigationBar = self.navigationController.navigationBar.frame;
    _heightDifference = statusBar.size.height + navigationBar.size.height;
    CGRect vcFrame = self.view.frame;
    
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 44);
    
    
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    
    _itemTable = [[UITableView alloc] initWithFrame:tableWithSearch];
    _itemTable.dataSource = self;
    _itemTable.delegate = self;
    
    _itemSearch = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    [_itemSearch setShowsCancelButton:YES];
    _itemSearch.delegate = self;
    
    [self.view addSubview:_itemTable];
    [self.view addSubview:_itemSearch];

}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self showAllItems];
    }
    else {
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
}

-(void)showAllItems {
    _displayedItems = _allItems;
    [_itemTable reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self showAllItems];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)dismissKeyboard {
    [_itemSearch resignFirstResponder];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_itemTable]) {
        return _displayedItems.count;
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
    } else {
        return nil;
    }
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_itemTable]) {
        Item *item = _displayedItems[indexPath.row];
        [self populateDetailsforItem:item];
        _itemDetailVC = [[ItemDetailViewController alloc] init];
        _itemDetailVC.selectedItem = item;
        _itemDetailVC.dbEngine = _dbEngine;
        _itemDetailVC.heightDifference = _heightDifference;
        [_itemSearch resignFirstResponder];
        [self.navigationController pushViewController:_itemDetailVC animated:YES];
        
        NSLog(@"Pause");
        
    }
    
}

-(void)populateDetailsforItem:(Item*)item{
    [_dbEngine getCombiningItemsForItem:item];
    [_dbEngine getUsageItemsForItem:item];
    [_dbEngine getMonsterDropsForItem:item];
    [_dbEngine getQuestRewardsForItem:item];
    [_dbEngine getLocationsForItem:item];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end



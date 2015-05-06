//
//  ItemViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/9/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

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

#pragma mark - Setup Views
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.title = NSLocalizedString(@"Items", @"Items");
    _allItems = [_dbEngine populateItemArray];
    _displayedItems = _allItems;
    
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navigationBar = self.navigationController.navigationBar.frame;
    _heightDifference = statusBar.size.height + navigationBar.size.height;
    CGRect vcFrame = self.view.frame;
    
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 44);
    _itemSearch = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _itemSearch.delegate = self;
    
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    [self setUpTableViewsWithFrame:tableWithSearch];
    
    [self.view addSubview:_itemTable];
    [self.view addSubview:_itemSearch];
    
}

-(void)setUpTableViewsWithFrame:(CGRect)tableFrame {
    if (!_itemTable) {
        _itemTable = [[UITableView alloc] initWithFrame:tableFrame];
        _itemTable.dataSource = self;
        _itemTable.delegate = self;
    }

}


#pragma mark - Search Bar Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_itemSearch setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showAllItems];
    }
    else {
    NSArray *searchedItems = [_allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        Item *item = (Item*)evaluatedObjected;
        if (!([item.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
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
    [searchBar setShowsCancelButton:NO];
    [self showAllItems];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Table View Methods
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemIdentifier"];
        }
        
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
        _itemDetailVC = [[ItemDetailViewController alloc] init];
        _itemDetailVC.selectedItem = item;
        _itemDetailVC.dbEngine = _dbEngine;
        _itemDetailVC.heightDifference = _heightDifference;
        [_itemSearch resignFirstResponder];
        [self.navigationController pushViewController:_itemDetailVC animated:YES];
        
    }
    
}

#pragma mark - Helper Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews {
    CGRect vcFrame = self.view.frame;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    int heightdifference = navBar.frame.size.height + statusBar.size.height;
    
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference, vcFrame.size.width, 44);
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - searchBarFrame.size.height);
    
    _itemSearch.frame = searchBarFrame;
    _itemTable.frame = tableWithSearch;
    
}
@end



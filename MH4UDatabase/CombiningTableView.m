//
//  CombiningTableView.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/1/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "CombiningTableView.h"
#import "ItemDetailViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface CombiningTableView ()
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) MH4UDBEngine *dbEngine;
@property (nonatomic, strong) NSArray *displayedCombined;
@end

@implementation CombiningTableView

-(id)initWithFrame:(CGRect)frame andNavigationController:(UINavigationController *)navigationController andDBEngine:(MH4UDBEngine *)dbEngine {
    if (self = [super init]) {
        self.frame = frame;
        
        if (navigationController && dbEngine) {
            _navigationController = navigationController;
            _dbEngine = dbEngine;
            UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 38)];
            searchBar.delegate = self;
            self.tableHeaderView = searchBar;
            self.delegate = self;
            self.dataSource = self;
            return self;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

#pragma mark - Search Bar Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [searchBar setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showAllCombine];
        [searchBar resignFirstResponder];
    } else {
        NSArray *searchedCombine = [_allCombined filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
            Combining *combineCombo = (Combining *)evaluatedObjected;
            if (!([combineCombo.combinedItem.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
                return YES;
            } else if (!([combineCombo.item1.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)){
                return YES;
            } else if (!([combineCombo.item2.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
                return YES;
            } else {
                return NO;
            }
        }]];
        
        _displayedCombined = searchedCombine;
        [self reloadData];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [self showAllCombine];
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)showAllCombine {
    _displayedCombined = _allCombined;
    [self  reloadData];
}

#pragma mark Table View Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_displayedCombined == nil) {
        _displayedCombined = _allCombined;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _displayedCombined.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CombiningCell *combiningCell = [tableView dequeueReusableCellWithIdentifier:@"combiningCell"];
    
    if (!combiningCell) {
        [tableView registerNib:[UINib nibWithNibName:@"UICombiningTableCell"  bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"combiningCell"];
        combiningCell = [tableView dequeueReusableCellWithIdentifier:@"combiningCell"];
    }
    return combiningCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(CombiningCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Combining *combineCombo = _displayedCombined[indexPath.row];
    cell.dbEngine = _dbEngine;
    cell.nC = _navigationController;
    cell.heightDifference = [self returnHeightDifference];
    cell.combinedItemName.text = combineCombo.combinedItem.name;
    [cell.combineItemButton setTitle:combineCombo.combinedItem.name forState:UIControlStateNormal];
    cell.combinedImageView.image = [UIImage imageNamed:combineCombo.combinedItem.icon];
    
    cell.item1Name.text = combineCombo.item1.name;
    [cell.item1Name setTranslatesAutoresizingMaskIntoConstraints:false];
    [cell.item1Button setTitle:combineCombo.item1.name forState:UIControlStateNormal];
    cell.item2Name.text = combineCombo.item2.name;
    [cell.item2Button setTitle:combineCombo.item2.name forState:UIControlStateNormal];
    cell.maxCombined.text = [NSString stringWithFormat:@"%i - %i",combineCombo.minMade, combineCombo.maxMade];
    cell.percentageCombined.text = [NSString stringWithFormat:@"%i%@", combineCombo.percentage, @"%"];
    cell.item1ImageView.image = [UIImage imageNamed:combineCombo.item1.icon];
    cell.item2ImageView.image = [UIImage imageNamed:combineCombo.item2.icon];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(CGFloat)returnHeightDifference {
    UINavigationBar *navBar = _navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    return navBar.frame.size.height + statusBar.size.height;
}

@end

@implementation CombiningCell


- (IBAction)launchDetailItem:(id)sender {
    ItemDetailViewController *iDVC = [[ItemDetailViewController alloc] init];
    UIButton *button = (UIButton *)sender;
    Item *selectedItem = [_dbEngine getItemForName:button.titleLabel.text];
    iDVC.selectedItem = selectedItem;
    iDVC.dbEngine = _dbEngine;
    iDVC.heightDifference = _heightDifference;
    [_nC pushViewController:iDVC animated:YES];
    
}
@end


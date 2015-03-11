//
//  CombiningViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "CombiningViewController.h"
#import "MH4UDBEntity.h"
#import "MenuViewController.h"
#import "MH4UDBEngine.h"

@interface CombiningViewController ()
@property UITableView *combiningTable;
@property UISearchBar *combineSearch;
@property NSArray *displayedCombined;

@end

@implementation CombiningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Combining" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    CGRect vcFrame = self.view.frame;
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 44);
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    _displayedCombined = _allCombined;
    _combiningTable = [[UITableView alloc] initWithFrame:tableWithSearch];
    _combiningTable.dataSource = self;
    _combiningTable.delegate = self;


    _combineSearch = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _combineSearch.delegate = self;
    [self.view addSubview:_combiningTable];
    [self.view addSubview:_combineSearch];
    // Do any additional setup after loading the view.
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_combineSearch setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showAllCombine];
        [searchBar resignFirstResponder];
    } else {
        NSArray *searchedCombine = [_allCombined filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
            Combining *combineCombo = (Combining *)evaluatedObjected;
            if ([combineCombo.combinedItem.name.lowercaseString containsString:searchText.lowercaseString]) {
                return YES;
            } else if ([combineCombo.item1.name.lowercaseString containsString:searchText.lowercaseString]){
                return YES;
            } else if (([combineCombo.item2.name.lowercaseString containsString:searchText.lowercaseString])) {
                return YES;
            } else {
                return NO;
            }
        }]];
        
        _displayedCombined = searchedCombine;
        [_combiningTable reloadData];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [self showAllCombine];
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

-(void)showAllCombine {
    _displayedCombined = _allCombined;
    [_combiningTable reloadData];
}

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
    cell.nC = self.navigationController;
    cell.heightDifference = _heightDifference;
    cell.combinedItemName.text = combineCombo.combinedItem.name;
    [cell.combineItemButton setTitle:combineCombo.combinedItem.name forState:UIControlStateNormal];
    cell.combinedImageView.image = [UIImage imageNamed:combineCombo.combinedItem.icon];
    
    cell.item1Name.text = combineCombo.item1.name;
    [cell.item1Button setTitle:combineCombo.item1.name forState:UIControlStateNormal];
    cell.item2Name.text = combineCombo.item2.name;
    [cell.item2Button setTitle:combineCombo.item2.name forState:UIControlStateNormal];
    cell.maxCombined.text = [NSString stringWithFormat:@"%i - %i",combineCombo.minMade, combineCombo.maxMade];
    cell.percentageCombined.text = [NSString stringWithFormat:@"%i%@", combineCombo.percentage, @"%"];
    cell.item1ImageView.image = [UIImage imageNamed:combineCombo.item1.icon];
    cell.item2ImageView.image = [UIImage imageNamed:combineCombo.item1.icon];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//
//  SkillTreeViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "SkillTreeViewController.h"
#import "SkillDetailViewController.h"

@interface SkillTreeViewController ()
@property (nonatomic) UITableView *skillTreeTableView;
@property (nonatomic) UISearchBar *skillTreeSearch;
@property (nonatomic) NSArray *displayedSkillTree;
@end

@implementation SkillTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Skill Tree" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    
    // Do any additional setup after loading the view.
    CGRect vcFrame = self.view.frame;
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 44);
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    _displayedSkillTree = _allSkillTrees;
    _skillTreeTableView = [[UITableView alloc] initWithFrame:tableWithSearch];
    _skillTreeTableView.dataSource = self;
    _skillTreeTableView.delegate = self;
    
    
    _skillTreeSearch = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _skillTreeSearch.delegate = self;
    [self.view addSubview:_skillTreeTableView];
    [self.view addSubview:_skillTreeSearch];

}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_skillTreeSearch setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showAllItems];
    }
    else {
        NSArray *searchedItems = [_allSkillTrees filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
            NSArray *skillTree = (NSArray *)evaluatedObjected;
            NSString *skillTreeName = skillTree[1];
            if ([skillTreeName.lowercaseString containsString:searchText.lowercaseString]) {
                return YES;
            } else {
                return NO;
            }
            
        }]];
        
        _displayedSkillTree = searchedItems;
        [_skillTreeTableView reloadData];
    }
}

-(void)showAllItems {
    _displayedSkillTree = _allSkillTrees;
    [_skillTreeTableView reloadData];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _displayedSkillTree.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *skillTree = _allSkillTrees[indexPath.row];
    SkillDetailViewController *sdVC = [[SkillDetailViewController alloc] init];
    sdVC.heightDifference = _heightDifference;
    sdVC.dbEngine = _dbEngine;
    sdVC.skilTreeName = skillTree[1];
    NSNumber *skillTreeID = skillTree[0];
    sdVC.skillTreeID = [skillTreeID intValue];
    [self.navigationController pushViewController:sdVC animated:YES];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"skillTree"];
    NSArray *skillTree = _displayedSkillTree[indexPath.row];
    cell.textLabel.text = skillTree[1];
    return cell;
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

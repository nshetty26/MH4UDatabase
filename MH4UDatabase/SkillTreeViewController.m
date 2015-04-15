//
//  SkillTreeViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "SkillTreeViewController.h"
#import "SkillDetailViewController.h"
#import "MH4UDBEngine.h"

@interface SkillTreeViewController ()
@property (nonatomic) UITableView *skillTreeTableView;
@property (nonatomic) UISearchBar *skillTreeSearch;
@property (nonatomic) NSArray *displayedSkillTree;
@end

@implementation SkillTreeViewController

#pragma mark - Setup Views
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.title = NSLocalizedString(@"Skill Trees", @"Skill Trees");
    
    _allSkillTrees = [_dbEngine getSkillTrees];
    _displayedSkillTree = _allSkillTrees;
    
    // Do any additional setup after loading the view.
    CGRect vcFrame = self.view.frame;
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 44);
    _skillTreeSearch = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _skillTreeSearch.delegate = self;
    
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    _skillTreeTableView = [[UITableView alloc] initWithFrame:tableWithSearch];
    _skillTreeTableView.dataSource = self;
    _skillTreeTableView.delegate = self;
    
    

    [self.view addSubview:_skillTreeTableView];
    [self.view addSubview:_skillTreeSearch];

}

#pragma mark - Search Bar Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_skillTreeSearch setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showAllSkills];
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

-(void)showAllSkills {
    _displayedSkillTree = _allSkillTrees;
    [_skillTreeTableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO];
    [self showAllSkills];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Table View Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _displayedSkillTree.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *skillTree = _displayedSkillTree[indexPath.row];
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
    
    _skillTreeSearch.frame = searchBarFrame;
    _skillTreeTableView.frame = tableWithSearch;
    
}


@end

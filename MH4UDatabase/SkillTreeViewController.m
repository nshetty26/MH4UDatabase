//
//  SkillTreeViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "SkillTreeViewController.h"

@interface SkillTreeViewController ()
@property (nonatomic) UITableView *skillTreeTableView;
@property (nonatomic) UISearchBar *skillTreeSearch;
@property (nonatomic) NSArray *displayedSkillTree;
@end

@implementation SkillTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _displayedSkillTree.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

//
//  QuestsViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "QuestsViewController.h"
#import "QuestDetailViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface QuestsViewController ()
@property (nonatomic) UITabBar *questTypeTab;
@property (nonatomic) NSArray *displayedQuests;
@property (nonatomic) UISearchBar *questSearch;
@property (nonatomic) UITableView *questTable;
@end

@implementation QuestsViewController

#pragma mark - Setup Views
-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_questTypeTab) {
        _questTypeTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
        UITabBarItem *caravan = [[UITabBarItem alloc] initWithTitle:@"Caravan" image:nil tag:1];
        UITabBarItem *guild = [[UITabBarItem alloc] initWithTitle:@"Guild" image:nil tag:2];
        UITabBarItem *event = [[UITabBarItem alloc] initWithTitle:@"Event" image:nil tag:3];
        
        _questTypeTab.delegate = self;
        [_questTypeTab setItems:@[caravan, guild, event]];
        [_questTypeTab setSelectedItem:caravan];
    }

}

-(void)setUpTableWithFrame:(CGRect)tableFrame {
    if (!_questTable) {
        _questTable = [[UITableView alloc] initWithFrame:tableFrame];
        _questTable.dataSource = self;
        _questTable.delegate = self;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.title = NSLocalizedString(@"Quests", @"Quests");
    
    _allQuestsArray = [_dbEngine getAllQuests:nil];
    _displayedQuests = [_allQuestsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Quest *quest = (Quest *)evaluatedObject;
        return [quest.hub isEqualToString:@"Caravan"];}]];;
    
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    [self setUpTabBarWithFrame:tabBarFrame];
    
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference + tabBarFrame.size.height, vcFrame.size.width, 44);
    _questSearch = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _questSearch.delegate = self;
    
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    [self setUpTableWithFrame:tableWithSearch];

    [self.view addSubview:_questTable];
    [self.view addSubview:_questTypeTab];
    [self.view addSubview:_questSearch];
}

#pragma mark - Search Bar Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_questSearch setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showallQuests];
        return;
    }
    NSArray *searchedQuest = [_displayedQuests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
        Quest *quest = (Quest*)evaluatedObjected;
        if (!([quest.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
            return YES;
        } else {
            return NO;
        }
        
    }]];
    
    _displayedQuests = searchedQuest;
    [_questTable reloadData];
}

-(void)showallQuests {
    if ([_questTypeTab selectedItem].tag == 1) {
        _displayedQuests = [_allQuestsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
            Quest *quest = (Quest *)evaluatedObject;
            return [quest.hub isEqualToString:@"Caravan"];}]];
    } else if ([_questTypeTab selectedItem].tag == 2 ) {
        _displayedQuests = [_allQuestsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
            Quest *quest = (Quest *)evaluatedObject;
            return [quest.hub isEqualToString:@"Guild"];}]];
    } else if ([_questTypeTab selectedItem].tag == 3 ) {
        _displayedQuests = [_allQuestsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
            Quest *quest = (Quest *)evaluatedObject;
            return [quest.hub isEqualToString:@"Event"];}]];
    }
    [_questTable reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO];
    [self showallQuests];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

#pragma mark - Tab Bar Methods
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([tabBar isEqual:_questTypeTab]) {
        switch (item.tag) {
            case 1:
                _displayedQuests = [_allQuestsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                    Quest *quest = (Quest *)evaluatedObject;
                    return [quest.hub isEqualToString:@"Caravan"];}]];
                break;
            case 2:
                _displayedQuests = [_allQuestsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                    Quest *quest = (Quest *)evaluatedObject;
                    return [quest.hub isEqualToString:@"Guild"];}]];
                break;
            case 3:
                _displayedQuests = [_allQuestsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                    Quest *quest = (Quest *)evaluatedObject;
                    return [quest.hub isEqualToString:@"Event"];}]];
                break;
            default:
                break;
        }
        [_questTable reloadData];
    }
}

#pragma mark - Table View Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:_questTable]) {
        return 10;
    } else {
        return 0;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_questTable]) {
        switch (section) {
            case 1:
                return @"1 *";
                break;
            case 2:
                return @"2 **";
                break;
            case 3:
                return @"3 ***";
                break;
            case 4:
                return @"4 ****";
                break;
            case 5:
                return @"5 *****";
                break;
            case 6:
                return @"6 ******";
                break;
            case 7:
                return @"7 *******";
                break;
            case 8:
                return @"8 ********";
                break;
            case 9:
                return @"9 *********";
                break;
            case 10:
                return @"10 **********";
                break;
            default:
                break;
        }
    }
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_questTable]) {
        NSArray *questArray = [_displayedQuests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
            Quest *quest = (Quest *)evaluatedObject;
            return quest.stars == section;}]];
        return questArray.count;
    } else {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"questCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"questCell"];
    }
    
    if ([tableView isEqual:_questTable]) {
        Quest *quest = [self returnQuestAtIndexPath:indexPath];
        cell.textLabel.text = quest.name;
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 50, cellFrame.size.height - 10, 30, 20);
        UILabel *accessoryText = [[UILabel alloc] initWithFrame:textView];
        [cell addSubview:accessoryText];
        accessoryText.textAlignment =  NSTextAlignmentRight;
        accessoryText.text = [quest.type isEqualToString:@"Key"] ? @"Key" : @"";
        UIFont *font = [accessoryText.font fontWithSize:12];
        accessoryText.font = font;
        cell.accessoryView = accessoryText;
        return cell;
    } else {
        return nil;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Quest *quest = [self returnQuestAtIndexPath:indexPath];
    QuestDetailViewController *qDVC = [[QuestDetailViewController alloc] init];
    qDVC.dbEngine = _dbEngine;
    qDVC.heightDifference = _heightDifference;
    qDVC.selectedQuest = quest;
    [self.navigationController pushViewController:qDVC animated:YES];

}

#pragma mark - Helper Methods
-(Quest *)returnQuestAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *questArray = [_displayedQuests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
        Quest *quest = (Quest *)evaluatedObject;
        return quest.stars == indexPath.section;}]];
    Quest *quest = questArray[indexPath.row];
    return quest;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews {
    CGRect vcFrame = self.view.frame;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    int heightdifference = navBar.frame.size.height + statusBar.size.height;
    
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference, vcFrame.size.width, 49);
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference + tabBarFrame.size.height, vcFrame.size.width, 44);
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - (searchBarFrame.size.height + tabBarFrame.size.height));
    
    _questTypeTab.frame = tabBarFrame;
    _questSearch.frame = searchBarFrame;
    _questTable.frame = tableWithSearch;
    
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

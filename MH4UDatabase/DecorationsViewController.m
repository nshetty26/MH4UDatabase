//
//  JewelsViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "DecorationsViewController.h"
#import "DecorationsDetailViewController.h"
#import "ItemDetailViewController.h"
#import "MH4UDBEntity.h"
#import "MH4UDBEngine.h"

@interface DecorationsViewController ()
@property (nonatomic) UITableView *decorationsTableView;
@property (nonatomic) UISearchBar *decorationsSearchBar;
@property (nonatomic) NSArray *displayedDecorations;

@end

@implementation DecorationsViewController

#pragma mark - Setup Views
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Decorations", @"Decorations");
    _allDecorations = [_dbEngine getAllDecorations];
    _displayedDecorations = _allDecorations;

    CGRect vcFrame = self.view.frame;
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 44);
    _decorationsSearchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _decorationsSearchBar.delegate = self;
    
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    _decorationsTableView = [[UITableView alloc] initWithFrame:tableWithSearch];
    _decorationsTableView.dataSource = self;
    _decorationsTableView.delegate = self;

    [self.view addSubview:_decorationsTableView];
    [self.view addSubview:_decorationsSearchBar];
}

#pragma mark - Search Bar Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_decorationsSearchBar setShowsCancelButton:YES];
    if (searchText.length == 0) {
        [self showAllItems];
    }
    else {
        NSArray *searchedItems = [_allDecorations filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObjected, NSDictionary *userInfo){
            Decoration *decoration = (Decoration *)evaluatedObjected;
            if ([decoration.name.lowercaseString containsString:searchText.lowercaseString]) {
                return YES;
            } else {
                return NO;
            }
            
        }]];
        
        _displayedDecorations = searchedItems;
        [_decorationsTableView reloadData];
    }
}

-(void)showAllItems {
    _displayedDecorations = _allDecorations;
    [_decorationsTableView reloadData];
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
    return _displayedDecorations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"skillTree"];
    Decoration *decoration = _displayedDecorations[indexPath.row];
    cell.textLabel.text = decoration.name;
    cell.imageView.image = [UIImage imageNamed:decoration.icon];
    
    CGRect cellFrame = cell.frame;
    CGRect textView = CGRectMake(cellFrame.size.width - 60, cellFrame.origin.y + 5, 50, 24);
    UILabel *acessoryText = [[UILabel alloc] initWithFrame:textView];
    [acessoryText setNumberOfLines:2];
    [acessoryText setLineBreakMode:NSLineBreakByWordWrapping];
    [cell addSubview:acessoryText];
    acessoryText.textAlignment =  NSTextAlignmentRight;
    UIFont *font = [acessoryText.font fontWithSize:8];
    acessoryText.font = font;
    
    NSArray *skill1 = decoration.skillArray[0];
    if (decoration.skillArray.count == 1) {
        acessoryText.text = [NSString stringWithFormat:@"%@ %@", skill1[1], skill1[2]];
    } else if (decoration.skillArray.count == 2) {
        NSArray *skill2 = decoration.skillArray[1];
        acessoryText.text = [NSString stringWithFormat:@"%@ %@ %@ %@", skill1[1], skill1[2], skill2[1], skill2[2]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Decoration *decoration= _allDecorations[indexPath.row];
    decoration.componentArray = [_dbEngine getComponentsfor:decoration.itemID];
    DecorationsDetailViewController *dDVC = [[DecorationsDetailViewController alloc] init];
    dDVC.heightDifference = _heightDifference;
    dDVC.dbEngine = _dbEngine;
    dDVC.selectedDecoration = decoration;
    [self.navigationController pushViewController:dDVC animated:YES];
    
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
    
    _decorationsSearchBar.frame = searchBarFrame;
    _decorationsTableView.frame = tableWithSearch;
    
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

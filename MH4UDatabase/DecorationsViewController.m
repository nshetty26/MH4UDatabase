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
#import "DecorationTableView.h"

@interface DecorationsViewController ()
@property (nonatomic) DecorationTableView *decorationsTableView;
@property (nonatomic) UISearchBar *decorationsSearchBar;
@property (nonatomic) NSArray *displayedDecorations;

@end

@implementation DecorationsViewController

#pragma mark - Setup Views
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.title = NSLocalizedString(@"Decorations", @"Decorations");
    
    _allDecorations = [_dbEngine getAllDecorations:nil];
    _displayedDecorations = _allDecorations;

    CGRect vcFrame = self.view.frame;
    CGRect searchBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 44);
    _decorationsSearchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    _decorationsSearchBar.delegate = self;
    
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + searchBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    _decorationsTableView = [[DecorationTableView alloc] initWithFrame:tableWithSearch andNavigationController:self.navigationController andDBEngine:_dbEngine];
    _decorationsTableView.displayedDecorations = _displayedDecorations;

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
            BOOL shouldBeDisplayed = FALSE;
            if (!([decoration.name.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
                shouldBeDisplayed = TRUE;
            }
            
            for (NSDictionary *skillTree in decoration.skillArray) {
                NSString *skillName = [skillTree valueForKey:@"skillTreeName"];
                if (!([skillName.lowercaseString rangeOfString:searchText.lowercaseString].location == NSNotFound)) {
                    shouldBeDisplayed = TRUE;
                }
            }
            return shouldBeDisplayed;
        }]];
        
        _decorationsTableView.displayedDecorations = searchedItems;
        [_decorationsTableView reloadData];
    }
}

-(void)showAllItems {
    _decorationsTableView.displayedDecorations = _allDecorations;
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

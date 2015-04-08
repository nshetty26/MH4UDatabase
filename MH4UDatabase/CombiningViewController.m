//
//  CombiningViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "CombiningViewController.h"
#import "CombiningTableView.h"
#import "MH4UDBEntity.h"
#import "MenuViewController.h"
#import "MH4UDBEngine.h"

@interface CombiningViewController ()
@property CombiningTableView *combiningTable;

@end

@implementation CombiningViewController

#pragma mark - Setup Views
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Combining", @"Combining");
    _allCombined = [_dbEngine getCombiningItems];
    CGRect vcFrame = self.view.frame;
    
    _combiningTable = [[CombiningTableView alloc] initWithFrame:vcFrame andNavigationController:self.navigationController andDBEngine:_dbEngine];
    _combiningTable.allCombined = _allCombined;

    [self.view addSubview:_combiningTable];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews {
    CGRect vcFrame = self.view.frame;
    
    //_combineSearch.frame = searchBarFrame;
    _combiningTable.frame = vcFrame;
    
}


@end

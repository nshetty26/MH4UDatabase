//
//  DetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/3/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "DetailViewController.h"
#import "ArmorDisplay.h"
#import "ItemDisplay.h"
#import "MH4UDBEngine.h"

@interface DetailViewController ()
@property (strong, nonatomic) ArmorDisplay *armorDisplay;
@property (strong, nonatomic) ItemDisplay *itemDisplay;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navigationBar = self.navigationController.navigationBar.frame;
    _heightDifference = statusBar.size.height + navigationBar.size.height;
    _tabBarFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + _heightDifference, self.view.frame.size.width, 49);
    _tableFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + _heightDifference + _tabBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    
    if ([_detailItem isEqualToString:@"Armor"]) {
        _armorDisplay = [[ArmorDisplay alloc] init];
        _armorDisplay.dVC = self;
        _armorDisplay.dbEngine = _dbEngine;
        _armorDisplay.allArmorArray = [_dbEngine populateArmorArray];
        [_armorDisplay setupArmorView];
    } else if ([_detailItem isEqualToString:@"Item"]) {
        _itemDisplay = [[ItemDisplay alloc] init];
        _itemDisplay.dVC = self;
        _itemDisplay.dbEngine = _dbEngine;
        _itemDisplay.allItems = [_dbEngine populateItemArray];
        [_itemDisplay setupItemDisplay];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //[self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

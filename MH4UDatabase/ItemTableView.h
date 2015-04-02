//
//  MH4UTableViews.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/26/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MH4UDBEngine;

@interface ItemTableView : UITableView <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *itemTableView;
@property (nonatomic, strong) NSArray *allItems;
@property (nonatomic, strong) NSString *accessoryType;


-(id)initWithFrame:(CGRect)frame andNavigationController:(UINavigationController *)navigationController andDBEngine:(MH4UDBEngine *)dbEngine;

@end

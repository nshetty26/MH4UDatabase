//
//  ItemViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/9/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MH4UDBEngine;
@class CombiningCell;
@class DetailViewController;

@interface ItemsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITabBarDelegate>
@property (strong, nonatomic) NSArray *allItems;
@property (strong, nonatomic) DetailViewController *dVC;
@property (strong, nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) CombiningCell *combiningCell;

@end




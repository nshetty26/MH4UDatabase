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

@interface Item : NSObject
@property (nonatomic) int itemID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *type;
@property (nonatomic) int rarity;
@property (nonatomic) int capacity;
@property (nonatomic) int price;
@property (nonatomic) int salePrice;
@property (nonatomic) NSString *itemDescription;
@property (nonatomic) NSString *icon;
@property (nonatomic) NSArray *combinedItemsArray;
@property (nonatomic) NSArray *usageItemsArray;
@property (nonatomic) NSArray *monsterDropsArray;
@property (nonatomic) NSArray *questRewardsArray;
@property (nonatomic) NSArray *locationsArray;

@end



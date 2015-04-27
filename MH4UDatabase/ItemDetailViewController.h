//
//  ItemDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/9/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+UIViewController_MenuButton.h"

@class Item;
@class BaseViewController;
@class MH4UDBEngine;

@interface ItemDetailViewController : UIViewController <UITabBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) BaseViewController *baseViewController;
@property (nonatomic) int heightDifference;
@property (nonatomic) Item *selectedItem;
@property (nonatomic) MH4UDBEngine *dbEngine;

@end

@interface DetailedItemView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UILabel *rareLabel;
@property (weak, nonatomic) IBOutlet UILabel *capacityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *salePriceLabel;
@property (weak, nonatomic) IBOutlet UITextView *itemDescription;
@property (weak, nonatomic) IBOutlet UILabel *slotTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *slotDescriptionLabel;

-(void)populateViewWithItem:(Item *)item;

@end
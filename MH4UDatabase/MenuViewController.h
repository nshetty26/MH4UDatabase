//
//  MasterViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/3/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonstersViewController;
@class MH4UDBEngine;

@interface MenuViewController : UITableViewController

@property (strong, nonatomic) MonstersViewController *monstersViewController;

@end

@interface ItemTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemAccessoryLabel1;
@property (weak, nonatomic) IBOutlet UILabel *itemAccessoryLabel2;
@property (weak, nonatomic) IBOutlet UILabel *itemAccessoryLabel3;
@property (weak, nonatomic) IBOutlet UILabel *itemSubLabel;

@end



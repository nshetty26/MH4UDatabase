//
//  MasterViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/3/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end

@interface CombiningCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *combinedImageView;
@property (weak, nonatomic) IBOutlet UILabel *combinedItemName;
@property (weak, nonatomic) IBOutlet UILabel *maxCombined;
@property (weak, nonatomic) IBOutlet UILabel *percentageCombined;
@property (weak, nonatomic) IBOutlet UILabel *item1Name;
@property (weak, nonatomic) IBOutlet UIImageView *item1ImageView;
@property (weak, nonatomic) IBOutlet UILabel *item2Name;
@property (weak, nonatomic) IBOutlet UIImageView *item2ImageView;

@end

//
//  WyporiumTableViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/26/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MH4UDBEngine;
@class Quest;
@class Item;

@interface WyporiumTableViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) MH4UDBEngine *dbEngine;

@end

@interface WyporiumTableViewCell : UITableViewCell
@property (weak, nonatomic) Item *itemIn;
@property (weak, nonatomic) Item *itemOut;
@property (weak, nonatomic) Quest *unlockQuest;
@property (weak, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) IBOutlet UIButton *inButton;
@property (weak, nonatomic) IBOutlet UIButton *outButton;
@property (weak, nonatomic) IBOutlet UIButton *questButton;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) int heightDifference;
@property (weak, nonatomic) IBOutlet UILabel *inItemLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inItemImage;
@property (weak, nonatomic) IBOutlet UIImageView *outItemImage;
@property (weak, nonatomic) IBOutlet UILabel *outItemLabel;
@property (weak, nonatomic) IBOutlet UILabel *questLabel;
- (IBAction)launchDetailedVC:(id)sender;


@end
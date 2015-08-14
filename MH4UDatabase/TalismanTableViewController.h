//
//  TalismanTableViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 8/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ArmorSet;
@class MH4UDBEngine;
@class ArmorSetDetailViewController;

@interface TalismanTableViewController : UITableViewController

@property (nonatomic) ArmorSetDetailViewController *asDVC;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) ArmorSet *selectedSet;
@property (nonatomic) NSArray *talismanArray;

-(void)updateTalismanArray;
@end

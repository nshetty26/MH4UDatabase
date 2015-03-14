//
//  WeaponsTableViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeaponsTableViewController : UITableViewController <UISearchBarDelegate>
@property (nonatomic) NSArray *weaponsArray;
@property (nonatomic) NSString *imageString;
@property (nonatomic) NSString *weaponFamily;
@end

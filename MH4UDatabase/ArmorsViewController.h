//
//  ArmorsViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MH4UDBEngine;

@interface ArmorsViewController : UIViewController <UITableViewDataSource, UITabBarDelegate, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) NSArray *allArmorArray;
@property (strong, nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) int heightDifference;

@end

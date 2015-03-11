//
//  MonstersViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MH4UDBEngine;

@interface MonstersViewController : UIViewController <UITabBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) MH4UDBEngine *dbEngine;
@property (strong, nonatomic) NSArray *allMonstersArray;
@property (nonatomic) int heightDifference;

@end

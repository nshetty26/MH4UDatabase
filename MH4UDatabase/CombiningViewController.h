//
//  CombiningViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MH4UDBEngine;

@interface CombiningViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic) NSArray *allCombined;
@property (nonatomic) int heightDifference;
@property (nonatomic) MH4UDBEngine *dbEngine;
@end

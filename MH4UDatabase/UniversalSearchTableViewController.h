//
//  UniversalSearchTableViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/7/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  MH4UDBEngine;

@interface UniversalSearchTableViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) MH4UDBEngine *dbEngine;

@end

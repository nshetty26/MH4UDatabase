//
//  CanteenTableViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 8/14/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MH4UDBEngine;

@interface CanteenTableViewController : UITableViewController <UITabBarDelegate>
@property (nonatomic) MH4UDBEngine *dbEngine;
@end


@interface CanteenCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ingredient1;
@property (weak, nonatomic) IBOutlet UILabel *bonus;
@property (weak, nonatomic) IBOutlet UILabel *method;
@property (weak, nonatomic) IBOutlet UILabel *skill1;
@property (weak, nonatomic) IBOutlet UILabel *skill2;
@property (weak, nonatomic) IBOutlet UILabel *skill3;

@end
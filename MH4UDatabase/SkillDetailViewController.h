//
//  SkillDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SkillCollection;
@class MH4UDBEngine;

@interface SkillDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>

@property (nonatomic) int heightDifference;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) int skillTreeID;
@property (nonatomic) NSString *skilTreeName;

@end

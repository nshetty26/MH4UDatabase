//
//  SkillTreeViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SkillTreeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic) NSArray *allSkillTrees;
@property (nonatomic) int heightDifference;

@end

//
//  MonsterViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/3/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonsterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>

@end

@interface Monster : NSObject

@property (nonatomic) int monsterID;
@property (nonatomic) NSString *monsterClass;
@property (nonatomic) NSString *monsterName;
@property (nonatomic) NSString *trait;
@property (nonatomic) NSString *iconName;

@end

//
//  MonsterDisplayh.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/7/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MH4UDBEngine;
@class DetailViewController;

@interface MonsterDisplay : NSObject  <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate>

@property (strong, nonatomic) DetailViewController *dVC;
@property (strong, nonatomic) MH4UDBEngine *dbEngine;
@property (strong, nonatomic) NSArray *allMonstersArray;

-(void)setupMonsterDisplay;

@end

@interface Monster : NSObject

@property (nonatomic) int monsterID;
@property (nonatomic) NSString *monsterClass;
@property (nonatomic) NSString *monsterName;
@property (nonatomic) NSString *trait;
@property (nonatomic) NSString *iconName;

@end


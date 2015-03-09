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
@property (nonatomic) NSArray *monsterDetailDamage;

@end

@interface MonsterDamage : NSObject
@property (nonatomic) NSString *bodyPart;
@property (nonatomic) int cutDamage;
@property (nonatomic) int impactDamage;
@property (nonatomic) int shotDamage;
@property (nonatomic) int fireDamage;
@property (nonatomic) int waterDamage;
@property (nonatomic) int iceDamage;
@property (nonatomic) int thunderDamage;
@property (nonatomic) int dragonDamage;
@property (nonatomic) int stun;


@end

@interface MonsterDetailView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *monsterImage;
@property (weak, nonatomic) IBOutlet UILabel *monsterName;
@property (weak, nonatomic) IBOutlet UITableView *monsterDetailTable;

@end

@interface MonsterDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *bodyPart;
@property (weak, nonatomic) IBOutlet UILabel *cutLabel;
@property (weak, nonatomic) IBOutlet UILabel *impactLabel;
@property (weak, nonatomic) IBOutlet UILabel *shotLabel;
@property (weak, nonatomic) IBOutlet UILabel *stunLabel;
@property (weak, nonatomic) IBOutlet UILabel *fireLabel;
@property (weak, nonatomic) IBOutlet UILabel *waterLabel;
@property (weak, nonatomic) IBOutlet UILabel *iceLabel;
@property (weak, nonatomic) IBOutlet UILabel *thunderLabel;
@property (weak, nonatomic) IBOutlet UILabel *dragonLabel;

@end


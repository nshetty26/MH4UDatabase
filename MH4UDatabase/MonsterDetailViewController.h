//
//  MonsterDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonsterDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>
@property (nonatomic) Monster *selectedMonster;
@property (nonatomic) int heightDifference;
@end

@interface DetailedMonsterView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *monsterImage;
@property (weak, nonatomic) IBOutlet UILabel *monsterName;

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

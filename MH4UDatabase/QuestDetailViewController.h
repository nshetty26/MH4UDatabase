//
//  QuestDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Quest;
@class MH4UDBEngine;

@interface QuestDetailViewController : UIViewController <UITabBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) Quest *selectedQuest;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) int heightDifference;

@end

@interface DetailedQuestView : UIView
@property (weak, nonatomic) IBOutlet UILabel *questName;
@property (weak, nonatomic) IBOutlet UILabel *questLevel;
@property (weak, nonatomic) IBOutlet UILabel *questHRP;
@property (weak, nonatomic) IBOutlet UILabel *questReward;
@property (weak, nonatomic) IBOutlet UILabel *questFee;
@property (weak, nonatomic) IBOutlet UILabel *questLocation;
@property (weak, nonatomic) IBOutlet UITextView *questGoal;
@property (weak, nonatomic) IBOutlet UILabel *subQuestLabel;
@property (weak, nonatomic) IBOutlet UILabel *subQuestDescription;
@property (weak, nonatomic) IBOutlet UILabel *subQuestHRP;
@property (weak, nonatomic) IBOutlet UILabel *subQuestHRPValue;
@property (weak, nonatomic) IBOutlet UILabel *subQuestRewardLabel;
@property (weak, nonatomic) IBOutlet UILabel *subQuestRewardValue;

-(void)populateViewWithQuest:(Quest *)quest;

@end

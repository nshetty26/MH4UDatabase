//
//  QuestDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "QuestDetailViewController.h"
#import "ItemTableView.h"
#import "MonsterDetailViewController.h"
#import "ItemDetailViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface QuestDetailViewController ()
@property (nonatomic) UITableView *monsterTable;
@property (nonatomic) NSArray *allViews;
@property (nonatomic) ItemTableView *rewardTable;
@property (nonatomic) UITabBar *questDetailTab;
@property (nonatomic) DetailedQuestView *detailedView;
@property (nonatomic) UITableView *questPreReqTable;
@property (nonatomic) NSArray *preReqs;
@end

@implementation QuestDetailViewController

#pragma mark - Setup Views
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    [_dbEngine getQuestInfoforQuest:_selectedQuest];
    _preReqs = [_dbEngine getAllPreReqsForQuest:_selectedQuest];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(_selectedQuest.name, _selectedQuest.name);
    
    // Do any additional setup after loading the view.
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    [self setUpTabBarWithFrame:tabBarFrame];
    
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - _heightDifference - tabBarFrame.size.height);
    [self setUpViewsWithFrame:tablewithTabbar];
    
    
    [self.view addSubview:_detailedView];
    [self.view addSubview:_questDetailTab];
    
}

-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_questDetailTab) {
        _questDetailTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
        UITabBarItem *detailView = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:1];
        UITabBarItem *monster = [[UITabBarItem alloc] initWithTitle:@"Monster" image:nil tag:2];
        UITabBarItem *reward = [[UITabBarItem alloc] initWithTitle:@"Reward" image:nil tag:3];
        UITabBarItem *preReqs = [[UITabBarItem alloc] initWithTitle:@"PreReqs" image:nil tag:4];
        
        _questDetailTab.delegate = self;
        [_questDetailTab setItems:@[detailView, monster, reward, preReqs]];
        [_questDetailTab setSelectedItem:detailView];
    }
}

-(void)setUpViewsWithFrame:(CGRect)tableFrame {
    _monsterTable = [[UITableView alloc] initWithFrame:tableFrame];
    _monsterTable.dataSource = self;
    _monsterTable.delegate = self;
    
    _rewardTable = [[ItemTableView alloc] initWithFrame:tableFrame andNavigationController:self.navigationController andDBEngine:_dbEngine];
    _rewardTable.allItems = _selectedQuest.rewards;
    _rewardTable.accessoryType = @"Percentage";
    
    _questPreReqTable = [[UITableView alloc] initWithFrame:tableFrame];
    _questPreReqTable.dataSource = self;
    _questPreReqTable.delegate = self;
    
    _detailedView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedQuestView" owner:self options:nil] lastObject];
    _detailedView.frame = tableFrame;
    [_detailedView populateViewWithQuest:_selectedQuest];
    _allViews = @[_detailedView, _monsterTable, _rewardTable, _questPreReqTable];
}


#pragma mark - Tab Bar Methods
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([tabBar isEqual:_questDetailTab]) {
        [self removeViewsFromDetail];
        switch (item.tag) {
            case 1:
                [self.view addSubview:_detailedView];
                break;
            case 2:
                [self.view addSubview:_monsterTable];
                break;
            case 3:
                [self.view addSubview:_rewardTable];
                break;
            case 4:
                [self.view addSubview:_questPreReqTable];
                break;
            default:
                break;
        }
        
    }
    [tabBar setSelectedItem:item];
    
}

#pragma mark - Table View Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_monsterTable]) {
        return _selectedQuest.monsters.count;
    } else if ([tableView isEqual:_questPreReqTable])  {
        return _preReqs.count;
    } else {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_monsterTable]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monsterCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"monsterCell"];
        }
        
        Monster *monster = _selectedQuest.monsters[indexPath.row];
        cell.textLabel.text = monster.monsterName;
        cell.imageView.image = [UIImage imageNamed:monster.iconName];
        return cell;
    } else if ([tableView isEqual:_questPreReqTable]) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"preReqCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"preReqCell"];
        }
        
        Quest *quest = _preReqs[(_preReqs.count -1) - indexPath.row];
        cell.textLabel.text = quest.name;
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 50, cellFrame.size.height - 10, 30, 20);
        UILabel *accessoryText = [[UILabel alloc] initWithFrame:textView];
        [cell addSubview:accessoryText];
        accessoryText.textAlignment =  NSTextAlignmentRight;
        accessoryText.text = [quest.type isEqualToString:@"Key"] ? @"Key" : @"";
        UIFont *font = [accessoryText.font fontWithSize:12];
        accessoryText.font = font;
        cell.accessoryView = accessoryText;
        return cell;

    }
    
    
    return NULL;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterTable]) {
        Monster *monster = _selectedQuest.monsters[indexPath.row];
        MonsterDetailViewController *mDVC = [[MonsterDetailViewController alloc] init];
        mDVC.heightDifference = _heightDifference;
        mDVC.selectedMonster = monster;
        mDVC.dbEngine = _dbEngine;
        [self.navigationController pushViewController:mDVC animated:YES];
    } else if ([tableView isEqual:_questPreReqTable]) {
        Quest *quest = _preReqs[(_preReqs.count -1) - indexPath.row];
        QuestDetailViewController *qDVC = [[QuestDetailViewController alloc] init];
        qDVC.dbEngine = _dbEngine;
        qDVC.heightDifference = _heightDifference;
        qDVC.selectedQuest = quest;
        [self.navigationController pushViewController:qDVC animated:YES];
    }
}

#pragma mark - Helper Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeViewsFromDetail {
    for (UIView *view in _allViews) {
        if (view.superview != nil) {
            [view removeFromSuperview];
        }
    }
}

-(void)viewWillLayoutSubviews {
    CGRect vcFrame = self.view.frame;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    int heightdifference = navBar.frame.size.height + statusBar.size.height;
    
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference, vcFrame.size.width, 49);
    _questDetailTab.frame = tabBarFrame;
    
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - (heightdifference + tabBarFrame.size.height));
    
    for (UIView *view in _allViews) {
        view.frame = tablewithTabbar;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end

@implementation DetailedQuestView

-(void)populateViewWithQuest:(Quest *)quest {
    _questName.text = quest.name;
    _questLevel.text  = [NSString stringWithFormat:@"%@ %i", quest.hub, quest.stars];
    _questHRP.text = [NSString stringWithFormat:@"%i", quest.hrp];
    _questReward.text = [NSString stringWithFormat:@"%iz", quest.reward];
    _questFee.text = [NSString stringWithFormat:@"%iz", quest.fee];;
    _questLocation.text = quest.location;
    _questGoal.text = quest.goal;
    
    if (![quest.subQuest isEqualToString:@"None"]) {
        _subQuestDescription.text = quest.subQuest;
        _subQuestHRPValue.text = [NSString stringWithFormat:@"%i", quest.subHRP];
        _subQuestRewardValue.text = [NSString stringWithFormat:@"%iz", quest.subQuestReward];;
    } else {
        _subQuestLabel.hidden = YES;
        _subQuestDescription.hidden = YES;
        _subQuestHRP.hidden = YES;
        _subQuestHRPValue.hidden = YES;
        _subQuestRewardLabel.hidden = YES;
        _subQuestRewardValue.hidden = YES;
    }
}

@end

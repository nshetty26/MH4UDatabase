//
//  QuestDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "QuestDetailViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface QuestDetailViewController ()
@property (nonatomic) UITableView *monsterTable;
@property (nonatomic) UITableView *rewardTable;
@property (nonatomic) UITabBar *questDetailTab;
@property (nonatomic) DetailedQuestView *detailedView;
@end

@implementation QuestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_dbEngine getQuestInfoforQuest:_selectedQuest];
    // Do any additional setup after loading the view from its nib.
    NSString *decorationName = _selectedQuest.name;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:decorationName style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    
    // Do any additional setup after loading the view.
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    
    _questDetailTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
    UITabBarItem *detailView = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:1];
    UITabBarItem *monster = [[UITabBarItem alloc] initWithTitle:@"Monster" image:nil tag:2];
    UITabBarItem *reward = [[UITabBarItem alloc] initWithTitle:@"Reward" image:nil tag:3];
    
    _questDetailTab.delegate = self;
    [_questDetailTab setItems:@[detailView, monster, reward]];
    [_questDetailTab setSelectedItem:detailView];
    _monsterTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _monsterTable.dataSource = self;
    _monsterTable.delegate = self;
    
    _rewardTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _rewardTable.delegate = self;
    _rewardTable.dataSource = self;
    
    _detailedView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedQuestView" owner:self options:nil] lastObject];
    _detailedView.frame = tablewithTabbar;
    [_detailedView populateViewWithQuest:_selectedQuest];
    
    [self.view addSubview:_detailedView];
    [self.view addSubview:_questDetailTab];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"armorCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"armorCell"];
    }
    
    if ([tableView isEqual:_monsterTable]) {
        Monster *monster = _selectedQuest.monsters[indexPath.row];
        cell.textLabel.text = monster.monsterName;
        cell.imageView.image = [UIImage imageNamed:monster.iconName];
        return cell;
    } else if ([tableView isEqual:_rewardTable]) {
        NSArray *itemArray = _selectedQuest.rewards[indexPath.row];
        Item *item = itemArray[1];
        cell.textLabel.text = item.name;
        cell.imageView.image = [UIImage imageNamed:item.icon];
        return cell;
    }
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_monsterTable]) {
        return _selectedQuest.monsters.count;
    } else if ([tableView isEqual:_rewardTable]) {
        return _selectedQuest.rewards.count;
    } else  {
        return 0;
    }
}

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
            default:
                break;
        }
        
    }
    [tabBar setSelectedItem:item];
    
}

-(void)removeViewsFromDetail {
    NSArray *allTables = @[_detailedView, _monsterTable, _rewardTable];
    for (UIView *view in allTables) {
        if (view.superview != nil) {
            [view removeFromSuperview];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (quest.subQuest) {
        _subQuestDescription.text = quest.subQuest;
        _subQuestHRP.text = [NSString stringWithFormat:@"%i", quest.subHRP];
        _subQuestRewardValue.text = [NSString stringWithFormat:@"%iz", quest.subQuestReward];;
    } else {
        _subQuestRewardLabel.hidden = YES;
        _subQuestRewardValue.hidden = YES;
        _subQuestHRP.hidden = YES;
        _subQuestHRPValue.hidden = YES;
        _subQuestRewardLabel.hidden = YES;
        _subQuestRewardValue.hidden = YES;
    }
}

@end

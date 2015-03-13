//
//  QuestDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "QuestDetailViewController.h"
#import "MonsterDetailViewController.h"
#import "ItemDetailViewController.h"
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
    NSString *questName = _selectedQuest.name;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:questName style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    
    // Do any additional setup after loading the view.
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - _heightDifference - tabBarFrame.size.height);
    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterTable]) {
        Monster *monster = _selectedQuest.monsters[indexPath.row];
        MonsterDetailViewController *mDVC = [[MonsterDetailViewController alloc] init];
        mDVC.heightDifference = _heightDifference;
        mDVC.selectedMonster = monster;
        mDVC.dbEngine = _dbEngine;
        [self.navigationController pushViewController:mDVC animated:YES];
        
    } else if ([tableView isEqual:_rewardTable]) {
        Item *item = [_selectedQuest.rewards[indexPath.row] objectAtIndex:1];
        ItemDetailViewController *iDVC = [[ItemDetailViewController alloc] init];
        iDVC.selectedItem = item;
        iDVC.heightDifference = _heightDifference;
        iDVC.dbEngine = _dbEngine;
        [self.navigationController pushViewController:iDVC animated:YES];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"armorCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"armorCell"];
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
        cell.detailTextLabel.text = itemArray[0];
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 60, cellFrame.origin.y + 5, 50, 24);
        UILabel *accessoryText = [[UILabel alloc] initWithFrame:textView];
        [accessoryText setNumberOfLines:2];
        [accessoryText setLineBreakMode:NSLineBreakByWordWrapping];
        [cell addSubview:accessoryText];
        accessoryText.textAlignment =  NSTextAlignmentRight;
        UIFont *font = [accessoryText.font fontWithSize:10];
        accessoryText.font = font;
        accessoryText.text = [NSString stringWithFormat:@"%i%@", item.percentage, @"%"];
        
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
    
    if (![quest.subQuest isEqualToString:@"None"]) {
        _subQuestDescription.text = quest.subQuest;
        _subQuestHRP.text = [NSString stringWithFormat:@"%i", quest.subHRP];
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

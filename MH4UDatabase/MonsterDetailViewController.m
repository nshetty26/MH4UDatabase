//
//  MonsterDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

/*
 STATUS
 SELECT status, initial, increase, max, duration, damage FROM monster_status where monster_status._id = 2
 HABITAT
 SELECT monster_habitat.location_id, locations.name, monster_habitat.start_area, monster_habitat.move_area, monster_habitat.rest_area From monster_habitat INNER JOIN locations on monster_habitat.location_id = locations._id WHERE monster_habitat.monster_id = 24
 
 RANKED DROPS
 SELECT items.name, hunting_rewards.condition, hunting_rewards.rank, hunting_rewards.stack_size, hunting_rewards.percentage from hunting_rewards inner join items on items._id = hunting_rewards.item_id where hunting_rewards.monster_id = 24 and hunting_rewards.rank = 'G'
 
 QUEST
 SELECT quests.name, monster_to_quest.unstable from monster_to_quest inner join quests on quests._id = monster_to_quest.quest_id where monster_to_quest.monster_id = 24
 */

#import "MH4UDBEntity.h"
#import "MonsterDetailViewController.h"

@interface MonsterDetailViewController ()
@property (nonatomic) UITableView *monsterDetailTable;
@property (nonatomic) UITabBar *monsterDetailTabBar;
@property (nonatomic) UITabBarItem *detail;
@property (nonatomic) UITabBarItem *status;
@property (nonatomic) UITabBarItem *habitat;
@property (nonatomic) UITabBarItem *lowRank;
@property (nonatomic) UITabBarItem *highRank;
@property (nonatomic) UITabBarItem *gRank;
@property (nonatomic) UITabBarItem *quest;
@property (nonatomic) DetailedMonsterView *monsterDetailView;

@end

@implementation MonsterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect tableWithSearch = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);

    _monsterDetailTabBar = [[UITabBar alloc] initWithFrame:tabBarFrame];
    _detail = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:1];
    _status = [[UITabBarItem alloc] initWithTitle:@"Status" image:nil tag:2];
    _habitat = [[UITabBarItem alloc] initWithTitle:@"Status" image:nil tag:3];
    _lowRank = [[UITabBarItem alloc] initWithTitle:@"Status" image:nil tag:4];
    _highRank = [[UITabBarItem alloc] initWithTitle:@"Status" image:nil tag:5];
    _gRank = [[UITabBarItem alloc] initWithTitle:@"Status" image:nil tag:6];
    _quest = [[UITabBarItem alloc] initWithTitle:@"Status" image:nil tag:7];
    [_monsterDetailTabBar setItems:@[_detail, _status, _habitat, _lowRank, _highRank, _gRank, _quest]];
    [_monsterDetailTabBar setSelectedItem:_detail];
    
    _monsterDetailView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedMonsterView" owner:self options:nil] lastObject];
    _monsterDetailView.frame = tableWithSearch;
    _monsterDetailView.monsterName.text = _selectedMonster.monsterName;
    _monsterDetailView.monsterImage.image = [UIImage imageNamed:_selectedMonster.iconName];
    
    _monsterDetailTable = [[UITableView alloc] init];
    _monsterDetailTable.delegate = self;
    _monsterDetailTable.dataSource = self;
    _monsterDetailTable.frame = CGRectMake(vcFrame.origin.x, _monsterDetailView.monsterImage.frame.origin.y + _monsterDetailView.monsterImage.frame.size.height + 20, vcFrame.size.height, vcFrame.size.width);
    
    [_monsterDetailView addSubview:_monsterDetailTable];
    [self.view addSubview:_monsterDetailView];
    [self.view addSubview:_monsterDetailTabBar];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_monsterDetailTable]){
        return _selectedMonster.monsterDetailDamage.count;
    } else {
        return 0;
    }
    
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterDetailTable]) {
        MonsterDetailCell *mDC = [tableView dequeueReusableCellWithIdentifier:@"monsterDetailCell"];
        if (!mDC) {
            [tableView registerNib:[UINib nibWithNibName:@"MonsterDetailCell"  bundle:nil] forCellReuseIdentifier:@"monsterDetailCell"];
            mDC = [tableView dequeueReusableCellWithIdentifier:@"monsterDetailCell"];
        }
        return mDC;
    } else {
        return nil;
    }
    
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(MonsterDetailCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterDetailTable]) {
        MonsterDamage *md = _selectedMonster.monsterDetailDamage[indexPath.row];
        cell.bodyPart.text = [NSString stringWithFormat:@"%@", md.bodyPart];
        cell.cutLabel.text = [NSString stringWithFormat:@"%i", md.cutDamage];
        cell.impactLabel.text = [NSString stringWithFormat:@"%i", md.impactDamage];
        cell.shotLabel.text = [NSString stringWithFormat:@"%i", md.shotDamage];
        cell.stunLabel.text = [NSString stringWithFormat:@"%i", md.stun];
        cell.fireLabel.text = [NSString stringWithFormat:@"%i", md.fireDamage];
        cell.waterLabel.text = [NSString stringWithFormat:@"%i", md.waterDamage];
        cell.iceLabel.text = [NSString stringWithFormat:@"%i", md.iceDamage];
        cell.thunderLabel.text = [NSString stringWithFormat:@"%i", md.thunderDamage];
        cell.dragonLabel.text = [NSString stringWithFormat:@"%i", md.dragonDamage];
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterDetailTable]) {
        return 70;
    } else {
        return 44;
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

@implementation DetailedMonsterView

@end

@implementation MonsterDetailCell

@end

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
#import "MH4UDBEngine.h"

@interface MonsterDetailViewController ()
@property (nonatomic) UITableView *monsterDetailTable;
@property (nonatomic) UITableView *statusEffectTable;
@property (nonatomic) UITableView *habitatTable;
@property (nonatomic) UITableView *rankDropTable;
@property (nonatomic) UITableView *questTable;
@property (nonatomic) UITabBar *monsterDetailTabBar;
@property (nonatomic) UITabBarItem *detail;
@property (nonatomic) UITabBarItem *status;
@property (nonatomic) UITabBarItem *habitat;
@property (nonatomic) UITabBarItem *lowRank;
@property (nonatomic) UITabBarItem *highRank;
@property (nonatomic) UITabBarItem *gRank;
@property (nonatomic) UITabBarItem *quest;
@property (nonatomic) DetailedMonsterView *monsterDetailView;
@property (nonatomic) NSArray *monsterDrops;

@end

@implementation MonsterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self populateDetailForMonster:_selectedMonster];
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect fullViewFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);

    _monsterDetailTabBar = [[UITabBar alloc] initWithFrame:tabBarFrame];
    _monsterDetailTabBar.delegate = self;
    
    _detail = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:1];
    _status = [[UITabBarItem alloc] initWithTitle:@"Status" image:nil tag:2];
    _habitat = [[UITabBarItem alloc] initWithTitle:@"Habitat" image:nil tag:3];
    _lowRank = [[UITabBarItem alloc] initWithTitle:@"Low Rank" image:nil tag:4];
    _highRank = [[UITabBarItem alloc] initWithTitle:@"High Rank" image:nil tag:5];
    _gRank = [[UITabBarItem alloc] initWithTitle:@"G Rank" image:nil tag:6];
    _quest = [[UITabBarItem alloc] initWithTitle:@"Quest" image:nil tag:7];
    
    [self setDetailTabBarItems];
    [_monsterDetailTabBar setSelectedItem:_detail];
    
    _monsterDetailView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedMonsterView" owner:self options:nil] lastObject];
    _monsterDetailView.frame = fullViewFrame;
    _monsterDetailView.monsterName.text = _selectedMonster.monsterName;
    _monsterDetailView.monsterImage.image = [UIImage imageNamed:_selectedMonster.iconName];
    
    CGRect tableFrame = CGRectMake(vcFrame.origin.x, _monsterDetailView.monsterImage.frame.origin.y + _monsterDetailView.monsterImage.frame.size.height + 20, vcFrame.size.height, vcFrame.size.width);
    
    _monsterDetailTable = [[UITableView alloc] init];
    _monsterDetailTable.delegate = self;
    _monsterDetailTable.dataSource = self;
    _monsterDetailTable.frame = tableFrame;
    
    _statusEffectTable = [[UITableView alloc] init];
    _statusEffectTable.delegate = self;
    _statusEffectTable.dataSource = self;
    _statusEffectTable.frame = tableFrame;
    
    _habitatTable = [[UITableView alloc] init];
    _habitatTable.delegate = self;
    _habitatTable.dataSource = self;
    _habitatTable.frame = tableFrame;
    
    _rankDropTable = [[UITableView alloc] init];
    _rankDropTable.delegate = self;
    _rankDropTable.dataSource = self;
    _rankDropTable.frame = tableFrame;
    
    _questTable = [[UITableView alloc] init];
    _questTable.delegate = self;
    _questTable.dataSource = self;
    _questTable.frame = tableFrame;
    
    [_monsterDetailView addSubview:_monsterDetailTable];
    [self.view addSubview:_monsterDetailView];
    [self.view addSubview:_monsterDetailTabBar];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_monsterDetailTable]){
        return _selectedMonster.monsterDetailDamage.count;
    } else if  ([tableView isEqual:_statusEffectTable]){
        return _selectedMonster.monsterStatusEffects.count;
    } else if  ([tableView isEqual:_habitatTable]){
        return _selectedMonster.monsterHabitats.count;
    } else if  ([tableView isEqual:_rankDropTable]){
        if ([_monsterDetailTabBar.selectedItem isEqual:_lowRank]) {
            return _selectedMonster.lowRankDrops.count;
        } else if ([_monsterDetailTabBar.selectedItem isEqual:_highRank]) {
            return _selectedMonster.highRankDrops.count;
        } else if ([_monsterDetailTabBar.selectedItem isEqual:_gRank]) {
            return _selectedMonster.gRankDrops.count;
        } else {
            return 0;
        }
    } else if ([tableView isEqual:_questTable]){
        return _selectedMonster.questInfos.count;
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
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monsterDetailCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"monsterDetailCell"];
    }
    
    if  ([tableView isEqual:_statusEffectTable]){
        MonsterStatusEffect *mse = _selectedMonster.monsterStatusEffects[indexPath.row];
        cell.textLabel.text = mse.status;
        return cell;
    } else if  ([tableView isEqual:_habitatTable]){
        MonsterHabitat *mh = _selectedMonster.monsterHabitats[indexPath.row];
        cell.textLabel.text = mh.locationName;
        return cell;
    } else if  ([tableView isEqual:_rankDropTable]){
        if ([_monsterDetailTabBar.selectedItem isEqual:_lowRank]) {
            _monsterDrops = _selectedMonster.lowRankDrops;
        } else if ([_monsterDetailTabBar.selectedItem isEqual:_highRank]) {
            _monsterDrops = _selectedMonster.highRankDrops;
        } else if ([_monsterDetailTabBar.selectedItem isEqual:_gRank]) {
            _monsterDrops = _selectedMonster.gRankDrops;
        }
        Item *huntingDrop = _monsterDrops[indexPath.row];
        cell.textLabel.text = huntingDrop.name;
        return cell;
    } else if ([tableView isEqual:_questTable]){
        NSArray *questInfo = _selectedMonster.questInfos[indexPath.row];
        cell.textLabel.text = questInfo[1];
        return cell;
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

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self removeViewsFromDetail];
    //[self.view addSubview:_monsterDetailView];
    switch (item.tag) {
            case 1:
            [_monsterDetailView addSubview:_monsterDetailTable];
            break;
        case 2:
            [_monsterDetailView addSubview:_statusEffectTable];
            break;
        case 3:
            [_monsterDetailView addSubview:_habitatTable];
            break;
        case 4:
        case 5:
        case 6:
            if (_rankDropTable.superview == nil) {
                [_monsterDetailView addSubview:_rankDropTable];
            }
            [_rankDropTable reloadData];
            break;
        case 7:
            [self.view addSubview:_questTable];
            break;
        default:
            break;
    }
    
    [tabBar setSelectedItem:item];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setDetailTabBarItems {
    NSMutableArray *tabItems = [[NSMutableArray alloc] initWithObjects:_detail, nil];
    if (_selectedMonster.monsterStatusEffects.count > 0) {
        [tabItems addObject:_status];
    }
    if (_selectedMonster.monsterHabitats.count > 0 ) {
        [tabItems addObject:_habitat];
    }
    if (_selectedMonster.lowRankDrops.count > 0 ) {
        [tabItems addObject:_lowRank];
    }
    if (_selectedMonster.highRankDrops.count > 0 ) {
        [tabItems addObject:_highRank];
    }
    if (_selectedMonster.gRankDrops.count > 0 ) {
        [tabItems addObject:_gRank];
    }
    if (_selectedMonster.questInfos.count > 0 ) {
        [tabItems addObject:_quest];
    }
    
    [_monsterDetailTabBar setItems:tabItems];
}

-(void)removeViewsFromDetail {
    
    if (_rankDropTable.superview != nil && ([_monsterDetailTabBar.selectedItem isEqual:_lowRank] || [_monsterDetailTabBar.selectedItem isEqual:_highRank] || [_monsterDetailTabBar.selectedItem isEqual:_gRank])) {
        return;
    }
    
    NSArray *allViews = @[_monsterDetailTable, _statusEffectTable, _habitatTable, _rankDropTable, _questTable];
    
    for (UIView *view in allViews) {
        if (view.superview != nil) {
            [view removeFromSuperview];
        }
    }
}

-(void)populateDetailForMonster:(Monster*) monster {
    [_dbEngine getDetailsForMonster:monster];
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

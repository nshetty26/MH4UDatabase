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
#import "ItemDetailViewController.h"
#import "QuestDetailViewController.h"
#import "LocationDetailViewController.h"

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
@property (nonatomic) NSArray *allViews;

@end

@implementation MonsterDetailViewController

#pragma mark - Setup Views
-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_monsterDetailTabBar) {
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
    }
}

-(void)setUpTablesWithFrame:(CGRect)tableFrame {
        _monsterDetailTable = [[UITableView alloc] initWithFrame:tableFrame];
        _statusEffectTable = [[UITableView alloc] initWithFrame:tableFrame];
        _habitatTable = [[UITableView alloc] initWithFrame:tableFrame];
        _rankDropTable = [[UITableView alloc] initWithFrame:tableFrame];
        _questTable = [[UITableView alloc] initWithFrame:tableFrame];
    
    _allViews = @[_monsterDetailTable, _statusEffectTable, _habitatTable, _rankDropTable, _questTable];
    
    for (UITableView *table in _allViews) {
        UITableView *tableView = (UITableView *)table;
        if (tableView) {
            tableView.delegate = self;
            tableView.dataSource = self;
            
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(_selectedMonster.monsterName, _selectedMonster.monsterName);
    [self populateDetailForMonster:_selectedMonster];
    CGRect vcFrame = self.view.frame;
    
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    
    CGRect fullViewFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    _monsterDetailView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedMonsterView" owner:self options:nil] lastObject];
    _monsterDetailView.frame = fullViewFrame;
    _monsterDetailView.monsterName.text = _selectedMonster.monsterName;
    _monsterDetailView.monsterImage.image = [UIImage imageNamed:_selectedMonster.iconName];
    
    CGRect tableFrame = CGRectMake(vcFrame.origin.x, _monsterDetailView.monsterImage.frame.origin.y + _monsterDetailView.monsterImage.frame.size.height + 20, vcFrame.size.height, vcFrame.size.width);
    
    [self setUpTabBarWithFrame:tabBarFrame];
    [self setUpTablesWithFrame:tableFrame];
    
    [_monsterDetailView addSubview:_monsterDetailTable];
    [self.view addSubview:_monsterDetailView];
    [self.view addSubview:_monsterDetailTabBar];
}

#pragma mark - Tab Bar Methods
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self removeViewsFromDetail];
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
            [_monsterDetailView addSubview:_questTable];
            break;
        default:
            break;
    }
    
    [tabBar setSelectedItem:item];
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

#pragma mark - Table View Methods
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"monsterDetailCell"];
    }
    
    if  ([tableView isEqual:_statusEffectTable]){
        MonsterStatusEffect *mse = _selectedMonster.monsterStatusEffects[indexPath.row];
        
        NSString *imageString;
        if ([mse.status isEqualToString:@"KO"]) {
            imageString = @"Stun";
        } else if ([mse.status isEqualToString:@"Para"]) {
            imageString = @"Paralysis";
        } else if ([mse.status isEqualToString:@"Blast"]) {
            imageString = @"Blastblight";
        } else if ([mse.status isEqualToString:@"Jump"]) {
            imageString = @"QuestionMark-Blue.png";
        } else {
            imageString = mse.status;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"[%@] Initial: %i \\ Max: %i",mse.status, mse.initial, mse.max];;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Damage %i \\ Duration: %i \\ Increase: %i",mse.damage, mse.duration, mse.increase];
        cell.imageView.image =[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", imageString]];
        return cell;
    } else if  ([tableView isEqual:_habitatTable]){
        MonsterHabitat *mh = _selectedMonster.monsterHabitats[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:mh.icon];
        cell.textLabel.text = mh.locationName;
        cell.detailTextLabel.text = mh.fullPath;
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
        cell.imageView.image = [UIImage imageNamed:huntingDrop.icon];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", huntingDrop.condition];
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 60, cellFrame.origin.y + 5, 50, 24);
        UILabel *accessoryText = [[UILabel alloc] initWithFrame:textView];
        [accessoryText setNumberOfLines:2];
        [accessoryText setLineBreakMode:NSLineBreakByWordWrapping];
        [cell addSubview:accessoryText];
        accessoryText.textAlignment =  NSTextAlignmentRight;
        UIFont *font = [accessoryText.font fontWithSize:10];
        accessoryText.font = font;
        accessoryText.text = [NSString stringWithFormat:@"%i%@", huntingDrop.percentage, @"%"];
        cell.accessoryView = accessoryText;
        return cell;
    } else if ([tableView isEqual:_questTable]){
        Quest *quest = _selectedMonster.questInfos[indexPath.row];
        cell.textLabel.text = quest.name;
        cell.detailTextLabel.text = quest.fullHub;
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 60, cellFrame.origin.y + 5, 50, 24);
        UILabel *accessoryText = [[UILabel alloc] initWithFrame:textView];
        [accessoryText setNumberOfLines:2];
        [accessoryText setLineBreakMode:NSLineBreakByWordWrapping];
        [cell addSubview:accessoryText];
        
        accessoryText.textAlignment =  NSTextAlignmentRight;
        UIFont *font = [accessoryText.font fontWithSize:10];
        accessoryText.font = font;
        accessoryText.text = [NSString stringWithFormat:@"%@", ([quest.unstable isEqualToString:@"Unstable"]) ? @"Unstable" : @""];
        
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_rankDropTable]) {
        if ([_monsterDetailTabBar.selectedItem isEqual:_lowRank]) {
            _monsterDrops = _selectedMonster.lowRankDrops;
        } else if ([_monsterDetailTabBar.selectedItem isEqual:_highRank]) {
            _monsterDrops = _selectedMonster.highRankDrops;
        } else if ([_monsterDetailTabBar.selectedItem isEqual:_gRank]) {
            _monsterDrops = _selectedMonster.gRankDrops;
        }
        Item *huntingDrop = _monsterDrops[indexPath.row];
        ItemDetailViewController *itemDetailVC = [[ItemDetailViewController alloc] init];
        itemDetailVC.selectedItem = huntingDrop;
        itemDetailVC.dbEngine = _dbEngine;
        itemDetailVC.heightDifference = _heightDifference;
        [self.navigationController pushViewController:itemDetailVC animated:YES];
    } else if ([tableView isEqual:_questTable]) {
        Quest *quest = _selectedMonster.questInfos[indexPath.row];
        QuestDetailViewController *qDVC = [[QuestDetailViewController alloc] init];
        qDVC.dbEngine = _dbEngine;
        qDVC.heightDifference = _heightDifference;
        qDVC.selectedQuest = quest;
        [self.navigationController pushViewController:qDVC animated:YES];
    } else if ([tableView isEqual:_habitatTable]) {
        LocationDetailViewController *lDVC = [[LocationDetailViewController alloc] init];
        MonsterHabitat *mh = _selectedMonster.monsterHabitats[indexPath.row];
        Location *location = [[Location alloc] init];
        location.locationID = mh.locationID;
        location.locationName = mh.locationName;
        location.locationIcon = mh.icon;
        lDVC.heightDifference = _heightDifference;
        lDVC.selectedLocation = location;
        lDVC.dbEngine = _dbEngine;
        [self.navigationController pushViewController:lDVC animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterDetailTable]) {
        return 70;
    } else {
        return 44;
    }
}



#pragma mark - Helper Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)removeViewsFromDetail {
    
    if (_rankDropTable.superview != nil && ([_monsterDetailTabBar.selectedItem isEqual:_lowRank] || [_monsterDetailTabBar.selectedItem isEqual:_highRank] || [_monsterDetailTabBar.selectedItem isEqual:_gRank])) {
        return;
    }
    
    for (UIView *view in _allViews) {
        if (view.superview != nil) {
            [view removeFromSuperview];
        }
    }
}

-(void)populateDetailForMonster:(Monster*) monster {
    [_dbEngine getDetailsForMonster:monster];
}

-(void)viewWillLayoutSubviews {
    CGRect vcFrame = self.view.frame;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    int heightdifference = navBar.frame.size.height + statusBar.size.height;
    
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference, vcFrame.size.width, 49);
    _monsterDetailTabBar.frame = tabBarFrame;

    
    CGRect fullViewFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    _monsterDetailView.frame = fullViewFrame;
    
    CGRect tableFrame = CGRectMake(vcFrame.origin.x, _monsterDetailView.monsterImage.frame.origin.y + _monsterDetailView.monsterImage.frame.size.height + 20, vcFrame.size.width, vcFrame.size.height - (heightdifference + _monsterDetailView.monsterImage.frame.size.height + 20 + tabBarFrame.size.height));
    
    for (UIView *view in _allViews) {
        view.frame = tableFrame;
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

@implementation DetailedMonsterView

@end

@implementation MonsterDetailCell

@end

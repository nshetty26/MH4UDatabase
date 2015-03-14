//
//  LocationDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "MonsterDetailViewController.h"
#import "ItemDetailViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface LocationDetailViewController ()
@property (nonatomic) UITabBar *locationDetailTabBar;
@property (nonatomic) UITabBarItem *map;
@property (nonatomic) UITabBarItem *monsters;
@property (nonatomic) UITabBarItem *lowRank;
@property (nonatomic) UITabBarItem *highRank;
@property (nonatomic) UITabBarItem *gRank;
@property (nonatomic) UIView *largeMap;
@property (nonatomic) UITableView *monsterTable;
@property (nonatomic) UITableView *rankDropTable;

@end

@implementation LocationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *locationName = _selectedLocation.locationName;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:locationName style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    // Do any additional setup after loading the view.
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    [_dbEngine monstersForLocationID:_selectedLocation];
    [_dbEngine itemsForLocationID:_selectedLocation];
    _locationDetailTabBar = [[UITabBar alloc] initWithFrame:tabBarFrame];
    _locationDetailTabBar.delegate = self;
    _map = [[UITabBarItem alloc] initWithTitle:@"Map" image:nil tag:1];
    _monsters = [[UITabBarItem alloc] initWithTitle:@"Monsters" image:nil tag:2];
    _lowRank = [[UITabBarItem alloc] initWithTitle:@"Low Rank" image:nil tag:3];
    _highRank = [[UITabBarItem alloc] initWithTitle:@"High Rank" image:nil tag:4];
    _gRank = [[UITabBarItem alloc] initWithTitle:@"G Rank" image:nil tag:5];
    [_locationDetailTabBar setItems:@[_map, _monsters, _lowRank, _highRank, _gRank]];
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + tabBarFrame.size.height + _heightDifference, vcFrame.size.width, vcFrame.size.height - _heightDifference - tabBarFrame.size.height);
    
    _largeMap = [[UIView alloc] initWithFrame:tablewithTabbar];
    [_largeMap setBackgroundColor:[UIColor whiteColor]];
    
    _rankDropTable = [[UITableView alloc] init];
    _rankDropTable.delegate = self;
    _rankDropTable.dataSource = self;
    _rankDropTable.frame = tablewithTabbar;
    
    _monsterTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _monsterTable.dataSource = self;
    _monsterTable.delegate = self;
    
    CGRect labelFrame = CGRectMake(_largeMap.bounds.origin.x, _largeMap.bounds.origin.y + 10, _largeMap.bounds.size.width, 20);

    UILabel *locationTitle = [[UILabel alloc] initWithFrame:labelFrame];
    [locationTitle setTextAlignment:NSTextAlignmentCenter];
    UIFont *font = [locationTitle.font fontWithSize:20];;
    locationTitle.font = font;
    locationTitle.text = _selectedLocation.locationName;
    
    CGRect imageFrame = CGRectMake(_largeMap.bounds.origin.x, _largeMap.bounds.origin.y + 30, _largeMap.bounds.size.width, _largeMap.bounds.size.height - 30);
    
    UIImageView *mapImage = [[UIImageView alloc] initWithFrame:imageFrame];
    mapImage.image = [UIImage imageNamed:_selectedLocation.locationIcon];
    [self.view addSubview:_largeMap];
    [_largeMap addSubview:locationTitle];
    [_largeMap addSubview:mapImage];
    [self.view addSubview:_locationDetailTabBar];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if  ([tableView isEqual:_monsterTable]){
        return _selectedLocation.monsterArray.count;
    } else if  ([tableView isEqual:_rankDropTable]){
        if ([_locationDetailTabBar.selectedItem isEqual:_lowRank]) {
            return _selectedLocation.lowRankItemsArray.count;
        } else if ([_locationDetailTabBar.selectedItem isEqual:_highRank]) {
            return _selectedLocation.highRankItemsArray.count;
        } else if ([_locationDetailTabBar.selectedItem isEqual:_gRank]) {
            return _selectedLocation.gRankItemsArray.count;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monsterDetailCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"monsterDetailCell"];
    }
    if  ([tableView isEqual:_monsterTable]){
        Monster *monster = [_selectedLocation.monsterArray[indexPath.row]objectAtIndex:0];
        MonsterHabitat *mh = [_selectedLocation.monsterArray[indexPath.row]objectAtIndex:1];
        cell.textLabel.text = monster.monsterName;
        cell.detailTextLabel.text = mh.fullPath;
        cell.imageView.image = [UIImage imageNamed:monster.iconName];
        return cell;
    } else if  ([tableView isEqual:_rankDropTable]){
        GatheredResource *gatheredResource;
        if ([_locationDetailTabBar.selectedItem isEqual:_lowRank]) {
            gatheredResource = _selectedLocation.lowRankItemsArray[indexPath.row];
        } else if ([_locationDetailTabBar.selectedItem isEqual:_highRank]) {
            gatheredResource = _selectedLocation.highRankItemsArray[indexPath.row];
        } else if ([_locationDetailTabBar.selectedItem isEqual:_gRank]) {
            gatheredResource = _selectedLocation.gRankItemsArray[indexPath.row];
        }
        cell.textLabel.text = gatheredResource.name;
        cell.imageView.image = [UIImage imageNamed:gatheredResource.icon];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", gatheredResource.site,gatheredResource.area];
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 60, cellFrame.origin.y + 5, 50, 24);
        UILabel *accessoryText = [[UILabel alloc] initWithFrame:textView];
        [accessoryText setNumberOfLines:2];
        [accessoryText setLineBreakMode:NSLineBreakByWordWrapping];
        [cell addSubview:accessoryText];
        accessoryText.textAlignment =  NSTextAlignmentRight;
        UIFont *font = [accessoryText.font fontWithSize:10];
        accessoryText.font = font;
        accessoryText.text = [NSString stringWithFormat:@"%i%@", gatheredResource.percentage, @"%"];
        return cell;
    } else {
        return nil;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_monsterTable]) {
        MonsterDetailViewController *mDVC = [[MonsterDetailViewController alloc] init];
        mDVC.dbEngine = _dbEngine;
        mDVC.selectedMonster = [_selectedLocation.monsterArray[indexPath.row] objectAtIndex:0];
        mDVC.heightDifference = _heightDifference;
        [self.navigationController pushViewController:mDVC animated:YES];
    } else if ([tableView isEqual:_rankDropTable]) {
        ItemDetailViewController *iDVC = [[ItemDetailViewController alloc] init];
        iDVC.dbEngine = _dbEngine;
        iDVC.heightDifference = _heightDifference;
        GatheredResource *gatheredResource;
        if ([_locationDetailTabBar.selectedItem isEqual:_lowRank]) {
            gatheredResource = _selectedLocation.lowRankItemsArray[indexPath.row];
        } else if ([_locationDetailTabBar.selectedItem isEqual:_highRank]) {
            gatheredResource = _selectedLocation.highRankItemsArray[indexPath.row];
        } else if ([_locationDetailTabBar.selectedItem isEqual:_gRank]) {
            gatheredResource = _selectedLocation.gRankItemsArray[indexPath.row];
        }
        iDVC.selectedItem = [_dbEngine getItemForName:gatheredResource.name];
        [self.navigationController pushViewController:iDVC animated:YES];

    }
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self removeViewsFromDetail];
    //[self.view addSubview:_monsterDetailView];
    switch (item.tag) {
        case 1:
            [self.view addSubview:_largeMap];
            break;
        case 2:
            [self.view addSubview:_monsterTable];
            break;
        case 3:
        case 4:
        case 5:
            if (_rankDropTable.superview == nil) {
                [self.view addSubview:_rankDropTable];
            }
            [_rankDropTable reloadData];
            break;
        default:
            break;
    }
    
    [tabBar setSelectedItem:item];
}

-(void)removeViewsFromDetail {
    NSArray *allTables = @[_largeMap, _monsterTable, _rankDropTable];
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

@implementation LargeMapView

@end

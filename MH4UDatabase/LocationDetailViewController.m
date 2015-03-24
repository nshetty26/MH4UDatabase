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
@property (nonatomic) UILabel *mapLabel;
@property (nonatomic) UIWebView *mapView;
@property (nonatomic) NSArray *allViews;
@property (nonatomic) NSArray *allTableViews;
@property (nonatomic) UILabel *cellAccessoryText;
@property (nonatomic) UITabBarItem *map;
@property (nonatomic) UITabBarItem *monsters;
@property (nonatomic) UITabBarItem *lowRank;
@property (nonatomic) UITabBarItem *highRank;
@property (nonatomic) UITabBarItem *gRank;
@property (nonatomic) UITableView *monsterTable;
@property (nonatomic) UITableView *rankDropTable;

@end

@implementation LocationDetailViewController

#pragma mark - Setup Views

-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    _locationDetailTabBar = [[UITabBar alloc] initWithFrame:tabBarFrame];
    _locationDetailTabBar.delegate = self;
    _map = [[UITabBarItem alloc] initWithTitle:@"Map" image:nil tag:1];
    _monsters = [[UITabBarItem alloc] initWithTitle:@"Monsters" image:nil tag:2];
    _lowRank = [[UITabBarItem alloc] initWithTitle:@"Low Rank" image:nil tag:3];
    _highRank = [[UITabBarItem alloc] initWithTitle:@"High Rank" image:nil tag:4];
    _gRank = [[UITabBarItem alloc] initWithTitle:@"G Rank" image:nil tag:5];
    [_locationDetailTabBar setItems:@[_map, _monsters, _lowRank, _highRank, _gRank]];
}

-(void)setUpViewsWithFrame:(CGRect)viewFrame {
    
    //Set up Map Title
    CGRect labelFrame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y + 10, viewFrame.size.width, 20);
    _mapLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [_mapLabel setTextAlignment:NSTextAlignmentCenter];
    UIFont *font = [_mapLabel.font fontWithSize:20];;
    _mapLabel.font = font;
    _mapLabel.text = _selectedLocation.locationName;
    
    //Set up Map Image
    CGRect imageFrame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y + 30, viewFrame.size.width, viewFrame.size.height - 30);
    _mapView = [[UIWebView alloc] initWithFrame:imageFrame];
    NSString *path = [_selectedLocation.locationIcon stringByDeletingPathExtension];
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:path ofType:@"png"]];
    [_mapView loadRequest:[NSURLRequest requestWithURL:url]];
    _mapView.scalesPageToFit = YES;
    //UIImageView *mapImage = [[UIImageView alloc] initWithFrame:imageFrame];
    //mapImage.image = [UIImage imageNamed:_selectedLocation.locationIcon];

    [self.view addSubview:_mapLabel];
    [self.view addSubview:_mapView];
    
    _rankDropTable = [[UITableView alloc] initWithFrame:viewFrame];
    _rankDropTable.delegate = self;
    _rankDropTable.dataSource = self;

    _monsterTable = [[UITableView alloc] initWithFrame:viewFrame];
    _monsterTable.dataSource = self;
    _monsterTable.delegate = self;
    
    _allTableViews = @[_rankDropTable, _monsterTable];
    _allViews = @[_mapLabel, _mapView, _rankDropTable, _monsterTable];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(_selectedLocation.locationName, _selectedLocation.locationName);
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [_dbEngine monstersForLocationID:_selectedLocation];
    [_dbEngine itemsForLocationID:_selectedLocation];

    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    [self setUpTabBarWithFrame:tabBarFrame];
    
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + tabBarFrame.size.height + _heightDifference, vcFrame.size.width, vcFrame.size.height - (_heightDifference + tabBarFrame.size.height));
    [self setUpViewsWithFrame:tablewithTabbar];

    //[self.view addSubview:_largeMap];
    [self.view addSubview:_locationDetailTabBar];
    
}

#pragma mark - Tab Bar Methods
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self removeViewsFromDetail];
    //[self.view addSubview:_monsterDetailView];
    switch (item.tag) {
        case 1:
            [self.view addSubview:_mapLabel];
            [self.view addSubview:_mapView];
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

#pragma mark Table View Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if  ([tableView isEqual:_monsterTable]){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monsterDetailCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"monsterDetailCell"];
        }
        Monster *monster = [_selectedLocation.monsterArray[indexPath.row]objectAtIndex:0];
        MonsterHabitat *mh = [_selectedLocation.monsterArray[indexPath.row]objectAtIndex:1];
        cell.textLabel.text = monster.monsterName;
        cell.detailTextLabel.text = mh.fullPath;
        cell.imageView.image = [UIImage imageNamed:monster.iconName];
        return cell;
    } else if  ([tableView isEqual:_rankDropTable]){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemDetailCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"itemDetailCell"];
        }
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
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ - %i%@", gatheredResource.site,gatheredResource.area, gatheredResource.percentage, @"%"];
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
    _locationDetailTabBar.frame = tabBarFrame;
    
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - (heightdifference + tabBarFrame.size.height));
    
    CGRect labelFrame = CGRectMake(tablewithTabbar.origin.x, tablewithTabbar.origin.y + 10, tablewithTabbar.size.width, 20);
    _mapLabel.frame = labelFrame;

    
    //Set up Map Image
    CGRect mapFrame = CGRectMake(tablewithTabbar.origin.x, tablewithTabbar.origin.y + 30, tablewithTabbar.size.width, tablewithTabbar.size.height - 30);
    _mapView.frame = mapFrame;

    
    for (UIView *view in _allTableViews) {
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

@implementation LargeMapView

@end

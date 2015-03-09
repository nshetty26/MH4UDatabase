//
//  ItemDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/9/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "MH4UDBEngine.h"
#import "MenuViewController.h"
#import "ItemsViewController.h"

@interface ItemDetailViewController ()
@property (nonatomic) DetailedItemView *detailItemView;
@property (nonatomic) UITabBarItem *itemDetail;
@property (nonatomic) UITabBarItem *combining;
@property (nonatomic) UITabBarItem *usage;
@property (nonatomic) UITabBarItem *monster;
@property (nonatomic) UITabBarItem *quest;
@property (nonatomic) UITabBarItem *location;
@property (nonatomic) UITableView *combiningTable;
@property (nonatomic) UITableView *usageTable;
@property (nonatomic) UITableView *monsterDropTable;
@property (nonatomic) UITableView *questRewardTable;
@property (nonatomic) UITableView *locationTable;
@property (nonatomic) UITabBar *itemDetailBar;
@end

@implementation ItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect tabBarFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + _heightDifference , self.view.frame.size.width, 49);
    CGRect vcFrame = CGRectMake(self.view.frame.origin.x, tabBarFrame.origin.y + tabBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    
    _combiningTable = [[UITableView alloc] initWithFrame:vcFrame];
    _combiningTable.dataSource = self;
    _combiningTable.delegate = self;
    
    _usageTable = [[UITableView alloc] initWithFrame:vcFrame];
    _usageTable.dataSource = self;
    _usageTable.delegate = self;
    
    _monsterDropTable = [[UITableView alloc] initWithFrame:vcFrame];
    _monsterDropTable.dataSource = self;
    _monsterDropTable.delegate = self;
    
    _questRewardTable = [[UITableView alloc] initWithFrame:vcFrame];
    _questRewardTable.dataSource = self;
    _questRewardTable.delegate = self;
    
    _locationTable = [[UITableView alloc] initWithFrame:vcFrame];
    _locationTable.dataSource = self;
    _locationTable.delegate = self;
    
    _itemDetailBar = [[UITabBar alloc] initWithFrame:tabBarFrame];
    _itemDetailBar.delegate = self;
    
    _itemDetail = [[UITabBarItem alloc] initWithTitle:@"Item Detail" image:nil tag:1];
    _combining = [[UITabBarItem alloc] initWithTitle:@"Combining" image:nil tag:2];
    _usage = [[UITabBarItem alloc] initWithTitle:@"Usage" image:nil tag:3];
    _monster = [[UITabBarItem alloc] initWithTitle:@"Monster Drop" image:nil tag:4];
    _quest = [[UITabBarItem alloc] initWithTitle:@"Quest Reward" image:nil tag:5];
    _location = [[UITabBarItem alloc] initWithTitle:@"Location" image:nil tag:6];
    
    _detailItemView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedItemView" owner:self options:nil] lastObject];
    _detailItemView.frame = vcFrame;
    [_detailItemView populateViewWithItem:_selectedItem];
    [self setDetailTabBarforItem:_selectedItem];
    [self.view addSubview:_detailItemView];
    [self.view addSubview:_itemDetailBar];


}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_combiningTable]) {
        return _selectedItem.combinedItemsArray.count;
    } else if ([tableView isEqual:_usageTable]) {
        return _selectedItem.usageItemsArray.count;
    } else if ([tableView isEqual:_monsterDropTable]) {
        return _selectedItem.monsterDropsArray.count;
    } else if ([tableView isEqual:_questRewardTable]) {
        return _selectedItem.questRewardsArray.count;
    } else if ([tableView isEqual:_locationTable]) {
        return _selectedItem.locationsArray.count;
    } else {
        return 0;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_combiningTable]) {
        CombiningCell *combiningCell = [tableView dequeueReusableCellWithIdentifier:@"combiningCell"];
        
        if (!combiningCell) {
            [tableView registerNib:[UINib nibWithNibName:@"UICombiningTableCell"  bundle:nil] forCellReuseIdentifier:@"combiningCell"];
            combiningCell = [tableView dequeueReusableCellWithIdentifier:@"combiningCell"];
        }
        return combiningCell;
    }
    
    else if ([tableView isEqual:_usageTable]){
        NSArray *usageArray = _selectedItem.usageItemsArray[indexPath.row];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemIdentifier"];
        NSString *label = [NSString stringWithFormat:@"%@: %@ %@", usageArray[0], usageArray[1], usageArray[2]];
        cell.textLabel.text = label;
        return cell;
    }
    
    else if ([tableView isEqual:_monsterDropTable]){
        NSArray *monsterDropArray = _selectedItem.monsterDropsArray[indexPath.row];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemIdentifier"];
        NSString *label = [NSString stringWithFormat:@" %@: %@ %@, %@ %@%@", monsterDropArray[0], monsterDropArray[1], monsterDropArray[2], monsterDropArray[3], monsterDropArray[4], @"%"];
        cell.textLabel.text = label;
        return cell;
    }
    
    else if ([tableView isEqual:_questRewardTable]){
        NSArray *questRewardArray = _selectedItem.questRewardsArray[indexPath.row];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemIdentifier"];
        NSString *label = [NSString stringWithFormat:@" %@: %@ %@, %@ %@ %@%@", questRewardArray[0], questRewardArray[1], questRewardArray[2], questRewardArray[3], questRewardArray[4], questRewardArray[5], @"%"];
        cell.textLabel.text = label;
        return cell;
    }
    
    else if ([tableView isEqual:_locationTable]){
        NSArray *locationArray = _selectedItem.locationsArray[indexPath.row];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemIdentifier"];
        NSString *label = [NSString stringWithFormat:@" %@: %@ %@, %@ %@ %@%@", locationArray[0], locationArray[1], locationArray[2], locationArray[3], locationArray[4], locationArray[5], @"%"];
        cell.textLabel.text = label;
        return cell;
    }
    
    else {
        return nil;
    }
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(CombiningCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_combiningTable]) {
        NSArray *combiningArray = _selectedItem.combinedItemsArray[indexPath.row];
        NSArray *combinedItemInfo = [_dbEngine infoForCombinedTableCellforItemID:combiningArray[0]];
        NSArray *item1Info = [_dbEngine infoForCombinedTableCellforItemID:combiningArray[1]];
        NSArray *item2Info = [_dbEngine infoForCombinedTableCellforItemID:combiningArray[2]];
        
        cell.combinedItemName.text = combinedItemInfo[0];
        cell.combinedImageView.image = [UIImage imageNamed:combinedItemInfo[1]];
        
        cell.item1Name.text = item1Info[0];
        cell.item2Name.text = item2Info[0];
        cell.maxCombined.text = [NSString stringWithFormat:@"Max: %@", combiningArray[4]];
        cell.percentageCombined.text = [NSString stringWithFormat:@"%@%@", combiningArray[5], @"%"];
        cell.item1ImageView.image = [UIImage imageNamed:item1Info[1]];
        cell.item2ImageView.image = [UIImage imageNamed:item2Info[1]];
    }
    
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self removeTableViewsFromDetail];
    switch (item.tag) {
        case 1:
            [self.view addSubview:_detailItemView];
            break;
        case 2:
            
            [self.view addSubview:_combiningTable];
            break;
        case 3:
            [self.view addSubview:_usageTable];
            break;
        case 4:
            [self.view addSubview:_monsterDropTable];
            break;
        case 5:
            [self.view addSubview:_questRewardTable];
            break;
        case 6:
            [self.view addSubview:_locationTable];
            break;
        default:
            break;
    }
    [self.view addSubview:_itemDetailBar];
}

-(void)setDetailTabBarforItem:(Item *)item {
    
    NSMutableArray *tabItems = [[NSMutableArray alloc] initWithObjects:_itemDetail  , nil];
    [_itemDetailBar setSelectedItem:_itemDetail];

    if (item.combinedItemsArray.count > 0) {
        [tabItems addObject:_combining];
    }
    
    if (item.usageItemsArray.count > 0) {
        [tabItems addObject:_usage];
    }
    
    if (item.monsterDropsArray.count > 0) {
        [tabItems addObject:_monster];
    }
    
    if (item.questRewardsArray.count > 0) {
        [tabItems addObject:_quest];
    }
    
    if (item.locationsArray.count > 0) {
        [tabItems addObject:_location];
    }
    
    _itemDetailBar.items = tabItems;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeTableViewsFromDetail {
    NSArray *allViews = @[_detailItemView, _combiningTable, _usageTable, _monsterDropTable, _questRewardTable, _locationTable];

    for (UIView *view in allViews) {
        if (view.superview != nil) {
            [view removeFromSuperview];
        }
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

@implementation DetailedItemView

-(void)populateViewWithItem:(Item *)item {
    _iconImageView.image = [UIImage imageNamed:item.icon];
    _itemName.text = item.name;
    _rareLabel.text = [NSString stringWithFormat:@"%i", item.rarity];
    _capacityLabel.text = [NSString stringWithFormat:@"%i", item.capacity];
    _priceLabel.text = [NSString stringWithFormat:@"%i", item.price];
    _salePriceLabel.text = [NSString stringWithFormat:@"%i", item.salePrice];
    _itemDescription.text = [NSString stringWithFormat:@"%@", item.itemDescription];;
    
}

@end

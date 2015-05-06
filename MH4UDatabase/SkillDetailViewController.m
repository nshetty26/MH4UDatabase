//
//  SkillDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "SkillDetailViewController.h"
#import "ItemDetailViewController.h"
#import "ArmorDetailViewController.h"
#import "DecorationsDetailViewController.h"
#import "ItemTableView.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface SkillDetailViewController ()
@property (nonatomic) SkillCollection *skillCollection;
@property (nonatomic) NSArray *allViews;
@property (nonatomic) UITableView *skillDetailTable;
@property (nonatomic) ItemTableView *equipmentTable;
@property (nonatomic) UITabBar *skillDetailTab;
@property (nonatomic) UITabBarItem *detail;
@property (nonatomic) UITabBarItem *body;
@property (nonatomic) UITabBarItem *head;
@property (nonatomic) UITabBarItem *arm;
@property (nonatomic) UITabBarItem *waist;
@property (nonatomic) UITabBarItem *leg;
@property (nonatomic) UITabBarItem *decorations;
@end

@implementation SkillDetailViewController
#pragma mark - Setup Views

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    self.title = NSLocalizedString(_skilTreeName, _skilTreeName);
    _skillCollection = [_dbEngine getSkillCollectionForSkillTreeID:_skillTreeID];
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    [self setUpTabBarWithFrame:tabBarFrame];
    
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height -( _heightDifference + tabBarFrame.size.height));
    [self setUpViewsWithFrame:tablewithTabbar];
    
    
    [self.view addSubview:_skillDetailTable];
    [self.view addSubview:_skillDetailTab];
    
}

-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    _skillDetailTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
    _skillDetailTab.delegate = self;
    
    _detail = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:1];
    _head = [[UITabBarItem alloc] initWithTitle:@"Head" image:nil tag:2];
    _body = [[UITabBarItem alloc] initWithTitle:@"Body" image:nil tag:3];
    _arm = [[UITabBarItem alloc] initWithTitle:@"Arm" image:nil tag:4];
    _waist = [[UITabBarItem alloc] initWithTitle:@"Waist" image:nil tag:5];
    _leg = [[UITabBarItem alloc] initWithTitle:@"Legs" image:nil tag:6];
    _decorations = [[UITabBarItem alloc] initWithTitle:@"Decorations" image:nil tag:7];
    
    [self setDetailTabBarItems];
    [_skillDetailTab setSelectedItem:[_skillDetailTab.items firstObject]];
    
}

-(void)setUpViewsWithFrame:(CGRect)tableFrame {
    _skillDetailTable = [[UITableView alloc] initWithFrame:tableFrame];
    _skillDetailTable.dataSource = self;
    _skillDetailTable.delegate = self;
    _equipmentTable = [[ItemTableView alloc] initWithFrame:tableFrame andNavigationController:self.navigationController andDBEngine:_dbEngine];
    _equipmentTable.accessoryType = @"Quantity";
    _allViews = @[_skillDetailTable, _equipmentTable];
}


#pragma mark - Tab Bar Methods
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self removeViewsFromDetail];
    //[self.view addSubview:_monsterDetailView];
    switch (item.tag) {
        case 1:
            [self.view addSubview:_skillDetailTable];
            break;
        case 2:
            if (!_equipmentTable.superview) {
                [self.view addSubview:_equipmentTable];
            }
            _equipmentTable.allItems = _skillCollection.headArray;
            [_equipmentTable reloadData];
            break;
        case 3:
            if (!_equipmentTable.superview) {
                [self.view addSubview:_equipmentTable];
            }
            _equipmentTable.allItems = _skillCollection.bodyArray;
            [_equipmentTable reloadData];
            break;
        case 4:
            if (!_equipmentTable.superview) {
                [self.view addSubview:_equipmentTable];
            }
            _equipmentTable.allItems = _skillCollection.armArray;
            [_equipmentTable reloadData];
            break;
        case 5:
            if (!_equipmentTable.superview) {
                [self.view addSubview:_equipmentTable];
            }
            _equipmentTable.allItems = _skillCollection.waistArray;
            [_equipmentTable reloadData];
            break;
        case 6:
            if (!_equipmentTable.superview) {
                [self.view addSubview:_equipmentTable];
            }
            _equipmentTable.allItems = _skillCollection.legArray;
            [_equipmentTable reloadData];
            break;
        case 7:
            if (!_equipmentTable.superview) {
                [self.view addSubview:_equipmentTable];
            }
            _equipmentTable.allItems = _skillCollection.decorationArray;
            [_equipmentTable reloadData];
            break;

        default:
            break;
    }
    [self.view addSubview:_skillDetailTab];
    [tabBar setSelectedItem:item];
}

#pragma mark - Table View Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_skillDetailTable]){
        return _skillCollection.skillArray.count;
    } else {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if  ([tableView isEqual:_skillDetailTable]){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"skillDetail"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"skillDetail"];
        }
        NSArray *skillArray = _skillCollection.skillArray[indexPath.row];
        
        UIFont *font = [cell.detailTextLabel.font fontWithSize:10];
        cell.detailTextLabel.numberOfLines = 3;
        cell.detailTextLabel.font = font;
        
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 50, cellFrame.size.height - 10, 30, 20);
        UILabel *accessoryText = [[UILabel alloc] initWithFrame:textView];
        accessoryText.textAlignment =  NSTextAlignmentRight;
        [cell addSubview:accessoryText];
        [cell setAccessoryView: accessoryText];
        
        
        cell.textLabel.text = skillArray[1];
        cell.detailTextLabel.text = skillArray[2];
        accessoryText.text = [NSString stringWithFormat:@"%@", skillArray[0]];
        
        return cell;
    }
    return nil;
}


#pragma mark - Helper Methods
-(void)setDetailTabBarItems{
    NSMutableArray *tabItems = [[NSMutableArray alloc] initWithObjects:_detail, nil];
    if (_skillCollection.headArray.count > 0 ) {
        [tabItems addObject:_head];
    }
    if (_skillCollection.bodyArray.count > 0 ) {
        [tabItems addObject:_body];
    }
    if (_skillCollection.armArray.count > 0 ) {
        [tabItems addObject:_arm];
    }
    if (_skillCollection.waistArray.count > 0 ) {
        [tabItems addObject:_waist];
    }
    if (_skillCollection.legArray.count > 0 ) {
        [tabItems addObject:_leg];
    }
    
    if (_skillCollection.decorationArray.count > 0) {
        [tabItems addObject:_decorations];
    }
    
    [_skillDetailTab setItems:tabItems];
}

-(void)removeViewsFromDetail {
    for (UIView *view in _allViews) {
        if (view.superview) {
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
    _skillDetailTab.frame = tabBarFrame;
    
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y + tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height - (heightdifference + tabBarFrame.size.height));
    
    for (UIView *view in _allViews) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tv = (UITableView *)view;
            [tv setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
            [tv setContentInset:UIEdgeInsetsZero];
        }

        view.frame = tablewithTabbar;
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

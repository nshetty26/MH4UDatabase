//
//  DecorationsDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/12/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "DecorationsDetailViewController.h"
#import "MH4UDBEntity.h"
#import "ItemDetailViewController.h"
#import "MH4UDBEngine.h"

@interface DecorationsDetailViewController ()
@property (nonatomic) UITableView *skillTable;
@property (nonatomic) UITableView *componentTable;
@property (nonatomic) UITabBar *decorationDetailTab;
@property (nonatomic) DetailedItemView *detailItemView;

@end

@implementation DecorationsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self populateDecorationComponent];
    // Do any additional setup after loading the view.
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    
    _decorationDetailTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
    UITabBarItem *statSheet = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:4];
    UITabBarItem *skillSheet = [[UITabBarItem alloc] initWithTitle:@"Skills" image:nil tag:5];
    UITabBarItem *componentSheet = [[UITabBarItem alloc] initWithTitle:@"Components" image:nil tag:6];
    
    _decorationDetailTab.delegate = self;
    [_decorationDetailTab setItems:@[statSheet, skillSheet, componentSheet]];
    [_decorationDetailTab setSelectedItem:statSheet];
    _skillTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _skillTable.dataSource = self;
    _skillTable.delegate = self;
    
    _componentTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _componentTable.delegate = self;
    _componentTable.dataSource = self;
    
    _detailItemView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedItemView" owner:self options:nil] lastObject];
    _detailItemView.frame = tablewithTabbar;
    [_detailItemView populateViewWithItem:(Item *)_selectedDecoration];
    [self.view addSubview:_decorationDetailTab];
    [self.view addSubview:_detailItemView];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_componentTable]) {
        return _selectedDecoration.componentArray.count;
    } else if ([tableView isEqual:_skillTable]) {
        return _selectedDecoration.skillArray.count;
    } else  {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"armorCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"armorCell"];
    }
    
    if ([tableView isEqual:_skillTable]) {
        NSArray *skillArray = _selectedDecoration.skillArray[indexPath.row];
        NSString *detailLabel = [NSString stringWithFormat:@"%@: %@", [skillArray objectAtIndex:1], [skillArray objectAtIndex:2]];
        cell.textLabel.text = detailLabel;
    } else if ([tableView isEqual:_componentTable]) {
        NSArray *componentArray = _selectedDecoration.componentArray[indexPath.row];
        cell.textLabel.text = [componentArray objectAtIndex:1];
    }
    
    return cell;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([tabBar isEqual:_decorationDetailTab]) {
        [self removeViewsFromDetail];
        switch (item.tag) {
            case 4:
                [self.view addSubview:_detailItemView];
                break;
            case 5:
                [self.view addSubview:_skillTable];
                break;
            case 6:
                [self.view addSubview:_componentTable];
                break;
            default:
                break;
        }
        
    }
    [tabBar setSelectedItem:item];
    
}

-(void)removeViewsFromDetail {
    NSArray *allTables = @[_detailItemView, _skillTable, _componentTable];
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

-(void)populateDecorationComponent {
    NSArray *componentArray = [_dbEngine getComponentsfor:_selectedDecoration.itemID];
    _selectedDecoration.componentArray = componentArray;
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

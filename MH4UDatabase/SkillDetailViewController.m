//
//  SkillDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "SkillDetailViewController.h"
#import "MH4UDBEntity.h"

@interface SkillDetailViewController ()
@property (nonatomic) UITableView *skillDetailTable;
@property (nonatomic) UITableView *equipmentTable;
@property (nonatomic) UITabBar *skillDetailTab;
@property (nonatomic) UITabBarItem *detail;
@property (nonatomic) UITabBarItem *head;
@property (nonatomic) UITabBarItem *arm;
@property (nonatomic) UITabBarItem *waist;
@property (nonatomic) UITabBarItem *leg;
@property (nonatomic) UITabBarItem *jewels;
@end

@implementation SkillDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, tabBarFrame.origin.y +tabBarFrame.size.height, vcFrame.size.width, vcFrame.size.height);
    
    _skillDetailTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
    _detail = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:1];
    _head = [[UITabBarItem alloc] initWithTitle:@"Head" image:nil tag:2];
    _arm = [[UITabBarItem alloc] initWithTitle:@"Arm" image:nil tag:3];
    _waist = [[UITabBarItem alloc] initWithTitle:@"Waist" image:nil tag:4];
    _leg = [[UITabBarItem alloc] initWithTitle:@"Arm" image:nil tag:5];
    _jewels = [[UITabBarItem alloc] initWithTitle:@"Arm" image:nil tag:6];
    
    _skillDetailTab.delegate = self;
    
    _skillDetailTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _skillDetailTable.dataSource = self;
    _skillDetailTable.delegate = self;
    
    _equipmentTable = [[UITableView alloc] initWithFrame:tablewithTabbar];
    _equipmentTable.delegate = self;
    _equipmentTable.dataSource = self;
    
    [self.view addSubview:_skillDetailTable];
    [_skillDetailTab setSelectedItem:[_skillDetailTab.items firstObject]];
    [self.view addSubview:_skillDetailTab];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_skillDetailTable]){
        return _skillCollection.skillArray.count;
    } else if  ([tableView isEqual:_equipmentTable]){
        if (_skillDetailTab.selectedItem.tag == 2) {
            return _skillCollection.headArray.count;
        } else if (_skillDetailTab.selectedItem.tag == 3) {
            return _skillCollection.bodyArray.count;
        } else if (_skillDetailTab.selectedItem.tag == 4) {
            return _skillCollection.armArray.count;
        } else if (_skillDetailTab.selectedItem.tag == 5) {
            return _skillCollection.waitArray.count;
        } else if (_skillDetailTab.selectedItem.tag == 6) {
            return _skillCollection.legArray.count;
        } else if (_skillDetailTab.selectedItem.tag == 7) {
            return _skillCollection.jewelArray.count;
        } else {
            return 0;
        }
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

        return cell;
    } else if  ([tableView isEqual:_equipmentTable]){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentCell"];
        if (!cell) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentCell"];
        }
        if (_skillDetailTab.selectedItem.tag == 2) {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            UILabel *acessoryText = [[UILabel alloc] initWithFrame:cell.accessoryView.frame];
            acessoryText.text = @"";
            cell.accessoryView = acessoryText;
            return cell;
        }  else if (_skillDetailTab.selectedItem.tag == 3) {
            return cell;
        } else if (_skillDetailTab.selectedItem.tag == 4) {
            return cell;
        } else if (_skillDetailTab.selectedItem.tag == 5) {
            return cell;
        } else if (_skillDetailTab.selectedItem.tag == 6) {
            return cell;
        } else {
            return nil;
        }

    } else {
        return nil;
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

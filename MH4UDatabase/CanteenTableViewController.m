//
//  CanteenTableViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 8/14/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "CanteenTableViewController.h"
#import "UIViewController+UIViewController_MenuButton.h"
#import "MH4UDBEngine.h"

@interface CanteenTableViewController ()
@property NSArray *allCombinations;
@property NSArray *allSkills;
@property BOOL displayingCombinations;
@property BOOL displayingSkills;
@end

@implementation CanteenTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenuButton];
    _allCombinations = [_dbEngine getAlLCanteenCombinations];
    _allSkills = [_dbEngine getAllFelyneSkills];
    self.title = @"Canteen Combinations";
    _displayingCombinations = YES;
    _displayingSkills = NO;
    
    CGRect tabBarFrame = CGRectMake(self.tableView.tableHeaderView.frame.origin.x, self.tableView.tableHeaderView.frame.origin.y, self.tableView.tableHeaderView.frame.size.width, 49);
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:tabBarFrame];

    UITabBarItem *combos = [[UITabBarItem alloc] initWithTitle:@"Combos" image:nil tag:1];
    UITabBarItem *skills = [[UITabBarItem alloc] initWithTitle:@"Skills" image:nil tag:2];
    
    [tabBar setItems:@[combos, skills]];
    [tabBar setSelectedItem:combos];
    
    tabBar.delegate = self;
    self.tableView.tableHeaderView = tabBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_displayingCombinations) {
        return _allCombinations.count;
    } else if (_displayingSkills) {
        return _allSkills.count;
    } else {
        return 0;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_displayingCombinations) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"canteenCell"];
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"CanteenCell"  bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"canteenCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"canteenCell"];
        }
        
        return cell;
    } else if (_displayingSkills) {
        NSDictionary *skillDictionary = _allSkills[indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        }
        
        cell.textLabel.text = [skillDictionary objectForKey:@"name"];
        cell.detailTextLabel.text = [skillDictionary objectForKey:@"description"];
        [cell.detailTextLabel setNumberOfLines:0];
        UIFont *font = [cell.detailTextLabel.font fontWithSize:10];
        [cell.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
        cell.detailTextLabel.font = font;

        return cell;
    } else {
        return NULL;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(CanteenCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_displayingCombinations) {
        NSDictionary *canteenCombo = _allCombinations[indexPath.row];
        cell.ingredient1.text = [NSString stringWithFormat:@"%@ + %@", [canteenCombo objectForKey:@"ingredient1"], [canteenCombo objectForKey:@"ingredient2"]];
        cell.method.text = [canteenCombo objectForKey:@"cookingMethod"];
        cell.bonus.text = [canteenCombo objectForKey:@"bonus"];
        cell.skill1.text = [canteenCombo objectForKey:@"skill1"];
        cell.skill2.text = [canteenCombo objectForKey:@"skill2"];
        cell.skill3.text = [canteenCombo objectForKey:@"skill3"];
    }

    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_displayingCombinations) {
        return 60.0;
    } else {
        return 80.0;
    }
    
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 1:
            _displayingCombinations = YES;
            _displayingSkills = NO;
            [self.tableView reloadData];
            break;
        case 2:
            _displayingCombinations = NO;
            _displayingSkills = YES;
            [self.tableView reloadData];
            break;
        default:
            break;
    }

}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


@interface CanteenCell()

@end

@implementation CanteenCell

@end


//
//  MH4UTableViews.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/26/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ItemTableView.h"
#import "ItemDetailViewController.h"
#import "MH4UDBEntity.h"
#import "MH4UDBEngine.h"

@interface ItemTableView()
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) MH4UDBEngine *dbEngine;
@end

@implementation ItemTableView

-(id)initWithFrame:(CGRect)frame andNavigationController:(UINavigationController *)navigationController andDBEngine:(MH4UDBEngine *)dbEngine {
    if (self = [super init]) {
        self.frame = frame;
        
        if (navigationController && dbEngine) {
            _navigationController = navigationController;
            _dbEngine = dbEngine;
            self.delegate = self;
            self.dataSource = self;
            return self;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"itemCell"];
    }
    
    Item *item = _allItems[indexPath.row];
    cell.textLabel.text = item.name;
    cell.imageView.image = [UIImage imageNamed:item.icon];
    if (item.condition) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", item.condition];
    } else if (item.site) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", item.site, item.area];
    }
    
    
    CGRect cellFrame = cell.frame;
    CGRect textView = CGRectMake(cellFrame.size.width - 60, cellFrame.origin.y + 5, 50, 24);
    UILabel *accessoryText = [[UILabel alloc] initWithFrame:textView];
    
    [accessoryText setNumberOfLines:2];
    [accessoryText setLineBreakMode:NSLineBreakByWordWrapping];
    accessoryText.textAlignment =  NSTextAlignmentRight;
    
    UIFont *font;
    [cell addSubview:accessoryText];
    if ([_accessoryType isEqualToString:@"Percentage"]) {
        accessoryText.text = [NSString stringWithFormat:@"%i%@", item.percentage, @"%"];
        font = [accessoryText.font fontWithSize:10];
    } else if ([_accessoryType isEqualToString:@"Quantity"]) {
        accessoryText.text = [NSString stringWithFormat:@"%i", item.capacity];
        font = [accessoryText.font fontWithSize:15];
    }
    accessoryText.font = font;
    cell.accessoryView = accessoryText;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = _allItems[indexPath.row];
    ItemDetailViewController *itemDetailVC = [[ItemDetailViewController alloc] init];
    itemDetailVC.selectedItem = item;
    itemDetailVC.dbEngine = _dbEngine;
    itemDetailVC.heightDifference = [self returnHeightDifference];
    [_navigationController pushViewController:itemDetailVC animated:YES];
}

-(CGFloat)returnHeightDifference {
    UINavigationBar *navBar = _navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    return navBar.frame.size.height + statusBar.size.height;
}

@end

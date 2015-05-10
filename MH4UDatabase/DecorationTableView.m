//
//  DecorationTableView.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 5/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "DecorationTableView.h"
#import "DecorationsDetailViewController.h"
#import "MH4UDBEntity.h"
#import "MH4UDBEngine.h"

@interface DecorationTableView()
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) MH4UDBEngine *dbEngine;
@end

@implementation DecorationTableView

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

#pragma mark - Table View Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _displayedDecorations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DecorationTableCell *itemCell = [tableView dequeueReusableCellWithIdentifier:@"decorationCell"];
    
    if (!itemCell) {
        [tableView registerNib:[UINib nibWithNibName:@"DecorationTableCell"  bundle:nil] forCellReuseIdentifier:@"decorationCell"];
        itemCell = [tableView dequeueReusableCellWithIdentifier:@"decorationCell"];
    }
    return itemCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(DecorationTableCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Decoration *decoration = _displayedDecorations[indexPath.row];
    cell.itemImageView.image = [UIImage imageNamed:decoration.icon];
    cell.itemLabel.text = decoration.name;
    
    if (decoration.skillArray.count == 1) {
        cell.itemAccessoryLabel1.hidden = YES;
        cell.itemAccessoryLabel3.hidden = YES;
        cell.itemAccessoryLabel2.hidden = NO;
        NSDictionary *skill1 = decoration.skillArray[0];
        cell.itemAccessoryLabel2.text = [NSString stringWithFormat:@"%@ %@", [skill1 valueForKey:@"skillTreeName"], [skill1 valueForKey:@"skillTreePointValue"]];
    } else if (decoration.skillArray.count == 2) {
        cell.itemAccessoryLabel1.hidden = NO;
        cell.itemAccessoryLabel3.hidden = NO;
        cell.itemAccessoryLabel2.hidden = YES;
        NSDictionary *skill1 = decoration.skillArray[0];
        NSDictionary *skill2 = decoration.skillArray[1];
        cell.itemAccessoryLabel1.text = [NSString stringWithFormat:@"%@ %@", [skill1 valueForKey:@"skillTreeName"], [skill1 valueForKey:@"skillTreePointValue"]];
        cell.itemAccessoryLabel3.text = [NSString stringWithFormat:@"%@ %@", [skill2 valueForKey:@"skillTreeName"], [skill2 valueForKey:@"skillTreePointValue"]];
    }
    
    if (decoration.componentArray < 0) {
        cell.itemSubLabel.text = @"Relic Decoration";
    }
    
    cell.itemSubLabel.hidden = YES;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Decoration *decoration= _displayedDecorations[indexPath.row];
    decoration.componentArray = [_dbEngine getComponentsfor:decoration.itemID];
    DecorationsDetailViewController *dDVC = [[DecorationsDetailViewController alloc] init];
    dDVC.dbEngine = _dbEngine;
    dDVC.selectedDecoration = decoration;
    [self.navigationController pushViewController:dDVC animated:YES];
    
}

@end


@implementation DecorationTableCell

@end
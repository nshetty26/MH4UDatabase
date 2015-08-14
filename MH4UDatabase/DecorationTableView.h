//
//  DecorationTableView.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 5/10/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MH4UDBEngine;

@interface DecorationTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *displayedDecorations;

-(id)initWithFrame:(CGRect)frame andNavigationController:(UINavigationController *)navigationController andDBEngine:(MH4UDBEngine *)dbEngine;



@end


@interface DecorationTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemAccessoryLabel1;
@property (weak, nonatomic) IBOutlet UILabel *itemAccessoryLabel2;
@property (weak, nonatomic) IBOutlet UILabel *itemAccessoryLabel3;
@property (weak, nonatomic) IBOutlet UILabel *itemSubLabel;

@end
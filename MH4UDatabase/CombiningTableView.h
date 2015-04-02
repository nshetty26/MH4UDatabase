//
//  CombiningTableView.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 4/1/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MH4UDBEngine;

@interface CombiningTableView : UITableView <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *allCombined;

-(id)initWithFrame:(CGRect)frame andNavigationController:(UINavigationController *)navigationController andDBEngine:(MH4UDBEngine *)dbEngine;
@end

@interface CombiningCell : UITableViewCell
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) int heightDifference;
@property (nonatomic) UINavigationController *nC;
@property (weak, nonatomic) IBOutlet UIImageView *combinedImageView;
@property (weak, nonatomic) IBOutlet UILabel *combinedItemName;
@property (weak, nonatomic) IBOutlet UILabel *maxCombined;
@property (weak, nonatomic) IBOutlet UILabel *percentageCombined;
@property (weak, nonatomic) IBOutlet UILabel *item1Name;
@property (weak, nonatomic) IBOutlet UIImageView *item1ImageView;
@property (weak, nonatomic) IBOutlet UILabel *item2Name;
@property (weak, nonatomic) IBOutlet UIButton *item1Button;
@property (weak, nonatomic) IBOutlet UIButton *item2Button;
@property (weak, nonatomic) IBOutlet UIButton *combineItemButton;
@property (weak, nonatomic) IBOutlet UIImageView *item2ImageView;
- (IBAction)launchDetailItem:(id)sender;

@end

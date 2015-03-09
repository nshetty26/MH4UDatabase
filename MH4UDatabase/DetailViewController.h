//
//  DetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/3/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MH4UDBEngine;

@interface DetailViewController : UIViewController 

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) NSArray *allArmorArray;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) CGRect tabBarFrame;
@property (nonatomic) CGRect tableFrame;
@property (nonatomic) int heightDifference;


@end




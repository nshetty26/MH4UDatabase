//
//  LocationDetailViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Location;
@class MH4UDBEngine;

@interface LocationDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>
@property (nonatomic) Location *selectedLocation;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) int heightDifference;

@end

@interface LargeMapView : UIView
@property (weak, nonatomic) IBOutlet UILabel *mapTitle;
@property (weak, nonatomic) IBOutlet UIImageView *mapImage;

@end

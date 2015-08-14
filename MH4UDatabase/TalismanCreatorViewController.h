//
//  TalismanCreatorViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 8/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MH4UDBEngine;
@class ArmorSet;
@class ArmorSetDetailViewController;

@interface TalismanCreatorViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>


@property (nonatomic) ArmorSetDetailViewController *asDVC;
@property (nonatomic) MH4UDBEngine *dbEngine;
@property (nonatomic) ArmorSet *selectedSet;

@end

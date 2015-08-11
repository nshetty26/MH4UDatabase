//
//  TalismanCreatorViewController.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 8/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MH4UDBEngine;

@interface TalismanCreatorViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
- (IBAction)slotValueChanged:(id)sender;

@property (nonatomic) MH4UDBEngine *dbEngine;

@end

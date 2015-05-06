//
//  ArmorSetAlertDelegates.h
//  MH4UDatabase
//
//  Created by Neil Shetty on 5/5/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MH4UDBEngine;
@class Item;

@interface ArmorSetDelegates : NSObject <UIAlertViewDelegate, UIActionSheetDelegate>

-(id)initWithSelectedItem:(Item *)selectedItem andDBEngine:(MH4UDBEngine *)dbEngine andViewController:(UIViewController *)viewController;

@end

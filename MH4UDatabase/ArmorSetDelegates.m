//
//  ArmorSetAlertDelegates.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 5/5/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "ArmorSetDelegates.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface ArmorSetDelegates ()

@property (nonatomic, strong) NSDictionary *selectedSet;
@property (nonatomic, strong) UIAlertView *doubleCheckAlert;
@property (nonatomic, strong) MH4UDBEngine *dbEngine;
@property (nonatomic, strong) Item *selectedItem;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSString *itemType;

@end


@implementation ArmorSetDelegates

-(id)initWithSelectedItem:(Item *)selectedItem andDBEngine:(MH4UDBEngine *)dbEngine andViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        _selectedItem = selectedItem;
        _dbEngine = dbEngine;
        _viewController = viewController;
        return self;
    } else {
        return nil;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([alertView isEqual:_doubleCheckAlert]) {
            if (buttonIndex == 1) {
                BOOL successfulDelete = [_dbEngine deleteAllDecorationsForArmorSetWithID:[_selectedSet objectForKey:@"setID"] andSetItem:_selectedItem];
                BOOL successful = [_dbEngine addSetItem:_selectedItem toArmorSetWithID:[_selectedSet objectForKey:@"setID"]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Your update was %@",successful ? @"Successful" : @"Failed"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            }
        }
        
        else {
            NSArray *allSets = [_dbEngine getAllArmorSets];
            if (allSets.count <= 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"No Custom Sets" message:@"Please add a custom set before trying to add items to it" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    return;
                });
            }
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Which Armor Set Would You Like to Add to?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
            
            for (NSDictionary *set in allSets) {
                [actionSheet addButtonWithTitle:[set objectForKey:@"setName"]];
            }
            
            actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [actionSheet showInView:_viewController.view];
            });
        }
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger cancelIndex = [actionSheet cancelButtonIndex];
    if (buttonIndex != cancelIndex) {
        NSArray *allSets = [_dbEngine getAllArmorSets];
        _selectedSet = allSets[buttonIndex];
        
        BOOL exists = [_dbEngine checkSetItem:_selectedItem atArmorSetWithID: [_selectedSet objectForKey:@"setID"]];
        
        if (!exists) {
            BOOL successful = [_dbEngine addSetItem:_selectedItem  toArmorSetWithID:[_selectedSet objectForKey:@"setID"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Your update was %@",successful ? @"Successful" : @"Failed"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        } else {
            _doubleCheckAlert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:[NSString stringWithFormat:@"This Set Already Has a Piece in the %@ Slot", _selectedItem.slot] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_doubleCheckAlert show];
            });
        }
        
    }
}



@end

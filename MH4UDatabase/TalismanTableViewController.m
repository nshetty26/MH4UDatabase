//
//  TalismanTableViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 8/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "TalismanTableViewController.h"
#import "TalismanCreatorViewController.h"
#import "ArmorSetDetailViewController.h"
#import "MH4UDBEntity.h"
#import "MH4UDBEngine.h"

@interface TalismanTableViewController ()

@end

@implementation TalismanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!_talismanArray){
        _talismanArray = [_dbEngine getAllTalismans];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:@"kTalismanCreated" object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(launchTalismanCreator)];
    self.navigationItem.rightBarButtonItems = @[addButton, self.editButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _talismanArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    Talisman *talisman = _talismanArray[indexPath.row];
    cell.textLabel.text = talisman.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@" %i slots", talisman.numSlots];
    cell.imageView.image = [UIImage imageNamed:[talisman getIconString]];
    
    if (talisman.skill2ID == 0) {
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 90, cellFrame.size.height - 20, 90, 20);
        UILabel *skill1Text = [[UILabel alloc] initWithFrame:textView];
        skill1Text.textAlignment =  NSTextAlignmentRight;
        [cell addSubview:skill1Text];
        [cell setAccessoryView: skill1Text];
        UIFont *font = [skill1Text.font fontWithSize:11];
        skill1Text.font = font;
        skill1Text.text = [NSString stringWithFormat:@"%@: %i", talisman.skill1Name, talisman.skill1Value];
    } else {
        CGRect cellFrame = cell.frame;
        CGRect textView = CGRectMake(cellFrame.size.width - 80, cellFrame.size.height - 25, 90, 40);
        UILabel *skill2Text = [[UILabel alloc] initWithFrame:textView];
        [skill2Text setNumberOfLines:0];
        [skill2Text setLineBreakMode:NSLineBreakByWordWrapping];
        skill2Text.textAlignment =  NSTextAlignmentRight;
        [cell addSubview:skill2Text];
        [cell setAccessoryView: skill2Text];
        UIFont *font = [skill2Text.font fontWithSize:11];
        skill2Text.font = font;
        skill2Text.text = [NSString stringWithFormat:@"%@: %i\n\n%@: %i", talisman.skill1Name, talisman.skill1Value, talisman.skill2Name, talisman.skill2Value];
    }

    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Talisman *talisman = _talismanArray[indexPath.row];
    bool successful = [_dbEngine addTalisman:talisman toArmorSet:_selectedSet];
    _selectedSet.talisman = talisman;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kSomethingHasChanged" object:nil];
    [self.navigationController popToViewController:_asDVC animated:YES];
    
}

-(void)launchTalismanCreator {
    TalismanCreatorViewController *tCVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"talismanCreatorVC"];
    tCVC.asDVC = _asDVC;
    tCVC.dbEngine = _dbEngine;
    tCVC.selectedSet = _selectedSet;
    [self.navigationController pushViewController:tCVC animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Talisman *talismanToDelete = _talismanArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_dbEngine deleteTalisman:talismanToDelete];
        _talismanArray = [_dbEngine getAllTalismans];
        
        if (_selectedSet.talisman.itemID == talismanToDelete.itemID) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kItemDeletedFromArmorSet" object:talismanToDelete];
            _selectedSet.talisman = NULL;
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)refreshTableView {
    _talismanArray = [_dbEngine getAllTalismans];
    [self.tableView reloadData];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

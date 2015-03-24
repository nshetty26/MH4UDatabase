//
//  LocationsViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 ]. All rights reserved.
//

#import "LocationsViewController.h"
#import "LocationDetailViewController.h"
#import "MH4UDBEntity.h"
#import "MH4UDBEngine.h"

@interface LocationsViewController ()
@property (strong, nonatomic) UITableView *locationsTable;
@end

@implementation LocationsViewController

#pragma mark - Setup Views
- (void)viewDidLoad {
    [super viewDidLoad];
    _allLocations = [_dbEngine getAllLocations];
    self.title = NSLocalizedString(@"Locations", @"Locations");
    // Do any additional setup after loading the view.
    _locationsTable = [[UITableView alloc] initWithFrame:self.view.frame];
    _locationsTable.dataSource = self;
    _locationsTable.delegate = self;
    [self.view addSubview:_locationsTable];
    

}

#pragma mark - Table View Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allLocations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Location *location = _allLocations[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"locationCell"];
    }
    
    cell.textLabel.text = location.locationName;
    cell.imageView.image = [UIImage imageNamed:location.locationIcon];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Location *location = _allLocations[indexPath.row];
    LocationDetailViewController *lDVC = [[LocationDetailViewController alloc] init];
    lDVC.heightDifference = _heightDifference;
    lDVC.selectedLocation = location;
    lDVC.dbEngine = _dbEngine;
    [self.navigationController pushViewController:lDVC animated:YES];
}

#pragma mark - Helper Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews {
    _locationsTable.frame = self.view.frame;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

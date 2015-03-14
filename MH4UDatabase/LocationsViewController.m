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

@interface LocationsViewController ()

@end

@implementation LocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Locations" style:UIBarButtonItemStyleDone target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    // Do any additional setup after loading the view.
    UITableView *locationsTable = [[UITableView alloc] initWithFrame:self.view.frame];
    locationsTable.dataSource = self;
    locationsTable.delegate = self;
    [self.view addSubview:locationsTable];
    

}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

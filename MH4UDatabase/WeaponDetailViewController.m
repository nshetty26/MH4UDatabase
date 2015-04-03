//
//  WeaponDetailViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 3/13/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "WeaponDetailViewController.h"
#import "ItemDetailViewController.h"
#import "ItemTableView.h"
#import "MH4UDBEntity.h"
#import "MH4UDBEngine.h"
#import "WeaponUpgradeTable.h"

@interface WeaponDetailViewController ()
@property (nonatomic) DetailedWeaponView *detailedView;
@property (nonatomic) UITabBar *weaponDetailTab;
@property (nonatomic) ItemTableView *componentTable;
@property (nonatomic) UITableView *weaponFamilyTable;
@property (nonatomic) UITableView *hornSongTable;
@property (nonatomic) NSArray *weaponComponents;
@property (nonatomic) NSArray *hornMelodies;
@property (nonatomic) NSArray *allViews;

@end

@implementation WeaponDetailViewController

#pragma mark - Setup Views
-(void)setUpTabBarWithFrame:(CGRect)tabBarFrame {
    if (!_weaponDetailTab) {
        NSMutableArray *tabItems = [[NSMutableArray alloc] init];
        
        UITabBarItem *statSheet = [[UITabBarItem alloc] initWithTitle:@"Detail" image:nil tag:1];
        UITabBarItem *fTree = [[UITabBarItem alloc] initWithTitle:@"Family Tree" image:nil tag:2];
        UITabBarItem *componentSheet = [[UITabBarItem alloc] initWithTitle:@"Components" image:nil tag:3];
        [tabItems addObject:statSheet];
        [tabItems addObject:fTree];
        [tabItems addObject:componentSheet];
        
        if ([_selectedWeapon.weaponType isEqualToString:@"Hunting Horn"]) {
            UITabBarItem *melodies = [[UITabBarItem alloc] initWithTitle:@"Melodies" image:nil tag:4];
            [tabItems addObject:melodies];
        }
        
        _weaponDetailTab = [[UITabBar alloc] initWithFrame:tabBarFrame];
        _weaponDetailTab.delegate = self;
        [_weaponDetailTab setSelectedItem:statSheet];
        [_weaponDetailTab setItems:tabItems];
    }
}

-(void)setUpViewsWithFrame:(CGRect)tableFrame {
    NSMutableArray *allViews = [[NSMutableArray alloc] init];
    
    _detailedView = [[[NSBundle mainBundle] loadNibNamed:@"DetailedWeaponView" owner:self options:nil] firstObject];
    [_detailedView populateWeapon:_selectedWeapon];
    _detailedView.frame = tableFrame;
    [allViews addObject:_detailedView];
    
    _componentTable = [[ItemTableView alloc] initWithFrame:tableFrame andNavigationController:self.navigationController andDBEngine:_dbEngine];
    _componentTable.allItems = _weaponComponents;
    _componentTable.accessoryType = @"Quantity";
    [allViews addObject:_componentTable];
    
    _weaponFamilyTable = [[WeaponUpgradeTable alloc] initWithFrame:tableFrame andNavigationController:self.navigationController andDBEngine:_dbEngine andWeapon:_selectedWeapon];
    [allViews addObject:_weaponFamilyTable];
    

    if ([_selectedWeapon.weaponType isEqualToString:@"Hunting Horn"]) {
        _hornSongTable = [[UITableView alloc] initWithFrame:tableFrame];
        _hornMelodies = [_dbEngine getHornSongsForHorn:_selectedWeapon];
        _hornSongTable.delegate = self;
        _hornSongTable.dataSource = self;
        [allViews addObject:_hornSongTable];
    }

    _allViews = allViews;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(_selectedWeapon.name, _selectedWeapon.name);
    _weaponComponents = [_dbEngine getComponentsfor:_selectedWeapon.itemID];
    
    CGRect vcFrame = self.view.frame;
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + _heightDifference, vcFrame.size.width, 49);
    CGRect tablewithTabbar = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + tabBarFrame.size.height + _heightDifference, vcFrame.size.width, vcFrame.size.height - _heightDifference - tabBarFrame.size.height);
    
    [self setUpTabBarWithFrame:tabBarFrame];
    [self setUpViewsWithFrame:tablewithTabbar];

    [self.view addSubview:_weaponDetailTab];
    [self.view addSubview:_detailedView];
}

#pragma mark - Tab Bar Methods
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([tabBar isEqual:_weaponDetailTab]) {
        [self removeViewsFromDetail];
        switch (item.tag) {
            case 1:
                [self.view addSubview:_detailedView];
                break;
            case 2:
                [self.view addSubview:_weaponFamilyTable];
                break;
            case 3:
                [self.view addSubview:_componentTable];
                break;
            case 4:
                [self.view addSubview:_hornSongTable];
                break;
            default:
                break;
        }
        
    }
    [tabBar setSelectedItem:item];
    
}

#pragma mark Tableview Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_hornSongTable]){
        return _hornMelodies.count;
    }else  {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:_hornSongTable]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hornCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"hornCell"];
        }
        NSArray *hornMelody = _hornMelodies[indexPath.row];
        cell.textLabel.text =[NSString stringWithFormat:@"%@: Dur:%@\\Ext:%@",hornMelody[0], hornMelody[3], hornMelody[4]];

        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\\%@",hornMelody[1], hornMelody[2]];
        return cell;
    }
    
    return nil;
}


#pragma mark - Helper Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)removeViewsFromDetail {

    for (UIView *view in _allViews) {
        if (view.superview != nil) {
            [view removeFromSuperview];
        }
    }
}

-(void)viewWillLayoutSubviews {
    CGRect vcFrame = self.view.frame;
    UINavigationBar *navBar = self.navigationController.navigationBar;
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    int heightdifference = navBar.frame.size.height + statusBar.size.height;
    
    CGRect tabBarFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + heightdifference, vcFrame.size.width, 49);
    _weaponDetailTab.frame = tabBarFrame;
    
    
    CGRect tableFrame = CGRectMake(vcFrame.origin.x, vcFrame.origin.y + tabBarFrame.size.height + heightdifference, vcFrame.size.width, vcFrame.size.height - heightdifference - tabBarFrame.size.height);
    
    for (UIView *view in _allViews) {
        view.frame = tableFrame;
    }
}

@end

@implementation DetailedWeaponView

-(void)populateWeapon:(Weapon *)weapon {
    _icon.image = [UIImage imageNamed:weapon.icon];
    _nameLabel.text = weapon.name;
    _attackLabel.text = [NSString stringWithFormat:@"%i", weapon.attack];
    NSString *elementString;
    if (weapon.awakenDamage > 0) {
        elementString = [NSString stringWithFormat:@"%@: %i", weapon.awaken_type, weapon.awakenDamage];
    } else if (weapon.elementalDamage_2 > 0) {
        elementString = [NSString stringWithFormat:@"%@\\%@: %i\\%i", weapon.elementalDamageType_1, weapon.elementalDamageType_2, weapon.elementalDamage_1,  weapon.elementalDamage_2];
    } else if (weapon.elementalDamage_1 > 0) {
        elementString = [NSString stringWithFormat:@"%@: %i", weapon.elementalDamageType_1, weapon.elementalDamage_1];
    } else {
        elementString = @"None";
    }
    _elementLabel.text = elementString;
    if ([weapon.weaponType isEqualToString:@"Switch Axe"] || [weapon.weaponType isEqualToString:@"Charge Blade"]) {
        _auxiliaryLabel1.hidden = NO;
        _auxiliaryValue1.hidden = NO;
        _auxiliaryLabel1.text = @"Phial";
        _auxiliaryValue1.text = weapon.phial;
    }
    
    if ([weapon.weaponType isEqualToString:@"Hunting Horn"]) {
        _auxiliaryLabel1.hidden = NO;
        _auxiliaryLabel1.text = @"Horn Notes:";
        _hornNote1.hidden = NO;
        _hornNote2.hidden = NO;
        _hornNote3.hidden = NO;
        _hornNote1.contentMode = UIViewContentModeScaleAspectFill;
        _hornNote2.contentMode = UIViewContentModeScaleAspectFill;
        _hornNote3.contentMode = UIViewContentModeScaleAspectFill;
        for (int i = 0; i < weapon.hornNotes.length; i++) {
            NSString *imageString;
            char note = [weapon.hornNotes characterAtIndex:i];
            if (note == 'W') {
                imageString = @"Note.white.png";
            }  else if (note == 'C') {
                imageString = @"Note.aqua.png";
            } else if (note == 'B') {
                imageString = @"Note.blue.png";
            } else if (note == 'O') {
                imageString = @"Note.orange.png";
            } else if (note == 'P') {
                imageString = @"Note.purple.png";
            } else if (note == 'R') {
                imageString = @"Note.red.png";
            } else if (note == 'Y') {
                imageString = @"Note.yellow.png";
            } else if (note == 'G') {
                imageString = @"Note.green.png";
            }
            
            switch (i) {
                case 0:
                    _hornNote1.image = [UIImage imageNamed:imageString];
                    break;
                case 1:
                    _hornNote2.image = [UIImage imageNamed:imageString];
                    break;
                case 2:
                    _hornNote3.image = [UIImage imageNamed:imageString];
                    break;
                default:
                    break;
            }
        }

    } else if ([weapon.type containsString:@"Bowgun"]) {
        _auxiliaryLabel1.hidden = NO;
        _auxiliaryValue1.hidden = NO;
        _auxiliaryLabel1.text = @"Reload:";
        _auxiliaryValue1.text = weapon.reloadSpeed;
        _auxiliaryLabel2.hidden = NO;
        _auxiliaryValue2.hidden = NO;
        _auxiliaryLabel2.text = @"Recoil";
        _auxiliaryValue2.text = weapon.recoil;
        _auxiliaryLabel3.hidden = NO;
        _auxiliaryValue3.hidden = NO;
        _auxiliaryLabel3.text = @"Steadiness";
        _auxiliaryValue3.text = weapon.deviation;
    } else if ([weapon.type isEqualToString:@"Bow"]) {
        NSArray *chargeArray = [weapon.charges componentsSeparatedByString:@"|"];
        _auxiliaryLabel1.hidden = NO;
        _auxiliaryValue1.hidden = NO;
        _auxiliaryLabel1.text = @"Arc:";
        _auxiliaryValue1.text = weapon.recoil;
        _auxiliaryLabel2.hidden = NO;
        _auxiliaryValue2.hidden = NO;
        _auxiliaryLabel2.text = @"Charge 1:";
        _auxiliaryValue2.text = chargeArray[0];
        _auxiliaryLabel3.hidden = NO;
        _auxiliaryValue3.hidden = NO;
        _auxiliaryLabel3.text = @"Charge 2:";
        _auxiliaryValue3.text = chargeArray[1];
        _auxiliaryLabel4.hidden = NO;
        _auxiliaryValue4.hidden = NO;
        _auxiliaryLabel4.text = @"Charge 3:";
        _auxiliaryValue4.text = chargeArray[2];
        _auxiliaryLabel5.hidden = NO;
        _auxiliaryValue5.hidden = NO;
        _auxiliaryLabel5.text = @"Charge 4";
        _auxiliaryValue5.text = chargeArray[3];
    }
    
    if (![weapon.type containsString:@"Bow"]) {
        [self drawSharpnessRectWithWeapon:weapon];
    } else {
        _sharpnessBackground.hidden = YES;
        _sharpnessView1.hidden = YES;
        _sharpnessView2.hidden = YES;
    }

    _rarityLabel.text = [NSString stringWithFormat:@"%i", weapon.rarity];
    _numSlotsLabel.text = [NSString stringWithFormat:@"%i", weapon.num_slots];
    _defenseLabel.text = [NSString stringWithFormat:@"%i", weapon.defense];
    _creationCostLabel.text = [NSString stringWithFormat:@"%i", weapon.creationCost];
    _upgradeCostLabel.text = [NSString stringWithFormat:@"%i", weapon.upgradeCost];
}

-(void)drawSharpnessRectWithWeapon:(Weapon *)weapon {
    NSArray *sharpnessStringArray = [weapon.sharpness componentsSeparatedByString:@" "];
    int sharpnessCount = 0;
    for (NSString *sharpnessString in sharpnessStringArray) {
        sharpnessCount++;
        int frameWidth = 0;
        UIView *sharpnessView = (sharpnessCount == 1) ? _sharpnessView1 : _sharpnessView2;
        
        [sharpnessView setBackgroundColor:[UIColor clearColor]];
        NSArray *sharpness = [sharpnessString componentsSeparatedByString:@"."];
        
        int mRed1 = (int)[sharpness[0] integerValue];
        int mOrange1 = (int)[sharpness[1] integerValue];
        int mYellow1 = (int)[sharpness[2] integerValue];
        int mGreen1 = (int)[sharpness[3] integerValue];
        int mBlue1 = (int)[sharpness[4] integerValue];
        int mWhite1 = (int)[sharpness[5] integerValue];
        int mPurple1 = (int)[sharpness[6] integerValue];
        
        int widthMultiplier = sharpnessView.bounds.size.width / (mRed1 + mOrange1 + mYellow1 + mGreen1 + mBlue1 + mWhite1 + mPurple1);
        
        CGRect sharpnessRect = sharpnessView.bounds;
        
        CGRect red = CGRectMake(sharpnessRect.origin.x, sharpnessRect.origin.y, mRed1 * widthMultiplier, sharpnessRect.size.height);
        UIView *redView = [[UIView alloc] initWithFrame:red];
        frameWidth += red.size.width;
        [redView setBackgroundColor:[UIColor redColor]];
        [sharpnessView addSubview:redView];
        
        CGRect orange = CGRectMake(red.size.width, red.origin.y, mOrange1 * widthMultiplier, sharpnessRect.size.height);
        UIView *orangeView = [[UIView alloc] initWithFrame:orange];
        frameWidth += orange.size.width;
        [orangeView setBackgroundColor:[UIColor orangeColor]];
        [sharpnessView addSubview:orangeView];
        
        CGRect yellow = CGRectMake(red.size.width + orange.size.width, orange.origin.y, mYellow1 * widthMultiplier, sharpnessRect.size.height);
        UIView *yellowView = [[UIView alloc] initWithFrame:yellow];
        frameWidth += yellow.size.width;
        [yellowView setBackgroundColor:[UIColor yellowColor]];
        [sharpnessView addSubview:yellowView];
        
        CGRect green = CGRectMake(red.size.width+yellow.size.width+orange.size.width, yellow.origin.y, mGreen1 * widthMultiplier, sharpnessRect.size.height);
        UIView *greenView = [[UIView alloc] initWithFrame:green];
        frameWidth += green.size.width;
        [greenView setBackgroundColor:[UIColor greenColor]];
        [sharpnessView addSubview:greenView];
        
        CGRect blue = CGRectMake(red.size.width+yellow.size.width+orange.size.width+green.size.width, green.origin.y, mBlue1 * widthMultiplier, sharpnessRect.size.height);
        frameWidth += blue.size.width;
        UIView *blueView = [[UIView alloc] initWithFrame:blue];
        [blueView setBackgroundColor:[UIColor blueColor]];
        [sharpnessView addSubview:blueView];
        
        CGRect white = CGRectMake(red.size.width+yellow.size.width+orange.size.width+green.size.width+blue.size.width, blue.origin.y, mWhite1 * widthMultiplier, sharpnessRect.size.height);
        frameWidth += white.size.width;
        UIView *whiteView = [[UIView alloc] initWithFrame:white];
        [whiteView setBackgroundColor:[UIColor whiteColor]];
        [sharpnessView addSubview:whiteView];
        
        CGRect purple = CGRectMake(red.size.width+yellow.size.width+orange.size.width+green.size.width+blue.size.width+white.size.width, white.origin.y, mPurple1 * widthMultiplier, sharpnessRect.size.height);
        UIView *purpleView = [[UIView alloc] initWithFrame:purple];
        frameWidth += purple.size.width;
        [purpleView setBackgroundColor:[UIColor purpleColor]];
        [sharpnessView addSubview:purpleView];
        
        [sharpnessView setFrame:CGRectMake(sharpnessView.frame.origin.x, sharpnessView.frame.origin.x, frameWidth, sharpnessView.frame.size.height)];
        
    }
}

@end

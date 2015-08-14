//
//  TalismanCreatorViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 8/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "TalismanCreatorViewController.h"
#import "ArmorSetDetailViewController.h"
#import "TalismanTableViewController.h"
#import "SkillTreeViewController.h"
#import "MH4UDBEngine.h"
#import "MH4UDBEntity.h"

@interface TalismanCreatorViewController ()
@property (weak, nonatomic) IBOutlet UILabel *skill2label;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIPickerView *typePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *slotsSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *skill1TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *skill2TitleLabel;
@property (nonatomic) NSArray *talismanTypes;
@property (nonatomic) NSArray *allSkillTrees;
@property (nonatomic) NSString *selectedType;
@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger slots;
- (IBAction)addSkillButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *skill1Value;
@property (weak, nonatomic) IBOutlet UITextField *skill2Value;
@property (nonatomic) UITextField *editingTextField;
@property (weak, nonatomic) IBOutlet UIButton *label1Button;
@property (weak, nonatomic) IBOutlet UIButton *label2Button;
@property (nonatomic) NSInteger skill1ID;
@property (nonatomic) NSInteger skill2ID;
@property (nonatomic) NSInteger *skillID;
@property (nonatomic) BOOL skill1ValueBool;
@property (nonatomic) BOOL skill2ValueBool;
@property (nonatomic) BOOL typeReady;

@property (nonatomic) BOOL skill1Ready;
@property (nonatomic) BOOL skill2Ready;

- (IBAction)editingDidBegin:(id)sender;
- (IBAction)editingDidEnd:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *createTalisman;
- (IBAction)valueChanged:(id)sender;
- (IBAction)createButtonTouched:(id)sender;

@property (nonatomic) UILabel *labelToEdit;
@end

@implementation TalismanCreatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _slots = -1;
    _skill1ID = -1;
    _skill2ID = -1;
    
    _talismanTypes = @[@"Pawn", @"Bishop", @"Knight", @"Rook", @"Queen", @"King", @"Dragon", @"Unknowable", @"Mystic", @"Hero", @"Legend", @"Creator", @"Sage", @"Miracle"];
    
    // Do any additional setup after loading the view.
    _typePicker.frame = CGRectMake(_typePicker.frame.origin.x, _typePicker.frame.origin.y, 160, 80);
    _typePicker.delegate = self;
    _typePicker.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addSkillButton:(id)sender {
    if ([sender isEqual:_label1Button]) {
        _labelToEdit = _skill1TitleLabel;
        _skillID = &_skill1ID;
    } else {
        _labelToEdit = _skill2TitleLabel;
        _skillID = &_skill2ID;
    }
    [self displayTableView];
}

-(void)displayTableView {
    CGRect tableFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + [self returnHeightDifference], self.view.frame.size.width, self.view.frame.size.height - [self returnHeightDifference]);
    UITableView *skillTreeTableView = [[UITableView alloc] initWithFrame:tableFrame];
    _allSkillTrees = [_dbEngine getSkillTrees];
    skillTreeTableView.dataSource = self;
    skillTreeTableView.delegate = self;
    [self.view addSubview:skillTreeTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allSkillTrees.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSDictionary *skill = _allSkillTrees[indexPath.row];
    cell.textLabel.text = [skill objectForKey:@"skillTreeName"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *skill = _allSkillTrees[indexPath.row];
    _labelToEdit.text = [skill objectForKey:@"skillTreeName"];
    
    if ([_labelToEdit isEqual:_skill1TitleLabel]) {
        _skill1Value.hidden = FALSE;
    } else if ([_labelToEdit isEqual:_skill2TitleLabel]) {
        _skill2Value.hidden = FALSE;
    }
    
    *_skillID = [[skill objectForKey:@"skillTreeID"] integerValue];
    [tableView removeFromSuperview];
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _talismanTypes.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _talismanTypes[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedType = _talismanTypes[row];
    _typeReady = YES;
    [self enableCreateButton];
}


-(void)cancelNumberPad{
    [_editingTextField resignFirstResponder];
    _editingTextField.text = @"";
}

-(void)doneWithNumberPad{
    [_editingTextField resignFirstResponder];
}

- (IBAction)editingDidBegin:(id)sender {
    _editingTextField = (UITextField *)sender;
}

- (IBAction)editingDidEnd:(id)sender {
    [self doneWithNumberPad];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    NSMutableCharacterSet *alphaNumsNeg = [[NSMutableCharacterSet alloc] init];
    [alphaNumsNeg addCharactersInString:@"-1234567890"];
    
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
    
    BOOL valid = [alphaNumsNeg isSupersetOfSet:inStringSet];
    
    if (valid) {
        NSInteger value = [textField.text integerValue];
        if (value < 21 && value > -21) {
            [textField resignFirstResponder];
            if ([textField isEqual:_skill1Value]) {
                _skill1ValueBool = YES;
                _skill2label.hidden = FALSE;
                _skill2TitleLabel.hidden = FALSE;
                _label2Button.enabled = TRUE;
                [self enableCreateButton];
            } else {
                _skill2ValueBool = YES;
                [self enableCreateButton];

            }
            return YES;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please pick between -20 and 20" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            textField.text = @"";
            return NO;
        }

    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please pick a number between -20 and 20" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        textField.text = @"";
        return NO;
    }

}


- (IBAction)valueChanged:(id)sender {
    if ([sender isEqual:_slotsSegmentedControl]) {
        _slots = _slotsSegmentedControl.selectedSegmentIndex;
    }

    [self enableCreateButton];
}

- (IBAction)createButtonTouched:(id)sender {
    UIAlertView *nameAlert = [[UIAlertView alloc] initWithTitle:@"Name Your Talisman" message:@"Please Give your talisman a name so that you can remember it later" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    nameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [nameAlert show];

    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        _name = [alertView textFieldAtIndex:0].text;
        if (_name.length > 20) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please keep name shorter than 20 Characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        } else {
            [self addTalismanToDatabase];
        }
        
        
    }
}

-(void)addTalismanToDatabase{
    Talisman *newTalisman = [[Talisman alloc] init];
    NSMutableArray *skillDictionary = [[NSMutableArray alloc] init];
    newTalisman.numSlots = _slots;
    newTalisman.name = _name;
    newTalisman.slot = @"Talisman";
    
    newTalisman.talismanType = _selectedType;
    if (_skill1Ready) {
        newTalisman.skill1ID = _skill1ID;
        newTalisman.skill1Name = _skill1TitleLabel.text;
        newTalisman.skill1Value = [_skill1Value.text integerValue];
        [skillDictionary addObject:@{@"skillTreeID" : [NSNumber numberWithInt:newTalisman.skill1ID], @"skillTreeName" : newTalisman.skill1Name, @"skillTreePointValue" : [NSNumber numberWithInt:newTalisman.skill1Value]}];
    }
    
    if (_skill2Ready) {
        newTalisman.skill2ID = _skill2ID;
        newTalisman.skill2Name = _skill2TitleLabel.text;
        newTalisman.skill2Value = [_skill2Value.text integerValue];
        [skillDictionary addObject:@{@"skillTreeID" : [NSNumber numberWithInt:newTalisman.skill2ID], @"skillTreeName" : newTalisman.skill2Name, @"skillTreePointValue" : [NSNumber numberWithInt:newTalisman.skill2Value]}];
    }
    
    BOOL successful = [_dbEngine insertNewTalismanIntoDatabase:newTalisman];
    
//    if (successful) {
//        _selectedSet.talisman = newTalisman;
//        [_dbEngine addTalisman:newTalisman toArmorSet:_selectedSet];
//        _asDVC.leftASDVC = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTalismanCreated" object:self];
        [self.navigationController popViewControllerAnimated:YES];
//    }
}


-(void)enableCreateButton {
    if (_skill1ValueBool && _skill1ID > -1) {
        _skill1Ready = YES;
    }
    
    if (_skill2Value && _skill2ID > -1) {
        _skill2Ready = YES;
    }
    
    if (_slots >= 0 && (_skill1Ready || _skill2Ready) && _typeReady) {
        _createButton.enabled = TRUE;
    }
}
@end

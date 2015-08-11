//
//  TalismanCreatorViewController.m
//  MH4UDatabase
//
//  Created by Neil Shetty on 8/11/15.
//  Copyright (c) 2015 GuthuDesigns. All rights reserved.
//

#import "TalismanCreatorViewController.h"
#import "SkillTreeViewController.h"
#import "MH4UDBEngine.h"

@interface TalismanCreatorViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *typePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *slotsSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *skill1TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *skill2TitleLabel;
@property (nonatomic) NSArray *talismanTypes;
@property (nonatomic) NSArray *allSkillTrees;
@property (nonatomic) NSString *selectedType;
@property (nonatomic) NSUInteger slots;
- (IBAction)addSkillButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *skill1Value;
@property (weak, nonatomic) IBOutlet UITextField *skill2Value;
@property (nonatomic) UITextField *editingTextField;
@property (weak, nonatomic) IBOutlet UIButton *label1Button;
@property (weak, nonatomic) IBOutlet UIButton *label2Button;
@property (nonatomic) NSInteger skill1ID;
@property (nonatomic) NSInteger skill2ID;
@property (nonatomic) NSInteger *skillID;

- (IBAction)editingDidBegin:(id)sender;
- (IBAction)editingDidEnd:(id)sender;
- (IBAction)touchUpOutside:(id)sender;
@property (nonatomic) UILabel *labelToEdit;
@end

@implementation TalismanCreatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _talismanTypes = @[@"Pawn", @"Bishop", @"Knight", @"Rook", @"Queen", @"King", @"Dragon", @"Unknowable", @"Mystic", @"Hero", @"Legend", @"Creator", @"Sage", @"Miracle"];
    
    // Do any additional setup after loading the view.
    _typePicker.frame = CGRectMake(_typePicker.frame.origin.x, _typePicker.frame.origin.y, 160, 80);
    _typePicker.delegate = self;
    _typePicker.dataSource = self;
    
//    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
//    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
//    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
//                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
//                            [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
//    [numberToolbar sizeToFit];
//    _skill1Value.inputAccessoryView = numberToolbar;
//    _skill2Value.inputAccessoryView = numberToolbar;
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
}

- (IBAction)slotValueChanged:(id)sender {
    _slots = _slotsSegmentedControl.selectedSegmentIndex;
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
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
    
    BOOL valid = [alphaNums isSupersetOfSet:inStringSet];
    
    if (valid) {
        NSInteger value = [textField.text integerValue];
        if (value < 21 && value > -21) {
            [textField resignFirstResponder];
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


@end

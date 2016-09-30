//
//  UserVerificationViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 05/02/15.
//
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "AppTextField.h"
#import "BaseViewController.h"

@interface UserVerificationViewController : BaseViewController <UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,CustomAlertDelegate>
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet AppTextField *txtName;
@property (weak, nonatomic) IBOutlet AppTextField *txtHobby;
@property (weak, nonatomic) IBOutlet AppTextField *txtRelation;
- (IBAction)submitTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet AppTextField *lblHobby;
- (IBAction)hobbyTapped:(id)sender;

@end

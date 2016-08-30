//
//  UserVerificationViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 05/02/15.
//
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface UserVerificationViewController : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,CustomAlertDelegate>
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtHobby;
@property (weak, nonatomic) IBOutlet UITextField *txtRelation;
- (IBAction)submitTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UILabel *lblHobby;
- (IBAction)hobbyTapped:(id)sender;

@end

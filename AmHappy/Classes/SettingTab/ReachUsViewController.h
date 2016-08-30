//
//  ReachUsViewController.h
//  BusMap
//
//  Created by Peerbits 8 on 23/12/14.
//
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface ReachUsViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,CustomAlertDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextView *txtComment;
- (IBAction)submitTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollview;

@end

//
//  ForgotPasswordViewController.h
//  AmHappy
//
//  Created by Syntel-Amargoal1 on 7/28/16.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "LoginViewController.h"

@interface ForgotPasswordViewController : BaseViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)onClickBackButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet AppTextField *txtFldEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
- (IBAction)onClickSubmitButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIN;
- (IBAction)onClickSignInButton:(id)sender;
@end

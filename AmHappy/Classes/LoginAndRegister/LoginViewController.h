//
//  LoginViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "FHSTwitterEngine.h"
#import "RegistrationViewController.h"
#import "BaseViewController.h"
#import "ForgotPasswordViewController.h"

@interface LoginViewController : BaseViewController <UITextFieldDelegate,GPPSignInDelegate,FHSTwitterEngineAccessTokenDelegate,CustomAlertDelegate>
{
    RegistrationViewController *registrationVC;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet AppTextField *txtUser;
@property (weak, nonatomic) IBOutlet AppTextField *txtPasswd;
- (IBAction)goTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnGo;
- (IBAction)forgetPasswdTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnForget;
- (IBAction)registerTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
- (IBAction)fbTapped:(id)sender;
- (IBAction)twitterTapped:(id)sender;
- (IBAction)googleTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgSeprator;
@property (weak, nonatomic) IBOutlet UIImageView *imgOr;

@end

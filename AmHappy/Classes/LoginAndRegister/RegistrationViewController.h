//
//  RegistrationViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "BaseViewController.h"



@interface RegistrationViewController : BaseViewController <UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CustomAlertDelegate>
{
    
}
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIImageView *placeImage;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet AppTextField *txtUser;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
- (IBAction)cameraTapped:(id)sender;
@property (weak, nonatomic) IBOutlet AppTextField *txtName;
@property (weak, nonatomic) IBOutlet AppTextField *txtDob;
@property (weak, nonatomic) IBOutlet AppTextField *txtEmail;
@property (weak, nonatomic) IBOutlet AppTextField *txtPasswd;
@property (weak, nonatomic) IBOutlet UILabel *lblHobby;
@property (weak, nonatomic) IBOutlet AppTextField *txtConfirm;
@property (weak, nonatomic) IBOutlet AppTextField *txtHobby;
- (IBAction)hobbyTapped:(id)sender;
@property (weak, nonatomic) IBOutlet AppTextField *txtRelation;
@property (weak, nonatomic) IBOutlet UILabel *lblGender;
- (IBAction)maleTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnMale;
- (IBAction)femailTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnFemail;
- (IBAction)termsTapped:(id)sender;
- (IBAction)checkTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (weak, nonatomic) IBOutlet UIImageView *imgconfirm;
- (IBAction)saveTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgPasswd;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgDob;
- (IBAction)blockedUserTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgEmail;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgname;
@property (weak, nonatomic) IBOutlet UIButton *btnBlockUser;

@property (assign, nonatomic) BOOL isEdit;
@property (assign, nonatomic) BOOL isMy;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UIButton *btnTerms;
- (IBAction)save2Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSave2;
- (IBAction)cancelTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIImageView *imgSepr;
@property (weak, nonatomic) IBOutlet UIView *camBgView;
- (IBAction)onClickSignInButton:(id)sender;

@end

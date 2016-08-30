//
//  OtherUserProfileViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 23/02/15.
//
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface OtherUserProfileViewController : UIViewController<CustomAlertDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UITextField *txtFname;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtDob;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtRelation;
@property (weak, nonatomic) IBOutlet UILabel *lblHobby;
@property (weak, nonatomic) IBOutlet UILabel *lblGender;
@property (weak, nonatomic) IBOutlet UIButton *btnfemail;
@property (weak, nonatomic) IBOutlet UIButton *btnMail;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property(strong,nonatomic) NSString *userId;
@property (weak, nonatomic) IBOutlet UIImageView *imgBg3;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgBg4;
@property (weak, nonatomic) IBOutlet UIImageView *imgSeperator;
@property (weak, nonatomic) IBOutlet UIButton *btnHobby;

@property (weak, nonatomic) IBOutlet UIImageView *imgIcone2;
- (IBAction)hobbyTapped:(id)sender;
- (IBAction)addTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgBg2;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIImageView *imgBg1;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon1;
- (IBAction)eventTapped:(id)sender;

@end

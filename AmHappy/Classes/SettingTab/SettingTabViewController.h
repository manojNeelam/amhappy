//
//  SettingTabViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import <FBSDKShareKit/FBSDKShareKit.h>

@interface SettingTabViewController : UIViewController<UIActionSheetDelegate,CustomAlertDelegate,FBSDKAppInviteDialogDelegate>


@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)languageTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblAppVersion;
@property (weak, nonatomic) IBOutlet UILabel *lblPush;
- (IBAction)notificationTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnVersion;
- (IBAction)feedbackTapped:(id)sender;
- (IBAction)logOutTapped:(id)sender;
- (IBAction)profileTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblLanguage;
@property (weak, nonatomic) IBOutlet UIButton *btnNotification;
@property (weak, nonatomic) IBOutlet UILabel *lblProfike;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)doneTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblLogout;
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property (strong, nonatomic) IBOutlet UIView *settingView;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblReport;
@property (weak, nonatomic) IBOutlet UIButton *btnReport;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@property (weak, nonatomic) IBOutlet UIView *currentdistanceView;
@property (weak, nonatomic) IBOutlet UIButton *btnLanguage;
- (IBAction)distanceChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrent;
- (IBAction)clickPromotion:(id)sender;

- (IBAction)clickPromotionsList:(id)sender;

- (IBAction)clickInviteFriends:(id)sender;



@end

//
//  EventTabViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "LocationCell2.h"
#import "CustomAlert2.h"
#import "DateCell.h"

@interface EventTabViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,LocationCellDelegate,UITableViewDataSource,UITableViewDelegate,CustomAlertDelegate,CustomAlertDelegate2,DateCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgEvent;
- (IBAction)cameraTapped:(id)sender;
- (IBAction)categoryTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnCategory;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivate;
- (IBAction)eventChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblselectedCategory;
@property (weak, nonatomic) IBOutlet UISwitch *eventSwitch;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIImageView *testImage;
@property (weak, nonatomic) IBOutlet UIScrollView *imgScroll;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (strong, nonatomic) IBOutlet UIView *privateView;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
- (IBAction)locationTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtAmount;
- (IBAction)submitTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *publicView;
@property (weak, nonatomic) IBOutlet UITextField *txtTime;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UITextField *txtEventName2;
@property (weak, nonatomic) IBOutlet UITextField *txtAmount2;
@property (weak, nonatomic) IBOutlet UITextView *txtDesc2;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
- (IBAction)submit2Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgBG;
@property (weak, nonatomic) IBOutlet UITextField *txtEnd2;
@property (weak, nonatomic) IBOutlet UIImageView *imgVotingDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgVoteCal;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit2;
@property (weak, nonatomic) IBOutlet UIImageView *placeImage;
@property(assign,nonatomic) BOOL isEdit,isRepost;
@property (weak, nonatomic) IBOutlet UIButton *btnCreate;
@property(strong,nonatomic) NSString *eventId;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;

- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgSeprator;
@property (weak, nonatomic) IBOutlet UIImageView *imgArrow;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;




@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_EventNameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_EventNameWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_DescriptionHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_DescriptionWidtth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_AmountHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_AmountWidth;
@property (weak, nonatomic) IBOutlet UITextField *txtFldDescription;


@property (weak, nonatomic) IBOutlet UILabel *lblEventName;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@end

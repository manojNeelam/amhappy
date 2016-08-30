//
//  EventDetailViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 13/02/15.
//
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "Zoomview.h"
#import "CommentList1Cell.h"
#import "CommentList2Cell.h"
//#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "ELCImagePickerHeader.h"
#import "CommentDetail.h"



@interface EventDetailViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,CustomAlertDelegate,CommentCell2Delegate,UIGestureRecognizerDelegate,CommentCell1Delegate,ELCImagePickerControllerDelegate>



@property (weak, nonatomic) IBOutlet UILabel *lblEventLocation;


@property (strong, nonatomic) IBOutlet UILabel *lblzoomViewTitle;

@property (weak, nonatomic) IBOutlet UIButton *btnWhatsapp;

- (IBAction)clickWhatsapp:(id)sender;


@property (weak, nonatomic) IBOutlet UIImageView *imgTrans;

@property (weak, nonatomic) IBOutlet UIView *shareSubview;
- (IBAction)cancelTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgEvent;
- (IBAction)editTapped:(id)sender;
- (IBAction)shareNewTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *shareImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
- (IBAction)downLoadTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UITextView *lbldesc;
@property (weak, nonatomic) IBOutlet UIImageView *imgShareBig;
- (IBAction)calTapped:(id)sender;
- (IBAction)locationTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblCalendar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
- (IBAction)guestTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblGuest;
- (IBAction)shareTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblShare;
- (IBAction)priceTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblEventName;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnPrice;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewBtn;
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UIButton *btnGuest;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollviewMain;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblAttending;
@property (weak, nonatomic) IBOutlet UIButton *btnCalendar;
- (IBAction)yesTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnYes;
- (IBAction)maybeTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnMaybe;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblCreatedby;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblCount;
@property (weak, nonatomic) IBOutlet UITextView *txtComment;

- (IBAction)cameraTapped:(id)sender;
- (IBAction)postTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPost;
@property (weak, nonatomic) IBOutlet UITableView *tableViewComment;
@property(strong,nonatomic) NSString *eventID;
@property (weak, nonatomic) IBOutlet UILabel *lblLast;
@property (weak, nonatomic) IBOutlet UIButton *btnLastDate;
@property (weak, nonatomic) IBOutlet UILabel *lblLastDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgCommentPre;
- (IBAction)photoTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblReport;
- (IBAction)reportTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnReport;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoto;

- (IBAction)timeTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

- (IBAction)likeEventTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLikeEvent;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeEvent;


//*************** Version 4 ***********

@property (weak, nonatomic) IBOutlet UIButton *btnRepost;


@property (weak, nonatomic) IBOutlet UILabel *lblEventDate;


@property (weak, nonatomic) IBOutlet UIView *viewAddImages;


@property (weak, nonatomic) IBOutlet UIButton *image1;

@property (weak, nonatomic) IBOutlet UIButton *image2;

@property (weak, nonatomic) IBOutlet UIButton *image3;


@property (weak, nonatomic) IBOutlet UIButton *image4;

@property (weak, nonatomic) IBOutlet UIButton *image5;

@property (retain) UIDocumentInteractionController * documentInteractionController;

@property (nonatomic, copy) NSArray *chosenImages;




@property (weak, nonatomic) IBOutlet UIView *viewTag;


- (IBAction)clickCLose:(id)sender;


@property (weak, nonatomic) IBOutlet UITableView *tblUsers;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTagTop;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;



//*************** Click events ********

- (IBAction)clickRepost:(id)sender;

- (IBAction)clickimage1:(id)sender;

- (IBAction)clickimage2:(id)sender;

- (IBAction)clickimage3:(id)sender;

- (IBAction)clickimage4:(id)sender;

- (IBAction)clickimage5:(id)sender;









@end

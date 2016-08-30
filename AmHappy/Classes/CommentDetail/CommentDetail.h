//
//  CommentDetail.h
//  
//
//  Created by Peerbits MacMini9 on 28/03/16.
//
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingTableView.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "TYMActivityIndicatorViewViewController.h"
#import "SBJSON.h"
#import "NSString+NSString___SizeForWidth.h"
#import "HBVLinkedTextView.h"



@interface CommentDetail : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
{
    
    
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeaderTop;


@property (weak, nonatomic) IBOutlet UIView *viewTopHeader;


@property(nonatomic,strong)NSMutableArray *gettedReplies;

@property(nonatomic,strong) NSString *commentID;

@property(nonatomic,strong) NSString *eventID;

@property(nonatomic,assign)BOOL isImageReplies;


@property (weak, nonatomic) IBOutlet UITableView *tblComments;

@property (weak, nonatomic) IBOutlet UILabel *lblTopHeader;

@property (weak, nonatomic) IBOutlet UIView *viewComment;

@property (weak, nonatomic) IBOutlet UITextView *txtviewComment;


@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewPickedImageWidth;

@property (weak, nonatomic) IBOutlet UIView *viewPickedImage;

@property (weak, nonatomic) IBOutlet UIImageView *imgPickedimage;

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;


//******* Tag User

@property (weak, nonatomic) IBOutlet UIView *viewTag;


- (IBAction)clickCLose:(id)sender;


@property (weak, nonatomic) IBOutlet UITableView *tblUsers;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTagTop;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;


//*********** Click Events *******

- (IBAction)clickBack:(id)sender;

- (IBAction)clickSend:(id)sender;


- (IBAction)cameraClicked:(id)sender;

- (IBAction)clickCancelImage:(id)sender;




@end

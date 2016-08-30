//
//  ChatViewController.h
//  iPhoneXMPP
//
//  Created by macmini5 on 29/08/13.
//
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import <CoreData/CoreData.h>
#import "DB.h"
#import "MessageCell1.h"
#import "MessageCell2.h"
#import "XMPPRoom.h"
#import "HPGrowingTextView.h"
#import "MessageCell3.h"



@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,XMPPRoomDelegate,UITextViewDelegate,CustomAlertDelegate,HPGrowingTextViewDelegate,CustomAlertDelegate>
{
    BOOL position;
    NSMutableArray  *messages;
    NSString *userId;
    XMPPStream *xmppStream;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    DB *dbmanager;
    
    __strong XMPPRoom   * xmppRoom;
    __strong id <XMPPRoomStorage> xmppRoomStorage;
    
    HPGrowingTextView *textViewMessage;
    UIView *containerView;

}
@property (weak, nonatomic) IBOutlet UIImageView *imgOnline;
@property (retain, nonatomic)NSString *userId;

@property (weak, nonatomic) IBOutlet UIButton *btnPost;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UIView *chatVC;
- (IBAction)sendMessage:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tView;
@property (weak, nonatomic) IBOutlet UITextView *textMessage;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (strong,nonatomic) NSString *fromJId;
@property (strong,nonatomic) NSString *fromUserId;
@property (assign,nonatomic) BOOL isGroupChat;
@property (strong,nonatomic) NSString *eventId;
@property (strong,nonatomic) NSString *name;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;

@property (strong,nonatomic) NSString *imgUrl;

@property (weak, nonatomic) IBOutlet UIImageView *bgImg;

- (IBAction)showGuestTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnShowGuest;





@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@end

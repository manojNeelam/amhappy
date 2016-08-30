//
//  GuestViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 18/02/15.
//
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import "FHSTwitterEngine.h"

#import "FriendCell.h"


@interface GuestViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,GPPSignInDelegate,MFMailComposeViewControllerDelegate,CustomAlertDelegate,FriendCellDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableGuest;
@property (weak, nonatomic) IBOutlet UIButton *btnAddAmhappy;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property(strong,nonatomic) NSString *eventID;
- (IBAction)addTapped:(id)sender;
- (IBAction)tweetTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
- (IBAction)fbTapped:(id)sender;
- (IBAction)googleTapped:(id)sender;
- (IBAction)messageTapped:(id)sender;
- (IBAction)addFrndTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet UILabel *lblNofound;
@property(assign, nonatomic) BOOL isMy;

@property(assign, nonatomic) BOOL isGroupAdmin;

@property(assign, nonatomic) BOOL isPrivate;
@property(assign, nonatomic) BOOL isFromChat;

@property(nonatomic,strong)NSString *eventType;







@end

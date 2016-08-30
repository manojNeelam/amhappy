//
//  UserTabViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import "FHSTwitterEngine.h"
#import "ChatUserCell.h"

@interface UserTabViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,GPPSignInDelegate,MFMailComposeViewControllerDelegate,CustomAlertDelegate,UISearchBarDelegate,UIGestureRecognizerDelegate>
- (IBAction)addTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tableviewFriend;
//- (IBAction)addTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
- (IBAction)twitterTapped:(id)sender;
- (IBAction)googleTapped:(id)sender;
- (IBAction)messageTapped:(id)sender;
- (IBAction)amhappyTapped:(id)sender;

- (IBAction)fbTapped:(id)sender;
- (IBAction)groupTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@end

//
//  FindingFriendsViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 02/03/15.
//
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "FHSTwitterEngine.h"
#import <MessageUI/MessageUI.h>
#import "FriendCell.h"


@interface FindingFriendsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,GPPSignInDelegate,MFMailComposeViewControllerDelegate,CustomAlertDelegate,FriendCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableviewFriends;
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitled;
@property(assign,nonatomic) int socialId;
@property(strong, nonatomic) NSArray *userArray;



@end

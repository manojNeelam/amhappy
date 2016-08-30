//
//  FriendListViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 20/02/15.
//
//

#import <UIKit/UIKit.h>
#import "FriendCell.h"
#import <GooglePlus/GooglePlus.h>
#import "FHSTwitterEngine.h"
#import <MessageUI/MessageUI.h>



@interface FriendListViewController : UIViewController<FriendCellDelegate,GPPSignInDelegate,MFMailComposeViewControllerDelegate,CustomAlertDelegate,UISearchBarDelegate>




@property (weak, nonatomic) IBOutlet UITableView *tableFriends;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property(strong, nonatomic) NSArray *userArray;
@property(assign,nonatomic) int socialId;
@property(strong,nonatomic) NSString *eventID;

@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;

@end

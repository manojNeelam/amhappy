//
//  ChatFriendsViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 02/03/15.
//
//

#import <UIKit/UIKit.h>
#import "FriendCell.h"
#import "ChatUserCell.h"

@interface ChatFriendsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,CustomAlertDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableviewFriend;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;

@end

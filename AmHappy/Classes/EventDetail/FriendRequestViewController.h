//
//  FriendRequestViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 25/02/15.
//
//

#import <UIKit/UIKit.h>
#import "InviteCell.h"
#import "SearchTextField.h"

@interface FriendRequestViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,InviteCellDelegate,CustomAlertDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableviewAccept;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property(assign, nonatomic) BOOL isFriend;

@property (weak, nonatomic) IBOutlet SearchTextField *txtSearch;

@end

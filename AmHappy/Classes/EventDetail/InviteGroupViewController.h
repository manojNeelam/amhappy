//
//  InviteGroupViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 14/09/15.
//
//

#import <UIKit/UIKit.h>
#import "FriendCell.h"

@interface InviteGroupViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,FriendCellDelegate,CustomAlertDelegate>
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblGroup;
@property(strong,nonatomic) NSString *eventID;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;


@end

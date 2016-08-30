//
//  EditGroupViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 14/09/15.
//
//

#import <UIKit/UIKit.h>
#import "FriendCellNew.h"

@interface EditGroupViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,CustomAlertDelegate,FriendCellNewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblFriend;
- (IBAction)backTapped:(id)sender;
- (IBAction)okTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnSave;




@property (strong,nonatomic) NSString *groupID;

@property (strong,nonatomic) NSString *groupName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;


@end

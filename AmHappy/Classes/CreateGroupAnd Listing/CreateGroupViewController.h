//
//  CreateGroupViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 01/09/15.
//
//

#import <UIKit/UIKit.h>
#import "FriendCellNew.h"

@interface CreateGroupViewController : UIViewController<FriendCellNewDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,CustomAlertDelegate,UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnSave;


@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgBg;
- (IBAction)okTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblInstruction;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
- (IBAction)imageClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblFriend;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@end

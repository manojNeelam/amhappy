//
//  GroupListViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 01/09/15.
//
//

#import <UIKit/UIKit.h>
#import "FriendCell.h"

@interface GroupListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnAdd;
@property(nonatomic,assign)BOOL isbtnAddHide;

- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;
- (IBAction)addGroupTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tblGroup;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

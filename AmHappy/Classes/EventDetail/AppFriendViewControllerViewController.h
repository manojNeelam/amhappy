//
//  AppFriendViewControllerViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 27/02/15.
//
//

#import <UIKit/UIKit.h>
#import "FriendCell.h"

@interface AppFriendViewControllerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,FriendCellDelegate,CustomAlertDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate>


@property (strong, nonatomic) IBOutlet UIButton *btnAdd;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(strong,nonatomic) NSString *eventID;
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;

- (IBAction)groupTapped:(id)sender;

@property(nonatomic,assign)BOOL isHideBtnAdd;

@property(nonatomic,assign)BOOL isbackToHome;

@end

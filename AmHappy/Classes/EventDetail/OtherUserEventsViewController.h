//
//  OtherUserEventsViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 14/09/15.
//
//

#import <UIKit/UIKit.h>
#import "SearchTextField.h"

@interface OtherUserEventsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CustomAlertDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnUpcoming;

- (IBAction)clickUpcoming:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnExpired;

- (IBAction)clickExpired:(id)sender;


@property (weak, nonatomic) IBOutlet UITableView *tblEvents;
//@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *userName;

@property (assign, nonatomic) BOOL isMy;


@property (weak, nonatomic) IBOutlet UIView *baseSearchView;
@property (weak, nonatomic) IBOutlet SearchTextField *txtSearch;
@property (weak, nonatomic) IBOutlet UILabel *lblUpcomingEvents;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiredEvents;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
- (IBAction)onClickSearchButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *baseExpiredUpcomingButtons;
@end

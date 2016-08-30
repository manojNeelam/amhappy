//
//  CommonListViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 15/09/15.
//
//

#import <UIKit/UIKit.h>
#import "EventListCell.h"
#import "SearchTextField.h"

@interface CommonListViewController : UIViewController<CustomAlertDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgTop;


@property (weak, nonatomic) IBOutlet UIButton *btnUpcoming;

- (IBAction)clickUpcoming:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnExpired;

- (IBAction)clickExpired:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tblEvent;

@property(strong, nonatomic) NSString *keyWord;

-(id)initWithNibName:(NSString *)nibNameOrNil LoadFlag:(int)loadFlag bundle:(NSBundle *)nibBundleOrNil;

@property (weak, nonatomic) IBOutlet UIView *baseSearchView;
@property (weak, nonatomic) IBOutlet SearchTextField *txtSearch;
@property (weak, nonatomic) IBOutlet UILabel *lblUpcomingEvents;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiredEvents;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
- (IBAction)onClickSearchButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *baseExpiredUpcomingButtons;

@end

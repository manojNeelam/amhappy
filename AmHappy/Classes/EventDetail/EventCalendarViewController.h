//
//  EventCalendarViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 18/02/15.
//
//

#import <UIKit/UIKit.h>
#import "VRGCalendarView.h"
#import "VoteListCell.h"

@interface EventCalendarViewController : UIViewController<VRGCalendarViewDelegate,UITableViewDelegate,UITableViewDataSource,voteCellDelegate,CustomAlertDelegate>
@property (weak, nonatomic) IBOutlet UIView *calView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UITableView *tableviewVote;
@property(strong, nonatomic) NSArray *voteDateArray;
- (IBAction)editTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property(assign, nonatomic) BOOL isMy;
@property(strong,nonatomic) NSString *eventID;
@property(assign,nonatomic) BOOL isPrivate;
@property(strong,nonatomic) NSString * myVotedId;

@property(nonatomic,strong)NSNumber *endVoting;

@property(nonatomic,strong)NSString *eventType;


@property(strong,nonatomic) NSString *peventDate;


- (id)initWithNibName:(NSString *)nibNameOrNil VoteID:(int)voteID bundle:(NSBundle *)nibBundleOrNil;





@end

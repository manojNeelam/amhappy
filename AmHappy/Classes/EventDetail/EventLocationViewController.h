//
//  EventLocationViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 18/02/15.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "VoteListCell.h"

@interface EventLocationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,CLLocationManagerDelegate,voteCellDelegate,CustomAlertDelegate>
{
    MKCoordinateRegion region;
    CLLocationCoordinate2D coordinate;
}
@property (weak, nonatomic) IBOutlet MKMapView *publicMap;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet MKMapView *userMap;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UITableView *tableviewVote;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
- (IBAction)editTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property(assign, nonatomic) BOOL isMy;
@property(strong,nonatomic) NSString *eventID;
@property(strong, nonatomic) NSArray *voteDateArray;
@property(assign,nonatomic) int catID;
@property(strong,nonatomic) NSString *imgURL;
@property(assign,nonatomic) BOOL isPrivate;
@property(strong,nonatomic) NSDictionary *pDictionary;
@property(assign,nonatomic) int type;
@property(strong,nonatomic) NSString *eventName;
@property(strong,nonatomic) NSString * myVotedId;



@property(nonatomic,strong)NSNumber *endVoting;

@property(nonatomic,strong)NSString *eventType;



- (id)initWithNibName:(NSString *)nibNameOrNil VoteID:(int)voteID bundle:(NSBundle *)nibBundleOrNil;






@end

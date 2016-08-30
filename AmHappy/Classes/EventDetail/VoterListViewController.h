//
//  VoterListViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 18/02/15.
//
//

#import <UIKit/UIKit.h>

@interface VoterListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CustomAlertDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblsubTitle;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(strong,nonatomic) NSString *eventID;
@property(assign,nonatomic) BOOL isLocation;
@property(assign,nonatomic) NSDictionary *dataDict;
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;


@end

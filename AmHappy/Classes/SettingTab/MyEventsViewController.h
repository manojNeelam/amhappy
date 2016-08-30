//
//  MyEventsViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 10/02/15.
//
//

#import <UIKit/UIKit.h>

@interface MyEventsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CustomAlertDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnUpcoming;

- (IBAction)clickUpcoming:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnExpired;

- (IBAction)clickExpired:(id)sender;







@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property(assign, nonatomic) BOOL isInvite;

@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tableAuto;

@end

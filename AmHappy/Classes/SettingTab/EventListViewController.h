//
//  EventListViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 10/02/15.
//
//

#import <UIKit/UIKit.h>

@interface EventListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CustomAlertDelegate,UIGestureRecognizerDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *imgTop;

@property (weak, nonatomic) IBOutlet UIButton *btnUpcoming;

- (IBAction)clickUpcoming:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnExpired;

- (IBAction)clickExpired:(id)sender;


@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
- (IBAction)textChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableAuto;
- (IBAction)backTapped:(id)sender;
- (IBAction)filterTapped:(id)sender;

@end

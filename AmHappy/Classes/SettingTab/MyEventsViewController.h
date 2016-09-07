//
//  MyEventsViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 10/02/15.
//
//

#import <UIKit/UIKit.h>
#import "SearchTextField.h"

@interface MyEventsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CustomAlertDelegate,UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnUpcoming;

- (IBAction)clickUpcoming:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnExpired;

- (IBAction)clickExpired:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblUpcoming;
@property (weak, nonatomic) IBOutlet UILabel *lblExpired;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property(assign, nonatomic) BOOL isInvite;

@property (weak, nonatomic) IBOutlet SearchTextField *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tableAuto;

@end

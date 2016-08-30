//
//  BlockedUserViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 01/07/15.
//
//

#import <UIKit/UIKit.h>
#import "ChatUserCell.h"

@interface BlockedUserViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableViewUser;

@end

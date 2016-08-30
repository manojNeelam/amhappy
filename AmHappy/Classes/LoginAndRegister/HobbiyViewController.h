//
//  HobbiyViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 16/02/15.
//
//

#import <UIKit/UIKit.h>
#import "HobbyCell.h"

@interface HobbiyViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HobbyCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (assign, nonatomic) BOOL isEdit;
-(id)initWithNibName:(NSString *)nibNameOrNil IdArray:(NSArray *)idArray bundle:(NSBundle *)nibBundleOrNil;
@property (assign, nonatomic) BOOL isFirst;
@property (assign, nonatomic) BOOL isOther;

@property (weak, nonatomic) IBOutlet UIButton *btnSave;


@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@end

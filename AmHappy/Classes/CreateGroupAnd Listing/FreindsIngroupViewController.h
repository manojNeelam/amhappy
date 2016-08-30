//
//  FreindsIngroupViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 03/09/15.
//
//

#import <UIKit/UIKit.h>

@interface FreindsIngroupViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UIButton *btnAddParticiapnts;


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIButton *btnGroupImage;

@property (strong, nonatomic) IBOutlet UITextField *txtfldGroupName;

@property (strong, nonatomic) IBOutlet UIButton *btnsave;

#pragma mark ----- click Events

-(IBAction)clickGroupImage:(id)sender;

- (IBAction)clickSave:(id)sender;

//*******************************

@property(nonatomic,strong) NSMutableDictionary *groupDetails;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tblFriends;
@property(strong,nonatomic) NSString *groupId;
@property (strong,nonatomic) NSString *groupName;
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;

- (IBAction)addTapped:(id)sender;


@end

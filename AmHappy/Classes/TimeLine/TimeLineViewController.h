//
//  TimeLineViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 11/09/15.
//
//

#import <UIKit/UIKit.h>
#import "TimeLineCell.h"
#import "TimeLineCell1.h"
#import "FRHyperLabel.h"

@interface TimeLineViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,TimeLineCell1Delegate,TimeLineCellDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (strong, nonatomic) IBOutlet UILabel *lblzoomImageTitle;



- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tblTimeLIne;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@property (weak, nonatomic) IBOutlet UIView *shareSubview;
@property (strong, nonatomic) IBOutlet UIView *shareImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imgShareBig;
- (IBAction)back2Tapped:(id)sender;
- (IBAction)downLoadTapped:(id)sender;
- (IBAction)shareTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *feebView;



- (IBAction)feedTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblFeed;
@property (weak, nonatomic) IBOutlet UIButton *btnFeed;

@end

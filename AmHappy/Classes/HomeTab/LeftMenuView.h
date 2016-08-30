//
//  LeftMenuView.h
//  AmHappy
//
//  Created by Syntel-Amargoal1 on 8/11/16.
//
//

#import <UIKit/UIKit.h>

@protocol LeftMenuViewDelegate <NSObject>

-(void)toggleMenuwithOpenSelectedOption:(NSString *)option;
@end

@interface LeftMenuView : UIView //<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *menuList;
}

@property (nonatomic, assign) id<LeftMenuViewDelegate> leftMenuDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;

@end

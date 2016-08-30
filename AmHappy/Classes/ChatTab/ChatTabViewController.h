//
//  ChatTabViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DB.h"


@interface ChatTabViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UISearchBarDelegate,CustomAlertDelegate,UIGestureRecognizerDelegate>
{
    NSFetchedResultsController *fetchedResultsController;

}
@property (weak, nonatomic) IBOutlet UISearchBar *txtSearch;
@property (weak, nonatomic) IBOutlet UITableView *tableViewChat;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)addTapped:(id)sender;

@end

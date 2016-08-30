//
//  likesPeople.h
//  AmHappy
//
//  Created by Peerbits MacMini9 on 30/11/15.
//
//

#import <UIKit/UIKit.h>

@interface likesPeople : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *lblwhoLikedThis;

@property(nonatomic,strong)NSMutableDictionary *likedDetail;


@property(nonatomic,strong)NSString *gettedId;


@property(nonatomic,strong)NSString *gettedType;


@property (strong, nonatomic) IBOutlet UITableView *tblView;


- (IBAction)clickBack:(id)sender;

@end

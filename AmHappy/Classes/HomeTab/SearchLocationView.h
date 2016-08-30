//
//  SearchLocationView.h
//  AmHappy
//
//  Created by Syntel-Amargoal1 on 8/24/16.
//
//

#import <UIKit/UIKit.h>

@protocol SearchLocationViewDelegate <NSObject>

-(void)selectedAddress:(NSDictionary *)dict;

@end

@interface SearchLocationView : UIView <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSArray *placesList;
}
@property (weak, nonatomic) IBOutlet UIView *baseSearchView;

@property (nonnull, assign) id<SearchLocationViewDelegate> searchDelegate;
@property (weak, nonatomic) IBOutlet UITextField *txtFldSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;

@end

//
//  PromotionListing.h
//  
//
//  Created by Peerbits MacMini9 on 19/03/16.
//
//

#import <UIKit/UIKit.h>
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "TYMActivityIndicatorViewViewController.h"
#import "SBJSON.h"
#import "SeachAddressmapViewController.h"

@interface PromotionListing:UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    
}


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnClearWidth;


@property (weak, nonatomic) IBOutlet UIButton *btnClear;


@property (weak, nonatomic) IBOutlet UIButton *btnProduct;

@property (weak, nonatomic) IBOutlet UIButton *btnService;

@property (weak, nonatomic) IBOutlet UIButton *btnReset;


@property (weak, nonatomic) IBOutlet UIView *viewFIlterData;


@property (weak, nonatomic) IBOutlet UITextField *txtfldWords;

@property (weak, nonatomic) IBOutlet UITextField *txtfldCategory;


@property (weak, nonatomic) IBOutlet UITextField *txtfldLocation;


@property (weak, nonatomic) IBOutlet UIButton *btnMyPromotion;

- (IBAction)clickApply:(id)sender;

- (IBAction)clickCancel:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *viewFilter;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewFilterLeading;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchPromotionHeight;

@property (weak, nonatomic) IBOutlet UISearchBar *searchPromotions;

@property (weak, nonatomic) IBOutlet UIButton *btnAdd;

@property (weak, nonatomic) IBOutlet UILabel *lblTopHeader;


@property (weak, nonatomic) IBOutlet UICollectionView *cvPromotions;

//@property (weak, nonatomic) IBOutlet UITableView *tblPromotions;

@property (weak, nonatomic) IBOutlet UILabel *lblNoPromotion;


//******** Click Event *******

- (IBAction)clickBack:(id)sender;

- (IBAction)clickSearch:(id)sender;

- (IBAction)clickAdd:(id)sender;

- (IBAction)clickMyPromotion:(id)sender;

- (IBAction)clickProduct:(id)sender;

- (IBAction)btnService:(id)sender;

- (IBAction)clickReset:(id)sender;

- (IBAction)clickClear:(id)sender;







@end

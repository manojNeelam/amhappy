//
//  addPromotion.h
//  
//
//  Created by Peerbits MacMini9 on 17/03/16.
//
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "TYMActivityIndicatorViewViewController.h"
#import "SBJSON.h"
#import "SeachAddressmapViewController.h"

@interface addPromotion : UIViewController

{
    
  
    
}

@property (weak, nonatomic) IBOutlet UIButton *btnSave;


@property(nonatomic,assign)BOOL isEdit;

@property(nonatomic,strong)NSString *gettedPromotionID;

@property(nonatomic,assign)BOOL isMyPromotion;

@property (weak, nonatomic) IBOutlet UIView *scrollContentView;

@property (weak, nonatomic) IBOutlet UILabel *lblTopHeader;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollview;

@property (weak, nonatomic) IBOutlet UIImageView *imgPromotion;

@property (weak, nonatomic) IBOutlet UITextField *txtfldPromotionType;

@property (weak, nonatomic) IBOutlet UIButton *bntProduct;

@property (weak, nonatomic) IBOutlet UIButton *bntService;

@property (weak, nonatomic) IBOutlet UITextField *txtfldCompanyName;


@property (weak, nonatomic) IBOutlet UITextField *txtFldDescription;


@property (weak, nonatomic) IBOutlet UITextField *txtfldLocation;


@property (weak, nonatomic) IBOutlet UITextField *txtfldWebsite;


@property (weak, nonatomic) IBOutlet UITextField *txtfldPrice;

@property (weak, nonatomic) IBOutlet UITextField *txtfldDiscount;


@property (weak, nonatomic) IBOutlet UITextField *txtfldStartDate;


@property (weak, nonatomic) IBOutlet UITextField *txtfldEndDate;

@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;


//********* Click Events *******

- (IBAction)clickBack:(id)sender;

- (IBAction)clickSubmit:(id)sender;

- (IBAction)clickProduct:(id)sender;

- (IBAction)clickService:(id)sender;

- (IBAction)clickimgPromotions:(id)sender;

- (IBAction)clickSave:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *lblCompanyHint;
@property (weak, nonatomic) IBOutlet UILabel *lblDescriptionHint;
@property (weak, nonatomic) IBOutlet UILabel *lblWebsiteHint;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_CompanyNameHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_CompanyNameWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_WebsiteHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_WebsiteWidtth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_DescriptionHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_DescriptionWidth;

@property (weak, nonatomic) IBOutlet UIView *baseCamView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *baseViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_width;

@end

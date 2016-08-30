//
//  PromotionCellTableViewCell.h
//  
//
//  Created by Peerbits MacMini9 on 19/03/16.
//
//

#import <UIKit/UIKit.h>

@interface PromotionCellTableViewCell : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *lblPrice;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblPriceWidth;



@property (weak, nonatomic) IBOutlet UILabel *lblDiscount;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblDiscountWidth;


@property (weak, nonatomic) IBOutlet UIImageView *imgPromotion;

@property (weak, nonatomic) IBOutlet UIImageView *imgShadow;

@property (weak, nonatomic) IBOutlet UILabel *lblCompanyname;

@property (weak, nonatomic) IBOutlet UIImageView *imgGreenDot;

@property (weak, nonatomic) IBOutlet UILabel *lblType;

@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

@property (weak, nonatomic) IBOutlet UILabel *lblLocation;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblDescriptionHeight;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblCompanyNameWidth;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblCompanyTop;














@end

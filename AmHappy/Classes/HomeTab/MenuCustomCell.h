//
//  MenuCustomCell.h
//  AmHappy
//
//  Created by Jiten on 05/08/16.
//
//

#import <UIKit/UIKit.h>
#import "MenuData.h"

@interface MenuCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *menuImg;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

-(void)loadData:(MenuData *)aData;

@end

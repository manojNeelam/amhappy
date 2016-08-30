//
//  MenuCustomCell.m
//  AmHappy
//
//  Created by Jiten on 05/08/16.
//
//

#import "MenuCustomCell.h"

@implementation MenuCustomCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)loadData:(MenuData *)aData
{
    [self.lblTitle setText:aData.title];
    [self.menuImg setImage:[UIImage imageNamed:aData.imgName]];
}

@end

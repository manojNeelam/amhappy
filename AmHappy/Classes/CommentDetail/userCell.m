//
//  userCell.m
//  
//
//  Created by Peerbits MacMini9 on 30/03/16.
//
//

#import "userCell.h"

@implementation userCell

- (void)awakeFromNib
{
    // Initialization code
    
    self.imgUser.contentMode = UIViewContentModeScaleAspectFill;
    self.imgUser.clipsToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "MessageCell2.h"

@implementation MessageCell2
@synthesize lblTime,lblMessage,lblDate,imgPointer,imgBg,imgSep1,imgSep2,lblName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_frame.png"]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

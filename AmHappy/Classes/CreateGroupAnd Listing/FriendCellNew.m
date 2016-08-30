//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "FriendCellNew.h"

@implementation FriendCellNew
@synthesize lblName,imgUser,btnAdd;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_frame.png"]];
    }
    return self;
}



- (IBAction)addBtnTapped:(UIButton *)sender
{
    [self.delegate addTapped:sender];
}

@end

//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "FriendCell.h"

@implementation FriendCell
@synthesize lblName,imgUser,btnAdd,btnInvite,btnAccept;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_frame.png"]];
    }
    return self;
}



- (IBAction)addBtnTapped:(id)sender
{
    [self.delegate addTapped:sender];
}
- (IBAction)inviteTapped:(id)sender
{
    [self.delegate inviteTapped:sender];
}

- (IBAction)acceptBtnTapped:(id)sender
{
    [self.delegate accerptTapped:sender];
}
@end

//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "InviteCell.h"

@implementation InviteCell
@synthesize lblName,imgUser,btnReject,btnAccept;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_frame.png"]];
    }
    return self;
}




- (IBAction)acceptBtnTapped:(id)sender
{
    [self.delegate accerptTapped:sender];
}
- (IBAction)rejectButtonTapped:(id)sender
{
    [self.delegate rejectTapped:sender];
}
@end

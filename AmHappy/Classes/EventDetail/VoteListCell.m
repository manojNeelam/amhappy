//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "VoteListCell.h"

@implementation VoteListCell
@synthesize lblName,lblVote,imvEvent,btnVote;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_frame.png"]];
    }
    return self;
}



- (IBAction)voteTapped:(id)sender
{
    [self.delegate voteBtnTapped:sender];
}
@end

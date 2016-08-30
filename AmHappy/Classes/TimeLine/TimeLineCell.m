//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "TimeLineCell.h"

@implementation TimeLineCell

@synthesize lblEventName,lblComment,lblCommentCount,lblDate,lblLikeCount,lblName,lblStatus;
@synthesize btnComment,btnDelete,btnLike,btnReport,btnShare,bgView,imgUser,btnView,lblCellTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_frame.png"]];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        // self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_frame.png"]];
    }
    return self;
}



- (IBAction)shareTapped:(UIButton *)sender
{
    [self.delegate sharePostTapped:sender];
}
- (IBAction)likeTapped:(UIButton *)sender
{
    [self.delegate likePostTapped:sender];
}
- (IBAction)commentTapped:(UIButton *)sender
{
    [self.delegate commentPostTapped:sender];
}
- (IBAction)reportTapped:(UIButton *)sender
{
    [self.delegate reportPostTapped:sender];
}
- (IBAction)deleteTapped:(UIButton *)sender
{
    [self.delegate deletePostTapped:sender];
}
- (IBAction)profileTapped:(UIButton *)sender
{
    [self.delegate profilePostTapped:sender];
}

- (IBAction)nameTapped:(UIButton *)sender
{
    [self.delegate namePostTapped:sender];
}

- (IBAction)eventTapped:(UIButton *)sender
{
    [self.delegate eventPostTapped:sender];
}
@end

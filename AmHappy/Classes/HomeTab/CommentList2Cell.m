//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "CommentList2Cell.h"

@implementation CommentList2Cell
@synthesize lblName,lblDate,lblComment,imgUser,imgComment,btnReport;

@synthesize btnView,btnDelete,btnLike,btnShare,imgBorder,lblLike;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
         
        
    }
    return self;
}



- (IBAction)shareTapped:(UIButton *)sender
{
    [self.delegate shareBtnTapped:sender];
}
- (IBAction)deleteTapped:(UIButton *)sender
{
    [self.delegate deleteBtnTapped:sender];
}

- (IBAction)likeTapped:(UIButton *)sender
{
    [self.delegate likeBtnTapped:sender];
}

- (IBAction)commentBtnTapped:(id)sender;
{
    [self.delegate commentBtnTapped:sender];
    
}

- (IBAction)reportTapped:(UIButton *)sender
{
    [self.delegate reportBtnTapped:sender];
}
@end

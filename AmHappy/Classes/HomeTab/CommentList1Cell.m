//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "CommentList1Cell.h"

@implementation CommentList1Cell
@synthesize imgUser,lblComment,lblDate,lblName;

@synthesize btnDelete,btnLike,btnReport,btnshare,btnView,imgBorder,lblLike;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_frame.png"]];
      
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

- (IBAction)reportTapped:(UIButton *)sender
{
    [self.delegate reportBtnTapped:sender];
}


- (IBAction)commentTapped:(id)sender
{
    [self.delegate commentTapped:sender];
}

- (IBAction)likeTapped:(UIButton *)sender
{
    [self.delegate likeBtnTapped:sender];
}
@end

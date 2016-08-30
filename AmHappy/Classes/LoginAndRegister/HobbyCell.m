//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "HobbyCell.h"

@implementation HobbyCell
@synthesize imgHobby,lblHobbyName,btnCheck;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_frame.png"]];
    }
    return self;
}



- (IBAction)checkTapped:(id)sender
{
    [self.delegate checkBtnTapped:sender];
}
@end

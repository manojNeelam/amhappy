//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "LocationCell2.h"

@implementation LocationCell2
@synthesize lblLocation,lblCellTitle,btnCancel,btnLocation;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_frame.png"]];
    }
    return self;
}
- (IBAction)cancelBtnTapped:(id)sender
{
    [self.delegate cancelTapped:sender];
}
- (IBAction)loocationTapped:(id)sender
{
    [self.delegate locTapped:sender];
}


@end

//
//  RecipeViewCell.m
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "DateCell.h"

@implementation DateCell

@synthesize lblCellTitle,txtDate,txtTime,btnCancel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (IBAction)cancelTapped:(UIButton *)sender
{
    [self.delegate cancelDateTapped:sender];
}
@end

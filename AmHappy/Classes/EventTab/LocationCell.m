//
//  SimpleTableCell.m
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell
{
}
@synthesize lblLocation,lblCellTitle,txtDate,btnCancel,btnLocation;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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

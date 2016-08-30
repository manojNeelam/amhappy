//
//  CustomAlert.m
//  AmHappy
//
//  Created by Peerbits 8 on 07/04/15.
//
//

#import "CustomImageAlert.h"

@implementation CustomImageAlert
@synthesize imgBG,imgEvent,lblTitle;


- (IBAction)backTapped:(UIButton *)sender
{
    [self.delegate backImageTapped:sender];
}

- (IBAction)saveTapped:(UIButton *)sender
{
    [self.delegate saveImageTapped:sender];
}
@end

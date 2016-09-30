//
//  CustomAlert.m
//  AmHappy
//
//  Created by Peerbits 8 on 07/04/15.
//
//

#import "CustomAlert2.h"

@implementation CustomAlert2
@synthesize lblMessage,customView;




- (IBAction)inviteTapped:(id)sender
{
    [self.delegate inviteBtnTapped:sender];
}
- (IBAction)laterTapped:(id)sender
{
    [self.delegate laterBtnTapped:sender];
}

@end

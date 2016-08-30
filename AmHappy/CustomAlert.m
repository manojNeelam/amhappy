//
//  CustomAlert.m
//  AmHappy
//
//  Created by Peerbits 8 on 07/04/15.
//
//

#import "CustomAlert.h"

@implementation CustomAlert
@synthesize lblMessage;



- (IBAction)ok1Tapped:(UIButton *)sender
{
    [self.delegate ok1BtnTapped:sender];
}
- (IBAction)ok2Tapped:(UIButton *)sender
{
    [self.delegate ok2BtnTapped:sender];
}
- (IBAction)cancelTapped:(UIButton *)sender
{
    [self.delegate cancelBtnTapped:sender];
}
@end

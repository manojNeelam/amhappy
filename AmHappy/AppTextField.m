//
//  AppTextField.m
//  AmHappy
//
//  Created by Syntel-Amargoal1 on 7/28/16.
//
//

#import "AppTextField.h"

@implementation AppTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

*/

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self customise];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    UIColor *colour = [UIColor whiteColor];
    if ([self.placeholder respondsToSelector:@selector(drawInRect:withAttributes:)])
    { // iOS7 and later
        NSDictionary *attributes = @{NSForegroundColorAttributeName: colour, NSFontAttributeName: self.font};
        CGRect boundingRect = [self.placeholder boundingRectWithSize:rect.size options:0 attributes:attributes context:nil];
        [self.placeholder drawAtPoint:CGPointMake(0, (rect.size.height/2)-boundingRect.size.height/2) withAttributes:attributes]; }
    else { // iOS 6
        [colour setFill];
        [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
    }
}

-(void)customise
{
    self.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f];
}

-(void)setPaddingViewWithImg:(NSString *)imgName
{
    UIView *basePaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [basePaddingView setBackgroundColor:[UIColor clearColor]];
    
    _paddingBGView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_paddingBGView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.9]];
    [basePaddingView addSubview:_paddingBGView];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 20, 20)];
    [img setImage:[UIImage imageNamed:imgName]];
    [_paddingBGView addSubview:img];
    
    [self setLeftView:basePaddingView];
    [self setLeftViewMode:UITextFieldViewModeAlways];
    [self setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.7]];

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [_paddingBGView setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.8]];

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [_paddingBGView setBackgroundColor:[UIColor greenColor]];
    return YES;
}

@end

//
//  TYMActivityIndicatorViewViewController.h
//  Movie Reviews
//
//  Created by Peerbits MacMini9 on 29/04/15.
//  Copyright (c) 2015 Peerbits MacMini9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYMActivityIndicatorView.h"

@interface TYMActivityIndicatorViewViewController : UIViewController
{
    IBOutlet UITextView *messageLabel;
    
    
    id delegate;
    NSTimeInterval time;
    SEL meth;
    
}
@property (strong, nonatomic) IBOutlet UIView *viewActivity;

@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UIView *viewBack;


@property (nonatomic,strong) TYMActivityIndicatorView *largeActivityIndicatorView;



- (id)initWithDelegate:(id)Class andInterval:(NSTimeInterval)interval andMathod:(SEL)mathod;
- (void)showWithMessage:(NSString *)message backgroundcolor:(UIColor *)color;
- (void) hide;




@end

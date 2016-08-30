//
//  TYMActivityIndicatorViewViewController.m
//  Movie Reviews
//
//  Created by Peerbits MacMini9 on 29/04/15.
//  Copyright (c) 2015 Peerbits MacMini9. All rights reserved.
//

#import "TYMActivityIndicatorViewViewController.h"

@interface TYMActivityIndicatorViewViewController ()

@end

@implementation TYMActivityIndicatorViewViewController
@synthesize viewBack;
@synthesize lblMessage;
@synthesize viewActivity;
@synthesize largeActivityIndicatorView = _largeActivityIndicatorView;

- (id)initWithDelegate:(id)Class andInterval:(NSTimeInterval)interval andMathod:(SEL)mathod {
    self = [super init];
    if (self) {
        delegate = Class;
        time = interval;
        meth = mathod;
    }
    return self;
}

- (TYMActivityIndicatorView *)largeActivityIndicatorView {
    if (!_largeActivityIndicatorView) {
        _largeActivityIndicatorView = [[TYMActivityIndicatorView alloc] initWithActivityIndicatorStyle:TYMActivityIndicatorViewStyleLarge];
        //_largeActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _largeActivityIndicatorView;
}

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)showWithMessage:(NSString *)message backgroundcolor:(UIColor *)color
{

    self.view.frame=CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    
    
    
    self.largeActivityIndicatorView.fullRotationDuration=1.5f;
    [self.largeActivityIndicatorView startAnimating];

    
    //[self.largeActivityIndicatorView  setMinProgressUnit:0.01f];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    [self.view addSubview:viewActivity];
    
    
    self.largeActivityIndicatorView.frame=self.viewActivity.bounds;
    
   
    self.viewBack.frame=CGRectMake(self.viewActivity.frame.origin.x-30,self.viewActivity.frame.origin.y-20,self.viewActivity.frame.size.width+60,self.viewActivity.frame.size.height+60);
    
    [self.viewBack.layer setCornerRadius:15];
    [self.viewBack.layer setMasksToBounds:YES];
    
    if (color)
    {
        [self.viewBack setBackgroundColor:color];
        
    }
    
  
    self.lblMessage.frame=CGRectMake(self.viewBack.frame.origin.x,self.viewActivity.frame.origin.y+self.viewActivity.frame.size.height+10,self.viewBack.frame.size.width,20);
    
    //[lblMessage setBackgroundColor:[UIColor yellowColor]];
    
     [self.lblMessage setText:message];
    
    [self.viewActivity addSubview:self.largeActivityIndicatorView];
  
      [self.view addSubview:self.viewActivity];
    
    
    
    [window addSubview:self.view];
    //[messageLabel setText:message];
    if (meth) {
        [delegate performSelector:meth];
    }
    
    // [self performSelector:@selector(hide) withObject:nil afterDelay:time];
}
//#pragma clang diagnostic pop


- (void) hide {
    // [delegate performSelector:meth];
    [self.largeActivityIndicatorView stopAnimating];
    [self.largeActivityIndicatorView removeFromSuperview];

    [self.view removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

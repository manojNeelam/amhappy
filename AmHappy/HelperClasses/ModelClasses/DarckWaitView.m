//
//  DarckWaitView.m
//  testProject
//
//  Created by Evgeny Kalashnikov on 18.01.11.
//  Copyright 2011 StableFlow. All rights reserved.
//

#import "DarckWaitView.h"
#define degreesToRadian(angle) ((angle) / 180.0 * M_PI)

@implementation DarckWaitView

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithDelegate:(id)Class andInterval:(NSTimeInterval)interval andMathod:(SEL)mathod {
    self = [super init];
    if (self) {
        delegate = Class;
        time = interval;
        meth = mathod;
    }
    return self;
}

- (void) showWithMessage:(NSString *)message{
    //NSLog(@"%@",message);
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
    
    [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    //[view addSubview:self.view];
	[messageLabel setText:message];
    if (meth) {
        [delegate performSelector:meth];
    }
    
   // [self performSelector:@selector(hide) withObject:nil afterDelay:time];
}

-(void)viewDidLoad{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if(orientation == UIDeviceOrientationPortrait){
        
        [lbl setFrame:CGRectMake(109, 226, 102, 21)];
    }
    else{
       
        
        [lbl setFrame:CGRectMake(109, 235, 102, 21)];
        
        // [lbl setFrame:CGRectMake(189, 150, 102, 21)];
    }
}

- (void) hide {
   // [delegate performSelector:meth];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
     [MBProgressHUD hideAllHUDsForView:window animated:YES];
	[self.view removeFromSuperview];
}


- (void)viewDidUnload {
    
    activity = nil;
    
    lbl = nil;
    [super viewDidUnload];
}
@end

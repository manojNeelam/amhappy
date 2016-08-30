//
//  RGSPreviewView.m
//  testColorSlider
//
//  Created by PC on 5/23/16.
//  Copyright © 2016 Randel Smith. All rights reserved.
//

#import "RGSPreviewView.h"

@interface RGSPreviewView ()

@property (nonatomic, strong)UIView *colorView;
@property (nonatomic, strong)UIView *arrowView;
@property (nonatomic, strong) UILabel *trackerLbl;

//18001030405
//7387039679

@end

@implementation RGSPreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _colorView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 3, 3)];
        _colorView.layer.cornerRadius = CGRectGetWidth(_colorView.frame)/2;
       // [self addSubview:_colorView];
        
        _trackerLbl = [[UILabel alloc] init];
        _trackerLbl.frame = CGRectInset(self.bounds, 3, 3);
        [_trackerLbl setTextColor:[UIColor blackColor]];
        [_trackerLbl setBackgroundColor:[UIColor whiteColor]];
        [_trackerLbl setTextAlignment:NSTextAlignmentCenter];
        [_trackerLbl setFont:[UIFont systemFontOfSize:11]];
        _trackerLbl.layer.cornerRadius =  CGRectGetWidth(_trackerLbl.frame)/2;
        [_trackerLbl setClipsToBounds:YES];
        
        [self addSubview:_trackerLbl];
        
        _arrowView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 19, 18)];
        
        CGRect rect = _arrowView.frame;
        rect.origin.y = CGRectGetHeight(self.bounds) - 15;
        rect.origin.x = CGRectGetMidX(self.bounds) - round(CGRectGetWidth(_arrowView.frame)/2);
        _arrowView.frame = rect;
        
        _arrowView.transform = CGAffineTransformMakeRotation(M_PI_2/2);
        _arrowView.layer.cornerRadius = 4;
    
        [self addSubview:_arrowView];
        [self sendSubviewToBack:_arrowView];
    }
    return self;
}

-(void)tintColorDidChange{
    self.backgroundColor = self.tintColor;
    self.arrowView.backgroundColor = self.tintColor;
}

-(void)setColor:(float )color{
    _color = color;
    
    [_trackerLbl setText:[NSString stringWithFormat:@"%0.0f", color]];
    
    [USER_DEFAULTS setInteger:[_trackerLbl.text integerValue] forKey:@"distance"];
    [USER_DEFAULTS synchronize];
    NSLog(@"result is %f",color);
}
@end
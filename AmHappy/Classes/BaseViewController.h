//
//  BaseViewController.h
//  AmHappy
//
//  Created by Syntel-Amargoal1 on 7/28/16.
//
//

#import <UIKit/UIKit.h>
#import "AppTextField.h"


@interface BaseViewController : UIViewController
-(void)resetPaddingBgColor;

@property (nonatomic, strong) UIView *errorBaseView;
@property (nonatomic, strong) UILabel *errorLabel;

-(void)showPopUpwithMsg:(NSString *)msg;

@end

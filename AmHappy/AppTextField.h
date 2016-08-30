//
//  AppTextField.h
//  AmHappy
//
//  Created by Syntel-Amargoal1 on 7/28/16.
//
//

#import <UIKit/UIKit.h>

@interface AppTextField : UITextField <UITextFieldDelegate>
{
    
}

@property (nonatomic, strong) UIView *paddingBGView;
@property (nonatomic, strong) UIImageView *paddingImg;
-(void)setPaddingViewWithImg:(NSString *)imgName;

@end

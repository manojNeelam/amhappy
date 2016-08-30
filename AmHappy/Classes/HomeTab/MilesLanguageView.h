//
//  MilesLanguageView.h
//  AnimationDemo
//
//  Created by Syntel-Amargoal1 on 8/10/16.
//  Copyright © 2016 com.demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGSColorSlider.h"
#import "ModelClass.h"

@protocol MilesLanguageViewDelegate <NSObject>

-(void)onClickCancelButton;
-(void)onClickOkButton:(int)sliderValue;
-(void)onSelectLaunguage:(NSString *)lang withSelectIndex:(int)selectedIndex andSliderValue:(int)sliderValue;

@end

@interface MilesLanguageView : UIView
{
    ModelClass *mc;
    int selectedIndex;
}
@property (nonatomic, assign) id<MilesLanguageViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet UIButton *btnEnglish;
@property (weak, nonatomic) IBOutlet UIButton *btnSpanish;
@property (weak, nonatomic) IBOutlet UIButton *btnChinese;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
- (IBAction)onClickCancelButton:(id)sender;
- (IBAction)onClickOkButton:(id)sender;
@property (weak, nonatomic) IBOutlet RGSColorSlider *distanceSlider;
- (IBAction)onClickEnglishButton:(id)sender;
- (IBAction)onClickSpanishButton:(id)sender;
- (IBAction)onClickChineseButton:(id)sender;
-(void)setCurrentSelectedLang;

@end

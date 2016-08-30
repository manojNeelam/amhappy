//
//  MilesLanguageView.m
//  AnimationDemo
//
//  Created by Syntel-Amargoal1 on 8/10/16.
//  Copyright © 2016 com.demo. All rights reserved.
//

#define Radio_Selected @"radioIcon"
#define Radio_UnSelected @"radioUnSelected"

#import "MilesLanguageView.h"

@implementation MilesLanguageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        
        mc=[[ModelClass alloc] init];
        mc.delegate =self;
        selectedIndex =-1;
        
        
    }
    return self;
}

-(void)setCurrentSelectedLang
{
    //[USER_DEFAULTS setObject:@"E" forKey:@"localization"];
    NSString *lang = [USER_DEFAULTS objectForKey:@"localization"];
    if ([lang isEqualToString:@"C"])
    {
        [self chineseSelected];
    }
    else if ([lang isEqualToString:@"S"])
    {
        [self spanishSelected];
    }
    else
    {
        [self englishSelected];
    }
}

- (IBAction)onClickCancelButton:(id)sender
{
    [self.delegate onClickCancelButton];
}

- (IBAction)onClickOkButton:(id)sender {
    [self.delegate onClickOkButton:(int)self.distanceSlider.value];
}

- (IBAction)onClickEnglishButton:(id)sender {
    
    
    [self englishSelected];
    
    //selectedIndex = 0;
    /*[mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:@"E" search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Event_notification:nil Comment_notification:nil Sel:@selector(responseLanguageChanged1:)];*/
    [self.delegate onSelectLaunguage:@"E" withSelectIndex:0 andSliderValue:(int)self.distanceSlider.value];
}

- (IBAction)onClickSpanishButton:(id)sender {
    
    [self spanishSelected];
    
//    selectedIndex = 1;
//    [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:@"S" search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Event_notification:nil Comment_notification:nil Sel:@selector(responseLanguageChanged1:)];
    
    [self.delegate onSelectLaunguage:@"S" withSelectIndex:1 andSliderValue:(int)self.distanceSlider.value];


}

- (IBAction)onClickChineseButton:(id)sender {
    
    [self chineseSelected];
    
    
    [self.delegate onSelectLaunguage:@"C" withSelectIndex:2 andSliderValue:(int)self.distanceSlider.value];

    
//    selectedIndex = 2;
//    [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:@"C" search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Event_notification:nil Comment_notification:nil Sel:@selector(responseLanguageChanged1:)];
}

-(void)englishSelected
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        [self.btnChinese setImage:[UIImage imageNamed:Radio_UnSelected] forState:UIControlStateNormal];
        [self.btnSpanish setImage:[UIImage imageNamed:Radio_UnSelected] forState:UIControlStateNormal];
        [self.btnEnglish setImage:[UIImage imageNamed:Radio_Selected] forState:UIControlStateNormal];
    });
    
}

-(void)spanishSelected
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        [self.btnChinese setImage:[UIImage imageNamed:Radio_UnSelected] forState:UIControlStateNormal];
        [self.btnEnglish setImage:[UIImage imageNamed:Radio_UnSelected] forState:UIControlStateNormal];
        [self.btnSpanish setImage:[UIImage imageNamed:Radio_Selected] forState:UIControlStateNormal];
    });
    
    
}

-(void)chineseSelected
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        [self.btnEnglish setImage:[UIImage imageNamed:Radio_UnSelected] forState:UIControlStateNormal];
        [self.btnSpanish setImage:[UIImage imageNamed:Radio_UnSelected] forState:UIControlStateNormal];
        [self.btnChinese setImage:[UIImage imageNamed:Radio_Selected] forState:UIControlStateNormal];
    });
    
   
}

@end

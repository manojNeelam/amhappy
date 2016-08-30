//
//  CustomAlert.h
//  AmHappy
//
//  Created by Peerbits 8 on 07/04/15.
//
//

#import <UIKit/UIKit.h>

@protocol CustomImageAlertDelegate <NSObject>
@optional
- (void)backImageTapped:(id)sender;
- (void)saveImageTapped:(id)sender;


@end

@interface CustomImageAlert : UIView<UIScrollViewDelegate,UIGestureRecognizerDelegate>

- (IBAction)backTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgBG;
@property (weak, nonatomic) IBOutlet UIImageView *imgEvent;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (nonatomic, strong) id <CustomImageAlertDelegate> delegate;


@end

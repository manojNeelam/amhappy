//
//  CustomAlert.h
//  AmHappy
//
//  Created by Peerbits 8 on 07/04/15.
//
//

#import <UIKit/UIKit.h>

@protocol CustomAlertDelegate2 <NSObject>
@optional
- (void)inviteBtnTapped:(id)sender;
- (void)laterBtnTapped:(id)sender;

@end

@interface CustomAlert2 : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
- (IBAction)inviteTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
- (IBAction)laterTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLater;
@property (weak, nonatomic) IBOutlet UIView *customView;

@property (nonatomic, strong) id <CustomAlertDelegate2> delegate;


@end

//
//  CustomAlert.h
//  AmHappy
//
//  Created by Peerbits 8 on 07/04/15.
//
//

#import <UIKit/UIKit.h>

@protocol CustomAlertDelegate <NSObject>
@optional
- (void)ok1BtnTapped:(id)sender;
- (void)ok2BtnTapped:(id)sender;
- (void)cancelBtnTapped:(id)sender;


@end

@interface CustomAlert : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
- (IBAction)ok1Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnOk1;
- (IBAction)ok2Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnOk2;
- (IBAction)cancelTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIView *customView;

@property (nonatomic, strong) id <CustomAlertDelegate> delegate;


@end

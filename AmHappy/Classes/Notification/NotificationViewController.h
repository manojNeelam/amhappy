//
//  NotificationViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 02/09/15.
//
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController<CustomAlertDelegate>
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAll;
@property (weak, nonatomic) IBOutlet UILabel *lblEvent;
@property (weak, nonatomic) IBOutlet UILabel *lblComment;
- (IBAction)allChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switchAll;
- (IBAction)eventChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switchEvent;
- (IBAction)commentChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switchComment;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)saveTapped:(id)sender;

@end

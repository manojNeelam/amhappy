//
//  Guests.h
//  AmHappy
//
//  Created by Peerbits MacMini9 on 01/12/15.
//
//

#import <UIKit/UIKit.h>

@interface Guests : UIViewController


@property (strong, nonatomic) IBOutlet UILabel *lblTitle;


@property(nonatomic,strong)NSString *eventId;

@property(nonatomic,assign)BOOL isMyEvent;

@property(nonatomic,assign)BOOL is_admin;

@property(nonatomic,assign)BOOL is_expired;





@property (strong, nonatomic) IBOutlet UITableView *tblVIew;

@property (strong, nonatomic) IBOutlet UIButton *btnAdd;

@property (strong, nonatomic) IBOutlet UIView *viewButtons;

//********* Invite by Email Pop-Up -------

@property (strong, nonatomic) IBOutlet UIView *viewEmailPopUp;
@property (strong, nonatomic) IBOutlet UIView *viewbackgroundPopUp;

@property (strong, nonatomic) IBOutlet UITextField *txtlfldEmail;

@property (strong, nonatomic) IBOutlet UIButton *btnCancel;

@property (strong, nonatomic) IBOutlet UIButton *btnSend;

- (IBAction)cancelClicked:(id)sender;

- (IBAction)sendClicked:(id)sender;


//**************



- (IBAction)clickMail:(id)sender;

- (IBAction)clickGroup:(id)sender;

- (IBAction)clickamHappyUsers:(id)sender;


- (IBAction)clickBack:(id)sender;

- (IBAction)clickAdd:(id)sender;



@end

//
//  LoginViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import "LoginViewController.h"
//#import <FacebookSDK/FacebookSDK.h>
#import "TYMActivityIndicatorViewViewController.h"
#import "ModelClass.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "UserVerificationViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "HobbiyViewController.h"


@interface LoginViewController ()
@property (nonatomic, strong) AppTextField *activeTxtFld;
@end

@implementation LoginViewController
{
    ModelClass *mc;
    TYMActivityIndicatorViewViewController *drk;
    
    UIToolbar *mytoolbar1;
}
@synthesize txtPasswd,txtUser,btnForget,btnGo,btnRegister,scrollview,imgSeprator,imgOr;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    [self customiseTxtFlds];
    
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:TwitteAppKEY andSecret:TwitteAppSecretId];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
    
    self.txtPasswd.delegate =self;
    self.txtUser.delegate =self;
    
    mytoolbar1 = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    mytoolbar1.barStyle = UIBarStyleBlackOpaque;
    if(IS_OS_7_OR_LATER)
    {
        mytoolbar1.barTintColor=[UIColor colorWithRed:228.0/255.0 green:123.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    else
    {
        mytoolbar1.tintColor=[UIColor colorWithRed:228.0/255.0 green:123.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    
   

    UIBarButtonItem *done1 = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Done"]
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self action:@selector(donePressed)];
    [done1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Next"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self action:@selector(nextPressed)];
    [next setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Previous"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self action:@selector(previousPressed)];
    [prev setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    mytoolbar1.items = [NSArray arrayWithObjects:prev,next,flexibleSpace,done1, nil];
    
    //self.txtPasswd.inputAccessoryView =mytoolbar1;
    //self.txtUser.inputAccessoryView =mytoolbar1;


    if(IS_IPHONE_6 || IS_IPHONE_6_PLUS || IS_Ipad)
    {
        [self.scrollview setContentSize:CGSizeMake(320, 100)];

    }
   
    else
    {
        [self.scrollview setContentSize:CGSizeMake(320, 600)];

    }
    
    
    
    [GPPSignIn sharedInstance].clientID = GOOGLEKEY;
    [GPPSignIn sharedInstance].scopes= [NSArray arrayWithObjects:kGTLAuthScopePlusLogin, nil];
    [GPPSignIn sharedInstance].shouldFetchGoogleUserID=YES;
    [GPPSignIn sharedInstance].shouldFetchGoogleUserEmail=YES;
    [GPPSignIn sharedInstance].delegate=self;
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[DELEGATE setWindowRoot];
}

-(void)customiseTxtFlds
{
    [self.txtUser setPaddingViewWithImg:@"userLogo"];
    [self.txtPasswd setPaddingViewWithImg:@"passwordLogo"];
    
    [self.txtUser.paddingBGView setBackgroundColor:[UIColor colorWithRed:117/255.0f green:171/255.0f blue:35/255.0f alpha:1.0f]];
    [self.btnForget setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8] forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
}

-(void)localize
{
    
    NSLog(@"local language is %@",[USER_DEFAULTS valueForKey:@"localization"] );
    if ([self.txtPasswd respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.txtPasswd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[localization localizedStringForKey:@"Password"] attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    
    if ([self.txtUser respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        self.txtUser.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[localization localizedStringForKey:@"Email"] attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    
    [self.txtUser setPlaceholder:[localization localizedStringForKey:@"Email"]];
    [self.txtPasswd setPlaceholder:[localization localizedStringForKey:@"Password"]];

    [self.btnForget setTitle:[localization localizedStringForKey:@"Forgot Password?"] forState:UIControlStateNormal];
    [self.btnGo setTitle:[localization localizedStringForKey:@"Sign In"] forState:UIControlStateNormal];
    [self.btnRegister setTitle:[localization localizedStringForKey:@"Sign Up"] forState:UIControlStateNormal];
    [self.btnForget.titleLabel adjustsFontSizeToFitWidth];
    [self.btnForget.titleLabel setMinimumScaleFactor:0.5];
    [self.btnForget.titleLabel setNumberOfLines:1.0];
    [self.btnForget.titleLabel sizeToFit];
    
    
    CGSize stringsize = [[localization localizedStringForKey:@"Forgot Password?"] sizeWithFont:[UIFont systemFontOfSize:12]];
    float width = stringsize.width;
    
    float value =(self.view.frame.size.width/2)- (width/2);

    CGPoint centerbtn = self.btnForget.center;

    
    self.btnForget.frame =CGRectMake(self.btnForget.frame.origin.x, self.btnForget.frame.origin.y, width, self.btnForget.frame.size.height);
    self.btnForget.center =centerbtn;
    
    CGPoint centerImageView = self.imgSeprator.center;

     self.imgSeprator.frame =CGRectMake(self.imgSeprator.frame.origin.x, self.imgSeprator.frame.origin.y, width-20, self.imgSeprator.frame.size.height);
    self.imgSeprator.center =centerImageView;
    
    if([USER_DEFAULTS valueForKey:@"localization"])
    {
        if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"S"])
        {
            [localization setLanguage:@"SP"];
            
            [self.imgOr setImage:[UIImage imageNamed:@"or2.png"]];
        }
        else if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"C"])
        {
            [localization setLanguage:@"CH"];
            [self.imgOr setImage:[UIImage imageNamed:@"or3.png"]];

        }
        else
        {
            [localization setLanguage:@"EN"];
            [self.imgOr setImage:[UIImage imageNamed:@"or.png"]];

        }
    }
    



    
    
}
-(void)nextPressed
{
    
    if ([txtUser isFirstResponder])
    {
        [txtPasswd becomeFirstResponder];
        return;
    }
    
}
-(void)previousPressed
{
    if ([txtPasswd isFirstResponder])
    {
        [txtUser becomeFirstResponder];
        return;
    }
    
}

-(void)donePressed
{
    [self.view endEditing:YES];
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self resetPaddingBgColor];
    _activeTxtFld = (AppTextField *)textField;
    [_activeTxtFld.paddingBGView setBackgroundColor:[UIColor colorWithRed:117/255.0f green:171/255.0f blue:35/255.0f alpha:1.0f]];
    [_activeTxtFld setTextColor:[UIColor colorWithRed:117/255.0f green:171/255.0f blue:35/255.0f alpha:1.0f]];
    
    if(textField == self.txtUser)
    {
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [_activeTxtFld setTextColor:[UIColor whiteColor]];
    
   /* if(textField==self.txtUser )
    {
        [self.imgUser setImage:[UIImage imageNamed:@"user.png"]];
    }
    else if(textField==self.txtPassword )
    {
        [self.imgPassword setImage:[UIImage imageNamed:@"lock.png"]];
    }*/
    // [self animateTextField: textField up: NO];
    
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    
    return [super canPerformAction:action withSender:sender];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

-(BOOL)checkValidation
{
    
    NSString *userId = [self.txtUser.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passwd = [self.txtPasswd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    if([userId length] <= 0 || [passwd length]<= 0 )
    {
        if(userId.length <=0 )
        {
            [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter email address."]];
            
           /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter Email"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
            [alert show];*/
            //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter email address."] AlertFlag:1 ButtonFlag:1];
            return FALSE;
        }
        else  if(passwd.length <=0)
        {
            
           /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter Password"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
            [alert show];*/
            
            [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter Password."]];
            
            //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter Password"] AlertFlag:1 ButtonFlag:1];

            return FALSE;
        }
        else
        {
            return TRUE;
        }
        
    }
    else
    {
        return TRUE;
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)twitterTapped:(id)sender
{
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
        [self listResults];
        
    }];
    [self presentViewController:loginController animated:YES completion:nil];
}

-(void)listResults {
   
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSDictionary *temp = [[NSDictionary alloc]initWithDictionary:[[FHSTwitterEngine sharedEngine]verifyCredentials]];
    NSLog(@"twitter data are %@",temp);
   
    
    if(DELEGATE.connectedToNetwork)
    {
        
        [mc loginTwitterUser:[temp valueForKey:@"id"] Fullname:[temp valueForKey:@"name"] Username:[temp valueForKey:@"name"] Email_id:nil Twitter_image:[temp valueForKey:@"profile_image_url"] Gender:nil Dob:nil Device_id:DELEGATE.tokenstring Sel:@selector(responseLoginTwitterUser:)];
       
    }
    
    
}
-(void)responseLoginTwitterUser:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"userid"] forKey:@"userid"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"jid"] forKey:@"myjid"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"fullname"] forKey:@"fullname"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"language"] forKey:@"language"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"recieve_push"] forKey:@"recieve_push"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"search_miles"] forKey:@"distance"];
        [USER_DEFAULTS setObject:[[results valueForKey:@"User"] valueForKey:@"language"] forKey:@"localization"];
        
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"comment_notification"] forKey:@"comment_notification"];
        
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"event_notification"] forKey:@"event_notification"];

        
        [USER_DEFAULTS synchronize];
        
        if([[[results valueForKey:@"User"] valueForKey:@"language"] isEqualToString:@"S"])
        {
            [localization setLanguage:@"SP"];
        }
        else if([[[results valueForKey:@"User"] valueForKey:@"language"] isEqualToString:@"C"])
        {
            [localization setLanguage:@"CH"];
        }
        else
        {
            [localization setLanguage:@"EN"];
        }
        NSLog(@"user id is %@",[USER_DEFAULTS valueForKey:@"userid"]);

        if([[[results valueForKey:@"User"] valueForKey:@"is_exist"] isEqualToString:@"N"])
        {
            UserVerificationViewController *userVC =[[UserVerificationViewController alloc] initWithNibName:@"UserVerificationViewController" bundle:nil];
            [self.navigationController pushViewController:userVC animated:YES];
        }
        else if([[[results valueForKey:@"User"] valueForKey:@"is_exist"] isEqualToString:@"Y"] )
        {
            [USER_DEFAULTS setValue:@"yes" forKey:@"updated"];
            [USER_DEFAULTS synchronize];

            [DELEGATE setWindowRoot];
            
        }
        else
        {
            
            UserVerificationViewController *userVC =[[UserVerificationViewController alloc] initWithNibName:@"UserVerificationViewController" bundle:nil];
            [self.navigationController pushViewController:userVC animated:YES];

        }
        
        
        
    }
    else
    {
        
        [self showPopUpwithMsg:[results valueForKey:@"message"]];
        
        //[DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
}
#pragma mark Twitter Methods
- (void)storeAccessToken:(NSString *)accessToken {
    [USER_DEFAULTS setObject:accessToken forKey:@"SavedAccessHTTPBody"];
    [USER_DEFAULTS synchronize];
}

- (NSString *)loadAccessToken
{
    return [USER_DEFAULTS objectForKey:@"SavedAccessHTTPBody"];
}

- (IBAction)googleTapped:(id)sender
{
    //[self animateButton:sender];
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    [[GPPSignIn sharedInstance] authenticate];
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error
{
    [drk hide];
    if (!error)
    {
         NSLog(@"userEmail is %@",[GPPSignIn sharedInstance].userEmail);
         NSLog(@"userEmail is %@",[GPPSignIn sharedInstance].userID);
        
        
      /* GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:[GPPSignIn sharedInstance].userID];
         GTLServicePlus* plusService = [[GTLServicePlus alloc] init] ;
         plusService.retryEnabled = YES;
         
         // 2. Set a valid |GTMOAuth2Authentication| object as the authorizer.
         [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
         
         // 3. Use the "v1" version of the Google+ API.*
         plusService.apiVersion = @"v1";
         [plusService executeQuery:query
         completionHandler:^(GTLServiceTicket *ticket,
         GTLPlusPerson *person,
         NSError *error)
        {
         if (error)
         {
             NSLog(@"error is %@",error.localizedDescription);
         }
         else
         {
         NSLog(@"Email= %@", [GPPSignIn sharedInstance].authentication.userEmail);
         NSLog(@"GoogleID=%@", person.identifier);
         NSLog(@"User Name=%@", person.name);
         NSLog(@"Gender=%@", person.gender);
         }
         }];*/
        
        
        if(DELEGATE.connectedToNetwork)
        {
            
            [mc loginGoogleUser:[GPPSignIn sharedInstance].userID Fullname:nil Username:nil Email_id:[GPPSignIn sharedInstance].userEmail Google_image:nil Gender:nil Dob:nil Device_id:DELEGATE.tokenstring Sel:@selector(responseLoginFBUser:)];
        }
    }
    else
    {
        [self showPopUpwithMsg:error.localizedDescription];
        
        //[DELEGATE showalert:self Message:error.localizedDescription AlertFlag:1 ButtonFlag:1];
      
    }
}
-(void)responseLoginGoogleUser:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"userid"] forKey:@"userid"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"jid"] forKey:@"myjid"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"fullname"] forKey:@"fullname"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"language"] forKey:@"language"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"recieve_push"] forKey:@"recieve_push"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"search_miles"] forKey:@"distance"];
        [USER_DEFAULTS setObject:[[results valueForKey:@"User"] valueForKey:@"language"] forKey:@"localization"];
        
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"comment_notification"] forKey:@"comment_notification"];
        
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"event_notification"] forKey:@"event_notification"];

        
        [USER_DEFAULTS synchronize];
        
        if([[[results valueForKey:@"User"] valueForKey:@"language"] isEqualToString:@"S"])
        {
            [localization setLanguage:@"SP"];
        }
        else if([[[results valueForKey:@"User"] valueForKey:@"language"] isEqualToString:@"C"])
        {
            [localization setLanguage:@"CH"];
        }
        else
        {
            [localization setLanguage:@"EN"];
        }
        
        if([[[results valueForKey:@"User"] valueForKey:@"is_exist"] isEqualToString:@"N"])
        {
            UserVerificationViewController *userVC =[[UserVerificationViewController alloc] initWithNibName:@"UserVerificationViewController" bundle:nil];
            [self.navigationController pushViewController:userVC animated:YES];
        }
        else if([[[results valueForKey:@"User"] valueForKey:@"is_exist"] isEqualToString:@"Y"] )
        {
            [USER_DEFAULTS setValue:@"yes" forKey:@"updated"];
            [USER_DEFAULTS synchronize];

            [DELEGATE setWindowRoot];
            
        }
        else
        {
            
            UserVerificationViewController *userVC =[[UserVerificationViewController alloc] initWithNibName:@"UserVerificationViewController" bundle:nil];
            [self.navigationController pushViewController:userVC animated:YES];
            
        }

       
        
        // [DELEGATE setWindowRoot];
        
    }
    else
    {
        [self showPopUpwithMsg:[results valueForKey:@"message"]];
        
        //[DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

       /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
}
-(void)getFBData:(NSDictionary *)fbdata
{
    NSLog(@"userdata is %@",fbdata);
    /*
     "first_name" = Ronit;
     gender = male;
     id = 331012533776314;
     "last_name" = Patel;
     link = "https://www.facebook.com/app_scoped_user_id/331012533776314/";
     locale = "en_US";
     name = "Ronit Patel";
     timezone = "5.5";
     "updated_time" = "2014-06-30T15:28:58+0000";
     verified = 1;
     */
    [drk hide];
    if(DELEGATE.connectedToNetwork)
    {
        NSString *gender=[[NSString alloc] init];
        
        if ([fbdata valueForKey:@"gender"])
        {
            if([[fbdata valueForKey:@"gender"] isEqualToString:@"male"])
            {
                gender =@"M";
            }
            else
            {
                gender =@"F";
                
            }
            
        }

       // [mc loginFBUser:[fbdata valueForKey:@"id"] Fullname:[fbdata valueForKey:@"name"] Username:[fbdata valueForKey:@"first_name"] Email_id:nil Facebook_image:nil Gender:gender Dob:nil Device_id:DeviceId Sel:@selector(responseLoginFBUser:)];
        [mc loginFBUser:[fbdata valueForKey:@"id"] Fullname:[fbdata valueForKey:@"name"] Username:[fbdata valueForKey:@"first_name"] Email_id:nil Facebook_image:nil Gender: gender != nil ? gender : nil Dob:nil Device_id:DELEGATE.tokenstring Sel:@selector(responseLoginFBUser:)];
    }
}

-(void)responseLoginFBUser:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"userid"] forKey:@"userid"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"jid"] forKey:@"myjid"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"fullname"] forKey:@"fullname"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"language"] forKey:@"language"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"recieve_push"] forKey:@"recieve_push"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"search_miles"] forKey:@"distance"];
        [USER_DEFAULTS setObject:[[results valueForKey:@"User"] valueForKey:@"language"] forKey:@"localization"];
        
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"comment_notification"] forKey:@"comment_notification"];
        
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"event_notification"] forKey:@"event_notification"];

        
        [USER_DEFAULTS synchronize];
        
        if([[[results valueForKey:@"User"] valueForKey:@"language"] isEqualToString:@"S"])
        {
            [localization setLanguage:@"SP"];
        }
        else if([[[results valueForKey:@"User"] valueForKey:@"language"] isEqualToString:@"C"])
        {
            [localization setLanguage:@"CH"];
        }
        else
        {
            [localization setLanguage:@"EN"];
        }
       
        if([[[results valueForKey:@"User"] valueForKey:@"is_exist"] isEqualToString:@"N"])
        {
            UserVerificationViewController *userVC =[[UserVerificationViewController alloc] initWithNibName:@"UserVerificationViewController" bundle:nil];
            [self.navigationController pushViewController:userVC animated:YES];
        }
      //  else if([[[results valueForKey:@"User"] valueForKey:@"is_exist"] isEqualToString:@"Y"] && [USER_DEFAULTS valueForKey:@"updated"])
        else if([[[results valueForKey:@"User"] valueForKey:@"is_exist"] isEqualToString:@"Y"] )
        {
            [USER_DEFAULTS setValue:@"yes" forKey:@"updated"];
            [USER_DEFAULTS synchronize];
            [DELEGATE setWindowRoot];
            
        }
        else
        {
            
            UserVerificationViewController *userVC =[[UserVerificationViewController alloc] initWithNibName:@"UserVerificationViewController" bundle:nil];
            [self.navigationController pushViewController:userVC animated:YES];
            
        }

        
        
          //  [DELEGATE setWindowRoot];
        
    }
    else
    {
        [self showPopUpwithMsg:[results valueForKey:@"message"]];
        
        //[DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
}
- (IBAction)goTapped:(id)sender
{
    [self animateButton:sender];
    [self.view endEditing:YES];
    if([self checkValidation])
    {
        if([DELEGATE validateEmail:self.txtUser.text])
        {
            if(DELEGATE.connectedToNetwork)
            {
                //[mc loginUser:self.txtUser.text Password:self.txtPasswd.text Device_id:DeviceId Sel:@selector(responseLoginUser:)];
                
                 [mc loginUser:self.txtUser.text Password:self.txtPasswd.text Device_id:DELEGATE.tokenstring Sel:@selector(responseLoginUser:)];
            }
        }
        else
        {
            [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter valid Email"]];
            
            //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter valid Email"] AlertFlag:1 ButtonFlag:1];

           /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter valid Email"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
            [alert show];*/
        }
    }
}

-(void)responseLoginUser:(NSDictionary *)results
{
      NSLog(@"result is %@",results);
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [USER_DEFAULTS setObject:self.txtUser.text forKey:@"email_address"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"userid"] forKey:@"userid"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"jid"] forKey:@"myjid"];
        [USER_DEFAULTS setValue:@"yes" forKey:@"updated"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"fullname"] forKey:@"fullname"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"language"] forKey:@"language"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"recieve_push"] forKey:@"recieve_push"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"search_miles"] forKey:@"distance"];
        
        [USER_DEFAULTS setObject:[[results valueForKey:@"User"] valueForKey:@"language"] forKey:@"localization"];

        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"comment_notification"] forKey:@"comment_notification"];

         [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"event_notification"] forKey:@"event_notification"];

        [USER_DEFAULTS synchronize];
        
        
        if([[[results valueForKey:@"User"] valueForKey:@"language"] isEqualToString:@"S"])
        {
            [localization setLanguage:@"SP"];
        }
        else if([[[results valueForKey:@"User"] valueForKey:@"language"] isEqualToString:@"C"])
        {
            [localization setLanguage:@"CH"];
        }
        else
        {
            [localization setLanguage:@"EN"];
        }
        
         [DELEGATE setWindowRoot];
        
    }
    else
    {
        [self showPopUpwithMsg:[results valueForKey:@"message"]];
        
         //[DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
      /*  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
    
}

- (IBAction)forgetPasswdTapped:(id)sender
{
    
    ForgotPasswordViewController *forgotPasswordVC =[[ForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:forgotPasswordVC animated:YES];
    
    
    /*UIAlertView  *av = [[UIAlertView alloc]initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Enter Email"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Send"], nil];
    
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[av textFieldAtIndex:0] setPlaceholder:[localization localizedStringForKey:@"Email"]];
    [[av textFieldAtIndex:0] setDelegate:self];
    [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeEmailAddress];
    [av setTag:2];
    [av show];*/
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([alertView tag]==2)
    {
        if (buttonIndex == 1)
        {
            
            NSString *email = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([email length] > 0 && [DELEGATE validateEmail:email])
            {
                if(DELEGATE.connectedToNetwork)
                {
                    [mc forgotPassword:[alertView textFieldAtIndex:0].text Sel:@selector(responsePasswd:)];
                }
            }
            else
            {
                
                [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter valid email address."]];
                
                //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter valid email address."] AlertFlag:1 ButtonFlag:1];
                
              /*  UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter valid Email"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil];
                [al show];*/
            }
            
            
        }
    }
    
}
-(void)responsePasswd:(NSDictionary *)results
{
   
    UIAlertView  *av = [[UIAlertView alloc]initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
    [av show];
}
- (IBAction)registerTapped:(id)sender
{
   registrationVC =[[RegistrationViewController alloc] initWithNibName:@"RegistrationViewController" bundle:nil];
    [registrationVC setIsEdit:NO];
     [registrationVC setIsMy:YES];
    [self.navigationController pushViewController:registrationVC animated:YES];
}
- (IBAction)fbTapped:(id)sender
{
//    
//    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
//    if([DELEGATE connectedToNetwork])
//    {
//        //@[@"public_profile",@"manage_friendlists",@"user_friends"]
//        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"basic_info",@"public_profile",@"user_friends"]
//                                           allowLoginUI:YES
//                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//                                          
//                                          switch (state) {
//                                              case FBSessionStateOpen:
//                                              {
//                                                  [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
//                                                      if (error) {
//                                                          
//                                                          NSLog(@"error:%@",error);
//                                                          
//                                                          
//                                                      }
//                                                      else
//                                                      {
//                                                          // retrive user's details at here as shown below
//                                                          /*   NSLog(@"FB user first name:%@",user.first_name);
//                                                           NSLog(@"FB user last name:%@",user.last_name);
//                                                           NSLog(@"FB user birthday:%@",user.birthday);
//                                                           NSLog(@"FB user location:%@",user.location);
//                                                           NSLog(@"FB user username:%@",user.username);
//                                                           NSLog(@"FB user gender:%@",[user objectForKey:@"gender"]);
//                                                           NSLog(@"email id:%@",[user objectForKey:@"email"]);
//                                                           NSLog(@"location:%@", [NSString stringWithFormat:@"Location: %@\n\n",
//                                                           user.location[@"name"]]);*/
//                                                          [self getFBData:user];
//                                                          [FBSession setActiveSession:session];
//                                                          
//                                                      }
//                                                  }];
//                                                  break;
//                                              }
//                                                  
//                                              case FBSessionStateClosed:
//                                              {
//                                                  [drk hide];
//                                              }
//                                              case FBSessionStateClosedLoginFailed:
//                                              {
//                                                  [drk hide];
//                                                  [FBSession.activeSession closeAndClearTokenInformation];
//                                                  break;
//                                              }
//                                                  
//                                              default:
//                                                  break;
//                                          }
//                                          
//                                      } ];
//    }
//    [drk hide];
//
    
    
    //[self animateButton:sender];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    
    [login logInWithReadPermissions:@[@"public_profile"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error)
        {
            [[[UIAlertView alloc]initWithTitle:nil message:@"Could not connect to facebook now" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show ];
            
        } else if (result.isCancelled)
        {
            // Handle cancellations
            
            
        } else
        {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
           
                NSLog(@"%@",result);
                
                [self loginWithFb];
            
        }
    }];

}

-(void)loginWithFb
{
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error)
        {
            [[[UIAlertView alloc]initWithTitle:nil message:@"Could not connect to facebook now" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show ];
        }
        else
        {
            
            NSLog(@"%@",result);
            
            [self getFBData:result];
            
//            userDataFB=[[NSMutableDictionary alloc]initWithDictionary:result];
//            
//            NSLog(@"%@",userDataFB);
//            
//            strFBID=[NSString stringWithFormat:@"%@",[result valueForKey:@"id"]];
//            strFBemail=[NSString stringWithFormat:@"%@",[result valueForKey:@"email"]];
//            name=[NSString stringWithFormat:@"%@",[result valueForKey:@"name"]];
//            
//            [mc CheckuserStatus:@"" facebookid:[NSString stringWithFormat:@"%@",strFBID] selector:@selector(ResponseCheckuserStatus:)];
            
            
        }
    }];
    
}
-(void)ok1BtnTapped:(id)sender
{
   // NSLog(@"ok1BtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];

}
-(void)ok2BtnTapped:(id)sender
{
   // NSLog(@"ok2BtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];

}
-(void)cancelBtnTapped:(id)sender
{
    //NSLog(@"cancelBtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];

}

-(void)animateButton:(UIButton*)animateBtn
{
    [UIView animateWithDuration:0.8 animations:^{
        animateBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
        //[self resetButton:animateBtn];
        [self performSelector:@selector(resetButton:) withObject:animateBtn afterDelay:0.1];
    }];
}

-(void)resetButton:(UIButton *)animateBtn
{
    [UIView animateWithDuration:0.8 animations:^{
        animateBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

/*
 -(IBAction)expand{//touch down
 
 
 NSLog(@"expand");
 
 [UIView transitionWithView:but duration:0.0 options:UIViewAnimationOptionTransitionNone animations:^(void) {
 
 
 CGRect newRect = but.frame;
 
 CGPoint ce= but.center;
 newRect.size.width *= 5;
 
 but.frame = newRect;
 
 but.center=ce;
 
 
 
 } completion:^(BOOL finished) {
 
 
 
 }];
 
 
 }
 
 -(IBAction)shrink{//touch up inside
 NSLog(@"shrink");
 
 
 [UIView transitionWithView:but duration:0.0 options:UIViewAnimationOptionTransitionNone animations:^(void) {
 
 
 CGRect newRect = but.frame;
 
 CGPoint ce= but.center;
 newRect.size.width /= 5;
 
 but.frame = newRect;
 
 but.center=ce;
 
 
 
 } completion:^(BOOL finished) {
 
 
 
 }];
 
 
 }
 */

@end

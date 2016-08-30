//
//  SettingTabViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import "SettingTabViewController.h"
#import "MyEventsViewController.h"
#import "ModelClass.h"
#import "ReachUsViewController.h"
#import "RegistrationViewController.h"
#import "LoginViewController.h"
#import "FriendRequestViewController.h"
#import "HomeTabViewController.h"
#import "BlockedUserViewController.h"
#import "NotificationViewController.h"

#import "TimeLineViewController.h"
#import "addPromotion.h"
#import "PromotionListing.h"





@interface SettingTabViewController ()

@end

@implementation SettingTabViewController
{
    ModelClass *mc;
    int selectedIndex;
    int actionTag;

}
@synthesize lblTitle,lblAppVersion,lblDistance,distanceSlider;
@synthesize btnLanguage,btnLogout,btnProfile,btnReport,btnSave,lblLanguage;

@synthesize lblCurrent,currentdistanceView;

@synthesize btnNotification,btnVersion,lblLogout,lblProfike,lblPush,lblReport;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
        {
            
            [self tabBarItem].selectedImage = [[UIImage imageNamed:@"sTab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self tabBarItem].image = [[UIImage imageNamed:@"sTab2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else
        {
            [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"sTab.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"sTab2.png"]];
        }
        
    }
    self.title =[localization localizedStringForKey:@"Settings"];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [self.btnVersion setTitle:version forState:UIControlStateNormal];

    mc=[[ModelClass alloc] init];
    mc.delegate =self;
    selectedIndex =-1;
    actionTag=0;
    self.lblAppVersion.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    

    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
   if([USER_DEFAULTS valueForKey:@"distance"])
    {
        self.distanceSlider.value =[USER_DEFAULTS integerForKey:@"distance"];
        self.lblCurrent.text =[NSString stringWithFormat:@"%ld",(long)[USER_DEFAULTS integerForKey:@"distance"]];
        [self changePopOver];

    }

}
-(void)localize
{
    [self.lblReport setText:[localization localizedStringForKey:@"Report/Feedback"]];
    [self.lblProfike setText:[localization localizedStringForKey:@"Profile"]];
    [self.lblLogout setText:[localization localizedStringForKey:@"Logout"]];
    [self.lblAppVersion setText:[localization localizedStringForKey:@"App Version"]];
    [self.lblLanguage setText:[localization localizedStringForKey:@"Language"]];    
    [self.lblTitle setText:[localization localizedStringForKey:@"Settings"]];
    [self.lblPush setText:[localization localizedStringForKey:@"Notification"]];
    [self.lblDistance setText:[localization localizedStringForKey:@"Search miles for events"]];
    
    [self.btnSave setTitle:[localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];

    
    [[self.tabBarController.tabBar.items objectAtIndex:0]setTitle:[localization localizedStringForKey:@"Home"]];
    [[self.tabBarController.tabBar.items objectAtIndex:1]setTitle:[localization localizedStringForKey:@"Promotions"]];
    [[self.tabBarController.tabBar.items objectAtIndex:3]setTitle:[localization localizedStringForKey:@"My Friends"]];
    [[self.tabBarController.tabBar.items objectAtIndex:2]setTitle:[localization localizedStringForKey:@"Board"]];
    [[self.tabBarController.tabBar.items objectAtIndex:4]setTitle:[localization localizedStringForKey:@"Settings"]];

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (IBAction)eventTapped:(id)sender
{
    MyEventsViewController *myVC =[[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
    [myVC setIsInvite:NO];
    [self.navigationController pushViewController:myVC animated:YES];
}

- (IBAction)languageTapped:(id)sender
{
    actionTag=0;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[localization localizedStringForKey:@"Select Language"]
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"English",@"Spanish",@"Chinese",[localization localizedStringForKey:@"Cancel"], nil];
    
  /*  [localization localizedStringForKey:@"English"]
    [localization localizedStringForKey:@"Spanish"]
    [localization localizedStringForKey:@"Chinese"]*/
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionTag==0)
    {
        selectedIndex =(int)buttonIndex;
        NSLog(@"Index is %ld",(long)buttonIndex);
        if(DELEGATE.connectedToNetwork)
        {
            if(buttonIndex==0)
            {
                // if(sender.isOn) ? @"Y" : @"N";
               // [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:@"E"search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Sel:@selector(responseLanguageChanged:)];
                
                [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:@"E" search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Event_notification:nil Comment_notification:nil Sel:@selector(responseLanguageChanged:)];
            }
            else if(buttonIndex==1)
            {
                // if(sender.isOn) ? @"Y" : @"N";
               // [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:@"S"search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Sel:@selector(responseLanguageChanged:)];
                
                [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:@"S" search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Event_notification:nil Comment_notification:nil Sel:@selector(responseLanguageChanged:)];
            }
            else if(buttonIndex==2)
            {
                // if(sender.isOn) ? @"Y" : @"N";
               // [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:@"C"search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Sel:@selector(responseLanguageChanged:)];
                
                [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:@"C" search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Event_notification:nil Comment_notification:nil Sel:@selector(responseLanguageChanged:)];
            }
            actionTag=-1;
        }
    }
    
    
}
-(void)responseLanguageChanged:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    NSLog(@"result is %d",selectedIndex);

    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(selectedIndex==0)
        {
            [localization setLanguage:@"EN"];
            [USER_DEFAULTS setObject:@"E" forKey:@"localization"];


        }
        else if(selectedIndex==1)
        {
            [localization setLanguage:@"SP"];
            [USER_DEFAULTS setObject:@"S" forKey:@"localization"];


        }
        else if(selectedIndex==2)
        {
            [localization setLanguage:@"CH"];
            [USER_DEFAULTS setObject:@"C" forKey:@"localization"];


        }
        selectedIndex =-1;
        
       
        [USER_DEFAULTS synchronize];
        [self localize];
        [DELEGATE setWindowRoot];
        
      
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
    
}
- (IBAction)pushChanged:(UISwitch *)sender
{
}
-(void)responsePushChanged:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"recieve_push"] forKey:@"recieve_push"];
        [USER_DEFAULTS synchronize];
        //[[USER_DEFAULTS valueForKey:@"recieve_push"] isEqualToString:@"Y"]
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

        
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
    
}
-(void)responseDistanceChanged:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"search_miles"] forKey:@"distance"];

        BOOL found =NO;
        NSLog(@"navigation are %@",self.navigationController.viewControllers);
        for(int i=0; i<self.navigationController.viewControllers.count;i++)
        {
            if([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[HomeTabViewController class]])
            {
                found =YES;
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i] animated:NO];
                
                break;
                
            }
        }
        if(!found)
        {
          
            [DELEGATE.tabBarController setSelectedIndex:0];
        }

    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
     
    }
    
}
- (IBAction)feedbackTapped:(id)sender
{
    ReachUsViewController *reachVC =[[ReachUsViewController alloc] initWithNibName:@"ReachUsViewController" bundle:nil];
    [self.navigationController pushViewController:reachVC animated:YES];
    
    
  /*  TimeLineViewController *timeVC =[[TimeLineViewController alloc] initWithNibName:@"TimeLineViewController" bundle:nil];
    [self.navigationController pushViewController:timeVC animated:YES];*/
}

- (IBAction)logOutTapped:(id)sender
{
    [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Are you sure, you want to Logout?"] AlertFlag:2 ButtonFlag:2];

}

- (IBAction)profileTapped:(id)sender
{
    RegistrationViewController *registrationVC =[[RegistrationViewController alloc] initWithNibName:@"RegistrationViewController" bundle:nil];
    [registrationVC setIsEdit:YES];
    [registrationVC setIsMy:NO];

    [self.navigationController pushViewController:registrationVC animated:YES];
}

- (IBAction)requestTapped:(id)sender
{
    FriendRequestViewController *frndVC =[[FriendRequestViewController alloc] initWithNibName:@"FriendRequestViewController" bundle:nil];
    [frndVC setIsFriend:YES];
    [self.navigationController pushViewController:frndVC animated:YES];
}

- (IBAction)doneTapped:(id)sender
{
    //[mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:nil search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Sel:@selector(responseDistanceChanged:)];
   
    if(DELEGATE.connectedToNetwork)
    {
         [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:nil search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Event_notification:nil Comment_notification:nil Sel:@selector(responseDistanceChanged:)];
    }
   
}

- (IBAction)invitationTapped:(id)sender
{
    MyEventsViewController *myVC =[[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
    [myVC setIsInvite:YES];
    [self.navigationController pushViewController:myVC animated:YES];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0)
    {
        if(DELEGATE.connectedToNetwork)
        {
            [mc logout:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responsegetLogout:)];

        }
        
    }
    
}
-(void)responsegetLogout:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
       /* [USER_DEFAULTS removeObjectForKey:@"userid"];
        [USER_DEFAULTS removeObjectForKey:@"myjid"];
        [USER_DEFAULTS removeObjectForKey:@"fullname"];
        [USER_DEFAULTS removeObjectForKey:@"myjid"];
        [USER_DEFAULTS removeObjectForKey:@"recieve_push"];*/
        NSDictionary * dict = [USER_DEFAULTS dictionaryRepresentation];
        for (id key in dict)
        {
            [USER_DEFAULTS removeObjectForKey:key];
        }
        [USER_DEFAULTS synchronize];

        
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        //  NSLog(@"current language is %@",language);
      
            if([language isEqualToString:@"es"])
            {
                [localization setLanguage:@"SP"];
               // [USER_DEFAULTS setObject:@"S" forKey:@"localization"];
            }
            else if([language isEqualToString:@"ch"])
            {
                [localization setLanguage:@"CH"];
               // [USER_DEFAULTS setObject:@"C" forKey:@"localization"];
            }
            else
            {
                [localization setLanguage:@"EN"];
                //[USER_DEFAULTS setObject:@"E" forKey:@"localization"];
            }
       
       // [USER_DEFAULTS synchronize];
       
        [DELEGATE disconnect];
        
        BOOL found =NO;
        for(int i=0; i<self.navigationController.viewControllers.count;i++)
        {
            if([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[LoginViewController class]])
            {
                found =YES;
                
                /* NSUserDefaults * defs = [NSUserDefaults standardUserDefaults]; NSDictionary * dict = [defs dictionaryRepresentation]; for (id key in dict) { [defs removeObjectForKey:key]; } [defs synchronize];*/
                
                
                DELEGATE.navigationController =[[UINavigationController alloc] initWithRootViewController:[self.navigationController.viewControllers objectAtIndex:i]];
                DELEGATE.navigationController.navigationBarHidden =YES;
                [DELEGATE.window setRootViewController:DELEGATE.navigationController];
                break;
                
            }
        }
        if(!found)
        {
            
            /*     NSUserDefaults * defs = [NSUserDefaults standardUserDefaults]; NSDictionary * dict = [defs dictionaryRepresentation]; for (id key in dict) { [defs removeObjectForKey:key]; } [defs synchronize];*/
            
            
            LoginViewController *loginVC =[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            DELEGATE.navigationController =[[UINavigationController alloc] initWithRootViewController:loginVC];
            DELEGATE.navigationController.navigationBarHidden =YES;
            [DELEGATE.window setRootViewController:DELEGATE.navigationController];
            //[self.navigationController pushViewController:dashVC animated:NO];
            
        }
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

       /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
    
    
    
}
- (IBAction)distanceChanged:(UISlider *)sender
{
    NSLog(@"result is %f",sender.value);
    self.lblCurrent.text =[NSString stringWithFormat:@"%d",(int)sender.value];
    
    [self changePopOver];

}
-(void)changePopOver
{
   /* CGRect        sliderFrame = self.distanceSlider.frame;
    CGFloat       x = sliderFrame.origin.x + sliderFrame.size.width * distanceSlider.value + 11;
    CGFloat       y = sliderFrame.origin.y + sliderFrame.size.height / 2;
    
    self.currentdistanceView.center = CGPointMake(x, y);*/
    
    CGRect trackRect = [self.distanceSlider trackRectForBounds:self.distanceSlider.bounds];
    CGRect thumbRect = [self.distanceSlider thumbRectForBounds:self.distanceSlider.bounds
                                             trackRect:trackRect
                                                 value:self.distanceSlider.value];
    
    self.currentdistanceView.center = CGPointMake(thumbRect.origin.x+15 + self.distanceSlider.frame.origin.x,  self.distanceSlider.frame.origin.y - 20);
   
}
- (IBAction)changed:(UISlider *)sender
{
    [USER_DEFAULTS setInteger:(int)sender.value forKey:@"distance"];
    [USER_DEFAULTS synchronize];
    NSLog(@"result is %f",sender.value);

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
    if(DELEGATE.connectedToNetwork)
    {
        [mc logout:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responsegetLogout:)];
        
    }
    
}
-(void)cancelBtnTapped:(id)sender
{
    //NSLog(@"cancelBtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];
    
}
- (IBAction)blockedTapped:(id)sender
{
    BlockedUserViewController *blockVC =[[BlockedUserViewController alloc] initWithNibName:@"BlockedUserViewController" bundle:nil];
    [self.navigationController pushViewController:blockVC animated:YES];
}
- (IBAction)notificationTapped:(id)sender
{
    NotificationViewController *notificationVC =[[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:nil];
    [self.navigationController pushViewController:notificationVC animated:YES];
}
- (IBAction)clickPromotion:(id)sender
{
    
    addPromotion *obj = [[addPromotion alloc]init];
    [obj setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:obj animated:YES];
    
}

- (IBAction)clickPromotionsList:(id)sender
{
    
    PromotionListing *obj = [[PromotionListing alloc]init];
    [obj setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:obj animated:YES];
    
    
}

- (IBAction)clickInviteFriends:(id)sender
{
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1702005553392744"];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:Icon_PATH];
    
    // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
    [FBSDKAppInviteDialog showWithContent:content
                                 delegate:self];
    
}

-(void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"%@",results);
    
    
}

-(void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    
    NSLog(@"%@",error);
    
    if(error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Something went wrong!"delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        
    }
    
    
}



@end

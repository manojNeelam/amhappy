//
//  NotificationViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 02/09/15.
//
//

#import "NotificationViewController.h"
#import "ModelClass.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController
{
    ModelClass *mc;
}

@synthesize lblAll,lblComment,lblEvent,lblTitle,switchAll,switchComment,switchEvent;
@synthesize btnSave;

- (void)viewDidLoad
{
    [super viewDidLoad];
    mc =[[ModelClass alloc] init];
    mc.delegate =self;
    
    self.lblTitle.text =[localization localizedStringForKey:@"Notification Settings"];
    self.lblEvent.text =[localization localizedStringForKey:@"Event Notification"];
    self.lblComment.text =[localization localizedStringForKey:@"Comment Notification"];
    self.lblAll.text =[localization localizedStringForKey:@"All Notification"];
    [self.btnSave setTitle:[localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];

    
   
    
    if([USER_DEFAULTS valueForKey:@"recieve_push"])
    {
        if([[USER_DEFAULTS valueForKey:@"recieve_push"] isEqualToString:@"Y"])
        {
            [self.switchAll setOn:YES];
        }
        else
        {
            [self.switchAll setOn:NO];

        }
    }
    
    if([USER_DEFAULTS valueForKey:@"comment_notification"])
    {
        if([[USER_DEFAULTS valueForKey:@"comment_notification"] isEqualToString:@"Y"])
        {
            [self.switchComment setOn:YES];
        }
        else
        {
            [self.switchComment setOn:NO];
            
        }
    }
    
    if([USER_DEFAULTS valueForKey:@"event_notification"])
    {
        if([[USER_DEFAULTS valueForKey:@"event_notification"] isEqualToString:@"Y"])
        {
            [self.switchEvent setOn:YES];
        }
        else
        {
            [self.switchEvent setOn:NO];
            
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)allChanged:(id)sender
{
}
- (IBAction)eventChanged:(id)sender
{
}
- (IBAction)commentChanged:(id)sender
{
}
- (IBAction)saveTapped:(id)sender
{
    if(DELEGATE.connectedToNetwork)
    {
       // [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:(sender.isOn) ? @"Y" : @"N" Langauge:@"C"search_miles:[NSString stringWithFormat:@"%d",(int)self.distanceSlider.value] Sel:@selector(responsePushChanged:)];
        
        
        [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:(self.switchAll.isOn) ? @"Y" : @"N" Langauge:nil search_miles:nil Event_notification:(self.switchEvent.isOn) ? @"Y" : @"N" Comment_notification:(self.switchComment.isOn) ? @"Y" : @"N" Sel:@selector(responseSettingChanged:)];
    }
    
}
-(void)responseSettingChanged:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"recieve_push"] forKey:@"recieve_push"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"comment_notification"] forKey:@"comment_notification"];
        
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"event_notification"] forKey:@"event_notification"];
        
        [USER_DEFAULTS synchronize];
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
    
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
@end

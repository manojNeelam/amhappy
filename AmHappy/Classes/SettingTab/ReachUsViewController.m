//
//  ReachUsViewController.m
//  BusMap
//
//  Created by Peerbits 8 on 23/12/14.
//
//

#import "ReachUsViewController.h"
#import "ModelClass.h"

@interface ReachUsViewController ()

@end

@implementation ReachUsViewController
{
    UIToolbar *mytoolbar1;
    ModelClass *mc;
    NSUserDefaults *defaults;
}
@synthesize lblTitle,txtComment,txtEmail,btnSubmit;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txtComment.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.txtEmail.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    defaults =[NSUserDefaults standardUserDefaults];
    
    [self.btnSubmit.layer setMasksToBounds:YES];
    [self.btnSubmit.layer setCornerRadius:3.0];
    
    if(IS_IPAD)
    {
        [self.lblTitle setFont:FONT_Regular(30)];
        [self.btnSubmit.titleLabel setFont:FONT_Regular(22)];
    }
    else
    {
        [self.lblTitle setFont:FONT_Regular(20)];
        [self.btnSubmit.titleLabel setFont:FONT_Regular(17)];
    }
   

    self.txtEmail.delegate =self;
    self.txtComment.delegate =self;
   
    
    if(IS_IPAD)
    {
        [ self.scrollview setContentSize:CGSizeMake(self.scrollview.frame.size.width, 100)];

    }
    else
    {
        [ self.scrollview setContentSize:CGSizeMake(self.scrollview.frame.size.width, 300)];

    }
    
    self.btnSubmit.layer.masksToBounds = YES;
    self.btnSubmit.layer.cornerRadius = 3.0;
    
    self.txtComment.layer.masksToBounds = YES;
    self.txtComment.layer.cornerRadius = 5.0;
    self.txtComment.layer.borderWidth =1.2;
    self.txtComment.layer.borderColor =[[UIColor colorWithRed:(214/255.f) green:(214/255.f) blue:(214/255.f) alpha:1.0f] CGColor];
    
    [self.txtComment setDelegate:self];
    //[self.txtComment setReturnKeyType:UIReturnKeyDone];
    [self.txtComment setText:[localization localizedStringForKey:@"Comment"]];
    [self.txtComment setFont:FONT_Regular(13.0)];
    [self.txtComment setTextColor:[UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]];
    
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
    
    self.txtComment.inputAccessoryView =mytoolbar1;
    self.txtEmail.inputAccessoryView =mytoolbar1;
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
}
-(void)localize
{
    [self.txtComment setText:[localization localizedStringForKey:@"Comment"]];
    [self.txtEmail setPlaceholder:[localization localizedStringForKey:@"Email"]];
    [self.btnSubmit setTitle:[localization localizedStringForKey:@"Submit"] forState:UIControlStateNormal];
    [self.lblTitle setText:[localization localizedStringForKey:@"Feedback"]];
    
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.txtComment.textColor == [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f])
    {
        self.txtComment.text = @"";
        self.txtComment.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(self.txtComment.text.length == 0){
        self.txtComment.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
        self.txtComment.text = @"Comment";

        //self.txtComment.text = [localization localizedStringForKey:@"Comment"];
        [self.txtComment resignFirstResponder];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
   
        if(self.txtComment.text.length == 0){
            self.txtComment.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
            self.txtComment.text = @"Comment";
            
            // self.txtComment.text = [localization localizedStringForKey:@"Comment"];
            [self.txtComment resignFirstResponder];
        }
    else
    {
        if(![textView.text isEqualToString:@"Comment"])
        {
            self.txtComment.textColor = [UIColor blackColor];
            
        }
    }
    
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
        if([textView.text isEqualToString:@"Comment"])
        {
            textView.text=@"";
            [textView setTextColor:[UIColor blackColor]];
        }
        else
        {
            [textView setTextColor:[UIColor blackColor]];
        }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
   /* if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(self.txtComment.text.length == 0){
            self.txtComment.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
            self.txtComment.text = @"Comment";

           // self.txtComment.text = [localization localizedStringForKey:@"Comment"];
            [self.txtComment resignFirstResponder];
        }
        return NO;
    }
    */
    return YES;
}
-(void)nextPressed
{
    if ([txtEmail isFirstResponder])
    {
        [txtComment becomeFirstResponder];
        return;
    }
    
   }
-(void)previousPressed
{
    
    if ([txtComment isFirstResponder])
    {
        [txtEmail becomeFirstResponder];
        return;
    }
    
}

-(void)donePressed
{
    [self.view endEditing:YES];
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
   
    if(textField==self.txtEmail)
    {
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(BOOL)checkValidation
{
    
    NSString *email = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *comment = [self.txtComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([comment isEqualToString:@"Comment"])
    {
        comment=@"";
    }
    
    
    if([email length] <= 0 || [comment length] <= 0 )
    {
        if(email.length <=0 )
        {
            
           // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter Email"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter Email"] AlertFlag:1 ButtonFlag:1];

            
            /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter Email"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
            
            
            [alert show];*/
            return FALSE;
        }
       if(comment.length <=0)
        {
            
          //  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter comment"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter comment"] AlertFlag:1 ButtonFlag:1];
            
           /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:@"Please enter comment" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];*/
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



-(void)responseUserComment:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
        
 
    }
}
- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)submitTapped:(id)sender
{
    [self.view endEditing:YES];
    if([self checkValidation])
    {
        if([DELEGATE validateEmail:self.txtEmail.text])
        {
            if(DELEGATE.connectedToNetwork)
            {
                [mc addFeedback:[USER_DEFAULTS valueForKey:@"userid"] Email:self.txtEmail.text Description:self.txtComment.text Sel:@selector(responseUserComment:)];
                
            }
        }
        else
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter valid Email"] AlertFlag:1 ButtonFlag:1];

        }
        
    }
}
-(void)ok1BtnTapped:(id)sender
{
    [[self.view viewWithTag:123] removeFromSuperview];
    
}
-(void)ok2BtnTapped:(id)sender
{
    [[self.view viewWithTag:123] removeFromSuperview];
    
}
-(void)cancelBtnTapped:(id)sender
{
    //NSLog(@"cancelBtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];
    
}
@end

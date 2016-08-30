//
//  ForgotPasswordViewController.m
//  AmHappy
//
//  Created by Syntel-Amargoal1 on 7/28/16.
//
//

#import "ForgotPasswordViewController.h"

@implementation ForgotPasswordViewController

- (IBAction)onClickBackButton:(id)sender {
    
    [self openLoginVC];
}


- (IBAction)onClickSubmitButton:(id)sender
{
    if([self checkValidation])
    {
        
    }
}

- (IBAction)onClickSignInButton:(id)sender
{
    [self openLoginVC];
}

-(void)openLoginVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self customiseScreen];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)customiseScreen
{
    [self.txtFldEmail setPaddingViewWithImg:@"userLogo"];
    [self.txtFldEmail.paddingBGView setBackgroundColor:[UIColor colorWithRed:117/255.0f green:171/255.0f blue:35/255.0f alpha:1.0f]];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.txtFldEmail setTextColor:[UIColor colorWithRed:117/255.0f green:171/255.0f blue:35/255.0f alpha:1.0f]];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField setTextColor:[UIColor whiteColor]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return  YES;
}

-(BOOL)checkValidation
{
    NSString *userId = [self.txtFldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(userId.length <=0 )
    {
        [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter email address."]];
        return NO;
    }
    
    return YES;
}

@end

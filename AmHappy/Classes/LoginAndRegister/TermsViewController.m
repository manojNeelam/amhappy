//
//  TermsViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 07/02/15.
//
//

#import "TermsViewController.h"
#import "ModelClass.h"
#import "DarckWaitView.h"

@interface TermsViewController ()

@end

@implementation TermsViewController
{
    ModelClass *mc;
    DarckWaitView *drk;
}

@synthesize webview;

- (void)viewDidLoad {
    [super viewDidLoad];
    mc =[[ModelClass alloc] init];
    mc.delegate =self;
    drk =[[DarckWaitView alloc] init];
    [self callApi];
    // Do any additional setup after loading the view from its nib.
}
-(void)callApi
{
    if(DELEGATE.connectedToNetwork)
    {
        if([USER_DEFAULTS valueForKey:@"userid"])
        {
            [mc getDropDowns:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responseGetDropDown1:)];
        }
        else
        {
            [mc getDropDowns:nil Sel:@selector(responseGetDropDown1:)];
        }
    }
    
}
-(void)responseGetDropDown1:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        if([results valueForKey:@"terms"])
        {
            NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@",[results valueForKey:@"terms"]]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [self.webview setScalesPageToFit:NO];
            [self.webview loadRequest:request];
        }
        
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
         [alert show];*/
    }
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    [drk showWithMessage:nil];
}
//a web view starts loading
- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [drk hide];
}
//web view finishes loading
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [drk hide];
}
- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)rq
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
}
-(void)localize
{
    [self.lblTitle setText:[localization localizedStringForKey:@"Terms And Policy"]];
}


- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

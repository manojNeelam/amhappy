//
//  BaseViewController.m
//  AmHappy
//
//  Created by Syntel-Amargoal1 on 7/28/16.
//
//
#define HEIGHT_ERRORPOPUP   50
#define XPOS_ERRORPOPUP 20

#import "BaseViewController.h"

@interface BaseViewController ()
{
    BOOL showErrorView;
    NSTimer *timer;
}
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view layoutIfNeeded];
    
    CGRect frame = self.view.frame;
    
    self.errorBaseView = [[UIView alloc] init];
    self.errorBaseView.frame = CGRectMake(0, frame.size.height, frame.size.width, HEIGHT_ERRORPOPUP);
    [self.errorBaseView setBackgroundColor:[UIColor colorWithRed:34/255.0f green:34/255.0f blue:34/255.0f alpha:1.0f]];
    
    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.frame = CGRectMake(XPOS_ERRORPOPUP, (XPOS_ERRORPOPUP-5), frame.size.width-(XPOS_ERRORPOPUP *2), 20);
    [self.errorLabel setTextColor:[UIColor whiteColor]];
    [self.errorLabel setBackgroundColor:[UIColor clearColor]];
    [self.errorLabel setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:13.0f]];
    
    [self.errorBaseView addSubview:self.errorLabel];
    
    [self.view addSubview:self.errorBaseView];
}


-(NSArray*)findAllTextFieldsInView:(UIView*)view{
    NSMutableArray* textfieldarray = [[NSMutableArray alloc] init];
    for(id x in [view subviews]){
        if([x isKindOfClass:[UITextField class]])
            [textfieldarray addObject:x];
        
        if([x respondsToSelector:@selector(subviews)]){
            // if it has subviews, loop through those, too
            [textfieldarray addObjectsFromArray:[self findAllTextFieldsInView:x]];
        }
    }
    return textfieldarray;
}

-(void)resetPaddingBgColor{
    NSArray* allTextFields = [self findAllTextFieldsInView:[self view]];
    for(UITextField *fields in allTextFields)
    {
        AppTextField *appTxtFld = (AppTextField *)fields;
        [appTxtFld.paddingBGView setBackgroundColor:[UIColor colorWithRed:101/255.0f green:101/255.0f blue:101/255.0f alpha:1.0f]];
    }
}

-(void)showErrorView
{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         CGRect frame = self.errorBaseView.frame;
                         frame.origin.y = self.view.frame.size.height-41;
                         self.errorBaseView.frame = frame;
                     }
                     completion:nil];
}

-(void)hideErrorView
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         CGRect frame = self.errorBaseView.frame;
                         frame.origin.y = self.view.frame.size.height;
                         self.errorBaseView.frame = frame;
                     }
                     completion:nil];
}

-(void)showPopUpwithMsg:(NSString *)msg
{
    [self.errorLabel setText:msg];
    [self showErrorView];
    
    if(timer)
    {
        [timer invalidate];
        timer = nil;
    }
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideErrorView) userInfo:nil repeats:NO];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

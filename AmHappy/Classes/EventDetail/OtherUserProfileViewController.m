//
//  OtherUserProfileViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 23/02/15.
//
//

#import "OtherUserProfileViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "HobbiyViewController.h"
#import "OtherUserEventsViewController.h"

@interface OtherUserProfileViewController ()

@end

@implementation OtherUserProfileViewController
{
    ModelClass *mc;
    int relationID;
    BOOL isMale;
    NSMutableArray *hobbyIdArray;


}
@synthesize lblGender,lblHobby,lblTitle,txtDob,txtEmail,txtFname,txtRelation,txtUsername,btnfemail,btnMail,userId,scrollview,imgUser,btnAdd;

@synthesize imgBg1,imgBg2,imgBg3,imgBg4,imgIcon1,imgIcone2,btnHobby;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.txtFname setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [self.txtRelation setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    [self.txtUsername setAutocapitalizationType:UITextAutocapitalizationTypeSentences];

    
    
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    relationID =-1;
    isMale =YES;
    hobbyIdArray =[[NSMutableArray alloc] init];
    self.imgUser.layer.cornerRadius = self.imgUser.frame.size.width/2;
    self.imgUser.layer.masksToBounds = YES;
    
    [self.scrollview setContentSize:CGSizeMake(self.view.bounds.size.width, 500)];
    
    if(IS_Ipad)
    {
       // self.btnAdd.frame =CGRectMake(self.btnAdd.frame.origin.x-50, self.btnAdd.frame.origin.y, self.btnAdd.frame.size.width, self.btnAdd.frame.size.height);
    }
    [self.lblGender setText:[localization localizedStringForKey:@"Gender"]];


    if(DELEGATE.connectedToNetwork)
    {
        [mc getUser:[NSString stringWithFormat:@"%@",userId] Sel:@selector(responseGetUser:)];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.btnAdd setTitle:[localization localizedStringForKey:@"Send Friend Request"] forState:UIControlStateNormal];
}

-(void)responseGetUser:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    /*
     "is_friend" = N;
     self = N;
     */
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        NSLog(@"%@",[USER_DEFAULTS valueForKey:@"userid"]);
        NSLog(@"%@",userId);
        
        if([[results valueForKey:@"is_friend"] isEqualToString:@"Y"])
        {
            self.txtEmail.text =[[results valueForKey:@"User"] valueForKey:@"email"];
            self.txtDob.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"User"] valueForKey:@"dob"]];
            if([[[results valueForKey:@"User"] valueForKey:@"hobbies_count"] integerValue]==1)
            {
                self.lblHobby.text =[NSString stringWithFormat:@"%@ %@",[[results valueForKey:@"User"] valueForKey:@"hobbies_count"],[localization localizedStringForKey:@"hobby selected"]];
                [lblHobby setTextColor:[UIColor blackColor]];
            }
            else
            {
                
                self.lblHobby.text =[NSString stringWithFormat:@"%@ %@",[[results valueForKey:@"User"] valueForKey:@"hobbies_count"],[localization localizedStringForKey:@"hobbies selected"]];
                [lblHobby setTextColor:[UIColor blackColor]];
                
            }
            
            
            self.txtRelation.text =[[results valueForKey:@"User"] valueForKey:@"relationship_name"];
            self.txtUsername.text =[[results valueForKey:@"User"] valueForKey:@"fullname"];
            relationID =[[[results valueForKey:@"User"] valueForKey:@"relationship"] intValue];
            
            
            if([[[results valueForKey:@"User"] valueForKey:@"gender"] length]>0)
            {
                if([[[results valueForKey:@"User"] valueForKey:@"gender"] isEqualToString:@"M"])
                {
                    [self.btnMail setImage:[UIImage imageNamed:@"male1.png"] forState:UIControlStateNormal];
                    [self.btnfemail setImage:[UIImage imageNamed:@"female.png"] forState:UIControlStateNormal];
                    isMale =YES;
                }
                else
                {
                    [self.btnMail setImage:[UIImage imageNamed:@"male.png"] forState:UIControlStateNormal];
                    [self.btnfemail setImage:[UIImage imageNamed:@"female1.png"] forState:UIControlStateNormal];
                    isMale =NO;
                }
            }
            if([[[results valueForKey:@"User"] valueForKey:@"hobbies"] length]>0)
            {
                [hobbyIdArray removeAllObjects];
                [hobbyIdArray addObjectsFromArray:[[[results valueForKey:@"User"] valueForKey:@"hobbies"] componentsSeparatedByString:@","]];
                
            }
            
            [self.btnAdd setHidden:YES];
        }
        else
        {
          
            
            
            if ([[[USER_DEFAULTS valueForKey:@"userid"] description]isEqualToString:userId])
            {
                    [self.btnAdd setHidden:YES];
            }
            else{
                
                [self.btnAdd setHidden:NO];
                
            }
            
            
            [self hideViews];

        }
        
        
        
        self.lblTitle.text =[[results valueForKey:@"User"] valueForKey:@"fullname"];
        self.txtFname.text =[[results valueForKey:@"User"] valueForKey:@"fullname"];
        
        [self.imgUser setContentMode:UIViewContentModeScaleAspectFill];
        
        if([[[results valueForKey:@"User"] valueForKey:@"image"] length]>0)
        {
            [self.imgUser sd_setImageWithURL:[NSURL URLWithString:[[results valueForKey:@"User"] valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"iconBlack"]];
        }
        
        
        
        
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

      
    }
    
    
}

-(void)hideViews
{
    [self.imgIcone2 setHidden:YES];
    [self.imgIcon1 setHidden:YES];
    [self.imgBg4 setHidden:YES];
    [self.imgBg3 setHidden:YES];
    [self.imgBg2 setHidden:YES];
    [self.imgBg1 setHidden:YES];
    [self.imgSeperator setHidden:YES];

    
    [self.btnHobby setHidden:YES];
    [self.btnMail setHidden:YES];
    [self.btnfemail setHidden:YES];
    
    [self.txtDob setHidden:YES];
    [self.txtEmail setHidden:YES];
    [self.txtRelation setHidden:YES];
    [self.txtUsername setHidden:YES];
    
    
    [self.lblGender setHidden:YES];
    [self.lblHobby setHidden:YES];

    
    [self.scrollview setContentSize:CGSizeMake(self.view.bounds.size.width, 100)];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)hobbyTapped:(id)sender
{
   HobbiyViewController *hobbyVC =[[HobbiyViewController alloc] initWithNibName:@"HobbiyViewController" IdArray:hobbyIdArray bundle:nil];
     [hobbyVC setIsEdit:NO];
     [hobbyVC setIsFirst:NO];
     [hobbyVC setIsOther:YES];
    [self.navigationController pushViewController:hobbyVC animated:YES];
    

}

- (IBAction)addTapped:(id)sender
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[NSString stringWithFormat:@"%@",userId] Sel:@selector(responseFriendRequest:)];
    }
    
}



-(void)responseFriendRequest:(NSDictionary *)results
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
    [[self.view viewWithTag:123] removeFromSuperview];
}
- (IBAction)eventTapped:(id)sender
{
    OtherUserEventsViewController *otherVC =[[OtherUserEventsViewController alloc] initWithNibName:@"OtherUserEventsViewController" bundle:nil];
    otherVC.userid =[NSString stringWithFormat:@"%@",userId];
    otherVC.userName = [NSString stringWithFormat:@"%@",self.txtFname.text];
    [otherVC setIsMy:NO];
    [self.navigationController pushViewController:otherVC animated:YES];
}
@end

//
//  Guests.m
//  AmHappy
//
//  Created by Peerbits MacMini9 on 01/12/15.
//
//

#import "Guests.h"
#import "FriendCell.h"
#import "UIImageView+WebCache.h"
#import "ModelClass.h"
#import "GuestViewController.h"
#import "AppFriendViewControllerViewController.h"
#import "InviteGroupViewController.h"
#import "RegistrationViewController.h"
#import "OtherUserProfileViewController.h"

@interface Guests ()<UIAlertViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,CustomAlertDelegate>
{
    ModelClass *mc;
    
    NSMutableDictionary *eventData;
    
    BOOL isShow;
    
    UIToolbar *mytoolbar1;
    
}


@end

@implementation Guests
@synthesize eventId,isMyEvent,is_admin,is_expired;


- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    
    [self.lblTitle setText:[localization localizedStringForKey:@"Guests"]];
    
    
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
    
    
    mytoolbar1.items = [NSArray arrayWithObjects:done1, nil];
    
    self.txtlfldEmail.inputAccessoryView =mytoolbar1;
    
    
    [self.viewbackgroundPopUp.layer setCornerRadius:10];
    [self.viewbackgroundPopUp setClipsToBounds:YES];
    
    
    self.viewbackgroundPopUp.frame = CGRectMake(self.viewbackgroundPopUp.frame.origin.x, [UIScreen mainScreen].bounds.size.width/2, self.viewbackgroundPopUp.frame.size.width, self.viewbackgroundPopUp.frame.size.height);
    
    
    [self.btnCancel.layer setBorderColor:[UIColor colorWithRed:65/225.0 green:65/255.0 blue:65/255.0 alpha:1].CGColor];
    [self.btnCancel.layer setBorderWidth:1];
    
    
    [self.btnSend.layer setBorderColor:[UIColor colorWithRed:65/225.0 green:65/255.0 blue:65/255.0 alpha:1].CGColor];
    [self.btnSend.layer setBorderWidth:1];
    

    [self.viewEmailPopUp setFrame:CGRectMake(0,-1500,self.viewEmailPopUp.frame.size.width,  self.viewEmailPopUp.frame.size.height)];
    
    
    
    
    
    if (!self.isMyEvent)
    {
        [self.btnAdd setHidden:YES];
        
    }
    
    
    if (is_admin)
    {
        
        if (is_expired)
        {
             [self.btnAdd setHidden:YES];
        }
        else{
            
            [self.btnAdd setHidden:NO];
            
        }
     
    }
 
    [self.viewButtons setHidden:YES];
    
    NSLog(@"%@",eventId);
    
    
    

    mc = [[ModelClass alloc]init];
    mc.delegate =self;
  
    if ([DELEGATE connectedToNetwork])
    {

        [mc getAttendingCount:[USER_DEFAULTS valueForKey:@"userid"] eventid:eventId Sel:@selector(response:)];
     
    }
    
 
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [self viewDidLoad];
}

-(void)donePressed
{
    [self.view endEditing:YES];
    
}


-(void)response:(NSDictionary *)dict
{
    
    NSLog(@"%@",dict);
    
    if ([[NSString stringWithFormat:@"%@",[dict valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        eventData = [[NSMutableDictionary alloc]initWithDictionary:dict];
        
        [self.tblVIew reloadData];
        
    }
    else
    {
        [DELEGATE showalert:self Message:[dict valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark ---------- TableView Datasource & Delegate ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (eventData)
    {
 
        if (section == 0)
        {
            
            if ([[eventData valueForKey:@"attendence_yes_count"]intValue]>3)
            {
                 return 4;
                
            }
            else{

                return [[eventData valueForKey:@"YES"]count];
            }
            
            
        }
        
        else if (section == 1)
        {
            
            if ([[eventData valueForKey:@"attendence_no_count"]intValue]>3)
            {
                return 4;
                
            }
            else{
                
                return [[eventData valueForKey:@"NO"]count];
            }
            
            
        }
        
        else
        {
            
            if ([[eventData valueForKey:@"no_answer_count"]intValue]>3)
            {
                return 4;
                
            }
            else{
                
                return [[eventData valueForKey:@"NA"]count];
            }
            
            
        }
        
    }
    else
    {
        
        return 0;
    }
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
    }
    
    
    
    [cell.lblName setFont:FONT_Regular(14)];
    [cell.btnInvite setHidden:YES];
    [cell.btnAccept setHidden:YES];

    [cell.btnAdd setHidden:YES];
    
    cell.imgUser.layer.masksToBounds = YES;
    cell.imgUser.layer.cornerRadius = 25.0;
    
  
    if (indexPath.section == 0)
    {
  
        if ([[eventData valueForKey:@"YES"]count]>0)
        {
            
            if (indexPath.row < 3)
            {
               
                [cell.imgUser setHidden:NO];
                
                cell.lblName.textAlignment = NSTextAlignmentLeft;
                
                cell.lblName.text =[[[eventData valueForKey:@"YES"] objectAtIndex:indexPath.row] valueForKey:@"name"];
               
                
                if([[[[eventData valueForKey:@"YES"] objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
                {
                    [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[[eventData valueForKey:@"YES"] objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                }
                
                
                if([[[[eventData valueForKey:@"YES"] objectAtIndex:indexPath.row] valueForKey:@"is_admin"]isEqualToString:@"Y"])
                {
                    
                    [cell.btnAdd setHidden:NO];
                    [cell.btnAdd setUserInteractionEnabled:NO];
                    
                    [cell.btnAdd setImage:[UIImage imageNamed:@"admin"] forState:UIControlStateNormal];
                    
                   
                }
                
             
                
                
                
            }
            else
            {
                
                [cell.imgUser setHidden:YES];
                
                cell.lblName.text = @"See more";
                
                cell.lblName.frame = CGRectMake(cell.lblName.frame.origin.x, cell.lblName.frame.origin.y, cell.frame.size.width-cell.lblName.frame.origin.x-20, cell.lblName.frame.size.height);
               
                cell.lblName.textAlignment = NSTextAlignmentCenter;
                
                [cell.lblName setTextColor:[UIColor colorWithRed:228/255.0 green:123/255.0 blue:0/255.0 alpha:1]];
                
                
                
            }
            
         
            
        }
        
       
       
    }

    if (indexPath.section == 1)
    {
        
        
        if ([[eventData valueForKey:@"NO"]count]>0)
        {
            
            if (indexPath.row < 3)
            {
                
                [cell.imgUser setHidden:NO];
              
                cell.lblName.textAlignment = NSTextAlignmentLeft;
                
                cell.lblName.text =[[[eventData valueForKey:@"NO"] objectAtIndex:indexPath.row] valueForKey:@"name"];
                
                
                if([[[[eventData valueForKey:@"NO"] objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
                {
                    [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[[eventData valueForKey:@"NO"] objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                }
                
                
            }
            else
            {
                
                
                [cell.imgUser setHidden:YES];
                
                cell.lblName.text = @"See more";
                
                cell.lblName.frame = CGRectMake(cell.lblName.frame.origin.x, cell.lblName.frame.origin.y, cell.frame.size.width-cell.lblName.frame.origin.x-20,  cell.lblName.frame.size.height);
                
                cell.lblName.textAlignment = NSTextAlignmentCenter;
                
                [cell.lblName setTextColor:[UIColor colorWithRed:228/255.0 green:123/255.0 blue:0/255.0 alpha:1]];
                
                
            }
            
            
        }
       
       
        
    }
    
    
    if (indexPath.section == 2)
    {
        
       
        if ([[eventData valueForKey:@"NA"]count]>0)
        {
            
            if (indexPath.row < 3)
            {
                
                [cell.imgUser setHidden:NO];
                
                cell.lblName.text =[[[eventData valueForKey:@"NA"] objectAtIndex:indexPath.row] valueForKey:@"name"];
                
                
                if([[[[eventData valueForKey:@"NA"] objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
                {
                    [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[[eventData valueForKey:@"NA"] objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                }
                
                
            }
            else
            {
                
                [cell.imgUser setHidden:YES];
                
                cell.lblName.text = @"See more";
                
               cell.lblName.frame = CGRectMake(cell.lblName.frame.origin.x, cell.lblName.frame.origin.y, cell.frame.size.width-cell.lblName.frame.origin.x-20,cell.lblName.frame.size.height);
                
                cell.lblName.textAlignment = NSTextAlignmentCenter;
                
                [cell.lblName setTextColor:[UIColor colorWithRed:228/255.0 green:123/255.0 blue:0/255.0 alpha:1]];
            }
            
            
        }
        
       
    }
  
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
    
}


-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 50.0)];
    sectionHeaderView.backgroundColor = [UIColor colorWithRed:232/255.0 green:235/255.0 blue:240/255.0 alpha:1];
    
    CALayer *border = [CALayer layer];
    border.backgroundColor = [UIColor lightGrayColor].CGColor;
    
    border.frame = CGRectMake(0, sectionHeaderView.frame.size.height - 1, sectionHeaderView.frame.size.width, 1);
    [sectionHeaderView.layer addSublayer:border];
    
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(10,2, sectionHeaderView.frame.size.width,sectionHeaderView.frame.size.height)];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    
    NSString *fontName = self.txtlfldEmail.font.fontName;
    [headerLabel setFont:[UIFont fontWithName:fontName size:14.0]];
    [sectionHeaderView addSubview:headerLabel];
    
 
    //******* attend 
  
    NSAttributedString *attendingStr = [[NSAttributedString alloc]init];
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]init];
    
    if ([eventData valueForKey:@"attendence_yes_count"])
    {
        
        attendingStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ (%@)",[localization localizedStringForKey:@"Attending"],[eventData valueForKey:@"attendence_yes_count"]]];
        
        NSLog(@"%lu",(unsigned long)attendingStr.length);
        
        text =
        [[NSMutableAttributedString alloc]
         initWithAttributedString: attendingStr];
        
        NSUInteger Countlenght = [[localization localizedStringForKey:@"Attending"]length];
        
       [text addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithRed:228/255.0 green:123/255.0 blue:0/255.0 alpha:1]
                     range:NSMakeRange(Countlenght,attendingStr.length-Countlenght)];
    }
    else{
        
           attendingStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ (%@)",[localization localizedStringForKey:@"Attending"],@"0"]];
        
    }
 
    
    //************* not Attend
    
    
    
    NSAttributedString *notAttendingStr = [[NSAttributedString alloc]init];
    NSMutableAttributedString *text2 =
    [[NSMutableAttributedString alloc]init];
    
    if ([eventData valueForKey:@"attendence_no_count"])
    {
        
        notAttendingStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ (%@)",[localization localizedStringForKey:@"Not Attending"],[eventData valueForKey:@"attendence_no_count"]]];
        
        NSLog(@"%lu",(unsigned long)attendingStr.length);
        
      text2 =
        [[NSMutableAttributedString alloc]
         initWithAttributedString: notAttendingStr];
        
        
        
        
        NSUInteger Countlenght = [[localization localizedStringForKey:@"Not Attending"]length];
        
        [text2 addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithRed:228/255.0 green:123/255.0 blue:0/255.0 alpha:1]
                     range:NSMakeRange(Countlenght,notAttendingStr.length-Countlenght)];
        
        /*[text2 addAttribute:NSForegroundColorAttributeName
                      value:[UIColor colorWithRed:228/255.0 green:123/255.0 blue:0/255.0 alpha:1]
                      range:NSMakeRange(14,notAttendingStr.length-14)];*/
        
    }
    else{
        
        notAttendingStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ (%@)",[localization localizedStringForKey:@"Not Attending"],@"0"]];
        
    }
    
   
    
  
    
    //********** pending
    
    NSAttributedString *pendingStr = [[NSAttributedString alloc]init];
     NSMutableAttributedString *text3 = [[NSMutableAttributedString alloc]init];

    if ([eventData valueForKey:@"no_answer_count"])
    {
        
        pendingStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ (%@)",[localization localizedStringForKey:@"Pending"],[eventData valueForKey:@"no_answer_count"]]];
        
        NSLog(@"%lu",(unsigned long)pendingStr.length);
        
       text3 =
        [[NSMutableAttributedString alloc]
         initWithAttributedString: pendingStr];
        
        
        NSUInteger Countlenght = [[localization localizedStringForKey:@"Pending"]length];
        
        [text3 addAttribute:NSForegroundColorAttributeName
                      value:[UIColor colorWithRed:228/255.0 green:123/255.0 blue:0/255.0 alpha:1]
                      range:NSMakeRange(Countlenght,pendingStr.length-Countlenght)];
        

        
        /*[text3 addAttribute:NSForegroundColorAttributeName
                      value:[UIColor colorWithRed:228/255.0 green:123/255.0 blue:0/255.0 alpha:1]
                      range:NSMakeRange(8,pendingStr.length-8)];*/
    }
    else{
        
        pendingStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ (%@)",[localization localizedStringForKey:@"Pending"],@"0"]];
        
    }
    

    
    switch (section)
    {
        case 0:
            
            NSLog(@"%@",text);
            
            [headerLabel setAttributedText:text];

            return sectionHeaderView;
            break;
            
            
        case 1:
            
            [headerLabel setAttributedText:text2];
            return sectionHeaderView;
            break;
            
            
        case 2:
            
            [headerLabel setAttributedText:text3];
            return sectionHeaderView;
            break;
            
        default:
            break;
    }
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 50;
    
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    GuestViewController *guestVC =[[GuestViewController alloc] initWithNibName:@"GuestViewController" bundle:nil];

    if (indexPath.section == 0)
    {
        
        if ([[eventData valueForKey:@"YES"]count]>0)
        {
            
            if (indexPath.row < 3)
            {
       
                NSString *userID;
               
                userID =[NSString stringWithFormat:@"%@",[[[eventData valueForKey:@"YES"] objectAtIndex:indexPath.row] valueForKey:@"id"]];
               
                
                if([userID isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
                {
                    RegistrationViewController *registrationVC =[[RegistrationViewController alloc] initWithNibName:@"RegistrationViewController" bundle:nil];
                    [registrationVC setIsEdit:YES];
                    [registrationVC setIsMy:NO];
                    
                    [self.navigationController pushViewController:registrationVC animated:YES];
                }
                else
                {
                    OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
                    [otherVC setUserId:userID];
                    [self.navigationController pushViewController:otherVC animated:YES];
                    
                }
                
            }
            else
            {
                
                [guestVC setEventID:self.eventId];
                
                
                guestVC.eventType = @"Y";
                    
          
                guestVC.isGroupAdmin = is_admin;
                
                
                [self.navigationController pushViewController:guestVC animated:YES];
               
                
            }
            
            
            
        }
        
        
        
    }
    
    if (indexPath.section == 1)
    {
        
        
        if ([[eventData valueForKey:@"NO"]count]>0)
        {
            
            if (indexPath.row < 3)
            {
                
                NSString *userID;
                
                userID =[NSString stringWithFormat:@"%@",[[[eventData valueForKey:@"NO"] objectAtIndex:indexPath.row] valueForKey:@"id"]];
                
                
                if([userID isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
                {
                    RegistrationViewController *registrationVC =[[RegistrationViewController alloc] initWithNibName:@"RegistrationViewController" bundle:nil];
                    [registrationVC setIsEdit:YES];
                    [registrationVC setIsMy:NO];
                    
                    [self.navigationController pushViewController:registrationVC animated:YES];
                }
                else
                {
                    OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
                    [otherVC setUserId:userID];
                    [self.navigationController pushViewController:otherVC animated:YES];
                    
                }
                

                
                
            }
            else
            {
                [guestVC setEventID:self.eventId];
                
              
                    
                guestVC.eventType = @"N";
                
                guestVC.isGroupAdmin = is_admin;
              
                
                [self.navigationController pushViewController:guestVC animated:YES];
               
                
                
            }
            
            
        }
        
        
        
    }
    
    
    if (indexPath.section == 2)
    {
        
        
        if ([[eventData valueForKey:@"NA"]count]>0)
        {
            
            if (indexPath.row < 3)
            {
                
          
                NSString *userID;
                
                userID =[NSString stringWithFormat:@"%@",[[[eventData valueForKey:@"NA"] objectAtIndex:indexPath.row] valueForKey:@"id"]];
                
                
                if([userID isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
                {
                    RegistrationViewController *registrationVC =[[RegistrationViewController alloc] initWithNibName:@"RegistrationViewController" bundle:nil];
                    [registrationVC setIsEdit:YES];
                    [registrationVC setIsMy:NO];
                    
                    [self.navigationController pushViewController:registrationVC animated:YES];
                }
                else
                {
                    OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
                    [otherVC setUserId:userID];
                    [self.navigationController pushViewController:otherVC animated:YES];
                    
                }
                

                
                
            }
            else
            {
                
                [guestVC setEventID:self.eventId];
                
                guestVC.eventType = @"NA";
                
                guestVC.isGroupAdmin = is_admin;
             
                [self.navigationController pushViewController:guestVC animated:YES];
                
                
            }
            
            
        }
        
        
    }

}


#pragma mark ---------------- Make Admin ------------------

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!isMyEvent)
    {
        
         return NO; 
    }
    
    
    if (indexPath.section == 0)
    {
        
        if (indexPath.row < 3)
        {
            if([[[[eventData valueForKey:@"YES"] objectAtIndex:indexPath.row] valueForKey:@"is_admin"]isEqualToString:@"Y"])
            {
                return NO;
                
            }
            else{
                
                return YES;
                
                
            }
            
        }
        else{
            
            return NO;
        }
        
        
    }
    
    return NO;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"here");
        
    }
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Make Admin"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              //insert your Make admin Code here
                                              
                                              if(DELEGATE.connectedToNetwork)
                                              {
                                                  
                                                  NSString *frndID;
                                                  
                                                  frndID =[NSString stringWithFormat:@"%@",[[[eventData valueForKey:@"YES"] objectAtIndex:indexPath.row] valueForKey:@"id"]];
                                               
                                                  [mc MakeAdmin:[USER_DEFAULTS valueForKey:@"userid"] eventid:eventId friendid:frndID Sel:@selector(makeAdmin:)];
                                                  
                                              }
                                              
                                          }];
    deleteAction.backgroundColor = AmHappyColor;
    
    return @[deleteAction];
}

-(void)makeAdmin:(NSDictionary *)results
{
    NSLog(@"%@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        [self viewDidLoad];
        
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
        
        
    }
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark ------- Textfield Delegate -----

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==self.txtlfldEmail)
    {
        if([self.txtlfldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtlfldEmail setText:@""];
            
        }
        
    }
  
}


-(BOOL)InviteValidation
{
    
    if ([self.txtlfldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
        
        
        [DELEGATE showalert:self Message:@"Please enter email address." AlertFlag:1 ButtonFlag:1];
     
        return NO;
        
        
        
    }
   
    else if (![DELEGATE IsValidEmail:self.txtlfldEmail.text])
    {

        
        
        [DELEGATE showalert:self Message:@"Please enter valid email address." AlertFlag:1 ButtonFlag:1];
        
   
   
        return NO;
     
    }
        
   
    else
    {
        return TRUE;
    }
    
    
    
}

- (IBAction)cancelClicked:(id)sender
{
    [self.view endEditing:YES];
    
    [self.viewEmailPopUp setFrame:CGRectMake(0,-1500,self.viewEmailPopUp.frame.size.width,  self.viewEmailPopUp.frame.size.height)];
}



- (IBAction)sendClicked:(id)sender
{
    
     [self.view endEditing:YES];
    
    if ([self InviteValidation])
    {
        
        if ([DELEGATE connectedToNetwork])
        {

            [mc eventInviteByMail:[USER_DEFAULTS valueForKey:@"userid"] eventid:eventId email:self.txtlfldEmail.text  Sel:@selector(responseEnvite:)];
         
        }
     
    }
    
    
}

- (IBAction)clickMail:(id)sender
{

    isShow=NO;
    [self.viewButtons setHidden:YES];
    
    self.txtlfldEmail.text = @"";
    
    [self.viewEmailPopUp setFrame:CGRectMake(0, 0, self.viewEmailPopUp.frame.size.width, self.viewEmailPopUp.frame.size.height)];

//    UIAlertView  *av = [[UIAlertView alloc]initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Enter Email"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Send"], nil];
//    
//    av.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    [[av textFieldAtIndex:0] setPlaceholder:[localization localizedStringForKey:@"Email"]];
//    [[av textFieldAtIndex:0] setDelegate:self];
//    [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeEmailAddress];
//    [av setTag:2];
//    [av show];

    
    
}


#pragma mark ---------- Alertview Delegate --------------


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
                   
                    
                    [mc eventInviteByMail:[USER_DEFAULTS valueForKey:@"userid"] eventid:eventId email:[alertView textFieldAtIndex:0].text  Sel:@selector(responseEnvite:)];
                    
                }
            }
            else
            {
                
                UIAlertView *a = [[UIAlertView alloc]initWithTitle:@"" message:@"Please enter valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [a show];
               // [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter valid email address."] AlertFlag:1 ButtonFlag:1];
               
            }
            
            
        }
    }
    
}

-(void)responseEnvite:(NSDictionary *)dict
{
    
    NSLog(@"%@",dict);
    
    if ([[NSString stringWithFormat:@"%@",[dict valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        
        
        [self.viewEmailPopUp setFrame:CGRectMake(0,-1500,self.viewEmailPopUp.frame.size.width,  self.viewEmailPopUp.frame.size.height)];
        
//        UIAlertView *a = [[UIAlertView alloc]initWithTitle:@"" message:@"Invite Sent Successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [a show];
        
        [DELEGATE showalert:self Message:@"Invite Sent Successfully." AlertFlag:1 ButtonFlag:1];
        
    }
    else
    {
        [DELEGATE showalert:self Message:[dict valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
//        UIAlertView *a = [[UIAlertView alloc]initWithTitle:@"" message:[dict valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [a show];
    }
    
}


-(void)ok1BtnTapped:(id)sender
{
    
     [[self.view viewWithTag:123] removeFromSuperview];
    
    
}








- (IBAction)clickGroup:(id)sender
{
    
    
    InviteGroupViewController *objVC = [[InviteGroupViewController alloc]init];
    
    objVC.eventID = eventId;
  
    [self.navigationController pushViewController:objVC animated:YES];
    

    
    
}

- (IBAction)clickamHappyUsers:(id)sender
{
    
    AppFriendViewControllerViewController *objVC = [[AppFriendViewControllerViewController alloc]init];
    
    objVC.isHideBtnAdd = YES;
    
    objVC.eventID = [[NSString alloc]init];
    
    objVC.eventID = eventId;
    
    [self.navigationController pushViewController:objVC animated:YES];
    
    
    
}

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)clickAdd:(id)sender
{

    if(isShow)
    {
        isShow=NO;
        [self.viewButtons setHidden:YES];
    }
    else
    {
        isShow=YES;
        [self.viewButtons setHidden:NO];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    isShow=NO;
    [self.viewButtons setHidden:YES];
    
}

@end

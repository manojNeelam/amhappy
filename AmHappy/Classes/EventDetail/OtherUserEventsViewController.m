//
//  OtherUserEventsViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 14/09/15.
//
//

#import "OtherUserEventsViewController.h"
#import "ModelClass.h"
#import "EventListCell.h"
#import "UIImageView+WebCache.h"
#import "EventDetailViewController.h"
#import "Toast+UIView.h"

@interface OtherUserEventsViewController ()

@end

@implementation OtherUserEventsViewController
{
    ModelClass *mc;
    NSMutableArray *upcomingArray;
    NSMutableArray *expiredArray;
    
    UIToolbar *mytoolbar1;
   
    
    BOOL isSearching;
    NSMutableArray *searchUpcomingArray;
    NSMutableArray *searchExpiredArray;
    
      BOOL isExpired;

    BOOL isSearch;
}
@synthesize lblTitle,tblEvents,txtSearch,userid,isMy,userName;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.baseSearchView setHidden:YES];
    CGRect frame = self.baseExpiredUpcomingButtons.frame;
    frame.origin.y = frame.origin.y - 40;
    self.baseExpiredUpcomingButtons.frame = frame;
    
    frame = self.tblEvents.frame;
    frame.origin.y = frame.origin.y - 40;
    self.tblEvents.frame = frame;

   // [self adjustUpcomingExpiredHeader];
    
    mc=[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    upcomingArray =[[NSMutableArray alloc] init];
    expiredArray =[[NSMutableArray alloc] init];
    searchUpcomingArray =[[NSMutableArray alloc] init];
    searchExpiredArray =[[NSMutableArray alloc] init];
    

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
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    mytoolbar1.items = [NSArray arrayWithObjects:flexibleSpace,done1, nil];
    
    self.txtSearch.inputAccessoryView =mytoolbar1;
    
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];
    
    if(isMy)
    {
        self.lblTitle.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:@"Event invitation"]];

        if(DELEGATE.connectedToNetwork)
        {
            [mc otherUpcomingInvitation:[USER_DEFAULTS valueForKey:@"userid"] Otherid:nil Sel:@selector(responseGetOtherUpcoming:)];
        }
    }
    else
    {
        
       // NSLog(@"user is %@",[USER_DEFAULTS valueForKey:@"User"]);
        
        if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"E"])
        {
              self.lblTitle.text =[NSString stringWithFormat:@"%@%@",self.userName,[localization localizedStringForKey:@"'s Events"]];
        }
        else
        {
              self.lblTitle.text =[NSString stringWithFormat:@"%@ %@",[localization localizedStringForKey:@"'s Events"],self.userName];
        }
      

        
        if(DELEGATE.connectedToNetwork)
        {
            [mc otherUpcomingInvitation:[USER_DEFAULTS valueForKey:@"userid"] Otherid:[NSString stringWithFormat:@"%@",self.userid] Sel:@selector(responseGetOtherUpcoming:)];
        }
    }
    

}

-(void)adjustUpcomingExpiredHeader
{
    
    self.btnUpcoming.frame = CGRectMake(0,txtSearch.frame.origin.y + txtSearch.frame.size.height,ScreenSize.width/2,self.btnUpcoming.frame.size.height);
    
    self.btnExpired.frame = CGRectMake(self.btnUpcoming.frame.origin.x+self.btnUpcoming.frame.size.width,_btnUpcoming.frame.origin.y ,self.btnUpcoming.frame.size.width,self.btnExpired.frame.size.height);
    
    
}
-(void)responseGetOtherUpcoming:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [upcomingArray removeAllObjects];
        [upcomingArray addObjectsFromArray:[results valueForKey:@"Event"]];
        [self.tblEvents reloadData];
    }
    if(DELEGATE.connectedToNetwork)
    {
        [mc otherExpiredInvitation:[USER_DEFAULTS valueForKey:@"userid"] Otherid:[NSString stringWithFormat:@"%@",self.userid] Sel:@selector(responseGetOtherEvents:)];
    }
}
-(void)responseGetOtherEvents:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [expiredArray removeAllObjects];
        [expiredArray addObjectsFromArray:[results valueForKey:@"Event"]];
        [self.tblEvents reloadData];
        
        if(upcomingArray.count==0 && expiredArray.count==0)
        {
            [self.view makeToast:[localization localizedStringForKey:@"No result found"]
                        duration:2.0
                        position:@"center"];
        }
    }
    else
    {
        if(expiredArray.count==0)
        {
            [self.view makeToast:[localization localizedStringForKey:@"No result found"]
                        duration:2.0
                        position:@"center"];
        }
      //  [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
}
-(void)donePressed
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//    return 2;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 50;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    UIView *headerView = [[UIView alloc]
//                          initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 50)];
//    UILabel *title =[[UILabel alloc] init];
//    [title setFrame:CGRectMake(0,0,self.view.frame.size.width, 50)];
//    
//    
//    if(section==0)
//    {
//        [title setText:[localization localizedStringForKey:@"Upcoming Events"]];
//        [headerView setBackgroundColor:[UIColor colorWithRed:(146.0/255.f) green:(188.0/255.f) blue:(0.0/255.f) alpha:1.0f]];
//    }
//    else if (section==1)
//    {
//        [title setText:[localization localizedStringForKey:@"Expired Events"]];
//        [headerView setBackgroundColor:[UIColor colorWithRed:(135.0/255.f) green:(135.0/255.f) blue:(135.0/255.f) alpha:1.0f]];
//        
//    }
//    [title setTextColor:[UIColor whiteColor]];
//
//    [title setTextAlignment:NSTextAlignmentCenter];
//    
//    [headerView addSubview:title];
//    
//    return headerView;
//    
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearching)
    {
        if(!isExpired)
        {
            return searchUpcomingArray.count;
        }
        else if (isExpired)
        {
            return searchExpiredArray.count;
        }
        else return 0;
    }
    else
    {
        
        if(!isExpired)
        {
            return upcomingArray.count;
        }
        else if (isExpired)
        {
            return expiredArray.count;
        }
        else return 0;
     
    }
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EventListCell *cell = (EventListCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EventListCell" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
    }
    
    if(IS_IPAD)
    {
        [cell.lblPrivate setFont:FONT_Regular(18)];
        [cell.lblName setFont:FONT_Regular(22)];
        [cell.lblDate setFont:FONT_Regular(18)];
        
    }
    else
    {
        /* [cell.lblPrivate setFont:FONT_Regular(10)];
         [cell.lblName setFont:FONT_Regular(15)];
         [cell.lblDate setFont:FONT_Regular(12)];*/
        
        
    }
    
    cell.imgEvent.layer.masksToBounds = YES;
    cell.imgEvent.layer.cornerRadius = 25.0;
    
   
    
    if(isSearching)
    {
        if(!isExpired)
        {
            cell.lblDate.text =[self getDate1:[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"date"]];
            cell.lblName.text =[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            cell.lblPrivate.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"type"]]];
            if([[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgEvent sd_setImageWithURL:[NSURL URLWithString:[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                
            }
            
            if([[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"Private"])
            {
                [cell.lblPrivate setTextColor:[UIColor colorWithRed:82.0/255.0f green:125.0/255.0f blue:255.0/255.0f alpha:1.0]];
            }
            else if([[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"Public"])
            {
                [cell.lblPrivate setTextColor:[UIColor colorWithRed:145.0/255.0f green:185.0/255.0f blue:0.0/255.0f alpha:1.0]];
            }
            
            if(self.isMy)
            {
                if([[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"is_new"] isEqualToString:@"Y"])
                {
                    UILabel *lblNew =[[UILabel alloc] initWithFrame:CGRectMake(cell.lblPrivate.frame.origin.x+cell.lblPrivate.frame.size.width-20, cell.lblPrivate.frame.origin.y+5, 35, cell.lblPrivate.frame.size.height-5)];
                    lblNew.layer.masksToBounds =YES;
                    lblNew.layer.cornerRadius =5.0;
                    lblNew.backgroundColor =[UIColor redColor];
                    lblNew.textColor =[UIColor whiteColor];
                    [lblNew setFont:[UIFont systemFontOfSize:11]];
                    lblNew.textAlignment =NSTextAlignmentCenter;
                    lblNew.numberOfLines =0;
                    [lblNew setMinimumScaleFactor:0.5];
                    lblNew.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:@"New"]];
                    [cell addSubview:lblNew];
                }
                
            }
          
        }
        else
        {
            cell.lblDate.text =[self getDate1:[[searchExpiredArray objectAtIndex:indexPath.row] valueForKey:@"date"]];
            cell.lblName.text =[[searchExpiredArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            
            cell.lblPrivate.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:[[searchExpiredArray objectAtIndex:indexPath.row] valueForKey:@"type"]]];
            
            if([[[searchExpiredArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgEvent sd_setImageWithURL:[NSURL URLWithString:[[searchExpiredArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                
            }
            
            [cell.lblPrivate setTextColor:[UIColor grayColor]];
        }
        
    }
    else
    {
        if(!isExpired)
        {
            cell.lblDate.text =[self getDate1:[[upcomingArray objectAtIndex:indexPath.row] valueForKey:@"date"]];
            cell.lblName.text =[[upcomingArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            
            cell.lblPrivate.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:[[upcomingArray objectAtIndex:indexPath.row] valueForKey:@"type"]]];
            
            if([[[upcomingArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgEvent sd_setImageWithURL:[NSURL URLWithString:[[upcomingArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                
                
            }
            
            
            if([[[upcomingArray objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"Private"])
            {
                [cell.lblPrivate setTextColor:[UIColor colorWithRed:82.0/255.0f green:125.0/255.0f blue:255.0/255.0f alpha:1.0]];
            }
            else if([[[upcomingArray objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"Public"])
            {
                [cell.lblPrivate setTextColor:[UIColor colorWithRed:145.0/255.0f green:185.0/255.0f blue:0.0/255.0f alpha:1.0]];
            }
            
            if(self.isMy)
            {
                
                if([[[upcomingArray objectAtIndex:indexPath.row] valueForKey:@"is_new"] isEqualToString:@"Y"])
                {
                    UILabel *lblNew =[[UILabel alloc] initWithFrame:CGRectMake(cell.lblPrivate.frame.origin.x+cell.lblPrivate.frame.size.width-20, cell.lblPrivate.frame.origin.y+5, 35, cell.lblPrivate.frame.size.height-5)];
                    lblNew.layer.masksToBounds =YES;
                    lblNew.layer.cornerRadius =5.0;
                    lblNew.backgroundColor =[UIColor redColor];
                    lblNew.textColor =[UIColor whiteColor];
                    [lblNew setFont:[UIFont systemFontOfSize:10]];
                    lblNew.textAlignment =NSTextAlignmentCenter;
                    lblNew.numberOfLines =0;
                    [lblNew setMinimumScaleFactor:0.5];
                   // [lblNew sizeToFit];
                    lblNew.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:@"New"]];
                    [cell addSubview:lblNew];
                }
                
            }
        }
        else
        {
            cell.lblDate.text =[self getDate1:[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"date"]];
            cell.lblName.text =[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            
            cell.lblPrivate.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"type"]]];
            
            if([[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgEvent sd_setImageWithURL:[NSURL URLWithString:[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                
                
            }
            
            
                [cell.lblPrivate setTextColor:[UIColor grayColor]];
            
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventDetailViewController *eventVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
    if(isSearching)
    {
        if(!isExpired)
        {
            
            if(self.isMy)
            {
                
                if([[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"is_new"] isEqualToString:@"Y"])
                {
             
                    for (int i = 0; i< [upcomingArray count]; i++)
                    {
                        
                        if ([[[upcomingArray objectAtIndex:i]valueForKey:@"id"]isEqualToNumber:[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"id"]])
                        {
                   
                            NSMutableDictionary *selectedUpcomingEvent = [[upcomingArray objectAtIndex:i]mutableCopy];
                            [selectedUpcomingEvent setValue:[NSString stringWithFormat:@"%@",@"N"] forKey:@"is_new"];
                            [upcomingArray setObject:selectedUpcomingEvent atIndexedSubscript:i];
                          
                            
                        }
                       
                    }
                    
                    
                    
                    NSMutableDictionary *selectedUpcomingEvent = [[searchUpcomingArray objectAtIndex:indexPath.row]mutableCopy];
                    [selectedUpcomingEvent setValue:[NSString stringWithFormat:@"%@",@"N"] forKey:@"is_new"];
                    [searchUpcomingArray setObject:selectedUpcomingEvent atIndexedSubscript:indexPath.row];
                    NSLog(@"%@",searchUpcomingArray);
                    
                }
                
                
                
                
            }
            
            
            eventVC.eventID =[NSString stringWithFormat:@"%@",[[searchUpcomingArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
        }
        else
        {
            eventVC.eventID =[NSString stringWithFormat:@"%@",[[searchExpiredArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
        }
    }
    else
    {
        if(!isExpired)
        {
            
            
            if(self.isMy)
            {
                
                if([[[upcomingArray objectAtIndex:indexPath.row] valueForKey:@"is_new"] isEqualToString:@"Y"])
                {
       
                    NSMutableDictionary *selectedUpcomingEvent = [[upcomingArray objectAtIndex:indexPath.row]mutableCopy];
                    [selectedUpcomingEvent setValue:[NSString stringWithFormat:@"%@",@"N"] forKey:@"is_new"];
                    [upcomingArray setObject:selectedUpcomingEvent atIndexedSubscript:indexPath.row];
                    NSLog(@"%@",upcomingArray);
 
                }
                
            }

       
            eventVC.eventID =[NSString stringWithFormat:@"%@",[[upcomingArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
            
            
            
            
        }
        else
        {
            eventVC.eventID =[NSString stringWithFormat:@"%@",[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
        }
    }
    
    [self.tblEvents reloadData];
    [self.navigationController pushViewController:eventVC animated:YES];
}




- (IBAction)clickUpcoming:(id)sender
{
    
    isExpired = NO;
    
//    [self.btnUpcoming setBackgroundColor:tabSelectedColor];
//    [self.btnExpired setBackgroundColor:tabunSelectedColor];

    [self.lblUpcomingEvents setBackgroundColor:[UIColor colorWithRed:242/255.0f green:107/255.0f blue:4/255.0f alpha:1.0f]];
    [self.lblExpiredEvents setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.7]];
    
    
    [self.tblEvents reloadData];
    
}
- (IBAction)clickExpired:(id)sender
{
    isExpired = YES;
    
    [self.lblExpiredEvents setBackgroundColor:[UIColor colorWithRed:242/255.0f green:107/255.0f blue:4/255.0f alpha:1.0f]];
    [self.lblUpcomingEvents setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.7]];

    
//    [self.btnExpired setBackgroundColor:tabSelectedColor];
//    [self.btnUpcoming setBackgroundColor:tabunSelectedColor];
    
    [self.tblEvents reloadData];
}

-(NSString *)getDate1:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    // NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",formattedDate];
}
- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    isSearching = YES;
    [self filterListForSearchText:searchText];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if([[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        isSearching =NO;
        [self.tblEvents reloadData];
    }
}
- (void)filterListForSearchText:(NSString *)searchText
{
    [searchExpiredArray removeAllObjects];
    [searchUpcomingArray removeAllObjects];

    
    if(upcomingArray.count>0)
    {
        for(int i=0;i<upcomingArray.count;i++)
        {
            NSRange nameRange;
            
            nameRange = [[[upcomingArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            
            if (nameRange.location != NSNotFound) {
                [searchUpcomingArray addObject:[upcomingArray objectAtIndex:i]];
            }
            
            
        }
    }
    if(expiredArray.count>0)
    {
        for(int i=0;i<expiredArray.count;i++)
        {
            NSRange nameRange;
            
            nameRange = [[[expiredArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            
            if (nameRange.location != NSNotFound)
            {
                [searchExpiredArray addObject:[expiredArray objectAtIndex:i]];
            }
            
            
        }
    }
    [self.tblEvents reloadData];
    
}


- (IBAction)onClickSearchButton:(id)sender
{
    //
    if(!isSearch)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            CGRect frame = self.baseExpiredUpcomingButtons.frame;
            frame.origin.y = frame.origin.y + 40;
            self.baseExpiredUpcomingButtons.frame = frame;
            
            frame = self.tblEvents.frame;
            frame.origin.y = frame.origin.y + 40;
            self.tblEvents.frame = frame;
            
        } completion:^(BOOL finished) {
            
            [self.baseSearchView setHidden:NO];
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            [self.baseSearchView setHidden:YES];
            
            CGRect frame = self.baseExpiredUpcomingButtons.frame;
            frame.origin.y = frame.origin.y - 40;
            self.baseExpiredUpcomingButtons.frame = frame;
            
            frame = self.tblEvents.frame;
            frame.origin.y = frame.origin.y - 40;
            self.tblEvents.frame = frame;
        } completion:^(BOOL finished) {
            
            
            
        }];
    }
    
    isSearch = !isSearch;
}

@end

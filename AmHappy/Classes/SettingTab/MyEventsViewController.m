//
//  MyEventsViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 10/02/15.
//
//

#import "MyEventsViewController.h"
#import "ModelClass.h"
#import "EventListCell.h"
#import "UIImageView+WebCache.h"
#import "EventDetailViewController.h"
#import "CommonListViewController.h"
#import "Toast+UIView.h"



@interface MyEventsViewController ()

@end

@implementation MyEventsViewController
{
    ModelClass *mc;
    NSMutableArray *eventsArray;
    NSMutableArray *expiredArray;
    NSMutableArray *autoArray;



    BOOL isSearching;
    UIToolbar *mytoolbar1;
    int deleteTag;
    int sectionTag;
    int searchStart;
    
    BOOL isLast;
    BOOL isLast2;
    int start;
    
    
    BOOL isLastExpire;
    int startExpire;
    
    BOOL isExpired;
    
    UITapGestureRecognizer *imageTap;
    
    
}
@synthesize lblTitle,tableview,isInvite,tableAuto;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self adjustUpcomingExpiredHeader];
    
    
    
   
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    eventsArray =[[NSMutableArray alloc] init];
    expiredArray =[[NSMutableArray alloc] init];
    autoArray =[[NSMutableArray alloc] init];
    
   


    [self clearAllvariables];


    
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
    
    if(self.isInvite)
    {
        self.lblTitle.text =@"Event Invitation";
       // [mc listEventInvitation:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responsegetInviteEvents:)];
        
        if(DELEGATE.connectedToNetwork)
        {
            [mc otherUpcomingInvitation:[USER_DEFAULTS valueForKey:@"userid"] Otherid:nil Sel:@selector(responseGetOtherUpcoming:)];
        }
    }
    else
    {
         [self callApiUpcoming];
    }

}

-(void)adjustUpcomingExpiredHeader
{
   
    self.btnUpcoming.frame = CGRectMake(0,_txtSearch.frame.origin.y + _txtSearch.frame.size.height,ScreenSize.width/2,self.btnUpcoming.frame.size.height);
    
    self.btnExpired.frame = CGRectMake(ScreenSize.width/2,_btnUpcoming.frame.origin.y ,ScreenSize.width/2,self.btnExpired.frame.size.height);
    
    
}

-(void)responseGetOtherUpcoming:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [eventsArray removeAllObjects];
        [eventsArray addObjectsFromArray:[results valueForKey:@"Event"]];
        [self.tableview reloadData];
    }
    if(DELEGATE.connectedToNetwork)
    {
        [mc otherExpiredInvitation:[USER_DEFAULTS valueForKey:@"userid"] Otherid:nil Sel:@selector(responseGetOtherEvents:)];
    }
}
-(void)responseGetOtherEvents:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [expiredArray removeAllObjects];
        [expiredArray addObjectsFromArray:[results valueForKey:@"Event"]];
        [self.tableview reloadData];
    }
    else
    {
        [self.view makeToast:[results valueForKey:@"message"]
                    duration:2.0
                    position:@"center"];
       // [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
}
-(void)clearAllvariables
{
    isSearching =NO;
    
    isLast =NO;
    isLast2 =NO;
    deleteTag =-1;
    
    searchStart =0;
    start =0;
    
    isLastExpire =NO;
    startExpire =0;
}
-(void)donePressed
{
    [self.view endEditing:YES];
    if([[self.txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        [self.tableAuto setHidden:YES];
    }}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self.view];
    CGRect fingerRect = CGRectMake(location.x-5, location.y-5, 10, 10);
    if(self.tableAuto.hidden==NO)
    {
        for(UITableView *view in self.view.subviews){
            CGRect subviewFrame = view.frame;
            if(view.tag!=125)
            {
                if(CGRectIntersectsRect(fingerRect, subviewFrame)){
                    //we found the finally touched view
                    NSLog(@"Yeah !, i found it %@",view);
                    isSearching =NO;
                    searchStart=0;
                    [self.tableAuto setHidden:YES];
                    self.txtSearch.text=@"";
                    [self.tableview setUserInteractionEnabled:YES];
                    [self.view endEditing:YES];
                }
            }
            
            
        }
    }
    
    
    
}
-(void)responsegetInviteEvents:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [eventsArray addObjectsFromArray:[results valueForKey:@"Event"]];
        [self.tableview reloadData];
    
    }
    else
    {
        [self.view makeToast:[results valueForKey:@"message"]
                    duration:2.0
                    position:@"center"];
       // [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

    }
}
-(void)viewWillAppear:(BOOL)animated
{
    isSearching =NO;
    searchStart =0;
    isSearching =NO;
    [self.tableAuto setHidden:YES];
    self.txtSearch.text=@"";
    //[self.tableview reloadData];
    [self.tableview setUserInteractionEnabled:YES];
    
    [self localize];
    
    if(!self.isInvite)
    {
        if(DELEGATE.isEventEditedList)
        {
            DELEGATE.isEventEditedList =NO;
            start =0;
            [eventsArray removeAllObjects];
            [self callApiUpcoming];
        }
    }
    
   
}
-(void)localize
{
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];

    if(self.isInvite)
    {
        [self.lblTitle setText:[localization localizedStringForKey:@"Event Invitation"]];

    }
    else
    {
        [self.lblTitle setText:[localization localizedStringForKey:@"My Events"]];
    }
}
-(void)callApi
{
    if(DELEGATE.connectedToNetwork)
    {
        
        [mc getMyEvents:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",searchStart] Limit:LimitComment Keyword:self.txtSearch.text Sel:@selector(responseCallApi:)];
    }
}
-(void)responseCallApi:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [self.tableAuto setHidden:NO];
        
        if(searchStart==0)
        {
            [autoArray removeAllObjects];
        }
        
        [autoArray addObjectsFromArray:[results valueForKey:@"Event"]];
        if(autoArray.count<=8)
        {
            self.tableAuto.frame =CGRectMake(self.tableAuto.frame.origin.x, self.tableAuto.frame.origin.y, self.tableAuto.frame.size.width, (autoArray.count+1)*40);
        }
        if(autoArray.count>0)
        {
           
            [self.tableAuto reloadData];
            
        }
        else
        {
            isSearching =NO;
            [self.tableAuto setHidden:YES];
            // [self.tableview reloadData];
            [self.tableview setUserInteractionEnabled:YES];
        }
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            isLast2 =YES;
        }
        else
        {
            isLast2 =NO;
        }
    }
    else
    {
        isSearching =NO;
        [self.tableAuto setHidden:YES];
        [self.tableview setUserInteractionEnabled:YES];
    }
    
}


-(void)callApiUpcoming
{
    if(DELEGATE.connectedToNetwork)
    {
        
        //[mc getMyUpcomingEvents:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Keyword:@"" Sel:@selector(responseMyUpcomingEvents:)];
        
        [mc getMyUpcomingEvents:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",start] Limit:@"100" Keyword:@"" Sel:@selector(responseMyUpcomingEvents:)];
    }
}
-(void)responseMyUpcomingEvents:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(start==0)
        {
            [eventsArray removeAllObjects];
        }
        
        [eventsArray addObjectsFromArray:[results valueForKey:@"Event"]];
        if(eventsArray.count>0)
        {
            [self.tableview reloadData];
            
        }
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            isLast =YES;
        }
        else
        {
            isLast =NO;
        }
    }
    else
    {
       /* [self.view makeToast:[results valueForKey:@"message"]
                    duration:2.0
                    position:@"center"];*/
        //[DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

    }
    
    if(start==0)
    {
        [self callApiExpired];
    }
    
}
-(void)callApiExpired
{
    if(DELEGATE.connectedToNetwork)
    {
        
        [mc getMyExpiredEvents:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",startExpire] Limit:LimitComment Keyword:@"" Sel:@selector(responseMyExpiredEvents:)];
    }
}
-(void)responseMyExpiredEvents:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(startExpire==0)
        {
            [expiredArray removeAllObjects];
        }
        [expiredArray addObjectsFromArray:[results valueForKey:@"Event"]];
        if(expiredArray.count>0)
        {
            [self.tableview reloadData];
            
        }
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            isLastExpire =YES;
        }
        else
        {
            isLastExpire =NO;
        }
        
        if(eventsArray.count==0 && expiredArray.count==0)
        {
            [self.view makeToast:[localization localizedStringForKey:@"No result found"]
                        duration:2.0
                        position:@"center"];
        }
    }
    else
    {
        if(eventsArray.count==0)
        {
            [self.view makeToast:[results valueForKey:@"message"]
                        duration:2.0
                        position:@"center"];
        }
        
       // [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Change 10.0 to adjust the distance from bottom
    /* if (maximumOffset - currentOffset <= 10.0  ) {
     // [self loadmoredata];
     if(!self.isInvite)
     {
     if(isSearching)
     {
     if(!isLastSearch)
     {
     searchStart =searchStart+10;
     [self callSearchApi];
     }
     }
     else
     {
     if(!isLast)
     {
     start =start+10;
     [self callApiUpcoming];
     }
     }
     
     }
     
     
     }
     */
    if (maximumOffset - currentOffset <= 10.0  )
    {
        if(!self.isInvite)
        {
            NSArray *visibleRows = [self.tableview visibleCells];
            UITableViewCell *lastVisibleCell = [visibleRows lastObject];
            NSIndexPath *path = [self.tableview indexPathForCell:lastVisibleCell];
            
            if(self.tableAuto.hidden==YES)
            {
                if(!isExpired && path.row == eventsArray.count-1)
                {
                    NSLog(@"section is 0");
                    if(!isLast)
                    {
                        start =start+100;
                        [self callApiUpcoming];
                    }
                }
                if(isExpired  && path.row == expiredArray.count-1)
                {
                    NSLog(@"section is 1");
                    if(!isLastExpire)
                    {
                        startExpire =startExpire+10;
                        [self callApiExpired];
                    }
                }
            }
            
        }
        
    }
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   // NSInteger currentOffset = scrollView.contentOffset.y;
   // NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Change 10.0 to adjust the distance from bottom
  /* if (maximumOffset - currentOffset <= 10.0  ) {
        // [self loadmoredata];
       if(!self.isInvite)
       {
           if(isSearching)
           {
               if(!isLastSearch)
               {
                   searchStart =searchStart+10;
                   [self callSearchApi];
               }
           }
           else
           {
               if(!isLast)
               {
                   start =start+10;
                   [self callApiUpcoming];
               }
           }
           
       }
        
        
    }
    */
   /* if (maximumOffset - currentOffset <= 10.0  )
    {
        if(!self.isInvite)
        {
            NSArray *visibleRows = [self.tableview visibleCells];
            UITableViewCell *lastVisibleCell = [visibleRows lastObject];
            NSIndexPath *path = [self.tableview indexPathForCell:lastVisibleCell];
            
            if(self.tableAuto.hidden==YES)
            {
                if(path.section == 0 && path.row == eventsArray.count-1)
                {
                    NSLog(@"section is 0");
                    if(!isLast)
                    {
                        start =start+10;
                        [self callApiUpcoming];
                    }
                }
                if(path.section == 1 && path.row == expiredArray.count-1)
                {
                    NSLog(@"section is 1");
                    if(!isLastExpire)
                    {
                        startExpire =startExpire+10;
                        [self callApiExpired];
                    }
                }
            }
            
        }
        
    }*/
    
  
}

- (void) handleImageTapFrom: (UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    UIView *view = [recognizer view];
    
   if(isSearching)
    {
       /* if([[[searchArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            //image
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:1];
        }*/
    }
    else
    {
        if(view.superview.tag==0)
        {
            if([[[eventsArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
            {
                //image
                [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[eventsArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:1];
            }
        }
        else
        {
            if([[[expiredArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
            {
                //image
                [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[expiredArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:1];
            }
            
        }
    }
  
   
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    // isSearching = YES;
    [self.tableview setUserInteractionEnabled:NO];

}
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    isSearching = YES;
    if(!self.isInvite)
    {
        if([[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]>=3)
        {
            if([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length%3==0)
            {
                searchStart=0;
                [self callApi];
            }
        }
        
    }
    
    
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
        searchStart=0;
        [self.tableAuto setHidden:YES];
        [self.tableview reloadData];
        [self.tableview setUserInteractionEnabled:YES];
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView ==self.tableAuto)
    {
       
            return autoArray.count;
      
    }
    else
    {
        if(!isExpired)
        {
            return eventsArray.count;
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
    if(tableView==self.tableAuto)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
       
        
        cell.textLabel.text = [[autoArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        [cell.textLabel setTextColor:[UIColor colorWithRed:228.0/255.0 green:123.0/255.0 blue:0.0/255.0 alpha:1]];
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        return cell;
        
    }
    else
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
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTapFrom:)];
        tapGestureRecognizer.delegate = self;
        tapGestureRecognizer.cancelsTouchesInView = YES;
        cell.imgEvent.tag =indexPath.row;
        cell.imgEvent.superview.tag=indexPath.section;
        [cell.imgEvent addGestureRecognizer:tapGestureRecognizer];
        
        
        
        
        if(!isExpired)
        {
            cell.lblDate.text =[self getDate1:[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"date"]];
            cell.lblName.text =[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            // cell.lblPrivate.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"type"];
            cell.lblPrivate.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"type"]]];
            if([[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgEvent sd_setImageWithURL:[NSURL URLWithString:[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                
            }
            
            if([[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"Private"])
            {
                [cell.lblPrivate setTextColor:[UIColor colorWithRed:82.0/255.0f green:125.0/255.0f blue:255.0/255.0f alpha:1.0]];
            }
            else if([[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"Public"])
            {
                [cell.lblPrivate setTextColor:[UIColor colorWithRed:145.0/255.0f green:185.0/255.0f blue:0.0/255.0f alpha:1.0]];
            }
        }
        else
        {
            cell.lblDate.text =[self getDate1:[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"date"]];
            cell.lblName.text =[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            // cell.lblPrivate.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"type"];
            cell.lblPrivate.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"type"]]];
            if([[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgEvent sd_setImageWithURL:[NSURL URLWithString:[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                
            }
            
            [cell.lblPrivate setTextColor:[UIColor grayColor]];
        }
        
        
        cell.imgEvent.contentMode = UIViewContentModeScaleAspectFill;
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
         return cell;


    }
    
    
   
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    [self.view endEditing:YES];
    EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
    if(tableView==self.tableAuto)
    {
            [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[autoArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
    }
    else
    {
        if(!isExpired)
        {
            [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
        }
        else
        {
            [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
        }
        
    }
    
    [self.navigationController pushViewController:eventDetailVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    if(tableView==self.tableAuto)
    {
        return NO;
    }
    else
    {
        if (!isExpired)
        {
            
            if ([[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"is_admin"]isEqualToString:@"N"])
            {
                return YES;
                
            }
            else
            {
                return NO;
                
            }
           
        }
        else{
            
            
            if ([[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"is_admin"]isEqualToString:@"N"])
            {
                return YES;
                
            }
            else
            {
                return NO;
                
            }

            
        }
        
        
    }
    
}
-(NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.tableAuto)
    {
        return nil;
    }
    else
    {
        return [localization localizedStringForKey:@"Delete"];
    }
    
}
-(void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"delete");
    
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[localization localizedStringForKey:@"Delete"]  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                                  if(indexPath.section==0)
                                                  {
                                                      [self deleteEvent:[NSString stringWithFormat:@"%@",[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
                                                  }
                                                  else
                                                  {
                                                      [self deleteEvent:[NSString stringWithFormat:@"%@",[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
                                                  }
                                             
                                              
                                              deleteTag=(int)indexPath.row;
                                              sectionTag =(int)indexPath.section;
                                              
                                          }];
    
    return @[deleteAction];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==self.tableAuto)
    {
        return 40;
    }
    else
    {
        return 60;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView==self.tableAuto && !isLast2)
    {
        return 40;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    /* if(tableView==self.tableAuto && !isLast2)
     {*/
    UIView *headerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0,0,self.tableAuto.frame.size.width, 40)];
    UILabel *title =[[UILabel alloc] init];
    [title setFrame:CGRectMake(0,0,self.tableAuto.frame.size.width, 40)];
    [title setText:[localization localizedStringForKey:@"See more"]];
    // [title setTextColor:[UIColor colorWithRed:(228.0/255.f) green:(123.0/255.f) blue:(0.0/255.f) alpha:1.0f]];
    [title setTextColor:[UIColor whiteColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    
    [headerView addSubview:title];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFooterTap:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = YES;
    [headerView addGestureRecognizer:tapGestureRecognizer];
    
    return headerView;
    //}
    
    
    return nil;
    
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    if(tableView==tableAuto)
//    {
//        return 1;
//    }
//    
//    return 2;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if(tableView==tableAuto)
//    {
//        return 0;
//    }
//    return 50;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if(tableView==tableAuto)
//    {
//        return nil;
//    }
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
- (void) handleFooterTap: (UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    
    CommonListViewController *commonVC =[[CommonListViewController alloc] initWithNibName:@"CommonListViewController" LoadFlag:1 bundle:nil];
    commonVC.keyWord =[NSString stringWithFormat:@"%@",self.txtSearch.text];
    [self.navigationController pushViewController:commonVC animated:YES];
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
-(void)hideTable
{
    if(self.tableAuto.hidden==NO)
    {
        
        isSearching =NO;
        [self.tableAuto setHidden:YES];
        searchStart=0;
        self.txtSearch.text=@"";
        [self.tableview setUserInteractionEnabled:YES];
        [self.view endEditing:YES];
        
    }
    // [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)deleteEvent:(NSString *)eventId
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc deleteEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:eventId Sel:@selector(responseDeleteEvents:)];
    }
}

-(void)responseDeleteEvents:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
    
            if(sectionTag==0)
            {
                [eventsArray removeObjectAtIndex:deleteTag];
            }
            else
            {
                [expiredArray removeObjectAtIndex:deleteTag];
            }
            
            [self.tableview reloadData];
             deleteTag =-1;
       
            sectionTag =-1;
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
       
    }
}

- (IBAction)backTapped:(id)sender
{
    [DELEGATE.tabBarController.tabBar setHidden:NO];
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

- (IBAction)clickUpcoming:(id)sender
{
    
    isExpired = NO;
    
    [self.btnUpcoming setBackgroundColor:tabSelectedColor];
    [self.btnExpired setBackgroundColor:tabunSelectedColor];
    

    [self.tableview reloadData];
    
}
- (IBAction)clickExpired:(id)sender
{
    isExpired = YES;
    
    [self.btnExpired setBackgroundColor:tabSelectedColor];
    [self.btnUpcoming setBackgroundColor:tabunSelectedColor];
    
    [self.tableview reloadData];
}
@end

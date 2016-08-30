//
//  CommonListViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 15/09/15.
//
//

#import "CommonListViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "EventDetailViewController.h"
#import "Toast+UIView.h"

@interface CommonListViewController ()
@end

@implementation CommonListViewController
{
    int loadingFlow;
    ModelClass *mc;
    NSMutableArray *eventsArray;
    NSMutableArray *expiredArray;
    
   
    
    int deleteTag;
    int sectionTag;
    
    BOOL isLast;
    int start;
    
    
    
    BOOL isLastExpire;
    int startExpire;
    
    BOOL isExpired;
    
    BOOL isSearch;
    
}
@synthesize lblTitle,tblEvent,keyWord;

-(id)initWithNibName:(NSString *)nibNameOrNil LoadFlag:(int)loadFlag bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        loadingFlow =loadFlag;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.baseSearchView setHidden:YES];
    CGRect frame = self.baseExpiredUpcomingButtons.frame;
    frame.origin.y = frame.origin.y - 40;
    self.baseExpiredUpcomingButtons.frame = frame;
    
    frame = self.tblEvent.frame;
    frame.origin.y = frame.origin.y - 40;
    self.tblEvent.frame = frame;
    
    
    //[self adjustUpcomingExpiredHeader];
    
    eventsArray =[[NSMutableArray alloc] init];
    expiredArray =[[NSMutableArray alloc] init];
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    [self clearAllvariables];
    
    [self callApiUpcoming];
    
    [self.lblTitle setText:[localization localizedStringForKey:@"Events"]];
    

}

-(void)adjustUpcomingExpiredHeader
{
    
    self.btnUpcoming.frame = CGRectMake(0,self.imgTop.frame.origin.y + self.imgTop.frame.size.height,ScreenSize.width/2,self.btnUpcoming.frame.size.height);
    
    self.btnExpired.frame = CGRectMake(ScreenSize.width/2,_btnUpcoming.frame.origin.y ,ScreenSize.width/2,self.btnExpired.frame.size.height);
    
    
}


-(void)clearAllvariables
{
    
    isLast =NO;
    deleteTag =-1;
    sectionTag =-1;

    start =0;
    isLastExpire =NO;
    startExpire =0;
}
-(NSString *)getCategories
{
    if(DELEGATE.selectedCategoryArray.count==0)
    {
        
        [DELEGATE.selectedCategoryArray addObjectsFromArray:DELEGATE.categoryArray];
        NSString *str =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
        return str;
        
    }
    else
    {
        NSString *str =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
        return str;
    }
}
-(void)callApiUpcoming
{
    if(loadingFlow==1)
    {
        if(DELEGATE.connectedToNetwork)
        {
             [mc getMyUpcomingEvents:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Keyword:[NSString stringWithFormat:@"%@",self.keyWord] Sel:@selector(responseMyUpcomingEvents:)];
        }
    }
    else if (loadingFlow==3)
    {
        if(DELEGATE.connectedToNetwork)
        {
            [mc searchUpcomingEvents:[USER_DEFAULTS valueForKey:@"userid"] Keyword:[NSString stringWithFormat:@"%@",self.keyWord] Category_id:[self getCategories] Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Sel:@selector(responseMyUpcomingEvents:)];
        }
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
            [self.tblEvent reloadData];
            
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
   /* else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }*/
    
    if(start==0)
    {
        [self callApiExpired];
    }
    
}
-(void)callApiExpired
{
    if(loadingFlow==1)
    {
        if(DELEGATE.connectedToNetwork)
        {
            
            [mc getMyExpiredEvents:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",startExpire] Limit:LimitComment Keyword:[NSString stringWithFormat:@"%@",self.keyWord] Sel:@selector(responseSearchExpired:)];
        }
    }
    else if (loadingFlow==3)
    {
        if(DELEGATE.connectedToNetwork)
        {
            [mc searchExpiredEvents:[USER_DEFAULTS valueForKey:@"userid"] Keyword:[NSString stringWithFormat:@"%@",self.keyWord] Category_id:[self getCategories] Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Sel:@selector(responseSearchExpired:)];
        }
    }
    
}
-(void)responseSearchExpired:(NSDictionary *)results
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
            [self.tblEvent reloadData];
            
        }
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            isLastExpire =YES;
        }
        else
        {
            isLastExpire =NO;
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
       /* [self.view makeToast:[results valueForKey:@"message"]
                    duration:2.0
                    position:@"center"];*/
        //[DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
   
    if (maximumOffset - currentOffset <= 10.0  )
    {
            NSArray *visibleRows = [self.tblEvent visibleCells];
            UITableViewCell *lastVisibleCell = [visibleRows lastObject];
            NSIndexPath *path = [self.tblEvent indexPathForCell:lastVisibleCell];
            
        
                if(!isExpired && path.row == eventsArray.count-1)
                {
                    NSLog(@"section is 0");
                    if(!isLast)
                    {
                        start =start+10;
                       // [self callApiUpcoming];
                    }
                }
                if(isExpired && path.row == expiredArray.count-1)
                {
                    NSLog(@"section is 1");
                    if(!isLastExpire)
                    {
                        startExpire =startExpire+10;
                       // [self callApiExpired];
                    }
                }
        
    }
    
    
}
- (void) handleImage: (UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    UIView *view = [recognizer view];
  
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"EventListCell";
    EventListCell *cell = (EventListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImage:)];
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
    
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
   
        if(!isExpired)
        {
            [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
        }
        else
        {
            [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
        }
   
    [self.navigationController pushViewController:eventDetailVC animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    if(loadingFlow==1)
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
}
-(NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(loadingFlow==1)
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
            
            [self.tblEvent reloadData];
            deleteTag =-1;
        sectionTag =-1;
    }
    else
    {
        [self.view makeToast:[results valueForKey:@"message"]
                    duration:2.0
                    position:@"center"];
       // [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
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



- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickUpcoming:(id)sender
{
    
    isExpired = NO;
    
    //[self.btnUpcoming setBackgroundColor:tabSelectedColor];
    //[self.btnExpired setBackgroundColor:tabunSelectedColor];
    
    [self.lblUpcomingEvents setBackgroundColor:[UIColor colorWithRed:242/255.0f green:107/255.0f blue:4/255.0f alpha:1.0f]];
    [self.lblExpiredEvents setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.7]];
    
    [self.tblEvent reloadData];
    
}

- (IBAction)clickExpired:(id)sender
{
    isExpired = YES;
    
    [self.lblExpiredEvents setBackgroundColor:[UIColor colorWithRed:242/255.0f green:107/255.0f blue:4/255.0f alpha:1.0f]];
    [self.lblUpcomingEvents setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.7]];
    
    //[self.btnExpired setBackgroundColor:tabSelectedColor];
    //[self.btnUpcoming setBackgroundColor:tabunSelectedColor];
    
    [self.tblEvent reloadData];
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
            
            frame = self.tblEvent.frame;
            frame.origin.y = frame.origin.y + 40;
            self.tblEvent.frame = frame;
            
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
            
            frame = self.tblEvent.frame;
            frame.origin.y = frame.origin.y - 40;
            self.tblEvent.frame = frame;
        } completion:^(BOOL finished) {
            
            
            
        }];
    }
    
    isSearch = !isSearch;
}

@end

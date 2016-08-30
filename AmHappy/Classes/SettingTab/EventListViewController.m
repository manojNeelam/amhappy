//
//  EventListViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 10/02/15.
//
//

#import "EventListViewController.h"
#import "ModelClass.h"
#import "EventListCell.h"
#import "UIImageView+WebCache.h"
#import "CategoryViewController.h"
#import "EventDetailViewController.h"
#import "CommonListViewController.h"
#import "Toast+UIView.h"

@interface EventListViewController ()

@end

@implementation EventListViewController
{
    ModelClass *mc;
    NSMutableArray *eventsArray;
    NSMutableArray *searchArray;
    NSMutableArray *autoArray;


    int start;
    UIToolbar *mytoolbar2;
    int searchStart;
    BOOL isSearching;
    NSString *resultAsString;
    
    BOOL isLast1;
    BOOL isLast2;
    
    BOOL isFirst;
    
    
    NSMutableArray *expiredArray;
    NSMutableArray *searchExpiredArray;
    int searchExpireStart;
    
    BOOL isLastExpire;
    int startExpire;
    
    BOOL isExpired;


  
}

@synthesize txtSearch,tableview,tableAuto;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self adjustUpcomingExpiredHeader];
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    eventsArray =[[NSMutableArray alloc] init];
    searchArray =[[NSMutableArray alloc] init];
    autoArray =[[NSMutableArray alloc] init];
    
    searchExpiredArray =[[NSMutableArray alloc] init];
    expiredArray =[[NSMutableArray alloc] init];
    
    [self clearAllvariables];

    isSearching =NO;
    isFirst=YES;

    self.txtSearch.delegate =self;
    [self.txtSearch setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

    
    mytoolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    mytoolbar2.barStyle = UIBarStyleBlackOpaque;
    
    
    UIBarButtonItem *done2 = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Done"]
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self action:@selector(donePressed)];
    
    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    mytoolbar2.items = [NSArray arrayWithObjects:flexibleSpace2,done2, nil];
    self.txtSearch.inputAccessoryView =mytoolbar2;
   /* if(DELEGATE.selectedCategoryArray.count==0)
    {
        
        [DELEGATE.selectedCategoryArray addObjectsFromArray:DELEGATE.categoryArray];
         resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
        NSString *str =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
        
        [self callApi:str];
    }
    else
    {
        NSString *str =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
        resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];

        [self callApi:str];
    }*/
    
    [self callUpcomingApi:[self getCategories]];
    
}

-(void)adjustUpcomingExpiredHeader
{
    
    self.btnUpcoming.frame = CGRectMake(0,self.imgTop.frame.origin.y + self.imgTop.frame.size.height,ScreenSize.width/2,self.btnUpcoming.frame.size.height);
    
    self.btnExpired.frame = CGRectMake(ScreenSize.width/2,_btnUpcoming.frame.origin.y ,ScreenSize.width/2,self.btnExpired.frame.size.height);
    
    
}
-(NSString *)getCategories
{
    if(DELEGATE.selectedCategoryArray.count==0)
    {
        
        [DELEGATE.selectedCategoryArray addObjectsFromArray:DELEGATE.categoryArray];
        resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
        NSString *str =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
        return str;
        
    }
    else
    {
        NSString *str =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
        resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
        return str;
    }
}
-(void)clearAllvariables
{
    
    searchStart =0;
    start =0;
    isLast1=NO;
    isLast2=YES;
    isSearching =NO;
    isLastExpire =NO;
    startExpire =0;
    searchExpireStart =0;
}
-(void)callUpcomingApi:(NSString *)catList
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc searchUpcomingEvents:[USER_DEFAULTS valueForKey:@"userid"] Keyword:@"" Category_id:catList Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Sel:@selector(responseUpcomingEvents:)];
    }
}
-(void)responseUpcomingEvents:(NSDictionary *)results
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
            isLast1 =YES;
        }
        else
        {
            isLast1 =NO;
        }
    }
    else
    {
       /* [self.view makeToast:[results valueForKey:@"message"]
                    duration:2.0
                    position:@"center"];*/
       // [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
     
    }
    
    if(start==0)
    {
        [self callExpiredApi:[self getCategories]];
    }
}
-(void)callExpiredApi:(NSString *)catList
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc searchExpiredEvents:[USER_DEFAULTS valueForKey:@"userid"] Keyword:@"" Category_id:catList Start:[NSString stringWithFormat:@"%d",startExpire] Limit:LimitComment Sel:@selector(responseExpiredEvents:)];
    }
}
-(void)responseExpiredEvents:(NSDictionary *)results
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
        /*[self.view makeToast:[results valueForKey:@"message"]
                    duration:2.0
                    position:@"center"];*/
       // [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
}


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
-(void)viewWillAppear:(BOOL)animated
{
    isSearching =NO;
    [self.tableAuto setHidden:YES];
    self.txtSearch.text=@"";
    //[self.tableview reloadData];
    [self.tableview setUserInteractionEnabled:YES];
    if(!isFirst)
    {
        if(DELEGATE.selectedCategoryArray.count==0)
        {
            start =0;
            startExpire =0;
            resultAsString=@"";
            [autoArray removeAllObjects];
            [eventsArray removeAllObjects];
            [searchArray removeAllObjects];
            [expiredArray removeAllObjects];
            [searchExpiredArray removeAllObjects];
            [self.tableview reloadData];

            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];

        }
        else
        {
            start =0;
            startExpire =0;
            [eventsArray removeAllObjects];
            [searchArray removeAllObjects];
            [expiredArray removeAllObjects];
            [searchExpiredArray removeAllObjects];
            resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
            //[self callApi:resultAsString];
            [self callUpcomingApi:resultAsString];
        }

    }
        [self localize];
    
}
-(void)localize
{
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];
}
-(void)callApi:(NSString *)catList
{
    
        if(DELEGATE.connectedToNetwork)
        {
            [mc searchAllEvents:[USER_DEFAULTS valueForKey:@"userid"] Keyword:@"" Category_id:catList Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Sel:@selector(responsegetMyEvents:)];
        }
    
}


-(void)callSearchApi:(NSString *)str
{
    if(DELEGATE.connectedToNetwork)
    {
        if(resultAsString.length>0)
        {
            [mc searchAllEvents:[USER_DEFAULTS valueForKey:@"userid"] Keyword:self.txtSearch.text Category_id:resultAsString Start:[NSString stringWithFormat:@"%d",searchStart] Limit:LimitComment Sel:@selector(responsegetMySearchEvents:)];
        }
        else
        {
            [self.tableAuto setHidden:YES];
            isSearching=NO;
            [autoArray removeAllObjects];
            searchStart=0;
           
        }
        
        
    }
}
-(void)responsegetMyEvents:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [eventsArray addObjectsFromArray:[results valueForKey:@"Event"]];
        if(eventsArray.count>0)
        {
            [self.tableview reloadData];

        }
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            isLast1 =YES;
        }
        else
        {
            isLast1 =NO;
        }
    }
    else
    {
        [self.view makeToast:[results valueForKey:@"message"]
                    duration:2.0
                    position:@"center"];
      //  [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
      
    }
}
-(void)responsegetMySearchEvents:(NSDictionary *)results
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
        if(autoArray.count>0)
        {
            if(autoArray.count<=8)
            {
                self.tableAuto.frame =CGRectMake(self.tableAuto.frame.origin.x, self.tableAuto.frame.origin.y, self.tableAuto.frame.size.width, autoArray.count*40);
            }
            
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

-(void)donePressed
{
    [self.view endEditing:YES];
    if([[self.txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        [self.tableAuto setHidden:YES];
    }
    
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSArray *visibleRows = [self.tableview visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableview indexPathForCell:lastVisibleCell];
    NSLog(@"section is %d",(int)path.section);
    NSLog(@"row is %d",(int)path.row);
    
    
    if(self.tableAuto.hidden==YES)
    {
        if(!isExpired && path.row == eventsArray.count-1)
        {
            NSLog(@"section is 0");
            if(!isLast1)
            {
                start +=10;
                //  [self callApi:resultAsString];
                [self callUpcomingApi:resultAsString];
            }
        }
        if(isExpired && path.row == expiredArray.count-1)
        {
            NSLog(@"section is 1");
            if(!isLastExpire)
            {
                startExpire =startExpire+10;
                [self callExpiredApi:resultAsString];
            }
        }
    }

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   /* NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0  ) {
        // [self loadmoredata];
        
            if(!isLast1)
            {
                start +=10;
                [self callApi:resultAsString];
            }
        
    }*/
    
    
    
   /* NSArray *visibleRows = [self.tableview visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableview indexPathForCell:lastVisibleCell];
    NSLog(@"section is %d",(int)path.section);
    NSLog(@"row is %d",(int)path.row);

    
    if(self.tableAuto.hidden==YES)
    {
        if(path.section == 0 && path.row == eventsArray.count-1)
        {
            NSLog(@"section is 0");
            if(!isLast1)
            {
                start +=10;
              //  [self callApi:resultAsString];
                [self callUpcomingApi:resultAsString];
            }
        }
        if(path.section == 1 && path.row == expiredArray.count-1)
        {
            NSLog(@"section is 1");
            if(!isLastExpire)
            {
                startExpire =startExpire+10;
                [self callExpiredApi:resultAsString];
            }
        }
    }*/
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableview setUserInteractionEnabled:NO];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if([[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        isSearching =NO;
        [self.tableAuto setHidden:YES];
        [self.tableview reloadData];
        [self.tableview setUserInteractionEnabled:YES];

    }
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

- (void) handleImageTap: (UITapGestureRecognizer *)recognizer
{
    UIView *view = [recognizer view];
    if(isSearching)
    {
        /*if([[[searchArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.tableAuto)
    {
        if(autoArray.count>0)
        {
            return autoArray.count;
        }
        
        else return 0;
    }
    else
    {
        if(isSearching)
        {
            if(!isExpired)
            {
                return searchArray.count;
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
                return eventsArray.count;
            }
            else if (isExpired)
            {
                return expiredArray.count;
            }
            else return 0;
        }
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
        if(IS_IPAD)
        {
            //[cell.lblHobbyName setFont:FONT_Regular(22)];
            
        }
        else
        {
            /* [cell.lblPrivate setFont:FONT_Regular(10)];
             [cell.lblName setFont:FONT_Regular(15)];
             [cell.lblDate setFont:FONT_Regular(12)];*/
            
            
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
            [cell.lblPrivate setFont:FONT_Regular(14)];
            [cell.lblName setFont:FONT_Regular(22)];
            [cell.lblDate setFont:FONT_Regular(18)];
            
        }
        else
        {
            //[cell.lblPrivate setFont:FONT_Regular(8)];
           // [cell.lblName setFont:FONT_Regular(16)];
           // [cell.lblDate setFont:FONT_Regular(14)];
        }
        cell.imgEvent.layer.masksToBounds = YES;
        cell.imgEvent.layer.cornerRadius = 25.0;
        
       
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
        tapGestureRecognizer.delegate = self;
        tapGestureRecognizer.cancelsTouchesInView = YES;
        cell.imgEvent.tag =indexPath.row;
        cell.imgEvent.superview.tag =indexPath.section;
        [cell.imgEvent addGestureRecognizer:tapGestureRecognizer];
        
        if(isSearching)
        {
            if(!isExpired)
            {
                cell.lblDate.text =[self getDate:[[searchArray objectAtIndex:indexPath.row] valueForKey:@"date"]];
                cell.lblName.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                // cell.lblPrivate.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"type"];
                cell.lblPrivate.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:[[searchArray objectAtIndex:indexPath.row] valueForKey:@"type"]]];
                if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
                {
                    [cell.imgEvent sd_setImageWithURL:[NSURL URLWithString:[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                    
                }
                
                if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"Private"])
                {
                    [cell.lblPrivate setTextColor:[UIColor colorWithRed:82.0/255.0f green:125.0/255.0f blue:255.0/255.0f alpha:1.0]];
                }
                else if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"type"] isEqualToString:@"Public"])
                {
                    [cell.lblPrivate setTextColor:[UIColor colorWithRed:145.0/255.0f green:185.0/255.0f blue:0.0/255.0f alpha:1.0]];
                }
                
            }
            else
            {
                cell.lblDate.text =[self getDate:[[searchExpiredArray objectAtIndex:indexPath.row] valueForKey:@"date"]];
                cell.lblName.text =[[searchExpiredArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                // cell.lblPrivate.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"type"];
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
                cell.lblDate.text =[self getDate:[[eventsArray objectAtIndex:indexPath.row] valueForKey:@"date"]];
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
                cell.lblDate.text =[self getDate:[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"date"]];
                cell.lblName.text =[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                // cell.lblPrivate.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"type"];
                cell.lblPrivate.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"type"]]];
                if([[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
                {
                    [cell.imgEvent sd_setImageWithURL:[NSURL URLWithString:[[expiredArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                    
                }
                
                [cell.lblPrivate setTextColor:[UIColor grayColor]];
            }
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
        if(isSearching)
        {
            if(!isExpired)
            {
                [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
            }
            else
            {
                [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[searchExpiredArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
            }
            
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
    }
   
    isFirst=NO;
    [self.navigationController pushViewController:eventDetailVC animated:YES];

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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTapFrom:)];
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
- (void) handleImageTapFrom: (UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
    
    CommonListViewController *commonVC =[[CommonListViewController alloc] initWithNibName:@"CommonListViewController" LoadFlag:3 bundle:nil];
    commonVC.keyWord =[NSString stringWithFormat:@"%@",self.txtSearch.text];
    [self.navigationController pushViewController:commonVC animated:YES];
}

-(NSString *)getDate:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",formattedDate];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)textChanged:(UITextField *)sender
{
    if([sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length>0)
    {
        if([sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length%3==0)
        {
            NSString *substring = [NSString stringWithString:sender.text];
            [self callSearchApi:substring];
        }
    }
   
}
- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    //[DELEGATE.selectedCategoryArray removeAllObjects];

}

- (IBAction)filterTapped:(id)sender
{
    CategoryViewController *catVC =[[CategoryViewController alloc] initWithNibName:@"CategoryViewController" bundle:nil];
    [catVC setIsMultiSelect:YES];
    isFirst=NO;
    [self.navigationController pushViewController:catVC animated:YES];
    
    isSearching =NO;
    [self.tableAuto setHidden:YES];
    self.txtSearch.text=@"";
    [self.tableview setUserInteractionEnabled:YES];
    [self.view endEditing:YES];
    
   /* [self.tableAuto setHidden:YES];
    isSearching=NO;
    [autoArray removeAllObjects];
    searchStart=0;*/
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

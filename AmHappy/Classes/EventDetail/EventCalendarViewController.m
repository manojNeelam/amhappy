//
//  EventCalendarViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 18/02/15.
//
//

#import "EventCalendarViewController.h"
#import "ModelClass.h"
#import "VoterListViewController.h"



@interface EventCalendarViewController ()

@end

@implementation EventCalendarViewController
{
    VRGCalendarView *dateCalendar;
    ModelClass *mc;
    int voteTag;
    int votingID;
    
    BOOL isChanged;

}
@synthesize calView,voteDateArray,btnEdit,eventID,isPrivate,peventDate,myVotedId,eventType,endVoting;
- (id)initWithNibName:(NSString *)nibNameOrNil VoteID:(int)voteID bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        votingID =voteID;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",endVoting.description);
    NSLog(@"%@",eventType);
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    isChanged =NO;
    
    self.scrollview.frame=CGRectMake(self.scrollview.frame.origin.x, self.scrollview.frame.origin.y, self.scrollview.frame.size.width, self.scrollview.frame.size.height-49);
    
    if(self.isMy)
    {
        //[self.btnEdit setHidden:NO];
    }
    [self.scrollview setContentSize:CGSizeMake(320, 600)];

    
    if(IS_Ipad)
    {
        self.calView.frame =CGRectMake(self.calView.frame.origin.x, self.calView.frame.origin.y, self.view.bounds.size.width, 500);
        
        self.lblDate.frame =CGRectMake(self.lblDate.frame.origin.x, self.calView.frame.origin.y+530, self.lblDate.frame.size.width, self.lblDate.frame.size.height);
        
        self.tableviewVote.frame =CGRectMake(self.tableviewVote.frame.origin.x, self.lblDate.frame.origin.y+self.lblDate.frame.size.height, self.tableviewVote.frame.size.width, 330);
        [self.scrollview setContentSize:CGSizeMake(320, 800)];

    }
    
    dateCalendar = [[VRGCalendarView alloc] init];
    dateCalendar.delegate=self;
    [dateCalendar setBackgroundColor:[UIColor clearColor]];
   // [dateCalendar setSelectedDate:[NSDate date]];
  
    //[dateCalendar markDates:[NSArray arrayWithObjects:@"20",@"21", nil]];

    NSLog(@"%@",self.voteDateArray);
    
    if(self.voteDateArray.count>0)
    {
        
        //2015-10-30 07:55:00 +0000
        NSLog(@"vote array is %@",self.voteDateArray);
        NSMutableArray *dates =[[NSMutableArray alloc] init];
        for(int i=0;i<self.voteDateArray.count;i++)
        {
                [dates addObject:[self getDate1:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:i] valueForKey:@"date"]]]];
            
        }
        NSLog(@"dates array is %@",dates);
        
        [dateCalendar setCurrentMonth:[self getDate1:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:0] valueForKey:@"date"]]]];
        [dateCalendar selectDate:[self getDay:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:0] valueForKey:@"date"]]]];
        
       // [dateCalendar setSelectedDate:[self getDate1:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:0] valueForKey:@"date"]]]];
        //dateCalendar.currentMonth =[self getDate1:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:0] valueForKey:@"date"]]];

        [dateCalendar setMarkedDates:dates];
    }
    
    if(!self.isPrivate)
    {
        [self.lblDate setHidden:YES];
        [self.tableviewVote setHidden:YES];
        [self.scrollview setContentSize:CGSizeMake(320, 300)];

        NSArray *array =[NSArray arrayWithObject:[self getDate1:[NSString stringWithFormat:@"%@",self.peventDate]]];
        
        [dateCalendar setCurrentMonth:[self getDate1:[NSString stringWithFormat:@"%@",self.peventDate]]];
        [dateCalendar selectDate:[self getDay:[NSString stringWithFormat:@"%@",self.peventDate]]];
        [dateCalendar setMarkedDates:array];

    }
    [self.calView addSubview:dateCalendar];

    // Do any additional setup after loading the view from its nib.
}
-(NSDate *)getDate1:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    return date;
    
}
-(int)getDay:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date]; // Get necessary date components
    
 return  (int) [components day];
    
}


-(void)viewWillAppear:(BOOL)animated
{
     [self localize];
    
}
-(void)localize
{
    [self.lblTitle setText:[localization localizedStringForKey:@"Calendar"]];
    [self.lblDate setText:[localization localizedStringForKey:@"Date (Votes)"]];    
}
-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated {
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate]; // Get necessary date components
    
    [components month]; //gives you month
    
    if([[self getMonths:month] count]>0)
    {
        [calendarView markDates:[self getMonths:month]];
    }
    
    
    //if (month==[components month]) {
       // NSArray *dates = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:5], nil];
       // [calendarView markDates:dates];
   // }
}
-(NSArray *)getMonths:(int)month
{
    NSMutableArray *array =[[NSMutableArray alloc] init];
    
    if(isPrivate)
    {
        for(int i=0;i<self.voteDateArray.count;i++)
        {
            NSDate *dt= [self getDate1:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:i] valueForKey:@"date"]]];
            
            // NSDate *currentDate = [NSDate date];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:dt]; // Get necessary date components
            
            [components month];
            if(month==[components month])
            {
                [array addObject:dt];
            }
        }
    }
    else
    {
        
        NSDate *dt=[self getDate1:[NSString stringWithFormat:@"%@",self.peventDate]];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:dt]; // Get necessary date components
        
        [components month];
        if(month==[components month])
        {
            [array addObject:dt];
        }
    }
    
    return array;
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date {
    NSLog(@"Selected date = %@",date);
    // dateStr =[NSString stringWithFormat:@"%@",date];
    
   // NSDateFormatter  *dateFormatter = [[NSDateFormatter alloc] init] ;
    //[dateFormatter setDateFormat:@"MM/dd/yyyy"];// here set format which you want...
    
   // dateStr = [dateFormatter stringFromDate:date];
    
    //self.txtExpDate.text =[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    
   // NSLog(@"Converted String : %@",dateStr);
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.voteDateArray.count>0)
    {
        return self.voteDateArray.count;
    }
    else return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    VoteListCell *cell = (VoteListCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VoteListCell" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
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
    
    /*
     id: 4,
     date: 1445472000,
     date_vote: 0
     */
    cell.delegate=self;
    cell.btnVote.tag =indexPath.row;
    if(self.isMy)
    {
        //[cell.btnVote setEnabled:NO];
    }
   // NSLog(@"cell.myVotedId is %d",votingID);
   // NSLog(@"cell.myVotedId is %@",[[self.voteDateArray objectAtIndex:indexPath.row] valueForKey:@"id"]);

   // NSLog(@"vote array is %@",[self.voteDateArray objectAtIndex:indexPath.row]);


    if(votingID>=0)
    {
        if(votingID == [[[self.voteDateArray objectAtIndex:indexPath.row] valueForKey:@"id"] intValue])
        {
            [cell.btnVote setImage:[UIImage imageNamed:@"voteHeartOrange.png"] forState:UIControlStateNormal];
        }
    }
    cell.lblVote.text =[NSString stringWithFormat:@"(%@)",[[self.voteDateArray objectAtIndex:indexPath.row] valueForKey:@"date_vote"]];
    cell.lblName.text =[self getDate2:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:indexPath.row] valueForKey:@"date"]]];
    //[cell.lblVote setFrame:CGRectMake(cell.lblName.frame.origin.x+cell.lblName.frame.size.width-50, cell.lblVote.frame.origin.y-10, cell.lblVote.frame.size.width, cell.lblVote.frame.size.height)];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    VoterListViewController *voterVC =[[VoterListViewController alloc] initWithNibName:@"VoterListViewController" bundle:nil];
    [voterVC setEventID:self.eventID];
    [voterVC setIsLocation:NO];
    [voterVC setDataDict:[self.voteDateArray objectAtIndex:indexPath.row] ];
    [self.navigationController pushViewController:voterVC animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}
-(NSString *)getDate2:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
  //  NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy hh:mm a"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",formattedDate];
}
-(void)voteBtnTapped:(UIButton *)sender
{
    voteTag =(int)[sender tag];
    if(DELEGATE.connectedToNetwork)
    {
        
        if (![eventType isEqualToString:@"Expired"])
        {
            
            if ([eventType isEqualToString:@"Private"])
            {
                
                if (![endVoting.description isEqualToString:@""])
                {
          
                    NSTimeInterval today = [[NSDate date]timeIntervalSince1970];
                    
                    NSLog(@"%@",[NSNumber numberWithDouble:today]);
                    
                    NSLog(@"%@",endVoting);
                    
                    if ([[NSNumber numberWithDouble:today]doubleValue] < [endVoting doubleValue])
                    {
                        
                        
                         [mc vote:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Type:@"D" Voteid:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:[sender tag]] valueForKey:@"id"]] Sel:@selector(responseGiveVote:)];
                        
                    }
                    else{
          
                          [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Voting date is over"] AlertFlag:1 ButtonFlag:1];
                        
                        
                    }
                 
                }
                else{
                    
                    
                      [mc vote:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Type:@"D" Voteid:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:[sender tag]] valueForKey:@"id"]] Sel:@selector(responseGiveVote:)];
                    
                    
                    
                }
             
            }
            else
            {
                
                       [mc vote:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Type:@"D" Voteid:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:[sender tag]] valueForKey:@"id"]] Sel:@selector(responseGiveVote:)];
                
                
            }
  
            
         
        }
        else{
            
            
              [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Event is expired"] AlertFlag:1 ButtonFlag:1];
          
        }
        
       
    }
}
-(void)responseGiveVote:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
     {
         votingID=[[[self.voteDateArray objectAtIndex:voteTag] valueForKey:@"id"] intValue];
         //[self setMyVotedId:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:voteTag] valueForKey:@"id"]]];
        // self.myVotedId =[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:voteTag] valueForKey:@"id"]];
         
         NSLog(@"self.myVotedId is %d",votingID);
         NSLog(@"myVotedId is %@",[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:voteTag] valueForKey:@"id"]]);

         voteTag =-1;
         self.voteDateArray =[NSArray arrayWithArray:[[results valueForKey:@"Event"] valueForKey:@"Date"]];
         [self.tableviewVote reloadData];
         
         isChanged =YES;
         
     }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
       /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backTapped:(id)sender
{
    if(isChanged)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"voteChanged" object:nil userInfo:nil];

    }

    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)editTapped:(id)sender {
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
@end

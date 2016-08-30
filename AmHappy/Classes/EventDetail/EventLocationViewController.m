//
//  EventLocationViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 18/02/15.
//
//

#import "EventLocationViewController.h"
#import "ModelClass.h"
#import "AnnotationViewController.h"
#import "UIImageView+WebCache.h"
#import "VoteListCell.h"
#import "VoterListViewController.h"

@interface EventLocationViewController ()

@end

@implementation EventLocationViewController
{
     ModelClass *mc;
    NSMutableArray *eventArray;
    NSMutableArray *voterArray;
    int voteTag;
    int votingID;
    BOOL isChanged;


}
@synthesize lblTitle,lblDate,scrollview,tableviewVote,userMap,btnEdit,voteDateArray,isMy,eventID,catID,imgURL,pDictionary,isPrivate,type,eventName,publicMap,myVotedId,endVoting,eventType;

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
    self.userMap.delegate =self;
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    isChanged =NO;
    
    [self.userMap setDelegate:self];
    if(self.isMy)
    {
       // [self.btnEdit setHidden:NO];
    }
    
    
    [self.scrollview setContentSize:CGSizeMake(320, 600)];
   
    
    if(self.voteDateArray.count>0)
    {
        [self showEvents];
    }

    if(!self.isPrivate)
    {
        [self.lblDate setHidden:YES];
        [self.tableviewVote setHidden:YES];
        [self.userMap setHidden:YES];

        // self.publicMap.frame =CGRectMake(self.publicMap.frame.origin.x, self.publicMap.frame.origin.y, self.view.bounds.size.width, (self.view.frame.size.height-120)/2);
        [self.scrollview setContentSize:CGSizeMake(320, 100)];
        [self showEvents];
        //self.userMap.frame =CGRectMake(self.userMap.frame.origin.x, self.userMap.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-94);
       // self.scrollview.frame =CGRectMake(self.scrollview.frame.origin.x, self.scrollview.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-94);
        
    }
    else
    {
        [self.publicMap setHidden:YES];

        if(IS_Ipad)
        {
            self.userMap.frame =CGRectMake(self.userMap.frame.origin.x, self.userMap.frame.origin.y, self.view.bounds.size.width, 500);
            
            self.lblDate.frame =CGRectMake(self.lblDate.frame.origin.x, self.userMap.frame.origin.y+530, self.lblDate.frame.size.width, self.lblDate.frame.size.height);
            
            self.tableviewVote.frame =CGRectMake(self.tableviewVote.frame.origin.x, self.lblDate.frame.origin.y+self.lblDate.frame.size.height, self.tableviewVote.frame.size.width, 330);
            
            [self.scrollview setContentSize:CGSizeMake(320, 800)];
            
        }
    }

    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
 
}
-(void)localize
{
    [self.lblTitle setText:[localization localizedStringForKey:@"Location"]];
    [self.lblDate setText:[localization localizedStringForKey:@"Location (Votes)"]];
}
-(void)showEvents
{
    if(!self.isPrivate)
    {
        
        NSLog(@" dictionary is %@",self.pDictionary);
        
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[[self.pDictionary valueForKey:@"Plat"] doubleValue];
        placeCoord.longitude=[[self.pDictionary valueForKey:@"Plong"] doubleValue];
        
        AnnotationViewController    *ann1 = [[AnnotationViewController alloc] init];
        ann1.title = self.eventName;
        if([self.pDictionary valueForKey:@"Plat"])
        {
            ann1.subtitle = [NSString stringWithFormat:@"%@",[self.pDictionary valueForKey:@"Paddress"]];
            
        }
        ann1.coordinate=placeCoord;
        region.center.latitude =ann1.coordinate.latitude;
        region.center.longitude =ann1.coordinate.longitude;
        ann1.tagValue =0;
        ann1.catID=self.catID ;
        
        [self.publicMap addAnnotation:ann1];
        [self.publicMap setRegion:region animated:YES];
    }
    else
    {
        for(int i=0;i<self.voteDateArray.count;i++)
        {
            
            
            CLLocationCoordinate2D placeCoord;
            
            //Set the lat and long.
            placeCoord.latitude=[[[self.voteDateArray objectAtIndex:i] valueForKey:@"latitude"] doubleValue];
            placeCoord.longitude=[[[self.voteDateArray objectAtIndex:i] valueForKey:@"longitude"] doubleValue];
            
            AnnotationViewController    *ann1 = [[AnnotationViewController alloc] init];
            ann1.title = [NSString stringWithFormat:@"%@",self.eventName];
            ann1.subtitle = [[self.voteDateArray objectAtIndex:i] valueForKey:@"location"];
            ann1.coordinate=placeCoord;
            region.center.latitude =ann1.coordinate.latitude;
            region.center.longitude =ann1.coordinate.longitude;
            ann1.tagValue =i;
            ann1.catID=self.catID ;
            
            [self.userMap addAnnotation:ann1];
            [self.userMap setRegion:region animated:YES];
        }
    }
    
    [self zoomToFitMapAnnotations:self.userMap];
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

-(void)zoomToFitMapAnnotations:(MKMapView *)mapview1 {
    if ([mapview1.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in userMap.annotations) {
        
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region3;
    region3.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region3.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region3.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    
    // Add a little extra space on the sides
    region3.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region3 = [mapview1 regionThatFits:region3];
    if((region3.center.longitude >= -180.00000000) || (region3.center.longitude <= 180.00000000) || (region3.center.latitude >= -90.00000000) || (region.center.latitude >= 90.00000000)){
        if (region3.span.latitudeDelta >=180 || region3.span.longitudeDelta >=180) {
            region3.span.latitudeDelta = 180.0;
            region3.span.longitudeDelta =180.0;
            [mapview1 setRegion:region3 animated:YES];
        }
        else
        {
            [mapview1 setRegion:region3 animated:YES];
        }
        
    }
    else
    {
        if (region3.span.latitudeDelta >=180 || region3.span.longitudeDelta >=180) {
            region3.span.latitudeDelta = 180.0;
            region3.span.longitudeDelta =180.0;
            [mapview1 setRegion:region3 animated:YES];
        }else
        {
            [mapview1 setRegion:region3 animated:YES];
        }
        
    }
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:
(id <MKAnnotation>)annotation {
    
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"] ;
    if(pinView == nil)
    {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"] ;
    }
    
    if (annotation == mV.userLocation)
    {
        self.userMap.userLocation.title = @"Current Location";
        //  [self.mapview setRegion:MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500) animated:YES];
        [pinView setImage:[UIImage imageNamed:@"currentLocation.png"]];
        
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = NO;
        pinView.canShowCallout = YES;
        [pinView setSelected:YES animated:YES];
        
        
        
    }
    else
    {
        
        pinView.animatesDrop = NO;        
        pinView.canShowCallout = YES;
        [pinView setSelected:YES animated:YES];
      //  pinView.pinColor = MKPinAnnotationColorRed;

        
        if ([annotation isKindOfClass:[AnnotationViewController class]])
        {
            
            AnnotationViewController *ann=(AnnotationViewController *)annotation;
            if(ann.catID !=0)
            {
                //[pinView setImage:[UIImage imageNamed:@"currentLocation.png"]];
                if(!self.isPrivate)
                {
                    [pinView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d%d.png",ann.catID,type]]];
                }
                else
                {
                    [pinView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d2.png",ann.catID]]];
                }
                NSLog(@"image is %@",[NSString stringWithFormat:@"%d2.png",ann.catID]);

              /*  UIImageView *img =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
                //  [img sd_setImageWithURL:[NSURL URLWithString:[[eventArray objectAtIndex:ann.arrayId] valueForKey:@"image"]]];
                if(self.imgURL)
                {
                    [img sd_setImageWithURL:[NSURL URLWithString:self.imgURL] placeholderImage:[UIImage imageNamed:@"logo.png"]];
                }
                else
                {
                    [img setImage:[UIImage imageNamed:@"mapIcon.png"]];
                }
                
                pinView.leftCalloutAccessoryView =img;*/
            }
            
            
            
         /*   if(ann.catID !=0)
            {
                [pinView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",ann.tagValue]]];
                UIImageView *img =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
                //  [img sd_setImageWithURL:[NSURL URLWithString:[[eventArray objectAtIndex:ann.arrayId] valueForKey:@"image"]]];
                [img sd_setImageWithURL:[NSURL URLWithString:[[eventArray objectAtIndex:ann.arrayId] valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"logo.png"]];
                pinView.leftCalloutAccessoryView =img;
                
            }*/
        }
        
        
    }
    
    return pinView;
    
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
     id: 5,
     location: "Ahmedabad, Gujarat, India",
     latitude: "23.022505",
     longitude: "72.571365",
     location_vote: 0
     */
    cell.delegate=self;
    cell.btnVote.tag =indexPath.row;
    if(self.isMy)
    {
        //[cell.btnVote setEnabled:NO];
    }
    
    NSLog(@"cell.myVotedId is %d",votingID);
    NSLog(@"cell.myVotedId is %@",[[self.voteDateArray objectAtIndex:indexPath.row] valueForKey:@"id"]);
    
    
    
    if(votingID>=0)
    {
        if(votingID == [[[self.voteDateArray objectAtIndex:indexPath.row] valueForKey:@"id"] intValue])
        {
            [cell.btnVote setImage:[UIImage imageNamed:@"voteHeartOrange.png"] forState:UIControlStateNormal];
        }
    }
    [cell.imvEvent setImage:[UIImage imageNamed:@"voteLocation.png"]];
    cell.lblVote.text =[NSString stringWithFormat:@"(%@)",[[self.voteDateArray objectAtIndex:indexPath.row] valueForKey:@"location_vote"]];
    cell.lblName.text =[[self.voteDateArray objectAtIndex:indexPath.row] valueForKey:@"location"];
    [cell.lblVote setFrame:CGRectMake(cell.lblName.frame.origin.x+cell.lblName.frame.size.width+5, cell.lblVote.frame.origin.y, cell.lblVote.frame.size.width, cell.lblVote.frame.size.height)];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VoterListViewController *voterVC =[[VoterListViewController alloc] initWithNibName:@"VoterListViewController" bundle:nil];
    [voterVC setEventID:self.eventID];
    [voterVC setIsLocation:YES];
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
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",formattedDate];
}
-(void)voteBtnTapped:(UIButton *)sender
{
    voteTag =(int)[sender tag];
//    if(DELEGATE.connectedToNetwork)
//    {
//        [mc vote:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Type:@"L" Voteid:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:[sender tag]] valueForKey:@"id"]] Sel:@selector(responseGiveVote:)];
//    }
//    
    
    
    
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
               
                       [mc vote:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Type:@"L" Voteid:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:[sender tag]] valueForKey:@"id"]] Sel:@selector(responseGiveVote:)];
                        
                    }
                    else{
                        
                        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Voting date is over"] AlertFlag:1 ButtonFlag:1];
                        
                        
                    }
                    
                }
                else{
                    
                    [mc vote:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Type:@"L" Voteid:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:[sender tag]] valueForKey:@"id"]] Sel:@selector(responseGiveVote:)];
                    
                    
                    
                }
                
            }
            else
            {
                
                 [mc vote:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Type:@"L" Voteid:[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:[sender tag]] valueForKey:@"id"]] Sel:@selector(responseGiveVote:)];
                
                
            }
            
            
            
        }
        else{
            
            
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Event is expired"] AlertFlag:1 ButtonFlag:1];
            
        }
        
        
    }
}
-(void)responseGiveVote:(NSDictionary *)results
{
    // NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        votingID=[[[self.voteDateArray objectAtIndex:voteTag] valueForKey:@"id"] intValue];
      
        
        NSLog(@"self.myVotedId is %d",votingID);
        NSLog(@"myVotedId is %@",[NSString stringWithFormat:@"%@",[[self.voteDateArray objectAtIndex:voteTag] valueForKey:@"id"]]);
        voteTag =-1;
        self.voteDateArray =[NSArray arrayWithArray:[NSArray arrayWithArray:[[results valueForKey:@"Event"] valueForKey:@"Location"]]];
        [self.tableviewVote reloadData];
        isChanged=YES;
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
    
    
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

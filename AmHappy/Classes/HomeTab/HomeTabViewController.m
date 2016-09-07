                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //
//  HomeTabViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import "HomeTabViewController.h"
#import "ModelClass.h"
#import "AnnotationViewController.h"
#import "UIImageView+WebCache.h"
#import "CategoryViewController.h"
#import "MyEventsViewController.h"
#import "EventListViewController.h"
#import "EventDetailViewController.h"
#import "FriendRequestViewController.h"
#import "Toast+UIView.h"

#import "TYMActivityIndicatorView.h"
#import "TYMActivityIndicatorViewViewController.h"
#import "OtherUserEventsViewController.h"

#import "EventTabViewController.h"
#import "MenuCustomCell.h"
#import "MenuData.h"
#import "DWBubbleMenuButton.h"
#import "RGSColorSlider.h"
#import "MilesLanguageView.h"
#import "LeftMenuView.h"

#import "PrivacyPolicyViewController.h"
#import "NotificationViewController.h"

#import "EventTabViewController.h"
#import "CommonListViewController.h"
#import "LoginViewController.h"
#import "ReachUsViewController.h"
#import "SearchLocationView.h"

#define openState 1
#define closeState 0


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface HomeTabViewController () <LeftMenuViewDelegate, MilesLanguageViewDelegate, SearchLocationViewDelegate, DWBubbleMenuViewDelegate>
{
    BOOL isMenuOpened;
    MilesLanguageView *milesLanguageView;
    LeftMenuView *leftMenuView;
    SearchLocationView *searchLocationView;
    AnnotationViewController *selectedAnnotation;
    
    DWBubbleMenuButton *downMenuButton;
    UITapGestureRecognizer *tap;
    NSArray *menuList;
    
    int selectedIndex;
}

@end

@implementation HomeTabViewController
{
    ModelClass *mc;
    NSUserDefaults *defaults;
    NSMutableArray *postArray;
    int start;
    TYMActivityIndicatorViewViewController *drk;
    NSMutableDictionary *addressDict;
    int loadTag;
    NSMutableArray *catArray;
    NSMutableArray *eventArray;
    float lat;float longi;
    BOOL isFilter;
    BOOL isfirst;
    BOOL isSearched;
    int badgeCount;
    UIToolbar *mytoolbar1;
    int inviteCount;
    int requestCount;
}

@synthesize txtSearch,mapView,lblFilter,lblMyEvent,filterView,btnFilter,btnSearch,lblInvitation,lblRequest,lblSearchEvent;

@synthesize lblNotificationEvent,lblNotificationFriend,lblTotalNotification;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
        {
            
            [self tabBarItem].selectedImage = [[UIImage imageNamed:@"home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self tabBarItem].image = [[UIImage imageNamed:@"home2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else
        {
            [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"home.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home2.png"]];
        }
        
        
    }
    
    self.title =[localization localizedStringForKey:@"Home"];
    return self;
}

-(void)updateCount
{
    int count =[[[self tabBarItem] badgeValue] intValue];
    if(count==0)
    {
        //[[self tabBarItem] setBadgeValue:nil];
        [self.lblTotalNotification setHidden:YES];
        
    }
    else
    {
        //[[self tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",count-1]];
        [self.lblTotalNotification setHidden:NO];
        self.lblTotalNotification.text =[NSString stringWithFormat:@"%d",count-1];
  
    }
    
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
    
    
    
    if(count==0)
    {
        [item setBadgeValue:nil];
    }
    else
    {
        [item setBadgeValue:[NSString stringWithFormat:@"%d",count]];
    }
 
}


-(void)refresh
{
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
    int count =[[item badgeValue] intValue];
    [item setBadgeValue:[NSString stringWithFormat:@"%d",count+1]];
    [self viewWillAppear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    inviteCount =0;
    requestCount=0;
    
    
    mc=[[ModelClass alloc] init];
    mc.delegate =self;
    selectedIndex =-1;
    
    self.lblNotificationFriend.layer.masksToBounds=YES;
    self.lblNotificationFriend.layer.cornerRadius=9.0;
    
    self.lblNotificationEvent.layer.masksToBounds=YES;
    self.lblNotificationEvent.layer.cornerRadius=9.0;
    
    self.lblTotalNotification.layer.masksToBounds=YES;
    self.lblTotalNotification.layer.cornerRadius=9.0;
    
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    self.mapView.delegate =self;
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    isfirst=YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"becomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:@"becomeActive" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"friendChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCount) name:@"friendChanged" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"refreshView" object:nil];
    
    isFilter =NO;
    defaults =[NSUserDefaults standardUserDefaults];
    postArray =[[NSMutableArray alloc] init];
    catArray =[[NSMutableArray alloc] initWithArray:DELEGATE.categoryArray];
    eventArray =[[NSMutableArray alloc] init];
    [self requestAlwaysAuthorization];
    [self.txtSearch setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    start =0;
    self.txtSearch.delegate =self;
    
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
   
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    mytoolbar1.items = [NSArray arrayWithObjects:flexibleSpace,done1, nil];
    
    self.txtSearch.inputAccessoryView =mytoolbar1;
    
    [self setMenuData];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view layoutIfNeeded];
    
    if(!downMenuButton || downMenuButton == nil)
    {
        [self eventsView];
    }
}

-(void)setCorners
{
    
//    self.lblNotificationEvent.layer.cornerRadius = self.lblNotificationEvent.frame.size.width/2;
//    self.lblNotificationFriend.layer.cornerRadius = self.lblNotificationEvent.frame.size.width/2;
//    self.lblNotificationEvent.clipsToBounds = YES;
//    self.lblNotificationFriend.clipsToBounds = YES;
  
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.viewFilter.frame = CGRectMake(1500, 0, ScreenSize.width, ScreenSize.height-50);
}

-(void)updateSideMeuState:(int)state
{
    
    switch (state)
    {
        case 0:
       
              [self closeMenu];
         
            break;
         
        case 1:
        
            [self openMenu];
            
            break;
            
        default:
            
            [self closeMenu];
            
            break;
    }
    
    
 
}

-(void)closeMenu
{
    
    self.viewFilter.alpha = 1;
    self.viewFilter.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
    self.viewFilter.frame = CGRectMake(0, 0, ScreenSize.width, ScreenSize.height-50);
    
    [UIView animateWithDuration:0.7 animations:^{
        
        self.viewFilter.alpha = 0;
        self.viewFilter.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1);
        
        self.viewFilter.frame = CGRectMake(1500, 0, ScreenSize.width, ScreenSize.height-50);
        
        
    }];
    
    
//    [UIView animateWithDuration:0
//                     animations:^{
//                         self.viewFilter.frame = CGRectMake(0, 0, ScreenSize.width, ScreenSize.height-50);
//                     }
//                     completion:^(BOOL finished)
//     {
//         
//         [UIView animateWithDuration:0.5
//                          animations:^{
//                              
//                              self.viewFilter.frame = CGRectMake(1500, 0, ScreenSize.width, ScreenSize.height-50);
//                          }];
//     }];

}

-(void)openMenu
{
    
    self.viewFilter.alpha = 0;
    self.viewFilter.layer.transform = CATransform3DMakeScale(-10,-10,-10);
   
    self.viewFilter.frame = CGRectMake(-1500, 0, ScreenSize.width, ScreenSize.height/2);

    [UIView animateWithDuration:0.5 animations:^{
        
        self.viewFilter.alpha = 1;
        self.viewFilter.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1);
        
       self.viewFilter.frame = CGRectMake(0, 0, ScreenSize.width, ScreenSize.height-50);

        
    }];

    
//    [UIView animateWithDuration:0
//                     animations:^{
//                         self.viewFilter.frame = CGRectMake(1500, 0, ScreenSize.width, ScreenSize.height-50);
//                     }
//                     completion:^(BOOL finished)
//     {
//         
//         [UIView animateWithDuration:0.5
//                          animations:^{
//                              
//                              self.viewFilter.frame = CGRectMake(0, 0, ScreenSize.width, ScreenSize.height-50);
//                          }];
//     }];

}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch ;
    touch = [[event allTouches] anyObject];
    
    
    if ([touch view] != filterView)
    {
        //Do what ever you want
        
       // [self.filterView setHidden:YES];
        //isFilter =NO;
    }
}

-(void)becomeActive
{
    [self viewWillAppear:NO];
}

-(void)donePressed
{
    [self.view endEditing:YES];
}

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusDenied)
    {
        
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? [localization localizedStringForKey:@"Location services are off"] : [localization localizedStringForKey:@"Background location is not enabled"];
        NSString *message2 = [localization localizedStringForKey:@"To use background location you must turn on 'Always' in the Location Services Settings"];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message2
                                                           delegate:self
                                                  cancelButtonTitle:[localization localizedStringForKey:@"Cancel"]
                                                  otherButtonTitles:[localization localizedStringForKey:@"Settings"], nil];
        alertView.tag = 150;
        [alertView show];
    }
    else if (status == kCLAuthorizationStatusNotDetermined) {
       // [DELEGATE.locationManager requestAlwaysAuthorization];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 150)
    {
        if (buttonIndex == 1)
        {
           // NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
           // [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
    else if ([alertView.message isEqualToString:[localization localizedStringForKey:@"Are you sure, you want to Logout?"]]){
        if (buttonIndex == 0)
        {
            if(DELEGATE.connectedToNetwork)
            {
                [mc logout:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responsegetLogout:)];
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.view layoutIfNeeded];
    self.const_BaseMenuView_Horizontal.constant = self.view.frame.size.width;
    
    self.viewFilter.frame = CGRectMake(1500, 0, ScreenSize.width, ScreenSize.height-50);
    //[self.filterView setHidden:YES];
    isFilter =NO;
    [self localize];
    if(!isSearched)
    {
        lat =DELEGATE.locationManager.location.coordinate.latitude;
        longi =DELEGATE.locationManager.location.coordinate.longitude;
    }
    //http://install.diawi.com/C95M9h
    if(DELEGATE.selectedCategoryArray.count==0)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];

        if(isfirst)
        {
            [DELEGATE.selectedCategoryArray addObjectsFromArray:DELEGATE.categoryArray];
             NSString *resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
            [self callApi:resultAsString];
        }
        else
        {
            [self.view makeToast:[localization localizedStringForKey:@"No result found"]
                        duration:2.0
                        position:@"center"];
            
            //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        }
    }
    else
    {
        NSString *resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
        [self callApi:resultAsString];
    }
}

-(void)localize
{
    self.title =[localization localizedStringForKey:@"Home"];
    self.lblRequest.text =[localization localizedStringForKey:@"Friend Request"];
    self.lblMyEvent.text =[localization localizedStringForKey:@"My Events"];
    self.lblInvitation.text =[localization localizedStringForKey:@"Event Invitation"];
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search location"]];
    self.lblSearchEvent.text =[localization localizedStringForKey:@"Search Event"];
    self.lblFilter.text =[localization localizedStringForKey:@"Filter"];
}

-(void)callApi:(NSString *)catList
{
    return;
    
    if(isSearched)
    {
         [mc getHomeEvents:[USER_DEFAULTS valueForKey:@"userid"] Latitude:[NSString stringWithFormat:@"%f",lat] Longitude:[NSString stringWithFormat:@"%f",longi] Category_id:catList Sel:@selector(responsegetEvents:)];
        
       //  [DELEGATE showalert:nil Message:[NSString stringWithFormat:@"latitude is %f and longitude is %f",lat,longi] AlertFlag:1 ButtonFlag:1];
    }
    else
    {
        if(DELEGATE.locationManager.location.coordinate.latitude>0 && DELEGATE.locationManager.location.coordinate.longitude>0)
        {
            [USER_DEFAULTS setValue:[NSString stringWithFormat:@"%f",DELEGATE.locationManager.location.coordinate.latitude] forKey:@"lastLat"];
            [USER_DEFAULTS setValue:[NSString stringWithFormat:@"%f",DELEGATE.locationManager.location.coordinate.longitude] forKey:@"lastlong"];
            [USER_DEFAULTS synchronize];
        }
        if(DELEGATE.connectedToNetwork)
        {
            if(lat>0 && longi>0)
            {
                NSLog(@"user id is %@",[USER_DEFAULTS valueForKey:@"userid"]);
               [mc getHomeEvents:[USER_DEFAULTS valueForKey:@"userid"] Latitude:[NSString stringWithFormat:@"%f",lat] Longitude:[NSString stringWithFormat:@"%f",longi] Category_id:catList Sel:@selector(responsegetEvents:)];
              //  [DELEGATE showalert:nil Message:[NSString stringWithFormat:@"latitude is %f and longitude is %f",lat,longi] AlertFlag:1 ButtonFlag:1];
                
              // [mc getHomeEvents:[USER_DEFAULTS valueForKey:@"userid"] Latitude:@"40.3755556" Longitude:@"-3.6355556" Category_id:catList Sel:@selector(responsegetEvents:)];
            }
            else if([USER_DEFAULTS valueForKey:@"lastLat"])
            {
                
                    [mc getHomeEvents:[USER_DEFAULTS valueForKey:@"userid"] Latitude:[NSString stringWithFormat:@"%f",[[USER_DEFAULTS valueForKey:@"lastLat"] floatValue]] Longitude:[NSString stringWithFormat:@"%f",[[USER_DEFAULTS valueForKey:@"lastlong"] floatValue]] Category_id:catList Sel:@selector(responsegetEvents:)];
                    
                  //  [DELEGATE showalert:nil Message:[NSString stringWithFormat:@"latitude is %f and longitude is %f",[[USER_DEFAULTS valueForKey:@"lastLat"] floatValue],[[USER_DEFAULTS valueForKey:@"lastlong"] floatValue]] AlertFlag:1 ButtonFlag:1];
                
            }
            else
            {
                [mc getHomeEvents:[USER_DEFAULTS valueForKey:@"userid"] Latitude:[NSString stringWithFormat:@"%f",lat] Longitude:[NSString stringWithFormat:@"%f",longi] Category_id:catList Sel:@selector(responsegetEvents:)];
               // [DELEGATE showalert:nil Message:[NSString stringWithFormat:@"latitude is %f and longitude is %f",lat,longi] AlertFlag:1 ButtonFlag:1];
            }
        }
    }
    
   // [mc getHomeEvents:[USER_DEFAULTS valueForKey:@"userid"] Latitude:@"40.5252821" Longitude:@"-3.8160296" Category_id:catList Sel:@selector(responsegetEvents:)];
}

-(void)responsegetEvents:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if([results valueForKey:@"request_count"])
    {
        badgeCount =[[results valueForKey:@"total_count"] intValue];
    
        //DELEGATE.frinedReqbadgeValue =[[results valueForKey:@"request_count"] intValue];
        if(badgeCount==0)
        {
           // [[self tabBarItem] setBadgeValue:nil];
            [self.lblTotalNotification setHidden:YES];
        }
        else
        {
           // [[self tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
            [self.lblTotalNotification setHidden:NO];
            self.lblTotalNotification.text =[NSString stringWithFormat:@"%d",badgeCount];
        }
        
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
        if(badgeCount==0)
        {
            [item setBadgeValue:nil];
        }
        else
        {
            [item setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
        }
        
//        UITabBarItem *item2 = [self.tabBarController.tabBar.items objectAtIndex:3];
//        
//        if(DELEGATE.frinedReqbadgeValue==0)
//        {
//            [item2 setBadgeValue:nil];
//        }
//        else
//        {
//            [item2 setBadgeValue:[NSString stringWithFormat:@"%d",DELEGATE.frinedReqbadgeValue]];
//        }

    }
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        inviteCount =[[results valueForKey:@"invite_count"] intValue];
        requestCount =[[results valueForKey:@"request_count"] intValue];
        self.lblNotificationEvent.text =[NSString stringWithFormat:@"%d",inviteCount];
        self.lblNotificationFriend.text =[NSString stringWithFormat:@"%d",requestCount];
        
        if(inviteCount==0)
        {
            [self.lblNotificationEvent setHidden:YES];
        }
        else
        {
            [self.lblNotificationEvent setHidden:NO];
        }
        
        if(requestCount==0)
        {
            [self.lblNotificationFriend setHidden:YES];
        }
        else
        {
            [self.lblNotificationFriend setHidden:NO];
        }
            
    
        
        if(isfirst)
        {
            isfirst=NO;
        }
        [self.mapView removeAnnotations:self.mapView.annotations];

       // [DELEGATE.selectedCategoryArray removeAllObjects];
        [eventArray removeAllObjects];
        //eventArray =nil;
        [eventArray addObjectsFromArray:[results valueForKey:@"Event"]];
        if(eventArray.count>0)
        {
            [self showEvents];
            [self zoomToFitMapAnnotations:self.mapView];
        }
        else
        {
           // self.mapView.userLocation.coordinate
            if(!isSearched)
            {
                if(DELEGATE.locationManager.location.coordinate.latitude>0)
                {
                    double miles = 5.0;
                    double scalingFactor = ABS( (cos(2 * M_PI * self.mapView.userLocation.coordinate.latitude / 360.0) ));
                    
                    MKCoordinateSpan span;
                    
                    span.latitudeDelta = miles/69.0;
                    span.longitudeDelta = miles/(scalingFactor * 69.0);
                    
                    MKCoordinateRegion region1;
                    region1.span = span;
                    region1.center = self.mapView.userLocation.coordinate;
                    
                    [mapView setRegion:region1 animated:YES];
                }
            }
           
            
           
        }
    }
    else
    {
       // [self.mapView removeAnnotations:self.mapView.annotations];
        [self.view makeToast:[results valueForKey:@"message"]
                    duration:2.0
                    position:@"center"];
        //[DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        if(!isSearched)
        {
            if(DELEGATE.locationManager.location.coordinate.latitude>0)
            {
                double miles = 5.0;
                double scalingFactor = ABS( (cos(2 * M_PI * self.mapView.userLocation.coordinate.latitude / 360.0) ));
                
                MKCoordinateSpan span;
                
                span.latitudeDelta = miles/69.0;
                span.longitudeDelta = miles/(scalingFactor * 69.0);
                
                MKCoordinateRegion region1;
                region1.span = span;
                region1.center = self.mapView.userLocation.coordinate;
                
                [mapView setRegion:region1 animated:YES];
            }
        }

       /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
    
    
    
    
}
-(void)showEvents
{
    for(int i=0;i<eventArray.count;i++)
    {
       //eventArray =nil;
        /*
         {
         "category_id" = 2;
         date = 1422921600;
         description = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt laoreet dolore magna aliquam tincidunt erat volutpat laoreet dolore magna aliquam tincidunt erat volutpat.";
         id = 1;
         image = "http://192.168.1.100/apps/amhappy/web/img/uploads/events/1146f763feab31c106ef8827666aa585.jpg";
         latitude = "23.05";
         location = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit,India";
         longitude = "72.04";
         name = test;
         type = Expired;
         },

         */
      //  NSLog(@"date is %@",[self getDate:[[eventArray objectAtIndex:i] valueForKey:@"date"]]);
        
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[[[eventArray objectAtIndex:i] valueForKey:@"latitude"] doubleValue];
        placeCoord.longitude=[[[eventArray objectAtIndex:i] valueForKey:@"longitude"] doubleValue];
        
        AnnotationViewController    *ann1 = [[AnnotationViewController alloc] init];
        ann1.title = [[eventArray objectAtIndex:i] valueForKey:@"name"];
        ann1.subtitle = [self getDate:[[eventArray objectAtIndex:i] valueForKey:@"date"]];
        ann1.coordinate=placeCoord;
        region.center.latitude =ann1.coordinate.latitude;
        region.center.longitude =ann1.coordinate.longitude;
        [ann1 setCatID:[[[eventArray objectAtIndex:i] valueForKey:@"category_id"] intValue]];
        [ann1 setArrayId:i];
        [ann1 setEventId:[[[eventArray objectAtIndex:i] valueForKey:@"id"] intValue]];
        
        
        if([[[eventArray objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"Expired"])
        {
            [ann1 setTagValue:[[NSString stringWithFormat:@"%@3",[[eventArray objectAtIndex:i] valueForKey:@"category_id"]] intValue]];
        }
        else if ([[[eventArray objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"Private"])
        {
            [ann1 setTagValue:[[NSString stringWithFormat:@"%@2",[[eventArray objectAtIndex:i] valueForKey:@"category_id"]] intValue]];
        }
        else if ([[[eventArray objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"Public"])
        {
            [ann1 setTagValue:[[NSString stringWithFormat:@"%@1",[[eventArray objectAtIndex:i] valueForKey:@"category_id"]] intValue]];
        }
        NSLog(@"ann tag is %d",ann1.tagValue);
        NSLog(@"ann tag is %@",ann1.subtitle);
        NSLog(@"ann tag is %d",ann1.catID);
        [self.mapView addAnnotation:ann1];
       // [self.mapView setRegion:region animated:YES];
    }
}
-(NSString *)getDate:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MM'/'dd'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",formattedDate];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   // [self.filterView setHidden:YES];
    isFilter =NO;
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if([self.txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length >0)
    {
        [self searchMap:textField.text];
    }
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    
    return [super canPerformAction:action withSender:sender];
}
-(void)searchMap:(NSString *)searchAddress
{
    //https://maps.googleapis.com/maps/api/place/search/json?location=-33.8670522,151.1957362&radius=500&types=grocery_or_supermarket&sensor=true&key=AIzaSyAiFpFd85eMtfbvmVNEYuNds5TEF9FjIPI
    
    if([DELEGATE connectedToNetwork])
    {
        NSArray *array1 =[[NSArray alloc] initWithArray:self.mapView.annotations];
        if(array1.count >0)
        {
          //  [self.mapView removeAnnotations:array1];
            
        }
        
        [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
        [self queryGooglePlaces:searchAddress];
        // self.txtSearch.text = @"";
    }
}
-(void) queryGooglePlaces:(NSString *)addressStr {
    
    
    
    //float lat =DELEGATE.locationManager.location.coordinate.latitude;
   // float lon =DELEGATE.locationManager.location.coordinate.longitude;
  
    
    
    // NSString *url = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&&sensor=true&key=%@&name=%@", lat, lon, kGOOGLE_API_KEY,addressStr]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = [[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", addressStr]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // NSLog(@"url is %@",url);
    
    
    
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
}
- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    
    NSArray* places = [json objectForKey:@"results"];
    if(places)
    {
        [self plotPositions:places];

    }
    else
    {
        [drk hide];
        //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        [self.view makeToast:[localization localizedStringForKey:@"No result found"]
                    duration:2.0
                    position:@"center"];

        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:@"No result found" delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
}

- (void)plotPositions:(NSArray *)data
{
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    if(data.count>0)
    {
        for (int i=0; i<[data count]; i++)
        {
            //Retrieve the NSDictionary object in each index of the array.
            NSDictionary* place = [data objectAtIndex:i];
            //   NSLog(@"place is %@",place);
            
            //There is a specific NSDictionary object that gives us location info.
            NSDictionary *geo = [place objectForKey:@"geometry"];
            
            //Get our name and address info for adding to a pin.
            NSString *name;
            if([[place objectForKey:@"address_components"] count]>0)
            {
                name=[[[place objectForKey:@"address_components"] objectAtIndex:0] valueForKey:@"short_name"];
            }
            else
            {
                name=[place objectForKey:@"formatted_address"];
            }
            
            NSString *vicinity=[place objectForKey:@"formatted_address"];
            
            //Get the lat and long for the location.
            NSDictionary *loc = [geo objectForKey:@"location"];
            
            //Create a special variable to hold this coordinate info.
            CLLocationCoordinate2D placeCoord;
            
            //Set the lat and long.
            placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
            placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
            
            //Create a new annotiation.
            
            selectedAnnotation = [[AnnotationViewController alloc] init];
            selectedAnnotation.title = name;
            selectedAnnotation.subtitle = vicinity;
            selectedAnnotation.coordinate=placeCoord;
            region.center.latitude =selectedAnnotation.coordinate.latitude;
            region.center.longitude =selectedAnnotation.coordinate.longitude;
            lat=placeCoord.latitude;
            longi =placeCoord.longitude;
            // region.span.latitudeDelta = 0.01;
            
            [self.mapView addAnnotation:selectedAnnotation];
            
            [self.mapView setRegion:region animated:YES];
            isSearched =YES;
            
            if(DELEGATE.selectedCategoryArray.count==0)
            {
                //[self.mapView removeAnnotations:self.mapView.annotations];
                if(isfirst)
                {
                    [DELEGATE.selectedCategoryArray addObjectsFromArray:DELEGATE.categoryArray];
                    NSString *resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
                    [self callApi:resultAsString];
                }
                else
                {
                    [self.view makeToast:[localization localizedStringForKey:@"No result found"]
                                duration:2.0
                                position:@"center"];
                   // [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
                }
            }
            else
            {
                NSString *resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
                [self callApi:resultAsString];
            }            //   [self.mapview setCenterCoordinate:region.center animated:YES];
            break;
        }
        [self zoomToFitMapAnnotations:self.mapView];
    }
    else
    {
        [drk hide];
        
        [self.view makeToast:[localization localizedStringForKey:@"No result found"]
                    duration:2.0
                    position:@"center"];
        
       // [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
      /*  UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"No result found"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
        [alert show];*/
    }
    [drk hide];
    // [self zoomToFitMapAnnotations:self.mapview];
}

-(void)zoomToFitMapAnnotations:(MKMapView *)mapview1 {
    if ([mapview1.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations) {
        
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
    if (!view.rightCalloutAccessoryView)
    {
       /* if ([view.annotation isKindOfClass:[AnnotationViewController class]])
        {
            AnnotationViewController *ann=(AnnotationViewController *)view.annotation;
           // NSLog(@"ann tag is %@",ann.tagValue);
            NSLog(@"ann tag is %@",ann.subtitle);
            NSLog(@"ann tag is %d",ann.catID);


            if(ann.catID ==0)
            {
                if(DELEGATE.connectedToNetwork)
                {
                    NSString *resultAsString;
                    if(DELEGATE.selectedCategoryArray.count>0)
                    {
                        resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
                        
                    }
                    else
                    {
                        resultAsString =[catArray componentsJoinedByString:@","];
                    }
                    
                    lat =ann.coordinate.latitude;
                    longi =ann.coordinate.longitude;

                    [mc getHomeEvents:[USER_DEFAULTS valueForKey:@"userid"] Latitude:[NSString stringWithFormat:@"%f",ann.coordinate.latitude] Longitude:[NSString stringWithFormat:@"%f",ann.coordinate.longitude] Category_id:resultAsString Sel:@selector(responsegetEvents:)];
                }
            }

        }*/
    }
    
}
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:
(id <MKAnnotation>)annotation {
    
    MKAnnotationView *pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"] ;
    if(pinView == nil)
    {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"] ;
    }
    
    if (annotation == mV.userLocation)
    {
        self.mapView.userLocation.title = @"Current Location";
        //  [self.mapview setRegion:MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500) animated:YES];
        [pinView setImage:[UIImage imageNamed:@"currentLocation.png"]];

      //  pinView.pinColor = MKPinAnnotationColorRed;
      //  pinView.animatesDrop = NO;
        pinView.canShowCallout = YES;
        [pinView setSelected:YES animated:YES];
    }
    else
    {
       // pinView.animatesDrop = NO;
      //  pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.canShowCallout = YES;
        [pinView setSelected:YES animated:YES];
        
        if ([annotation isKindOfClass:[AnnotationViewController class]])
        {
            AnnotationViewController *ann=(AnnotationViewController *)annotation;
            /*if(ann.tagValue.length>0)
            {*/
            if(ann.catID !=0)
            {
                [pinView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",ann.tagValue]]];
                UIImageView *img =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
              //  [img sd_setImageWithURL:[NSURL URLWithString:[[eventArray objectAtIndex:ann.arrayId] valueForKey:@"image"]]];
                [img sd_setImageWithURL:[NSURL URLWithString:[[eventArray objectAtIndex:ann.arrayId] valueForKey:@"thumb_image"]] placeholderImage:[UIImage imageNamed:@"mapIcon.png"]];
                pinView.leftCalloutAccessoryView =img;
                
                UIButton *myDetailAccessoryButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
                myDetailAccessoryButton.frame = CGRectMake(0, 0, 23, 23);
                myDetailAccessoryButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                myDetailAccessoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                pinView.rightCalloutAccessoryView = myDetailAccessoryButton;
            }
            else
            {
                pinView.canShowCallout = YES;
                pinView.image = [UIImage imageNamed:@"currentLocation.png"];
                pinView.calloutOffset = CGPointMake(0, 32);
                pinView.annotation = annotation;
            }
        }
    }
    return pinView;
}


- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView *)pin calloutAccessoryControlTapped:(UIControl *)control
{
    if ([pin.annotation isKindOfClass:[AnnotationViewController class]])
    {
        
        AnnotationViewController *ann=(AnnotationViewController *)pin.annotation;
        /*if(ann.tagValue.length>0)
         {*/
      /*  if(ann.catID !=0)
        {
            [pinView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",ann.tagValue]]];
            UIImageView *img =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            //  [img sd_setImageWithURL:[NSURL URLWithString:[[eventArray objectAtIndex:ann.arrayId] valueForKey:@"image"]]];
            [img sd_setImageWithURL:[NSURL URLWithString:[[eventArray objectAtIndex:ann.arrayId] valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"logo.png"]];
            pinView.leftCalloutAccessoryView =img;
            
            UIButton *myDetailAccessoryButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            myDetailAccessoryButton.frame = CGRectMake(0, 0, 23, 23);
            myDetailAccessoryButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            myDetailAccessoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            pinView.rightCalloutAccessoryView = myDetailAccessoryButton;
            
        }*/
        
        EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
        [eventDetailVC setEventID:[NSString stringWithFormat:@"%d",ann.eventId]];
        [self.navigationController pushViewController:eventDetailVC animated:YES];
        
        
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)searchTapped:(id)sender
{
    EventListViewController *eventVC =[[EventListViewController alloc] initWithNibName:@"EventListViewController" bundle:nil];
    [self.navigationController pushViewController:eventVC animated:YES];
    //[self.filterView setHidden:YES];
    isFilter =NO;
    
}

- (IBAction)filterTapped:(id)sender
{
    
    [self updateSideMeuState:openState];
    
//    if(isFilter)
//    {
//        [self.filterView setHidden:YES];
//        isFilter =NO;
//    }
//    else
//    {
//        [self.filterView setHidden:NO];
//        isFilter =YES;
//    }
   
}
- (IBAction)filter2Tapped:(id)sender
{
    CategoryViewController *catVC =[[CategoryViewController alloc] initWithNibName:@"CategoryViewController" bundle:nil];
    [catVC setIsMultiSelect:YES];
    [self.navigationController pushViewController:catVC animated:YES];
   // [self.filterView setHidden:YES];
    isFilter =NO;
}

- (IBAction)myEventTapped:(id)sender
{
    MyEventsViewController *myVC =[[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
    [myVC setIsInvite:NO];
    [self.navigationController pushViewController:myVC animated:YES];
    //[self.filterView setHidden:YES];
    isFilter =NO;
}
- (IBAction)requestTapped:(id)sender
{
    FriendRequestViewController *frndVC =[[FriendRequestViewController alloc] initWithNibName:@"FriendRequestViewController" bundle:nil];
    [frndVC setIsFriend:YES];
    [self.navigationController pushViewController:frndVC animated:YES];
    //[self.filterView setHidden:YES];
    isFilter =NO;
}
- (IBAction)invitationTapped:(id)sender
{
   /* MyEventsViewController *myVC =[[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
    [myVC setIsInvite:YES];
    [self.navigationController pushViewController:myVC animated:YES];*/
    
    
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
    
    int count =[[item badgeValue] intValue];
    
    [item setBadgeValue:[NSString stringWithFormat:@"%d",count-inviteCount]];
    
    
    //here
    if([[item badgeValue] intValue] <= 0)
    {
        [item setBadgeValue:nil];
    }
    
    //[self.filterView setHidden:YES];
    isFilter =NO;
    
    
    OtherUserEventsViewController *otherVC =[[OtherUserEventsViewController alloc] initWithNibName:@"OtherUserEventsViewController" bundle:nil];
    [otherVC setIsMy:YES];
    [self.navigationController pushViewController:otherVC animated:YES];
}
- (IBAction)myLocationTapped:(id)sender
{
    //[self.filterView setHidden:YES];
    isFilter =NO;
    
    if(isSearched)
    {
        isSearched=NO;
        region.center.latitude =self.mapView.userLocation.coordinate.latitude;
        region.center.longitude =self.mapView.userLocation.coordinate.longitude;
        [self.mapView setRegion:region];
        lat=self.mapView.userLocation.coordinate.latitude;
        longi =self.mapView.userLocation.coordinate.longitude;
        
        
        if(DELEGATE.selectedCategoryArray.count==0)
        {
            
            if(isfirst)
            {
                
                [DELEGATE.selectedCategoryArray addObjectsFromArray:DELEGATE.categoryArray];
                NSString *resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
                [self callApi:resultAsString];
            }
            else
            {
                [self.view makeToast:[localization localizedStringForKey:@"No result found"]
                            duration:2.0
                            position:@"center"];
               // [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
             
            }
            
            
            
        }
        else
        {
            NSString *resultAsString =[DELEGATE.selectedCategoryArray componentsJoinedByString:@","];
            [self callApi:resultAsString];
        }
    }
    
   
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
    if(DELEGATE.connectedToNetwork)
    {
        [mc logout:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responsegetLogout:)];
    }

}
-(void)cancelBtnTapped:(id)sender
{
    //NSLog(@"cancelBtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];
    
}
- (IBAction)clickAdd:(id)sender
{
    
    EventTabViewController *eventVC =[[EventTabViewController alloc] initWithNibName:@"EventTabViewController" bundle:nil];
    [self.navigationController pushViewController:eventVC animated:YES];
  
}
- (IBAction)clickClose:(id)sender
{
    [self updateSideMeuState:closeState];
}


-(void)loadSearchLocationView
{
    searchLocationView = [[[NSBundle mainBundle] loadNibNamed:@"SearchLocationView"
                                                        owner:self
                                                      options:nil]
                          objectAtIndex:0];
    [searchLocationView setFrame:CGRectMake(0,
                                      0,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height)];
    
    [searchLocationView setSearchDelegate:self];
    [searchLocationView.searchTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    searchLocationView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.4];
    
    [searchLocationView.txtFldSearch becomeFirstResponder];
    
    UITapGestureRecognizer *searchLocationGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDismissSearchLocationView:)];
    [searchLocationGest setDelegate:self];
    [searchLocationGest setCancelsTouchesInView:NO];
    [searchLocationView addGestureRecognizer:searchLocationGest];
    
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [[[window subviews] objectAtIndex:0] addSubview:searchLocationView];
}

-(void)onDismissSearchLocationView:(UIGestureRecognizer *)aGest
{
    [searchLocationView removeFromSuperview];
}

-(void)loadLeftMenuView
{
    leftMenuView =
    [[[NSBundle mainBundle] loadNibNamed:@"LeftMenuView"
                                   owner:self
                                 options:nil]
     objectAtIndex:0];
    [leftMenuView setFrame:CGRectMake(-self.view.bounds.size.width,
                                           0,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height)];
    [leftMenuView setLeftMenuDelegate:self];
    leftMenuView.backgroundColor = [UIColor clearColor];
    
    
    
    NSString *userID = [USER_DEFAULTS objectForKey:@"email_address"];
    NSString *fullName = [USER_DEFAULTS objectForKey:@"fullname"];
    
    [leftMenuView.lblName setText:fullName];
    [leftMenuView.lblEmailAddress setText:userID];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismisMenuView:)];
    [tap setDelegate:self];
    tap.cancelsTouchesInView = NO;
    [leftMenuView addGestureRecognizer:tap];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [[[window subviews] objectAtIndex:0] addSubview:leftMenuView];
    
    
    
}

- (IBAction)toggleMenu:(id)sender
{
    if(!isMenuOpened)
    {
        [self loadLeftMenuView];
        
        [UIView animateWithDuration:0.6f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             CGRect initalFrame = leftMenuView.frame;
                             initalFrame.origin.x = 0;
                             leftMenuView.frame = initalFrame;
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             leftMenuView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
                             
                         }];
    }
    else
    {
        leftMenuView.backgroundColor = [UIColor clearColor];
        
        [UIView animateWithDuration:0.6f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             CGRect initalFrame = leftMenuView.frame;
                             initalFrame.origin.x = -self.view.bounds.size.width;
                             leftMenuView.frame = initalFrame;
                         }
                         completion:^(BOOL finished){
                             
                             [leftMenuView removeFromSuperview];
                             
                         }];
    }
    
    
    isMenuOpened = !isMenuOpened;
    
    
    //[self.view layoutIfNeeded];
 
//    if (!isMenuOpened)
//    {
//        //self.const_BaseMenuView_Horizontal.constant = 70;
//    }
//    else
//    {
//        //self.const_BaseMenuView_Horizontal.constant = self.view.frame.size.width;
//    }
//    
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         
//                         [self.view layoutIfNeeded]; // Called on parent view
//                         [self.imgBG setHidden:isMenuOpened];
//                         
//                     }];
//    
//    isMenuOpened = !isMenuOpened;
    
    //[self.view bringSubviewToFront:self.baseMenuView];
}

- (IBAction)onClickSearchButton:(id)sender {
    
    [self loadSearchLocationView];
}

-(void)eventsView
{
    CGRect frame = self.view.bounds;
    UIView *homeLabel = [self createHomeButtonView];
    downMenuButton = [[DWBubbleMenuButton alloc] initWithFrame:CGRectMake(frame.size.width-(homeLabel.frame.size.width + 20),
                                                                                              (frame.size.height - homeLabel.frame.size.height)-64,
                                                                                              homeLabel.frame.size.width,
                                                                                              homeLabel.frame.size.height)
                                                                expansionDirection:DirectionUp];
    downMenuButton.homeButtonView = homeLabel;
    downMenuButton.buttonSpacing = 10.0f;
    [downMenuButton addButtons:[self createDemoButtonArray]];
    [downMenuButton setDelegate:self];
    
    [self.view addSubview:downMenuButton];
}

- (UIView *)createHomeButtonView {
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 65)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(160-55, 5.f, 55, 55)];
    
    label.text = @"+";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:30];
    label.tag = 121;
    label.layer.cornerRadius = label.frame.size.height / 2.f;
    label.backgroundColor =[UIColor colorWithRed:242/255.f green:107/255.f blue:4/255.f alpha:1.0f];
    label.clipsToBounds = YES;
    [view addSubview:label];
    
    return view;
}

- (NSArray *)createDemoButtonArray {
    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
    
    int i = 0;
    NSArray *imgList = [[NSArray alloc] initWithObjects:@"add-event_New",@"search-event_New", @"event-invitation_New", @"friend-request_New", @"my-event_New", @"filter_New", nil];
    NSArray *titilesList = [[NSArray alloc] initWithObjects:@"Add Event",@"Search Event", @"Event Invitation", @"Friend Request", @"My Event", @"Filter", nil];
    //@[@"add-event", @"search-event", @"event-invitation", @"invitation-request", @"my-event", @"filter-selected"]
    
    for (NSString *title in imgList) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:title] forState:UIControlStateNormal];
        //[button setTitle:title forState:UIControlStateNormal];
        
        [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [button setTitle:[titilesList objectAtIndex:i] forState:UIControlStateNormal];
        
        [button sizeToFit];
        button.clipsToBounds = YES;
        
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageView.frame.size.width, 0, button.imageView.frame.size.width);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, button.titleLabel.frame.size.width, 0, -button.titleLabel.frame.size.width);
        
        
        //button.imageEdgeInsets = UIEdgeInsetsMake(0, button.titleLabel.frame.size.width, 0, -button.titleLabel.frame.size.width);
        button.frame = CGRectMake(0.f, 0.f, 160, 45);
        //button.layer.cornerRadius = button.frame.size.height / 2.f;
        //button.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
        
        //[button sizeToFit];
        //button.clipsToBounds = YES;
        button.tag = i++;
        
        [button addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonsMutable addObject:button];
    }
    
    return [buttonsMutable copy];
}

- (void)test:(UIButton *)sender {
    NSLog(@"Button tapped, tag: %ld", (long)sender.tag);
    
    switch (sender.tag) {
        case 0:
        {
            EventTabViewController *eventVC = [[EventTabViewController alloc] initWithNibName:@"EventTabViewController" bundle:nil];
            [self.navigationController pushViewController:eventVC animated:YES];
        }
            break;
        case 1:
        {
            CommonListViewController *commonListVC = [[CommonListViewController alloc] initWithNibName:@"CommonListViewController" bundle:nil];
            [self.navigationController pushViewController:commonListVC animated:YES];
        }
            break;
        case 2:
        {
            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
            
            int count =[[item badgeValue] intValue];
            
            [item setBadgeValue:[NSString stringWithFormat:@"%d",count-inviteCount]];
            
            
            //here
            if([[item badgeValue] intValue] <= 0)
            {
                [item setBadgeValue:nil];
            }
            
            //[self.filterView setHidden:YES];
            isFilter =NO;
            
            
            OtherUserEventsViewController *otherVC =[[OtherUserEventsViewController alloc] initWithNibName:@"OtherUserEventsViewController" bundle:nil];
            [otherVC setIsMy:YES];
            [self.navigationController pushViewController:otherVC animated:YES];
        } 
            break;
            
        case 3:
        {
            FriendRequestViewController *frndVC = [[FriendRequestViewController alloc] initWithNibName:@"FriendRequestViewController" bundle:nil];
            [frndVC setIsFriend:YES];
            isFilter =NO;
            [self.navigationController pushViewController:frndVC animated:YES];
        }
            break;
        case 4:
        {
            MyEventsViewController *commonListVC = [[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
            commonListVC.isInvite = NO;
            [self.filterView setHidden:YES];
            /*
             MyEventsViewController *myVC =[[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
             [myVC setIsInvite:NO];
             [self.navigationController pushViewController:myVC animated:YES];
             //[self.filterView setHidden:YES];
             isFilter =NO;
             */
            [self.navigationController pushViewController:commonListVC animated:YES];
        }
            break;
        case 5:
        {
            
            CategoryViewController *catVC = [[CategoryViewController alloc] initWithNibName:@"CategoryViewController" bundle:nil];
            [catVC setIsMultiSelect:YES];
            isFilter =NO;
            
            [self.navigationController pushViewController:catVC animated:YES];
        }
            break;
        default:
            break;
    }
}

- (UIButton *)createButtonWithName:(NSString *)imageName {
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button sizeToFit];
    
    [button addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

-(void)showMilesLanguageView
{
    [self customView];
    
    [UIView animateWithDuration:0.6f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect initalFrame = milesLanguageView.frame;
                         initalFrame.origin.x = -(self.view.bounds.size.width - milesLanguageView.popUpView.frame.size.width)/2 + 10;
                         milesLanguageView.frame = initalFrame;
                     }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.1
                          
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              
                                              CGRect initalFrame = milesLanguageView.frame;
                                              initalFrame.origin.x = 0;
                                              milesLanguageView.frame = initalFrame;
                                              
                                          }
                                          completion:^(BOOL finished){
                                              
                                              [milesLanguageView setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.7]];
                                          }];
                     }];
}

-(void)customView
{
    milesLanguageView =
    [[[NSBundle mainBundle] loadNibNamed:@"MilesLanguageView"
                                   owner:self
                                 options:nil]
     objectAtIndex:0];
    [milesLanguageView setFrame:CGRectMake(self.view.bounds.size.width,
                                           0,
                                           self.view.bounds .size.width,
                                           self.view.bounds.size.height)];
    milesLanguageView.delegate = self;
    [milesLanguageView setCurrentSelectedLang];
    
    if([USER_DEFAULTS objectForKey:@"distance"])
    {
        NSString *sliderValue = [USER_DEFAULTS objectForKey:@"distance"];
        milesLanguageView.distanceSlider.value = [sliderValue integerValue];
        
        milesLanguageView.distanceSlider.color = [sliderValue floatValue];
    }
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [[[window subviews] objectAtIndex:0] addSubview:milesLanguageView];
    
    //[self.view addSubview:milesLanguageView];
}

-(void)hideMileLanguageView
{
    [milesLanguageView setBackgroundColor:[UIColor clearColor]];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect initalFrame = milesLanguageView.frame;
                         initalFrame.origin.x = 20;
                         milesLanguageView.frame = initalFrame;
                         
                     }
                     completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.1
                          
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              
                                              CGRect initalFrame = milesLanguageView.frame;
                                              initalFrame.origin.x = -milesLanguageView.frame.size.width;
                                              milesLanguageView.frame = initalFrame;
                                              // milesLanguageView.popUpView.center = milesLanguageView.center;
                                              
                                          }
                                          completion:^(BOOL finished){
                                              
                                              
                                              [milesLanguageView removeFromSuperview];
                                          }];
                     }];
}

-(void)onClickOkButton:(int)sliderValue
{
    [self hideMileLanguageView];
    
    if(DELEGATE.connectedToNetwork)
    {
        [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:nil search_miles:[NSString stringWithFormat:@"%d",sliderValue] Event_notification:nil Comment_notification:nil Sel:@selector(responseDistanceChanged:)];
    }
}

-(void)responseDistanceChanged:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        //[USER_DEFAULTS setInteger:[[[results valueForKey:@"User"] valueForKey:@"search_miles"] integerValue] forKey:@"distance"];
        NSString *sliderValue = [[results objectForKey:@"User"] objectForKey:@"search_miles"];
        
        [USER_DEFAULTS setObject:sliderValue forKey:@"distance"];
        
        //setValue:[[results valueForKey:@"User"] valueForKey:@"search_miles"] forKey:@"distance"];
        [USER_DEFAULTS synchronize];
        
        BOOL found =NO;
        NSLog(@"navigation are %@",self.navigationController.viewControllers);
        for(int i=0; i<self.navigationController.viewControllers.count;i++)
        {
            if([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[HomeTabViewController class]])
            {
                found =YES;
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i] animated:NO];
                
                break;
                
            }
        }
        if(!found)
        {
            
            [DELEGATE.tabBarController setSelectedIndex:0];
        }
        
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
}

-(IBAction)sliderDidChange:(RGSColorSlider *)sender{
    
}


-(void)onClickCancelButton
{
    [self hideMileLanguageView];
}

-(void)dismisMenuView:(UIGestureRecognizer *)agest
{
    [self toggleMenu:nil];
}

-(void)toggleMenuwithOpenSelectedOption:(NSString *)option
{
    [self toggleMenu:nil];
    
    [self performSelector:@selector(showMilesLanguageView) withObject:nil afterDelay:0.2];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MenuCustomCell";
    MenuCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"MenuCustomCell" owner:nil options:nil];
        cell = [nibs lastObject];
    }
    
    MenuData *menuData = [menuList objectAtIndex:indexPath.row];
    [cell loadData:menuData];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuList.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MenuData *menuData = [menuList objectAtIndex:indexPath.row];
    [self toggleMenu:nil];
    
    if([menuData.title isEqualToString:[localization localizedStringForKey:@"Language"]])
    {
        [self performSelector:@selector(showMilesLanguageView) withObject:nil afterDelay:0.5];
    }
    else if([menuData.title isEqualToString:@"Miles saved"])
    {
        [self performSelector:@selector(showMilesLanguageView) withObject:nil afterDelay:0.5];
    }
    else if([menuData.title isEqualToString:[localization localizedStringForKey:@"Notification"]])
    {
       [self performSelector:@selector(openNotifiationVC) withObject:nil afterDelay:0.5];
    }
    else if([menuData.title isEqualToString:@"Terms and Policy"])
    {
        [self performSelector:@selector(openPrivacyPolicy) withObject:nil afterDelay:0.5];
    }
    else if([menuData.title isEqualToString:[localization localizedStringForKey:@"Logout"]])
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Are you sure, you want to Logout?"] AlertFlag:2 ButtonFlag:2];
    }
    else if([menuData.title isEqualToString:[localization localizedStringForKey:@"Report/Feedback"]])
    {
        ReachUsViewController *reachVC =[[ReachUsViewController alloc] initWithNibName:@"ReachUsViewController" bundle:nil];
        [self.navigationController pushViewController:reachVC animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

-(void)openNotifiationVC
{
    NotificationViewController *eventDetailVC =[[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:nil];
    [self.navigationController pushViewController:eventDetailVC animated:YES];
}

-(void)openPrivacyPolicy
{
    PrivacyPolicyViewController *eventDetailVC =[[PrivacyPolicyViewController alloc] initWithNibName:@"PrivacyPolicyViewController" bundle:nil];
    [self.navigationController pushViewController:eventDetailVC animated:YES];
}

//Manoj
//Set Menu data

-(void)setMenuData
{
    NSMutableArray *list = [NSMutableArray array];
    /*
     [self.lblReport setText:[localization localizedStringForKey:@"Report/Feedback"]];
     [self.lblProfike setText:[localization localizedStringForKey:@"Profile"]];
     [self.lblLogout setText:[localization localizedStringForKey:@"Logout"]];
     [self.lblAppVersion setText:[localization localizedStringForKey:@"App Version"]];
     [self.lblLanguage setText:[localization localizedStringForKey:@"Language"]];
     [self.lblTitle setText:[localization localizedStringForKey:@"Settings"]];
     [self.lblPush setText:[localization localizedStringForKey:@"Notification"]];
     [self.lblDistance setText:[localization localizedStringForKey:@"Search miles for events"]];
     
     [self.btnSave setTitle:[localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];
     */
    
    MenuData *data = [[MenuData alloc] init];
    data.imgName = @"language";
    data.title = [localization localizedStringForKey:@"Language"];
    [list addObject:data];
    
    data = [[MenuData alloc] init];
    data.imgName = @"settings";
    data.title = @"Miles saved";
    [list addObject:data];
    
    data = [[MenuData alloc] init];
    data.imgName = @"notification";
    data.title = [localization localizedStringForKey:@"Notification"];
    [list addObject:data];
    
    data = [[MenuData alloc] init];
    data.imgName = @"report-feedback";
    data.title = [localization localizedStringForKey:@"Report/Feedback"];
    [list addObject:data];
    
    data = [[MenuData alloc] init];
    data.imgName = @"privacy";
    data.title = @"Terms and Policy";
    [list addObject:data];
    
    data = [[MenuData alloc] init];
    data.imgName = @"logout";
    data.title = [localization localizedStringForKey:@"Logout"];
    [list addObject:data];
    
    menuList = list;
}

-(void)responsegetLogout:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        /* [USER_DEFAULTS removeObjectForKey:@"userid"];
         [USER_DEFAULTS removeObjectForKey:@"myjid"];
         [USER_DEFAULTS removeObjectForKey:@"fullname"];
         [USER_DEFAULTS removeObjectForKey:@"myjid"];
         [USER_DEFAULTS removeObjectForKey:@"recieve_push"];*/
        NSDictionary * dict = [USER_DEFAULTS dictionaryRepresentation];
        for (id key in dict)
        {
            [USER_DEFAULTS removeObjectForKey:key];
        }
        [USER_DEFAULTS synchronize];
        
        
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        //  NSLog(@"current language is %@",language);
        
        if([language isEqualToString:@"es"])
        {
            [localization setLanguage:@"SP"];
            // [USER_DEFAULTS setObject:@"S" forKey:@"localization"];
        }
        else if([language isEqualToString:@"ch"])
        {
            [localization setLanguage:@"CH"];
            // [USER_DEFAULTS setObject:@"C" forKey:@"localization"];
        }
        else
        {
            [localization setLanguage:@"EN"];
            //[USER_DEFAULTS setObject:@"E" forKey:@"localization"];
        }
        
        // [USER_DEFAULTS synchronize];
        
        [DELEGATE disconnect];
        
        BOOL found =NO;
        for(int i=0; i<self.navigationController.viewControllers.count;i++)
        {
            if([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[LoginViewController class]])
            {
                found =YES;
                
                /* NSUserDefaults * defs = [NSUserDefaults standardUserDefaults]; NSDictionary * dict = [defs dictionaryRepresentation]; for (id key in dict) { [defs removeObjectForKey:key]; } [defs synchronize];*/
                
                
                DELEGATE.navigationController =[[UINavigationController alloc] initWithRootViewController:[self.navigationController.viewControllers objectAtIndex:i]];
                DELEGATE.navigationController.navigationBarHidden =YES;
                [DELEGATE.window setRootViewController:DELEGATE.navigationController];
                break;
                
            }
        }
        if(!found)
        {
            
            /*     NSUserDefaults * defs = [NSUserDefaults standardUserDefaults]; NSDictionary * dict = [defs dictionaryRepresentation]; for (id key in dict) { [defs removeObjectForKey:key]; } [defs synchronize];*/
            
            
            LoginViewController *loginVC =[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            DELEGATE.navigationController =[[UINavigationController alloc] initWithRootViewController:loginVC];
            DELEGATE.navigationController.navigationBarHidden =YES;
            [DELEGATE.window setRootViewController:DELEGATE.navigationController];
            //[self.navigationController pushViewController:dashVC animated:NO];
            
        }
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
        /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
         [alert show];*/
    }
}

-(void)onSelectLaunguage:(NSString *)lang withSelectIndex:(int)Index andSliderValue:(int)sliderValue
{
    selectedIndex = Index;
    [mc editSetting:[USER_DEFAULTS valueForKey:@"userid"] Recieve_push:nil Langauge:lang search_miles:[NSString stringWithFormat:@"%d",sliderValue] Event_notification:nil Comment_notification:nil Sel:@selector(responseLanguageChanged1:)];
}

-(void)responseLanguageChanged1:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    NSLog(@"result is %d",selectedIndex);
    
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(selectedIndex==0)
        {
            [localization setLanguage:@"EN"];
            [USER_DEFAULTS setObject:@"E" forKey:@"localization"];
            
            
        }
        else if(selectedIndex==1)
        {
            [localization setLanguage:@"SP"];
            [USER_DEFAULTS setObject:@"S" forKey:@"localization"];
            
            
        }
        else if(selectedIndex==2)
        {
            [localization setLanguage:@"CH"];
            [USER_DEFAULTS setObject:@"C" forKey:@"localization"];
        }
        selectedIndex =-1;
        
        
        [USER_DEFAULTS synchronize];
        //[self localize];
        [DELEGATE setWindowRoot];
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
         [alert show];*/
    }
}

-(void)showSearchView
{
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch
{
    if([touch.view class] == [UITableViewCell class])
    {
        return NO;
    }
    if([[touch.view superview] isKindOfClass:[UITableViewCell class]])
    {
        return NO;
    }
    
    if([[[touch.view superview] superview] isKindOfClass:[UITableViewCell class]])
    {
        return NO;
    }
    return YES;
}

-(void)selectedAddress:(NSDictionary *)dict
{
    [self plotPositions:[[NSArray alloc] initWithObjects:dict, nil]];
    
}


- (void)bubbleMenuButtonWillExpand:(DWBubbleMenuButton *)expandableView
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveLinear)
                     animations:^ {
                         UILabel *lbl = [expandableView viewWithTag:121];
                         lbl.transform = CGAffineTransformMakeRotation(45.0*M_PI/180.0);
                    }
                     completion:^(BOOL finished){
                     }
     ];
}

- (void)bubbleMenuButtonDidExpand:(DWBubbleMenuButton *)expandableView
{
    [self.imgBG setHidden:NO];
}

- (void)bubbleMenuButtonWillCollapse:(DWBubbleMenuButton *)expandableView
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveLinear)
                     animations:^ {
                         UILabel *lbl = [expandableView viewWithTag:121];
                         lbl.transform = CGAffineTransformMakeRotation(45.0*M_PI/90.0);
                     }
                     completion:^(BOOL finished){
                     }
     ];
}

- (void)bubbleMenuButtonDidCollapse:(DWBubbleMenuButton *)expandableView
{
    [self.imgBG setHidden:YES];
}


@end

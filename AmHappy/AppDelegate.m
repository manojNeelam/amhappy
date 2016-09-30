//
//  AppDelegate.m
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import "AppDelegate.h"
#import "ChatTabViewController.h"
#import "EventTabViewController.h"
#import "HomeTabViewController.h"
#import "SettingTabViewController.h"
#import "UserTabViewController.h"
#import "LoginViewController.h"
//#import <FacebookSDK/FacebookSDK.h>
#import "ModelClass.h"
#import "MyEventsViewController.h"
#import "FriendRequestViewController.h"
#import "UserVerificationViewController.h"
#import "ChatTabViewController.h"
#import "CMNavBarNotificationView.h"
#import "ChatViewController.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "EventDetailViewController.h"
#import "IQKeyboardManager.h"
#import "CommentDetail.h"


#import "CoreDataUtils.h"
#import "NSManagedObject+Utilities.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPMessageDeliveryReceipts.h"

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "TURNSocket.h"
#import "Base64.h"

#import <CFNetwork/CFNetwork.h>
//#import <Crashlytics/Crashlytics.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UIImageView+WebCache.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CustomAlert2.h"

#import "TimeLineViewController.h"
#import "UserTabViewController.h"


#import <Bolts/BFURL.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "PromotionListing.h"


#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

#define VIEW_FOR_ZOOM_TAG (1)




#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface AppDelegate ()

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end

@implementation AppDelegate
{
    NSUserDefaults *defaults;
    BOOL isInternet;
    XMPPMessageDeliveryReceipts *reciept;
    BOOL isShowNotification;
    BOOL isBecameActive;
    
    NSDictionary *notificationDict;
    
    BOOL isLaunched;

}

@synthesize FriendMessage,FriendName,isGroupUpdated,frinedReqbadgeValue,BoardbadgeValue;
@synthesize isUpdatePromotions;
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppLastActivity;
@synthesize xmppCapabilitiesStorage;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
//@synthesize roomStorage;


@synthesize navigationController,window,tabBarController,tokenstring,locationManager,categoryArray;

@synthesize isAccepted,isInvited,isEventEdited,isEventEditedList;




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     [[UIApplication sharedApplication]setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    
    frinedReqbadgeValue = 0;
    BoardbadgeValue = 0;
    
    self.window =[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    defaults  =[NSUserDefaults standardUserDefaults];
    
    
    
    self.isInvited=YES;
    self.isAccepted=YES;
    self.isEventEdited=NO;
    self.isEventEditedList =NO;
    
    isShowNotification =YES;
    isBecameActive =YES;


    notificationDict =[[NSDictionary alloc] init];
   // [Crashlytics startWithAPIKey:@"fb32da027e6daa6ad490d6c98016d64893b3efd2"];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    roomStorage = [[XMPPRoomMemoryStorage alloc] init];

   // [self setupStream];
    
    NSArray *arr = [NSLocale preferredLanguages];
    for (NSString *lan in arr)
    {
        NSLog(@"identifires are %@: %@ %@",lan, [NSLocale canonicalLanguageIdentifierFromString:lan], [[[NSLocale alloc] initWithLocaleIdentifier:lan] displayNameForKey:NSLocaleIdentifier value:lan]);
    }
    
  
  
    if([USER_DEFAULTS valueForKey:@"fromJId"])
    {
        [USER_DEFAULTS removeObjectForKey:@"fromJId"];
        [USER_DEFAULTS synchronize];
    }
    [NSThread sleepForTimeInterval:3.0];
    self.categoryArray =[[NSMutableArray alloc] init];
    self.selectedCategoryArray =[[NSMutableArray alloc] init];
    self.categoryDictionaryArray =[[NSMutableArray alloc] initWithArray:[self getItems]];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
 
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
  //  NSLog(@"current language is %@",language);
    
    if([USER_DEFAULTS valueForKey:@"localization"])
    {
        if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"S"])
        {
            [localization setLanguage:@"SP"];
        }
        else if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"C"])
        {
            [localization setLanguage:@"CH"];
        }
        else
        {
            [localization setLanguage:@"EN"];
        }
    }
    else
    {
        if([language isEqualToString:@"es"])
        {
            [localization setLanguage:@"SP"];
            [USER_DEFAULTS setObject:@"S" forKey:@"localization"];
        }
        else if([language isEqualToString:@"ch"])
        {
            [localization setLanguage:@"CH"];
            [USER_DEFAULTS setObject:@"C" forKey:@"localization"];
        }
        else
        {
            [localization setLanguage:@"EN"];
            [USER_DEFAULTS setObject:@"E" forKey:@"localization"];
        }
    }
    [USER_DEFAULTS synchronize];

    for(int i=1;i<=21;i++)
    {
        //[self.categoryArray removeObjectAtIndex:5];
        [self.categoryArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
  
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    if (launchOptions !=nil)
    {
        NSDictionary* notificationdict1= [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (notificationdict1 != nil)
        {
            [self responseToNotification:notificationdict1];
        }
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager setDelegate:self];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
   
    
    if([defaults valueForKey:@"userid"] && [defaults valueForKey:@"updated"])
    {
        [self setWindowRoot];
        
        /***************** need to uncomment while enable chat view *******************/
        //[self getAllUnreadMessages];
    }
    else if([defaults valueForKey:@"userid"])
    {
        UserVerificationViewController *userVC =[[UserVerificationViewController alloc] initWithNibName:@"UserVerificationViewController" bundle:nil];
        self.navigationController =[[UINavigationController alloc] initWithRootViewController:userVC];
        self.window.rootViewController = self.navigationController;
    }
    else
    {
        LoginViewController *loginVC =[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        self.navigationController =[[UINavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = self.navigationController;
        
    }
    
    self.navigationController.navigationBarHidden =YES;

    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
     NSArray *fontFamilies = [UIFont familyNames];
     
     for (int i = 0; i < [fontFamilies count]; i++)
     {
     NSString *fontFamily = [fontFamilies objectAtIndex:i];
     NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
     NSLog (@"font are %@: %@", fontFamily, fontNames);
     }
    
    //////////////////////////////////////////XMPP************************
    _presences=[[NSMutableDictionary alloc]init];
    
    
    
    
  /*  if (![self connect])
    {
        [self connect];
    }*/
  

    
    [self DisableIQKeyboard];
    
    [FBSDKSettings setDisplayName:[[FBSDKSettings displayName] precomposedStringWithCanonicalMapping]];
    
    //[FBSDKSettings setDefaultDisplayName:[[FBSDKSettings displayName] precomposedStringWithCanonicalMapping]];
    
    [FBSDKAppEvents activateApp];
    
    
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];

}

-(void)enableIQKeyboard
{
    [[IQKeyboardManager sharedManager]setEnable:YES];
    
     [[IQKeyboardManager sharedManager] disableToolbarInViewControllerClass:[CommentDetail class]];
   
}

-(void)DisableIQKeyboard
{
    [[IQKeyboardManager sharedManager]setEnable:NO];
}


-(NSArray *)getItems
{
    NSDictionary *dict=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
    NSArray *arr =[[NSArray alloc] initWithArray:[dict valueForKey:@"Items"]];
    return arr;
}
-(void)backImageTapped:(UIButton *)sender
{
    [[self.window viewWithTag:111] removeFromSuperview];
}
-(void)saveImageTapped:(UIButton *)sender
{
    CustomImageAlert *cmAlert = (CustomImageAlert *)sender.superview;
    if(cmAlert.imgEvent.image)
    {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        [library writeImageToSavedPhotosAlbum:[cmAlert.imgEvent.image CGImage] orientation:(ALAssetOrientation)[cmAlert.imgEvent.image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error)
         {
             if (error) {
                 [DELEGATE showalert:nil Message:error.localizedDescription AlertFlag:1 ButtonFlag:1];
                 // TODO: error handling
             } else {
                 
                 [DELEGATE showalert:nil Message:[localization localizedStringForKey:@"Image Saved to Gallery"] AlertFlag:1 ButtonFlag:1];
                 
                 // TODO: success handling
             }
         }];
    }
    
}
-(void)showCustomImageAlert:(NSString *)url Type:(int)type
{
    CustomImageAlert *cmAlert = [[[NSBundle mainBundle]
                                 loadNibNamed:@"CustomImageAlert"
                                 owner:self options:nil]
                                firstObject];
    
    cmAlert.frame =self.window.bounds;
    cmAlert.tag=111;
    cmAlert.delegate=self;
    
    if(type==1)
    {
        [cmAlert.lblTitle setText:[localization localizedStringForKey:@"Event image"] ];
    }
    else
    {
        [cmAlert.lblTitle setText:[localization localizedStringForKey:@"Profile image"] ];
    }
    
    if(IS_IPHONE_4s)
    {
        [cmAlert.imgBG setImage:[UIImage imageNamed:@"bg4s.png"]];
    }
    else if (IS_IPHONE_5)
    {
        [cmAlert.imgBG setImage:[UIImage imageNamed:@"bg5.png"]];
    }
    else if (IS_IPHONE_6)
    {
        [cmAlert.imgBG setImage:[UIImage imageNamed:@"bg6.png"]];
    }
    else if (IS_IPHONE_6_PLUS)
    {
        [cmAlert.imgBG setImage:[UIImage imageNamed:@"bg6plus.png"]];
    }
    else if (IS_Ipad)
    {
        [cmAlert.imgBG setImage:[UIImage imageNamed:@"bgipad.png"]];
    }
    
    [cmAlert.imgEvent sd_setImageWithURL:[NSURL URLWithString:url]];
    
    [cmAlert.imgEvent setHidden:YES];

    
    
    BOOL zoom;
    int selected_index;
    
    float minimumScale;
    
    
    
    NSArray *getted_images =[[NSArray alloc] initWithObjects:cmAlert.imgBG.image, nil];
    
  UIScrollView * mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 65,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-65)];
    
    mainScrollView.pagingEnabled = YES;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    
    CGRect innerScrollFrame = mainScrollView.bounds;
    
    for (NSInteger i = 0; i < [getted_images count]; i++)
    {
        UIImageView *imageForZooming= [[UIImageView alloc] initWithImage:[getted_images objectAtIndex:i]];
        
        // UIImageView *imageForZooming= [[UIImageView alloc] init];
        [imageForZooming sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]]];
        
        zoom=YES;
        imageForZooming.tag = VIEW_FOR_ZOOM_TAG;
        
        UIScrollView *pageScrollView = [[UIScrollView alloc]
                                        initWithFrame:innerScrollFrame];
        
        
        
        pageScrollView.minimumZoomScale = 1.0f;
        pageScrollView.maximumZoomScale = 2.0f;
        pageScrollView.zoomScale = 1.0f;
        pageScrollView.contentSize = imageForZooming.bounds.size;
        pageScrollView.delegate = self;
        pageScrollView.showsHorizontalScrollIndicator = NO;
        pageScrollView.showsVerticalScrollIndicator = NO;
        
        
        imageForZooming.frame=CGRectMake(pageScrollView.bounds.origin.x,pageScrollView.bounds.origin.y-35,pageScrollView.bounds.size.width,pageScrollView.bounds.size.height);
        
        
        
        
        
        //******
        
        
        
        [pageScrollView addSubview:imageForZooming];
        
        imageForZooming.layer.masksToBounds=YES;
        imageForZooming.contentMode=UIViewContentModeScaleAspectFit;
        
        minimumScale = [UIScreen mainScreen].bounds.size.width/ imageForZooming.frame.size.width;
        [pageScrollView setMinimumZoomScale:minimumScale];
        [pageScrollView setZoomScale:minimumScale];
        
        [mainScrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width*selected_index,0) animated:YES];
        
        [mainScrollView addSubview:pageScrollView];
        pageScrollView.tag =i+10;
        
        // Add gesture,double tap zoom imageView.
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleDoubleTap:)];
        doubleTapGesture.view.tag=i;
        
        //NSLog(@"%d",doubleTapGesture.view.tag);
        doubleTapGesture.delegate =self;
        
        [doubleTapGesture setNumberOfTapsRequired:2];
        [pageScrollView addGestureRecognizer:doubleTapGesture];
        
        
        
        if (i < [getted_images count]-1) {
            innerScrollFrame.origin.x += innerScrollFrame.size.width;
        }
        
        
    }
    
    mainScrollView.contentSize = CGSizeMake(innerScrollFrame.origin.x +
                                            innerScrollFrame.size.width, mainScrollView.bounds.size.height);
    
    [cmAlert addSubview:mainScrollView];
    
    cmAlert.center = self.window.center;
    [self.window addSubview:cmAlert];
    
}





#pragma mark array by remove string
-(NSMutableArray*)getArrayByRemovingString:(NSString*)String fromstring:(NSString *)fromstring
{
    NSString *match = String;
    NSString *preTel = [[NSString alloc] init];
    //   NSString *postTel;
    
    NSMutableArray *strArray = [[NSMutableArray alloc] init];
    
    while ([fromstring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)
    {
        NSScanner *scanner = [NSScanner scannerWithString:fromstring];
        [scanner scanUpToString:match intoString:&preTel];
        
        [scanner scanString:match intoString:nil];
        preTel = [preTel stringByAppendingString:@""];
        [strArray addObject:preTel];
        
        preTel = @"";
        fromstring = [fromstring substringFromIndex:scanner.scanLocation];
    }
    
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<strArray.count; i++)
    {
        if (i%2 != 0)
            
        {
            [finalArray addObject:[strArray objectAtIndex:i]];
        }
    }
    
    return strArray;
}

#pragma mark - Zoom methods


- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    //NSLog(@"%d",gestureRecognizer.view.tag);
    UIScrollView *pageScrollView1=(UIScrollView *)[gestureRecognizer view];
    
    if(pageScrollView1.zoomScale > pageScrollView1.minimumZoomScale)
    {
        [pageScrollView1 setZoomScale:pageScrollView1.minimumZoomScale animated:YES];
    }
    else
    {
        [pageScrollView1 setZoomScale:pageScrollView1.maximumZoomScale animated:YES];
    }
    
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView viewWithTag:VIEW_FOR_ZOOM_TAG];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(void)showalertNew:(UIViewController *)containerView Message:(NSString *)msg AlertFlag:(int)alertFlag{
    CustomAlert2 *customAlert;
    if(IS_Ipad)
    {
        customAlert = [[[NSBundle mainBundle]
                        loadNibNamed:@"CustomAlert2_ipad"
                        owner:self options:nil]
                       firstObject];
    }
    else
    {
        customAlert = [[[NSBundle mainBundle]
                        loadNibNamed:@"CustomAlert2"
                        owner:self options:nil]
                       firstObject];
    }
    
    if(alertFlag==0)
    {
        [customAlert.lblMessage setText:[localization localizedStringForKey:@"Do you want to invite guest to this event?"]];
        [customAlert.btnInvite setTitle:[localization localizedStringForKey:@"Invite now"] forState:UIControlStateNormal];
        [customAlert.btnLater setTitle:[localization localizedStringForKey:@"Later"] forState:UIControlStateNormal];
    }
    else
    {
        customAlert.btnInvite.tag =alertFlag;
        customAlert.btnLater.tag =alertFlag;

        [customAlert.lblMessage setText:[localization localizedStringForKey:msg]];
        [customAlert.btnInvite setTitle:[localization localizedStringForKey:@"Yes"] forState:UIControlStateNormal];
        [customAlert.btnLater setTitle:[localization localizedStringForKey:@"No"] forState:UIControlStateNormal];
    }
    
    
    
    [customAlert.customView.layer setMasksToBounds:YES];
    [customAlert.customView.layer setCornerRadius:10.0];
  
    customAlert.frame =containerView.view.frame;
    [containerView.view addSubview:customAlert];
    customAlert.delegate =containerView;
    customAlert.center = containerView.view.center;
        
    
}
-(void)showalert:(UIViewController *)containerView Message:(NSString *)msg AlertFlag:(int)alertFlag ButtonFlag:(int)buttonFlag
{
    CustomAlert *customAlert;
    if(IS_Ipad)
    {
        customAlert = [[[NSBundle mainBundle]
                        loadNibNamed:@"CustomAlert_ipad"
                        owner:self options:nil]
                       firstObject];
    }
    else
    {
        customAlert = [[[NSBundle mainBundle]
                        loadNibNamed:@"CustomAlert"
                        owner:self options:nil]
                       firstObject];
    }
    customAlert.tag=123;
    [customAlert.lblMessage setText:msg];
    
    [customAlert.customView.layer setMasksToBounds:YES];
    [customAlert.customView.layer setCornerRadius:10.0];
    
    if(buttonFlag==2)
    {
        [customAlert.btnCancel setTitle:[localization localizedStringForKey:@"No"] forState:UIControlStateNormal];
        [customAlert.btnOk1 setTitle:[localization localizedStringForKey:@"Yes"] forState:UIControlStateNormal];
        [customAlert.btnOk2 setTitle:[localization localizedStringForKey:@"Yes"] forState:UIControlStateNormal];
    }
    else if (buttonFlag==5)
    {
        [customAlert.btnCancel setTitle:[localization localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
        [customAlert.btnOk1 setTitle:[localization localizedStringForKey:@"View Now"] forState:UIControlStateNormal];
        [customAlert.btnOk2 setTitle:[localization localizedStringForKey:@"View Now"] forState:UIControlStateNormal];
    }
    else
    {
        [customAlert.btnCancel setTitle:[localization localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
        [customAlert.btnOk1 setTitle:[localization localizedStringForKey:@"Ok"] forState:UIControlStateNormal];
        [customAlert.btnOk2 setTitle:[localization localizedStringForKey:@"Ok"] forState:UIControlStateNormal];
    }
    
  

    
    if(alertFlag==1)
    {
        [customAlert.btnOk2 setHidden:YES];
        [customAlert.btnCancel setHidden:YES];

    }
    else
    {
        customAlert.btnOk2.tag =alertFlag;
        [customAlert.btnOk1 setHidden:YES];

    }
    
    if([msg isEqualToString:@"123"])
    {
        [customAlert.lblMessage setText:[localization localizedStringForKey:@"Your report has been submitted"]];
        customAlert.btnOk1.tag =151;
        
    }
    
    
    if(containerView)
    {
        [containerView.view addSubview:customAlert];
        customAlert.delegate =containerView;
        customAlert.frame =containerView.view.frame;

        customAlert.center = containerView.view.center;

    }
    else
    {
        customAlert.frame =self.window.bounds;

        customAlert.center = self.window.center;
        customAlert.delegate =self;

        [self.window addSubview:customAlert];

    }
}

-(void)setWindowRoot
{
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.delegate=self;
    // [[[self tabBarController] tabBar] setBackgroundImage:[UIImage imageNamed:@"tabbg.png"]];
    [[[self tabBarController] tabBar] setBackgroundColor:[UIColor whiteColor]];
    HomeTabViewController *homeVC =[[HomeTabViewController alloc] initWithNibName:@"HomeTabViewController" bundle:nil];
    PromotionListing *eventVC =[[PromotionListing alloc] initWithNibName:@"PromotionListing" bundle:nil];
    UserTabViewController *userVC =[[UserTabViewController alloc] initWithNibName:@"UserTabViewController" bundle:nil];
   // ChatTabViewController *chatVC =[[ChatTabViewController alloc] initWithNibName:@"ChatTabViewController" bundle:nil];
    
    TimeLineViewController *timelineVC =[[TimeLineViewController alloc] initWithNibName:@"TimeLineViewController" bundle:nil];
    
    
    //SettingTabViewController *settingVC =[[SettingTabViewController alloc] initWithNibName:@"SettingTabViewController" bundle:nil];
    
    UINavigationController *navController1=[[UINavigationController alloc]initWithRootViewController:homeVC];
    [navController1.navigationBar setHidden:YES];
    UINavigationController *navController2=[[UINavigationController alloc]initWithRootViewController:eventVC];
    [navController2.navigationBar setHidden:YES];
    UINavigationController *navController3=[[UINavigationController alloc]initWithRootViewController:timelineVC];
    [navController3.navigationBar setHidden:YES];
    UINavigationController *navController4=[[UINavigationController alloc]initWithRootViewController:userVC];
    [navController4.navigationBar setHidden:YES];
    //UINavigationController *navController5=[[UINavigationController alloc]initWithRootViewController:settingVC];
    //[navController5.navigationBar setHidden:YES];
    

    [[self.tabBarController.tabBar.items objectAtIndex:0]setTitle:[localization localizedStringForKey:@"Home"]];
    [[self.tabBarController.tabBar.items objectAtIndex:1]setTitle:[localization localizedStringForKey:@"Promotions"]];
    [[self.tabBarController.tabBar.items objectAtIndex:3]setTitle:[localization localizedStringForKey:@"My Friends"]];
   // [[self.tabBarController.tabBar.items objectAtIndex:3]setTitle:[localization localizedStringForKey:@"Chat"]];
    
    [[self.tabBarController.tabBar.items objectAtIndex:2]setTitle:[localization localizedStringForKey:@"Board"]];

    [[self.tabBarController.tabBar.items objectAtIndex:4]setTitle:[localization localizedStringForKey:@"Settings"]];
    self.tabBarController.viewControllers = nil ;
     NSArray *tabArrays = [NSArray arrayWithObjects: navController1, navController2,navController3,navController4,nil];
    self.tabBarController.viewControllers = tabArrays ;
    
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:230.0/255.0f green:133/255.0f blue:28.0/255.0f alpha:1.0],UITextAttributeTextColor,nil,UITextAttributeFont,nil]forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor lightGrayColor],UITextAttributeTextColor,nil,UITextAttributeFont,nil]forState:UIControlStateNormal];

   
    
    self.window.rootViewController = self.tabBarController;
    
}
- (BOOL) connectedToNetwork{
    // check network availability
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        isInternet =NO;
        ;
        
        [self showalert:nil Message:[localization localizedStringForKey:@"Please check your internet connection"] AlertFlag:1 ButtonFlag:1];

    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        isInternet = TRUE;
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        isInternet = TRUE;
        
        
    }
    return isInternet;
}
- (BOOL) connectedToNetwork2{
    // check network availability
    Reachability* reachability = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        isInternet =NO;
        ;
        
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        isInternet = TRUE;
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        isInternet = TRUE;
        
    }
    return isInternet;
}

-(void)ok1BtnTapped:(id)sender
{
    // NSLog(@"ok1BtnTapped");
    [[self.window viewWithTag:123] removeFromSuperview];
    
}


-(BOOL)IsValidEmail:(NSString *)emailString
{
    NSString *emailid = emailString;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL myStringMatchesRegEx=[emailTest evaluateWithObject:emailid];
    return myStringMatchesRegEx;
}


-(void)cancelBtnTapped:(id)sender
{
    //NSLog(@"cancelBtnTapped");
    [[self.window viewWithTag:123] removeFromSuperview];
    
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController1 shouldSelectViewController:(UIViewController *)viewController
{
    if ([tabBarController1.viewControllers indexOfObject:viewController] == tabBarController1.selectedIndex)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    
    self.tokenstring =[NSString stringWithFormat:@"%@",deviceToken];
    self.tokenstring = [tokenstring stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    self.tokenstring = [[NSString alloc]initWithFormat:@"%@",[self.tokenstring stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    
  //  NSLog(@"tokenstring is %@",self.tokenstring);
    
    
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
   // UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:@"notification recieved" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //[alert show];
   // NSLog(@"notification dictionary is %@",userInfo);
    
    /*
     $body['aps'] = array('alert' =>  $message);
     $body['aps']['type'] = "I";
     $body['aps']['badge'] = 1;
     $body['aps']['sound'] = 'default';
     $body['aps']['event_id'] = $_POST['eventid'];
     */
    
    //notificationDict =[NSMutableDictionary dictionaryWithDictionary:[userInfo valueForKey:@"aps"]];
    [self responseToNotification:userInfo];
    
}


-(void)responseToNotification:(NSDictionary *)dict
{
    notificationDict =[NSMutableDictionary dictionaryWithDictionary:[dict valueForKey:@"aps"]];
    if([defaults valueForKey:@"userid"] && [defaults valueForKey:@"updated"])
    {
        if([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"F"])
        {
 
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
            {
                
                
                //********* increase filter count here
                
                //refreshView
                
                
                
                FriendRequestViewController *frndVC =[[FriendRequestViewController alloc] initWithNibName:@"FriendRequestViewController" bundle:nil];
                [frndVC setIsFriend:YES];
                
                DELEGATE.tabBarController = (UITabBarController *)DELEGATE.window.rootViewController;
                DELEGATE.tabBarController.selectedIndex = 4;
                
                [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:frndVC animated:YES];
                
                
              
            
//                UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
//                
//                int count =[[item badgeValue] intValue];
//                
//                [item setBadgeValue:[NSString stringWithFormat:@"%d",count+1]];
            
            }
            else{
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshView" object:nil userInfo:nil];

                
            }
            
       
            
            if(![self.navigationController.visibleViewController isKindOfClass:[FriendRequestViewController class]])
            {
       
                // [self showalert:nil Message:[localization localizedStringForKey:@"You have a Friend request. want to see?"] AlertFlag:3 ButtonFlag:2];
            }
        }
        else if ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"I"])
        {
            self.isInvited=YES;
            
          
            
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
            {
                
                EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
                [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[notificationDict valueForKey:@"event_id"]]];
                
                [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventDetailVC animated:YES];
                
                
                
            }
            else{
                
                
                
                
                UINavigationController *navigation = (UINavigationController *)self.tabBarController.selectedViewController;
                if ([navigation.visibleViewController isKindOfClass:[EventDetailViewController class]])
                {
                 
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"commentAdded" object:nil userInfo:nil];
                    
                }
                else{
                    
                    
                    //************ increase filter pop up count here
                    
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshView" object:nil userInfo:nil];
                    
//                    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:0];
//                    
//                    int count =[[item badgeValue] intValue];
//                    
//                    [item setBadgeValue:[NSString stringWithFormat:@"%d",count+1]];
                    
                    
                    
                    
                }
            
            }
        
            
            if(![self.navigationController.visibleViewController isKindOfClass:[MyEventsViewController class]])
            {
            
                
               // [self showalert:nil Message:[NSString stringWithFormat:@"%@",[[dict valueForKey:@"aps"] valueForKey:@"alert"]] AlertFlag:4 ButtonFlag:2];
            }
            
        }
        else if  ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"U"]||[[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"V"]||[[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"C"])
        {
                     
            
            
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
            {
                
                EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
                [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[notificationDict valueForKey:@"event_id"]]];
                
                [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventDetailVC animated:YES];
                
                
                
            }
            else{
                
                
                
                if ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"U"])
                {
            
                    [self showalert:nil Message:[NSString stringWithFormat:@"%@",[[dict valueForKey:@"aps"] valueForKey:@"alert"]] AlertFlag:6 ButtonFlag:2];
                 
                    
                }
                else if ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"V"])
                {
                    
                    [self showalert:nil Message:[NSString stringWithFormat:@"%@",[[dict valueForKey:@"aps"] valueForKey:@"alert"]] AlertFlag:5 ButtonFlag:2];
                    
                    
                }
                else if ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"C"])
                {
                    
                    
                    UINavigationController *navigation = (UINavigationController *)self.tabBarController.selectedViewController;
                    if(![navigation.visibleViewController isKindOfClass:[TimeLineViewController class]])
                    {
                        
                        
                        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:2];
                        
                        int count =[[item badgeValue] intValue];
                        
                        [item setBadgeValue:[NSString stringWithFormat:@"%d",count+1]];
                        
                        
                    }
                    
                    
                    
                }
           
            }
            
           
                     
        }
    
        //********* new added
//        
//        else if ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"V"])
//        {
//            
//            EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
//            [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[notificationDict valueForKey:@"event_id"]]];
//            
//            [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventDetailVC animated:YES];
//         
//            if(![self.navigationController.visibleViewController isKindOfClass:[MyEventsViewController class]])
//            {
//      
//                //[self showalert:nil Message:[NSString stringWithFormat:@"%@",[[dict valueForKey:@"aps"] valueForKey:@"alert"]] AlertFlag:5 ButtonFlag:2];
//            }
//            
//        }
//     
//        else if ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"U"])
//        {
//         
//            
//            
//            EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
//            [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[notificationDict valueForKey:@"event_id"]]];
//            
//            [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventDetailVC animated:YES];
//            
//            if(![self.navigationController.visibleViewController isKindOfClass:[MyEventsViewController class]])
//            {
//         
//                //[self showalert:nil Message:[NSString stringWithFormat:@"%@",[[dict valueForKey:@"aps"] valueForKey:@"alert"]] AlertFlag:6 ButtonFlag:2];
//            }
//            
//        }
        
        //*******************
        
        
        else if ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"A"])
        {
            
            
            
            
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
            {
                
                UserTabViewController *objVC =[[UserTabViewController alloc] initWithNibName:@"UserTabViewController" bundle:nil];
    
                DELEGATE.tabBarController = (UITabBarController *)DELEGATE.window.rootViewController;
                DELEGATE.tabBarController.selectedIndex = 3;
    
                [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:objVC animated:YES];

                
                
            }
            else{
                
                
                UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:3];
                
                int count =[[item badgeValue] intValue];
                
                [item setBadgeValue:[NSString stringWithFormat:@"%d",count+1]];
                
                
            }
            
            
            
            
      
//              frinedReqbadgeValue++;
//      
//            
//            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:3];
//            
//            if(frinedReqbadgeValue==0)
//            {
//                [item setBadgeValue:nil];
//            }
//            else
//            {
//                [item setBadgeValue:[NSString stringWithFormat:@"%d",frinedReqbadgeValue]];
//            }
//            
//            
//            UserTabViewController *objVC =[[UserTabViewController alloc] initWithNibName:@"UserTabViewController" bundle:nil];
//            
//            DELEGATE.tabBarController = (UITabBarController *)DELEGATE.window.rootViewController;
//            DELEGATE.tabBarController.selectedIndex = 3;
//            
//            [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:objVC animated:YES];


          
             //[self showalert:nil Message:[localization localizedStringForKey:@"Your friend request accepted. want to see?"] AlertFlag:7 ButtonFlag:2];
           
        }
        else if ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"R"])
        {
   
            [self showalert:nil Message:[localization localizedStringForKey:@"Your friend request rejected."] AlertFlag:1 ButtonFlag:1];
         
        }
//        else if ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"C"])
//        {
//            
//            if(![self.navigationController.visibleViewController isKindOfClass:[TimeLineViewController class]])
//            {
//                
//                BoardbadgeValue++;
//                
//                UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:2];
//                
//                if(BoardbadgeValue==0)
//                {
//                    [item setBadgeValue:nil];
//                }
//                else
//                {
//                    [item setBadgeValue:[NSString stringWithFormat:@"%d",BoardbadgeValue]];
//                }
//                
//                
//                UINavigationController *navigation = (UINavigationController *)self.tabBarController.selectedViewController;
//                if ([navigation.visibleViewController isKindOfClass:[EventDetailViewController class]])
//                {
//                    [[NSNotificationCenter defaultCenter]postNotificationName:@"commentAdded" object:nil userInfo:nil];
//                    
//                    
//                }
//                
//                else{
//                    
//                    EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
//                    [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[notificationDict valueForKey:@"event_id"]]];
//                    
//                    [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventDetailVC animated:YES];
//                    
//                    
//                    
//                }
//                
//
//                
//               // [self showalert:nil Message:[NSString stringWithFormat:@"%@",[[dict valueForKey:@"aps"] valueForKey:@"alert"]] AlertFlag:4 ButtonFlag:5];
//                
//                
//            }
//            
//           
//        }
        
    }
    else
    {
       /* if ([[[dict valueForKey:@"aps"] valueForKey:@"type"]isEqualToString:@"A"])
        {
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[[dict valueForKey:@"aps"] valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"You have a Notification"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
            [alert show];
        }*/
        
    }
    
}





-(void)ok2BtnTapped:(UIButton *)sender
{
    // NSLog(@"ok2BtnTapped");
    [[self.window viewWithTag:123] removeFromSuperview];
    if(sender.tag==3)
    {
        
        FriendRequestViewController *frndVC =[[FriendRequestViewController alloc] initWithNibName:@"FriendRequestViewController" bundle:nil];
        [frndVC setIsFriend:YES];
        
        DELEGATE.tabBarController = (UITabBarController *)DELEGATE.window.rootViewController;
        DELEGATE.tabBarController.selectedIndex = 4;
        
        [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:frndVC animated:YES];
    }
    if(sender.tag==4)
    {
        
        
        
        UINavigationController *navigation = (UINavigationController *)self.tabBarController.selectedViewController;
        if ([navigation.visibleViewController isKindOfClass:[EventDetailViewController class]])
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"commentAdded" object:nil userInfo:nil];
            
            
        }
        
        else{
            
            EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
            [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[notificationDict valueForKey:@"event_id"]]];
            
            [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventDetailVC animated:YES];
            
            
            
        }
        
        
    }
    
    
    //*********** new added for voting end & upcoming event
    
    if(sender.tag==5)
    {
        EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
        [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[notificationDict valueForKey:@"event_id"]]];
        
        [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventDetailVC animated:YES];
    }
    
    
    
    
    if(sender.tag==6)
    {
        EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
        [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[notificationDict valueForKey:@"event_id"]]];
        
        [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventDetailVC animated:YES];
    }
    
    //************* request accepted ******
    
    if(sender.tag==7)
    {
        UserTabViewController *objVC =[[UserTabViewController alloc] initWithNibName:@"UserTabViewController" bundle:nil];
        
        DELEGATE.tabBarController = (UITabBarController *)DELEGATE.window.rootViewController;
        DELEGATE.tabBarController.selectedIndex = 3;
        
        [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:objVC animated:YES];
    }
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==10)
    {
        if (buttonIndex == 1)
        {
            FriendRequestViewController *frndVC =[[FriendRequestViewController alloc] initWithNibName:@"FriendRequestViewController" bundle:nil];
            [frndVC setIsFriend:YES];
            
            DELEGATE.tabBarController = (UITabBarController *)DELEGATE.window.rootViewController;
            DELEGATE.tabBarController.selectedIndex = 4;
            
            [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:frndVC animated:YES];
        }
    }
    else if(alertView.tag==11)
    {
        if (buttonIndex == 1)
        {
            MyEventsViewController *eventVC =[[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
            [eventVC setIsInvite:YES];
            
            DELEGATE.tabBarController = (UITabBarController *)DELEGATE.window.rootViewController;
            DELEGATE.tabBarController.selectedIndex = 4;
            
            [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:eventVC animated:YES];
        }
    }
 
}
- (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}
-(void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray *)locations
{
    CLLocation *location;
    location =  [manager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    currentLocation = [[CLLocation alloc] init];
    _longitude = coordinate.longitude;
    _latitude = coordinate.latitude;
}

-(void)responseLoginGoogleUser:(NSDictionary *)results
{
    
}

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
}
//- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
//    // set facebook session
//
//    
//    return [FBSession openActiveSessionWithReadPermissions:nil
//                                              allowLoginUI:NO
//                                         completionHandler:^(FBSession *session,
//                                                             FBSessionState state,
//                                                             NSError *error) {
//                                             
//                                             if (!error) {
//                                                 [FBSession setActiveSession:session];
//                                             }
//                                             
//                                             [self sessionStateChanged:session
//                                                                 state:state
//                                                                 error:error];
//                                         }];
//    
//}
//- (void)sessionStateChanged:(FBSession *)session
//                      state:(FBSessionState) state
//                      error:(NSError *)error
//{
//    switch (state) {
//        case FBSessionStateOpen:
//            if (!error) {
//                // We have a valid session
//               // NSLog(@"User session found");
//            }
//            break;
//        case FBSessionStateClosed:
//           // NSLog(@"User session found");
//            break;
//        case FBSessionStateClosedLoginFailed:
//            [FBSession.activeSession closeAndClearTokenInformation];
//            break;
//        default:
//            break;
//    }
//    
//    /*  [[NSNotificationCenter defaultCenter]
//     postNotificationName:FBSessionStateChangedNotification
//     object:session];*/
//    
//    if (error) {
//        
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:[localization localizedStringForKey:@"Error"]
//                                  message:error.localizedDescription
//                                  delegate:nil
//                                  cancelButtonTitle:[localization localizedStringForKey:@"Ok"]
//                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    if ([parsedUrl appLinkData])
    {
        NSURL *targetUrl = [parsedUrl targetURL];
        //process applink data
        
        NSLog(@"%@",targetUrl);
        
        [[UIApplication sharedApplication] openURL:targetUrl];
        
        
    }
 
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
 
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    
//    
//    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
//    if ([parsedUrl appLinkData]) {
//        NSURL *targetUrl = [parsedUrl targetURL];
//        //process applink data
//        
//        NSLog(@"%@",targetUrl);
//        
//        [[UIApplication sharedApplication] openURL:targetUrl];
//        
//        
//    }
//    
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                          openURL:url
//                                                sourceApplication:sourceApplication
//                                                       annotation:annotation];
//}




#pragma mark - Core Data stack


- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MatchMedia" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MatchMedia.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
              //  NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (NSString *)GettingDirectryPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // return [NSString stringWithFormat:@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.locationManager stopUpdatingLocation];
    
    isShowNotification =NO;
    isBecameActive=NO;
    
   /* BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{ [self backgroundHandler]; }];
    if (backgroundAccepted)
    {
        NSLog(@"VOIP backgrounding accepted");
    }*/
  

}
- (void)backgroundHandler {
    
    NSLog(@"### -->VOIP backgrounding callback"); // What to do here to extend timeout?
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    isBecameActive=NO;
    
    [self connect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
     [FBSDKAppEvents activateApp];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [self.locationManager startUpdatingLocation];
    
    if(([defaults valueForKey:@"userid"] && [defaults valueForKey:@"updated"]) && isLaunched)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"becomeActive" object:nil userInfo:nil];

    }
    
   /* if(isLaunched)
    {        //becomeActive
        [[NSNotificationCenter defaultCenter]postNotificationName:@"becomeActive" object:nil userInfo:nil];
        
    }*/
    isLaunched=YES;
  //  [self testMessageArchiving];
   
}
-(void)testMessageArchiving{
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
     NSError *error;
      NSArray *messages1 = [moc executeFetchRequest:request error:&error];
    
     [self print:[[NSMutableArray alloc]initWithArray:messages1]];
}
-(void)print:(NSMutableArray*)messages1
{
    
    for (XMPPMessageArchiving_Message_CoreDataObject *message in messages1) {
         NSLog(@"messageStr param is %@",message.messageStr);
        //  NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
        //  NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
        //   NSLog(@"NSCore object id param is %@",message.objectID);
        //  NSLog(@"bareJid param is %@",message.bareJid);
        //   NSLog(@"bareJidStr param is %@",message.bareJidStr);
        //    NSLog(@"body param is %@",message.body);
        //    NSLog(@"timestamp param is %@",message.timestamp);
        //   NSLog(@"outgoing param is %d",[message.outgoing intValue]);
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   
    [USER_DEFAULTS removeObjectForKey:@"catid"];
    [USER_DEFAULTS synchronize];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}


- (void)saveContext
{
    @try
    {
        NSError *error = nil;
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        if (managedObjectContext != nil) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //  NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                // abort();
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@", exception.reason);
        NSLog(@" in catch block");
        
    }
    @finally {
        NSLog(@" in finally block");
        
    }
    
    
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
   //roomStorage = [[XMPPRoomMemoryStorage alloc] init];
    //    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"setup"]isEqualToString:@"Y"]) {
    //
    //    }
    //    else
    //    {
    //        [[NSUserDefaults standardUserDefaults]setValue:@"Y" forKeyPath:@"setup"];
    //        [[NSUserDefaults standardUserDefaults]synchronize];
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
  //  xmppStream.enableBackgroundingOnSocket = YES;

    [xmppReconnect activate:self.xmppStream];
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    [reciept setAutoSendMessageDeliveryReceipts:YES];
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    
    
    xmppLastActivity = [[XMPPLastActivity alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [xmppLastActivity addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    [xmppLastActivity      activate:xmppStream];
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    [xmppStream setHostName:HostingServer];
    [xmppStream setHostPort:5222];
    
    
    // You may need to alter these settings depending on the server you're connecting to
    allowSelfSignedCertificates = NO;
    allowSSLHostNameMismatch = NO;
    // }
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    [xmppLastActivity removeDelegate:self];
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    [xmppLastActivity    deactivate];
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
}
- (void)goOnline
{
    NSLog(@"ZAKIRzakir");
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
    NSLog(@"connected called");
    if (![xmppStream isDisconnected]) {
        
        
        if(!isBecameActive)
        {
            isShowNotification =NO;
        }
        
        if(!isBecameActive && !isShowNotification)
        {
            [self performSelector:@selector(hideNotificationBar) withObject:nil afterDelay:10.0];
        }
        
        return YES;
    }
    
    XMPPMessageDeliveryReceipts* xmppMessageDeliveryRecipts = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryReceipts = YES;
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryRequests = YES;
    [xmppMessageDeliveryRecipts activate:self.xmppStream];
    
    //	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    //	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    NSString *myJID =[USER_DEFAULTS valueForKey:@"myjid"];
    NSString *myPassword = @"123";
    
   // NSString *myJID =@"aklesh@192.168.1.100";//[[NSUserDefaults standardUserDefaults]valueForKey:@"myjid"];
   // NSString *myPassword = @"123";
    //
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    // myJID = @"user@gmail.com/xmppframework";
    // myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        
        //DDLogError(@"Error connecting: %@", error);
        return NO;
    }
    if(!isBecameActive)
    {
        isShowNotification =NO;
    }
    if(!isBecameActive && !isShowNotification)
    {
        [self performSelector:@selector(hideNotificationBar) withObject:nil afterDelay:10.0];
    }
    //[self performSelector:@selector(hideNotificationBar) withObject:nil afterDelay:10.0];

    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
     [[NSNotificationCenter defaultCenter]postNotificationName:@"PresenceChanged" object:nil userInfo:nil];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (allowSelfSignedCertificates)
    {
        [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
    }
    
    if (allowSSLHostNameMismatch)
    {
        [settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
    }
    else
    {
        // Google does things incorrectly (does not conform to RFC).
        // Because so many people ask questions about this (assume xmpp framework is broken),
        // I've explicitly added code that shows how other xmpp clients "do the right thing"
        // when connecting to a google server (gmail, or google apps for domains).
        
        NSString *expectedCertName = nil;
        
        NSString *serverDomain = xmppStream.hostName;
        NSString *virtualDomain = [xmppStream.myJID domain];
        
        if ([serverDomain isEqualToString:@"talk.google.com"])
        {
            if ([virtualDomain isEqualToString:@"gmail.com"])
            {
                expectedCertName = virtualDomain;
            }
            else
            {
                expectedCertName = serverDomain;
            }
        }
        else if (serverDomain == nil)
        {
            expectedCertName = virtualDomain;
        }
        else
        {
            expectedCertName = serverDomain;
        }
        
        if (expectedCertName)
        {
            [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
        }
    }
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    //DDLogVerbose(@" didd connect %@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    // NSLog(@"didReceiveIQ %@", iq);
    //return NO;
    if ([TURNSocket isNewStartTURNRequest:iq]) {
        NSLog(@"IS NEW TURN request..");
        TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] incomingTURNRequest:iq];
      //  NSLog(@"is a client = %hhd", turnSocket.isClient);
        //[turnSocket addObject:turnSocket];
        [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    return YES;
}
- (void)xmppLastActivity:(XMPPLastActivity *)sender didReceiveResponse:(XMPPIQ *)response
{
  //  NSLog(@"last activity: %lu", (unsigned long)[response lastActivitySeconds]);
    _lastSeconds = (unsigned long)[response lastActivitySeconds];
    NSNotification *lastSeen = [NSNotification notificationWithName:@"lastSeen" object:self];
    [[NSNotificationCenter defaultCenter]postNotification:lastSeen];
    
}
- (void)xmppLastActivity:(XMPPLastActivity *)sender didNotReceiveResponse:(NSString *)queryID dueToTimeout:(NSTimeInterval)timeout
{
   // NSLog(@"%@",queryID);
    [xmppLastActivity sendLastActivityQueryToJID:[XMPPJID jidWithString:DELEGATE.FrienID]];
    
    
}

- (void)xmppStream:(XMPPStream *)sender socketWillConnect:(GCDAsyncSocket *)socket
{
    // Tell the socket to stay around if the app goes to the background (only works on apps with the VoIP background flag set)
    [socket performBlock:^{
        [socket enableBackgroundingOnSocket];
    }];
}
-(NSString *)getTimestamp:(NSDate *)date
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss a"] ;
    
    NSTimeInterval interval  = [date timeIntervalSince1970] ;
  //  NSLog(@"interval=%f",interval) ;
    return [NSString stringWithFormat:@"%f",interval];
    // NSDate *methodStart = [NSDate dateWithTimeIntervalSince1970:interval] ;
    //[dateFormatter setDateFormat:@"yyyy/MM/dd "] ;
    // NSLog(@"result: %@", [dateFormatter stringFromDate:methodStart]) ;
    
    
    
}
- (NSString *) GetUniversalTime:(NSDate *)IN_strLocalTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss a"];
    // NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *strDateTime   = [dateFormatter stringFromDate:IN_strLocalTime];
    NSDate *objUTCDate  = [dateFormatter dateFromString:strDateTime];
    double seconds = (long long)([objUTCDate timeIntervalSince1970] );
    
    NSString *strTimeStamp = [NSString stringWithFormat:@"%f",seconds];
  //  NSLog(@"The Timestamp is = %@",strTimeStamp);
    return strTimeStamp;
}

-(void)hideNotificationBar
{
    isShowNotification =YES;
    isBecameActive =YES;
    [self getAllUnreadMessages];
    
   // NSNotification *notification1 = [NSNotification notificationWithName:@"UnreadGroupMessage" object:self];
   // [[NSNotificationCenter defaultCenter]postNotification:notification1];

}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
   
   // XMPPJID *user =[message from];

   // NSLog(@"%@",message);
  //  NSLog(@"%@",[message from] );
 
  //  NSLog(@"messageType is %@",[message attributeForName:@"messageType"] );
    
  //  NSLog(@"messageType is %@",[message attributeForName:@"type"] );

    
    
    /* for android group chat
     <message xmlns="jabber:client" id="kKfL8-12" to="user35@amhappy.es/3494daa3" type="groupchat" from="room23@conference.amhappy.es/androidtest2"><body>ye lo</body><request xmlns="urn:xmpp:receipts"/></message>
     
     
     for iOS group chat
     <message xmlns="jabber:client" type="groupchat" to="user41@amhappy.es/875df45d" messageType="G" id="F4D57F83-C758-4834-8CE7-3EC6CFCAD2F9" sendername="chris" align="L" from="room23@conference.amhappy.es/chris"><body>W</body></message>
     
     for iOS personal chat
     <message xmlns="jabber:client" type="chat" to="user41@amhappy.es" messageType="C" id="6AC1DBDF-185D-4188-95BA-57ED3C19B5D2" sendername="chris" align="L" from="user35@amhappy.es/8f0b087f"><body>Dbdnb</body><request xmlns="urn:xmpp:receipts"/></message>
     
     

     */

    
    
    
    
    
    @try
    {
        if ([message isChatMessage])
        {
            
            
            XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                     xmppStream:xmppStream
                                                           managedObjectContext:[self managedObjectContext_roster]];
            
            /*
             <message xmlns="jabber:client" id="l80Cs-73" to="aklesh@192.168.1.100" from="aabid@192.168.1.100/Spark 2.6.3" type="chat"><body>hello</body><thread>810X8N</thread><x xmlns="jabber:x:event"><offline/><composing/></x></message>
             */
            
            /* for android */
            /*
             <message xmlns="jabber:client" id="q7pJN-11" to="user35@amhappy.es" from="user37@amhappy.es/amHappy.57DEF16C" type="chat"><body>yo chrish</body><request xmlns="urn:xmpp:receipts"/><properties xmlns="http://www.jivesoftware.com/xmlns/xmpp/properties"><property><name>sendername</name><value type="string">androidtest2</value></property></properties></message>
             */
            
            
            NSString *body = [[message elementForName:@"body"] stringValue];
            NSString *idd = [[message attributeForName:@"messageType"] stringValue];
            // NSLog(@"messageType is %@",[message attributeForName:@"messageType"] );
            
            
            
            NSMutableArray *messages = [[NSMutableArray alloc ] init];
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            if ([def valueForKey:[NSString stringWithFormat:@"%@",[user jid]]] != nil) {
                messages = [NSMutableArray arrayWithArray:[def valueForKey:[NSString stringWithFormat:@"%@",[user jid]]]];
                
            }
            FriendMessage = [NSString stringWithString:body];
            FriendMessage = [NSString stringWithFormat:@"%@",[self substituteEmoticons:FriendMessage]];
            
            
            NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
            [m setObject:[NSString stringWithFormat:@"%@",[self substituteEmoticons:FriendMessage]] forKey:@"msg"];
            
            
            [m setObject:@"r" forKey:@"align"];
            NSDate *nowUTC = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            [m setObject:[dateFormatter stringFromDate:nowUTC] forKey:@"time"];
            [messages addObject:m];
            [def setObject:messages forKey:[NSString stringWithFormat:@"%@",[user jid]]];
            
            
            NSString *MyNickname = [[message attributeForName:@"MyNickname"] stringValue];
            
            
            
            // if ([[[message attributeForName:@"messageType"] stringValue] isEqualToString:@"C"])
            //  {
            
            
            DB *DB1;
            DB1 = [DB newInsertedObject];
            DB1.messageType =@"C";
            DB1.identifier = @([CoreDataUtils getNextID:[DB description]]);
            BOOL isfrom=NO;
            DB1.isClear = @"Y";
            DB1.from=@(isfrom);
            DB1.timestamp = nowUTC;
            DB1.time = [self GetUniversalTime:nowUTC];
            DB1.idd=[[message attributeForName:@"sendername"] stringValue];
            
            if([USER_DEFAULTS valueForKey:@"myjid"])
            {
                NSString *str = [NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"myjid"]];
                NSArray *myArray1 = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
                DB1.userid = [myArray1 objectAtIndex:0] ;
            }
            
            DB1.message =[[message elementForName:@"body"] stringValue];
            DB1.isShow = @"R" ;
            
            NSString *abc = [NSString stringWithFormat:@"%@",[message from]];
            NSArray *myArray = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
            DB1.jid = [myArray objectAtIndex:0];
            
            
            UINavigationController *controller =[self.tabBarController.viewControllers objectAtIndex:3];
            
            
            if([controller.visibleViewController isKindOfClass:[ChatViewController class]])
            {
                if([[USER_DEFAULTS valueForKey:@"fromJId"] isEqualToString:[myArray objectAtIndex:0]])
                {
                    DB1.unread=@"N";
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"PresenceChanged" object:nil userInfo:nil];
                }
                else
                {
                    DB1.unread=@"Y";
                    if([USER_DEFAULTS valueForKey:@"recieve_push"])
                    {
                        if([[USER_DEFAULTS valueForKey:@"recieve_push"] isEqualToString:@"Y"])
                        {
                            if(isBecameActive && isShowNotification)
                            {
                                AudioServicesPlaySystemSound(1002);
                                CMNavBarNotificationView *notif= [CMNavBarNotificationView notifyWithText:MyNickname andDetail:[NSString stringWithFormat:@"%@ : %@",user.displayName,[[message elementForName:@"body"] stringValue]]];
                                [notif setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:161.0/255.0 blue:20.0/255.0 alpha:1.0]];
                            }
                            
                        }
                    }
                    
                }
                
            }
            else
            {
                DB1.unread=@"Y";
                
                if([USER_DEFAULTS valueForKey:@"recieve_push"])
                {
                    if([[USER_DEFAULTS valueForKey:@"recieve_push"] isEqualToString:@"Y"])
                    {
                        if(isBecameActive && isShowNotification)
                        {
                            AudioServicesPlaySystemSound(1002);
                            
                            CMNavBarNotificationView *notif= [CMNavBarNotificationView notifyWithText:MyNickname andDetail:[NSString stringWithFormat:@"%@ : %@",user.displayName,[[message elementForName:@"body"] stringValue]]];
                            [notif setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:161.0/255.0 blue:20.0/255.0 alpha:1.0]];
                        }
                        
                    }
                }
                
            }
            
            [CoreDataUtils updateDatabase];
            
            if ([idd isEqualToString:@"G"])
            {
                if(isBecameActive && isShowNotification)
                {
                    NSNotification *notification2 = [NSNotification notificationWithName:@"Unread1" object:self];
                    [[NSNotificationCenter defaultCenter]postNotification:notification2];
                }
                
                
            }
            else
            {
                if(isBecameActive && isShowNotification)
                {
                    NSNotification *notification1 = [NSNotification notificationWithName:@"UnreadGroupMessage" object:self];
                    [[NSNotificationCenter defaultCenter]postNotification:notification1];
                    [self getAllUnreadMessages];
                }
                
            }
            
            if(isBecameActive && isShowNotification)
            {
                [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:YES];
                
            }
        }
        else if ([[[message attributeForName:@"type"] stringValue] isEqualToString:@"groupchat"] && [[message attributeForName:@"type"] stringValue] !=nil)
        {
            //  NSLog(@"message is %@",message);
            //  NSLog(@"message from is %@",[message from] );
            UINavigationController *controller =[self.tabBarController.viewControllers objectAtIndex:3];
            
            /*
             <message xmlns="jabber:client" type="groupchat" to="user41@amhappy.es/8906790c" messageType="G" id="27826F14-9E1D-4846-8DE0-A5BF9E04EE6D" sendername="chris" align="L" from="room23@conference.amhappy.es/chris"><body>,&amp;,&amp;</body></message>
             */
            
            //message from is room23@conference.amhappy.es/chris
            
            NSString *abc = [NSString stringWithFormat:@"%@",[message from]];
            NSArray *myArray = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            
            NSString *messageID=[DELEGATE.xmppStream generateUUID];
            NSDate *nowUTC = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            
            if(![controller.visibleViewController isKindOfClass:[ChatViewController class]])
            {
                
                if([USER_DEFAULTS valueForKey:@"recieve_push"])
                {
                    if([[USER_DEFAULTS valueForKey:@"recieve_push"] isEqualToString:@"Y"])
                    {
                        if(isBecameActive && isShowNotification)
                        {
                            AudioServicesPlaySystemSound(1002);
                            
                            CMNavBarNotificationView *notif= [CMNavBarNotificationView notifyWithText:@"" andDetail:[NSString stringWithFormat:@"%@ : %@",[myArray objectAtIndex:1],[[message elementForName:@"body"] stringValue]]];
                            [notif setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:161.0/255.0 blue:20.0/255.0 alpha:1.0]];
                        }
                        
                    }
                }
                
                
                if(![[myArray objectAtIndex:1] isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
                {
                    DB *DB1;
                    DB1 = [DB newInsertedObject];
                    DB1.waitingType =messageID;
                    DB1.delivered =@"Y";
                    DB1.messageType =@"G";
                    DB1.identifier = @([CoreDataUtils getNextID:[DB description]]);
                    BOOL isfrom=NO;
                    
                    DB1.from=@(isfrom);
                    DB1.timestamp = nowUTC;
                    DB1.time = [DELEGATE GetUniversalTime:nowUTC];
                    DB1.idd =[myArray objectAtIndex:1] ;//[USER_DEFAULTS valueForKey:@"fullname"];
                    NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
                    NSString *str =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
                    DB1.userid = str ;
                    DB1.message =[[message elementForName:@"body"] stringValue];
                    
                    DB1.isShow = @"R" ;
                    DB1.isClear = @"Y";
                    // }
                    
                    NSString *abc = [NSString stringWithFormat:@"%@",[message from]];
                    NSArray *myArray = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
                    DB1.jid = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]]];
                    DB1.unread=@"Y";
                    [CoreDataUtils updateDatabase];
                    
                    if(isBecameActive && isShowNotification)
                    {
                        NSNotification *notification1 = [NSNotification notificationWithName:@"UnreadGroupMessage" object:self];
                        [[NSNotificationCenter defaultCenter]postNotification:notification1];
                        [self getAllUnreadMessages];
                    }
                    
                    
                    
                }
                
                
                
            }
            else
            {
                NSString *abc = [NSString stringWithFormat:@"%@",[message from]];
                NSArray *array = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
                if(![[USER_DEFAULTS valueForKey:@"fromJId"] isEqualToString:[array objectAtIndex:0]])
                {
                    if([USER_DEFAULTS valueForKey:@"recieve_push"])
                    {
                        if([[USER_DEFAULTS valueForKey:@"recieve_push"] isEqualToString:@"Y"])
                        {
                            if(isBecameActive && isShowNotification)
                            {
                                
                                AudioServicesPlaySystemSound(1002);
                                
                                CMNavBarNotificationView *notif= [CMNavBarNotificationView notifyWithText:@"" andDetail:[NSString stringWithFormat:@"%@ : %@",[myArray objectAtIndex:1],[[message elementForName:@"body"] stringValue]]];
                                
                                [notif setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:161.0/255.0 blue:20.0/255.0 alpha:1.0]];
                            }
                            
                        }
                    }
                    
                    
                    
                    
                    
                    
                    DB *DB1;
                    DB1 = [DB newInsertedObject];
                    DB1.waitingType =messageID;
                    DB1.delivered =@"Y";
                    DB1.messageType =@"G";
                    DB1.identifier = @([CoreDataUtils getNextID:[DB description]]);
                    BOOL isfrom=NO;
                    
                    DB1.from=@(isfrom);
                    DB1.timestamp = nowUTC;
                    DB1.time = [DELEGATE GetUniversalTime:nowUTC];
                    DB1.idd =[myArray objectAtIndex:1] ;//[USER_DEFAULTS valueForKey:@"fullname"];
                    NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
                    NSString *str =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
                    DB1.userid = str ;
                    DB1.message =[[message elementForName:@"body"] stringValue];
                    
                    DB1.isShow = @"R" ;
                    DB1.isClear = @"Y";
                    // }
                    
                    NSString *abc = [NSString stringWithFormat:@"%@",[message from]];
                    NSArray *myArray = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
                    DB1.jid = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]]];
                    DB1.unread=@"Y";
                    [CoreDataUtils updateDatabase];
                    
                    if(isBecameActive && isShowNotification)
                    {
                        NSNotification *notification1 = [NSNotification notificationWithName:@"UnreadGroupMessage" object:self];
                        [[NSNotificationCenter defaultCenter]postNotification:notification1];
                        [self getAllUnreadMessages];
                    }
                    
                    
                }
                else
                {
                    self.db = [CoreDataUtils getObject:[DB description] withQueryString:@"waitingType = %@ " queryArguments:@[[[message attributeForName:@"id"] stringValue]]];
                    self.db.delivered = @"Y";
                    [CoreDataUtils updateDatabase];
                    
                    if(isBecameActive && isShowNotification)
                    {
                        NSNotification *notification = [NSNotification notificationWithName:@"myDliver" object:self];
                        [[NSNotificationCenter defaultCenter]postNotification:notification];
                    }
                    
                }
            }
            
        }
        else
        {
            /* if ([idd isEqualToString:@"C"])
             {*/
            //groupchat
            ;
            if([[message elementsForName:@"received"] count]>0)
            {
                //  NSLog(@"%@",[[[[message elementsForName:@"received"] objectAtIndex:0] attributeForName:@"id"] stringValue] );
                
                self.db = [CoreDataUtils getObject:[DB description] withQueryString:@"waitingType = %@" queryArguments:@[[[[[message elementsForName:@"received"] objectAtIndex:0] attributeForName:@"id"] stringValue]]];
                self.db.delivered = @"Y";
                [CoreDataUtils updateDatabase];
                
                if(isBecameActive && isShowNotification)
                {
                    NSNotification *notification = [NSNotification notificationWithName:@"myDliver" object:self];
                    [[NSNotificationCenter defaultCenter]postNotification:notification];
                }
                
            }
            
            // }
            
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@", exception.reason);
        NSLog(@" in catch block");
        
    }
    @finally {
        NSLog(@" in finally block");
        
    }
    
}

-(void)notify
{
    NSNotification *notification = [NSNotification notificationWithName:@"myMessage" object:self];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}


- (NSString *) substituteEmoticons:(NSString *)stringToReplace {
    //See http://www.easyapns.com/iphone-emoji-alerts for a list of emoticons available
    NSString *res = [stringToReplace stringByReplacingOccurrencesOfString:@":)" withString:@"\ue415"];
    res = [res stringByReplacingOccurrencesOfString:@":(" withString:@"\ue403"];
    res = [res stringByReplacingOccurrencesOfString:@";-)" withString:@"\ue405"];
    res = [res stringByReplacingOccurrencesOfString:@":-x" withString:@"\ue418"];
    res = [res stringByReplacingOccurrencesOfString:@"(Y)" withString:@"\ue00e"];
    
    return res;
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    
    if([presence fromStr])
    {
        if([USER_DEFAULTS valueForKey:@"fromJId"])
        {
            NSString *abc = [NSString stringWithFormat:@"%@",[presence fromStr]];
            NSArray *myArray = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
           if([[USER_DEFAULTS valueForKey:@"fromJId"] isEqualToString:[myArray objectAtIndex:0]])
            {
             //   NSLog(@"presence found %@",[presence fromStr]);
                [[NSNotificationCenter defaultCenter]postNotificationName:@"PresenceChanged" object:nil userInfo:nil];
            }
        }
        
    }
    
   
    @try
    {
        [_presences setValue:presence  forKey:[[presence.fromStr componentsSeparatedByString:@"/"] objectAtIndex:0]];
        
        //    NSXMLElement *showStatus = [presence elementForName:@"status"];
        //    NSString *presenceString = [showStatus stringValue];
        //    NSString *customMessage = [[presence elementForName:@"show"]stringValue];
        
        // NSLog(@"Presence : %@, and presenceMessage: %@",presenceString,customMessage);
        //    NSLog(@"_presences =>>%@",_presences);
        //    NSLog(@"%@",[presence type]);
        //    NSLog(@"%@",[[presence.fromStr componentsSeparatedByString:@"/"] objectAtIndex:0]);
        
        //    NSLog(@"%@ \n %@",presence.fromStr,presence);
        
        if ([DELEGATE.FrienID isEqualToString:[[presence.fromStr componentsSeparatedByString:@"/"] objectAtIndex:0]] )
        {
            [xmppLastActivity sendLastActivityQueryToJID:[XMPPJID jidWithString:DELEGATE.FrienID]];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@", exception.reason);
        NSLog(@" in catch block");
        
    }
    @finally {
        NSLog(@" in finally block");
        
    }
    
    
    
    
}


- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    //DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}
-(void)leaveFromRoom
{
   /* if(xmppRoom)
    {
        [xmppRoom removeDelegate:self];
    }*/
}
-(void)getList
{
    //[USER_DEFAULTS valueForKey:@"myjid"]
   // [NSString stringWithFormat:@"%@",self.xmppStream.myJID];
    XMPPJID *servrJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",self.xmppStream.myJID] ];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[xmppStream myJID].full];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];[xmppStream sendElement:iq];
}
-(void)createRoom:(NSString *)fromJid
{
    XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@conference.%@",fromJid,HostingServer]];
  /*  if(xmppRoom)
    {
        [xmppRoom removeDelegate:self];
    }*/
   
    
    roomStorage = [[XMPPRoomMemoryStorage alloc] init];
    
  //  NSLog(@"received from %@",roomStorage.parent);
    
   /* xmppRoom =roomStorage.parent;
    if(xmppRoom)
    {
        NSLog(@"room is %@",xmppRoom.roomJID);
    }*/

    xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomStorage
                                                 jid:roomJID
                                       dispatchQueue:dispatch_get_main_queue()];
    
   // [xmppRoom removeDelegate:self];
    
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self
            delegateQueue:dispatch_get_main_queue()];
    
   // NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    //           // [history addAttributeWithName:@"maxstanzas" stringValue:@"1000"];
   // [history addAttributeWithName:@"since" stringValue:@"1970-01-01T00:00:00Z"];
    
    
    
    [xmppRoom joinRoomUsingNickname:[USER_DEFAULTS valueForKey:@"fullname"]
                            history:nil
                           password:nil];
    
    [xmppRoom fetchConfigurationForm];
    [self ConfigureNewRoom];
    
    
    
}
- (void)ConfigureNewRoom
{
    
    [xmppRoom configureRoomUsingOptions:nil];
    [xmppRoom fetchConfigurationForm];
    [xmppRoom fetchBanList];
    [xmppRoom fetchMembersList];
    [xmppRoom fetchModeratorsList];
    
}
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    DDLogVerbose(@"%@: %@ -> %@", THIS_FILE, THIS_METHOD, sender.roomJID.user);
}

//#pragma mark XMPPRoom Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    // [logField setStringValue:@"did create room"];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSNotification *notification1 = [NSNotification notificationWithName:@"connected" object:self];
    [[NSNotificationCenter defaultCenter]postNotification:notification1];
    //[logField setStringValue:@"did join room"];
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSNotification *notification1 = [NSNotification notificationWithName:@"connected" object:self];
    [[NSNotificationCenter defaultCenter]postNotification:notification1];
    
    [DELEGATE showalert:nil Message:[localization localizedStringForKey:@"Connection lost due to slow network"] AlertFlag:1 ButtonFlag:1];
    //[logField setStringValue:@"did leave room"];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //[logField setStringValue:[NSString stringWithFormat:@"occupant did join: %@", [occupantJID resource]]];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //[logField setStringValue:[NSString stringWithFormat:@"occupant did join: %@", [occupantJID resource]]];
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
  //  NSLog(@"received from %@",occupantJID.resource);
    
  //  NSLog(@"%@",[self getTime2:[message localTimestamp]] );
   
    
    
    NSDate *nowUTC = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
   // NSString *messageID=[DELEGATE.xmppStream generateUUID];
    
 
    
    DB *db =[CoreDataUtils getObject:[DB description] withQueryString:@"waitingType = %@ " queryArguments:@[[[message attributeForName:@"id"] stringValue]]];
    
    
    if(db)
    {
        [NSString stringWithFormat:@"%@",db.waitingType];
        if([[NSString stringWithFormat:@"%@",db.waitingType] isEqualToString:[NSString stringWithFormat:@"%@",[[message attributeForName:@"id"] stringValue]]])
        {
           // NSLog(@"found");
        }
        else
        {
           // NSLog(@"not found");
        }
    }
    else
    {

        if (occupantJID.resource !=nil)
        {
            if(![occupantJID.resource isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
            {
                DB *DB1;
                DB1 = [DB newInsertedObject];
                DB1.waitingType =[[message attributeForName:@"id"] stringValue];
                DB1.delivered =@"Y";
                DB1.messageType =@"G";
                DB1.identifier = @([CoreDataUtils getNextID:[DB description]]);
                BOOL isfrom=NO;
                
                DB1.from=@(isfrom);
                DB1.timestamp = nowUTC;
                DB1.time = [DELEGATE GetUniversalTime:nowUTC];
                DB1.idd =occupantJID.resource ;//[USER_DEFAULTS valueForKey:@"fullname"];
                NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
                NSString *str =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
                DB1.userid = str ;
                DB1.message =[[message elementForName:@"body"] stringValue];
                
                DB1.isShow = @"R" ;
                DB1.isClear = @"Y";
                // }
                
                NSString *abc = [NSString stringWithFormat:@"%@",[message from]];
                NSArray *myArray = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
                DB1.jid = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]]];
                
                
                UINavigationController *controller =[self.tabBarController.viewControllers objectAtIndex:3];
                //NSLog(@"self.self.navigationController is %@",controller.viewControllers);
                
                
                if(![controller.visibleViewController isKindOfClass:[ChatViewController class]])
                {
                    
                    // DB1.isClear = @"N";
                    DB1.unread=@"Y";
                    [CoreDataUtils updateDatabase];
                    
                    NSNotification *notification1 = [NSNotification notificationWithName:@"UnreadGroupMessage" object:self];
                    [[NSNotificationCenter defaultCenter]postNotification:notification1];
                    [self getAllUnreadMessages];
                    if([USER_DEFAULTS valueForKey:@"recieve_push"])
                    {
                        if([[USER_DEFAULTS valueForKey:@"recieve_push"] isEqualToString:@"Y"])
                        {
                            if(isBecameActive && isShowNotification)
                            {
                                
                                AudioServicesPlaySystemSound(1002);

                                CMNavBarNotificationView *notif= [CMNavBarNotificationView notifyWithText:@"" andDetail:[NSString stringWithFormat:@"Received message from %@",[NSString stringWithFormat:@"%@",occupantJID.resource]]];
                                [notif setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:161.0/255.0 blue:20.0/255.0 alpha:1.0]];
                            }
                            
                            
                        }
                    }
                    
                   
                    
                }
                else
                {
                    
                    DB1.unread=@"N";
                    [CoreDataUtils updateDatabase];
                    
                    
                    NSNotification *notification = [NSNotification notificationWithName:@"myMessage" object:self];
                    [[NSNotificationCenter defaultCenter]postNotification:notification];
                }
                
                
                
                
            }
            
        }
    }

 
    /*for(int i=0;i<array.count;i++)
    {
       DB *dbmanager =[array objectAtIndex:i];
        NSLog(@"array count is %@",dbmanager.waitingType);


    }*/

    
    
    
    
    

}

-(void)getAllUnreadMessages
{
    
    NSString *unread =@"Y";
    NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    NSString *jid =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
    
    NSArray *array =[[NSArray alloc ]initWithArray:[CoreDataUtils getObjects:[DB description] withQueryString:@"userid = %@ AND unread = %@ " queryArguments:@[jid,unread]]];
    
   int badgeCount=0;
   
        badgeCount +=array.count;
    
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:3];
    
    
    
    if(badgeCount==0)
    {
        [item setBadgeValue:nil];
    }
    else
    {
        [item setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
    }
}

#pragma mark XMPPRoomMemoryStorage Delegate


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
              occupantDidJoin:(XMPPRoomOccupantMemoryStorageObject *)occupant
                      atIndex:(NSUInteger)index
                      inArray:(NSArray *)allOccupants {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
}


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
             occupantDidLeave:(XMPPRoomOccupantMemoryStorageObject *)occupant
                      atIndex:(NSUInteger)index
                    fromArray:(NSArray *)allOccupants {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
    
}


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
            occupantDidUpdate:(XMPPRoomOccupantMemoryStorageObject *)occupant
                    fromIndex:(NSUInteger)oldIndex
                      toIndex:(NSUInteger)newIndex
                      inArray:(NSArray *)allOccupants {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
    
}


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
            didReceiveMessage:(XMPPRoomMessageMemoryStorageObject *)message
                 fromOccupant:(XMPPRoomOccupantMemoryStorageObject *)occupantJID
                      atIndex:(NSUInteger)index
                      inArray:(NSArray *)allMessages {
   
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  
    
    
    
    
}
-(NSString *)getTime2:(NSDate *)timestamp
{
    
    //    NSTimeInterval _interval=[timestamp doubleValue];
    //    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    //    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    //    [_formatter setDateFormat:@"hh:mm a"];
    //    NSString *_date=[_formatter stringFromDate:date];
    //    return _date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // [formatter setDateFormat:@"dd/MM/yyyy"];
    //  NSDate *date = [formatter dateFromString:timestamp];
    [formatter setDateFormat:@"EEE, MMM dd, yyyy"];
    NSString *newDate = [formatter stringFromDate:timestamp];
    return newDate;
}
- (void)dealloc
{
    [self teardownStream];
}

@end

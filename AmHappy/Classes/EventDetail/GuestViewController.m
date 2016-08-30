//
//  GuestViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 18/02/15.
//
//

#import "GuestViewController.h"
#import "ModelClass.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "FriendListViewController.h"
//#import <FacebookSDK/FacebookSDK.h>
#import "OtherUserProfileViewController.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "AppFriendViewControllerViewController.h"
#import "UIImageView+WebCache.h"
#import "TYMActivityIndicatorViewViewController.h"
#import "RegistrationViewController.h"
#import "SWTableViewCell.h"


#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface GuestViewController ()<FBSDKAppInviteDialogDelegate>

@end

@implementation GuestViewController
{
    ModelClass *mc;
    NSMutableArray *guestArray;
    NSMutableArray *searchArray;
    BOOL isSearching;
    BOOL isShow;
    TYMActivityIndicatorViewViewController *drk;
    UIToolbar *mytoolbar1;
    
    NSMutableDictionary *dicContact;
    NSMutableArray *contactArray;
    NSMutableArray *mobileArray;
    
    NSMutableArray *twitterArray;


}
@synthesize lblTitle,tableGuest,scrollview,txtSearch,eventID,inviteView,isMy,btnAdd,lblNofound,btnAddAmhappy,isPrivate,isFromChat,eventType,isGroupAdmin;

- (void)viewDidLoad {
    [super viewDidLoad];
    mc=[[ModelClass alloc] init];
    
    
    NSLog(@"%@",eventID);
    NSLog(@"%@",eventType);
    [mc setDelegate:self];
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    guestArray =[[NSMutableArray alloc] init];
    searchArray =[[NSMutableArray alloc] init];
    
    dicContact =[[NSMutableDictionary alloc] init];
    contactArray =[[NSMutableArray alloc] init];
    mobileArray =[[NSMutableArray alloc] init];
    twitterArray =[[NSMutableArray alloc] init];

   
    

     NSLog(@"self.view.Frame=%@", NSStringFromCGRect(self.scrollview.frame));

    
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:TwitteAppKEY andSecret:TwitteAppSecretId];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
    isSearching=NO;
    isShow =NO;
    
    //if(!self.isMy || !self.isPrivate)
    
    [self.inviteView setHidden:YES];
    [self.btnAdd setHidden:YES];

    if(!self.isMy)
    {
        [self.scrollview setContentSize:CGSizeMake(320, 400)];
      //  [self.inviteView setHidden:YES];
       // [self.btnAdd setHidden:YES];
        [self.btnAddAmhappy setHidden:YES];

    }
    else
    {
        [self.scrollview setContentSize:CGSizeMake(320, 555)];

    }
   
    
    if(self.isFromChat)
    {
        self.tableGuest.frame =CGRectMake(self.tableGuest.frame.origin.x, self.tableGuest.frame.origin.y, self.tableGuest.frame.size.width, self.tableGuest.frame.size.height+49);
        self.scrollview.frame =CGRectMake(self.scrollview.frame.origin.x, self.scrollview.frame.origin.y, self.scrollview.frame.size.width, self.scrollview.frame.size.height+49);
    }
    
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

    if(DELEGATE.connectedToNetwork)
    {
        //[mc guestList:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Sel:@selector(responsegetGuest:)];
        
        [mc getAttendList:[USER_DEFAULTS valueForKey:@"userid"] eventid:self.eventID type:eventType Sel:@selector(responsegetGuest:)];
    }
    [GPPSignIn sharedInstance].clientID = GOOGLEKEY;
    [GPPSignIn sharedInstance].scopes= [NSArray arrayWithObjects:kGTLAuthScopePlusLogin, nil];
    [GPPSignIn sharedInstance].shouldFetchGoogleUserID=YES;
    [GPPSignIn sharedInstance].shouldFetchGoogleUserEmail=YES;
    [GPPSignIn sharedInstance].delegate=self;
    
  
    

}

-(void)viewWillAppear:(BOOL)animated
{
    [twitterArray removeAllObjects];
    [contactArray removeAllObjects];
    [mobileArray removeAllObjects];
    [self localize];
   
}
-(void)localize
{
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];
    [self.lblTitle setText:[localization localizedStringForKey:@"Guest"]];
}
-(void)donePressed
{
    [self.view endEditing:YES];
}
-(void)responsegetGuest:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [guestArray addObjectsFromArray:[results valueForKey:@"User"] ];
        if(guestArray.count==0)
        {
            self.lblNofound.text =[localization localizedStringForKey:@"No result found"];
            [self.lblNofound setHidden:NO];

            
        }
        else
        {
           // [self.tableGuest setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            [self.tableGuest setHidden:NO];
            [self.txtSearch setHidden:NO];
            [self.tableGuest reloadData];

        }
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
- (void)handleFriendsTap: (UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];

    UIView *view = [recognizer view];
    if(isSearching)
    {
        if([[[searchArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
        }
    }
    else
    {
        if([[[guestArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[guestArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
        }
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearching)
    {
        if(searchArray.count>0)
        {
            return searchArray.count;
        }
        else return 0;
    }
    else
    {
        if(guestArray.count>0)
        {
            return guestArray.count;
        }
        else return 0;
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
    //cell.delegate=self;
    cell.imgUser.layer.masksToBounds = YES;
    cell.imgUser.layer.cornerRadius = 25.0;
   
    
    
    
    [cell.btnAccept setHidden:YES];
    [cell.btnInvite setHidden:YES];
    
    if ([eventType isEqualToString:@"Y"])
    {
        [cell.btnAdd setHidden:NO];
        [cell.btnAdd setUserInteractionEnabled:YES];
        
        cell.btnAdd.contentMode = UIViewContentModeScaleAspectFill;
        cell.btnAdd.clipsToBounds = YES;
     
                                    
        
    }
    else{
        
        [cell.btnAdd setHidden:YES];
        [cell.btnAdd setUserInteractionEnabled:NO];
    }
    
    
    if (isSearching)
    {
        
        if ([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"is_admin"]isEqualToString:@"Y"])
        {
            [cell.btnAdd setHidden:NO];
            [cell.btnAdd setUserInteractionEnabled:NO];
            [cell.btnAdd setImage:[UIImage imageNamed:@"admin"] forState:UIControlStateNormal];
            
        }
        else
        {
            [cell.btnAdd setHidden:YES];
            [cell.btnAdd setUserInteractionEnabled:NO];
            
        }
   
    }
    else{
        
        if ([[[guestArray objectAtIndex:indexPath.row] valueForKey:@"is_admin"]isEqualToString:@"Y"])
        {
            [cell.btnAdd setHidden:NO];
            [cell.btnAdd setUserInteractionEnabled:NO];
            [cell.btnAdd setImage:[UIImage imageNamed:@"admin"] forState:UIControlStateNormal];
            
        }
        else
        {
            [cell.btnAdd setHidden:YES];
            [cell.btnAdd setUserInteractionEnabled:NO];
            
        }
    
    }
    
    
    
    
    

    
    cell.btnInvite.tag=indexPath.row;
    
    if(!self.isFromChat)
    {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFriendsTap:)];
        tapGestureRecognizer.delegate = self;
        tapGestureRecognizer.cancelsTouchesInView = YES;
        cell.imgUser.tag =indexPath.row;
        [cell.imgUser addGestureRecognizer:tapGestureRecognizer];
    }
    
    
  
    
    if(isSearching)
    {
        if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]] placeholderImage:[UIImage imageNamed:@"mapIcon.png"]];
        }
        
        cell.lblName.text = [[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"];

    }
    else
    {
        if([[[guestArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[guestArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]] placeholderImage:[UIImage imageNamed:@"mapIcon.png"]];
        }
       
        cell.lblName.text = [[guestArray objectAtIndex:indexPath.row] valueForKey:@"name"];

    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (!isGroupAdmin)
    {
        return NO;
        
    }
 
    if ([eventType isEqualToString:@"Y"])
    {
        if(isSearching)
        {
            if (![[[searchArray objectAtIndex:indexPath.row] valueForKey:@"is_admin"]isEqualToString:@"N"])
            {
                return NO;
            }
            else{
                
                return YES;
                
            }
            
        }
        else
        {
            
            if (![[[guestArray objectAtIndex:indexPath.row] valueForKey:@"is_admin"]isEqualToString:@"N"])
            {
                return NO;
            }
            else{
                
                return YES;
                
            }
            
            
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
            if(isSearching)
            {
                frndID =[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
            }
            else
            {
                frndID =[NSString stringWithFormat:@"%@",[[guestArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
            }
            
            [mc MakeAdmin:[USER_DEFAULTS valueForKey:@"userid"] eventid:self.eventID friendid:frndID Sel:@selector(makeAdmin:)];
            
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




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *userID;
    if(isSearching)
    {
        userID =[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
    }
    else
    {
        userID =[NSString stringWithFormat:@"%@",[[guestArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
    }
    
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
   // isSearching = YES;
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
        [self.tableGuest reloadData];
    }
}
- (void)filterListForSearchText:(NSString *)searchText
{
    [searchArray removeAllObjects];
    
    if(guestArray.count>0)
    {
        for(int i=0;i<guestArray.count;i++)
        {
            NSRange nameRange = [[[guestArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound) {
                [searchArray addObject:[guestArray objectAtIndex:i]];
            }
        }
    }
    
    
    [self.tableGuest reloadData];
    
}

- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)inviteTapped:(id)sender
{
}
-(void)accerptTapped:(id)sender
{}
- (IBAction)addTapped:(id)sender
{
    
    
    if(isShow)
    {
        isShow=NO;
        [self.inviteView setHidden:YES];
    }
    else
    {
        isShow=YES;
        [self.inviteView setHidden:NO];
    }
}

- (IBAction)tweetTapped:(id)sender
{
    //android_pb
    //pb.android123
    //[self getTwitterAccounts];
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
        [self listResults];
        
    }];
    [self presentViewController:loginController animated:YES completion:nil];
    
    
}
- (void)listResults {
    
    NSString *username = [FHSTwitterEngine sharedEngine].authenticatedUsername;
  /*  NSMutableDictionary *   dict1 = [[FHSTwitterEngine sharedEngine]listFriendsForUser:username isID:NO withCursor:@"-1"];
    
    //  NSLog(@"====> %@",[dict1 objectForKey:@"users"] );        // Here You get all the data
    NSMutableArray *array=[dict1 objectForKey:@"users"];
    [twitterArray removeAllObjects];
    for(int i=0;i<[array count];i++)
    {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
        [dict setValue:[[array objectAtIndex:i] valueForKey:@"screen_name"] forKey:@"name"];
        [dict setValue:[[array objectAtIndex:i] valueForKey:@"profile_image_url"] forKey:@"image"];
        [dict setValue:[[array objectAtIndex:i] valueForKey:@"id"] forKey:@"id"];
        [twitterArray addObject:dict];
        dict=nil;


     //   NSLog(@"names:%@",[twitterArray objectAtIndex:i]);
        //profile_image_url
        //id
    }
    if(twitterArray.count>0)
    {
        FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
        [frndVC setUserArray:twitterArray];
        [frndVC setSocialId:1];
        [self.navigationController pushViewController:frndVC animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:@"No followers found for this twitter account" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }*/
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                for(ACAccount *t in accounts)
                {
                    if([t.username isEqualToString:username])
                    {
                        twitterAccount = t;
                        break;
                    }
                }
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", username], @"screen_name", @"-1", @"cursor", nil]];
                [twitterInfoRequest setAccount:twitterAccount];
                // Making the request
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Check if we reached the reate limit
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        // Check if there was an error
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        // Check if there is some response data
                        if (responseData) {
                            NSError *error = nil;
                            NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                           // NSLog(@"TWData is %d",[[TWData valueForKey:@"users"] count]);
                            [twitterArray removeAllObjects];
                            NSArray *array =[NSArray arrayWithArray:[TWData valueForKey:@"users"]];
                            for(int i=0;i<[array count];i++)
                            {
                                NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
                                [dict setValue:[[array objectAtIndex:i] valueForKey:@"screen_name"] forKey:@"name"];
                                [dict setValue:[[array objectAtIndex:i] valueForKey:@"profile_image_url"] forKey:@"image"];
                                [dict setValue:[[array objectAtIndex:i] valueForKey:@"id"] forKey:@"id"];
                                [twitterArray addObject:dict];
                                dict=nil;
                                
                              
                            }
                            if(twitterArray.count>0)
                            {
                                FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
                                [frndVC setUserArray:twitterArray];
                                [frndVC setSocialId:1];
                                [frndVC setEventID:self.eventID];

                                [self.navigationController pushViewController:frndVC animated:YES];
                            }
                            else
                            {
                                [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No followers found for this twitter account"] AlertFlag:1 ButtonFlag:1];

                                
                            }

                            
                            
                        }
                    });
                }];
            }
        }
        else
        {
             [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No access granted"] AlertFlag:1 ButtonFlag:1];
        
            NSLog(@"No access granted");
        }
    }];
}
-(void)getFBFrdList
{
//    NSString *query =
//    @"SELECT uid, name, pic_square FROM user WHERE uid IN "
//    @"(SELECT uid2 FROM friend WHERE uid1 = me() )";
//    NSDictionary *queryParam =
//    [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
//    // Make the API request that uses FQL
//    
//    [FBRequestConnection startWithGraphPath:@"/fql"
//                                 parameters:queryParam
//                                 HTTPMethod:@"GET"
//                          completionHandler:^(FBRequestConnection *connection,
//                                              id result,
//                                              NSError *error) {
//                              if (error) {
//                                  NSLog(@"Error: %@", [error localizedDescription]);
//                              } else {
//                                   NSLog(@"Result: %@", result);
//                                  // Get the friend data to display
//                                  // Show the friend details display
//                                  // [self showFriends:friendInfo];
//                                 // [self getFBFrdListFinished:result];
//                              }
//                          }];
}



//use this general method with any parameters you want. All requests will be handled correctly

- (void)makeFBRequestToPath:(NSString *)aPath withParameters:(NSDictionary *)parameters success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    //create array to store results of multiple requests
    NSMutableArray *recievedDataStorage = [NSMutableArray new];
    
    //run requests with array to store results in
    
    [self p_requestFromPath:aPath parameters:parameters storage:recievedDataStorage succes:success failure:failure];
    
    
}


- (void)p_requestFromPath:(NSString *)path parameters:(NSDictionary *)params storage:(NSMutableArray *)friends succes:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    //create requests with needed parameters
    FBSDKGraphRequest *fbRequest = [[FBSDKGraphRequest alloc]initWithGraphPath:path
                                                                    parameters:params
                                                                    HTTPMethod:nil];
    
    //then make a Facebook connection
    FBSDKGraphRequestConnection *connection = [FBSDKGraphRequestConnection new];
    [connection addRequest:fbRequest
         completionHandler:^(FBSDKGraphRequestConnection *connection, NSDictionary*result, NSError *error) {
             
             //if error pass it in a failure block and exit out of method
             if (error){
                 if(failure){
                     failure(error);
                 }
                 return ;
             }
             //add recieved data to array
             [friends addObjectsFromArray:result[@"data"]];
             //then get parameters of link for the next page of data
             NSDictionary *paramsOfNextPage = [FBSDKUtility dictionaryWithQueryString:result[@"paging"][@"next"]];
             if (paramsOfNextPage.allKeys.count > 0){
                 [self p_requestFromPath:path
                              parameters:paramsOfNextPage
                                 storage:friends
                                  succes:success
                                 failure:failure];
                 //just exit out of the method body if next link was found
                 return;
             }
             if (success){
                 success([friends copy]);
             }
         }];
    //do not forget to run connection
    [connection start];
}


-(void)callFriends
{
    
    
    NSString *path = @"/me/friends";
    
    
    NSDictionary *param = @{ @"fields": @"name,picture,gender",@"limit":@5000};
    
    [self makeFBRequestToPath:path withParameters:param success:^(NSArray *result)
     {
         
         NSLog(@"Found friends are:\n%@",result);
         
         
         NSLog(@"fetched user:%@", result);
         
         NSArray *data = [[NSArray alloc]initWithArray:result];
         
         
         NSMutableArray *friendsList = [[NSMutableArray alloc] init];
         for (FBSDKShareOpenGraphObject *friend in data)
         {
             NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
             NSLog(@"friend:%@", friend);
             [dict setValue:[[[friend objectForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"] forKey:@"image"];
             [dict setValue:[friend objectForKey:@"name"] forKey:@"name"];
             [dict setValue:[friend objectForKey:@"id"] forKey:@"id"];
             [friendsList addObject:dict];
             dict=nil;
             
         }
         if(friendsList.count>0)
         {
             [drk hide];
               FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
               [frndVC setUserArray:friendsList];
               [frndVC setSocialId:2];
               [frndVC setEventID:self.eventID];
               [self.navigationController pushViewController:frndVC animated:YES];

         }
         else
         {
             [drk hide];
             
             [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No facebook friends found"] AlertFlag:1 ButtonFlag:1];
             
             
         }
         
         
         
     } failure:^(NSError *error)
     {
         NSLog(@"Oops! Something went wrong(\n%@",error);
         
         
     }];
    


    
}


-(void)callFriend
{
//    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
//   // if (!FBSession.activeSession.isOpen)
//   // {
//     //   NSLog(@"permissions::%@",FBSession.activeSession.permissions);
//        
//        // if the session is closed, then we open it here, and establish a handler for state changes
//        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"user_friends"]
//                                           allowLoginUI:YES
//                                      completionHandler:^(FBSession *session,
//                                                          FBSessionState state,
//                                                          NSError *error) {
//                                          
//                                          if (error)
//                                          {
//                                              [drk hide];
//                                              
//                                              [DELEGATE showalert:self Message:error.localizedDescription AlertFlag:1 ButtonFlag:1];
//                                              
//                                             /* UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                                                  message:error.localizedDescription
//                                                                                                 delegate:nil
//                                                                                        cancelButtonTitle:@"OK"
//                                                                                        otherButtonTitles:nil];
//                                              [alertView show];*/
//                                          }
//                                          else if (session.isOpen)
//                                          {
//                                             // [self showWithStatus:@""];
//                                              FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,picture,gender"];
//                                              
//                                              
//                                              [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                                  NSArray *data = [result objectForKey:@"data"];
//                                                  NSMutableArray *friendsList = [[NSMutableArray alloc] init];
//                                                  for (FBGraphObject<FBGraphUser> *friend in data)
//                                                  {
//                                                      NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
//                                                      NSLog(@"friend:%@", friend);
//                                                      [dict setValue:[[[friend objectForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"] forKey:@"image"];
//                                                      [dict setValue:[friend objectForKey:@"name"] forKey:@"name"];
//                                                      [dict setValue:[friend objectForKey:@"id"] forKey:@"id"];
//                                                      [friendsList addObject:dict];
//                                                      dict=nil;
//                                             
//                                                  }
//                                                  if(friendsList.count>0)
//                                                  {
//                                                      [drk hide];
//                                                      FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
//                                                      [frndVC setUserArray:friendsList];
//                                                      [frndVC setSocialId:2];
//                                                      [frndVC setEventID:self.eventID];
//                                                      [self.navigationController pushViewController:frndVC animated:YES];
//                                                  }
//                                                  else
//                                                  {
//                                                      [drk hide];
//                                                      
//                                                      [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No facebook friends found"] AlertFlag:1 ButtonFlag:1];
//                                                      
//                                                  
//                                                  }
//                                                  
//                                                  
//                                                 
//                                              }];
//                                              
//                                              
//                                          }
//                                      }];
//    //}

}
- (IBAction)fbTapped:(id)sender
{
    
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1702005553392744"];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:Icon_PATH];
    
    // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
    [FBSDKAppInviteDialog showWithContent:content
                                 delegate:self];

   
    
    //[self callFriends];
}

-(void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"%@",results);
    
    
}

-(void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    
    NSLog(@"%@",error);
    
    if(error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Something went wrong!"delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        
    }
    
    
}



- (IBAction)googleTapped:(id)sender
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    
    [[GPPSignIn sharedInstance] authenticate];
    
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error
{
    
    if (!error)
    {
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        
        plusService.retryEnabled = YES;
        
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        GTLQueryPlus *query =
        [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                        collection:kGTLPlusCollectionVisible];
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPeopleFeed *peopleFeed,
                                    NSError *error) {
                    if (error) {
                        GTMLoggerError(@"Error: %@", error);
                    } else {
                        // Get an array of people from GTLPlusPeopleFeed
                        NSArray* peopleList = peopleFeed.items;
                        NSLog(@"peopleList %@ ",peopleList);
                        
                        FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
                        [frndVC setUserArray:peopleList];
                        [frndVC setSocialId:3];
                        [frndVC setEventID:self.eventID];

                        [self.navigationController pushViewController:frndVC animated:YES];
                        
                        /*for(int i=0;i<peopleList.count;i++)
                        {
                            GTLPlusPerson *per =[peopleList objectAtIndex:i];
                            
                            NSLog(@"GoogleID=%@", per.identifier);
                            NSLog(@"Gender=%@", per.image.url);
                            NSLog(@"Gender=%@", per.displayName);


                        }*/
                        
                        /*
                          "GTLPlusPerson 0x7fe718c608b0: {displayName:\"Jagpreet Kaur Ahuja\" url:\"https://plus.google.com/101527755343855740823\" objectType:\"person\" id:\"101527755343855740823\" image:{url} kind:\"plus#person\" etag:\"\"RqKWnRU4WW46-6W3rWhLR9iFZQM/1PnU3fRs0xds6eVcs0dTHcOSwz4\"\"}",
                         */
                        
                    }
                }];
        [drk hide];
    }
    else
    {
        [drk hide];

        [DELEGATE showalert:self Message:error.localizedDescription AlertFlag:1 ButtonFlag:1];
        
      
    }
}

- (IBAction)messageTapped:(id)sender
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self addressBookValidation];
    }
    else
    {
        NSString *emailTitle = [localization localizedStringForKey:@"Amhappy invitation"];
        // Email Content
        
        NSString *messageBody = [localization localizedStringForKey:@"I just found this awesome app that I think you would like!"];
       
        
        MFMailComposeViewController *mf = [[MFMailComposeViewController alloc] init];
        mf.mailComposeDelegate = self;
        [mf setSubject:emailTitle];
        [mf setMessageBody:messageBody isHTML:NO];
        // setToRecipients:toRecipents];
        
        [self presentViewController:mf animated:YES completion:NULL];
    }

}

- (IBAction)addFrndTapped:(id)sender
{
    AppFriendViewControllerViewController *addVC =[[AppFriendViewControllerViewController alloc] initWithNibName:@"AppFriendViewControllerViewController" bundle:nil];
    NSLog(@"event id is %@",self.eventID);
    [addVC setEventID:self.eventID];
    //addVC.eventID =[NSString stringWithFormat:@"%@",self.eventID];
    [self.navigationController pushViewController:addVC animated:YES];
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Mail sent"] AlertFlag:1 ButtonFlag:1];

            break;
        }
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(void)addressBookValidation
{
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
    // ABAddressBookRef addressbook = ABAddressBookCreate();
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook,
                                             ^(bool granted, CFErrorRef error){
                                                 dispatch_semaphore_signal(sema);
                                             });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
        {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                     {
                                                         accessGranted = granted;
                                                         dispatch_semaphore_signal(sema);
                                                     });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
        }
        else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
        {
            NSLog(@"kABAuthorizationStatusAuthorized");
            accessGranted = YES;
        }
        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusDenied)
        {
            NSLog(@"kABAuthorizationStatusDenied");
            accessGranted = NO;
        }
        else if (ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusRestricted){
            
            NSLog(@"kABAuthorizationStatusRestricted");
            
            accessGranted = NO;
        }
        else
        {
            NSLog(@"else");
            accessGranted = YES;
        }
        
        
    }
    else
    {
       // NSLog(@"ABAddressBookRequestAccessWithCompletion is null");
        accessGranted = YES;
    }
    [prefs setBool:accessGranted forKey:@"addressBook"];
    
    if (accessGranted) {
        [self SyncContactData];
    }
    else{
         [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please allow permission from privacy setting to display contact list"] AlertFlag:1 ButtonFlag:1];
        
     
        
    }
    
    [prefs synchronize];
    //    CFRelease(addressbook);
}
- (void) SyncContactData
{
    // ABAddressBookRef addressBook = ABAddressBookCreate();
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook,
                                             ^(bool granted, CFErrorRef error){
                                                 dispatch_semaphore_signal(sema);
                                             });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    CFTypeRef multival;
    
    NSLog(@"%li",nPeople);
    
    
    for( int i = 0 ; i < nPeople ; i++ )
    {
        dicContact = [[NSMutableDictionary alloc] init];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i );
        
        
        
        if(ABRecordCopyValue(ref, kABPersonFirstNameProperty) != nil || [[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonFirstNameProperty)] length] == 0)
            [dicContact setValue:[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonFirstNameProperty)] forKey:@"firstname"];
        else
            [dicContact setValue:@"" forKey:@"firstname"];
        
        if(ABRecordCopyValue(ref, kABPersonLastNameProperty) != nil || [[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonLastNameProperty)] length] == 0)
            [dicContact setValue:[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonLastNameProperty)] forKey:@"lastname"];
        else
            [dicContact setValue:@"" forKey:@"lastname"];
        
        if(ABRecordCopyValue(ref, kABPersonOrganizationProperty) != nil || [[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonOrganizationProperty)] length] == 0)
            [dicContact setValue:[NSString stringWithFormat:@"%@",ABRecordCopyValue(ref, kABPersonOrganizationProperty)] forKey:@"name"];
        else
            [dicContact setValue:[NSString stringWithFormat:@"%@ %@",[dicContact valueForKey:@"firstname"],[dicContact valueForKey:@"lastname"]] forKey:@"name"];
        
        NSData *data1 = (__bridge NSData *) ABPersonCopyImageData(ref);
        
        if(data1 == nil)
            [dicContact setObject:@"" forKey:@"image"];
        else
            [dicContact setObject:data1 forKey:@"image"];
        
        
        multival = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        NSArray *arrayPhone = (__bridge  NSArray *)ABMultiValueCopyArrayOfAllValues(multival);
        if([arrayPhone count] > 0)
            [dicContact setValue:[arrayPhone objectAtIndex:0] forKey:@"telephone"];
        else
            [dicContact setValue:@"" forKey:@"telephone"];
        
        multival = ABRecordCopyValue(ref, kABPersonEmailProperty);
        NSArray *arrayEmail = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(multival);
        if([arrayEmail count])
            [dicContact setValue:[arrayEmail objectAtIndex:0] forKey:@"email"];
        else
            [dicContact setValue:@"" forKey:@"email"];
        [dicContact setValue:@"No" forKey:@"selected"];
        
        if (contactArray==nil) {
            NSLog(@"if");
            
            contactArray=[[NSMutableArray alloc]initWithObjects:dicContact, nil];
            
            
        }else{
            NSLog(@"else");
            
            [contactArray addObject:dicContact];
            
        }
        dicContact =nil;
        
        
    }
    [self sortContactArray];
    CFRelease(addressBook);
    CFRelease(allPeople);
    
}
-(void)sortContactArray
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *sortedArray = [contactArray sortedArrayUsingDescriptors:sortDescriptors];
    
    [contactArray removeAllObjects];
    [contactArray addObjectsFromArray:[NSMutableArray arrayWithArray:sortedArray]];
     NSLog(@"sorted array is %@",contactArray);
    NSArray *array =[[NSArray alloc] initWithArray:[self getContactArray]];
    
    if(array.count>0)
    {
        FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
        [frndVC setUserArray:array];
        [frndVC setEventID:self.eventID];
        [frndVC setSocialId:4];
        [self.navigationController pushViewController:frndVC animated:YES];
    }
    else
    {
        NSString *emailTitle = @"AmHappy";
        // Email Content
        NSString *messageBody = @"I just found this awesome app that I think you would like!";
        
        MFMailComposeViewController *mf = [[MFMailComposeViewController alloc] init];
        mf.mailComposeDelegate = self;
        [mf setSubject:emailTitle];
        [mf setMessageBody:messageBody isHTML:NO];
        // setToRecipients:toRecipents];
        
        [self presentViewController:mf animated:YES completion:NULL];
    }
}
-(NSArray *)getContactArray
{
    NSMutableArray *temp =[[NSMutableArray alloc] init];
    if(contactArray.count>0)
    {
        for(int i=0;i<contactArray.count;i++)
        {
            if([[[contactArray objectAtIndex:i] valueForKey:@"email"] length]>0)
            {
                NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
                [dict setValue:[[contactArray objectAtIndex:i] valueForKey:@"email"] forKey:@"email"];
                [dict setValue:[[contactArray objectAtIndex:i] valueForKey:@"name"] forKey:@"name"];
                [dict setValue:[[contactArray objectAtIndex:i] valueForKey:@"telephone"] forKey:@"telephone"];
                [temp addObject:dict];
               // [dict setValue:[[contactArray objectAtIndex:i] valueForKey:@"image"] forKey:@"image"];


            }
        }
    }
    
    /*
     email = "";
     firstname = "Tony Stark";
     image = "";
     lastname = "";
     name = "Tony Stark ";
     selected = No;
     telephone = "079 2565252";
     */
    return temp;
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

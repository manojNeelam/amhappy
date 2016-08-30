//
//  FindingFriendsViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 02/03/15.
//
//

#import "FindingFriendsViewController.h"
#import "ModelClass.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "UIImageView+WebCache.h"

#import "TYMActivityIndicatorViewViewController.h"


@interface FindingFriendsViewController ()

@end

@implementation FindingFriendsViewController
{
    ModelClass *mc;
    NSMutableArray *friendsArray;
    NSMutableArray *searchArray;
     NSMutableArray *sendingArray;
    BOOL isSearching;
    TYMActivityIndicatorViewViewController *drk;
    
    int inviteTag;
    UIToolbar *mytoolbar1;
    
    

    NSMutableArray *inviteArray;

    int start;
    BOOL isLast;
    
    NSMutableArray *searchFriendsArray;
    NSMutableArray *searchInviteArray;
    
    int searchStart;
    BOOL isLastSearch;
    

    
    //dax
    //----------------------------
    
    NSMutableArray *Arrfriends;   //friendsArray
  //  NSMutableArray *Arrinvite;   //inviteArray
    
    int Taginvite;  //inviteTag
    int startindex;      //start
    BOOL ischeckLast;     //isLast na
    
    NSMutableArray *ArrsearchFriends; //searchFriendsArray
   // NSMutableArray *ArrsearchInvite; //searchInviteArray
    
    int Startsearch;  //searchStart
    BOOL LastSearch; //isLastSearch na
    
    BOOL Searching;  //isSearching
   
    //-----------------------------
    

}
@synthesize lblTitled,txtSearch,tableviewFriends,socialId,userArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //-----------------------------
    
    Arrfriends =[[NSMutableArray alloc] init];
   // Arrinvite =[[NSMutableArray alloc] init];
    Taginvite =-1;
    startindex =0;
    Searching =NO;
    
    ArrsearchFriends =[[NSMutableArray alloc] init];
   // ArrsearchInvite =[[NSMutableArray alloc] init];
    Startsearch =0;
    
    //-----------------------------
    
    
    mc=[[ModelClass alloc] init];
    [mc setDelegate:self];
    friendsArray =[[NSMutableArray alloc] init];
    searchArray =[[NSMutableArray alloc] init];
    sendingArray =[[NSMutableArray alloc] init];
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    
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

    if(self.socialId==1)
    {
        [self.lblTitled setText:[localization localizedStringForKey:@"Facebook Friends"]];
        if(self.userArray.count>0)
        {
            for(int i=0;i<self.userArray.count;i++)
            {
                [sendingArray addObject:[NSString stringWithFormat:@"%@",[[userArray objectAtIndex:i] valueForKey:@"id"]]];
            }
            if(sendingArray.count>0)
            {
                if(DELEGATE.connectedToNetwork)
                {
                    NSError *error;
                    NSData *dateData = [NSJSONSerialization dataWithJSONObject:sendingArray options:NSJSONWritingPrettyPrinted error:&error];
                    NSString *str = [[NSString alloc] initWithData:dateData encoding:NSUTF8StringEncoding];
                    [mc findFriends:[USER_DEFAULTS valueForKey:@"userid"] Type:@"F" Friendids:str Sel:@selector(responseGetFriends:)];
                }
            }
            

        }
    }
    
    if(self.socialId==2)
    {
        
        [self.lblTitled setText:[localization localizedStringForKey:@"Google Plus Friends"]];
        if(self.userArray.count>0)
        {
            for(int i=0;i<self.userArray.count;i++)
            {
                GTLPlusPerson *per =[self.userArray objectAtIndex:i];
                [sendingArray addObject:[NSString stringWithFormat:@"%@",per.identifier]];
                
                /* NSLog(@"GoogleID=%@", per.identifier);
                 NSLog(@"Gender=%@", per.image.url);
                 NSLog(@"Gender=%@", per.displayName);*/
                
            }
            if(sendingArray.count>0)
            {
                if(DELEGATE.connectedToNetwork)
                {
                    NSError *error;
                    NSData *dateData = [NSJSONSerialization dataWithJSONObject:sendingArray options:NSJSONWritingPrettyPrinted error:&error];
                    NSString *str = [[NSString alloc] initWithData:dateData encoding:NSUTF8StringEncoding];
                    [mc findFriends:[USER_DEFAULTS valueForKey:@"userid"] Type:@"G" Friendids:str Sel:@selector(responseGetFriends:)];
                }
            }
        }
    }
    
    else if(self.socialId==3)
    {
        
        [self.lblTitled setText:[localization localizedStringForKey:@"Twitter Friends"]];

        if(self.userArray.count>0)
        {
            for(int i=0;i<self.userArray.count;i++)
            {
                [sendingArray addObject:[NSString stringWithFormat:@"%@",[[userArray objectAtIndex:i] valueForKey:@"id"]]];
            }
            if(sendingArray.count>0)
            {
                if(DELEGATE.connectedToNetwork)
                {
                    NSError *error;
                    NSData *dateData = [NSJSONSerialization dataWithJSONObject:sendingArray options:NSJSONWritingPrettyPrinted error:&error];
                    NSString *str = [[NSString alloc] initWithData:dateData encoding:NSUTF8StringEncoding];
                    [mc findFriends:[USER_DEFAULTS valueForKey:@"userid"] Type:@"T" Friendids:str Sel:@selector(responseGetFriends:)];
                }
            }
        }
    }
    
    else if(self.socialId==4)
    {
        
        [self.lblTitled setText:[localization localizedStringForKey:@"Contacts Friends"]];

        if(self.userArray.count>0)
        {
            for(int i=0;i<self.userArray.count;i++)
            {
                [sendingArray addObject:[NSString stringWithFormat:@"%@",[[userArray objectAtIndex:i] valueForKey:@"email"]]];
            }
            if(sendingArray.count>0)
            {
                if(DELEGATE.connectedToNetwork)
                {
                    NSError *error;
                    NSData *dateData = [NSJSONSerialization dataWithJSONObject:sendingArray options:NSJSONWritingPrettyPrinted error:&error];
                    NSString *str = [[NSString alloc] initWithData:dateData encoding:NSUTF8StringEncoding];
                    [mc findFriends:[USER_DEFAULTS valueForKey:@"userid"] Type:@"E" Friendids:str Sel:@selector(responseGetFriends:)];
                }
            }
        }
    }
    else if(self.socialId==5)
    {
        [self.lblTitled setText:[localization localizedStringForKey:@"AmHappy Users"]];

        [self callApi];
        
        //dax
       // -> comment this code
        
//        if(DELEGATE.connectedToNetwork)
//        {
//            
//            // [mc findFriends:[USER_DEFAULTS valueForKey:@"userid"] Type:@"A" Friendids:@"" Sel:@selector(responseGetFriends:)];
//        }
    }

}
-(void)callApi
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc DisplayUser:[USER_DEFAULTS valueForKey:@"userid"] Keyword:@"" Start:[NSString stringWithFormat:@"%d",startindex] Limit:LimitComment Sel:@selector(responseGetUsers:)];
    }
}
-(void)responseGetUsers:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [Arrfriends addObjectsFromArray:[results valueForKey:@"User"]];
        
        [self.tableviewFriends reloadData];
        
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            ischeckLast =YES;
        }
        else
        {
            ischeckLast =NO;
        }
    }
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGPoint targetPoint = *targetContentOffset;
    CGPoint currentPoint = scrollView.contentOffset;
    
    if (targetPoint.y > currentPoint.y) {
        NSLog(@"up");
    }
    else
    {
        if(Searching)
        {
            if(!LastSearch)
            {
                Startsearch=Startsearch+10;
                [self callSearchApi];
            }
        }
        else
        {
            if(!ischeckLast)
            {
                startindex=startindex+10;
                [self callApi];
            }
        }
        
        NSLog(@"down");
    }
}
-(void)callSearchApi
{
    if(DELEGATE.connectedToNetwork)
    {
      //  [mc getAppUser:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",searchStart] Limit:LimitComment Eventid:[NSString stringWithFormat:@"%@",self.eventID] Keyword:[self.txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] Sel:@selector(responseGetSearchedUsers:)];
        
        [mc DisplayUser:[USER_DEFAULTS valueForKey:@"userid"] Keyword:[self.txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] Start:[NSString stringWithFormat:@"%d",searchStart] Limit:LimitComment Sel:@selector(responseGetSearchedUsers:)];
    }
}
-(void)responseGetSearchedUsers:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(Startsearch==0)
        {
            [ArrsearchFriends removeAllObjects];
            
            
        }
        [ArrsearchFriends addObjectsFromArray:[results valueForKey:@"User"]];
  
        [self.tableviewFriends reloadData];
        
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            LastSearch =YES;
        }
        else
        {
            LastSearch =NO;
        }
    }
}


//-------------- * ---------- * -------------- * -------------- * -------------

-(void)donePressed
{
    [self.view endEditing:YES];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
}
-(void)localize
{
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];
    
}
-(void)responseGetFriends:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        [self convertArray:[results valueForKey:@"User"]];

        if(self.socialId==3)
        {
            [self getSocialArray3:[results valueForKey:@"Social"]];
            
        }
        else if(self.socialId==2)
        {
            [self getSocialArray2:[results valueForKey:@"Social"]];
            
        }
        else if(self.socialId==4)
        {
            [self getSocialArray4:[results valueForKey:@"Social"]];
            
        }
        [self.tableviewFriends reloadData];
        
    }
    else
    {
        
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

      
    }
}
-(void)convertArray:(NSArray *)array
{
    if(array.count>0)
    {
        for(int i=0;i<array.count;i++)
        {
            
                NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[array objectAtIndex:i]];
                [dict setValue:@"Y" forKey:@"user"];
                [friendsArray addObject:dict];
                dict =nil;
                
           
        }
       
    }

}
-(void)getSocialArray1:(NSArray *)array
{
    if(array.count>0)
    {
        for(int i=0;i<array.count;i++)
        {
            for(int j=0;j<self.userArray.count;j++)
            {
                if([[NSString stringWithFormat:@"%@",[[array objectAtIndex:i] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[[self.userArray objectAtIndex:j] valueForKey:@"id"]]])
                {
                    [friendsArray addObject:[self.userArray objectAtIndex:j]];
                }
            }
        }
        if(friendsArray.count==0)
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"None of user found from your social link who are not using Amhappy"] AlertFlag:1 ButtonFlag:1];

        }
    }
    
}
-(void)getSocialArray3:(NSArray *)array
{
    if(array.count>0)
    {
        for(int i=0;i<array.count;i++)
        {
            for(int j=0;j<self.userArray.count;j++)
            {
                if([[NSString stringWithFormat:@"%@",[[array objectAtIndex:i] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[[self.userArray objectAtIndex:j] valueForKey:@"id"]]])
                {
                    [friendsArray addObject:[self.userArray objectAtIndex:j]];
                }
            }
        }
     
    }
    
}
-(void)getSocialArray2:(NSArray *)array
{
    if(array.count>0)
    {
        for(int i=0;i<array.count;i++)
        {
            for(int j=0;j<self.userArray.count;j++)
            {
                GTLPlusPerson *per =[self.userArray objectAtIndex:j];
                if([[NSString stringWithFormat:@"%@",[[array objectAtIndex:i] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",per.identifier]])
                {
                    NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
                    [dict setValue:per.identifier forKey:@"id"];
                    [dict setValue:per.displayName forKey:@"name"];
                    [dict setValue:@"N" forKey:@"user"];


                    [friendsArray addObject:dict];
                    dict =nil;
                    
                }
            }
        }
        
    }
    
}
-(void)getSocialArray4:(NSArray *)array
{
    if(array.count>0)
    {
        for(int i=0;i<array.count;i++)
        {
            for(int j=0;j<self.userArray.count;j++)
            {
                if([[NSString stringWithFormat:@"%@",[[array objectAtIndex:i] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[[self.userArray objectAtIndex:j] valueForKey:@"email"]]])
                {
                    [friendsArray addObject:[self.userArray objectAtIndex:j]];
                    
                }
            }
        }
     
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.socialId == 5) {
        
        if(Searching)
        {
            return ArrsearchFriends.count;
        }
        else
        {
            return Arrfriends.count;
            
        }
    }
    else
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
            if(friendsArray.count>0)
            {
                return friendsArray.count;
            }
            else return 0;
        }
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.socialId==5)
    {
        FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:nil];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil];
            cell=[nib objectAtIndex:0] ;
        }
        cell.delegate=self;
        cell.imgUser.layer.masksToBounds = YES;
        cell.imgUser.layer.cornerRadius = 25.0;
        
        cell.btnAdd.tag=indexPath.row;
        cell.btnAdd.superview.tag =indexPath.section;
        
        cell.btnInvite.tag=indexPath.row;
        cell.btnInvite.superview.tag =indexPath.section;
        
        
       
        [cell.btnInvite setHidden:YES];
        [cell.btnAccept setHidden:YES];

        [cell.btnAdd setHidden:NO];
        
        
        //-------*--------*--------*--------***
        
        
        
        
        
        if(Searching)
        {

                if([[[ArrsearchFriends objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
                {
                    [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[ArrsearchFriends objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                }
                cell.lblName.text =[[ArrsearchFriends objectAtIndex:indexPath.row] valueForKey:@"name"];
              //  [cell.btnInvite setHidden:YES];
              //  [cell.btnAdd setHidden:NO];
                
            
        }
        else
        {

                if([[[Arrfriends objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
                {
                    [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[Arrfriends objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                }
                cell.lblName.text =[[Arrfriends objectAtIndex:indexPath.row] valueForKey:@"name"];
              //  [cell.btnInvite setHidden:YES];
              //  [cell.btnAdd setHidden:NO];
            
        }


        
        
//        if(isSearching)
//        {
//            if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
//            {
//                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
//                
//            }
//            cell.lblName.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"];
//
//        }
//        else
//        {
//            if([[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
//            {
//                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
//                
//            }
//            cell.lblName.text =[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
//
//        }
        
            
       
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
        
        
        [cell.textLabel setFont:FONT_Regular(15.0)];
        [cell.textLabel setNumberOfLines:0];
        [cell.textLabel setMinimumScaleFactor:0.5];
        
        if(isSearching)
        {
            cell.textLabel.text = [[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            
        }
        else
        {
            cell.textLabel.text = [[friendsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            
        }
        
        UIButton *button = [[UIButton alloc] init];
        [button addTarget:self
                   action:@selector(inviteFriend:)
         forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"addFrnd.png"] forState:UIControlStateNormal];
        button.frame = CGRectMake(self.view.frame.size.width-80, 10.0, 80.0, 30.0);
        button.tag =indexPath.row;
        
        [cell addSubview:button];
        
        
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        return cell;
    }
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*  OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
     if(isSearching)
     {
     [otherVC setUserId:[[guestArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
     
     }
     else
     {
     [otherVC setUserId:[[guestArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
     }
     [self.navigationController pushViewController:otherVC animated:YES];*/
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.socialId==5)
    {
        return 55;
    }
    else
    {
        return 44;
    }
    
}


-(void)shareData:(UIButton *)sender
{
    
            if(self.socialId==3)
            {
                //http://stackoverflow.com/questions/22433436/ios-is-there-any-way-to-post-facebook-and-twitter-in-background
              
                
                if ([TWTweetComposeViewController canSendTweet])
                {
                    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
                    
                    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
                    
                    // Create an account type that ensures Twitter accounts are retrieved.
                    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                    
                    // Request access from the user to use their Twitter accounts.
                    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
                        [drk hide];
                        if(granted) {
                            // Get the list of Twitter accounts.
                            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                            
                            // For the sake of brevity, we'll assume there is only one Twitter account present.
                            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
                            if ([accountsArray count] > 0)
                            {
                                // Grab the initial Twitter account to tweet from.
                                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                                // how to call https://api.twitter.com/1.1/direct_messages/new.json? in objective c
                                NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
                                
                                if(isSearching)
                                {
                                    [dict setValue:[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:sender.tag] valueForKey:@"id"]] forKey:@"user_id"];
                                    [dict setValue:[[searchArray objectAtIndex:sender.tag] valueForKey:@"name"] forKey:@"screen_name"];
                                    [dict setValue:@"" forKey:@"text"];
                                }
                                else
                                {
                                    [dict setValue:[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:sender.tag] valueForKey:@"id"]] forKey:@"user_id"];
                                    [dict setValue:[[friendsArray objectAtIndex:sender.tag] valueForKey:@"name"] forKey:@"screen_name"];
                                    
                                    [dict setValue:@"Hi, I am using Amhappy , a new mobile application that lets you create events and meetups with friends, share photos and comments.I find it very interesting and I encourage to you to install it.Amhappy is available for Android and iPhone. Download it from http://www.amhappy.es and check how easy it is to meet friends" forKey:@"text"];
                                }
                                
                                
                                
                                
                                
                                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/direct_messages/new.json"];
                                TWRequest *req = [[TWRequest alloc] initWithURL:url
                                                                     parameters:dict
                                                                  requestMethod:TWRequestMethodPOST];
                                
                                // Important: attach the user's Twitter ACAccount object to the request
                                req.account = twitterAccount;
                                
                                [req performRequestWithHandler:^(NSData *responseData,
                                                                 NSHTTPURLResponse *urlResponse,
                                                                 NSError *error)
                                 {
                                     [drk hide];
                                     // If there was an error making the request, display a message to the user
                                     if(error != nil) {
                                         [drk hide];
                                         NSLog(@"error is %@",error.localizedDescription);
                                         
                                     }
                                     
                                     // Parse the JSON response
                                     NSError *jsonError = nil;
                                     NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                          options:0
                                                                                            error:&jsonError];
                                    
                                     
                                     if(resp.count>1)
                                     {
                                         [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Message sent successfully"] AlertFlag:1 ButtonFlag:1];
                                      
                                     }
                                     else
                                     {
                                         [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Already sent"] AlertFlag:1 ButtonFlag:1];
                                         
                                        
                                     }
                                     
                                     if(jsonError != nil)
                                     {
                                         [drk hide];
                                         
                                         return;
                                     }
                                     
                                     
                                     
                                     
                                 }];
                                
                                
                            }
                        }
                        else
                        {
                            NSLog(@"request not granted");
                        }
                    }];
                }
                
            }
            if(self.socialId==2)
            {
                 [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
                id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
                
                [shareBuilder setPrefillText:@"I just found this awesome app that I think you would like!"];
                
                [shareBuilder setURLToShare:[NSURL URLWithString:@"www.apple.com"]];
                NSString *per;
                if(isSearching)
                {
                    per =[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:sender.tag] valueForKey:@"id"]];
                }
                else
                {
                    per =[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:sender.tag] valueForKey:@"id"]];
                }
                
                
                NSArray *array =[NSArray arrayWithObject:per];
                
                [shareBuilder setPreselectedPeopleIDs:array];
                [drk hide];
                
                [shareBuilder open];
            }
            if(self.socialId==4)
            {
                
                NSString *emailTitle = [localization localizedStringForKey:@"Amhappy invitation"];
                // Email Content
                
                NSString *messageBody = [localization localizedStringForKey:@"I just found this awesome app that I think you would like!"];
                // To address
                NSArray *toRecipents;
                if(isSearching)
                {
                    toRecipents= [NSArray arrayWithObject:[[searchArray objectAtIndex:sender.tag] valueForKey:@"email"]];
                }
                else
                {
                    toRecipents= [NSArray arrayWithObject:[[friendsArray objectAtIndex:sender.tag] valueForKey:@"email"]];
                }
                
                MFMailComposeViewController *mf = [[MFMailComposeViewController alloc] init];
                mf.mailComposeDelegate = self;
                [mf setSubject:emailTitle];
                [mf setMessageBody:messageBody isHTML:NO];
                [mf setToRecipients:toRecipents];
                
                
                //*********** attach HTML File Here
                
                
                
                
                [self presentViewController:mf animated:YES completion:NULL];
                
            }
        
        
    
}

-(void)accerptTapped:(id)sender
{
}
-(void)addTapped:(UIButton *)sender
{
    if(DELEGATE.connectedToNetwork)
    {
        
        if(self.socialId == 5)
        {
            Taginvite =(int)[sender tag];
            if(DELEGATE.connectedToNetwork)
            {
                if(Searching)
                {
                    [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[ArrsearchFriends objectAtIndex:sender.tag] valueForKey:@"id"] Sel:@selector(responseSentRequest:)];
                }
                else
                {
                    [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[Arrfriends objectAtIndex:sender.tag] valueForKey:@"id"] Sel:@selector(responseSentRequest:)];
                }
                
            }
        }
        else
        {
            inviteTag =(int)[sender tag];
            if(DELEGATE.connectedToNetwork)
            {
                if(isSearching)
                {
                    if([[[searchArray objectAtIndex:sender.tag] valueForKey:@"user"] isEqualToString:@"Y"])
                    {
                        [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[searchArray objectAtIndex:sender.tag] valueForKey:@"id"] Sel:@selector(responseSentRequest:)];
                    }
                    else
                    {
                        [self shareData:sender];
                    }
                }
                else
                {
                    if([[[friendsArray objectAtIndex:sender.tag] valueForKey:@"user"] isEqualToString:@"Y"])
                    {
                        [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[friendsArray objectAtIndex:sender.tag] valueForKey:@"id"] Sel:@selector(responseSentRequest:)];
                    }
                    else
                    {
                        [self shareData:sender];
                    }
                }
                
                
                
                
            }
        }
        
        

    }
}
-(void)inviteTapped:(UIButton *)sender
{
}

-(void)inviteFriend:(UIButton *)sender
{
    
    inviteTag =(int)[sender tag];
    if(DELEGATE.connectedToNetwork)
    {
        if(isSearching)
        {
            if([[[searchArray objectAtIndex:sender.tag] valueForKey:@"user"] isEqualToString:@"Y"])
            {
                 [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[searchArray objectAtIndex:sender.tag] valueForKey:@"id"] Sel:@selector(responseSentRequest:)];
            }
            else
            {
                [self shareData:sender];
            }
        }
        else
        {
            if([[[friendsArray objectAtIndex:sender.tag] valueForKey:@"user"] isEqualToString:@"Y"])
            {
                [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[friendsArray objectAtIndex:sender.tag] valueForKey:@"id"] Sel:@selector(responseSentRequest:)];
            }
            else
            {
                [self shareData:sender];
            }
        }
        
      
        
        
    }
   
    
    
   
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
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(void)deleteObject
{
    NSString *frndID =[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:inviteTag] valueForKey:@"id"]];
    for(int i=0;i<friendsArray.count;i++)
    {
        if([[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:i] valueForKey:@"id"]] isEqualToString:frndID])
        {
            [friendsArray removeObjectAtIndex:i];
            break;
        }
    }
}
-(void)responseSentRequest:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(self.socialId == 5)
        {
            
            if(Searching)
            {
                [self deleteFriendObject];
                [ArrsearchFriends removeObjectAtIndex:Taginvite];
            }
            else
            {
                [Arrfriends removeObjectAtIndex:Taginvite];
            }
            [self.tableviewFriends reloadData];
            
            Taginvite =-1;
            
        }
        else
        {
            if(isSearching)
            {
                [self deleteObject];
                [searchArray removeObjectAtIndex:inviteTag];
            }
            else
            {
                [friendsArray removeObjectAtIndex:inviteTag];
                
            }
            [self.tableviewFriends reloadData];
            inviteTag =-1;
        }

    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
      
    }
    
}

//dax
//-------*--------*------------*---------*---------------*---------

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    //isSearching = YES;
}
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{

    
    
    if (self.socialId==5) {
       
        Searching = YES;
        
        if([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length%3==0)
        {
            [self callSearchApi];
        }
    }
    else
    {
        isSearching = YES;
        [self filterListForSearchText:searchText];
    }
    

}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (self.socialId==5) {
        
        if([[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
        {
            Searching =NO;
            LastSearch =NO;
            Startsearch =0;
            [ArrsearchFriends removeAllObjects];
            [self.tableviewFriends reloadData];
            
        }
    }
    else
    {
        if([[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
        {
            isSearching =NO;
            [self.tableviewFriends reloadData];
        }
    }
    

}


//-------*--------*------------*---------*---------------*---------


- (void)filterListForSearchText:(NSString *)searchText
{
    [searchArray removeAllObjects];
    
    if(friendsArray.count>0)
    {
        for(int i=0;i<friendsArray.count;i++)
        {
            NSRange nameRange;

               nameRange = [[[friendsArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
               
            
            if (nameRange.location != NSNotFound) {
                [searchArray addObject:[friendsArray objectAtIndex:i]];
            }
           
            
        }
    }
    [self.tableviewFriends reloadData];
    
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

//dax
//--------*---------*-----------*-------------*---------------
-(void)deleteFriendObject
{
    NSString *frndID =[NSString stringWithFormat:@"%@",[[ArrsearchFriends objectAtIndex:Taginvite] valueForKey:@"id"]];
    for(int i=0;i<Arrfriends.count;i++)
    {
        if([[NSString stringWithFormat:@"%@",[[Arrfriends objectAtIndex:i] valueForKey:@"id"]] isEqualToString:frndID])
        {
            [Arrfriends removeObjectAtIndex:i];
            break;
        }
    }
}

//-(void)deleteInviteObject
//{
//    NSString *frndID =[NSString stringWithFormat:@"%@",[[searchInviteArray objectAtIndex:Taginvite] valueForKey:@"id"]];
//    for(int i=0;i<inviteArray.count;i++)
//    {
//        if([[NSString stringWithFormat:@"%@",[[inviteArray objectAtIndex:i] valueForKey:@"id"]] isEqualToString:frndID])
//        {
//            [inviteArray removeObjectAtIndex:i];
//            break;
//        }
//    }
//}
//-(void)inviteTapped:(UIButton *)sender
//{
//    Taginvite =(int)[sender tag];
//    if(DELEGATE.connectedToNetwork)
//    {
//        NSLog(@"event id is %@",self.eventID);
//        if(Searching)
//        {
//            [mc inviteFriendtoEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Friendids:[[searchInviteArray objectAtIndex:sender.tag] valueForKey:@"id"] Type:@"F" Sel:@selector(responseSentinvitation:)];
//        }
//        else
//        {
//            [mc inviteFriendtoEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Friendids:[[inviteArray objectAtIndex:sender.tag] valueForKey:@"id"] Type:@"F" Sel:@selector(responseSentinvitation:)];
//        }
//        
//    }
//}
//-(void)responseSentinvitation:(NSDictionary *)results
//{
//    NSLog(@"result is %@",results);
//    
//    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
//    {
//        if(isSearching)
//        {
//            [self deleteInviteObject];
//            [searchInviteArray removeObjectAtIndex:inviteTag];
//        }
//        else
//        {
//            [inviteArray removeObjectAtIndex:inviteTag];
//            
//        }
//        
//        [self.tableview reloadData];
//        inviteTag =-1;
//        
//    }
//    else
//    {
//        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
//        
//    }
//}
//- (IBAction)backTapped:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

//-(void)ok1BtnTapped:(id)sender
//{
//    // NSLog(@"ok1BtnTapped");
//    [[self.view viewWithTag:123] removeFromSuperview];
//    
//}
//-(void)ok2BtnTapped:(id)sender
//{
//    // NSLog(@"ok2BtnTapped");
//    [[self.view viewWithTag:123] removeFromSuperview];
//    
//}
//-(void)cancelBtnTapped:(id)sender
//{
//    //NSLog(@"cancelBtnTapped");
//    [[self.view viewWithTag:123] removeFromSuperview];
//    
//}
//- (IBAction)groupTapped:(id)sender
//{
//    InviteGroupViewController *inviteGroupVC =[[InviteGroupViewController alloc] initWithNibName:@"InviteGroupViewController" bundle:nil];
//    inviteGroupVC.eventID =[NSString stringWithFormat:@"%@",self.eventID];
//    [self.navigationController pushViewController:inviteGroupVC animated:YES];
//}




@end

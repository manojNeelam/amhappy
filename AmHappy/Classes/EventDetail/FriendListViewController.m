//
//  FriendListViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 20/02/15.
//
//

#import "FriendListViewController.h"
#import "ModelClass.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "UIImageView+WebCache.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TYMActivityIndicatorViewViewController.h"
#import "Toast+UIView.h"
#import "Base64.h"




@interface FriendListViewController ()

@end

@implementation FriendListViewController
{
    ModelClass *mc;
    NSMutableArray *friendsArray;
    NSMutableArray *socialArray;
    NSMutableArray *appUserArray;

    NSMutableArray *sendingArray;
    TYMActivityIndicatorViewViewController *drk;
    
    BOOL isSearching;
    NSMutableArray *searchSocialArray;
    NSMutableArray *searchAppuserArray;

    
    UIToolbar *mytoolbar1;
    
    int friendTag;


}
@synthesize lblTitle,tableFriends,userArray,eventID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSLog(@"%@",userArray);
    
    mc=[[ModelClass alloc] init];
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    [mc setDelegate:self];
    friendsArray =[[NSMutableArray alloc] init];
    socialArray =[[NSMutableArray alloc] init];
    appUserArray =[[NSMutableArray alloc] init];
    searchSocialArray =[[NSMutableArray alloc] init];
    searchAppuserArray =[[NSMutableArray alloc] init];
    
    friendTag =-1;

    sendingArray =[[NSMutableArray alloc] init];
    
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

    
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:TwitteAppKEY andSecret:TwitteAppSecretId];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
    if(self.socialId==3)
    {
        [self.lblTitle setText:[localization localizedStringForKey:@"Google Plus Friends"]];

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
    
   else if(self.socialId==1)
    {
        [self.lblTitle setText:[localization localizedStringForKey:@"Twitter Friends"]];

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
   else if(self.socialId==2)
   {
       [self.lblTitle setText:[localization localizedStringForKey:@"Facebook Friends"]];

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
    
   else if(self.socialId==4)
   {
       [self.lblTitle setText:[localization localizedStringForKey:@"Contacts Friends"]];

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
                   //NSLog(@"date str is %@",dateAsString);
                   [mc findFriends:[USER_DEFAULTS valueForKey:@"userid"] Type:@"E" Friendids:str Sel:@selector(responseGetFriends:)];
               }
           }
       }
   }
    
   
}
-(void)donePressed
{
    [self.view endEditing:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
   // [self localize];
}
-(void)localize
{
   // [self.lblTitle setText:[localization localizedStringForKey:@"Friends"]];
}
-(void)responseGetFriends:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        /*
         "friend_id" = 101144018;
         id = "";
         "is_exist" = N;
         "is_friend" = N;
         */
        [friendsArray addObjectsFromArray:[results valueForKey:@"Friend"]];
        [appUserArray addObjectsFromArray:[results valueForKey:@"User"]];
        //[socialArray addObjectsFromArray:[results valueForKey:@"Social"]];
        NSLog(@"social count is %d",(int)[[results valueForKey:@"Social"] count]);
        if(self.socialId==1)
        {
            [self getSocialArray1:[results valueForKey:@"Social"]];

        }
        if(self.socialId==2)
        {
           // [socialArray addObjectsFromArray:self.userArray];
        }
        else if(self.socialId==3)
        {
            [self getSocialArray3:[results valueForKey:@"Social"]];
        }
        else if(self.socialId==4)
        {
            [self getSocialArray4:[results valueForKey:@"Social"]];
        }
        [self.tableFriends reloadData];

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
                if([[NSString stringWithFormat:@"%@",[[array objectAtIndex:i] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[[self.userArray objectAtIndex:j] valueForKey:@"id"]]])
                {
                    [socialArray addObject:[self.userArray objectAtIndex:j]];
                    
                }
            }
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
                    [socialArray addObject:[self.userArray objectAtIndex:j]];

                }
            }
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
                GTLPlusPerson *per =[self.userArray objectAtIndex:j];
                
                if([[NSString stringWithFormat:@"%@",[[array objectAtIndex:i] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",per.identifier]])
                {
                    [socialArray addObject:[self.userArray objectAtIndex:j]];
                    
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
                    [socialArray addObject:[self.userArray objectAtIndex:j]];
                    
                }
            }
        }
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self.tableFriends reloadData];
    }
}
- (void)filterListForSearchText:(NSString *)searchText
{
    [searchSocialArray removeAllObjects];
    [searchAppuserArray removeAllObjects];

    
    if(socialArray.count>0)
    {
        for(int i=0;i<socialArray.count;i++)
        {
            NSRange nameRange = [[[socialArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound) {
                [searchSocialArray addObject:[socialArray objectAtIndex:i]];
            }
        }
    }
    
    if(appUserArray.count>0)
    {
        for(int i=0;i<appUserArray.count;i++)
        {
            NSRange nameRange = [[[appUserArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound) {
                [searchAppuserArray addObject:[appUserArray objectAtIndex:i]];
            }
        }
    }
    
    
    [self.tableFriends reloadData];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 50)];
    UILabel *title =[[UILabel alloc] init];
    [title setFrame:CGRectMake(0,0,self.view.frame.size.width, 50)];
    
    
    if (section==0)
    {
        [title setText:[localization localizedStringForKey:@"Invite social friends to AmHappy"]];
       // [title setText:@"Invite social friends to AmHappy"];
    }
    else if (section==1)
    {
        [title setText:[localization localizedStringForKey:@"Add friends to AmHappy"]];

       // [title setText:@"Add friends to AmHappy"];
    }
    [headerView setBackgroundColor:[UIColor colorWithRed:(229/255.f) green:(229/255.f) blue:(231/255.f) alpha:1.0f]];
    [title setTextColor:[UIColor colorWithRed:(228/255.f) green:(123/255.f) blue:(0/255.f) alpha:1.0f]];
    [title setTextAlignment:NSTextAlignmentCenter];
    
    [headerView addSubview:title];
    
    return headerView;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearching)
    {
        if (section==0)
        {
            return searchSocialArray.count;
        }
        else if (section==1)
        {
            return searchAppuserArray.count;
        }
        else return 0;
    }
    else
    {
        if (section==0)
        {
            return socialArray.count;
        }
        else if (section==1)
        {
            return appUserArray.count;
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
        cell.delegate=self;
        cell.imgUser.layer.masksToBounds = YES;
        cell.imgUser.layer.cornerRadius = 25.0;
    
        cell.btnAdd.tag=indexPath.row;
        cell.btnAdd.superview.tag =indexPath.section;
    
        cell.btnInvite.tag=indexPath.row;
        cell.btnInvite.superview.tag =indexPath.section;
    
    
        [cell.btnAccept setTitle:[localization localizedStringForKey:@"Accept"] forState:UIControlStateNormal];
        [cell.btnInvite setTitle:[localization localizedStringForKey:@"Invite"] forState:UIControlStateNormal];


    
      if(indexPath.section==0)
        {
            [cell.btnInvite setHidden:NO];
            [cell.btnAdd setHidden:YES];
            if(self.socialId==1)
            {
                if(isSearching)
                {
                    cell.lblName.text =[[searchSocialArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                    if([[[searchSocialArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
                    {
                        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchSocialArray objectAtIndex:indexPath.row] valueForKey:@"image"]]];
                    }
                }
                else
                {
                    cell.lblName.text =[[socialArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                    
                    if([[[socialArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
                    {
                        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[socialArray objectAtIndex:indexPath.row] valueForKey:@"image"]]];
                    }
                }
                
                
            }
            if(self.socialId==2)
            {
                if(isSearching)
                {
                    cell.lblName.text =[[searchSocialArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                    if([[[searchSocialArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
                    {
                        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchSocialArray objectAtIndex:indexPath.row] valueForKey:@"image"]]];
                    }
                }
                else
                {
                    cell.lblName.text =[[socialArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                    if([[[socialArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
                    {
                        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[socialArray objectAtIndex:indexPath.row] valueForKey:@"image"]]];
                    }
                }
                
                
            }
            if(self.socialId==3)
            {
                GTLPlusPerson *per;
                if(isSearching)
                {
                    per =[searchSocialArray objectAtIndex:indexPath.row];
                }
                else
                {
                    per =[socialArray objectAtIndex:indexPath.row];
                }
                
                
                
                /* NSLog(@"GoogleID=%@", per.identifier);
                 NSLog(@"Gender=%@", per.image.url);
                 NSLog(@"Gender=%@", per.displayName);*/
                cell.lblName.text =per.displayName;
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:per.image.url]];
                per =nil;
            }
            if(self.socialId==4)
            {
                if(isSearching)
                {
                    cell.lblName.text =[[searchSocialArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                    if([[[searchSocialArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
                    {
                        cell.imgUser.image =(UIImage *)[[searchSocialArray objectAtIndex:indexPath.row] valueForKey:@"image"];
                    }
                }
                else
                {
                    cell.lblName.text =[[socialArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                    if([[[socialArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
                    {
                        cell.imgUser.image =(UIImage *)[[socialArray objectAtIndex:indexPath.row] valueForKey:@"image"];
                    }
                }
                
                
            }
            
        }
        else
        {
            [cell.btnInvite setHidden:YES];
            [cell.btnAdd setHidden:NO];
            if(isSearching)
            {
                cell.lblName.text =[[searchAppuserArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                if([[[searchAppuserArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
                {
                    [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchAppuserArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                }
            }
            else
            {
                cell.lblName.text =[[appUserArray objectAtIndex:indexPath.row] valueForKey:@"name"];
                if([[[appUserArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
                {
                    [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[appUserArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
                }
            }
            
        }
    
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
  
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)accerptTapped:(id)sender
{
}
-(void)addTapped:(UIButton *)sender
{
    friendTag =(int)[sender tag];
    if(DELEGATE.connectedToNetwork)
    {
        if(isSearching)
        {
            [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[searchAppuserArray objectAtIndex:sender.tag] valueForKey:@"id"] Sel:@selector(responseSentRequest:)];
        }
        else
        {
            [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[appUserArray objectAtIndex:sender.tag] valueForKey:@"id"] Sel:@selector(responseSentRequest:)];
        }
        
    }
}
-(void)deleteFriendsObject
{
    NSString *frndID =[NSString stringWithFormat:@"%@",[[searchAppuserArray objectAtIndex:friendTag] valueForKey:@"id"]];
    for(int i=0;i<appUserArray.count;i++)
    {
        if([[NSString stringWithFormat:@"%@",[[appUserArray objectAtIndex:i] valueForKey:@"id"]] isEqualToString:frndID])
        {
            [appUserArray removeObjectAtIndex:i];
            break;
        }
    }
}
-(void)responseSentRequest:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(isSearching)
        {
            [self deleteFriendsObject];
            [searchAppuserArray removeObjectAtIndex:friendTag];
        }
        else
        {
            [appUserArray removeObjectAtIndex:friendTag];
        }
        [self.tableFriends reloadData];
        friendTag =-1;
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
   
    
}
-(void)inviteTapped:(UIButton *)sender
{
   
    
    
    
   /* NSString * username = [FHSTwitterEngine sharedEngine].authenticatedUsername;

    NSMutableDictionary *   dict1 = [[FHSTwitterEngine sharedEngine]listFriendsForUser:username isID:NO withCursor:@"-1"];
    
    NSLog(@"====> %@",[dict1 objectForKey:@"users"] );        // Here You get all the data
    NSMutableArray *array=[dict1 objectForKey:@"users"];
    for(int i=0;i<[array count];i++)
    {
        NSLog(@"names:%@",[[array objectAtIndex:i]objectForKey:@"name"]);
        
    }*/
    
    //https://developers.google.com/+/mobile/ios/share/prefill
    if(sender.superview.tag==0)
    {
        if(self.socialId==1)
        {
            //http://stackoverflow.com/questions/22433436/ios-is-there-any-way-to-post-facebook-and-twitter-in-background
          
            
           if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                ;
                /*TWTweetComposeViewController *controller = [[TWTweetComposeViewController alloc] init];
                [controller setInitialText:[NSString stringWithFormat:@"d %@ Something I want to tweet",[[socialArray objectAtIndex:sender.tag] valueForKey:@"name"]]];
                [self presentViewController:controller animated:NO completion:nil];*/
                
                
              
                    
                    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                    
                    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
                        if (result == SLComposeViewControllerResultCancelled) {
                            
                            NSLog(@"Cancelled");
                            
                        } else
                            
                        {
                            NSLog(@"Done");
                            [self.view makeToast:[localization localizedStringForKey:@"Message sent successfully"]
                                        duration:2.0
                                        position:@"center"];
                        }
                        
                        [controller dismissViewControllerAnimated:YES completion:Nil];
                    };
                    controller.completionHandler =myBlock;
                    
                    //Adding the Text to the facebook post value from iOS
                    
                    if(isSearching)
                    {
                        [controller setInitialText:[NSString stringWithFormat:@"%@ %@",[[searchSocialArray objectAtIndex:sender.tag] valueForKey:@"name"],[localization localizedStringForKey:@"Hi, I am using Amhappy , a new mobile application that lets you create events and meetups with friends, share photos and comments.I find it very interesting and I encourage to you to install it.Amhappy is available for Android and iPhone. Download it from http://www.amhappy.es and check how easy it is to meet friends."]]];

                    }
                    else
                    {
                        [controller setInitialText:[NSString stringWithFormat:@"%@ %@",[[socialArray objectAtIndex:sender.tag] valueForKey:@"name"],[localization localizedStringForKey:@"Hi, I am using Amhappy , a new mobile application that lets you create events and meetups with friends, share photos and comments.I find it very interesting and I encourage to you to install it.Amhappy is available for Android and iPhone. Download it from http://www.amhappy.es and check how easy it is to meet friends."]]];
                    }
                    
                    //Adding the URL to the facebook post value from iOS
                    
                    [controller addURL:[NSURL URLWithString:@"http://www.amhappy.es"]];
                    
                    //Adding the Image to the facebook post value from iOS
                    
                    //[controller addImage:[UIImage imageNamed:@"fb.png"]];
                    
                    [self presentViewController:controller animated:YES completion:Nil];
                    
               
               /* [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
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
                                [dict setValue:[NSString stringWithFormat:@"%@",[[searchSocialArray objectAtIndex:sender.tag] valueForKey:@"id"]] forKey:@"user_id"];
                                [dict setValue:[[searchSocialArray objectAtIndex:sender.tag] valueForKey:@"name"] forKey:@"screen_name"];
                            }
                            else
                            {
                                [dict setValue:[NSString stringWithFormat:@"%@",[[socialArray objectAtIndex:sender.tag] valueForKey:@"id"]] forKey:@"user_id"];
                                [dict setValue:[[socialArray objectAtIndex:sender.tag] valueForKey:@"name"] forKey:@"screen_name"];
                            }
                           
                            [dict setValue:[localization localizedStringForKey:@"I just found this awesome app that I think you would like!"] forKey:@"text"];
                            
                            
                            
                            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/direct_messages/new.json"];
                        
                            
//                             {
//                             "screen_name" = FriendSolanki;
//                             text = "I just found this awesome app that I think you would like!";
//                             "user_id" = 3221378472;
//                             }
//                            
//                           TWRequest *req = [[TWRequest alloc] initWithURL:url
//                                                                 parameters:dict
//                                                              requestMethod:TWRequestMethodPOST];
                            
                            SLRequest *req  = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                      requestMethod:SLRequestMethodPOST
                                                                                URL:url
                                                                         parameters:dict];
                            
                            req.account = twitterAccount;
                            
                            [req performRequestWithHandler:^(NSData *responseData,
                                                             NSHTTPURLResponse *urlResponse,
                                                             NSError *error)
                             {
                                 [drk hide];
                                 if(error != nil) {
                                     [drk hide];
                                     NSLog(@"error is %@",error.localizedDescription);
                                     
                                 }
                                 
                                 NSError *jsonError = nil;
                                 NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:responseData
                                                                           options:0
                                                                             error:&jsonError];
                                
                                 
                                 if(resp.count>1)
                                 {
                                     NSLog(@"Message sent");

                                     [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Message sent successfully"] AlertFlag:1 ButtonFlag:1];

                                   
                                 }
                                 else
                                 {
                                     NSLog(@"error occured %@",jsonError.localizedDescription);

                                     [DELEGATE showalert:self Message:[localization localizedStringForKey:@"You can not send more than one message"] AlertFlag:1 ButtonFlag:1];
                                   
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
                }];*/
            }
           else{
              // NSLog(@"UnAvailable");
               
               [self.view makeToast:[localization localizedStringForKey:@"Your device can not open twitter message composer, please check your account in device settings"]
                           duration:2.0
                           position:@"center"];
           }
            
        }
        if(self.socialId==3)
        {
            [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
            
            id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
            
            [shareBuilder setPrefillText:[localization localizedStringForKey:@"I just found this awesome app that I think you would like!"]];
            
            [shareBuilder setURLToShare:[NSURL URLWithString:@"www.apple.com"]];
            GTLPlusPerson *per;
            if(isSearching)
            {
                per =[searchSocialArray objectAtIndex:sender.tag];
            }
            else
            {
                per =[socialArray objectAtIndex:sender.tag];
            }
            
            
            
            NSArray *array =[NSArray arrayWithObject:per.identifier];
            
            [shareBuilder setPreselectedPeopleIDs:array];
            [drk hide];
            
            [shareBuilder open];
        }
        if(self.socialId==4)
        {
            NSString *emailTitle = [localization localizedStringForKey:@"Amhappy invitation"];
            // Email Content
            
           // NSString *messageBody = [localization localizedStringForKey:@"I just found this awesome app that I think you would like!"];
            // To address
            NSArray *toRecipents ;
            if(isSearching)
            {
                toRecipents = [NSArray arrayWithObject:[[searchSocialArray objectAtIndex:sender.tag] valueForKey:@"email"]];
            }
            else
            {
                toRecipents = [NSArray arrayWithObject:[[socialArray objectAtIndex:sender.tag] valueForKey:@"email"]];
            }
            
            
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mf = [[MFMailComposeViewController alloc] init];
                mf.mailComposeDelegate = self;
                [mf setSubject:emailTitle];
                //[mf setMessageBody:messageBody isHTML:NO];
                [mf setToRecipients:toRecipents];
                
                //******** add the HTMl attachment Here
                
                NSString *file = @"InviatacionUsarAmhappyEnglish.html";
              
                // Determine the file name and extension
                NSArray *filepart = [file componentsSeparatedByString:@"."];
                NSString *filename = [filepart objectAtIndex:0];
                NSString *extension = [filepart objectAtIndex:1];
                
                // Get the resource path and read the file using NSData
                NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
                NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                

                // Determine the MIME type
                NSString *mimeType;
                if ([extension isEqualToString:@"jpg"]) {
                    mimeType = @"image/jpeg";
                } else if ([extension isEqualToString:@"png"]) {
                    mimeType = @"image/png";
                } else if ([extension isEqualToString:@"doc"]) {
                    mimeType = @"application/msword";
                } else if ([extension isEqualToString:@"ppt"]) {
                    mimeType = @"application/vnd.ms-powerpoint";
                } else if ([extension isEqualToString:@"html"]) {
                    mimeType = @"text/html";
                } else if ([extension isEqualToString:@"pdf"]) {
                    mimeType = @"application/pdf";
                }
                
                // Add attachment
                [mf addAttachmentData:fileData mimeType:mimeType fileName:filename];
                
//                NSMutableString *body = [NSMutableString string];
//                // add HTML before the link here with line breaks (\n)
//                [body appendString:@"<p>Hi, I am using Amhappy , a new mobile application that lets you create events and meetups with friends, share photos and comments.</p>"];
//                [body appendString:@"<p>Amhappy is available for Android and iPhone.</p>"];
//                [body appendString:@"<div>Thanks much!</div>\n"];
//                
//                [body appendString:@"<p>Download it from <a href=
//                 "http://www.amhappy.es">http://www.amhappy.es </a> and check how easy it is to meet friends.</p>"];
                
                 
//                NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"];
//                //Add some text to it however you want
//               
//                //Pick an image to insert
//                //This example would come from the main bundle, but your source can be elsewhere
//                UIImage *emailImage = [UIImage imageNamed:@"logo.png"];
//                //Convert the image into data
//                NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(emailImage)];
//                //Create a base64 string representation of the data using NSData+Base64
//                NSString *base64String = [imageData base64EncodedString];
//                //Add the encoded string to the emailBody string
//                //Don't forget the "<b>" tags are required, the "<p>" tags are optional
//                [emailBody appendString:[NSString stringWithFormat:@"<p><b><img src='data:image/png;base64,%@'></b></p>",base64String]];
//                //You could repeat here with more text or images, otherwise
//                //close the HTML formatting
//                
//                
//                [emailBody appendString:@"<p>Hi, I am using Amhappy , a new mobile application that lets you create events and meetups with friends, share photos and comments.</p>"];
//                
//                
//                [emailBody appendString:@"<p>I find it very interesting and I encourage to you to install it.</p>"];
//                
//                [emailBody appendString:@"<p>Amhappy is available for Android and iPhone.</p>"];
//                
//                [emailBody appendString:@"<p>Download it from<a href=\"http://www.amhappy.es\">http://www.amhappy.es</a> and check how easy it is to meet friends.</p>"];
//                
//                
//               // [emailBody appendString:@"<ul><li><h1 class="slider-title  hide-animation">You are not alone </h1><p>Find your friends and enjoy</p><p><a href=""><img src="http://www.amhappy.es/wp-content/uploads/2015/07/apple-btn.png" alt="app store" draggable="false"></a><a href="https://play.google.com/store/apps/details?id=com.amhappy"><img src="http://www.amhappy.es/wp-content/uploads/2015/07/googleplay-btn.png" alt="play store" draggable="false"></a></p> </li></ul>"];
//                
//                
//                [emailBody appendString:@""];
//                
//
//                [emailBody appendString:@"</body></html>"];
//                NSLog(@"%@",emailBody);
//
//                [mf setMessageBody:emailBody isHTML:YES];
//                
                
                

                [self presentViewController:mf animated:YES completion:NULL];
            }
            else
            {
                NSLog(@"This device cannot send email");
            }
          
            

        }
       
    }
  }

-(void)responseSentinvitation:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
       // [alert show];
    }
    else
    {
         [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
     
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
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
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

- (IBAction)clickGroupImage:(id)sender {
}
@end

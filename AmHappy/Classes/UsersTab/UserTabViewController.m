//
//  UserTabViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import "UserTabViewController.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
//#import <FacebookSDK/FacebookSDK.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "FindingFriendsViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "FriendListViewController.h"
#import "OtherUserProfileViewController.h"
#import "TYMActivityIndicatorViewViewController.h"

#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "GroupListViewController.h"

@interface UserTabViewController ()

@end

@implementation UserTabViewController
{
    NSArray *socialArray;
    NSMutableArray *twitterArray;
    TYMActivityIndicatorViewViewController *drk;
    NSMutableDictionary *dicContact;
    NSMutableArray *contactArray;
    NSMutableArray *mobileArray;
    NSMutableArray *friendsArray;
    ModelClass *mc;
    int start;
    BOOL isLast;
    BOOL isShow;
    
    NSMutableArray *searchArray;

    BOOL isSearching;
    
    int searchStart;
    
    UIToolbar *mytoolbar2;
    
    int blockTag;
    NSArray *indexTitles;
    
    NSString *userid;
    
    
    NSMutableArray *sectionTitleArray;
    NSMutableDictionary *keyDict;
    
    
    NSMutableArray *searchSectionTitleArray;
    NSMutableDictionary *searchKeyDict;

}
@synthesize txtSearch;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
        {
            
            [self tabBarItem].selectedImage = [[UIImage imageNamed:@"frnd.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self tabBarItem].image = [[UIImage imageNamed:@"frnd2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else
        {
            [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"frnd.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"frnd2.png"]];
        }
        
    }
    
    self.title =[localization localizedStringForKey:@"My Friends"];

    return self;
}

@synthesize lblTitle,tableviewFriend;

@synthesize btnAdd,inviteView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userid =[[NSString alloc] init];
    searchSectionTitleArray =[[NSMutableArray alloc] init];
    sectionTitleArray =[[NSMutableArray alloc] init];
    keyDict =[[NSMutableDictionary alloc] init];
    searchKeyDict =[[NSMutableDictionary alloc] init];
    socialArray =[[NSArray alloc] initWithObjects:@"Facebook",@"Google Plus",@"Twitter",@"Contact",@"Amhappy User", nil];
    indexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    twitterArray=[[NSMutableArray alloc] init];
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    mc=[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    start =0;
    isLast =YES;
    isShow =NO;
    isSearching =NO;
    
    searchStart =0;
    
    blockTag =-1;
    
    searchArray =[[NSMutableArray alloc] init];
    dicContact =[[NSMutableDictionary alloc] init];
    contactArray =[[NSMutableArray alloc] init];
    mobileArray =[[NSMutableArray alloc] init];
    
    friendsArray =[[NSMutableArray alloc] init];
    
    mytoolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    mytoolbar2.barStyle = UIBarStyleBlackOpaque;
    if(IS_OS_7_OR_LATER)
    {
        mytoolbar2.barTintColor=[UIColor colorWithRed:228.0/255.0 green:123.0/255.0 blue:0.0/255.0 alpha:1.0];
        
    }
    else
    {
        mytoolbar2.tintColor=[UIColor colorWithRed:228.0/255.0 green:123.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    
    
    UIBarButtonItem *done2 = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Done"]
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self action:@selector(donePressed)];
    
    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    mytoolbar2.items = [NSArray arrayWithObjects:flexibleSpace2,done2, nil];
    self.txtSearch.inputAccessoryView =mytoolbar2;

    
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:TwitteAppKEY andSecret:TwitteAppSecretId];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
    [GPPSignIn sharedInstance].clientID = GOOGLEKEY;
    [GPPSignIn sharedInstance].scopes= [NSArray arrayWithObjects:kGTLAuthScopePlusLogin, nil];
    [GPPSignIn sharedInstance].shouldFetchGoogleUserID=YES;
    [GPPSignIn sharedInstance].shouldFetchGoogleUserEmail=YES;
    [GPPSignIn sharedInstance].delegate=self;
}
-(void)donePressed
{
    [self.view endEditing:YES];
    if([[self.txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        [self.tableviewFriend setHidden:NO];
    }
    
}
-(void)callApi
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc getFriends:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Sel:@selector(responseGetUsers:)];
      
    }
}
-(void)responseGetUsers:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        DELEGATE.isAccepted =NO;
        
        [friendsArray removeAllObjects];
        [keyDict removeAllObjects];
        [sectionTitleArray removeAllObjects];        
        [searchKeyDict removeAllObjects];
        [searchSectionTitleArray removeAllObjects];
        
        [friendsArray addObjectsFromArray:[results valueForKey:@"Friend"]];
        
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            isLast =YES;
            if(friendsArray.count==0)
            {
                [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
            }
        }
        else
        {
            
            isLast =NO;
        }
        [self getMainArray];
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
    }
}
-(void)getMainArray
{
    for(NSString *str in indexTitles)
    {
        NSArray *array =[[NSArray alloc] initWithArray:[self getArrayfor:str]];
        [keyDict setObject:array forKey:str];
    }
    
    [sectionTitleArray removeAllObjects];
    [sectionTitleArray addObjectsFromArray:[[keyDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [self.tableviewFriend reloadData];
    
  /*  if(sectionTitleArray.count>0)
    {
        [self.tableviewFriend reloadData];
    }*/
    
}

-(NSArray *)getArrayfor:(NSString *)startWord
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", startWord];
    NSArray *result = [friendsArray filteredArrayUsingPredicate:pred];
    //NSLog(@"result is %@",result);
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewWillAppear:(BOOL)animated
{
    
    DELEGATE.frinedReqbadgeValue = 0;
    
    UITabBarItem *item2 = [self.tabBarController.tabBar.items objectAtIndex:3];
    
    if(DELEGATE.frinedReqbadgeValue==0)
    {
        [item2 setBadgeValue:nil];
    }
    else
    {
        [item2 setBadgeValue:[NSString stringWithFormat:@"%d",DELEGATE.frinedReqbadgeValue]];
    }

    
    [self localize];
    
   
    [self.tableviewFriend setHidden:NO];
    self.txtSearch.text =@"";
    isSearching=NO;
    
   /* if(DELEGATE.isAccepted)
    {*/
        [twitterArray removeAllObjects];
        [contactArray removeAllObjects];
        [mobileArray removeAllObjects];
        start=0;
        isLast=YES;
        [friendsArray removeAllObjects];
        
        [self callApi];
   // }
    
    
}
-(void)localize
{
    self.lblTitle.text= [localization localizedStringForKey:@"My Friends"];
    self.title =[localization localizedStringForKey:@"My Friends"];
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];

    
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    //isSearching = YES;
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
        [self.tableviewFriend reloadData];
    }
}
- (void)filterListForSearchText:(NSString *)searchText
{
    [searchArray removeAllObjects];
    [searchKeyDict removeAllObjects];
    [searchSectionTitleArray removeAllObjects];
    
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
    if(searchArray.count>0)
    {
        [self getSearchArray];
    }
    else
    {
        [self.tableviewFriend reloadData];
    }
    
}
-(void)getSearchArray
{
    for(NSString *str in indexTitles)
    {
        NSArray *array =[[NSArray alloc] initWithArray:[self getSearchArrayfor:str]];
        [searchKeyDict setObject:array forKey:str];
    }
    
    [searchSectionTitleArray removeAllObjects];

    [searchSectionTitleArray addObjectsFromArray:[[searchKeyDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    
    [self.tableviewFriend reloadData];
    /*if(searchSectionTitleArray.count>0)
    {
        [self.tableviewFriend reloadData];
    }*/
    
}

-(NSArray *)getSearchArrayfor:(NSString *)startWord
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", startWord];
    NSArray *result = [searchArray filteredArrayUsingPredicate:pred];
    
    NSLog(@"result is %@",result);
    return result;
}


- (void)handleFriendsTapFrom: (UITapGestureRecognizer *)recognizer
{
    UIView *view = [recognizer view];
    int superTag =(int)view.superview.tag;
    
   /* if([[[friendsArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
    {
        [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
    }*/
    
    if(isSearching)
    {
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:superTag];
        NSArray *dataArray = [searchKeyDict objectForKey:sectionTitle];
        
        if([[[dataArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
        }
        
        dataArray =nil;
        sectionTitle=nil;
        
    }
    else
    {
        NSString *sectionTitle = [sectionTitleArray objectAtIndex:superTag];
        NSArray *dataArray = [keyDict objectForKey:sectionTitle];
        if([[[dataArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
        }
        dataArray =nil;
        sectionTitle=nil;
        
    }
    
    /* else
     {
     [DELEGATE showalert:self Message:[localization localizedStringForKey:@"There is no image to show preview"] AlertFlag:1 ButtonFlag:1];
     }*/
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if(isSearching)
    {
        return [searchSectionTitleArray count];
    }
    else
    {
        return [sectionTitleArray count];
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearching)
    {
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:section];
        NSArray *sectionAnimals = [searchKeyDict objectForKey:sectionTitle];
        return [sectionAnimals count];
    }
    else
    {
        NSString *sectionTitle = [sectionTitleArray objectAtIndex:section];
        NSArray *sectionAnimals = [keyDict objectForKey:sectionTitle];
        return [sectionAnimals count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        ChatUserCell *cell = (ChatUserCell *)[tableView dequeueReusableCellWithIdentifier:nil];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatUserCell" owner:self options:nil];
            cell=[nib objectAtIndex:0] ;
        }
    
       [cell.imgUser setContentMode:UIViewContentModeScaleAspectFill];
       [cell.imgUser setClipsToBounds:YES];
    
        [cell.lblLastMessage setHidden:YES];
        [cell.lblName2 setHidden:YES];
        [cell.lblCount setHidden:YES];
        
        
        if(IS_IPAD)
        {
            [cell.lblCount setFont:FONT_Regular(18)];
            [cell.lblName setFont:FONT_Regular(22)];
            
        }
        else
        {
            /* [cell.lblPrivate setFont:FONT_Regular(10)];
             [cell.lblName setFont:FONT_Regular(15)];
             [cell.lblDate setFont:FONT_Regular(12)];*/
            
            
        }
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFriendsTapFrom:)];
        tapGestureRecognizer.delegate = self;
        tapGestureRecognizer.cancelsTouchesInView = YES;
        cell.imgUser.tag =indexPath.row;
        cell.imgUser.superview.tag =indexPath.section;
        [cell.imgUser addGestureRecognizer:tapGestureRecognizer];
        cell.imgUser.layer.masksToBounds = YES;
        cell.imgUser.layer.cornerRadius = 25.0;
    
    if(isSearching)
    {
        
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [searchKeyDict objectForKey:sectionTitle];
        
        cell.lblName.text =[[dataArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        if([[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
        
        dataArray =nil;
        sectionTitle=nil;
    }
    else
    {
        NSString *sectionTitle = [sectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [keyDict objectForKey:sectionTitle];
        
        
        cell.lblName.text =[[dataArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        if([[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
        
        dataArray =nil;
        sectionTitle=nil;
    }
    
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
       
        
        return cell;
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //  return animalSectionTitles;
    return indexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [sectionTitleArray indexOfObject:title];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   [self.view endEditing:YES];
   
    
    OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];

    if(isSearching)
    {
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [searchKeyDict objectForKey:sectionTitle];
        [otherVC setUserId:[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
        NSLog(@"userid is %@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]);

        dataArray =nil;
        sectionTitle=nil;

    }
    else
    {
        NSString *sectionTitle = [sectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [keyDict objectForKey:sectionTitle];
        [otherVC setUserId:[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
        NSLog(@"userid is %@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]);

        dataArray =nil;
        sectionTitle=nil;

    }
    isSearching =NO;
    [self.tableviewFriend setHidden:NO];
  
    
    
    [self.navigationController pushViewController:otherVC animated:YES];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
        return 60;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[localization localizedStringForKey:@"Block"]  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        
        NSLog(@"Hello World!");
        [tableView reloadData];
        if(DELEGATE.connectedToNetwork)
        {
            blockTag =(int)indexPath.row;
            
            if(isSearching)
            {
                NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:indexPath.section];
                NSArray *dataArray = [searchKeyDict objectForKey:sectionTitle];
                
                userid =[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
                 [mc blockUser:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]] Sel:@selector(responseBlockUser:)];
                
                dataArray =nil;
                sectionTitle=nil;
            }
            else
            {
                NSString *sectionTitle = [sectionTitleArray objectAtIndex:indexPath.section];
                NSArray *dataArray = [keyDict objectForKey:sectionTitle];
                
                userid =[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
                 [mc blockUser:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]] Sel:@selector(responseBlockUser:)];
                
                dataArray =nil;
                sectionTitle=nil;
            }
           
        }
    }];
    
    return @[deleteAction];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [localization localizedStringForKey:@"Block"];
}
-(void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"delete");

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}
-(void)responseBlockUser:(NSDictionary *)results
{
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(isSearching)
        {
           // NSString *friendId =[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:blockTag] valueForKey:@"id"]];

            for(int i=0; i<friendsArray.count;i++)
            {
                if([[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:i] valueForKey:@"id"]] isEqualToString:userid])
                {
                    [friendsArray removeObjectAtIndex:i];
                    break;
                }
            }
            for(int i=0; i<searchArray.count;i++)
            {
                if([[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:i] valueForKey:@"id"]] isEqualToString:userid])
                {
                    [searchArray removeObjectAtIndex:i];
                    break;
                }
            }
            [self getMainArray];
            [self getSearchArray];
            //[searchArray removeObjectAtIndex:blockTag];
            if(searchArray.count==0)
            {
                isSearching =NO;
            }

        }
        else
        {
           // [friendsArray removeObjectAtIndex:blockTag];
            for(int i=0; i<friendsArray.count;i++)
            {
                if([[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:i] valueForKey:@"id"]] isEqualToString:userid])
                {
                    [friendsArray removeObjectAtIndex:i];
                    break;
                }
            }
                [self getMainArray];
            
            
        }
        
        blockTag =-1;

    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
    }
}



- (void)listResults2 {
    
    NSString *username = [FHSTwitterEngine sharedEngine].authenticatedUsername;
   // NSMutableDictionary *   dict1 = [[FHSTwitterEngine sharedEngine]listFriendsForUser:username isID:NO withCursor:@"-1"];
    NSMutableDictionary *dict1 = [[FHSTwitterEngine sharedEngine]listFollowersForUser:username isID:YES withCursor:@"-1"];
    
    //  NSLog(@"====> %@",[dict1 objectForKey:@"users"] );        // Here You get all the data
    NSMutableArray *array=[dict1 objectForKey:@"users"];
    for(int i=0;i<[array count];i++)
    {
        NSLog(@"names:%@",[[array objectAtIndex:i]objectForKey:@"name"]);
    }
    
    
     
     for(int i=0;i<[array count];i++)
     {
         NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
         [dict setValue:[[array objectAtIndex:i] valueForKey:@"screen_name"] forKey:@"name"];
         [dict setValue:[[array objectAtIndex:i] valueForKey:@"profile_image_url"] forKey:@"image"];
         [dict setValue:[[array objectAtIndex:i] valueForKey:@"id"] forKey:@"id"];
         [twitterArray addObject:dict];
         NSLog(@"names:%@",dict);

         dict=nil;
     
     
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
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No followers found for this twitter account"] AlertFlag:1 ButtonFlag:1];
        
    }
    
    
}

-(void)twitterTapped
{
    if(DELEGATE.connectedToNetwork)
    {
        UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
            NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
            [self listResults2];
            
        }];
        [self presentViewController:loginController animated:YES completion:nil];
    }
    
}
- (void)listResults {
    
    NSString *username = [FHSTwitterEngine sharedEngine].authenticatedUsername;
  //  NSLog(@"all followers are %@",[[FHSTwitterEngine sharedEngine] listFollowersForUser:[FHSTwitterEngine sharedEngine].authenticatedID isID:YES withCursor:nil]);
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
          
        }
    }];
}
-(void)fbTapped
{
    if(DELEGATE.connectedToNetwork)
    {
        [self callFriends];
    }
    
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
    
//    
//    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//                                  initWithGraphPath:@"/me/friends"
//                                  parameters:@{ @"fields": @"name,picture,gender",}
//                                  HTTPMethod:@"GET"];
//    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//        // Insert your code here
//        
//        NSMutableArray *data = [[NSMutableArray alloc]init];
//        
//        if (!error) {
//            NSLog(@"fetched user:%@", result);
//       
//            [data addObjectsFromArray:[result objectForKey:@"data"]];
//            
//            
//            
//            
//            
//            if (![[[data valueForKey:@"user"]valueForKey:@"paging"]isEqualToString:@""])
//            {
//                
//                
//                
//                
//                
//                
//                
//            }
//            
//            
//            
//            
//            
//            NSMutableArray *friendsList = [[NSMutableArray alloc] init];
//            for (FBSDKShareOpenGraphObject *friend in data)
//            {
//                NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
//                NSLog(@"friend:%@", friend);
//                [dict setValue:[[[friend objectForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"] forKey:@"image"];
//                [dict setValue:[friend objectForKey:@"name"] forKey:@"name"];
//                [dict setValue:[friend objectForKey:@"id"] forKey:@"id"];
//                [friendsList addObject:dict];
//                dict=nil;
//                
//            }
//            if(friendsList.count>0)
//            {
//                [drk hide];
//                
//                
//                FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
//                [frndVC setUserArray:friendsList];
//                [frndVC setSocialId:2];
//                [self.navigationController pushViewController:frndVC animated:YES];
//            }
//            else
//            {
//                [drk hide];
//                
//                [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No facebook friends found"] AlertFlag:1 ButtonFlag:1];
//                
//                
//            }
//            
//        }
//
//        
//    }];
//    
    
    
    
//    if ([FBSDKAccessToken currentAccessToken])
//    {
//        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends?fields=name,picture,gender" parameters:nil]
//         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
//        {
//             if (!error) {
//                 NSLog(@"fetched user:%@", result);
//                 
//                 
//                 
//                                                               NSArray *data = [result objectForKey:@"data"];
//                                                               NSMutableArray *friendsList = [[NSMutableArray alloc] init];
//                                                               for (FBSDKShareOpenGraphObject *friend in data)
//                                                               {
//                                                                   NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
//                                                                   NSLog(@"friend:%@", friend);
//                                                                   [dict setValue:[[[friend objectForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"] forKey:@"image"];
//                                                                   [dict setValue:[friend objectForKey:@"name"] forKey:@"name"];
//                                                                   [dict setValue:[friend objectForKey:@"id"] forKey:@"id"];
//                                                                   [friendsList addObject:dict];
//                                                                   dict=nil;
//                 
//                                                               }
//                                                               if(friendsList.count>0)
//                                                               {
//                                                                   [drk hide];
//                 
//                 
//                                                                   FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
//                                                                   [frndVC setUserArray:friendsList];
//                                                                   [frndVC setSocialId:2];
//                                                                   [self.navigationController pushViewController:frndVC animated:YES];
//                                                               }
//                                                               else
//                                                               {
//                                                                   [drk hide];
//                 
//                                                                   [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No facebook friends found"] AlertFlag:1 ButtonFlag:1];
//                                                                   
//                                                               
//                                                               }
//           
//             }
//         }];
//    }
    

    
    
    
//    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    
    
    
    
//   
//    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"user_friends"]
//                                       allowLoginUI:YES
//                                  completionHandler:^(FBSession *session,
//                                                      FBSessionState state,
//                                                      NSError *error)
//     {
//                                      
//                                      if (error)
//                                      {
//                                          [drk hide];
//                                          
//                                          [DELEGATE showalert:self Message:error.localizedDescription AlertFlag:1 ButtonFlag:1];
//                                          
//                                        
//                                      }
//                                      else if (session.isOpen)
//                                      {
//                                          FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,picture,gender"];
//                                          
//                                          
//                                          [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                              NSArray *data = [result objectForKey:@"data"];
//                                              NSMutableArray *friendsList = [[NSMutableArray alloc] init];
//                                              for (FBGraphObject<FBGraphUser> *friend in data)
//                                              {
//                                                  NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
//                                                  NSLog(@"friend:%@", friend);
//                                                  [dict setValue:[[[friend objectForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"] forKey:@"image"];
//                                                  [dict setValue:[friend objectForKey:@"name"] forKey:@"name"];
//                                                  [dict setValue:[friend objectForKey:@"id"] forKey:@"id"];
//                                                  [friendsList addObject:dict];
//                                                  dict=nil;
//                                                  
//                                              }
//                                              if(friendsList.count>0)
//                                              {
//                                                  [drk hide];
//                                                
//                                                  
//                                                  FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
//                                                  [frndVC setUserArray:friendsList];
//                                                  [frndVC setSocialId:2];
//                                                  [self.navigationController pushViewController:frndVC animated:YES];
//                                              }
//                                              else
//                                              {
//                                                  [drk hide];
//                                                  
//                                                  [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No facebook friends found"] AlertFlag:1 ButtonFlag:1];
//                                                  
//                                              
//                                              }
//                                              
//                                              
//                                              
//                                          }];
//                                          
//                                          
//                                      }
//                                  }];
//    //}
    
}

-(void)googleTapped
{
    if(DELEGATE.connectedToNetwork)
    {
        [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
        [[GPPSignIn sharedInstance] authenticate];
    }
    
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
                        
                     
                        FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
                        [frndVC setUserArray:peopleList];
                        [frndVC setSocialId:3];
                        
                        [self.navigationController pushViewController:frndVC animated:YES];
                        
                       
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

-(void)mailTapped
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self addressBookValidation];
    }
    else
    {
        NSString *emailTitle = @"Test Email";
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
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL)
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
      //  NSLog(@"ABAddressBookRequestAccessWithCompletion is null");
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
    
}
- (void) SyncContactData
{
    
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
  //  NSLog(@"sorted array is %@",contactArray);
    NSArray *array =[[NSArray alloc] initWithArray:[self getContactArray]];
    
    if(array.count>0)
    {
       
        FriendListViewController *frndVC =[[FriendListViewController alloc] initWithNibName:@"FriendListViewController" bundle:nil];
        [frndVC setUserArray:array];
        [frndVC setSocialId:4];
        [self.navigationController pushViewController:frndVC animated:YES];
    }
    else
    {
        NSString *emailTitle = @"Test Email";
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
                
                
            }
        }
    }
    
   
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
- (IBAction)twitterTapped:(id)sender
{
     [self twitterTapped];
}

- (IBAction)googleTapped:(id)sender
{
    [self googleTapped];
}

- (IBAction)messageTapped:(id)sender
{
    [self mailTapped];
}

- (IBAction)amhappyTapped:(id)sender
{
    FindingFriendsViewController *frndVC =[[FindingFriendsViewController alloc] initWithNibName:@"FindingFriendsViewController" bundle:nil];
    NSArray *array =[[NSArray alloc] init];
    [frndVC setUserArray:array];
    [frndVC setSocialId:5];
    [self.navigationController pushViewController:frndVC animated:YES];
}

- (IBAction)fbTapped:(id)sender
{
     [self fbTapped];
}

- (IBAction)groupTapped:(id)sender
{
    GroupListViewController *groupListVC =[[GroupListViewController alloc] initWithNibName:@"GroupListViewController" bundle:nil];
    [self.navigationController pushViewController:groupListVC animated:YES];
}
@end

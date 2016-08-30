//
//  FriendRequestViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 25/02/15.
//
//

#import "FriendRequestViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "HomeTabViewController.h"

@interface FriendRequestViewController ()

@end

@implementation FriendRequestViewController
{
    ModelClass *mc;
    NSMutableArray *friendsArray;
    NSMutableArray *eventArray;
    int acceptTag;
    
    NSMutableArray *searchArray;
    BOOL isSearching;
    UIToolbar *mytoolbar1;
    
}
@synthesize lblTitle,tableviewAccept,isFriend,txtSearch;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mc=[[ModelClass alloc] init];
    [mc setDelegate:self];
    friendsArray =[[NSMutableArray alloc] init];
    eventArray =[[NSMutableArray alloc] init];
    searchArray =[[NSMutableArray alloc] init];
    
    isSearching =NO;
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
   
}
-(void)donePressed
{
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
    if(DELEGATE.connectedToNetwork)
    {
        [friendsArray removeAllObjects];
        [eventArray removeAllObjects];

        [mc listFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responseGetFriends:)];
    }
}
-(void)localize
{
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];

    [self.lblTitle setText:[localization localizedStringForKey:@"Friend Request"]];
}
-(void)responseGetFriends:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [friendsArray addObjectsFromArray:[results valueForKey:@"User"]];
        [self.tableviewAccept reloadData];
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) handleFriendTapFrom: (UITapGestureRecognizer *)recognizer
{
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
        if([[[friendsArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
        }
    }
    
   /* else
    {
         [DELEGATE showalert:self Message:[localization localizedStringForKey:@"There is no image to show preview"] AlertFlag:1 ButtonFlag:1];
    }*/
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearching)
    {
        if(self.isFriend)
        {
            return searchArray.count;
        }
        else return 0;
    }
    else
    {
        if(self.isFriend)
        {
            return friendsArray.count;
        }
        else return 0;
    }
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    InviteCell *cell = (InviteCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InviteCell" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
    }
    cell.delegate=self;
    cell.imgUser.layer.masksToBounds = YES;
    cell.imgUser.layer.cornerRadius = 30.0;
    
    cell.btnReject.layer.masksToBounds = YES;
    cell.btnReject.layer.cornerRadius = 3.0;
    
    cell.btnAccept.layer.masksToBounds = YES;
    cell.btnAccept.layer.cornerRadius = 3.0;
  
   
    cell.btnAccept.tag =indexPath.row;
    cell.btnReject.tag =indexPath.row;
   
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFriendTapFrom:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = YES;
    cell.imgUser.tag =indexPath.row;
    [cell.imgUser addGestureRecognizer:tapGestureRecognizer];
    if(isSearching)
    {
        cell.lblName.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
    }
    else
    {
        cell.lblName.text =[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        if([[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
    }

    
   /* if(self.isFriend)
    {
        cell.lblName.text =[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        if([[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
        
    }
   
    else
    {

        cell.lblName.text =[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        if([[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"image"]]];
        }
        
    }*/
    
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
        [self.tableviewAccept reloadData];
    }
}
- (void)filterListForSearchText:(NSString *)searchText
{
    [searchArray removeAllObjects];
    
    if(friendsArray.count>0)
    {
        for(int i=0;i<friendsArray.count;i++)
        {
            NSRange nameRange = [[[friendsArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound) {
                [searchArray addObject:[friendsArray objectAtIndex:i]];
            }
        }
    }
    
    
    [self.tableviewAccept reloadData];
    
}

-(void)accerptTapped:(UIButton *)sender
{
    acceptTag =(int)[sender tag];
    if(DELEGATE.connectedToNetwork)
    {
        if(isSearching)
        {
            [mc acceptFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[searchArray objectAtIndex:[sender tag]] valueForKey:@"id"] Is_accept:@"Y" Sel:@selector(responseFriendsRequest:)];
        }
        else
        {
            [mc acceptFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[friendsArray objectAtIndex:[sender tag]] valueForKey:@"id"] Is_accept:@"Y" Sel:@selector(responseFriendsRequest:)];
        }
        
    }
}
-(void)rejectTapped:(UIButton *)sender
{
    acceptTag =(int)[sender tag];
    
    
    [DELEGATE showalertNew:self Message:[localization localizedStringForKey:@"Are you sure, you want to reject this request?"] AlertFlag:1];

    
}
- (void)inviteBtnTapped:(id)sender
{
    [[self.view viewWithTag:191] removeFromSuperview];
    if(DELEGATE.connectedToNetwork)
    {
        if(isSearching)
        {
            [mc acceptFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[searchArray objectAtIndex:acceptTag] valueForKey:@"id"] Is_accept:@"N" Sel:@selector(responseFriendsRequest:)];
        }
        else
        {
            [mc acceptFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[friendsArray objectAtIndex:acceptTag] valueForKey:@"id"] Is_accept:@"N" Sel:@selector(responseFriendsRequest:)];
        }
        
    }
    
}
- (void)laterBtnTapped:(id)sender
{
    
    [[self.view viewWithTag:191] removeFromSuperview];
    
}

- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)deleteObject
{
    NSString *eventID =[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:acceptTag] valueForKey:@"id"]];
    for(int i=0;i<friendsArray.count;i++)
    {
        if([[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:i] valueForKey:@"id"]] isEqualToString:eventID])
        {
            [friendsArray removeObjectAtIndex:i];
            break;
        }
    }
}
-(void)responseFriendsRequest:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        DELEGATE.isAccepted=YES;
        if(isSearching)
        {
            [self deleteObject];
            [searchArray removeObjectAtIndex:acceptTag];
            
        }
        else
        {
            [friendsArray removeObjectAtIndex:acceptTag];
        }
        
         acceptTag =-1;
        [self.tableviewAccept reloadData];
        
        NSNotification *notification1 = [NSNotification notificationWithName:@"friendChanged" object:self];
        [[NSNotificationCenter defaultCenter]postNotification:notification1];
        if(friendsArray.count==0)
        {
            BOOL found =NO;
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
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
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
    
}
-(void)cancelBtnTapped:(id)sender
{
    //NSLog(@"cancelBtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];
    
}
@end

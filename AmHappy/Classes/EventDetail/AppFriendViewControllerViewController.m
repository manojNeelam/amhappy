//
//  AppFriendViewControllerViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 27/02/15.
//
//

#import "AppFriendViewControllerViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "InviteGroupViewController.h"

@interface AppFriendViewControllerViewController ()

@end

@implementation AppFriendViewControllerViewController
{
    ModelClass *mc;
    NSMutableArray *friendsArray;
    NSMutableArray *inviteArray;

    int inviteTag;
    int start;
    BOOL isLast;
    
    NSMutableArray *searchFriendsArray;
    NSMutableArray *searchInviteArray;
    
    int searchStart;
    BOOL isLastSearch;
    
    BOOL isSearching;
    UIToolbar *mytoolbar1;
}
@synthesize lblTitle,tableview,eventID,isHideBtnAdd,isbackToHome;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (isHideBtnAdd)
    {
        
        [self.btnAdd setHidden:YES];
        
    }
    
    
    mc=[[ModelClass alloc] init];
    [mc setDelegate:self];
    friendsArray =[[NSMutableArray alloc] init];
    inviteArray =[[NSMutableArray alloc] init];
    inviteTag =-1;
    start =0;
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
    
    
    searchFriendsArray =[[NSMutableArray alloc] init];
    searchInviteArray =[[NSMutableArray alloc] init];
    searchStart =0;
    NSLog(@"event id is %@",self.eventID);

    [self callApi];
}
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
    [self.lblTitle setText:[localization localizedStringForKey:@"AmHappy Users"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)callSearchApi
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc getAppUser:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",searchStart] Limit:LimitComment Eventid:[NSString stringWithFormat:@"%@",self.eventID] Keyword:[self.txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] Sel:@selector(responseGetSearchedUsers:)];
    }
}
-(void)responseGetSearchedUsers:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(searchStart==0)
        {
            [searchFriendsArray removeAllObjects];
            [searchInviteArray removeAllObjects];

        }
        [searchFriendsArray addObjectsFromArray:[results valueForKey:@"User"]];
        [searchInviteArray addObjectsFromArray:[results valueForKey:@"Friend"]];
        
        [self.tableview reloadData];
        
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            isLastSearch =YES;
        }
        else
        {
            isLastSearch =NO;
        }
    }
}
-(void)callApi
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc getAppUser:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Eventid:[NSString stringWithFormat:@"%@",self.eventID] Keyword:@"" Sel:@selector(responseGetUsers:)];
    }
}
-(void)responseGetUsers:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [friendsArray addObjectsFromArray:[results valueForKey:@"User"]];
        [inviteArray addObjectsFromArray:[results valueForKey:@"Friend"]];

        [self.tableview reloadData];
        
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            isLast =YES;
        }
        else
        {
            isLast =NO;
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
        if(isSearching)
        {
            if(!isLastSearch)
            {
                searchStart=searchStart+10;
                [self callSearchApi];
            }
        }
        else
        {
            if(!isLast)
            {
                start=start+10;
                [self callApi];
            }
        }
        
        NSLog(@"down");
    }
}
- (void)handleTap: (UITapGestureRecognizer *)recognizer
{
    UIView *view = [recognizer view];
    if(isSearching)
    {
        if(view.superview.tag==0)
        {
            if([[[searchInviteArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
            {
                [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[searchInviteArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
            }
        }
        else
        {
            if([[[searchFriendsArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
            {
                [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[searchFriendsArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
            }
        }
    }
    else
    {
        if(view.superview.tag==0)
        {
            if([[[inviteArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
            {
                [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[inviteArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
            }
        }
        else
        {
            if([[[friendsArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
            {
                [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
            }
        }
    }
    
    
    
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    //isSearching = YES;
}
- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    isSearching = YES;
    
        if([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length%3==0)
        {
            [self callSearchApi];
        }
    
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
        isLastSearch =NO;
        searchStart =0;
        [searchInviteArray removeAllObjects];
        [searchFriendsArray removeAllObjects];

        [self.tableview reloadData];
    }
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
    
    
    if(section==0)
    {
        [title setText:[localization localizedStringForKey:@"Invite friends to Event"]];
    }
    else if (section==1)
    {
        [title setText:[localization localizedStringForKey:@"Add friends to AmHappy"]];

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
        if(section==0)
        {
            return searchInviteArray.count;
        }
        else if (section==1)
        {
            return searchFriendsArray.count;
        }
        else return 0;
    }
    else
    {
        if(section==0)
        {
            return inviteArray.count;
        }
        else if (section==1)
        {
            return friendsArray.count;
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
    
    [cell.btnAccept setTitle:[localization localizedStringForKey:@"Accept"] forState:UIControlStateNormal];
    [cell.btnInvite setTitle:[localization localizedStringForKey:@"Invite"] forState:UIControlStateNormal];
    
    [cell.btnAccept setTitle:[localization localizedStringForKey:@"Invite"] forState:UIControlStateNormal];

    
    cell.btnAdd.tag=indexPath.row;
    
    [cell.btnAccept setHidden:YES];
    //[cell.btnInvite setHidden:YES];
    
    cell.btnInvite.tag=indexPath.row;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = YES;
    cell.imgUser.tag =indexPath.row;
    cell.imgUser.superview.tag =indexPath.section;
    [cell.imgUser addGestureRecognizer:tapGestureRecognizer];
    
    if(isSearching)
    {
        if(indexPath.section==0)
        {
            if([[[searchInviteArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchInviteArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]] placeholderImage:[UIImage imageNamed:@"iconBlack"]];
            }
            cell.lblName.text =[[searchInviteArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            [cell.btnInvite setHidden:NO];
            [cell.btnAdd setHidden:YES];
            
        }
        else
        {
            if([[[searchFriendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchFriendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]] placeholderImage:[UIImage imageNamed:@"iconBlack"]];
            }
            cell.lblName.text =[[searchFriendsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            [cell.btnInvite setHidden:YES];
            [cell.btnAdd setHidden:NO];
            
        }
    }
    else
    {
        if(indexPath.section==0)
        {
            if([[[inviteArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[inviteArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]] placeholderImage:[UIImage imageNamed:@"iconBlack"]];
            }
            cell.lblName.text =[[inviteArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            [cell.btnInvite setHidden:NO];
            [cell.btnAdd setHidden:YES];
            
        }
        else
        {
            if([[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]] placeholderImage:[UIImage imageNamed:@"iconBlack"]];
            }
            cell.lblName.text =[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            [cell.btnInvite setHidden:YES];
            [cell.btnAdd setHidden:NO];
            
        }
    }
    
   
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)deleteFriendObject
{
    NSString *frndID =[NSString stringWithFormat:@"%@",[[searchFriendsArray objectAtIndex:inviteTag] valueForKey:@"id"]];
    for(int i=0;i<friendsArray.count;i++)
    {
        if([[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:i] valueForKey:@"id"]] isEqualToString:frndID])
        {
            [friendsArray removeObjectAtIndex:i];
            break;
        }
    }
}
-(void)accerptTapped:(id)sender
{
}
-(void)addTapped:(UIButton *)sender
{
    inviteTag =(int)[sender tag];
    if(DELEGATE.connectedToNetwork)
    {
        if(isSearching)
        {
            [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[searchFriendsArray objectAtIndex:sender.tag] valueForKey:@"id"] Sel:@selector(responseSentRequest:)];
        }
        else
        {
            [mc sendFriendRequest:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[[friendsArray objectAtIndex:sender.tag] valueForKey:@"id"] Sel:@selector(responseSentRequest:)];        }
        
    }
}
-(void)responseSentRequest:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(isSearching)
        {
            [self deleteFriendObject];
            [searchFriendsArray removeObjectAtIndex:inviteTag];
        }
        else
        {
            [friendsArray removeObjectAtIndex:inviteTag];
        }
        [self.tableview reloadData];
        inviteTag =-1;
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
    
}
-(void)deleteInviteObject
{
    NSString *frndID =[NSString stringWithFormat:@"%@",[[searchInviteArray objectAtIndex:inviteTag] valueForKey:@"id"]];
    for(int i=0;i<inviteArray.count;i++)
    {
        if([[NSString stringWithFormat:@"%@",[[inviteArray objectAtIndex:i] valueForKey:@"id"]] isEqualToString:frndID])
        {
            [inviteArray removeObjectAtIndex:i];
            break;
        }
    }
}
-(void)inviteTapped:(UIButton *)sender
{
    inviteTag =(int)[sender tag];
    if(DELEGATE.connectedToNetwork)
    {
        NSLog(@"event id is %@",self.eventID);
        if(isSearching)
        {
            [mc inviteFriendtoEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Friendids:[[searchInviteArray objectAtIndex:sender.tag] valueForKey:@"id"] Type:@"F" Sel:@selector(responseSentinvitation:)];
        }
        else
        {
            [mc inviteFriendtoEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Friendids:[[inviteArray objectAtIndex:sender.tag] valueForKey:@"id"] Type:@"F" Sel:@selector(responseSentinvitation:)];
        }
        
    }
}
-(void)responseSentinvitation:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(isSearching)
        {
            [self deleteInviteObject];
            [searchInviteArray removeObjectAtIndex:inviteTag];
        }
        else
        {
            [inviteArray removeObjectAtIndex:inviteTag];

        }
       
        [self.tableview reloadData];
         inviteTag =-1;
       
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
   
    }
    
    
}
- (IBAction)backTapped:(id)sender
{
    
    if (isbackToHome)
    {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else
    {
        
        [self.navigationController popViewControllerAnimated:YES];
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
- (IBAction)groupTapped:(id)sender
{
    InviteGroupViewController *inviteGroupVC =[[InviteGroupViewController alloc] initWithNibName:@"InviteGroupViewController" bundle:nil];
    inviteGroupVC.eventID =[NSString stringWithFormat:@"%@",self.eventID];
    [self.navigationController pushViewController:inviteGroupVC animated:YES];
}
@end

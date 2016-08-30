//
//  InviteGroupViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 14/09/15.
//
//

#import "InviteGroupViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"

@interface InviteGroupViewController ()

@end

@implementation InviteGroupViewController
{
    ModelClass *mc;
    NSMutableArray *groupArray;
    NSMutableArray *searchArray;
    
    int inviteTag;
    BOOL isSearching;
    UIToolbar *mytoolbar1;
}
@synthesize lblTitle,tblGroup,txtSearch;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mc=[[ModelClass alloc] init];
    [mc setDelegate:self];
    groupArray =[[NSMutableArray alloc] init];
    searchArray =[[NSMutableArray alloc] init];
    inviteTag =-1;
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
    
    if(DELEGATE.connectedToNetwork)
    {
        [mc myGroupsForEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:[NSString stringWithFormat:@"%@",self.eventID] Sel:@selector(responseGetMyGroup:)];
        //[mc myGroups:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responseGetMyGroup:)];
    }
    
    [self localize];
    
}
-(void)localize
{
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];
    [self.lblTitle setText:[localization localizedStringForKey:@"Groups"]];
    
}

-(void)responseGetMyGroup:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [groupArray removeAllObjects];
        [groupArray addObjectsFromArray:[results valueForKey:@"Group"]];
        [self.tblGroup reloadData];        
    }
    
}

-(void)donePressed
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearching)
    {
        return searchArray.count;
    }
    else
    {
        return groupArray.count;
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
            if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
            }
            cell.lblName.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            [cell.btnInvite setHidden:NO];
            [cell.btnAdd setHidden:YES];
            
        
    }
    else
    {
       
            if([[[groupArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
            {
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[groupArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
            }
            cell.lblName.text =[[groupArray objectAtIndex:indexPath.row] valueForKey:@"name"];
            [cell.btnInvite setHidden:NO];
            [cell.btnAdd setHidden:YES];
            
        
    }
    
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
        [self.tblGroup reloadData];
    }
}
- (void)filterListForSearchText:(NSString *)searchText
{
    [searchArray removeAllObjects];
    
    if(groupArray.count>0)
    {
        for(int i=0;i<groupArray.count;i++)
        {
            NSRange nameRange;
            
            nameRange = [[[groupArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            
            if (nameRange.location != NSNotFound) {
                [searchArray addObject:[groupArray objectAtIndex:i]];
            }
            
            
        }
    }
    [self.tblGroup reloadData];
    
}


-(void)inviteTapped:(UIButton *)sender
{
    inviteTag =(int)[sender tag];
    if(DELEGATE.connectedToNetwork)
    {
        if(isSearching)
        {
            [mc inviteFriendtoEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Friendids:[[searchArray objectAtIndex:sender.tag] valueForKey:@"id"] Type:@"G" Sel:@selector(responseInvitation:)];
        }
        else
        {
            [mc inviteFriendtoEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Friendids:[[groupArray objectAtIndex:sender.tag] valueForKey:@"id"] Type:@"G" Sel:@selector(responseInvitation:)];
        }
        
    }
}
-(void)responseInvitation:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(isSearching)
        {
            [self deleteInviteObject];
            [searchArray removeObjectAtIndex:inviteTag];
        }
        else
        {
            [groupArray removeObjectAtIndex:inviteTag];
        }
        
        [self.tblGroup reloadData];
        inviteTag =-1;
        
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
}
-(void)deleteInviteObject
{
    NSString *frndID =[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:inviteTag] valueForKey:@"id"]];
    for(int i=0;i<groupArray.count;i++)
    {
        if([[NSString stringWithFormat:@"%@",[[groupArray objectAtIndex:i] valueForKey:@"id"]] isEqualToString:frndID])
        {
            [groupArray removeObjectAtIndex:i];
            break;
        }
    }
}

-(void)addTapped:(id)sender
{
}
-(void)accerptTapped:(id)sender
{
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
- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

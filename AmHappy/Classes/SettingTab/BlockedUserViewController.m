//
//  BlockedUserViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 01/07/15.
//
//

#import "BlockedUserViewController.h"
#import "OtherUserProfileViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"

@interface BlockedUserViewController ()

@end

@implementation BlockedUserViewController
{
    NSMutableArray *friendsArray;
    ModelClass *mc;
    int blockTag;
}
@synthesize tableViewUser,lblTitle;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.lblTitle setText:[localization localizedStringForKey:@"Blocked User"]];

    friendsArray=[[NSMutableArray alloc] init];
    mc=[[ModelClass alloc] init];
    [mc setDelegate:self];
    blockTag =-1;
    if(DELEGATE.connectedToNetwork)
    {
        [mc getBlockedUsers:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responseGetBlockedUsers:)];
    }
}
-(void)responseGetBlockedUsers:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        [friendsArray addObjectsFromArray:[results valueForKey:@"Block"]];
        if(friendsArray.count==0)
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        }
        
      
       
        [self.tableViewUser reloadData];
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        if(friendsArray.count>0)
        {
            return friendsArray.count;
        }
        else return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        ChatUserCell *cell = (ChatUserCell *)[tableView dequeueReusableCellWithIdentifier:nil];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatUserCell" owner:self options:nil];
            cell=[nib objectAtIndex:0] ;
        }
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
      /*  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFriendsTapFrom:)];
        tapGestureRecognizer.delegate = self;
        tapGestureRecognizer.cancelsTouchesInView = YES;
        cell.imgUser.tag =indexPath.row;
        [cell.imgUser addGestureRecognizer:tapGestureRecognizer];*/
        
        cell.imgUser.layer.masksToBounds = YES;
        cell.imgUser.layer.cornerRadius = 25.0;
        
        
        cell.lblName.text =[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        if([[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        
        return cell;
    
    
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
    
        [otherVC setUserId:[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"id"]]];
   
    [self.navigationController pushViewController:otherVC animated:YES];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[localization localizedStringForKey:@"Unblock"]  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              
                                              if(DELEGATE.connectedToNetwork)
                                              {
                                                  blockTag =(int)indexPath.row;
                                                
                                                      
                                                      [mc unBlockUser:[USER_DEFAULTS valueForKey:@"userid"] Friendid:[NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"id"]] Sel:@selector(responseBlockUser:)];
                                                  
                                              }
                                          }];
    
    return @[deleteAction];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [localization localizedStringForKey:@"Unblock"];
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
        [friendsArray removeObjectAtIndex:blockTag];
        [self.tableViewUser reloadData];
         blockTag =-1;
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
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

- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

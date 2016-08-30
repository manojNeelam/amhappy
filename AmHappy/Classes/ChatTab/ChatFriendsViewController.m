//
//  ChatFriendsViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 02/03/15.
//
//

#import "ChatFriendsViewController.h"
#import "UIImageView+WebCache.h"
#import "ModelClass.h"
#import "NSManagedObject+Utilities.h"
#import "CoreDataUtils.h"
#import "ChatViewController.h"

@interface ChatFriendsViewController ()

@end

@implementation ChatFriendsViewController
{
    ModelClass *mc;
    NSMutableArray *friendsArray;
    int start;
    BOOL isLast;
    
    NSMutableArray *searchArray;
    BOOL isSearching;
    
    UIToolbar *mytoolbar1;
}
@synthesize tableviewFriend,lblTitle;
- (void)viewDidLoad
{
    [super viewDidLoad];
    mc=[[ModelClass alloc] init];
    [mc setDelegate:self];
    friendsArray =[[NSMutableArray alloc] init];
    searchArray =[[NSMutableArray alloc] init];

    
   //   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Unread" object:nil];
  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UnreadMessage1) name:@"Unread" object:nil];
    start =0;
    isLast =YES;
    
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
    
    [self.lblTitle setText:[localization localizedStringForKey:@"Friends"]];
    
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];


    [self callApi];
    // Do any additional setup after loading the view from its nib.
}
-(void)donePressed
{
    [self.view endEditing:YES];
    
}
-(void)UnreadMessage1
{
    [self updateDataBase];
}
-(void)callApi
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc getFriends:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Sel:@selector(responseGetUsers:)];
        //[mc getAppUser:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Sel:@selector(responseGetUsers:)];
    }
}
-(void)responseGetUsers:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
       
        [friendsArray addObjectsFromArray:[results valueForKey:@"Friend"]];
        [self updateDataBase];
        
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            isLast =YES;
            if(friendsArray.count==0)
            {
                [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
                /*UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"No result found"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
                [alert show];*/
            }
        }
        else
        {
            
            isLast =NO;
        }
    }
    else
    {
         [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
       /* UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"No result found"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
        [alert show];*/
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [self updateDataBase];
}
-(void)updateDataBase
{
    NSString *unread =@"Y";
    
    NSArray *myArray = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    NSString *userid =[NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]];
    for (int i=0; i<friendsArray.count; i++)
    {
        
        
        NSArray *myArray1 = [[[friendsArray objectAtIndex:i]valueForKey:@"jid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
        NSString *jid =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];

        
        NSArray *array =[[NSArray alloc ]initWithArray:[CoreDataUtils getObjects:[DB description] withQueryString:@"jid = %@ AND userid = %@ AND unread = %@ " queryArguments:@[jid,userid,unread]]];
    
        
        NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithDictionary:[friendsArray objectAtIndex:i]];
        [dict setValue:[NSString stringWithFormat:@"%lu",(unsigned long)array.count] forKey:@"message_count"];
        [friendsArray replaceObjectAtIndex:i withObject:dict];
        dict =nil;
        array =nil;
     
        
    }
    [self.tableviewFriend reloadData];
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
  //  isSearching = YES;
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
    
    if(friendsArray.count>0)
    {
        for(int i=0;i<friendsArray.count;i++)
        {
            NSRange nameRange;
            //            if(socialId==2)
            //            {
            //                GTLPlusPerson *per =[friendsArray objectAtIndex:i];
            //                 nameRange = [per.displayName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            //                per =nil;
            //            }
            //            else
            //            {
            nameRange = [[[friendsArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            //}
            if (nameRange.location != NSNotFound) {
                [searchArray addObject:[friendsArray objectAtIndex:i]];
            }
            
            
        }
    }
    [self.tableviewFriend reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGPoint targetPoint = *targetContentOffset;
    CGPoint currentPoint = scrollView.contentOffset;
    
    if (targetPoint.y > currentPoint.y)
    {
        NSLog(@"up");
    }
    else
    {
        if(!isLast)
        {
            start=start+10;
            [self callApi];
        }
        NSLog(@"down");
    }
}

- (void)handleFriends: (UITapGestureRecognizer *)recognizer
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
        if(friendsArray.count>0)
        {
            return friendsArray.count;
        }
        else return 0;
    }}

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
    
    cell.imgUser.layer.masksToBounds = YES;
    cell.imgUser.layer.cornerRadius = 25.0;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFriends:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = YES;
    cell.imgUser.tag =indexPath.row;
    [cell.imgUser addGestureRecognizer:tapGestureRecognizer];
    
   
    if(isSearching)
    {
        cell.lblName.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
      //  cell.lblCount.text =[NSString stringWithFormat:@"%@ unread message",[[searchArray objectAtIndex:indexPath.row] valueForKey:@"message_count"]];
        if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
    }
    else
    {
        cell.lblName.text =[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
      //  cell.lblCount.text =[NSString stringWithFormat:@"%@ unread message",[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"message_count"]];
        if([[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
    }
    
    
    
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewController *cvc = [[ChatViewController alloc]init];
  
    if(isSearching)
    {
        NSString *abc = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row]valueForKey:@"jid"]];
        NSArray *myArray = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
        // NSLog(@"%@",[myArray objectAtIndex:0]);
        cvc.fromJId = [NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]];
        cvc.fromUserId = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row]valueForKey:@"id"]];
        [cvc setIsGroupChat:NO];
        cvc.name = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"]];
        if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
        {
            cvc.imgUrl = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] valueForKey:@"image"]];

            
        }

    }
    else
    {
        NSString *abc = [NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:indexPath.row]valueForKey:@"jid"]];
        NSArray *myArray = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
        // NSLog(@"%@",[myArray objectAtIndex:0]);
        cvc.fromJId = [NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]];
        cvc.fromUserId = [NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:indexPath.row]valueForKey:@"id"]];
        [cvc setIsGroupChat:NO];
        cvc.name = [NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"name"]];
        if([[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
        {
            cvc.imgUrl = [NSString stringWithFormat:@"%@",[[friendsArray objectAtIndex:indexPath.row] valueForKey:@"image"]];
            
            
        }

    }
  

    [self.navigationController pushViewController:cvc animated:YES];
}
-(void)accerptTapped:(id)sender
{
}
-(void)addTapped:(UIButton *)sender
{   
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
@end

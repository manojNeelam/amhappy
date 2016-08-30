//
//  VoterListViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 18/02/15.
//
//

#import "VoterListViewController.h"
#import "ModelClass.h"
#import "HobbyCell.h"
#import "UIImageView+WebCache.h"
#import "OtherUserProfileViewController.h"
#import "RegistrationViewController.h"

@interface VoterListViewController ()

@end

@implementation VoterListViewController
{
    ModelClass *mc;
    NSMutableArray *voterArray;
    NSMutableArray *searchArray;
    BOOL isSearching;
    UIToolbar *mytoolbar1;
    
    NSArray *indexTitles;
    
    NSMutableArray *sectionTitleArray;
    NSMutableDictionary *keyDict;
    
    
    NSMutableArray *searchSectionTitleArray;
    NSMutableDictionary *searchKeyDict;
}
@synthesize lblTitle,lblsubTitle,eventID,isLocation,dataDict,txtSearch;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    voterArray =[[ NSMutableArray alloc] init];
    searchArray =[[ NSMutableArray alloc] init];
    isSearching=NO;
    
    searchSectionTitleArray =[[NSMutableArray alloc] init];
    sectionTitleArray =[[NSMutableArray alloc] init];
    keyDict =[[NSMutableDictionary alloc] init];
    searchKeyDict =[[NSMutableDictionary alloc] init];    
    
    indexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
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
    if(DELEGATE.connectedToNetwork)
    {
        
         /*
         id: 4,
         date: 1445472000,
         date_vote: 0
         */
        
        if(self.isLocation)
        {
            /*
             id: 5,
             location: "Ahmedabad, Gujarat, India",
             latitude: "23.022505",
             longitude: "72.571365",
             location_vote: 0
             */
            self.lblTitle.text =[self.dataDict valueForKey:@"location"];
            self.lblsubTitle.text =[NSString stringWithFormat:@"(%@ Votes)",[self.dataDict valueForKey:@"location_vote"]];
            
            [mc voterList:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Type:@"L" Voteid:[self.dataDict valueForKey:@"id"] Sel:@selector(responseGetVoterList:)];
        }
        else
        {

            self.lblTitle.text =[self getDate2:[self.dataDict valueForKey:@"date"]];
            self.lblsubTitle.text =[NSString stringWithFormat:@"(%@ %@)",[self.dataDict valueForKey:@"date_vote"],[localization localizedStringForKey:@"Votes"]];
            
            [mc voterList:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Type:@"D" Voteid:[self.dataDict valueForKey:@"id"] Sel:@selector(responseGetVoterList:)];
        }
       
    }
}


-(NSString *)getDate2:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    //  NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",formattedDate];
}
-(void)responseGetVoterList:(NSDictionary *)results
{
     NSLog(@"result is %@",results);
    
   if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
     {
         
         [voterArray removeAllObjects];
         [keyDict removeAllObjects];
         [sectionTitleArray removeAllObjects];
         
         [searchKeyDict removeAllObjects];
         [searchSectionTitleArray removeAllObjects];
         
         [voterArray addObjectsFromArray:[results valueForKey:@"User"]];
         
         [self getMainArray];
       
     }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

    }
}
-(void)getMainArray
{
    for(NSString *str in indexTitles)
    {
        NSArray *array =[[NSArray alloc] initWithArray:[self getArrayfor:str]];
        [keyDict setObject:array forKey:str];
    }
    
    [sectionTitleArray addObjectsFromArray:[[keyDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    if(sectionTitleArray.count>0)
    {
        [self.tableview reloadData];
    }
    
}
-(NSArray *)getArrayfor:(NSString *)startWord
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", startWord];
    NSArray *result = [voterArray filteredArrayUsingPredicate:pred];
    
    NSLog(@"result is %@",result);
    return result;
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
        [self.tableview reloadData];
    }
}
- (void)filterListForSearchText:(NSString *)searchText
{
    [searchArray removeAllObjects];
    [searchKeyDict removeAllObjects];
    [searchSectionTitleArray removeAllObjects];
    
    if(voterArray.count>0)
    {
        for(int i=0;i<voterArray.count;i++)
        {
            NSRange nameRange;
            
            nameRange = [[[voterArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (nameRange.location != NSNotFound) {
                [searchArray addObject:[voterArray objectAtIndex:i]];
            }
            
            
        }
    }
    
    if(searchArray.count>0)
    {
        [self getSearchArray];
    }
    else
    {
        [self.tableview reloadData];
    }
    
    
}

-(void)getSearchArray
{
    for(NSString *str in indexTitles)
    {
        NSArray *array =[[NSArray alloc] initWithArray:[self getSearchArrayfor:str]];
        [searchKeyDict setObject:array forKey:str];
    }
    
    [searchSectionTitleArray addObjectsFromArray:[[searchKeyDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    if(searchSectionTitleArray.count>0)
    {
        [self.tableview reloadData];
    }
    
}

-(NSArray *)getSearchArrayfor:(NSString *)startWord
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", startWord];
    NSArray *result = [searchArray filteredArrayUsingPredicate:pred];
    
    NSLog(@"result is %@",result);
    return result;
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
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:view.superview.tag];
        NSMutableArray *dataArray = [[NSMutableArray alloc] initWithArray:[searchKeyDict objectForKey:sectionTitle]];
        
        if([[[dataArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
        }
    }
    else
    {
        NSString *sectionTitle = [sectionTitleArray objectAtIndex:view.superview.tag];
        NSMutableArray *dataArray = [[NSMutableArray alloc] initWithArray:[keyDict objectForKey:sectionTitle]];
        
        if([[[dataArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
        }
        
    }
    
  /*  if(isSearching)
    {
        if([[[searchArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
        }
    }
    else
    {
        if([[[voterArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[voterArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:2];
        }
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
    
   
    
    
    HobbyCell *cell = (HobbyCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HobbyCell" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
    }
    [cell.btnCheck setHidden:YES];
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFriendsTap:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = YES;
    cell.imgHobby.tag =indexPath.row;
    cell.imgHobby.superview.tag =indexPath.section;
    [cell.imgHobby addGestureRecognizer:tapGestureRecognizer];
    
    cell.imgHobby.layer.masksToBounds = YES;
    cell.imgHobby.layer.cornerRadius = 25.0;
    
    
    if(isSearching)
    {
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [searchKeyDict objectForKey:sectionTitle];
        
        cell.lblHobbyName.text =[[dataArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        if([[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgHobby sd_setImageWithURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
        
        dataArray =nil;
        sectionTitle=nil;
        
    }
    else
    {
        NSString *sectionTitle = [sectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [keyDict objectForKey:sectionTitle];
        cell.lblHobbyName.text =[[dataArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        if([[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgHobby sd_setImageWithURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
        
        dataArray =nil;
        sectionTitle=nil;
        
    }
    
    
 /*   if(isSearching)
    {
        cell.lblHobbyName.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgHobby sd_setImageWithURL:[NSURL URLWithString:[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
    }
    else
    {
        cell.lblHobbyName.text =[[voterArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        if([[[voterArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgHobby sd_setImageWithURL:[NSURL URLWithString:[[voterArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
    }*/
    
   
    
    
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
    
    
    NSString *userID;
    
    if(isSearching)
    {
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [searchKeyDict objectForKey:sectionTitle];
        userID=[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
        
    }
    else
    {
        NSString *sectionTitle = [sectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [keyDict objectForKey:sectionTitle];
        userID=[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
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
        
        [otherVC setUserId:[NSString stringWithFormat:@"%@",userID]];
        
        [self.navigationController pushViewController:otherVC animated:YES];
        
    }
   /* OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
    if(isSearching)
    {
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [searchKeyDict objectForKey:sectionTitle];
        otherVC.userId=[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
        
    }
    else
    {
        NSString *sectionTitle = [sectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [keyDict objectForKey:sectionTitle];
        otherVC.userId=[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
    }
   
    [self.navigationController pushViewController:otherVC animated:YES];*/
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
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

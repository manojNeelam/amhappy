//
//  GroupListViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 01/09/15.
//
//

#import "GroupListViewController.h"
#import "CreateGroupViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "FreindsIngroupViewController.h"

@interface GroupListViewController ()

@end

@implementation GroupListViewController
{
    NSMutableArray *groupArray;
    NSMutableArray *searchArray;
    BOOL isSearching;
    
    UIToolbar *mytoolbar1;
    ModelClass *mc;
    NSArray *indexTitles;
    
    NSMutableArray *sectionTitleArray;
    NSMutableDictionary *keyDict;
    
    
    NSMutableArray *searchSectionTitleArray;
    NSMutableDictionary *searchKeyDict;
    
    NSIndexPath *deleteIndexPath;




}

@synthesize lblTitle,txtSearch,tblGroup,isbtnAddHide;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (isbtnAddHide)
    {
        
        [self.btnAdd setHidden:YES];
    }
    
    
    mc =[[ModelClass alloc] init];
    mc.delegate=self;
    
    groupArray =[[NSMutableArray alloc] init];
    searchArray =[[NSMutableArray alloc] init];
    searchSectionTitleArray =[[NSMutableArray alloc] init];
    sectionTitleArray =[[NSMutableArray alloc] init];
    keyDict =[[NSMutableDictionary alloc] init];
    searchKeyDict =[[NSMutableDictionary alloc] init];



    
    indexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"groupCreated" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(groupCreated)
                                                 name:@"groupCreated"
                                               object:nil];
    
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
    
    if(DELEGATE.connectedToNetwork)
    {
        [mc myGroups:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responseGetMyGroup:)];
    }
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.txtSearch setText:@""];

    if(DELEGATE.isGroupUpdated)
    {
        DELEGATE.isGroupUpdated = NO;
    
        [self viewDidLoad];
      
    }
    
    
    [self localize];
}



-(void)localize
{
    self.lblTitle.text =[localization localizedStringForKey:@"Group"];
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];

    /*self.lblEvent.text =[localization localizedStringForKey:@"Event Notification"];
    self.lblComment.text =[localization localizedStringForKey:@"Comment Notification"];
    self.lblAll.text =[localization localizedStringForKey:@"All Notification"];
    [self.btnSave setTitle:[localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];*/
}
-(void)groupCreated
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc myGroups:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responseGetMyGroup:)];
    }
}
-(void)donePressed
{
    [self.view endEditing:YES];
    
}
-(void)responseGetMyGroup:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [groupArray removeAllObjects];
        [keyDict removeAllObjects];
        [sectionTitleArray removeAllObjects];
        
        [searchKeyDict removeAllObjects];
        [searchSectionTitleArray removeAllObjects];
        
        [groupArray addObjectsFromArray:[results valueForKey:@"Group"]];
        
        [self getMainArray];
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
        [self.tblGroup reloadData];
    }

}

-(NSArray *)getArrayfor:(NSString *)startWord
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", startWord];
    NSArray *result = [groupArray filteredArrayUsingPredicate:pred];
    
    NSLog(@"result is %@",result);
    return result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
   /* for(UIView *view in [tableView subviews])
    {
        if([[[view class] description] isEqualToString:@"UITableViewIndex"])
        {            
            [view setBackgroundColor:[UIColor colorWithRed:223.0/255.0 green:128.0/225.0 blue:0/255.0 alpha:1.0]];
        }
    }*/
    
    FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
    }
    cell.imgUser.layer.masksToBounds = YES;
    cell.imgUser.layer.cornerRadius = 25.0;
    
    [cell.btnInvite setHidden:YES];
    [cell.btnAccept setHidden:YES];
    [cell.btnAdd setHidden:YES];
    
    /*
     id: 1,
     name: "apitest",
     image: "http://192.168.1.100/apps/amhappy/web/img/uploads/group/14400727631415714380.jpg",
     thumb_image: "http://192.168.1.100/apps/amhappy/web/img/uploads/group/9589cbaa802ba59d562066fc2e98e102.jpg"
     */
    
   
    
    if(isSearching)
    {
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [searchKeyDict objectForKey:sectionTitle];
        
        if([[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]] placeholderImage:[UIImage imageNamed:@"iconBlack"]];
        }
        cell.lblName.text =[[dataArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        dataArray =nil;
        sectionTitle=nil;
        
    }
    else
    {
        NSString *sectionTitle = [sectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [keyDict objectForKey:sectionTitle];
        if([[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]] placeholderImage:[UIImage imageNamed:@"iconBlack"]];
        }
        cell.lblName.text =[[dataArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        dataArray =nil;
        sectionTitle=nil;
        
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;

    
}



#pragma mark ----------- Delete Group Functionality -------------

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[localization localizedStringForKey:@"Delete"]  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              
                                              [self deleteGroup:indexPath];
                                              
                                          }];
    
    return @[deleteAction];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


-(void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Delete");
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}



#pragma mark ------------- Delete User From Group ---------------

-(void)deleteGroup:(NSIndexPath *)indexPath
{
    
    NSLog(@"%@",indexPath);
    
    deleteIndexPath = [[NSIndexPath alloc]init];
    deleteIndexPath = indexPath;
    
    
    if ([DELEGATE connectedToNetwork])
    {
        
        if(isSearching)
        {
            [mc deleteGroup:[USER_DEFAULTS valueForKey:@"userid"] groupid:[[[searchKeyDict objectForKey:[searchSectionTitleArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]valueForKey:@"id"] Sel:@selector(responseDeleteGroup:)];
            
            
        }
        else
        {
            
            [mc deleteGroup:[USER_DEFAULTS valueForKey:@"userid"] groupid:[[[keyDict objectForKey:[sectionTitleArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]valueForKey:@"id"] Sel:@selector(responseDeleteGroup:)];
            
        }
        
        
    }
    
//      
//    if(isSearching)
//    {
//        
//        //**************** First Delete From Search Dictionary *****
//        
//        
//       // [deletedUsers addObject:[[[searchKeyDict objectForKey:[searchSectionTitleArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]valueForKey:@"id"]];
//        
//        NSString *dataToDelete = [[[searchKeyDict objectForKey:[searchSectionTitleArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]valueForKey:@"id"];
//        
//        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:[searchKeyDict objectForKey:[searchSectionTitleArray objectAtIndex:indexPath.section]]];
//        
//        [tempArray removeObjectAtIndex:indexPath.row];
//        
//        [searchKeyDict setValue:tempArray forKey:[searchSectionTitleArray objectAtIndex:indexPath.section]];
//        
//        
//        
//        
//        //********************** Now Delete From Main Dictionary as well
//        
//        
//        NSMutableArray *tArray = [[NSMutableArray alloc]initWithArray:[keyDict objectForKey:[searchSectionTitleArray objectAtIndex:indexPath.section]]];
//        
//        // NSLog(@"%@",tArray);
//        
//        //************** From Here Get id of user to Delete From Friend List
//        
//        for (int i = 0; i< [tArray count]; i++)
//        {
//            
//            if ([[[tArray objectAtIndex:i]valueForKey:@"id"]isEqualToNumber:[NSNumber numberWithInt:dataToDelete.intValue]])
//            {
//                
//                [tArray removeObjectAtIndex:i];
//                
//            }
//            
//        }
//        
//        
//        //NSLog(@"%@",tArray);
//        
//        [keyDict setValue:tempArray forKey:[sectionTitleArray objectAtIndex:indexPath.section]];
//        
//        
//        //NSLog(@"%@",keyDict);
//        
//        
//    }
//    else
//    {
//        
//        //************ First Delete From Main Dictionary *****
//        
//        //NSLog(@"%@",[[[keyDict objectForKey:[sectionTitleArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]valueForKey:@"id"]);
//        
//        //[deletedUsers addObject:[[[keyDict objectForKey:[sectionTitleArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]valueForKey:@"id"]];
//        
//        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:[keyDict objectForKey:[sectionTitleArray objectAtIndex:indexPath.section]]];
//        
//        //************** From Here Get id of user to Delete From Friend List
//        NSString *dataToDelete = [[tempArray objectAtIndex:indexPath.row]valueForKey:@"id"];
//        
//        
//        [tempArray removeObjectAtIndex:indexPath.row];
//        
//        
//        [keyDict setValue:tempArray forKey:[sectionTitleArray objectAtIndex:indexPath.section]];
//        
//        //****************** Now Delete From Search Dictionary As Well *****
//        
//        
//        for (int i = 0; i<[groupArray count]; i++)
//        {
//            
//            if ([[[groupArray objectAtIndex:i]valueForKey:@"id"]isEqualToNumber:[NSNumber numberWithInt:dataToDelete.intValue]])
//            {
//                
//                [groupArray removeObjectAtIndex:i];
//                
//            }
//            
//        }
//        
//    }
//    
//    [self.tblGroup reloadData];
    
  
}


-(void)responseDeleteGroup:(NSDictionary *)dict
{
    NSLog(@"%@",dict);
    
    if ([[NSString stringWithFormat:@"%@",[dict valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
   
        [self viewDidLoad];
        
    }
    else
    {
        [DELEGATE showalert:self Message:[dict valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
  
}











- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    FreindsIngroupViewController *friendVC =[[FreindsIngroupViewController alloc] initWithNibName:@"FreindsIngroupViewController" bundle:nil];
    
    
    if(isSearching)
    {
   
        NSString *sectionTitle = [[NSString alloc]initWithString:[searchSectionTitleArray objectAtIndex:indexPath.section]];
        NSArray *dataArray = [[NSArray alloc]initWithArray:[searchKeyDict objectForKey:sectionTitle]];
        friendVC.groupId=[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
        friendVC.groupName=[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"name"]];
        
          friendVC.groupDetails = [[NSMutableDictionary alloc]initWithDictionary:[dataArray objectAtIndex:indexPath.row]];
        
       // NSLog(@"userid is %@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]);

        dataArray =nil;
        sectionTitle=nil;
    }
    else
    {
        NSString *sectionTitle = [[NSString alloc]initWithString:[sectionTitleArray objectAtIndex:indexPath.section]];
        NSArray *dataArray = [[NSArray alloc]initWithArray:[keyDict objectForKey:sectionTitle]];
        friendVC.groupId=[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]];
    
        friendVC.groupName=[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"name"]];
      //  NSLog(@"userid is %@",[[dataArray objectAtIndex:indexPath.row] valueForKey:@"id"]);
        
        friendVC.groupDetails = [[NSMutableDictionary alloc]initWithDictionary:[dataArray objectAtIndex:indexPath.row]];

        dataArray =nil;
        sectionTitle=nil;
    }
    
    isSearching =NO;
    [self.tblGroup reloadData];
    
    
    [self.navigationController pushViewController:friendVC animated:YES];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 55;
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
        [self.tblGroup reloadData];
    }
}
- (void)filterListForSearchText:(NSString *)searchText
{
    [searchArray removeAllObjects];
    [searchKeyDict removeAllObjects];
    [searchSectionTitleArray removeAllObjects];
    
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
    
    if(searchArray.count>0)
    {
        [self getSearchArray];
    }
    else
    {
        [self.tblGroup reloadData];
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
        [self.tblGroup reloadData];
    }
    
}

-(NSArray *)getSearchArrayfor:(NSString *)startWord
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", startWord];
    NSArray *result = [searchArray filteredArrayUsingPredicate:pred];
    
    NSLog(@"result is %@",result);
    return result;
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
- (IBAction)addGroupTapped:(id)sender
{
    CreateGroupViewController *createVC =[[CreateGroupViewController alloc] initWithNibName:@"CreateGroupViewController" bundle:nil];
    [self.navigationController pushViewController:createVC animated:YES];
}
@end

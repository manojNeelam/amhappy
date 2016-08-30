//
//  FreindsIngroupViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 03/09/15.
//
//

#import "FreindsIngroupViewController.h"
#import "FriendCell.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "ModelClass.h"
#import "OtherUserProfileViewController.h"
#import "EditGroupViewController.h"
#import "SBJSON.h"

@interface FreindsIngroupViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation FreindsIngroupViewController
{
    NSMutableArray *friendsArray;
    ModelClass *mc;
    
    NSMutableArray *mainDisplayArray;
    
    NSMutableArray *searchArray;
    BOOL isSearching;
    UIToolbar *mytoolbar1;
    
    NSMutableArray *sectionTitleArray;
    NSMutableDictionary *keyDict;
    
    NSArray *indexTitles;

    NSMutableArray *searchSectionTitleArray;
    NSMutableDictionary *searchKeyDict;
    
    UIImagePickerController *pickerController;
    
    BOOL isImageChanged;
    
    UIImage *updatedImage;
    
    NSMutableArray *deletedUsers;

}
@synthesize lblTitle,tblFriends,groupId,groupName,groupDetails;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.btnGroupImage setContentMode:UIViewContentModeScaleAspectFill];
    //[self.btnGroupImage setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
    //[self.btnGroupImage setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
    
    
    
    [self.lblTitle setText:[localization localizedStringForKey:@"Group detail"]];
    
    [self.btnsave setTitle:[localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];
    
     [self.btnAddParticiapnts setTitle:[localization localizedStringForKey:@"Add participant"] forState:UIControlStateNormal];
    
    
    
    
    deletedUsers = [[NSMutableArray alloc]init];

    //NSLog(@"%@",groupDetails);
    
    [self.btnGroupImage.layer setCornerRadius:self.btnGroupImage.frame.size.width/2];
    [self.btnGroupImage setClipsToBounds:YES];
    
    //self.btnGroupImage.contentMode = UIViewContentModeScaleToFill;
 
    if(groupDetails)
    {
        
        [self.btnGroupImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[groupDetails valueForKey:@"image"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"groupPlaceHolder"]];
        
        [self.txtfldGroupName setText:[NSString stringWithFormat:@"%@",[groupDetails valueForKey:@"name"]]];
    
    }
    
    
    isImageChanged=NO;
    
    friendsArray =[[NSMutableArray alloc] init];
    mc =[[ModelClass alloc] init];
    mc.delegate=self;
    mainDisplayArray =[[NSMutableArray alloc] init];
    searchArray =[[NSMutableArray alloc] init];
    
    searchSectionTitleArray =[[NSMutableArray alloc] init];
    sectionTitleArray =[[NSMutableArray alloc] init];
    keyDict =[[NSMutableDictionary alloc] init];
    searchKeyDict =[[NSMutableDictionary alloc] init];
    

    
    indexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];


    
    //self.lblTitle.text =[NSString stringWithFormat:@"%@",self.groupName];
    
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"groupUpdated" object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(groupUpdated)
     name:@"groupUpdated"
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
    self.txtfldGroupName.inputAccessoryView =mytoolbar1;
    
    
    
    [self callApi];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
}
-(void)localize
{
   // self.lblTitle.text =[localization localizedStringForKey:@"Friends"];
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];
    
    
    /*self.lblEvent.text =[localization localizedStringForKey:@"Event Notification"];
     self.lblComment.text =[localization localizedStringForKey:@"Comment Notification"];
     self.lblAll.text =[localization localizedStringForKey:@"All Notification"];
     [self.btnSave setTitle:[localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];*/
}
-(void)donePressed
{
    [self.view endEditing:YES];
}
-(void)callApi
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc getMemberOfGroup:[USER_DEFAULTS valueForKey:@"userid"] Groupid:self.groupId Sel:@selector(responseGetFriendsOfGroup:)];
    }
}
-(void)groupUpdated
{
      [self callApi];
}

-(void)responseGetFriendsOfGroup:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [friendsArray removeAllObjects];
       
        [keyDict removeAllObjects];
        [sectionTitleArray removeAllObjects];
        
        [searchKeyDict removeAllObjects];
        [searchSectionTitleArray removeAllObjects];
        
        [friendsArray addObjectsFromArray:[results valueForKey:@"Member"]];
        
        
        
        [self getMainArray];
      
        if(friendsArray.count==0)
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No friends found"] AlertFlag:1 ButtonFlag:1];
        }
        
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No friends found"] AlertFlag:1 ButtonFlag:1];
        
    }
}
-(NSArray *)getArrayfor:(NSString *)startWord
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", startWord];
    NSArray *result = [friendsArray filteredArrayUsingPredicate:pred];
    
    NSLog(@"result is %@",result);
    return result;
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
        [self.tblFriends reloadData];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        
        NSLog(@"%@",searchSectionTitleArray);
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:section];
        
         NSLog(@"%@",sectionTitle);
        
        NSArray *sectionAnimals = [searchKeyDict objectForKey:sectionTitle];
        
        NSLog(@"%@",sectionAnimals);
        
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
    
    if(isSearching)
    {
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [searchKeyDict objectForKey:sectionTitle];
        
        if([[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
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
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
        cell.lblName.text =[[dataArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        dataArray =nil;
        sectionTitle=nil;
        
    }
  
  
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
    
    
}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[localization localizedStringForKey:@"Remove"]  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                   
                                              [self deleteUser:indexPath];
                                              
                                          }];
    
    return @[deleteAction];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


-(void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"delete");
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}



#pragma mark ------------- Delete User From Group ---------------

-(void)deleteUser:(NSIndexPath *)indexPath
{

    NSLog(@"%@",indexPath);
    
    if(isSearching)
    {
        
        //**************** First Delete From Search Dictionary *****

 
        [deletedUsers addObject:[[[searchKeyDict objectForKey:[searchSectionTitleArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]valueForKey:@"id"]];
        
        NSString *dataToDelete = [[[searchKeyDict objectForKey:[searchSectionTitleArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]valueForKey:@"id"];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:[searchKeyDict objectForKey:[searchSectionTitleArray objectAtIndex:indexPath.section]]];
      
        [tempArray removeObjectAtIndex:indexPath.row];
    
        [searchKeyDict setValue:tempArray forKey:[searchSectionTitleArray objectAtIndex:indexPath.section]];
        
        
        
    
        //********************** Now Delete From Main Dictionary as well
    
        
        NSMutableArray *tArray = [[NSMutableArray alloc]initWithArray:[keyDict objectForKey:[searchSectionTitleArray objectAtIndex:indexPath.section]]];
        
       // NSLog(@"%@",tArray);
        
        //************** From Here Get id of user to Delete From Friend List
       
        for (int i = 0; i< [tArray count]; i++)
        {
            
            if ([[[tArray objectAtIndex:i]valueForKey:@"id"]isEqualToNumber:[NSNumber numberWithInt:dataToDelete.intValue]])
            {
                
                [tArray removeObjectAtIndex:i];
                
            }
            
        }
    
        
        //NSLog(@"%@",tArray);
        
        [keyDict setValue:tempArray forKey:[sectionTitleArray objectAtIndex:indexPath.section]];
        
        
         //NSLog(@"%@",keyDict);

        
    }
    else
    {
        
        //************ First Delete From Main Dictionary *****
        
        //NSLog(@"%@",[[[keyDict objectForKey:[sectionTitleArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]valueForKey:@"id"]);
        
        [deletedUsers addObject:[[[keyDict objectForKey:[sectionTitleArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row]valueForKey:@"id"]];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:[keyDict objectForKey:[sectionTitleArray objectAtIndex:indexPath.section]]];
    
        //************** From Here Get id of user to Delete From Friend List
        NSString *dataToDelete = [[tempArray objectAtIndex:indexPath.row]valueForKey:@"id"];
        
        
        [tempArray removeObjectAtIndex:indexPath.row];
        
    
        [keyDict setValue:tempArray forKey:[sectionTitleArray objectAtIndex:indexPath.section]];
    
        //****************** Now Delete From Search Dictionary As Well *****
        
    
        for (int i = 0; i<[friendsArray count]; i++)
        {
            
            if ([[[friendsArray objectAtIndex:i]valueForKey:@"id"]isEqualToNumber:[NSNumber numberWithInt:dataToDelete.intValue]])
            {
                
                [friendsArray removeObjectAtIndex:i];
          
            }
          
        }
     
    }
    
    [self.tblFriends reloadData];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];

    
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
    
    
    
    [self.navigationController pushViewController:otherVC animated:YES];
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
        [self.tblFriends reloadData];
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
        [self.tblFriends reloadData];
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
        [self.tblFriends reloadData];
    }
    
}

-(NSArray *)getSearchArrayfor:(NSString *)startWord
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", startWord];
    NSArray *result = [searchArray filteredArrayUsingPredicate:pred];
    
    NSLog(@"result is %@",result);
    return result;
}


- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)ok1BtnTapped:(id)sender
{
    [[self.view viewWithTag:123] removeFromSuperview];
}
-(void)ok2BtnTapped:(id)sender
{
    [[self.view viewWithTag:123] removeFromSuperview];
}
-(void)cancelBtnTapped:(id)sender
{
    [[self.view viewWithTag:123] removeFromSuperview];    
}
- (IBAction)addTapped:(id)sender
{
    [self.view endEditing:YES];
    EditGroupViewController *editVC =[[EditGroupViewController alloc] initWithNibName:@"EditGroupViewController" bundle:nil];
    
    editVC.groupID =[NSString stringWithFormat:@"%@",self.groupId];
    editVC.groupName =[NSString stringWithFormat:@"%@",self.groupName];
    
    [self.navigationController pushViewController:editVC animated:YES];
}


#pragma mark ------------- Validations --------------

-(BOOL)validation
{

    if ([self.txtfldGroupName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
       
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter group name"] AlertFlag:1 ButtonFlag:1];
     
        return NO;
      
    }
    else
    {
        return YES;
    }
  
}


#pragma mark ------------- click Events ---------------

- (IBAction)clickGroupImage:(id)sender
{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
    [alert show];
}

- (IBAction)clickSave:(id)sender
{
    
    
    if ([DELEGATE connectedToNetwork])
    {
        
        if ([self validation])
        {
   
            if(isImageChanged)
            {
                
                if ([deletedUsers count]>0)
                {
                    
                    NSError *error;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deletedUsers options:NSJSONWritingPrettyPrinted error:&error];
                    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                    
                    [mc editGroup:[USER_DEFAULTS valueForKey:@"userid"] groupid:self.groupId name:self.txtfldGroupName.text image:updatedImage member_added:nil member_remove:resultAsString Sel:@selector(ResponseEditGroup:)];
                    
                }
                else
                {
                    
                    [mc editGroup:[USER_DEFAULTS valueForKey:@"userid"] groupid:self.groupId name:self.txtfldGroupName.text image:updatedImage member_added:nil member_remove:nil Sel:@selector(ResponseEditGroup:)];
                   
                }
                
                
                

            }
            else
            {
                
                if ([deletedUsers count]>0)
                {
                    
                    
                    
                    NSError *error;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deletedUsers options:NSJSONWritingPrettyPrinted error:&error];
                    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    
                     [mc editGroup:[USER_DEFAULTS valueForKey:@"userid"] groupid:self.groupId name:self.txtfldGroupName.text image:nil member_added:nil member_remove:resultAsString Sel:@selector(ResponseEditGroup:)];
                    
                }
                else
                {
                    
                       [mc editGroup:[USER_DEFAULTS valueForKey:@"userid"] groupid:self.groupId name:self.txtfldGroupName.text image:nil member_added:nil member_remove:nil Sel:@selector(ResponseEditGroup:)];
                    
                }
              
                
            }
        
        }
        
        
    }
   
    
}


#pragma mark ---------- Reponse Edit Group ------


-(void)ResponseEditGroup:(NSDictionary *)dict
{
    
    NSLog(@"%@",dict);
    
    if ([[NSString stringWithFormat:@"%@",[dict valueForKey:@"code"]] isEqualToString:@"200"])
    {
    
        
        DELEGATE.isGroupUpdated = YES;
        
        
        [self.navigationController popViewControllerAnimated:YES];
        
        
        
    }
    else
    {
        [DELEGATE showalert:self Message:[dict valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }

    
}




#pragma mark ----------- AlertView Delegate --------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 2)
    {
        pickerController = [[UIImagePickerController alloc]init];
        pickerController.delegate = self;
        pickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        pickerController.allowsEditing = YES;
        
        // [self presentModalViewController:pickerController animated:YES];
        [self presentViewController:pickerController animated:YES completion:nil];
    }
    else if(buttonIndex == 1)
    {
        
        pickerController = [[UIImagePickerController alloc]init];
        pickerController.delegate = self;
        pickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
        pickerController.allowsEditing = YES;
        //  [self presentModalViewController:pickerController animated:YES];
        [self presentViewController:pickerController animated:YES completion:nil];
        
    }
    
}

#pragma mark -------- UIImagePicker Delegate ------------

- (void)imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    
    if(image)
    {
        
        updatedImage = [[UIImage alloc]init];
        
        updatedImage = [mc scaleAndRotateImage:image];
        
     
        [self.btnGroupImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.btnGroupImage setClipsToBounds:YES];
        
        [self.btnGroupImage setBackgroundImage:updatedImage forState:UIControlStateNormal];
    
        isImageChanged = YES;
        
        
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark ------- Textfield Delegate -----

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==self.txtfldGroupName)
    {
        if([self.txtfldGroupName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldGroupName setText:@""];
            
        }
        
    }
   
}





@end

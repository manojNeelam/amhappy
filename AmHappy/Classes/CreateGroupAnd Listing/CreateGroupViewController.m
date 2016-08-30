//
//  CreateGroupViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 01/09/15.
//
//

#import "CreateGroupViewController.h"
#import "ModelClass.h"
#import "FriendCell.h"
#import "UIImageView+WebCache.h"

@interface CreateGroupViewController ()

@end

@implementation CreateGroupViewController
{
    NSMutableArray *friendArray;
    NSMutableArray *searchArray;
    BOOL isSearching;    
    UIToolbar *mytoolbar1;
    ModelClass *mc;
    BOOL isImageChanged;
    UIImagePickerController *pickerController;
    
    
    NSMutableArray *sectionTitleArray;
    NSMutableDictionary *keyDict;
    
    NSArray *indexTitles;
    
    NSMutableArray *searchSectionTitleArray;
    NSMutableDictionary *searchKeyDict;
}

@synthesize lblTitle,lblInstruction,txtSearch,txtName,tblFriend,imgBg;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.txtName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    
    [self.btnSave setTitle:[localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];
    
    isImageChanged=NO;
    
    
    mc =[[ModelClass alloc] init];
    mc.delegate=self;
    
    pickerController = [[UIImagePickerController alloc]
                        init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    
    friendArray =[[NSMutableArray alloc] init];
    searchArray =[[NSMutableArray alloc] init];
    
    searchSectionTitleArray =[[NSMutableArray alloc] init];
    sectionTitleArray =[[NSMutableArray alloc] init];
    keyDict =[[NSMutableDictionary alloc] init];
    searchKeyDict =[[NSMutableDictionary alloc] init];
    
    
    
    
    indexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    [self callApi];
    
    self.imgProfile.layer.masksToBounds=YES;
    self.imgProfile.layer.cornerRadius=50.0;
    
    [self.scrollview setContentSize:CGSizeMake(self.view.bounds.size.width, 700)];
    
    mytoolbar1 = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    mytoolbar1.barStyle = UIBarStyleBlackOpaque;
    
    if(IS_Ipad)
    {
        self.imgBg.frame =CGRectMake(self.imgProfile.frame.origin.x+self.imgProfile.frame.size.width+20, self.imgBg.frame.origin.y, 300, self.imgBg.frame.size.height);
        
        self.txtName.frame =CGRectMake(self.imgProfile.frame.origin.x+self.imgProfile.frame.size.width+25, self.txtName.frame.origin.y, 290, self.txtName.frame.size.height);
    }
  /*  else
    {
        self.imgBg.frame =CGRectMake(self.imgProfile.frame.origin.x+self.imgProfile.frame.size.width+20, self.imgBg.frame.origin.y, self.imgBg.frame.size.width, self.imgBg.frame.size.height);
        
        self.txtName.frame =CGRectMake(self.imgProfile.frame.origin.x+self.imgProfile.frame.size.width+25, self.txtName.frame.origin.y, self.txtName.frame.size.width, self.txtName.frame.size.height);
    }*/
    
    
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
    self.txtName.inputAccessoryView=mytoolbar1;
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
}
-(void)localize
{
    self.lblTitle.text =[localization localizedStringForKey:@"Create Group"];
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];
    [self.txtName setPlaceholder:[localization localizedStringForKey:@"Group name"]];

    
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
        [mc getFriends:[USER_DEFAULTS valueForKey:@"userid"] Start:@"0" Limit:LimitComment Sel:@selector(responseGetFriends:)];        
    }
}
-(void)responseGetFriends:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        DELEGATE.isAccepted =NO;
        [friendArray removeAllObjects];
        
        [keyDict removeAllObjects];
        [sectionTitleArray removeAllObjects];
        
        [searchKeyDict removeAllObjects];
        [searchSectionTitleArray removeAllObjects];
        
        [friendArray addObjectsFromArray:[results valueForKey:@"Friend"]];
        [self getMainArray];
            if(friendArray.count==0)
            {
                [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
            }
        [self.tblFriend reloadData];
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
    }
}
-(NSArray *)getArrayfor:(NSString *)startWord
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", startWord];
    NSArray *result = [friendArray filteredArrayUsingPredicate:pred];
    
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
        [self.tblFriend reloadData];
    }
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}


- (void)didReceiveMemoryWarning
{
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
    
    
    FriendCellNew *cell = (FriendCellNew *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCellNew" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
    }
    cell.imgUser.layer.masksToBounds = YES;
    cell.imgUser.layer.cornerRadius = 25.0;
    
    cell.delegate=self;
    
    [cell.btnAdd setTag:indexPath.row];
    cell.btnAdd.superview.tag = indexPath.section;
    
    if(isSearching)
    {
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:indexPath.section];
        NSArray *dataArray = [searchKeyDict objectForKey:sectionTitle];
        
        if([[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
        cell.lblName.text =[[dataArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        
        if([[[dataArray objectAtIndex:indexPath.row] valueForKey:@"message_count"] isEqualToString:@"0"])
        {
            [cell.btnAdd setImage:[UIImage imageNamed:@"fDeselected.png"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.btnAdd setImage:[UIImage imageNamed:@"fSelected.png"] forState:UIControlStateNormal];
        }
        
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
        
        if([[[dataArray objectAtIndex:indexPath.row] valueForKey:@"message_count"] isEqualToString:@"0"])
        {
            [cell.btnAdd setImage:[UIImage imageNamed:@"fDeselected.png"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.btnAdd setImage:[UIImage imageNamed:@"fSelected.png"] forState:UIControlStateNormal];
        }
        
        dataArray =nil;
        sectionTitle=nil;
        
    }
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
    
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    isSearching =NO;
    
    
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
        [self.tblFriend reloadData];
    }
}
- (void)filterListForSearchText:(NSString *)searchText
{
    [searchArray removeAllObjects];
    [searchKeyDict removeAllObjects];
    [searchSectionTitleArray removeAllObjects];
    
    if(friendArray.count>0)
    {
        for(int i=0;i<friendArray.count;i++)
        {
            NSRange nameRange;
            
            nameRange = [[[friendArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (nameRange.location != NSNotFound) {
                [searchArray addObject:[friendArray objectAtIndex:i]];
            }
            
            
        }
    }
    
    if(searchArray.count>0)
    {
        [self getSearchArray];
    }
    else
    {
        [self.tblFriend reloadData];
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
        [self.tblFriend reloadData];
    }
    
}

-(NSArray *)getSearchArrayfor:(NSString *)startWord
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", startWord];
    NSArray *result = [searchArray filteredArrayUsingPredicate:pred];
    
    NSLog(@"result is %@",result);
    return result;
}


-(void)changeObject:(NSString *)userid Sender:(UIButton *)sender
{
    /* for(int i=0;i<friendArray.count;i++)
     {
     NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[friendArray objectAtIndex:i]];
     if([[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]] isEqualToString:userid])
     {
     if([[dict valueForKey:@"message_count"] isEqualToString:@"0"])
     {
     [dict setValue:@"1" forKey:@"message_count"];
     }
     else
     {
     [dict setValue:@"0" forKey:@"message_count"];
     }
     
     [friendArray replaceObjectAtIndex:i withObject:dict];
     break;
     }
     }*/
    
    NSString *sectionTitle = [sectionTitleArray objectAtIndex:sender.superview.tag];
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithArray:[keyDict objectForKey:sectionTitle]];
    
    for(int i=0;i<dataArray.count;i++)
    {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[dataArray objectAtIndex:i]];
        if([[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]] isEqualToString:userid])
        {
            if([[dict valueForKey:@"message_count"] isEqualToString:@"0"])
            {
                [dict setValue:@"1" forKey:@"message_count"];
            }
            else
            {
                [dict setValue:@"0" forKey:@"message_count"];
            }
            
            [dataArray replaceObjectAtIndex:sender.tag withObject:dict];
            
            [keyDict setObject:dataArray forKey:sectionTitle];
            break;
            
        }
    }
  
}
- (void)addTapped:(UIButton *)sender
{
    NSLog(@"sender tag is %d",(int)sender.tag);
    
    if(isSearching)
    {
        NSString *sectionTitle = [searchSectionTitleArray objectAtIndex:sender.superview.tag];
        NSMutableArray *dataArray = [[NSMutableArray alloc] initWithArray:[searchKeyDict objectForKey:sectionTitle]];
        
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[dataArray objectAtIndex:sender.tag]];
        
        if([[dict valueForKey:@"message_count"] isEqualToString:@"0"])
        {
            [dict setValue:@"1" forKey:@"message_count"];
        }
        else
        {
            [dict setValue:@"0" forKey:@"message_count"];
        }
        
        [dataArray replaceObjectAtIndex:sender.tag withObject:dict];
        [self changeObject:[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]] Sender:sender];
        [self changeFreindArray:[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]]];
        
        [searchKeyDict setObject:dataArray forKey:sectionTitle];
        [self updateSearchArray:[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]]];
        
        [self.tblFriend reloadData];
    }
    else
    {
        NSString *sectionTitle = [sectionTitleArray objectAtIndex:sender.superview.tag];
        NSMutableArray *dataArray = [[NSMutableArray alloc] initWithArray:[keyDict objectForKey:sectionTitle]];
        
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[dataArray objectAtIndex:sender.tag]];
        
        if([[dict valueForKey:@"message_count"] isEqualToString:@"0"])
        {
            [dict setValue:@"1" forKey:@"message_count"];
        }
        else
        {
            [dict setValue:@"0" forKey:@"message_count"];
        }
        
        [dataArray replaceObjectAtIndex:sender.tag withObject:dict];
        
        [keyDict setObject:dataArray forKey:sectionTitle];
        
        [self changeFreindArray:[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]]];
        [self.tblFriend reloadData];
        
    }
}


-(void)updateSearchArray:(NSString *)userid
{
    
    //[self changeFreindArray:[NSString stringWithFormat:@"%@",userid]];
    
    for(int i=0;i<searchArray.count;i++)
    {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[searchArray objectAtIndex:i]];
        if([[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]] isEqualToString:userid])
        {
            if([[dict valueForKey:@"message_count"] isEqualToString:@"0"])
            {
                [dict setValue:@"1" forKey:@"message_count"];
            }
            else
            {
                [dict setValue:@"0" forKey:@"message_count"];
            }
            
            [searchArray replaceObjectAtIndex:i withObject:dict];
            break;
        }
    }
    
}

-(void)changeFreindArray:(NSString *)userid
{
    for(int i=0;i<friendArray.count;i++)
    {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[friendArray objectAtIndex:i]];
        if([[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]] isEqualToString:userid])
        {
            if([[dict valueForKey:@"message_count"] isEqualToString:@"0"])
            {
                [dict setValue:@"1" forKey:@"message_count"];
            }
            else
            {
                [dict setValue:@"0" forKey:@"message_count"];
            }
            
            [friendArray replaceObjectAtIndex:i withObject:dict];
            break;
        }
    }
}
- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    
    if(image)
    {
        self.imgProfile.image = [mc scaleAndRotateImage:image];
        isImageChanged=YES;
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
        if(buttonIndex == 2)
        {
            pickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
            pickerController.allowsEditing = NO;
            
            // [self presentModalViewController:pickerController animated:YES];
            [self presentViewController:pickerController animated:YES completion:nil];
        }
        else if(buttonIndex == 1)
        {
            pickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
            pickerController.allowsEditing = NO;
            //  [self presentModalViewController:pickerController animated:YES];
            [self presentViewController:pickerController animated:YES completion:nil];
            
        }
    
}



- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
   
}
-(NSArray *)getMembers
{
    NSMutableArray *array =[[NSMutableArray alloc] init];
    for(int i=0;i<friendArray.count;i++)
    {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[friendArray objectAtIndex:i]];
        
        if([[dict valueForKey:@"message_count"] isEqualToString:@"1"])
        {
            [array addObject:[NSString stringWithFormat:@"%@",[dict valueForKey:@"id"]]];
        }
        
    }
    return array;
}

- (IBAction)okTapped:(id)sender
{
    [self.view endEditing:YES];
    if([[self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]>0)
    {
        if(DELEGATE.connectedToNetwork)
        {
            NSString *idString=[[NSString alloc] init];
            NSArray *idArray =[[NSArray alloc] initWithArray:[self getMembers]];
            
            
            if(idArray.count>0)
            {
                 NSError *error;
                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:idArray options:NSJSONWritingPrettyPrinted error:&error];
               idString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                 NSLog(@"jsonData as string:\n%@ Error:%@", idString,error);
                
            }
            else
            {
                idString=nil;
            }
            [mc addGroup:[USER_DEFAULTS valueForKey:@"userid"] Name:self.txtName.text Image:(isImageChanged) ? (UIImagePNGRepresentation(self.imgProfile.image)) : nil  Member_ids:idString Sel:@selector(responseAddGroup:)];
        }
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter group name"] AlertFlag:1 ButtonFlag:1];
    }
}

-(void)responseAddGroup:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"groupCreated" object:nil userInfo:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
}

- (IBAction)imageClicked:(id)sender
{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
    [alert show];
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

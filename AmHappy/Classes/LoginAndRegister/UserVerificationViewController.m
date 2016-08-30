//
//  UserVerificationViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 05/02/15.
//
//

#import "UserVerificationViewController.h"
#import "ModelClass.h"
#import "HobbiyViewController.h"

@interface UserVerificationViewController ()

@end

@implementation UserVerificationViewController
{
    ModelClass *mc;    
    UIToolbar *mytoolbar1;
    UIPickerView *listPicker;
    NSMutableArray *relationArray;
    NSMutableArray *hobbyArray;
    NSMutableArray *hobbyIdArray;


    int relationID;
    NSMutableDictionary *selectionStates;


}
@synthesize lblTitle,txtHobby,txtName,txtRelation,scrollview,btnSubmit,lblHobby;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    relationID =-1;
    [self localize];
    relationArray =[[NSMutableArray alloc] init];
    hobbyArray =[[NSMutableArray alloc] init];
    hobbyIdArray =[[NSMutableArray alloc] init];

    
    [self.btnSubmit.layer setMasksToBounds:YES];
    [self.btnSubmit.layer setCornerRadius:3.0];
    
    selectionStates = [[NSMutableDictionary alloc] init];
   
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Hobby" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hobbySelected:)
                                                 name:@"Hobby"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectHobby" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hobbynotSelected:)
                                                 name:@"selectHobby"
                                               object:nil];
    
    self.txtRelation.delegate =self;
    self.txtName.delegate =self;
    self.txtHobby.delegate =self;
    
   

    
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
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Next"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self action:@selector(nextPressed)];
    [next setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    
    UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Previous"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self action:@selector(previousPressed)];
    [prev setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    mytoolbar1.items = [NSArray arrayWithObjects:prev,next,flexibleSpace,done1, nil];
    
    self.txtHobby.inputAccessoryView =mytoolbar1;
    self.txtName.inputAccessoryView =mytoolbar1;
    self.txtRelation.inputAccessoryView =mytoolbar1;
    
    listPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-150)];
    [listPicker setBackgroundColor:[UIColor whiteColor]];
    listPicker.showsSelectionIndicator = YES;
    listPicker.delegate =self;
    listPicker.dataSource =self;
    
    self.txtRelation.inputView =listPicker;
    
    

    if(DELEGATE.connectedToNetwork)
    {
        [mc getDropDowns:nil Sel:@selector(responseGetDropDown:)];

        //[mc getDropDowns:@selector(responseGetDropDown:)];
    }

}
-(void)viewWillAppear:(BOOL)animated
{
    
}
-(void)localize
{
    [self.txtRelation setPlaceholder:[localization localizedStringForKey:@"Select Relationship Status"]];
    [self.txtName setPlaceholder:[localization localizedStringForKey:@"Display Name"]];
    [self.btnSubmit setTitle:[localization localizedStringForKey:@"Submit"] forState:UIControlStateNormal];
    [self.lblTitle setText:[localization localizedStringForKey:@"Complete Profile"]];
    [self.lblHobby setText:[localization localizedStringForKey:@"Tap to select Hobby"]];
}
-(void)hobbySelected:(NSNotification *)notification
{
    NSDictionary *json = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
    NSLog(@"json is %@",json);
    if(json.count>0)
    {
        self.lblHobby.text =[NSString stringWithFormat:@"%@ hobby selected",[json valueForKey:@"count"]];
        hobbyIdArray =[NSMutableArray arrayWithArray:[json objectForKey:@"selected"]];
        [self.lblHobby setTextColor:[UIColor blackColor]];
    }
}
-(void)hobbynotSelected:(NSNotification *)notification
{
    NSDictionary *json = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
    NSLog(@"json is %@",json);
    if(json.count>0)
    {
        self.lblHobby.text =[NSString stringWithFormat:@"%@ hobby selected",[json valueForKey:@"count"]];
        hobbyIdArray =[NSMutableArray arrayWithArray:[json objectForKey:@"selected"]];
        [self.lblHobby setTextColor:[UIColor blackColor]];
    }
    else
    {
        self.lblHobby.text =[NSString stringWithFormat:@"0 hobby selected"];

    }
}
-(void)responseGetDropDown:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if([[results valueForKey:@"hobbies"] count]>0)
        {
            [hobbyArray addObjectsFromArray:[self getArrays:[results valueForKey:@"hobbies"]]];
            for (NSString *key in hobbyArray)
                [selectionStates setObject:[NSNumber numberWithBool:NO] forKey:key];
        }
        
        if([[results valueForKey:@"relation"] count]>0)
        {
            [relationArray addObjectsFromArray:[self getArrays:[results valueForKey:@"relation"]]];
            [listPicker reloadAllComponents];
          
                if(relationArray.count>0)
                {
                    relationID =[[[relationArray objectAtIndex:0] valueForKey:@"id"] intValue];
                    [listPicker selectRow:0 inComponent:0 animated:NO];
                }
                
           
        }
        
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

      
    }
}
-(NSArray *)getArrays:(NSArray *)array
{
    NSMutableArray *temp=[[NSMutableArray alloc] init];
    for(int i=0; i<array.count;i++)
    {
        if([[[array objectAtIndex:i] valueForKey:@"is_deleted"] isEqualToString:@"N"])
        {
            [temp addObject:[array objectAtIndex:i]];
        }
    }
    return temp;
}
-(void)nextPressed
{
    
    if ([txtName isFirstResponder])
    {
        [txtRelation becomeFirstResponder];
        return;
    }
    
    
}
-(void)previousPressed
{
    if ([txtRelation isFirstResponder])
    {
        [txtName becomeFirstResponder];
        return;
    }
    
    
}

-(void)donePressed
{
    [self.view endEditing:YES];
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    /*  if(textField==self.txtUser )
     {
     [self.imgUser setImage:[UIImage imageNamed:@"user2.png"]];
     }
     else if(textField==self.txtPassword )
     {
     [self.imgPassword setImage:[UIImage imageNamed:@"lock2.png"]];
     }*/
    
    //   [self animateTextField: textField up: YES];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    /* if(textField==self.txtUser )
     {
     [self.imgUser setImage:[UIImage imageNamed:@"user.png"]];
     }
     else if(textField==self.txtPassword )
     {
     [self.imgPassword setImage:[UIImage imageNamed:@"lock.png"]];
     }*/
    // [self animateTextField: textField up: NO];
    
    if(textField==self.txtRelation )
    {
        if(self.txtRelation.text.length==0)
        {
            if(relationArray.count>0)
            {
                self.txtRelation.text = [[relationArray objectAtIndex:0] valueForKey:@"name"] ;
                relationID =[[[relationArray objectAtIndex:0] valueForKey:@"id"] intValue];

                
            }
            
        }
    }
    
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
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    
    return [super canPerformAction:action withSender:sender];
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if(relationArray.count>0)
    {
        return relationArray.count;
    }
    else
    {
        return 0;
    }
    
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if(relationArray.count>0)
    {
        return [[relationArray objectAtIndex:row] valueForKey:@"name"] ;
    }
    else
    {
        return nil;
    }
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    if(relationArray.count>0)
    {
        self.txtRelation.text = [[relationArray objectAtIndex:row] valueForKey:@"name"] ;
        relationID =[[[relationArray objectAtIndex:row] valueForKey:@"id"] intValue];
    }
}



- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    int sectionWidth = 320;
    
    return sectionWidth;
}



-(NSArray *)getArrayIDS:(NSArray *)array
{
    NSMutableArray *temp=[[NSMutableArray alloc] init];
    for(int i=0; i<array.count;i++)
    {
            [temp addObject:[[array objectAtIndex:i] valueForKey:@"id"]];
       
    }
    return temp;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)submitTapped:(id)sender
{
    [self.view endEditing:YES];
    if([[self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]>0)
    {
        if(DELEGATE.connectedToNetwork)
        {
           
            

            [mc editUser:[USER_DEFAULTS valueForKey:@"userid"] Fullname:[self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] Username:nil Email_id:nil Image:nil Gender:nil Dob:nil Hobbies:(hobbyIdArray.count>0) ? [hobbyIdArray componentsJoinedByString:@","] : nil Relationship:(relationID >= 0) ? [NSString stringWithFormat:@"%d",relationID] : nil Password:nil Device_id:DELEGATE.tokenstring Sel:@selector(responseeditUser:)];
        }
       

        
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter Display Name"] AlertFlag:1 ButtonFlag:1];

     
    }
}
-(void)responseeditUser:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [USER_DEFAULTS setValue:@"yes" forKey:@"updated"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"jid"] forKey:@"myjid"];
        [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"fullname"] forKey:@"fullname"];


        [USER_DEFAULTS synchronize];
        [DELEGATE setWindowRoot];

    }
    else
    {
         [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
      
    }
}
- (IBAction)hobbyTapped:(id)sender
{
    [self.view endEditing:YES];
    HobbiyViewController *hobbyVC;
    if(hobbyIdArray.count>0)
    {
        hobbyVC =[[HobbiyViewController alloc] initWithNibName:@"HobbiyViewController" IdArray:hobbyIdArray bundle:nil];
        
    }
    else
    {
        hobbyVC =[[HobbiyViewController alloc] initWithNibName:@"HobbiyViewController" bundle:nil];
        
    }
    
    [hobbyVC setIsEdit:NO];
    [hobbyVC setIsFirst:YES];
    [self.navigationController pushViewController:hobbyVC animated:YES];
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

//
//  RegistrationViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import "RegistrationViewController.h"
#import "ModelClass.h"
#import "TermsViewController.h"
#import "UIImageView+WebCache.h"
#import "HobbiyViewController.h"
#import "BlockedUserViewController.h"


@interface RegistrationViewController ()
@property (nonatomic, strong) AppTextField *activeTxtFld;
@end

@implementation RegistrationViewController
{
    BOOL isMale;
    BOOL isCheck;
    BOOL isSocial;

    ModelClass *mc;
    UIToolbar *mytoolbar1;
    UIPickerView *listPicker;
    NSMutableArray *relationArray;
  //  NSMutableArray *hobbyArray;
    NSMutableArray *hobbyIdArray;
    
    int relationID;
    NSMutableDictionary *selectionStates;
    
    UIImagePickerController *pickerController;
    UIDatePicker *datePicker1;
    
    NSString *hobbies;

    NSString *relationType;
}
@synthesize lblGender,lblTitle,btnCheck,btnFemail,btnMale,btnSave,txtName,txtHobby,txtConfirm,txtDob,txtEmail,txtPasswd,txtRelation,scrollview,imgconfirm,imgDob,imgEmail,imgname,imgPasswd,imgUser,txtUser,placeImage,isEdit;
@synthesize lblHobby,isMy,btnTerms,btnBack,btnSave2,btnCancel,imgSepr,btnBlockUser;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.txtName setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
//    [self.txtHobby setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
//    [self.txtRelation setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
//    [self.txtUser setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    relationID =-1;
    
    [self.btnSave.layer setMasksToBounds:YES];
    [self.btnSave.layer setCornerRadius:3.0];
    
    [[self.txtRelation valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];

    isCheck =NO;
    isMale =YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectHobby" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hobbySelected:)
                                                 name:@"selectHobby"
                                               object:nil];
    
    
    relationArray =[[NSMutableArray alloc] init];
   // hobbyArray =[[NSMutableArray alloc] init];
    hobbyIdArray =[[NSMutableArray alloc] init];
    hobbies =[[NSString alloc] init];
    
    selectionStates = [[NSMutableDictionary alloc] init];
    
    [self localize];
    if(isEdit)
    {
        [self.btnBack setHidden:YES];
        [self.btnSave2 setHidden:NO];
        [self.btnSave setHidden:YES];
        [self.btnCancel setHidden:NO];
        [self.btnBlockUser setHidden:NO];

        [self.lblTitle setText:[localization localizedStringForKey:@"Profile"]];
        [self.txtEmail setUserInteractionEnabled:NO];
        [mc getUser:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responseGetUser:)];
    }
    else
    {
        if(DELEGATE.connectedToNetwork)
        {
            [mc getDropDowns:nil Sel:@selector(responseGetDropDown:)];
           // [mc getDropDowns:@selector(responseGetDropDown:)];
        }
    }
    
    
    
//    self.txtRelation.delegate =self;
//    self.txtName.delegate =self;
//    self.txtHobby.delegate =self;
//    self.txtConfirm.delegate =self;
//    self.txtDob.delegate =self;
//    self.txtEmail.delegate =self;
//    self.txtPasswd.delegate =self;
//    self.txtUser.delegate =self;
    [self.scrollview setContentSize:CGSizeMake(320, 750)];
    
    
    self.placeImage.layer.masksToBounds = YES;
    self.placeImage.layer.cornerRadius = 50.0;
    
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.cornerRadius = 50.0;
    
    
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
    
//    self.txtHobby.inputAccessoryView =mytoolbar1;
//    self.txtName.inputAccessoryView =mytoolbar1;
//    self.txtRelation.inputAccessoryView =mytoolbar1;
//    self.txtPasswd.inputAccessoryView =mytoolbar1;
//    self.txtEmail.inputAccessoryView =mytoolbar1;
//    self.txtDob.inputAccessoryView =mytoolbar1;
//    self.txtConfirm.inputAccessoryView =mytoolbar1;
//    self.txtUser.inputAccessoryView =mytoolbar1;

   
    
    listPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-150)];
    [listPicker setBackgroundColor:[UIColor whiteColor]];
    listPicker.showsSelectionIndicator = YES;
    listPicker.delegate =self;
    listPicker.dataSource =self;
    
    self.txtRelation.inputView =listPicker;
    
    

    
    datePicker1 = [[UIDatePicker alloc]init];
    datePicker1.datePickerMode = UIDatePickerModeDate;
    datePicker1.maximumDate = [NSDate date];
    [datePicker1 setDate:[NSDate date]];
    [datePicker1 addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.txtDob setInputView:datePicker1];
    
    [self customScreen];

}

-(void)customScreen
{
    [self.txtName setPaddingViewWithImg:@"user1"];
    [self.txtUser setPaddingViewWithImg:@"user1"];
    [self.txtEmail setPaddingViewWithImg:@"mail"];
    [self.txtPasswd setPaddingViewWithImg:@"pass1"];
    [self.txtConfirm setPaddingViewWithImg:@"pass1"];
    
    [self.camBgView.layer setCornerRadius:self.camBgView.frame.size.width/2];
    [self.camBgView setBackgroundColor:self.btnSave.backgroundColor];
    self.camBgView.layer.masksToBounds = YES;
    
    [self.txtName.paddingBGView setBackgroundColor:[UIColor colorWithRed:117/255.0f green:171/255.0f blue:35/255.0f alpha:1.0f]];
}

-(void)hobbySelected:(NSNotification *)notification
{
    NSDictionary *json = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
    NSLog(@"json is %@",json);
    if(json.count>0)
    {
        hobbies =[json valueForKey:@"ids"];
        self.lblHobby.text =[NSString stringWithFormat:@"%@ %@",[json valueForKey:@"count"],[localization localizedStringForKey:@"hobbies selected"]];
        hobbyIdArray =[NSMutableArray arrayWithArray:[json objectForKey:@"selected"]];
        [self.lblHobby setTextColor:[UIColor blackColor]];
    }
    else
    {
        if(hobbyIdArray)
        {
            [hobbyIdArray removeAllObjects];
        }
        self.lblHobby.text =[NSString stringWithFormat:@"0 %@",[localization localizedStringForKey:@"hobby selected"] ];
        [self.lblHobby setTextColor:[UIColor blackColor]];
    }
}

-(void)responseGetUser:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
       
        
        /*
         code: 200,
         status: "Success",
         User: {
         userid: 5,
         email: "",
         username: "Ronit",
         fullname: "robot",
         gender: "M",
         dob: "",
         image: "http://graph.facebook.com/331012533776314/picture?type=large",
         relationship: 1,
         relationship_name: "Single",
         hobbies: "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15",
         hobbies_count: 15,
         recieve_push: "Y",
         langauge: "E"
         }
         */
       // self.txtEmail.text =@"a123@a123.com";
        
        relationType = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@",[[results valueForKey:@"User"] valueForKey:@"relationship"]]];

        self.txtEmail.text =[[results valueForKey:@"User"] valueForKey:@"email"];
        self.txtDob.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"User"] valueForKey:@"dob"]];
        if([[[results valueForKey:@"User"] valueForKey:@"hobbies_count"] integerValue]==1)
        {
            self.lblHobby.text =[NSString stringWithFormat:@"%@ %@",[[results valueForKey:@"User"] valueForKey:@"hobbies_count"],[localization localizedStringForKey:@"hobby selected"]];
            [lblHobby setTextColor:[UIColor blackColor]];
        }
        else
        {
            self.lblHobby.text =[NSString stringWithFormat:@"%@ %@",[[results valueForKey:@"User"] valueForKey:@"hobbies_count"],[localization localizedStringForKey:@"hobbies selected"]];
            [lblHobby setTextColor:[UIColor blackColor]];

        }
        [self.btnCheck setImage:[UIImage imageNamed:@"tick2.png"] forState:UIControlStateNormal];
        [self.btnCheck setUserInteractionEnabled:NO];
        self.txtName.text =[[results valueForKey:@"User"] valueForKey:@"fullname"];
        
        
        
        
        //self.txtRelation.text =[[results valueForKey:@"User"] valueForKey:@"relationship_name"];
        self.txtRelation.text = [localization localizedStringForKey:[[results valueForKey:@"User"] valueForKey:@"relationship_name"]];
        
        
        
        self.txtUser.text =[[results valueForKey:@"User"] valueForKey:@"username"];
        relationID =(int)[[[results valueForKey:@"User"] valueForKey:@"relationship"] integerValue];
        hobbies =[[results valueForKey:@"User"] valueForKey:@"hobbies"];
        if([[[results valueForKey:@"User"] valueForKey:@"hobbies"] length]>0)
        {
            [hobbyIdArray removeAllObjects];
            [hobbyIdArray addObjectsFromArray:[[[results valueForKey:@"User"] valueForKey:@"hobbies"] componentsSeparatedByString:@","]];
            
           
        }
        if([[[results valueForKey:@"User"] valueForKey:@"type"] isEqualToString:@"S"])
        {
            [self.txtPasswd setEnabled:NO];
            [self.txtConfirm setEnabled:NO];
            isSocial =YES;

        }
        else
        {
            isSocial =NO;
        }
        
        
        
        [self.profileImage sd_setImageWithURL:[NSURL URLWithString:[[results valueForKey:@"User"] valueForKey:@"image"]]];
        
        if([[[results valueForKey:@"User"] valueForKey:@"gender"] length]>0)
        {
            if([[[results valueForKey:@"User"] valueForKey:@"gender"] isEqualToString:@"M"])
            {
                [self.btnMale setImage:[UIImage imageNamed:@"male1.png"] forState:UIControlStateNormal];
                [self.btnFemail setImage:[UIImage imageNamed:@"female.png"] forState:UIControlStateNormal];
                isMale =YES;
            }
            else
            {
                [self.btnMale setImage:[UIImage imageNamed:@"male.png"] forState:UIControlStateNormal];
                [self.btnFemail setImage:[UIImage imageNamed:@"female1.png"] forState:UIControlStateNormal];
                isMale =NO;
            }
        }
        
        if(DELEGATE.connectedToNetwork)
        {
        
            
            [mc getDropDowns:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responseGetDropDown:)];
            //[mc getDropDowns:@selector(responseGetDropDown:)];
        }
        
        
    }
    else
    {
        [self showPopUpwithMsg:[results valueForKey:@"message"]];
        
        //[DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
      /*  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
   
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
}
-(void)localize
{
   // [self.txtUser setPlaceholder:[localization localizedStringForKey:@"fullname"]];
    [self.txtPasswd setPlaceholder:[localization localizedStringForKey:@"Password"]];
    [self.txtRelation setPlaceholder:[localization localizedStringForKey:@"Select Relationship Status"]];
    [self.txtName setPlaceholder:[localization localizedStringForKey:@"Full Name"]];
    [self.txtEmail setPlaceholder:[localization localizedStringForKey:@"Email"]];
    [self.txtDob setPlaceholder:[localization localizedStringForKey:@"Date of Birth"]];
    [self.txtConfirm setPlaceholder:[localization localizedStringForKey:@"Confirm Password"]];
    [self.btnSave setTitle:[localization localizedStringForKey:@"Sign Up"] forState:UIControlStateNormal];
    [self.btnSave2 setTitle:[localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];

    [self.btnTerms setTitle:[localization localizedStringForKey:@"Terms and Policy"] forState:UIControlStateNormal];
    [self.btnCancel setTitle:[localization localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];

    
    [self.lblTitle setText:[localization localizedStringForKey:@"Register"]];
    [self.lblGender setText:[localization localizedStringForKey:@"Gender"]];
    [self.lblHobby setText:[localization localizedStringForKey:@"Tap to select Hobby"]];
    
    
    
    CGSize stringsize = [[localization localizedStringForKey:@"Terms and Policy"] sizeWithFont:[UIFont systemFontOfSize:13]];
    float width = stringsize.width;
    
    
    CGPoint centerbtn = self.btnTerms.center;
    
    self.btnTerms.frame =CGRectMake(self.btnTerms.frame.origin.x, self.btnTerms.frame.origin.y, width, self.btnTerms.frame.size.height);
    self.btnTerms.center =centerbtn;
    
    CGPoint centerImageView = self.imgSepr.center;
    
    self.imgSepr.frame =CGRectMake(self.imgSepr.frame.origin.x, self.imgSepr.frame.origin.y, width-10, self.imgSepr.frame.size.height);
    self.imgSepr.center =centerImageView;


    
}
-(void)updateTextField:(id)sender
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:datePicker1.date];
    self.txtDob.text = [NSString stringWithFormat:@"%@",formattedDate];
}

-(void)responseGetDropDown:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
      /*  if([[results valueForKey:@"hobbies"] count]>0)
        {
            [hobbyArray addObjectsFromArray:[self getArrays:[results valueForKey:@"hobbies"]]];
            for (NSString *key in hobbyArray)
                [selectionStates setObject:[NSNumber numberWithBool:NO] forKey:key];
            
            [multiPicker reloadAllComponents];

            
            if(hobbyIdArray.count>0)
            {
                for (NSString *key in hobbyArray)
                {
                    NSLog(@"key is %@",[key valueForKey:@"id"]);
                    for(int i=0;i<hobbyIdArray.count;i++)
                    {
                         if([[NSString stringWithFormat:@"%@",[key valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[hobbyIdArray objectAtIndex:i]]])
                         {
                             [selectionStates setObject:[NSNumber numberWithBool:YES] forKey:key];
                         }
                    }
                   
                }
            }
            [multiPicker reloadAllComponents];

        }*/
        
        
        
        for (int i = 0; i < [[results valueForKey:@"relation"]count]; i++)
        {
            
            if ([[[[results valueForKey:@"relation"]objectAtIndex:i]valueForKey:@"id"]intValue] == relationType.intValue)
            {
                
                [self.txtRelation setText:[[[results valueForKey:@"relation"]objectAtIndex:i]valueForKey:@"name"]];
                
                
            }
            
            
            
        }
        
        
        
        if([[results valueForKey:@"relation"] count]>0)
        {
            [relationArray addObjectsFromArray:[self getArrays:[results valueForKey:@"relation"]]];
            [listPicker reloadAllComponents];

            if(!isEdit)
            {
                if(relationArray.count>0)
                {
                    relationID =[[[relationArray objectAtIndex:0] valueForKey:@"id"] intValue];
                    [listPicker selectRow:0 inComponent:0 animated:NO];
                }
                
            }
        }
        
    }
    else
    {
        [self showPopUpwithMsg:[results valueForKey:@"message"]];
        
       // [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];

      /*  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
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
        [txtDob becomeFirstResponder];
        return;
    }
   /* if ([txtUser isFirstResponder])
    {
        [txtDob becomeFirstResponder];
        return;
    }*/
    if ([txtDob isFirstResponder])
    {
        [txtEmail becomeFirstResponder];
        return;
    }
    if ([txtEmail isFirstResponder])
    {
        [txtPasswd becomeFirstResponder];
        return;
    }
    if ([txtPasswd isFirstResponder])
    {
        [txtConfirm becomeFirstResponder];
        return;
    }
    if ([txtConfirm isFirstResponder])
    {
        [txtRelation becomeFirstResponder];
        return;
    }
    
}
-(void)previousPressed
{
    if ([txtRelation isFirstResponder])
    {
        [txtConfirm becomeFirstResponder];
        return;
    }
    if ([txtConfirm isFirstResponder])
    {
        [txtPasswd becomeFirstResponder];
        return;
    }
    if ([txtPasswd isFirstResponder])
    {
        [txtEmail becomeFirstResponder];
        return;
    }
    if ([txtEmail isFirstResponder])
    {
        [txtDob becomeFirstResponder];
        return;
    }
    if ([txtDob isFirstResponder])
    {
        [txtName becomeFirstResponder];
        return;
    }
    /*if ([txtUser isFirstResponder])
    {
        [txtName becomeFirstResponder];
        return;
    }*/
    
}

-(void)donePressed
{
    [self.view endEditing:YES];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
 
    [self resetPaddingBgColor];
    _activeTxtFld = (AppTextField *)textField;
    [_activeTxtFld.paddingBGView setBackgroundColor:[UIColor colorWithRed:117/255.0f green:171/255.0f blue:35/255.0f alpha:1.0f]];
    [_activeTxtFld setTextColor:[UIColor colorWithRed:117/255.0f green:171/255.0f blue:35/255.0f alpha:1.0f]];
    
    if(textField == self.txtUser)
    {
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    }
    
     if(textField==self.txtName )
     {
         [self.imgname setImage:[UIImage imageNamed:@"user2.png"]];
     }
     else if(textField==self.txtUser )
      {
          [self.imgUser setImage:[UIImage imageNamed:@"user2.png"]];
      }
     else if(textField==self.txtDob )
     {
         [self.imgDob setImage:[UIImage imageNamed:@"cal1.png"]];
     }
     else if(textField==self.txtEmail )
     {
         [self.imgEmail setImage:[UIImage imageNamed:@"mail1.png"]];
         [textField setKeyboardType:UIKeyboardTypeEmailAddress];

     }
     else if(textField==self.txtPasswd )
     {
         [self.imgPasswd setImage:[UIImage imageNamed:@"pass2.png"]];
     }
     else if(textField==self.txtConfirm )
     {
         [self.imgconfirm setImage:[UIImage imageNamed:@"pass2.png"]];
     }
    
    //   [self animateTextField: textField up: YES];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    [_activeTxtFld setTextColor:[UIColor whiteColor]];

    if(textField==self.txtName )
    {
        [self.imgname setImage:[UIImage imageNamed:@"user1.png"]];
    }
    else if(textField==self.txtUser )
    {
        [self.imgUser setImage:[UIImage imageNamed:@"user1.png"]];
    }
    else if(textField==self.txtDob )
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
        NSString *formattedDate = [dateFormatter stringFromDate:datePicker1.date];
        self.txtDob.text = [NSString stringWithFormat:@"%@",formattedDate];
        [self.imgDob setImage:[UIImage imageNamed:@"cal.png"]];
    }
    else if(textField==self.txtEmail )
    {
        [self.imgEmail setImage:[UIImage imageNamed:@"mail.png"]];
    }
    else if(textField==self.txtPasswd )
    {
        [self.imgPasswd setImage:[UIImage imageNamed:@"pass1.png"]];
    }
    else if(textField==self.txtConfirm )
    {
        [self.imgconfirm setImage:[UIImage imageNamed:@"pass1.png"]];
    }
    else if(textField==self.txtRelation )
    {
        if(self.txtRelation.text.length==0)
        {
            if(relationArray.count>0)
            {
                self.txtRelation.text = [[relationArray objectAtIndex:0] valueForKey:@"name"] ;

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cameraTapped:(id)sender
{
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
    [alert show];
    pickerController = [[UIImagePickerController alloc]
                        init];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
}
- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    
    if(image)
    {

        
        self.placeImage.hidden =YES;        
       // self.profileImage.image =image;
        
        CGRect rect =CGRectMake(0, 0, self.profileImage.frame.size.width, self.profileImage.frame.size.height);
        
        //CGRect screenRect = self.imgEvent.frame;
        UIGraphicsBeginImageContext(rect.size);
        [image drawInRect:rect];
        // [image drawInRect:screenRect blendMode:kCGBlendModePlusDarker alpha:1];
        UIImage *tmpValue = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.profileImage.image =tmpValue;
    }
  //  [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 2)
    {
        pickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
       // [self presentModalViewController:pickerController animated:YES];
        [self presentViewController:pickerController animated:YES completion:nil];
    }
    else if(buttonIndex == 1)
    {
        pickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
      //  [self presentModalViewController:pickerController animated:YES];
        [self presentViewController:pickerController animated:YES completion:nil];

    }
    
    
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

- (IBAction)maleTapped:(id)sender
{
    if(!isMale)
    {
        [self.btnMale setImage:[UIImage imageNamed:@"male1.png"] forState:UIControlStateNormal];
        [self.btnFemail setImage:[UIImage imageNamed:@"female.png"] forState:UIControlStateNormal];
        isMale =YES;
    }
   
}
- (IBAction)femailTapped:(id)sender
{
    if(isMale)
    {
        [self.btnMale setImage:[UIImage imageNamed:@"male.png"] forState:UIControlStateNormal];
        [self.btnFemail setImage:[UIImage imageNamed:@"female1.png"] forState:UIControlStateNormal];
        isMale =NO;
    }
}
- (IBAction)termsTapped:(id)sender
{
    TermsViewController *termsVC =[[TermsViewController alloc] initWithNibName:@"TermsViewController" bundle:nil];
    [self.navigationController pushViewController:termsVC animated:YES];
}

- (IBAction)checkTapped:(id)sender
{
    if(isCheck)
    {
        [self.btnCheck setImage:[UIImage imageNamed:@"tick1.png"] forState:UIControlStateNormal];
        isCheck =NO;
    }
    else
    {
        [self.btnCheck setImage:[UIImage imageNamed:@"tick2.png"] forState:UIControlStateNormal];
        isCheck =YES;
    }
}
-(BOOL)checkValidation
{
    
    NSString *name = [self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passwd = [self.txtPasswd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *confirm = [self.txtConfirm.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   // NSString *user = [self.txtUser.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];


    
    
    if([name length] <= 0 || [email length]<= 0 || [passwd length]<= 6 || [confirm length]<= 6 || !isCheck)
    {
        if(name.length <=0 )
        {
            
           /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter Full Name"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
            [alert show];*/
            
            [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter Full Name"]];
            
            //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter Full Name"] AlertFlag:1 ButtonFlag:1];

            
            return FALSE;
        }
      /*  else  if(user.length <=0)
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter User Name"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
            [alert show];
            return FALSE;
        }*/
        else  if(email.length <=0)
        {
            
          /*  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter Email"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
            [alert show];*/
            
            [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter email address."]];
            
            //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter email address."] AlertFlag:1 ButtonFlag:1];
            return FALSE;
        }
        else  if(passwd.length <=0)
        {
            
          /*  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter Password"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
            [alert show];*/
            
            [self showPopUpwithMsg:[localization localizedStringForKey:@"Password can not be less than six characters."]];
            
            //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Password can not be less than six characters"] AlertFlag:1 ButtonFlag:1];
            
            return FALSE;
        }
        else  if(confirm.length <=0)
        {
            
            [self showPopUpwithMsg:[localization localizedStringForKey:@"Password can not be less than six characters."]];
            
            // [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Password can not be less than six characters"] AlertFlag:1 ButtonFlag:1];
            
            return FALSE;
        }
//        else  if(!isCheck)
//        {
//            [self showPopUpwithMsg:[localization localizedStringForKey:@"Please accept Terms and Policy to Continue."]];
//            
//            //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please accept Terms and Policy to Continue"] AlertFlag:1 ButtonFlag:1];
//          
//            
//            return FALSE;
//        }
        else
        {
            return TRUE;
        }
        
    }
    else
    {
        return TRUE;
    }
    
    
    
}
-(BOOL)checkValidation2
{
    
    NSString *name = [self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   // NSString *user = [self.txtUser.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(isSocial)
    {
        if([name length] <= 0  )
        {
            if(name.length <=0 )
            {
                
               /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter Full Name"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
                [alert show];*/
                
                [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter Full Name"]];
                
                
                //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter Full Name"] AlertFlag:1 ButtonFlag:1];
                
                return FALSE;
            }
            else
            {
                return TRUE;
            }
            
        }
        else
        {
            return TRUE;
        }
    }
    else
    {
        if([name length] <= 0 ||[email length]<= 0 )
        {
            if(name.length <=0 )
            {
                [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter Full Name"]];
                
                //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter Full Name"] AlertFlag:1 ButtonFlag:1];
                
                return FALSE;
            }
            else  if(email.length <=0)
            {
                [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter valid email address."]];
                
                //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter valid email address."] AlertFlag:1 ButtonFlag:1];
                 
                return FALSE;
            }
            else
            {
                return TRUE;
            }
            
        }
        else
        {
            return TRUE;
        }
    }
    
    
    
    
    
    
}

- (IBAction)saveTapped:(id)sender
{
   
        if([self checkValidation])
        {
            if([DELEGATE validateEmail:self.txtEmail.text])
            {
                if(self.txtPasswd.text.length>=6)
                {
                    if([self.txtPasswd.text isEqualToString:self.txtConfirm.text])
                    {
                        if(DELEGATE.connectedToNetwork)
                        {
                            // if(hobbyIdArray.count>0) ? [hobbyIdArray componentsJoinedByString:@","] : nil
                            //   if(relationID >= 0) ? [NSString stringWithFormat:@"%d",relationID] : nil;
                            
                            //if(isMale) ? @"M" : @"F";
                            NSData *imageData;
                            if(self.profileImage.image)
                            {
                                imageData = UIImagePNGRepresentation(self.profileImage.image);
                            }
                            else
                            {
                                imageData=nil;
                            }
                            // [mc createUser:self.txtName.text Username:self.txtUser.text Email_id:self.txtEmail.text Image:imageData Gender:(isMale) ? @"M" : @"F" Dob:self.txtDob.text Hobbies:(hobbyIdArray.count>0) ? [hobbyIdArray componentsJoinedByString:@","] : nil Relationship:(relationID >= 0) ? [NSString stringWithFormat:@"%d",relationID] : nil Password:self.txtPasswd.text Device_id:DeviceId Sel:@selector(responseCreateUser:)];
                            
                            [mc createUser:self.txtName.text Username:nil Email_id:self.txtEmail.text Image:imageData Gender:(isMale) ? @"M" : @"F" Dob:self.txtDob.text Hobbies:(hobbyIdArray.count>0) ? [hobbyIdArray componentsJoinedByString:@","] : nil Relationship:(relationID >= 0) ? [NSString stringWithFormat:@"%d",relationID] : nil Password:self.txtPasswd.text Device_id:DELEGATE.tokenstring Sel:@selector(responseCreateUser:)];
                        }
                    }
                    else
                    {
                        
                        [self showPopUpwithMsg:[localization localizedStringForKey:@"Password does not match!"]];
                        
                        //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Password does not match!"] AlertFlag:1 ButtonFlag:1];
                        
                        /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please Confirm your password carefully"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
                         [alert show];*/
                    }
                }
                else
                {
                     [self showPopUpwithMsg:[localization localizedStringForKey:@"Password can not be less than six characters"]];
                    
                    //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Password can not be less than six characters"] AlertFlag:1 ButtonFlag:1];
                }
                
                
            }
            else
            {
                [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter valid Email"]];
                
                //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter valid Email"] AlertFlag:1 ButtonFlag:1];
                
               /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Please enter valid Email"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
                [alert show];*/
            }
        }
    
}





-(void)editUser
{
    if([self checkValidation2])
    {
        if(isSocial)
        {
            
                    if(DELEGATE.connectedToNetwork)
                    {
                        
                        
                        NSData *imageData;
                        if(self.profileImage.image)
                        {
                            imageData = UIImagePNGRepresentation(self.profileImage.image);
                        }
                        else
                        {
                            imageData=nil;
                        }
                       
                        
                         [mc editUser:[USER_DEFAULTS valueForKey:@"userid"] Fullname:self.txtName.text Username:nil Email_id:self.txtEmail.text Image:imageData Gender:(isMale) ? @"M" : @"F" Dob:self.txtDob.text Hobbies:(hobbyIdArray.count>0) ? [hobbyIdArray componentsJoinedByString:@","] : nil Relationship:(relationID >= 0) ? [NSString stringWithFormat:@"%d",relationID] : nil Password:(self.txtPasswd.text.length>0) ? self.txtPasswd.text : nil Device_id:DELEGATE.tokenstring Sel:@selector(responseCreateUser:)];
                    }
            
            
        }
        else
        {
            if([DELEGATE validateEmail:self.txtEmail.text])
            {
                if(self.txtPasswd.text.length>0 ||self.txtConfirm.text.length>0 )
                {
                    if(self.txtPasswd.text.length>=6 || self.txtConfirm.text.length>=6)
                    {
                        if([self.txtPasswd.text isEqualToString:self.txtConfirm.text])
                        {
                            if(DELEGATE.connectedToNetwork)
                            {
                                
                                NSData *imageData;
                                if(self.profileImage.image)
                                {
                                    imageData = UIImagePNGRepresentation(self.profileImage.image);
                                }
                                else
                                {
                                    imageData=nil;
                                }
                                
                                
                                
                                [mc editUser:[USER_DEFAULTS valueForKey:@"userid"] Fullname:self.txtName.text Username:self.txtUser.text Email_id:self.txtEmail.text Image:imageData Gender:(isMale) ? @"M" : @"F" Dob:self.txtDob.text Hobbies:(hobbyIdArray.count>0) ? [hobbyIdArray componentsJoinedByString:@","] : nil Relationship:(relationID >= 0) ? [NSString stringWithFormat:@"%d",relationID] : nil Password:(self.txtPasswd.text.length>0) ? self.txtPasswd.text : nil Device_id:DELEGATE.tokenstring Sel:@selector(responseCreateUser:)];
                            }
                        }
                        else
                        {
                            [self showPopUpwithMsg:[localization localizedStringForKey:@"Password does not match!"]];
                            
                            //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Password does not match!"] AlertFlag:1 ButtonFlag:1];
                        }
                    }
                    else
                    {
                        [self showPopUpwithMsg:[localization localizedStringForKey:@"Password can not be less than six characters"]];
                        
                        //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Password can not be less than six characters"] AlertFlag:1 ButtonFlag:1];
                    }
                    
                }
                else
                {
                    
                    if(DELEGATE.connectedToNetwork)
                    {
                        
                        NSData *imageData;
                        if(self.profileImage.image)
                        {
                            imageData = UIImagePNGRepresentation(self.profileImage.image);
                        }
                        else
                        {
                            imageData=nil;
                        }
                        
                        
                        
                        [mc editUser:[USER_DEFAULTS valueForKey:@"userid"] Fullname:self.txtName.text Username:self.txtUser.text Email_id:self.txtEmail.text Image:imageData Gender:(isMale) ? @"M" : @"F" Dob:self.txtDob.text Hobbies:(hobbyIdArray.count>0) ? [hobbyIdArray componentsJoinedByString:@","] : nil Relationship:(relationID >= 0) ? [NSString stringWithFormat:@"%d",relationID] : nil Password:(self.txtPasswd.text.length>0) ? self.txtPasswd.text : nil Device_id:DELEGATE.tokenstring Sel:@selector(responseCreateUser:)];
                    }
                 
                }
                
            }
            else
            {
                [self showPopUpwithMsg:[localization localizedStringForKey:@"Please enter valid email address."]];
                
                //[DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter valid email address."] AlertFlag:1 ButtonFlag:1];
             
            }
        }
        
    }
}
-(void)responseCreateUser:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(isEdit)
        {
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"userid"] forKey:@"userid"];
            [USER_DEFAULTS setObject:self.txtEmail.text forKey:@"email_address"];
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"fullname"] forKey:@"fullname"];
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"language"] forKey:@"language"];
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"recieve_push"] forKey:@"recieve_push"];
            
            
            
            [USER_DEFAULTS setObject:[[results valueForKey:@"User"] valueForKey:@"language"] forKey:@"localization"];
            
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"comment_notification"] forKey:@"comment_notification"];
            
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"event_notification"] forKey:@"event_notification"];

             [USER_DEFAULTS synchronize];
            
            if([[[results valueForKey:@"User"] valueForKey:@"language"] isEqualToString:@"S"])
            {
                [localization setLanguage:@"SP"];
            }
            else if([[[results valueForKey:@"User"] valueForKey:@"language"] isEqualToString:@"C"])
            {
                [localization setLanguage:@"CH"];
            }
            else
            {
                [localization setLanguage:@"EN"];
            }

            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"userid"] forKey:@"userid"];
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"jid"] forKey:@"myjid"];
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"fullname"] forKey:@"fullname"];
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"langauge"] forKey:@"langauge"];
            [USER_DEFAULTS setValue:[[results valueForKey:@"User"] valueForKey:@"recieve_push"] forKey:@"recieve_push"];
            [USER_DEFAULTS setObject:[[results valueForKey:@"User"] valueForKey:@"langauge"] forKey:@"localization"];


            [USER_DEFAULTS setValue:@"yes" forKey:@"updated"];
            [USER_DEFAULTS synchronize];
            
            if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"S"])
            {
                [localization setLanguage:@"SP"];
            }
            else if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"C"])
            {
                [localization setLanguage:@"CH"];
            }
            else
            {
                [localization setLanguage:@"EN"];
            }
            [DELEGATE setWindowRoot];
        }
    }
    else
    {
        [self showPopUpwithMsg:[results valueForKey:@"message"]];
        
        //[DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
        
      /*  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
}
- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)hobbyTapped:(id)sender
{
    [self.view endEditing:YES];

    HobbiyViewController *hobbyVC ;
    if(self.isEdit)
    {
        hobbyVC =[[HobbiyViewController alloc] initWithNibName:@"HobbiyViewController" IdArray:hobbyIdArray bundle:nil];
        [hobbyVC setIsEdit:YES];
        [hobbyVC setIsFirst:NO];
        [hobbyVC setIsOther:NO];


    }
    else
    {
        if(hobbyIdArray.count>0)
        {
            hobbyVC =[[HobbiyViewController alloc] initWithNibName:@"HobbiyViewController" IdArray:hobbyIdArray bundle:nil];
            
        }
        else
        {
            hobbyVC =[[HobbiyViewController alloc] initWithNibName:@"HobbiyViewController" bundle:nil];
            
        }
        
        //hobbyVC =[[HobbiyViewController alloc] initWithNibName:@"HobbiyViewController" bundle:nil];
        [hobbyVC setIsEdit:NO];
        [hobbyVC setIsFirst:NO];
        [hobbyVC setIsOther:NO];


    }
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
- (IBAction)save2Tapped:(id)sender
{
        [self editUser];
}
- (IBAction)cancelTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)blockedUserTapped:(id)sender
{
    BlockedUserViewController *blockVC =[[BlockedUserViewController alloc] initWithNibName:@"BlockedUserViewController" bundle:nil];
    [self.navigationController pushViewController:blockVC animated:YES];
}
- (IBAction)onClickSignInButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

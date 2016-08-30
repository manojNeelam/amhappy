//
//  addPromotion.m
//  
//
//  Created by Peerbits MacMini9 on 17/03/16.
//
//

#import "addPromotion.h"


@interface addPromotion ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    ModelClass *mc;
    
    UIToolbar *mytoolbar1;
    
    UIDatePicker *StartDatePicker;
    UIDatePicker *EndDatePicker;
    
    double startTime;
    double endTime;
    
    BOOL isProduct;
    
    UIImagePickerController *pickerController;
    
    NSData *imageData;
    
    NSMutableArray *promotionTypes;
    
    UIPickerView *Picker;
    
    int promotionSelectedIndex;
    
    NSString *promotionID;

    CLLocation *loc;
    
    
    NSMutableDictionary *promotionDetail;
}

@end

@implementation addPromotion
@synthesize isEdit,gettedPromotionID,isMyPromotion;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //Manoj Aug 02
    [self customiseScreen];
    
    if (isEdit)
    {
        if (isMyPromotion)
        {
            self.btnSave.hidden = NO;
        }
        else
        {
            self.btnSave.hidden = YES;
        }
        [self.lblTopHeader setText:@"Promotion Detail"];
    }
    
    NSLog(@"%@",promotionID);
   [self Initialsetup];
   
    // Do any additional setup after loading the view from its nib.
}

-(void)customiseScreen
{
    self.baseCamView.layer.cornerRadius = self.baseCamView.frame.size.width/2;
    self.baseCamView.layer.masksToBounds = YES;
    
    self.const_CompanyNameHeight.constant = self.const_CompanyNameHeight.constant + 30;
    self.const_CompanyNameWidth.constant =  self.const_CompanyNameWidth.constant + 50;
    
    self.const_WebsiteHeight.constant = self.const_WebsiteHeight.constant + 30;
    self.const_WebsiteWidtth.constant =  self.const_WebsiteWidtth.constant + 50;
    
    self.const_DescriptionHeight.constant = self.const_DescriptionHeight.constant + 30;
    self.const_DescriptionWidth.constant =  self.const_DescriptionWidth.constant + 50;
    
    
    [self.lblCompanyHint setTextColor:[UIColor lightGrayColor]];
    
    [self.lblDescriptionHint setTextColor:[UIColor lightGrayColor]];
    
    [self.lblWebsiteHint setTextColor:[UIColor lightGrayColor]];
    
    [self.lblWebsiteHint setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
    
    [self.lblDescriptionHint setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
    
    
    [self.lblCompanyHint setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
    
    
//    CGRect frame = self.lblCompanyHint.frame;
//    frame.size.width = frame.size.width + 20;
//    frame.size.height = frame.size.height + 5;
//    self.lblCompanyHint.frame = frame;
//    
//    frame = self.lblDescriptionHint.frame;
//    frame.size.width = frame.size.width + 20;
//    frame.size.height = frame.size.height + 5;
//    self.lblDescriptionHint.frame = frame;
//    
//    frame = self.lblWebsiteHint.frame;
//    frame.size.width = frame.size.width + 20;
//    frame.size.height = frame.size.height + 5;
//    self.lblWebsiteHint.frame = frame;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (UIView *view in self.scrollview.subviews)
    {
        view.userInteractionEnabled = YES;
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.view layoutIfNeeded];
    
    CGSize size = self.view.frame.size;
    
    self.const_width.constant = 375;
    [self.scrollview setContentSize:CGSizeMake(size.width, self.btnSubmit.frame.size.height+self.btnSubmit.frame.origin.y+60)];
}

-(void)Initialsetup
{
    if (isEdit)
    {
        [self.btnSave setHidden:NO];
        [self.btnSubmit setHidden:YES];
        
        if (isMyPromotion)
        {
            self.btnSave.hidden = NO;
        }
        else
        {
            self.btnSave.hidden = YES;
            for (UIView *view in self.scrollview.subviews)
            {
                view.userInteractionEnabled = NO;
            }
        }
    }
    else
    {
        [self.btnSave setHidden:YES];
        [self.btnSubmit setHidden:NO];
    }
    
    
    promotionDetail = [[NSMutableDictionary alloc]init];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
    {
        
        [self.txtfldPromotionType setTintColor:[UIColor clearColor]];
        [self.txtfldStartDate setTintColor:[UIColor clearColor]];
        [self.txtfldEndDate setTintColor:[UIColor clearColor]];
   
    }
    else
    {
        
        [[self.txtfldPromotionType valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
        [[self.txtfldStartDate valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
        [[self.txtfldEndDate valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
        
        
    }

    
    _txtfldPromotionType.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    _txtfldCompanyName.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    _txtfldEndDate.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    _txtfldWebsite.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    _txtfldLocation.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddPromotionLocationUpdate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdated:)
                                                 name:@"AddPromotionLocationUpdate"
                                               object:nil];
  
    promotionSelectedIndex = 0;
    
  
    promotionID = [[NSString alloc]init];

    
    isProduct = YES;
   
    
    [_imgPromotion setClipsToBounds:YES];
    
    
    startTime = 0;
    endTime = 0;
    
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    
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
    [done1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Next"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self action:@selector(nextPressed)];
    [next setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Previous"]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self action:@selector(previousPressed)];
    [prev setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    mytoolbar1.items = [NSArray arrayWithObjects:prev,next,flexibleSpace,done1, nil];
    
    
    
    
    
    StartDatePicker = [[UIDatePicker alloc]init];
    StartDatePicker.datePickerMode = UIDatePickerModeDate;
    StartDatePicker.minimumDate = [NSDate date];
    [StartDatePicker setDate:[NSDate date]];
    [StartDatePicker addTarget:self action:@selector(updateStartTime:) forControlEvents:UIControlEventValueChanged];
    [self.txtfldStartDate setInputView:StartDatePicker];
    
    
    EndDatePicker = [[UIDatePicker alloc]init];
    EndDatePicker.datePickerMode = UIDatePickerModeDate;
    EndDatePicker.minimumDate = [NSDate date];
    [EndDatePicker setDate:[NSDate date]];
    [EndDatePicker addTarget:self action:@selector(updateEndTime:) forControlEvents:UIControlEventValueChanged];
    [self.txtfldEndDate setInputView:EndDatePicker];
    
    
    self.txtfldPromotionType.inputAccessoryView =mytoolbar1;
    self.txtfldCompanyName.inputAccessoryView =mytoolbar1;
    self.txtFldDescription.inputAccessoryView =mytoolbar1;
    self.txtfldWebsite.inputAccessoryView =mytoolbar1;
    self.txtfldLocation.inputAccessoryView =mytoolbar1;
    
    self.txtfldPrice.inputAccessoryView =mytoolbar1;
    self.txtfldDiscount.inputAccessoryView =mytoolbar1;
    self.txtfldStartDate.inputAccessoryView =mytoolbar1;
    self.txtfldEndDate.inputAccessoryView =mytoolbar1;
    
    
    
    Picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width, self.view.frame.size.height-150)];
    [Picker setBackgroundColor:[UIColor whiteColor]];
    Picker.showsSelectionIndicator = YES;
    Picker.delegate =self;
    Picker.dataSource =self;
    
     _txtfldPromotionType.inputView =Picker;
    
   
    [self getPromotionTypes];
    
}

-(void)ResetAll
{
    
    _txtfldCompanyName.text = @"";
    _txtfldDiscount.text = @"";
    _txtfldEndDate.text = @"";
    _txtfldLocation.text = @"";
    _txtfldPrice.text = @"";
    _txtfldPromotionType.text = @"";
    _txtfldStartDate.text = @"";
    _txtfldWebsite.text = @"";
    _txtFldDescription.text = @"Description";
    
    [self.txtFldDescription setTextColor:[UIColor lightGrayColor]];
  
    isProduct = YES;
    
    [_bntProduct setImage:[UIImage imageNamed:@"radioIcon"] forState:UIControlStateNormal];
    [_bntService setImage:[UIImage imageNamed:@"radioUnSelected"] forState:UIControlStateNormal];
    
    promotionSelectedIndex = 0;
    
    _imgPromotion.image = [UIImage imageNamed:@"placeholder"];
    imageData=nil;
    
    //loc = [[CLLocation alloc]init];
    
  
}

-(void)getPromotionTypes
{
    
    if (DELEGATE.connectedToNetwork)
    {
        
        if (isEdit)
        {
            [mc PromotionDetail:[USER_DEFAULTS valueForKey:@"userid"] promo_id:[NSString stringWithFormat:@"%@",gettedPromotionID] Sel:@selector(promotionDetail:)];
            
        }
        else
        {
            [mc getPromotionTypes:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(promotionTypes:)];
            
        }
    
    }
   
}

#pragma mark ----------- Promotion Detail --------

-(void)promotionDetail:(NSDictionary *)response
{
    
    NSLog(@"result is %@",response);
    
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        if (DELEGATE.connectedToNetwork)
        {
            
            promotionDetail = [[NSMutableDictionary alloc]initWithDictionary:[response valueForKey:@"Promotion"]];
          
            [mc getPromotionTypes:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(promotionTypes:)];
        }
     
    }
    else
    {
        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
    
}

-(void)setPromotionData
{
    
    
    if (![[promotionDetail valueForKey:@"image"]isEqualToString:@""])
    {

        [self.imgPromotion sd_setImageWithURL:[NSURL URLWithString:[promotionDetail valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
            
            
            self.imgPromotion.image = image;
            
            imageData = UIImageJPEGRepresentation(image, 1);
    
        }];
   
    }
    
    
    for (int i = 0; i < [promotionTypes count]; i++)
    {
        if ([[[[promotionTypes objectAtIndex:i]valueForKey:@"id"]description]isEqualToString:[[promotionDetail valueForKey:@"type_id"] description]])
        {
            
            
            promotionSelectedIndex = i;
            
           [Picker selectRow:promotionSelectedIndex inComponent:0 animated:NO];
            
            [self.txtfldPromotionType setText:[[promotionTypes objectAtIndex:i]valueForKey:@"name"]];
            
            [Picker reloadAllComponents];
            
            
        }
      
    }
  
    if ([[promotionDetail valueForKey:@"promotion_type"]isEqualToString:@"P"])
    {
        isProduct=YES;
        
        [_bntProduct setImage:[UIImage imageNamed:@"radioIcon"] forState:UIControlStateNormal];
        [_bntService setImage:[UIImage imageNamed:@"radioUnSelected"] forState:UIControlStateNormal];
        
    }
    else{
        
        isProduct=NO;
        
        [_bntProduct setImage:[UIImage imageNamed:@"radioUnSelected"] forState:UIControlStateNormal];
        [_bntService setImage:[UIImage imageNamed:@"radioIcon"] forState:UIControlStateNormal];
        
        
    }
  
    [self.txtfldCompanyName setText:[promotionDetail valueForKey:@"company_name"]];
    
    
    if (![[promotionDetail valueForKey:@"description"]isEqualToString:@""])
    {
        [self.txtFldDescription setTextColor:[UIColor blackColor]];
        
        [self.txtFldDescription setText:[promotionDetail valueForKey:@"description"]];
        
    }
    
    
    
    [self.txtfldLocation setText:[promotionDetail valueForKey:@"location"]];
    
    
    if (![[promotionDetail valueForKey:@"latitude"]isEqualToString:@""]&&![[promotionDetail valueForKey:@"longitude"]isEqualToString:@""])
    {
        loc = [[CLLocation alloc]initWithLatitude:[[promotionDetail valueForKey:@"latitude"] doubleValue] longitude:[[promotionDetail valueForKey:@"longitude"] doubleValue]];
    }
    
    [self.txtfldWebsite setText:[promotionDetail valueForKey:@"website"]];
    
    [self.txtfldPrice setText:[NSString stringWithFormat:@"%d",[[promotionDetail valueForKey:@"price"] intValue]]];
    
    [self.txtfldDiscount setText:[NSString stringWithFormat:@"%d",[[promotionDetail valueForKey:@"discount"] intValue]]];
    
    
   
        
        startTime = [[promotionDetail valueForKey:@"start_date"] doubleValue];
        
        [self.txtfldStartDate setText:[self getDate:[promotionDetail valueForKey:@"start_date"]]];
    
        [StartDatePicker setDate:[NSDate dateWithTimeIntervalSince1970:startTime] animated:NO];
 
    
  
        
        endTime = [[promotionDetail valueForKey:@"end_date"] doubleValue];
        
        [self.txtfldEndDate setText:[self getDate:[promotionDetail valueForKey:@"end_date"]]];
    
      [EndDatePicker setDate:[NSDate dateWithTimeIntervalSince1970:endTime] animated:NO];
    
    
 
}


-(NSString *)getDate:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    // To parse the Date "Sun Jul 17 07:48:34 +0000 2011", you'd need a Format like so:
    
    //9 fer 2015
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    
    
    //en: en English
    //es: es español
    //zh-Hant: zh-Hant 中文（繁體字）
    if([USER_DEFAULTS valueForKey:@"localization"])
    {
        if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"S"])
        {
            [localization setLanguage:@"SP"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"es"]];
            
        }
        else if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"C"])
        {
            [localization setLanguage:@"CH"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-Hant"]];
            
        }
        else
        {
            [localization setLanguage:@"EN"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
            
        }
    }
    else
    {
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
        
    }
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",formattedDate];
}

#pragma mark --------- Location Updated -------

-(void)locationUpdated:(NSNotification *)notification
{
    NSDictionary *json = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
    if(json.count>0)
    {
        loc = [[CLLocation alloc] initWithLatitude:[[json valueForKey:@"lat"] floatValue] longitude:[[json valueForKey:@"long"] floatValue]];
        self.txtfldLocation.text =[NSString stringWithFormat:@"%@",[json valueForKey:@"addressstr"]];
 
    }
}


#pragma mark ---------- Response Promotion Types ---------------

-(void)promotionTypes:(NSDictionary *)response
{
    
    NSLog(@"result is %@",response);
    
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        promotionTypes = [[NSMutableArray alloc]initWithArray:[response valueForKey:@"Type"]];
        
        [Picker reloadAllComponents];
        
        if (isEdit)
        {
            
            [self setPromotionData];
        }
        
        
  
    }
    else
    {
        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    
    }
  
}

-(void)ok1BtnTapped:(id)sender
{
    [[self.view viewWithTag:123] removeFromSuperview];
}


-(void)viewDidAppear:(BOOL)animated
{
    //_scrollview.contentSize = _scrollContentView.frame.size;
    
     _scrollview.contentSize = CGSizeMake(ScreenSize.width,_scrollContentView.frame.size.height);
    
    NSLog(@"%@",NSStringFromCGSize(_scrollview.contentSize));
}

//-(void)viewDidLayoutSubviews
//{
//
//     _scrollview.contentSize = CGSizeMake(ScreenSize.width,_scrollContentView.frame.size.height);
//    
//    NSLog(@"%@",NSStringFromCGSize(_scrollview.contentSize));
//}

#pragma mark ------ Handle toolbar ----

-(void)donePressed
{
    [self.view endEditing:YES];
    
}

-(void)nextPressed
{
   
    if ([_txtfldPromotionType isFirstResponder])
    {
        [_txtfldCompanyName becomeFirstResponder];
        return;
    }
    if ([_txtfldCompanyName isFirstResponder])
    {
        [_txtFldDescription becomeFirstResponder];
        return;
    }
    if ([_txtFldDescription isFirstResponder])
    {
        [_txtfldLocation becomeFirstResponder];
        return;
    }
    
    if ([_txtfldLocation isFirstResponder])
    {
        [_txtfldWebsite becomeFirstResponder];
        return;
    }
    if ([_txtfldWebsite isFirstResponder])
    {
        [_txtfldPrice becomeFirstResponder];
        return;
    }
    if ([_txtfldPrice isFirstResponder])
    {
        [_txtfldDiscount becomeFirstResponder];
        return;
    }
    if ([_txtfldDiscount isFirstResponder])
    {
        [_txtfldStartDate becomeFirstResponder];
        return;
    }
    if ([_txtfldStartDate isFirstResponder])
    {
        [_txtfldEndDate becomeFirstResponder];
        return;
    }
    
   
}

-(void)previousPressed
{

    if ([_txtfldEndDate isFirstResponder])
    {
        [_txtfldStartDate becomeFirstResponder];
        return;
    }

    if ([_txtfldStartDate isFirstResponder])
    {
        [_txtfldDiscount becomeFirstResponder];
        return;
    }
    if ([_txtfldDiscount isFirstResponder])
    {
        [_txtfldPrice becomeFirstResponder];
        return;
    }
    if ([_txtfldPrice isFirstResponder])
    {
        [_txtfldWebsite becomeFirstResponder];
        return;
    }
    
    if ([_txtfldWebsite isFirstResponder])
    {
        [_txtfldLocation becomeFirstResponder];
        return;
    }
    if ([_txtfldLocation isFirstResponder])
    {
        [_txtFldDescription becomeFirstResponder];
        return;
    }
    if ([_txtFldDescription isFirstResponder])
    {
        [_txtfldCompanyName becomeFirstResponder];
        return;
    }
    if ([_txtfldCompanyName isFirstResponder])
    {
        [_txtfldPromotionType becomeFirstResponder];
        return;
    }
    
}


#pragma mark -------- Set Start and End Time --------


- (double) GetUTCDateTimeFromLocalTime:(NSDate *)IN_strLocalTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
    // NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *strDateTime   = [dateFormatter stringFromDate:IN_strLocalTime];
    NSDate *objUTCDate  = [dateFormatter dateFromString:strDateTime];
    double seconds = (long long)([objUTCDate timeIntervalSince1970] );
    
    NSString *strTimeStamp = [NSString stringWithFormat:@"%f",seconds];
    NSLog(@"The Timestamp is = %@",strTimeStamp);
    return seconds;
}

#pragma mark ------ update Start time --------

-(void)updateStartTime:(id)sender
{
    NSLog(@"%@",[sender class]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:StartDatePicker.date];
 
    self.txtfldStartDate.text = [NSString stringWithFormat:@"%@",formattedDate];

    startTime =[self GetUTCDateTimeFromLocalTime:StartDatePicker.date];
 
}

#pragma mark ------ update end time --------

-(void)updateEndTime:(id)sender
{
    NSLog(@"%@",[sender class]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:EndDatePicker.date];
    
    self.txtfldEndDate.text = [NSString stringWithFormat:@"%@",formattedDate];
    
    endTime =[self GetUTCDateTimeFromLocalTime:EndDatePicker.date];
    
}

#pragma mark -------- Picker DataSource & Delegate --------

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if(promotionTypes.count>0)
    {
        return promotionTypes.count;
    }
    else
    {
        return 0;
    }
    
}


// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if(promotionTypes.count>0)
    {
        return [[promotionTypes objectAtIndex:row] valueForKey:@"name"] ;
    }
    else
    {
        return nil;
    }
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    if(promotionTypes.count>0)
    {
        promotionSelectedIndex = (int)row;
        
        _txtfldPromotionType.text = [[promotionTypes objectAtIndex:row] valueForKey:@"name"] ;
        promotionID =[[promotionTypes objectAtIndex:row] valueForKey:@"id"];
    }
}



- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    int sectionWidth = ScreenSize.width;
    
    return sectionWidth;
}


-(BOOL)isEmpty:(NSString *)txtFld
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [txtFld stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
    
        return YES;
    }
    
    return NO;
}

#pragma mark ------- Textfield Delegate -----


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([textField isEqual:self.txtfldCompanyName])
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_CompanyNameHeight.constant = self.const_CompanyNameHeight.constant - 30;
            self.const_CompanyNameWidth.constant =  self.const_CompanyNameWidth.constant - 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblCompanyHint setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:12.0f]];
                                 
                                 [self.lblCompanyHint setTextColor:[UIColor blackColor]];
                                 
                             }];
        }
        
        
 
    }
    else if ([textField isEqual:self.txtfldWebsite])
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_WebsiteHeight.constant = self.const_WebsiteHeight.constant - 30;
            self.const_WebsiteWidtth.constant =  self.const_WebsiteWidtth.constant - 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblWebsiteHint setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:12.0f]];
                                 
                                 [self.lblWebsiteHint setTextColor:[UIColor blackColor]];
                             }];
        }
        
        
    }
    else if ([textField isEqual:self.txtFldDescription] )
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_DescriptionHeight.constant = self.const_DescriptionHeight.constant - 30;
            self.const_DescriptionWidth.constant =  self.const_DescriptionWidth.constant - 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblDescriptionHint setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:12.0f]];
                                 
                                 [self.lblDescriptionHint setTextColor:[UIColor blackColor]];
                             }];
        }
    }
    
    if ([_txtfldPromotionType isFirstResponder])
    {
        if ([promotionTypes count]>0)
        {
            
            [self.txtfldPromotionType setText:[[promotionTypes objectAtIndex:promotionSelectedIndex] valueForKey:@"name"]];
            
            promotionID =[[promotionTypes objectAtIndex:promotionSelectedIndex] valueForKey:@"id"];
        }
    }
    
    if ([_txtfldLocation isFirstResponder])
    {
        [self.view endEditing:YES];
  
        SeachAddressmapViewController *searchVC =[[SeachAddressmapViewController alloc] initWithNibName:@"SeachAddressmapViewController" bundle:nil];
        searchVC.isFromAddPromotion = YES;
        [self.navigationController pushViewController:searchVC animated:YES];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if([textField isEqual:self.txtfldCompanyName])
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_CompanyNameHeight.constant = self.const_CompanyNameHeight.constant + 30;
            self.const_CompanyNameWidth.constant =  self.const_CompanyNameWidth.constant + 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblCompanyHint setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
                                 
                                 [self.lblCompanyHint setTextColor:[UIColor lightGrayColor]];
                             }];
        }
    }
    
    else if ([textField isEqual:self.txtfldWebsite])
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_WebsiteHeight.constant = self.const_WebsiteHeight.constant + 30;
            self.const_WebsiteWidtth.constant =  self.const_WebsiteWidtth.constant + 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblWebsiteHint setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
                                 
                                 [self.lblWebsiteHint setTextColor:[UIColor lightGrayColor]];
                             }];
        }
        
    }
    else if ([textField isEqual:self.txtFldDescription])
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_DescriptionHeight.constant = self.const_DescriptionHeight.constant + 30;
            self.const_DescriptionWidth.constant =  self.const_DescriptionWidth.constant + 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblDescriptionHint setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
                                 
                                 [self.lblDescriptionHint setTextColor:[UIColor lightGrayColor]];
                             }];
        }
        
    }
    
    
    
    if (textField==self.txtfldCompanyName)
    {
        if([self.txtfldCompanyName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldCompanyName setText:@""];
            
        }
        
    }
    
    if(textField==self.txtfldDiscount)
    {
        if([self.txtfldDiscount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldDiscount setText:@""];
            
        }
        
    }
    
    if (textField==self.txtfldLocation)
    {
        if([self.txtfldLocation.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldLocation setText:@""];
            
        }
        
    }
    
    if (textField==self.txtfldPrice)
    {
        if([self.txtfldPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldPrice setText:@""];
            
        }
        
    }
    
    if (textField==self.txtfldPromotionType)
    {
        if([self.txtfldPromotionType.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldPromotionType setText:@""];
            
        }
        
    }
    
    if (textField==self.txtfldStartDate)
    {
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
        NSString *formattedDate = [dateFormatter stringFromDate:StartDatePicker.date];
        
        _txtfldStartDate.text = [NSString stringWithFormat:@"%@",formattedDate];
        
        startTime = [self GetUTCDateTimeFromLocalTime:StartDatePicker.date];
        
        if([self.txtfldStartDate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldStartDate setText:@""];
            
        }
        
        
    }
    
    
    if (textField==self.txtfldEndDate)
    {
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
        NSString *formattedDate = [dateFormatter stringFromDate:EndDatePicker.date];
        
        _txtfldEndDate.text = [NSString stringWithFormat:@"%@",formattedDate];
        
        endTime = [self GetUTCDateTimeFromLocalTime:EndDatePicker.date];
        
        if([self.txtfldEndDate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldEndDate setText:@""];
            
        }
        
        
    }
    
    if (textField==self.txtfldWebsite)
    {
        if([self.txtfldWebsite.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldWebsite setText:@""];
            
        }
        
    }
    
    
   

 
}


//#pragma mark -------  Textview Delegate ---------
//
//-(void)textViewDidBeginEditing:(UITextView *)textView
//{
//    
//    if (textView==self.txtviewDescription)
//    {
//        
//        if ([self.txtviewDescription.text isEqualToString:@"Description"])
//        {
//            [self.txtviewDescription setText:@""];
//            
//            [self.txtviewDescription setTextColor:[UIColor blackColor]];
//        }
//       
//        
//    }
//   
//}
//
//-(void)textViewDidEndEditing:(UITextView *)textView
//{
//    
//    if (textView==self.txtviewDescription)
//    {
//        
//        if([self.txtviewDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
//        {
//            
//            [self.txtviewDescription setText:@"Description"];
//            [self.txtviewDescription setTextColor:[UIColor lightGrayColor]];
//  
//        }
//        else
//        {
//            
//           [self.txtviewDescription setTextColor:[UIColor blackColor]];
//            
//        }
//        
//    }
//  
//}


#pragma mark -------- Response add Promotion -----------

-(void)addPromotion:(NSDictionary *)response
{
    NSLog(@"result is %@",response);
    
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        DELEGATE.isUpdatePromotions = YES;
  
        if (isEdit)
        {
  
           [self.navigationController popViewControllerAnimated:YES];
            
        }
        else{
            
              //[DELEGATE showalert:self Message:@"Promotion added Successfully" AlertFlag:1 ButtonFlag:1];
            
             [self ResetAll];
            
             [self.navigationController popViewControllerAnimated:YES];
            
        }
     
    }
    else
    {
        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
    

}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark ----------- Validation --------------

-(BOOL)AddpromotionValidation
{
    
    if ([self.txtfldPromotionType.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
       
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter Promotion Type"] AlertFlag:1 ButtonFlag:1];
        [self.txtfldPromotionType becomeFirstResponder];
        return NO;
        
        
    }
    
    if ([self.txtfldCompanyName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter Company Name"] AlertFlag:1 ButtonFlag:1];
        [self.txtfldCompanyName becomeFirstResponder];
        return NO;
        
        
    }
    
    if ([self.txtFldDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter Description"] AlertFlag:1 ButtonFlag:1];
        [self.txtFldDescription becomeFirstResponder];
        return NO;
        
        
    }
    
    if ([self.txtfldLocation.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"please select Location"] AlertFlag:1 ButtonFlag:1];
        [self.txtfldLocation becomeFirstResponder];
        return NO;
        
        
    }
    
    if ([self.txtfldWebsite.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"please enter Website Url"] AlertFlag:1 ButtonFlag:1];
        [self.txtfldWebsite becomeFirstResponder];
        return NO;
        
        
    }
    
    NSLog(@"%@",[self.txtfldWebsite.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]);
    
    
    if (![self validateUrl:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",self.txtfldWebsite.text]]])
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"please enter valid Website Url"] AlertFlag:1 ButtonFlag:1];
        [self.txtfldWebsite becomeFirstResponder];
        return NO;
        
        
    }
  
    if ([self.txtfldPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"please enter Price"] AlertFlag:1 ButtonFlag:1];
        [self.txtfldPrice becomeFirstResponder];
        return NO;
        
        
    }
    
    if ([self.txtfldDiscount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"please enter Discount"] AlertFlag:1 ButtonFlag:1];
        [self.txtfldDiscount becomeFirstResponder];
        return NO;
        
        
    }
    
    if ([self.txtfldStartDate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"please Select Start Date"] AlertFlag:1 ButtonFlag:1];
        [self.txtfldStartDate becomeFirstResponder];
        return NO;
   
    }
    
    if ([self.txtfldEndDate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
    {
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"please Select End Date"] AlertFlag:1 ButtonFlag:1];
        [self.txtfldEndDate becomeFirstResponder];
        return NO;
        
    }
    
    if (![self checkStartEndDate])
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"End Date Must be Greater than / Equal to Start Date"] AlertFlag:1 ButtonFlag:1];
        [self.txtfldEndDate becomeFirstResponder];
        return NO;
        
    }
    
    
    return YES;
  
}

- (BOOL)validateUrl:(NSURL *)candidate
{
    NSURLRequest *req = [NSURLRequest requestWithURL:candidate];
    return [NSURLConnection canHandleRequest:req];
}

-(BOOL)checkStartEndDate
{
    
    if (![_txtfldStartDate.text isEqualToString:@""] && ![_txtfldEndDate.text isEqualToString:@""])
    {
        return [self datecomapre:[NSString stringWithFormat:@"%@",_txtfldStartDate.text] endDate:[NSString stringWithFormat:@"%@",_txtfldEndDate.text]];
        
    }

    return NO;
}

-(BOOL)datecomapre:(NSString *)startDate endDate:(NSString *)endDate
{
    
    NSDateFormatter *dateFormatterForGettingDate = [[NSDateFormatter alloc] init];
    [dateFormatterForGettingDate setDateFormat:@"dd'/'MM'/'yyyy"];
    NSDate *dateFromStr = [dateFormatterForGettingDate dateFromString:startDate];
    NSDate *voteDate = [dateFormatterForGettingDate dateFromString:endDate];
    
    
    
    NSComparisonResult result;
    
    result = [dateFromStr compare:voteDate];
    
    BOOL type;
    
    if(result==NSOrderedAscending)
    {
        // NSLog(@"today is less");
        type= YES;
    }
    else if(result==NSOrderedDescending)
    {
        // NSLog(@"newDate is less");
        type= NO;
    }
    else
    {
        //  NSLog(@"Both dates are same");
        type= YES;
    }
    
    return type;
    
    
}



#pragma mark ------------- Click Events --------------

- (IBAction)clickBack:(id)sender
{
 
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSubmit:(id)sender
{
    if ([self AddpromotionValidation])
    {
        if (DELEGATE.connectedToNetwork)
        {
            
            if (isProduct)
            {
   
                [mc CreatePromotion:[USER_DEFAULTS valueForKey:@"userid"] type_id:promotionID promotion_type:@"P" company_name:[NSString stringWithFormat:@"%@",_txtfldCompanyName.text] description:[NSString stringWithFormat:@"%@",_txtFldDescription.text] location:[NSString stringWithFormat:@"%@",_txtfldLocation.text] latitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.latitude] : nil longitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.longitude] : nil website:[NSString stringWithFormat:@"%@",_txtfldWebsite.text] price:[NSString stringWithFormat:@"%@",_txtfldPrice.text] discount:[NSString stringWithFormat:@"%@",_txtfldDiscount.text] start_date:[NSString stringWithFormat:@"%f",startTime] end_date:[NSString stringWithFormat:@"%f",endTime] image:imageData Sel:@selector(addPromotion:)];
            }
            else{

                   [mc CreatePromotion:[USER_DEFAULTS valueForKey:@"userid"] type_id:promotionID promotion_type:@"S" company_name:[NSString stringWithFormat:@"%@",_txtfldCompanyName.text] description:[NSString stringWithFormat:@"%@",_txtFldDescription.text] location:[NSString stringWithFormat:@"%@",_txtfldLocation.text] latitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.latitude] : nil longitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.longitude] : nil website:[NSString stringWithFormat:@"%@",_txtfldWebsite.text] price:[NSString stringWithFormat:@"%@",_txtfldPrice.text] discount:[NSString stringWithFormat:@"%@",_txtfldDiscount.text] start_date:[NSString stringWithFormat:@"%f",startTime] end_date:[NSString stringWithFormat:@"%f",endTime] image:imageData Sel:@selector(addPromotion:)];
            
            }
  
        }
       
    }
   
}



- (IBAction)clickProduct:(id)sender
{
    
    isProduct=YES;
    
    [_bntProduct setImage:[UIImage imageNamed:@"radioIcon"] forState:UIControlStateNormal];
    [_bntService setImage:[UIImage imageNamed:@"radioUnSelected"] forState:UIControlStateNormal];
    
}

- (IBAction)clickService:(id)sender
{
    
    isProduct=NO;
    
    [_bntProduct setImage:[UIImage imageNamed:@"radioUnSelected"] forState:UIControlStateNormal];
    [_bntService setImage:[UIImage imageNamed:@"radioIcon"] forState:UIControlStateNormal];
   
    
    
}

#pragma ------------- UIImagePicker Delegate --------

- (IBAction)clickimgPromotions:(id)sender
{
    
    if (imageData)
    {

        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"],[localization localizedStringForKey:@"Remove Photo"], nil];
        [alert show];
        
    }
    else
    {
        
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
        [alert show];
        
        
    }
  
    pickerController = [[UIImagePickerController alloc]
                        init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    
}

- (IBAction)clickSave:(id)sender
{
    
    if ([self AddpromotionValidation])
    {
        if (DELEGATE.connectedToNetwork)
        {
            
            DELEGATE.isUpdatePromotions = YES;
            
            if (isProduct)
            {
        
                if (imageData)
                {
                    
                    
                    [mc EditPromotion:[USER_DEFAULTS valueForKey:@"userid"] promo_id:[NSString stringWithFormat:@"%@",gettedPromotionID] type_id:promotionID promotion_type:@"P" company_name:[NSString stringWithFormat:@"%@",_txtfldCompanyName.text] description:[NSString stringWithFormat:@"%@",_txtFldDescription.text] location:[NSString stringWithFormat:@"%@",_txtfldLocation.text] latitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.latitude] : nil longitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.longitude] : nil website:[NSString stringWithFormat:@"%@",_txtfldWebsite.text] price:[NSString stringWithFormat:@"%@",_txtfldPrice.text] discount:[NSString stringWithFormat:@"%@",_txtfldDiscount.text] start_date:[NSString stringWithFormat:@"%f",startTime] end_date:[NSString stringWithFormat:@"%f",endTime] image:imageData image_deleted:@"N" Sel:@selector(addPromotion:)];
                    
                }
                else{
                    
                     [mc EditPromotion:[USER_DEFAULTS valueForKey:@"userid"] promo_id:[NSString stringWithFormat:@"%@",gettedPromotionID] type_id:promotionID promotion_type:@"P" company_name:[NSString stringWithFormat:@"%@",_txtfldCompanyName.text] description:[NSString stringWithFormat:@"%@",_txtFldDescription.text] location:[NSString stringWithFormat:@"%@",_txtfldLocation.text] latitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.latitude] : nil longitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.longitude] : nil website:[NSString stringWithFormat:@"%@",_txtfldWebsite.text] price:[NSString stringWithFormat:@"%@",_txtfldPrice.text] discount:[NSString stringWithFormat:@"%@",_txtfldDiscount.text] start_date:[NSString stringWithFormat:@"%f",startTime] end_date:[NSString stringWithFormat:@"%f",endTime] image:imageData image_deleted:@"Y" Sel:@selector(addPromotion:)];
                    
                }
                
               
            }
            else{
                
                
                if (imageData)
                {
                   [mc EditPromotion:[USER_DEFAULTS valueForKey:@"userid"] promo_id:[NSString stringWithFormat:@"%@",gettedPromotionID] type_id:promotionID promotion_type:@"S" company_name:[NSString stringWithFormat:@"%@",_txtfldCompanyName.text] description:[NSString stringWithFormat:@"%@",_txtFldDescription.text] location:[NSString stringWithFormat:@"%@",_txtfldLocation.text] latitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.latitude] : nil longitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.longitude] : nil website:[NSString stringWithFormat:@"%@",_txtfldWebsite.text] price:[NSString stringWithFormat:@"%@",_txtfldPrice.text] discount:[NSString stringWithFormat:@"%@",_txtfldDiscount.text] start_date:[NSString stringWithFormat:@"%f",startTime] end_date:[NSString stringWithFormat:@"%f",endTime] image:imageData image_deleted:@"N" Sel:@selector(addPromotion:)];
                    
                }
                else{
                    
                      [mc EditPromotion:[USER_DEFAULTS valueForKey:@"userid"] promo_id:[NSString stringWithFormat:@"%@",gettedPromotionID] type_id:promotionID promotion_type:@"S" company_name:[NSString stringWithFormat:@"%@",_txtfldCompanyName.text] description:[NSString stringWithFormat:@"%@",_txtFldDescription.text] location:[NSString stringWithFormat:@"%@",_txtfldLocation.text] latitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.latitude] : nil longitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.longitude] : nil website:[NSString stringWithFormat:@"%@",_txtfldWebsite.text] price:[NSString stringWithFormat:@"%@",_txtfldPrice.text] discount:[NSString stringWithFormat:@"%@",_txtfldDiscount.text] start_date:[NSString stringWithFormat:@"%f",startTime] end_date:[NSString stringWithFormat:@"%f",endTime] image:imageData image_deleted:@"Y" Sel:@selector(addPromotion:)];
                    
                }
                
               
                
            }
            
        }
        
    }
  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(buttonIndex == 1)
    {
        pickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
        pickerController.allowsEditing = NO;
        [self presentViewController:pickerController animated:YES completion:nil];
        
    }
    if(buttonIndex == 2)
    {
        pickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
        pickerController.allowsEditing = NO;
        [self presentViewController:pickerController animated:YES completion:nil];
    }
    
    if(buttonIndex == 3)
    {
        [self.imgPromotion setImage:[UIImage imageNamed:@"placeholder"]];
        
        imageData = nil;
    }

}

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    
    if(image)
    {

        self.imgPromotion.image =[mc scaleAndRotateImage:image];
        
        imageData = UIImageJPEGRepresentation([mc scaleAndRotateImage:image], 1);
   
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



@end

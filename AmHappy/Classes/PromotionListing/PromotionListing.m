//
//  PromotionListing.m
//  
//
//  Created by Peerbits MacMini9 on 19/03/16.
//
//

#import "PromotionListing.h"
//#import "PromotionCellTableViewCell.h"
#import "addPromotion.h"
#import "NSString+HTML.h"
#import "PromotionCollectionViewCell.h"

@interface PromotionListing ()<UISearchBarDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
     ModelClass *mc;
    
    NSMutableArray *Promotions;
    
    int deleteIndex;
    
    BOOL isLoadMoreCalled;
    
    BOOL isLast,isSearch,isSearchTextChanging,isMyPromotion;
    
    NSTimer *myTimer;
    
    NSMutableArray *promotionTypes;
    
    UIPickerView *Picker;
    
    int promotionSelectedIndex;
    
    NSString *promotionID;
    
    CLLocation *loc;
    
    float lat;
    float longi;
    
    NSString *productService;
    

}

@end

@implementation PromotionListing

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
        {
            
            [self tabBarItem].selectedImage = [[UIImage imageNamed:@"promotionSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self tabBarItem].image = [[UIImage imageNamed:@"promotionUnSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else
        {
            [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"promotionSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"promotionUnSelected"]];
        }
        
        
    }
    
    self.title =[localization localizedStringForKey:@"Promotions"];
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //promotions
    
    //Manoj
    [self.cvPromotions registerNib:[UINib nibWithNibName:@"PromotionCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"PromotionCollectionViewCell"];
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.delegate = self;
    //tapGestureRecognizer.cancelsTouchesInView = YES;

    [self.viewFilter addGestureRecognizer:tapGestureRecognizer];

    
    
    [self initialSetup];
    
    [self getGetPromotions];
  
    
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != self.viewFilter) { // accept only touchs on superview, not accept touchs on subviews
        return NO;
    }
    
    return YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([touch.view isKindOfClass:[self.viewFIlterData class]])
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
//}

- (void)handleTap: (UITapGestureRecognizer *)recognizer
{
    UIView *view = [recognizer view];

    if (view == self.viewFilter)
    {
        [UIView animateWithDuration:0
                         animations:^{
                             self.viewFilterLeading.constant = 0;
                             
                             
                         }
                         completion:^(BOOL finished)
         {
             
             [UIView animateWithDuration:1.0
                              animations:^{
                                  
                                  self.viewFilterLeading.constant = 1500;
                              }];
         }];

        
    }
  
}

-(void)viewWillAppear:(BOOL)animated
{
    if (DELEGATE.isUpdatePromotions)
    {
        
        DELEGATE.isUpdatePromotions = NO;
        
        [self viewDidLoad];
        
    }
  
    
}

-(void)initialSetup
{
    
    if (loc != nil)
    {
        [self AddLocationClearButton];
        
    }
    else{
        
        [self removeLocationClearButton];
    }

    self.viewFilterLeading.constant = 1500;
    
    productService = nil;
    promotionID = nil;
    promotionSelectedIndex = -1;
    
    
   
    
    
 
    

    lat =DELEGATE.locationManager.location.coordinate.latitude;
    longi =DELEGATE.locationManager.location.coordinate.longitude;
    
    if (lat != 0 && longi != 0)
    {
        
        loc = [[CLLocation alloc] initWithLatitude:lat longitude:longi];
        
    }
    
    

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
    {
        
        [self.txtfldLocation setTintColor:[UIColor clearColor]];
        [self.txtfldCategory setTintColor:[UIColor clearColor]];
 
    }
    else
    {
        
        [[self.txtfldCategory valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
        [[self.txtfldLocation valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
 
    }

    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddPromotionLocationUpdate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdated:)
                                                 name:@"AddPromotionLocationUpdate"
                                               object:nil];

    
 
    
   
    
   // _txtfldCategory.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    
    Picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width, self.view.frame.size.height-150)];
    [Picker setBackgroundColor:[UIColor whiteColor]];
    Picker.showsSelectionIndicator = YES;
    Picker.delegate =self;
    Picker.dataSource =self;
    
    _txtfldCategory.inputView =Picker;
    

    
    isSearchTextChanging = NO;
    
    [self.lblNoPromotion setHidden:YES];

    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    
  
    deleteIndex = -1;
    
    Promotions = [[NSMutableArray alloc]init];
    
    isLast = YES;
    
    //isSearch = NO;
    
    self.searchPromotionHeight.constant = 0;
    

    
}



#pragma mark --------- Location Updated -------

-(void)locationUpdated:(NSNotification *)notification
{
    NSDictionary *json = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
    if(json.count>0)
    {
        loc = [[CLLocation alloc] initWithLatitude:[[json valueForKey:@"lat"] floatValue] longitude:[[json valueForKey:@"long"] floatValue]];
        self.txtfldLocation.text =[NSString stringWithFormat:@"%@",[json valueForKey:@"addressstr"]];
        
        [self AddLocationClearButton];
        
    }
}


#pragma mark ------- Textfield Delegate -----


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([_txtfldCategory isFirstResponder])
    {
        if ([promotionTypes count]>0)
        {
            if (promotionSelectedIndex >=0)
            {
                [_txtfldCategory setText:[[promotionTypes objectAtIndex:promotionSelectedIndex] valueForKey:@"name"]];
                
                promotionID =[[promotionTypes objectAtIndex:promotionSelectedIndex] valueForKey:@"id"];
                
            }
            
            
            
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
    if (textField==self.txtfldWords)
    {
        if([self.txtfldWords.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldWords setText:@""];
            
        }
        
    }
    
    if(textField==self.txtfldLocation)
    {
        if([self.txtfldLocation.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldLocation setText:@""];
            
        }
        
    }
    
    if (textField==self.txtfldCategory)
    {
        if([self.txtfldCategory.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<=0)
        {
            
            [self.txtfldCategory setText:@""];
            
        }
        
    }
   
}







-(void)getGetPromotions
{
    if ([DELEGATE connectedToNetwork])
    {
//        if (isSearch)
//        {
        
//        if (loc != nil)
//        {
        
        NSLog(@"%@",loc);
        
            [mc getPromotionList:[USER_DEFAULTS valueForKey:@"userid"] start:[NSString stringWithFormat:@"%lu",(unsigned long)Promotions.count] limit:@"10" keyword: self.txtfldWords.text != nil ? [NSString stringWithFormat:@"%@",self.txtfldWords.text] : nil latitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.latitude] : nil  longitude: loc != nil ? [NSString stringWithFormat:@"%f",loc.coordinate.longitude] : nil  type_id: promotionID != nil ? [NSString stringWithFormat:@"%@",promotionID] : nil promotion_type: productService != nil ? [NSString stringWithFormat:@"%@",productService] : nil my_promo: isMyPromotion ? @"Y" : @"N" Sel:@selector(promotionList:)];
//            
//        }
//        else
//        {
//             [mc getPromotionList:[USER_DEFAULTS valueForKey:@"userid"] start:[NSString stringWithFormat:@"%lu",(unsigned long)Promotions.count] limit:@"10" keyword: self.txtfldWords.text != nil ? [NSString stringWithFormat:@"%@",self.txtfldWords.text] : nil latitude: nil  longitude:nil   type_id: promotionID != nil ? [NSString stringWithFormat:@"%@",promotionID] : nil promotion_type: productService != nil ? [NSString stringWithFormat:@"%@",productService] : nil my_promo: isMyPromotion ? @"Y" : @"N" Sel:@selector(promotionList:)];
//         
//        }
  
//        }
//        else{
//            
//             [mc getPromotionList:[USER_DEFAULTS valueForKey:@"userid"] start:[NSString stringWithFormat:@"%lu",(unsigned long)Promotions.count] limit:@"10" keyword:@"" Sel:@selector(promotionList:)];
//        }
        
       
        
    }
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
        
        _txtfldCategory.text = [[promotionTypes objectAtIndex:row] valueForKey:@"name"] ;
        promotionID =[[promotionTypes objectAtIndex:row] valueForKey:@"id"];
    }
}



- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    int sectionWidth = ScreenSize.width;
    
    return sectionWidth;
}



#pragma mark ---------------- Get My Promotions --------------------

-(void)promotionList:(NSDictionary *)response
{

    NSLog(@"result is %@",response);
    
    isLoadMoreCalled = NO;
    
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        
        if ([DELEGATE connectedToNetwork])
        {
            [mc getPromotionTypes:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(promotionTypes:)];
            
            
        }
    

//        if (isSearchTextChanging)
//        {
//            Promotions = [[NSMutableArray alloc]init];
//            isSearchTextChanging = NO;
//        }
        

        [Promotions addObjectsFromArray:[response valueForKey:@"Promotion"]];
        
        if ([[response valueForKey:@"is_last"]isEqualToString:@"Y"])
        {
            
            isLast = YES;
            
        }
        else{
            
            isLast = NO;
            
        }
        
        if ([Promotions count]>0)
        {
            
             [self.lblNoPromotion setHidden:YES];
            
        }
        else{
            
            [self.lblNoPromotion setHidden:NO];
        }
        
  
        [_cvPromotions reloadData];
        
    }
    else
    {
        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
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



#pragma mark ---------- table view datasorce ----------

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [Promotions count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifre =@"PromotionCollectionViewCell";
    
    PromotionCollectionViewCell *cell =(PromotionCollectionViewCell *) [_cvPromotions dequeueReusableCellWithReuseIdentifier:cellIdentifre forIndexPath:indexPath];
 
    if (cell==nil)
    {
        NSArray *arrNib=[[NSBundle mainBundle] loadNibNamed:cellIdentifre owner:self options:nil];
        cell= (PromotionCollectionViewCell *)[arrNib objectAtIndex:0];
        
       
   
    }
    
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    /*if ([[[Promotions objectAtIndex:indexPath.row] valueForKey:@"is_creater"]isEqualToString:@"N"])
    {
        
        cell.btnDelete.hidden = YES;
        
    }
    else
    {
        
        cell.btnDelete.hidden = FALSE;
        
    }
    
    
    cell.btnDelete.tag = indexPath.row;
    
    [cell.btnDelete addTarget:self action:@selector(deletePromotion:) forControlEvents:UIControlEventTouchUpInside];
    */
    
    cell.imgPromotion.clipsToBounds = YES;
    
    if (![[[Promotions objectAtIndex:indexPath.row] valueForKey:@"image"]isEqualToString:@""])
    {
        
        [cell.imgPromotion sd_setImageWithURL:[NSURL URLWithString:[[Promotions objectAtIndex:indexPath.row] valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"event-img-placeholder"]];
    
    }
    else
    {
        
        [cell.imgPromotion setImage:[UIImage imageNamed:@"event-img-placeholder"]];
        
        
        
    }
    
    
    
    if ([[[Promotions objectAtIndex:indexPath.row] valueForKey:@"status"]isEqualToString:@"Active"])
    {
        
        [cell.imgGreenDot setImage:[UIImage imageNamed:@"greenDot"]];
        
    }
    else if ([[[Promotions objectAtIndex:indexPath.row] valueForKey:@"status"]isEqualToString:@"Inactive"])
    {
        
        [cell.imgGreenDot setImage:[UIImage imageNamed:@"redDot"]];
        
    }
    else
    {
        [cell.imgGreenDot setImage:[UIImage imageNamed:@"orangeDot"]];
 
    }
    
    
    UIFont *priceFont = [UIFont fontWithName:self.lblTopHeader.font.fontName size:20];
    NSString *string = [NSString stringWithFormat:@"%@%@",[EURO stringByConvertingHTMLToPlainText],[[[Promotions objectAtIndex:indexPath.row] valueForKey:@"price"] description]];
    CGSize BoundingBox = [string sizeWithFont:priceFont];
    
    CGFloat reqWidth = BoundingBox.width;
    
    if (reqWidth < ScreenSize.width/2)
    {
        
        cell.lblPriceWidth.constant = reqWidth;
        
    }
    else{
        
         cell.lblPriceWidth.constant = (ScreenSize.width/2)+10;
        
    }
    
   // price
    cell.lblPrice.text = [NSString stringWithFormat:@"%@%@",[EURO stringByConvertingHTMLToPlainText],[[[Promotions objectAtIndex:indexPath.row] valueForKey:@"discount"] description]];
    
    
    UIFont *yourFont = [UIFont fontWithName:self.lblTopHeader.font.fontName size:16];
   // UIFont *discountFont = [UIFont fontWithName:self.lblTopHeader.font.fontName size:16];
    
    NSString *text = [NSString stringWithFormat:@"%@%@",[EURO stringByConvertingHTMLToPlainText],[[[Promotions objectAtIndex:indexPath.row] valueForKey:@"price"] description]];
    CGSize Box = [text sizeWithFont:yourFont];
    
    CGFloat Width = Box.width;
    
    if (Width < ScreenSize.width/2)
    {
        
        cell.lblDiscountWidth.constant = Width;
        
    }
    else{
        
        cell.lblDiscountWidth.constant = (ScreenSize.width/2)+10;
        
    }
   // discount
    NSString *discountedAmount = [NSString stringWithFormat:@"%@%@",[EURO stringByConvertingHTMLToPlainText],[[[Promotions objectAtIndex:indexPath.row] valueForKey:@"price"] description]];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:discountedAmount];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:@2
                            range:NSMakeRange(0, [attributeString length])];
    cell.lblDiscount.attributedText = attributeString;
    
    
  
 UIFont *discountFont = [UIFont fontWithName:self.lblTopHeader.font.fontName size:16];
    //UIFont *yourFont = [UIFont fontWithName:self.lblTopHeader.font.fontName size:16];
    CGSize stringBoundingBox = [[[Promotions objectAtIndex:indexPath.row] valueForKey:@"company_name"] sizeWithFont:discountFont];
    
    CGFloat requiredWidth = stringBoundingBox.width;
 
    if (requiredWidth < ScreenSize.width-45)
    {
        cell.lblCompanyNameWidth.constant = requiredWidth;
        
    }
    else{
        
         cell.lblCompanyNameWidth.constant = ScreenSize.width-45;
        
    }
    
    [cell.lblCompanyname setText:[[Promotions objectAtIndex:indexPath.row] valueForKey:@"company_name"]];

    CGFloat requiredHeight = [self getDescriptionHeight:[[Promotions objectAtIndex:indexPath.row] valueForKey:@"description"]];
    
    if (requiredHeight <= 21)
    {
        cell.lblDescriptionHeight.constant = requiredHeight;
        cell.lblCompanyTop.constant = 125 + (45-requiredHeight);
        
    }
    else{
        
        cell.lblDescriptionHeight.constant = 45;
         cell.lblCompanyTop.constant = 125;
        
    }
    
    
    [cell.lblDescription setText:[[Promotions objectAtIndex:indexPath.row] valueForKey:@"description"]];
    
    //[cell.lblLocation setText:[[Promotions objectAtIndex:indexPath.row] valueForKey:@"location"]];
    
   // [cell.lblLocation setText:[[Promotions objectAtIndex:indexPath.row] valueForKey:@"location"]];
    
    
    
    [cell.lblType setText:[[Promotions objectAtIndex:indexPath.row] valueForKey:@"type_name"]];
    
    //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.lblPrice.layer.cornerRadius = cell.lblPriceWidth.constant * 10 / 100;
    cell.lblPrice.clipsToBounds = YES;
    
    cell.lblDiscount.layer.cornerRadius = cell.lblPriceWidth.constant * 10 / 100;
    cell.lblDiscount.clipsToBounds = YES;
    

    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = self.view.frame.size;
    return CGSizeMake((size.width -30)/2, 184);
}

-(CGFloat)getTextWidth:(NSString *)text label:(UILabel *)label
{
    if ([Promotions count]>0)
    {

        CGSize maximumSize = CGSizeMake(ScreenSize.width-100,21);
        
        UIFont *fontName;
        
        if (label.tag == 11)
        {
           fontName  = [UIFont fontWithName:self.lblTopHeader.font.fontName size:20];
            
        }
        else{
            
           fontName  = [UIFont fontWithName:self.lblTopHeader.font.fontName size:16];
            
        }
    
        CGRect labelHeighSize = [text boundingRectWithSize:maximumSize
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 
                                              attributes:@{NSFontAttributeName:fontName}
                                                 context:nil];

        return labelHeighSize.size.width;

        
    }
    else{
        
        return 0;
    }
  
}

-(CGFloat)getDescriptionHeight:(NSString *)text
{

    CGSize maximumSize = CGSizeMake(ScreenSize.width-30,45);
    
    UIFont *fontName = [UIFont fontWithName:self.lblTopHeader.font.fontName size:14];
    

    CGRect labelHeighSize = [text boundingRectWithSize:maximumSize
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                            attributes:@{NSFontAttributeName:fontName}
                                               context:nil];
    
    return labelHeighSize.size.height;
    
    
}

#pragma mark --------- Delete Promotion --------

-(void)deletePromotion:(UIButton *)sender
{
    
    deleteIndex = (int)sender.tag;
    
    [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Are you sure, you want to Delete this Promotion?"] AlertFlag:2 ButtonFlag:2];

}

-(void)cancelBtnTapped:(id)sender
{
   
    [[self.view viewWithTag:123] removeFromSuperview];
    
}


-(void)ok2BtnTapped:(id)sender
{

    [[self.view viewWithTag:123] removeFromSuperview];
    
    if (deleteIndex >= 0)
    {
        if(DELEGATE.connectedToNetwork)
        {
            [mc DeletePromotion:[USER_DEFAULTS valueForKey:@"userid"] promo_id:[NSString stringWithFormat:@"%@",[[Promotions objectAtIndex:deleteIndex] valueForKey:@"id"]] Sel:@selector(deletedPromotion:)];
            
        }
     
    }
    else{
        
        [DELEGATE showalert:self Message:@"Something Went Wrong!" AlertFlag:1 ButtonFlag:1];
        
    }
  
}

-(void)deletedPromotion:(NSDictionary *)response
{
    NSLog(@"result is %@",response);

    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {

        DELEGATE.isUpdatePromotions = YES;
        
        [self viewWillAppear:YES];
    
    }
    else
    {
        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
 
}

#pragma mark --------- tableview Delegate ---------

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    addPromotion *obj = [[addPromotion alloc]init];
    obj.isEdit = YES;
    
    obj.gettedPromotionID = [[NSString alloc]init];
    
    //NSLog(@"%@",[NSString stringWithFormat:@"%@",[[Promotions objectAtIndex:indexPath.row] valueForKey:@"id"]]);
    
    
    obj.gettedPromotionID = [NSString stringWithFormat:@"%@",[[Promotions objectAtIndex:indexPath.row] valueForKey:@"id"]];
    
    
    
    if ([[[Promotions objectAtIndex:indexPath.row] valueForKey:@"is_creater"]isEqualToString:@"N"])
    {
        obj.isMyPromotion = NO;
 
        if (![[[Promotions objectAtIndex:indexPath.row]valueForKey:@"website"]isEqualToString:@""])
        {
            
            if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@",[[Promotions objectAtIndex:indexPath.row]valueForKey:@"website"]]]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@",[[Promotions objectAtIndex:indexPath.row]valueForKey:@"website"]]]];
                
            }
            else{
                
               [DELEGATE showalert:self Message:@"No Valid Website Found!" AlertFlag:1 ButtonFlag:1];
                
            }
           
        }
        else{
            
              [DELEGATE showalert:self Message:@"No Website Found!" AlertFlag:1 ButtonFlag:1];
            
        }
    
    }
    else
    {
        obj.isMyPromotion = YES;
        
        [self.navigationController pushViewController:obj animated:YES];
        
        
    }
    
    
  
}

#pragma mark ------------ Search bar Delegate -------------------

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    
    //NSLog(@"Timer=%@",myTimer);
    if (myTimer)
    {
        if ([myTimer isValid])
        {
            [myTimer invalidate];
        }
        myTimer=nil;
    }
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(OnTextChange) userInfo:nil repeats:NO];
    
//    if ([searchText isEqualToString:@""])
//    {
//        [self.view endEditing:YES];
//        
//        Promotions = [[NSMutableArray alloc]init];
//        
//        [_tblPromotions reloadData];
//        
//        [self getGetPromotions];
//    
//    }
//    else{
//        
//          // isSearchTextChanging = YES;
//
//            Promotions = [[NSMutableArray alloc]init];
//        
//            [_tblPromotions reloadData];
//        
//            [self getGetPromotions];
//        
//    }
    
    
}

-(void)OnTextChange
{
    
        if ([_searchPromotions.text isEqualToString:@""])
        {
            [self.view endEditing:YES];
    
            Promotions = [[NSMutableArray alloc]init];
    
            [_cvPromotions reloadData];
    
            [self getGetPromotions];
    
        }
        else{
    
              // isSearchTextChanging = YES;
    
                Promotions = [[NSMutableArray alloc]init];
    
                [_cvPromotions reloadData];
            
                [self getGetPromotions];
            
        }
    
    
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
 
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
//    Promotions = [[NSMutableArray alloc]init];
//    
//    [_tblPromotions reloadData];
//    
//    [self getGetPromotions];
  
}

#pragma mark ---------- Load More --------------

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentOffset = scrollView.contentOffset.y;
     NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
     
     // Change 10.0 to adjust the distance from bottom
     if (maximumOffset - currentOffset <= 10.0)
     {
  
         
         if (!isLast)
         {
             
             if (!isLoadMoreCalled)
             {
           
                 isLoadMoreCalled = YES;
                 
                 
                 [self getGetPromotions];
                 
             }
             
         }
    
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

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSearch:(id)sender
{
    
//    if (isSearch)
//    {
//        isSearch = NO;
//        
//        self.viewFilterLeading.constant = 1500;
//        
////        Promotions = [[NSMutableArray alloc]init];
////        
////        [_tblPromotions reloadData];
//    
//       // [self getGetPromotions];
//    }
//    else{
    
        [self setSelectedCategory];
        
        //isSearch = YES;
        
        [UIView animateWithDuration:0
                         animations:^{ //self.viewFilter.alpha = 0;
                             self.viewFilterLeading.constant = 1500;
                         }
                         completion:^(BOOL finished)
        {
            
                             [UIView animateWithDuration:1.0
                                              animations:^{
                                                  //self.viewFilter.alpha = 1;
                                                  self.viewFilterLeading.constant = 0;
                                              }];
                         }];
        
        //self.viewFilterLeading.constant = 0;
        
      //  Promotions = [[NSMutableArray alloc]init];
        
       // [_tblPromotions reloadData];
      
       // [self getGetPromotions];
        
   // }
 
}


-(void)setSelectedCategory
{
    
    if ([promotionTypes count]>0)
    {
        
        if (promotionSelectedIndex >=0)
        {
        
        _txtfldCategory.text = [[promotionTypes objectAtIndex:promotionSelectedIndex] valueForKey:@"name"];
        promotionID = [[promotionTypes objectAtIndex:promotionSelectedIndex] valueForKey:@"id"];
            
        }
        else{
            
            _txtfldCategory.text = @"";
            promotionID = nil;
       
        }
    
    }
    
    
}

- (IBAction)clickAdd:(id)sender
{
    
    addPromotion *obj = [[addPromotion alloc]init];
    [self.navigationController pushViewController:obj animated:YES];
    
    
}

- (IBAction)clickMyPromotion:(id)sender
{
    
    if (isMyPromotion)
    {
        
        isMyPromotion = NO;
        [self.btnMyPromotion setImage:[UIImage imageNamed:@"tick1"] forState:UIControlStateNormal];
        
    }
    else{
        
        isMyPromotion = YES;
        [self.btnMyPromotion setImage:[UIImage imageNamed:@"tick2"] forState:UIControlStateNormal];
        
    }
    
    
}

- (IBAction)clickProduct:(id)sender
{
    
    productService = @"P";
    
    [self selectProduct];
 
}

- (IBAction)btnService:(id)sender
{
    productService = @"S";
    [self selectService];
}

-(void)DeselectProductService
{
    productService = nil;
    
    [self.btnProduct setImage:[UIImage imageNamed:@"radioUnSelected"] forState:UIControlStateNormal];
    
    [self.btnProduct setTitle:@" Prodcut" forState:UIControlStateNormal];

    [self.btnService setImage:[UIImage imageNamed:@"radioUnSelected"] forState:UIControlStateNormal];
    [self.btnService setTitle:@" Service" forState:UIControlStateNormal];
}

-(void)selectProduct
{
    
    productService = @"P";
    
    [self.btnProduct setImage:[UIImage imageNamed:@"radioIcon"] forState:UIControlStateNormal];
    
   [self.btnProduct setTitle:@" Prodcut" forState:UIControlStateNormal];
    
    
    
    [self.btnService setImage:[UIImage imageNamed:@"radioUnSelected"] forState:UIControlStateNormal];
    [self.btnService setTitle:@" Service" forState:UIControlStateNormal];
}

-(void)selectService
{
    productService = @"S";
    
    [self.btnProduct setImage:[UIImage imageNamed:@"radioUnSelected"] forState:UIControlStateNormal];
    
    [self.btnProduct setTitle:@" Prodcut" forState:UIControlStateNormal];

    [self.btnService setImage:[UIImage imageNamed:@"radioIcon"] forState:UIControlStateNormal];
    [self.btnService setTitle:@" Service" forState:UIControlStateNormal];
}


-(void)ResetLocation
{
    _txtfldLocation.text = @"";

    loc = nil;
    
}

-(void)ResetCategory
{
    _txtfldCategory.text = @"";
    
    promotionSelectedIndex = -1;

    promotionID = nil;
}

-(void)ResetMyPromotion
{
    isMyPromotion = NO;
    [self.btnMyPromotion setImage:[UIImage imageNamed:@"tick1"] forState:UIControlStateNormal];
  
}

-(void)ResetKeyword
{
    
    self.txtfldWords.text = @"";
}


-(void)ResetFilter
{
    
    [self ResetKeyword];
    
    [self ResetLocation];
   
    [self ResetCategory];

    [self DeselectProductService];
    
    [self ResetMyPromotion];

}

- (IBAction)clickReset:(id)sender
{
    [self ResetFilter];

}

-(void)removeLocationClearButton
{
    self.btnClearWidth.constant = 0;
}

-(void)AddLocationClearButton
{
    self.btnClearWidth.constant = 20;
}

- (IBAction)clickClear:(id)sender
{
    
    [self removeLocationClearButton];
    
    loc = nil;
    self.txtfldLocation.text = @"";
  
}
- (IBAction)clickApply:(id)sender
{

    Promotions = [[NSMutableArray alloc]init];
    
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0
                     animations:^{
                         self.viewFilterLeading.constant = 0;
                         
                         
                     }
                     completion:^(BOOL finished)
     {
         
         [UIView animateWithDuration:1.0
                          animations:^{
                              
                              self.viewFilterLeading.constant = 1500;
                          }];
     }];

    
    if ([DELEGATE connectedToNetwork])
    {

        [self getGetPromotions];
  
    }
  
}

- (IBAction)clickCancel:(id)sender
{
   // isSearch = NO;
    
    [UIView animateWithDuration:0
                     animations:^{
                         self.viewFilterLeading.constant = 0;
                         
                         
                     }
                     completion:^(BOOL finished)
     {
         
         [UIView animateWithDuration:1.0
                          animations:^{
                      
                              self.viewFilterLeading.constant = 1500;
                          }];
     }];

}
@end

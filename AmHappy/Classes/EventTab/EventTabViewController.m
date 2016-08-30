//
//  EventTabViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import "EventTabViewController.h"
#import "ModelClass.h"
#import "SeachAddressmapViewController.h"
#import "CategoryViewController.h"
#import "SBJSON.h"
#import "UIImageView+WebCache.h"
#import "HomeTabViewController.h"
#import "GuestViewController.h"
#import "TYMActivityIndicatorViewViewController.h"
#import "AppFriendViewControllerViewController.h"
#import "Guests.h"

@interface EventTabViewController ()

@end

@implementation EventTabViewController
{
    UIImagePickerController *pickerController;
    NSMutableArray *locationArray;
    NSMutableArray *dateArray;
    NSMutableArray *dateAndTimeArray;


    BOOL isPrivate;
    ModelClass *mc;
    UIDatePicker *datePicker1;
    UIDatePicker *datePicker2;
    UIDatePicker *timePicker1;
    UIDatePicker *timePicker2;

    float previousSize;

    UIToolbar *mytoolbar1;
    int categoryID;
    
    NSString *place;
    NSString *city;
    NSString *state;
    NSString *country;
    NSString *address;

    UIToolbar *mytoolbar2;
  
    double time;
    double time2;
    NSDate *maxDate;

    CLLocation *loc;
    NSData *imageData;
    NSString *currentEventId;
    
    double publicEventTime;

}
@synthesize lblLocation,lblPrivate,lblTitle,txtAmount,txtDate,txtDescription,txtName,btnCategory,publicView,scrollview,eventSwitch,imgEvent,lblselectedCategory,imgVoteCal,imgVotingDate,btnSubmit2,imgBG,placeImage;
@synthesize imgArrow,imgSeprator,btnCamera,isRepost;

@synthesize txtAmount2,txtDesc2,txtEventName2,tableview,privateView,txtEnd2,isEdit,eventId,btnBack,btnCreate;

@synthesize imgScroll,testImage,txtTime;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
        {
            
            [self tabBarItem].selectedImage = [[UIImage imageNamed:@"event.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self tabBarItem].image = [[UIImage imageNamed:@"event2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else
        {
            [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"event.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"event2.png"]];
        }
        
    }
    self.title =[localization localizedStringForKey:@"New Event"];


    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.txtDesc2.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.txtDescription.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.txtEventName2.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.txtName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
  
    time2 = 0;
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    currentEventId =[[NSString alloc] init];
    
    [self.imgScroll setHidden:YES];
    isPrivate =NO;
    [self.eventSwitch setOn:NO];
    categoryID =-1;
    imageData =[[NSData alloc] init];
    
    previousSize =750;
    
  /*  TYMActivityIndicatorViewViewController *indicatior =[[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:10.0 andMathod:nil];
    [indicatior showWithMessage:@"AmHappy" backgroundcolor:[UIColor blackColor]];*/
    
    [self.btnCreate.layer setMasksToBounds:YES];
    [self.btnCreate.layer setCornerRadius:3.0];
    
    [self.btnSubmit2.layer setMasksToBounds:YES];
    [self.btnSubmit2.layer setCornerRadius:3.0];
    
    [self localize];
    
    [self.tableview setScrollEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationChanged" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceieved:)
                                                 name:@"LocationUpdate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceieved2:)
                                                 name:@"LocationChanged"
                                               object:nil];
    
    //[self GetCurrentTimeStamp];
    
    
    place =[[NSString alloc] init];
    city =[[NSString alloc] init];
    state =[[NSString alloc] init];
    country =[[NSString alloc] init];
    address =[[NSString alloc] init];
    locationArray =[[NSMutableArray alloc] init];
    dateArray =[[NSMutableArray alloc] init];
    dateAndTimeArray =[[NSMutableArray alloc] init];

    [locationArray addObject:[self addLocationDictionary]];
    [dateAndTimeArray addObject:[self addDateDictionary]];
    [self.tableview reloadData];



    self.txtName.delegate =self;
    self.txtDescription.delegate =self;
    self.txtDate.delegate =self;
    self.txtAmount.delegate =self;
    
    
    self.txtEventName2.delegate =self;
    self.txtDesc2.delegate =self;
    self.txtAmount2.delegate =self;
    self.txtEnd2.delegate =self;
    [self.lblLocation setTextColor:[UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]];
    
    self.txtDescription.layer.masksToBounds = YES;
    self.txtDescription.layer.cornerRadius = 3.0;
    self.txtDescription.layer.borderWidth =1.1;
    self.txtDescription.layer.borderColor =[[UIColor colorWithRed:(214/255.f) green:(214/255.f) blue:(214/255.f) alpha:1.0f] CGColor];
    
    [self.txtDescription setDelegate:self];
    [self.txtDescription setText:[localization localizedStringForKey:@"Short Description or Message"]];
    [self.txtDescription setFont:FONT_Regular(14.0)];
    [self.txtDescription setTextColor:[UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]];
    
    
    self.txtDesc2.layer.masksToBounds = YES;
    self.txtDesc2.layer.cornerRadius = 3.0;
    self.txtDesc2.layer.borderWidth =1.1;
    self.txtDesc2.layer.borderColor =[[UIColor colorWithRed:(214/255.f) green:(214/255.f) blue:(214/255.f) alpha:1.0f] CGColor];
    
    [self.txtDesc2 setDelegate:self];
    [self.txtDesc2 setText:[localization localizedStringForKey:@"Short Description or Message"]];
    [self.txtDesc2 setFont:FONT_Regular(14.0)];
    [self.txtDesc2 setTextColor:[UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]];

   
    [self.scrollview setContentSize:CGSizeMake(320, 750)];
    
    [self.testImage setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
    
    [self.imgScroll setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width)];
   // self.automaticallyAdjustsScrollViewInsets = NO;

    
    
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
    
//    self.txtDate.inputAccessoryView =mytoolbar1;
//    self.txtName.inputAccessoryView =mytoolbar1;
//    self.txtDescription.inputAccessoryView =mytoolbar1;
//    self.txtAmount.inputAccessoryView =mytoolbar1;
//    self.txtTime.inputAccessoryView =mytoolbar1;
//
//    
//    self.txtEnd2.inputAccessoryView =mytoolbar1;
//    self.txtDesc2.inputAccessoryView =mytoolbar1;
//    self.txtEventName2.inputAccessoryView =mytoolbar1;
//    self.txtAmount2.inputAccessoryView =mytoolbar1;
    
  

   
    datePicker1 = [[UIDatePicker alloc]init];
    datePicker1.datePickerMode = UIDatePickerModeDate;
    datePicker1.minimumDate = [NSDate date];
    [datePicker1 setDate:[NSDate date]];
    [datePicker1 addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.txtDate setInputView:datePicker1];
    [self.txtEnd2 setInputView:datePicker1];
    
    datePicker2 = [[UIDatePicker alloc]init];
    datePicker2.datePickerMode = UIDatePickerModeDate;
    datePicker2.minimumDate = [NSDate date];
    [datePicker2 setDate:[NSDate date]];
    [datePicker2 addTarget:self action:@selector(updateTextField2:) forControlEvents:UIControlEventValueChanged];
    
    
    timePicker1 = [[UIDatePicker alloc]init];
    timePicker1.datePickerMode = UIDatePickerModeTime;
    timePicker1.minimumDate = [NSDate date];
    [timePicker1 setDate:[NSDate date]];
    [timePicker1 addTarget:self action:@selector(updateTextField2:) forControlEvents:UIControlEventValueChanged];
    
    timePicker2 = [[UIDatePicker alloc]init];
    timePicker2.datePickerMode = UIDatePickerModeTime;
    timePicker2.minimumDate = [NSDate date];
    [timePicker2 setDate:[NSDate date]];
    [timePicker2 addTarget:self action:@selector(updateTextField2:) forControlEvents:UIControlEventValueChanged];
    [self.txtTime setInputView:timePicker2];

    
    
    mytoolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    mytoolbar2.barStyle = UIBarStyleBlackOpaque;
    if(IS_OS_7_OR_LATER)
    {
        mytoolbar2.barTintColor=[UIColor colorWithRed:228.0/255.0 green:123.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    else
    {
        mytoolbar2.tintColor=[UIColor colorWithRed:228.0/255.0 green:123.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    
   
    UIBarButtonItem *done2 = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Done"]
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self action:@selector(donePressed)];
    [done2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];

    
    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
   
    mytoolbar2.items = [NSArray arrayWithObjects:flexibleSpace2,done2, nil];
    if(isEdit)
    {
        self.lblTitle.text =[localization localizedStringForKey:@"Edit Event"];
        [self callEventApi];
        [self.btnBack setHidden:NO];
    }
    else if (isRepost)
    {
        self.lblTitle.text =[localization localizedStringForKey:@"New Event"];
        
        [self callEventApi];
        
        [self.btnBack setHidden:NO];
    }
    
    
    self.const_EventNameHeight.constant = self.const_EventNameHeight.constant + 30;
    self.const_EventNameWidth.constant =  self.const_EventNameWidth.constant + 50;
    
    self.const_AmountHeight.constant = self.const_AmountHeight.constant + 30;
    self.const_AmountWidth.constant =  self.const_AmountWidth.constant + 50;
    
    self.const_DescriptionHeight.constant = self.const_DescriptionHeight.constant + 30;
    self.const_DescriptionWidtth.constant =  self.const_DescriptionWidtth.constant + 50;
    
    
    [self.lblEventName setTextColor:[UIColor lightGrayColor]];
    
    [self.lblDescription setTextColor:[UIColor lightGrayColor]];
    
    [self.lblAmount setTextColor:[UIColor lightGrayColor]];
    
    [self.lblAmount setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
    
    [self.lblDescription setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
    
    
    [self.lblEventName setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
    
    
    if(IS_Ipad)
    {
        [self setIpadSize];
    }

}
-(void)setIpadSize
{
     [self.scrollview setContentSize:CGSizeMake(320, 1380)];
    
    self.imgEvent.frame =CGRectMake(self.imgEvent.frame.origin.x, self.imgEvent.frame.origin.y, self.view.bounds.size.width, 650);
    
     self.testImage.frame =CGRectMake(self.imgEvent.frame.origin.x, self.imgEvent.frame.origin.y, self.view.bounds.size.width, 650);
    
    self.imgScroll.frame =CGRectMake(self.imgEvent.frame.origin.x, self.imgEvent.frame.origin.y, self.view.bounds.size.width, 650);
    
    self.placeImage.frame =CGRectMake(self.placeImage.frame.origin.x, self.placeImage.frame.origin.y, self.view.bounds.size.width, 650);
    
    self.btnCamera.frame =CGRectMake(self.btnCamera.frame.origin.x, 600, self.btnCamera.frame.size.width, self.btnCamera.frame.size.height);
    
    self.lblselectedCategory.frame =CGRectMake(self.lblselectedCategory.frame.origin.x, self.imgEvent.frame.origin.y+self.imgEvent.frame.size.height, self.lblselectedCategory.frame.size.width, self.lblselectedCategory.frame.size.height);
    
    self.btnCategory.frame =CGRectMake(self.btnCategory.frame.origin.x, self.imgEvent.frame.origin.y+self.imgEvent.frame.size.height, self.btnCategory.frame.size.width, self.btnCategory.frame.size.height);
    
    self.imgArrow.frame =CGRectMake(self.imgArrow.frame.origin.x, self.btnCategory.frame.origin.y+15, self.imgArrow.frame.size.width, self.imgArrow.frame.size.height);
    
    self.imgSeprator.frame =CGRectMake(self.imgSeprator.frame.origin.x, self.btnCategory.frame.origin.y+self.btnCategory.frame.size.height-5, self.imgSeprator.frame.size.width, self.imgSeprator.frame.size.height);
    
    self.lblPrivate.frame =CGRectMake(self.lblPrivate.frame.origin.x, self.btnCategory.frame.origin.y+self.btnCategory.frame.size.height-3, self.lblPrivate.frame.size.width, self.lblPrivate.frame.size.height);
    
   self.eventSwitch.frame =CGRectMake(self.eventSwitch.frame.origin.x, self.btnCategory.frame.origin.y+self.btnCategory.frame.size.height-3, self.eventSwitch.frame.size.width, self.eventSwitch.frame.size.height);
    
    self.privateView.frame =CGRectMake(self.privateView.frame.origin.x, self.lblPrivate.frame.origin.y+self.lblPrivate.frame.size.height, self.privateView.frame.size.width, self.privateView.frame.size.height);
    
    self.publicView.frame =CGRectMake(self.publicView.frame.origin.x, self.lblPrivate.frame.origin.y+self.lblPrivate.frame.size.height, self.publicView.frame.size.width, self.publicView.frame.size.height);
}
-(void)callEventApi
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc getEventDetail:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventId Sel:@selector(responseEventDetail:)];
    }
}
-(void)responseEventDetail:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        if (isRepost)
        {

            if([[[results valueForKey:@"Event"] valueForKey:@"type"] isEqualToString:@"Private"])
            {
                [self.btnSubmit2 setTitle:[localization localizedStringForKey:@"Create"] forState:UIControlStateNormal];
                
                
                isPrivate=YES;
                [self.eventSwitch setOn:YES];
                self.publicView.hidden=YES;
                self.privateView.hidden=NO;
                if(IS_Ipad)
                {
                    [self.scrollview setContentSize:CGSizeMake(320, 1500)];
                }
                else
                {
                    [self.scrollview setContentSize:CGSizeMake(320, 1150)];
                }
                
                
                //****** set amount ***
                
                
                self.txtAmount2.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
                
                self.txtAmount.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
                
                //***** Set Description ****
                
                self.txtDesc2.text =[[results valueForKey:@"Event"] valueForKey:@"description"];
                
                self.txtDescription.text =[[results valueForKey:@"Event"] valueForKey:@"description"];
                
                //***** Set Event name ***
                
                self.txtEventName2.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
                
                self.txtName.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
             
  
                if([[[results valueForKey:@"Event"] valueForKey:@"Location"] count]>0)
                {
                    [locationArray removeAllObjects];
                    for(int i=0;i<[[[results valueForKey:@"Event"] valueForKey:@"Location"] count];i++)
                    {
                        [locationArray addObject:[self addDictionary]];
                        
                    }
                    
                    for(int i=0;i<[[[results valueForKey:@"Event"] valueForKey:@"Location"] count];i++)
                    {
                        NSMutableDictionary *dict =[locationArray objectAtIndex:i];
                        [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"location"] forKey:@"location"];
                        
                        [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"latitude"] forKey:@"latitude"];
                        
                        [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"longitude"] forKey:@"longitude"];
                        
                        [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"id"] forKey:@"id"];
                        
                        [locationArray replaceObjectAtIndex:i withObject:dict];
                        
                    }
                }
                
   
                
                
                [self.tableview reloadData];
                
                
                
                
                
            }
            else if ([[[results valueForKey:@"Event"] valueForKey:@"type"] isEqualToString:@"Public"])
            {
                
                [self.btnCreate setTitle:[localization localizedStringForKey:@"Create"] forState:UIControlStateNormal];
                
                isPrivate=NO;
                [self.eventSwitch setOn:NO];
                self.publicView.hidden=NO;
                self.privateView.hidden=YES;
                if(IS_Ipad)
                {
                    [self.scrollview setContentSize:CGSizeMake(320, 1200)];
                }
                else
                {
                    [self.scrollview setContentSize:CGSizeMake(320, 750)];
                }
                
                //********* Set Amount ******
                
                self.txtAmount.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
                
                 self.txtAmount2.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
                
                //******* Set Description *****
                
                self.txtDescription.text =[[results valueForKey:@"Event"] valueForKey:@"description"];
                
                self.txtDesc2.text =[[results valueForKey:@"Event"] valueForKey:@"description"];
                
                //******** Set Event Name
             
                self.txtName.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
                self.txtEventName2.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
                
                

                address =[[results valueForKey:@"Event"] valueForKey:@"location"];
                self.lblLocation.text =[[results valueForKey:@"Event"] valueForKey:@"location"];
                [self.lblLocation setTextColor:[UIColor blackColor]];
                
                loc = [[CLLocation alloc] initWithLatitude:[[[results valueForKey:@"Event"] valueForKey:@"latitude"] floatValue] longitude:[[[results valueForKey:@"Event"] valueForKey:@"longitude"] floatValue]];
                self.txtDescription.textColor = [UIColor blackColor];
                
                
                
            }
            else
            {
                if([[[results valueForKey:@"Event"] valueForKey:@"event_type"] isEqualToString:@"PR"])
                {
                    [self.btnSubmit2 setTitle:[localization localizedStringForKey:@"Create"] forState:UIControlStateNormal];
                    
                    
                    isPrivate=YES;
                    [self.eventSwitch setOn:YES];
                    self.publicView.hidden=YES;
                    self.privateView.hidden=NO;
                    if(IS_Ipad)
                    {
                        [self.scrollview setContentSize:CGSizeMake(320, 1500)];
                    }
                    else
                    {
                        [self.scrollview setContentSize:CGSizeMake(320, 1150)];
                    }
                    
                    
                    //****** set amount ***
                    
                    
                    self.txtAmount2.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
                    
                    self.txtAmount.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
                    
                    //***** Set Description ****
                    
                    self.txtDesc2.text =[[results valueForKey:@"Event"] valueForKey:@"description"];
                    
                    self.txtDescription.text =[[results valueForKey:@"Event"] valueForKey:@"description"];
                    
                    //***** Set Event name ***
                    
                    self.txtEventName2.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
                    
                    self.txtName.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
                    
                    
                    if([[[results valueForKey:@"Event"] valueForKey:@"Location"] count]>0)
                    {
                        [locationArray removeAllObjects];
                        for(int i=0;i<[[[results valueForKey:@"Event"] valueForKey:@"Location"] count];i++)
                        {
                            [locationArray addObject:[self addDictionary]];
                            
                        }
                        
                        for(int i=0;i<[[[results valueForKey:@"Event"] valueForKey:@"Location"] count];i++)
                        {
                            NSMutableDictionary *dict =[locationArray objectAtIndex:i];
                            [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"location"] forKey:@"location"];
                            
                            [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"latitude"] forKey:@"latitude"];
                            
                            [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"longitude"] forKey:@"longitude"];
                            
                            [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"id"] forKey:@"id"];
                            
                            [locationArray replaceObjectAtIndex:i withObject:dict];
                            
                        }
                    }
            
                    [self.tableview reloadData];
                
                }
                else if ([[[results valueForKey:@"Event"] valueForKey:@"event_type"] isEqualToString:@"PB"])
                {
                    
                    [self.btnCreate setTitle:[localization localizedStringForKey:@"Create"] forState:UIControlStateNormal];
                    
                    isPrivate=NO;
                    [self.eventSwitch setOn:NO];
                    self.publicView.hidden=NO;
                    self.privateView.hidden=YES;
                    if(IS_Ipad)
                    {
                        [self.scrollview setContentSize:CGSizeMake(320, 1200)];
                    }
                    else
                    {
                        [self.scrollview setContentSize:CGSizeMake(320, 750)];
                    }
                    
                    //********* Set Amount ******
                    
                    self.txtAmount.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
                    
                    self.txtAmount2.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
                    
                    //******* Set Description *****
                    
                    self.txtDescription.text =[[results valueForKey:@"Event"] valueForKey:@"description"];
                    
                    self.txtDesc2.text =[[results valueForKey:@"Event"] valueForKey:@"description"];
                    
                    //******** Set Event Name
                    
                    self.txtName.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
                    self.txtEventName2.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
                    
                    
                    
                    address =[[results valueForKey:@"Event"] valueForKey:@"location"];
                    self.lblLocation.text =[[results valueForKey:@"Event"] valueForKey:@"location"];
                    [self.lblLocation setTextColor:[UIColor blackColor]];
                    
                    loc = [[CLLocation alloc] initWithLatitude:[[[results valueForKey:@"Event"] valueForKey:@"latitude"] floatValue] longitude:[[[results valueForKey:@"Event"] valueForKey:@"longitude"] floatValue]];
                    self.txtDescription.textColor = [UIColor blackColor];
                    
                    
                    
                }
             
            }
            
            if([[[results valueForKey:@"Event"] valueForKey:@"image"] length]>0)
            {

                
     
                [self.testImage sd_setImageWithURL:[NSURL URLWithString:[[results valueForKey:@"Event"] valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"YourPlaceholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                {
                    
                    [self.imgScroll setHidden:NO];
                    
                    self.placeImage.hidden =YES;
                    
                    
                    self.testImage.image =[mc scaleAndRotateImage:image];
                    self.testImage.contentMode = UIViewContentModeScaleAspectFill;
                    self.testImage.clipsToBounds = YES;
                    
                    float widthRatio = self.testImage.bounds.size.width / image.size.width;
                    float heightRatio = self.testImage.bounds.size.height / image.size.height;
                    
                    
                    float scale = MAX(widthRatio, heightRatio);
                    float imageWidth = scale * self.testImage.image.size.width;
                    float imageHeight = scale * self.testImage.image.size.height;
         
                    [self.imgScroll setContentSize:CGSizeMake( imageWidth, imageHeight)];

                    
                }];
                
               
            }
            
            
            self.lblselectedCategory.text =[localization localizedStringForKey:[[results valueForKey:@"Event"] valueForKey:@"category_name"]];
            
            
            [USER_DEFAULTS setValue:[[results valueForKey:@"Event"] valueForKey:@"category_id"] forKey:@"catid"];
            [USER_DEFAULTS synchronize];
        
            
        }
        else
        {
            //[self.eventSwitch setUserInteractionEnabled:NO];
            
            if([[[results valueForKey:@"Event"] valueForKey:@"type"] isEqualToString:@"Private"])
            {
                [self.btnSubmit2 setTitle:[localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];
                
                
                isPrivate=YES;
                [self.eventSwitch setOn:YES];
                self.publicView.hidden=YES;
                self.privateView.hidden=NO;
                if(IS_Ipad)
                {
                    [self.scrollview setContentSize:CGSizeMake(320, 1500)];
                }
                else
                {
                    [self.scrollview setContentSize:CGSizeMake(320, 1150)];
                }
                self.txtAmount2.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
                self.txtDesc2.text =[[results valueForKey:@"Event"] valueForKey:@"description"];
                self.txtEventName2.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
                
                
                
                NSNumber *endVoting = [[results valueForKey:@"Event"] valueForKey:@"voting_close_date"];
                
                
                if ([endVoting.description isEqualToString:@""])
                {
                    
                    
                }
                else{
                    
                    self.txtEnd2.text =[self getDate1:[[results valueForKey:@"Event"] valueForKey:@"voting_close_date"]];
                    
                }
                
                self.txtDesc2.textColor = [UIColor blackColor];
                time2=[[[results valueForKey:@"Event"] valueForKey:@"voting_close_date"] doubleValue];
                
                //  [locationArray addObjectsFromArray:[[results valueForKey:@"Event"] valueForKey:@"Location"]];
                
                if([[[results valueForKey:@"Event"] valueForKey:@"Date"] count]>0)
                {
                    //[dateArray removeAllObjects];
                    //[dateArray addObjectsFromArray:[[results valueForKey:@"Event"] valueForKey:@"Date"]];
                    
                    [dateAndTimeArray removeAllObjects];
                    
                    for(int i=0;i<[[[results valueForKey:@"Event"] valueForKey:@"Date"] count];i++)
                    {
                        [dateAndTimeArray addObject:[self addDateDictionary]];
                    }
                    for(int i=0;i<[[[results valueForKey:@"Event"] valueForKey:@"Date"] count];i++)
                    {
                        
                        NSMutableDictionary *dict =[dateAndTimeArray objectAtIndex:i];
                        [dict setValue:[NSString stringWithFormat:@"%@",[[[[results valueForKey:@"Event"] valueForKey:@"Date"] objectAtIndex:i] valueForKey:@"date"]] forKey:@"date"];
                        [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Date"] objectAtIndex:i] valueForKey:@"id"] forKey:@"id"];
                        
                        [dict setValue:[self getDate1:[[[[results valueForKey:@"Event"] valueForKey:@"Date"] objectAtIndex:i] valueForKey:@"date"]] forKey:@"dateold"];
                        
                        [dict setValue:[self getDate1:[[[[results valueForKey:@"Event"] valueForKey:@"Date"] objectAtIndex:i] valueForKey:@"date"]] forKey:@"dateDisplay"];
                        
                        [dict setValue:[self getDisplayTime:[[[[results valueForKey:@"Event"] valueForKey:@"Date"] objectAtIndex:i] valueForKey:@"date"]] forKey:@"timeDisplay"];
                        
                        [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Date"] objectAtIndex:i] valueForKey:@"date"] forKey:@"time"];
                        
                        [dateAndTimeArray replaceObjectAtIndex:i withObject:dict];
                    }
                }
                
                if([[[results valueForKey:@"Event"] valueForKey:@"Location"] count]>0)
                {
                    [locationArray removeAllObjects];
                    for(int i=0;i<[[[results valueForKey:@"Event"] valueForKey:@"Location"] count];i++)
                    {
                        [locationArray addObject:[self addDictionary]];
                        
                    }
                    
                    for(int i=0;i<[[[results valueForKey:@"Event"] valueForKey:@"Location"] count];i++)
                    {
                        NSMutableDictionary *dict =[locationArray objectAtIndex:i];
                        [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"location"] forKey:@"location"];
                        
                        [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"latitude"] forKey:@"latitude"];
                        
                        [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"longitude"] forKey:@"longitude"];
                        
                        [dict setValue:[[[[results valueForKey:@"Event"] valueForKey:@"Location"] objectAtIndex:i] valueForKey:@"id"] forKey:@"id"];
                        
                        [locationArray replaceObjectAtIndex:i withObject:dict];
                        
                    }
                }
                
                /* if(dateAndTimeArray.count>1 || locationArray.count>1)
                 {
                 if(dateAndTimeArray.count>1)
                 {
                 int count = (int)[dateAndTimeArray count];
                 [self setTableFrame:count];
                 
                 }
                 
                 if(locationArray.count>0)
                 {
                 int count = (int)[locationArray count];
                 
                 [self setTableFrame:count];
                 }
                 
                 }*/
                
                for(int i=0;i<dateAndTimeArray.count-1;i++)
                {
                    [self increaseHeight];
                }
                
                for(int i=0;i<locationArray.count-1;i++)
                {
                    [self increaseHeight];
                }
                
                
                
                [self.tableview reloadData];
                
                
                
                
                
            }
            else if ([[[results valueForKey:@"Event"] valueForKey:@"type"] isEqualToString:@"Public"])
            {
                
                [self.btnCreate setTitle:[localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];
                
                isPrivate=NO;
                [self.eventSwitch setOn:NO];
                self.publicView.hidden=NO;
                self.privateView.hidden=YES;
                if(IS_Ipad)
                {
                    [self.scrollview setContentSize:CGSizeMake(320, 1200)];
                }
                else
                {
                    [self.scrollview setContentSize:CGSizeMake(320, 750)];
                }
                self.txtAmount.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
                self.txtDescription.text =[[results valueForKey:@"Event"] valueForKey:@"description"];
                self.txtName.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
                self.txtDate.text =[self getDate1:[[results valueForKey:@"Event"] valueForKey:@"date"]];
                self.txtTime.text =[self getDisplayTime:[[results valueForKey:@"Event"] valueForKey:@"date"]];
                
                datePicker1.date =[self getDatetoPicker:[[results valueForKey:@"Event"] valueForKey:@"date"]];
                time=[[[results valueForKey:@"Event"] valueForKey:@"date"] doubleValue];
                publicEventTime=[[[results valueForKey:@"Event"] valueForKey:@"date"] doubleValue];
                address =[[results valueForKey:@"Event"] valueForKey:@"location"];
                self.lblLocation.text =[[results valueForKey:@"Event"] valueForKey:@"location"];
                [self.lblLocation setTextColor:[UIColor blackColor]];
                
                loc = [[CLLocation alloc] initWithLatitude:[[[results valueForKey:@"Event"] valueForKey:@"latitude"] floatValue] longitude:[[[results valueForKey:@"Event"] valueForKey:@"longitude"] floatValue]];
                self.txtDescription.textColor = [UIColor blackColor];
                
                
                
            }
            
            if([[[results valueForKey:@"Event"] valueForKey:@"image"] length]>0)
            {
                self.placeImage.hidden =YES;
                [self.imgEvent sd_setImageWithURL:[NSURL URLWithString:[[results valueForKey:@"Event"] valueForKey:@"image"]]];
            }
            
            
            self.lblselectedCategory.text =[localization localizedStringForKey:[[results valueForKey:@"Event"] valueForKey:@"category_name"]];
            
            
            [USER_DEFAULTS setValue:[[results valueForKey:@"Event"] valueForKey:@"category_id"] forKey:@"catid"];
            [USER_DEFAULTS synchronize];
         
            
        }
     
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
       /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
}
-(NSDate *)getDatetoPicker:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    return date;
    
}
-(NSString *)getDate1:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    // To parse the Date "Sun Jul 17 07:48:34 +0000 2011", you'd need a Format like so:
    
    //9 fer 2015
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    NSLog(@"date is %@",[NSString stringWithFormat:@"%@",formattedDate]);
    return [NSString stringWithFormat:@"%@",formattedDate];
}

-(NSString *)getDisplayTime:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    // To parse the Date "Sun Jul 17 07:48:34 +0000 2011", you'd need a Format like so:
    
    //9 fer 2015
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    NSLog(@"date is %@",[NSString stringWithFormat:@"%@",formattedDate]);
    return [NSString stringWithFormat:@"%@",formattedDate];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [datePicker2 setDate:[NSDate date]];
    [datePicker1 setDate:[NSDate date]];
    
     [self.imgEvent setFrame:CGRectMake(self.imgEvent.frame.origin.x, self.imgEvent.frame.origin.x, self.view.frame.size.width, self.imgEvent.frame.size.height)];

    [DELEGATE.tabBarController.tabBar setHidden:NO];
    if([USER_DEFAULTS valueForKey:@"catid"])
    {
        for(int i=0;i<DELEGATE.categoryDictionaryArray.count;i++)
        {
            if([[[DELEGATE.categoryDictionaryArray objectAtIndex:i] valueForKey:@"id"] integerValue]==[[USER_DEFAULTS valueForKey:@"catid"] integerValue])
            {
                
               // self.lblselectedCategory.text =[NSString stringWithFormat:@"%@",[[DELEGATE.categoryDictionaryArray objectAtIndex:i] valueForKey:@"Name"]];
                
                self.lblselectedCategory.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:[[DELEGATE.categoryDictionaryArray objectAtIndex:i] valueForKey:@"Name"]]];

            }
        }
    }
    else
    {
        [self.lblselectedCategory setText:[localization localizedStringForKey:@"Select Category"]];

    }
   
}

-(void)localize
{
    //self.title =[localization localizedStringForKey:@"New Event"];
    if(isEdit)
    {
        self.lblTitle.text =[localization localizedStringForKey:@"Edit Event"];
        
    }

//    [self.txtName setPlaceholder:[localization localizedStringForKey:@"Event Name"]];
//    [self.txtDate setPlaceholder:[localization localizedStringForKey:@"Date"]];
//    [self.txtTime setPlaceholder:[localization localizedStringForKey:@"Time"]];
//
//    [self.txtAmount setPlaceholder:[localization localizedStringForKey:@"Amount"]];
//    [self.txtDescription setText:[localization localizedStringForKey:@"Short Description or Message"]];
//    
//    [self.txtAmount2 setPlaceholder:[localization localizedStringForKey:@"Amount"]];
//    [self.txtDesc2 setText:[localization localizedStringForKey:@"Short Description or Message"]];
//    [self.txtEnd2 setPlaceholder:[localization localizedStringForKey:@"End Voting Date"]];
//    [self.txtEventName2 setPlaceholder:[localization localizedStringForKey:@"Event Name"]];

    
    [self.btnCreate setTitle:[localization localizedStringForKey:@"Create"] forState:UIControlStateNormal];
    [self.btnSubmit2 setTitle:[localization localizedStringForKey:@"Create"] forState:UIControlStateNormal];

   
    [self.lblPrivate setText:[localization localizedStringForKey:@"Private"]];
    [self.lblselectedCategory setText:[localization localizedStringForKey:@"Select Category"]];
    [self.lblLocation setText:[localization localizedStringForKey:@"Tap to add Location"]];
    
    
    [self.lblTitle setText:[localization localizedStringForKey:@"New Event"]];
    
    [self.tableview reloadData];

    
}
-(void)messageReceieved:(NSNotification *)notification
{
    NSDictionary *json = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
    if(json.count>0)
    {
        loc = [[CLLocation alloc] initWithLatitude:[[json valueForKey:@"lat"] floatValue] longitude:[[json valueForKey:@"long"] floatValue]];
        //        [addressDict setValue:[NSString stringWithFormat:@"%@ %@",ann.title,ann.subtitle] forKey:@"addressstr"];
        self.lblLocation.text =[NSString stringWithFormat:@"%@",[json valueForKey:@"addressstr"]];
        [self.lblLocation setTextColor:[UIColor blackColor]];

        address =[NSString stringWithFormat:@"%@",[json valueForKey:@"addressstr"]];


       // [self getAddressFromLatLon:loc];
    }
}
-(void)messageReceieved2:(NSNotification *)notification
{
    NSDictionary *json = [NSDictionary dictionaryWithDictionary:[notification userInfo]];
    if(json.count>0)
    {
       CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:[[json valueForKey:@"lat"] floatValue] longitude:[[json valueForKey:@"long"] floatValue]];
        
       // address =[NSString stringWithFormat:@"%@",[json valueForKey:@"addressstr"]];
        int tag =[[json valueForKey:@"tag"] intValue];
       if(tag!=locationArray.count)
        {
       

        
            NSMutableDictionary *dict =[locationArray objectAtIndex:tag];
            [dict setValue:[NSString stringWithFormat:@"%@",[json valueForKey:@"addressstr"]] forKey:@"location"];
            [dict setValue:[NSString stringWithFormat:@"%f",loc1.coordinate.latitude] forKey:@"latitude"];
            [dict setValue:[NSString stringWithFormat:@"%f",loc1.coordinate.longitude] forKey:@"longitude"];
            [locationArray replaceObjectAtIndex:tag withObject:dict];
            [self.tableview reloadData];
        }
        
        
        
    }
}
-(void)getAddressFromLatLon:(CLLocation*) location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(placemarks && placemarks.count > 0)
         {
             CLPlacemark *placemark= [placemarks objectAtIndex:0];
             //  NSLog(@"placemark %@",[placemarks objectAtIndex:0]);
             // address defined in .h file
           //  NSString *address = [NSString stringWithFormat:@"%@ , %@ , %@, %@", [placemark thoroughfare], [placemark locality], [placemark administrativeArea], [placemark country]];
             // NSLog(@"New Address Is:%@", address);
             if(placemark.thoroughfare )
             {
                 place =[placemark thoroughfare];
                 
             }
             else
             {
                 place =@"";
             }
             if(placemark.locality )
             {
                 city =[placemark locality];
                 
             }
             else
             {
                 city =@"";
             }
             if(placemark.administrativeArea)
             {
                 state =[placemark administrativeArea];
                 
             }
             else
             {
                 state =@"";
             }
             if(placemark.country )
             {
                 country =[placemark country];
                 
             }
             else
             {
                 country =@"";
             }
             
             self.lblLocation.text = [NSString stringWithFormat:@"%@ %@ %@ %@",place,city,state,country];
             [self.lblLocation setTextColor:[UIColor blackColor]];
         }
     }];
}

-(void)nextPressed
{
    if(isPrivate)
    {
        if ([txtEventName2 isFirstResponder])
        {
            [txtDesc2 becomeFirstResponder];
            return;
        }
        if ([txtDesc2 isFirstResponder])
        {
            [txtAmount2 becomeFirstResponder];
            return;
        }
        if ([txtAmount2 isFirstResponder])
        {
            [txtEnd2 becomeFirstResponder];
            return;
        }
    }
    else
    {
        if ([txtName isFirstResponder])
        {
            [txtDescription becomeFirstResponder];
            return;
        }
        if ([txtDescription isFirstResponder])
        {
            [txtDate becomeFirstResponder];
            return;
        }
        if ([txtDate isFirstResponder])
        {
            [txtTime becomeFirstResponder];
            return;
        }
        if ([txtTime isFirstResponder])
        {
            [txtAmount becomeFirstResponder];
            return;
        }
    }
    
   
    
}
-(void)previousPressed
{
    if(isPrivate)
    {
        if ([txtEnd2 isFirstResponder])
        {
            [txtAmount2 becomeFirstResponder];
            return;
        }
        if ([txtAmount2 isFirstResponder])
        {
            [txtDesc2 becomeFirstResponder];
            return;
        }
        if ([txtDesc2 isFirstResponder])
        {
            [txtEventName2 becomeFirstResponder];
            return;
        }
    }
    else
    {
        if ([txtAmount isFirstResponder])
        {
            [txtTime becomeFirstResponder];
            return;
        }
        if ([txtTime isFirstResponder])
        {
            [txtDate becomeFirstResponder];
            return;
        }
        if ([txtDate isFirstResponder])
        {
            [txtDescription becomeFirstResponder];
            return;
        }
        if ([txtDescription isFirstResponder])
        {
            [txtName becomeFirstResponder];
            return;
        }
    }
    
}

-(void)donePressed
{
    [self.view endEditing:YES];
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if([textField isEqual:self.txtName])
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_EventNameHeight.constant = self.const_EventNameHeight.constant - 30;
            self.const_EventNameWidth.constant =  self.const_EventNameWidth.constant - 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblEventName setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:12.0f]];
                                 
                                 [self.lblEventName setTextColor:[UIColor blackColor]];
                                 
                             }];
        }
        
        
        
    }
    else if ([textField isEqual:self.txtFldDescription])
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_DescriptionHeight.constant = self.const_DescriptionHeight.constant - 30;
            self.const_DescriptionWidtth.constant =  self.const_DescriptionWidtth.constant - 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblDescription setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:12.0f]];
                                 
                                 [self.lblDescription setTextColor:[UIColor blackColor]];
                             }];
        }
        
        
    }
    else if ([textField isEqual:self.txtAmount] )
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_AmountHeight.constant = self.const_AmountHeight.constant - 30;
            self.const_AmountWidth.constant =  self.const_AmountWidth.constant - 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblAmount setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:12.0f]];
                                 
                                 [self.lblAmount setTextColor:[UIColor blackColor]];
                             }];
        }
    }
    
    
    if ([txtAmount isFirstResponder] || [txtAmount2 isFirstResponder])
    {
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        
    }
    
    if(textField==self.txtTime)
    {
        timePicker2.date =datePicker1.date;
    }
   
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField isEqual:self.txtName])
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_EventNameHeight.constant = self.const_EventNameHeight.constant + 30;
            self.const_EventNameWidth.constant =  self.const_EventNameWidth.constant + 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblEventName setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
                                 
                                 [self.lblEventName setTextColor:[UIColor lightGrayColor]];
                             }];
        }
    }
    
    else if ([textField isEqual:self.txtFldDescription])
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_DescriptionHeight.constant = self.const_DescriptionHeight.constant + 30;
            self.const_DescriptionWidtth.constant =  self.const_DescriptionWidtth.constant + 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblDescription setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
                                 
                                 [self.lblDescription setTextColor:[UIColor lightGrayColor]];
                             }];
        }
        
    }
    else if ([textField isEqual:self.txtAmount])
    {
        if([self isEmpty:textField.text])
        {
            [self.view layoutIfNeeded];
            
            self.const_AmountHeight.constant = self.const_AmountHeight.constant + 30;
            self.const_AmountWidth.constant =  self.const_AmountWidth.constant + 50;
            
            
            [UIView animateWithDuration:0.5
                             animations:^{
                                 [self.view layoutIfNeeded]; // Called on parent view
                                 [self.lblAmount setFont:[UIFont fontWithName:@"AvenirLTStd-Roman" size:14.0f]];
                                 
                                 [self.lblAmount setTextColor:[UIColor lightGrayColor]];
                             }];
        }
        
    }
    
    if(textField.tag>=1000)
    {
        
            if(textField.text.length==0)
            {
               // textField.text =strAmount;
            }
        
            
        
            NSMutableDictionary *dict =[[NSMutableDictionary alloc]initWithDictionary:[dateAndTimeArray objectAtIndex:textField.tag-1000]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
            NSString *formattedDate = [dateFormatter stringFromDate:datePicker2.date];
        
           textField.text = [NSString stringWithFormat:@"%@",formattedDate];
        
            double timestamp = [self GetUTCDateTimeFromLocalTime:datePicker2.date];
        
                [dict setValue:[NSString stringWithFormat:@"%f",timestamp] forKey:@"dateold"];
                [dict setValue:textField.text forKey:@"dateDisplay"];
                [dateAndTimeArray replaceObjectAtIndex:textField.tag-1000 withObject:dict];
                [self.tableview reloadData];
        
        timePicker1.date =datePicker2.date;
        
        
    }
   else if(textField.tag>=200)
    {
        
        if(textField.text.length==0)
        {
            // textField.text =strAmount;
        }
        
        
        
        NSMutableDictionary *dict =[[NSMutableDictionary alloc]initWithDictionary:[dateAndTimeArray objectAtIndex:textField.tag-200]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm a"];
        NSString *formattedDate = [dateFormatter stringFromDate:timePicker1.date];
        textField.text = [NSString stringWithFormat:@"%@",formattedDate];
        double timestamp = [self GetUTCTimeFromLocalTime:timePicker1.date];
        [dict setValue:[NSString stringWithFormat:@"%f",[self GetUTCDateTimeFromLocalTime2:timePicker1.date]] forKey:@"time"];
        [dict setValue:[NSString stringWithFormat:@"%f",[self GetUTCDateTimeFromLocalTime2:timePicker1.date]] forKey:@"date"];
        [dict setValue:textField.text forKey:@"timeDisplay"];
        [dateAndTimeArray replaceObjectAtIndex:textField.tag-200 withObject:dict];
        [self.tableview reloadData];
        
        
    }
    else
    {
        if(textField==self.txtDate || textField==self.txtEnd2)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
            NSString *formattedDate = [dateFormatter stringFromDate:datePicker1.date];
            
            textField.text = [NSString stringWithFormat:@"%@",formattedDate];
            if(textField==self.txtDate)
            {
                time =[self GetUTCDateTimeFromLocalTime:datePicker1.date];
                timePicker2.date =datePicker1.date;
                publicEventTime = [self GetUTCTimeForPublic:timePicker2.date];


            }
            else
            {
                time2 =[self GetUTCDateTimeFromLocalTime:datePicker1.date];

            }

        }
        
        if(textField==self.txtTime)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm a"];
            NSString *formattedDate = [dateFormatter stringFromDate:timePicker2.date];
            textField.text = [NSString stringWithFormat:@"%@",formattedDate];
            publicEventTime = [self GetUTCTimeForPublic:timePicker2.date];
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
/*
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
   /* NSLog(@"class is %@",[sender class]);
    
    if (self.txtEventName2.isFirstResponder || self.txtName.isFirstResponder ||self.txtDesc2.isFirstResponder || self.txtDescription.isFirstResponder)
    {

       /* [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[UIMenuController sharedMenuController] setMenuVisible:YES animated:NO];
        }];
        
        return [super canPerformAction:action withSender:sender];*/
        /*return YES;
    }
    else
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
        }];
        
        return [super canPerformAction:action withSender:sender];
    }*/

    
   
    
   
//}*/
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if(isPrivate)
    {
        if (self.txtDesc2.textColor == [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]) {
            self.txtDesc2.text = @"";
            self.txtDesc2.textColor = [UIColor blackColor];
        }
    }
    else
    {
        if (self.txtDescription.textColor == [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]) {
            self.txtDescription.text = @"";
            self.txtDescription.textColor = [UIColor blackColor];
        }
    }
    
    
    return YES;
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


-(void) textViewDidChange:(UITextView *)textView
{
    if(isPrivate)
    {
        if(self.txtDesc2.text.length == 0){
            //self.txtDesc2.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
            [self.txtDesc2 setText:[localization localizedStringForKey:@"Short Description or Message"]];

           // self.txtDesc2.text = [localization localizedStringForKey:@"Desciption"];
            self.txtDesc2.textColor=[UIColor blackColor];
            [self.txtDesc2 resignFirstResponder];
        }
    }
    else
    {
        if(self.txtDescription.text.length == 0){
          //  self.txtDescription.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
            [self.self.txtDescription setText:[localization localizedStringForKey:@"Short Description or Message"]];

           // self.txtDescription.text = [localization localizedStringForKey:@"Desciption"];
            self.txtDescription.textColor=[UIColor blackColor];

            [self.txtDescription resignFirstResponder];
        }
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length)
        return YES;
    
    if (textField == self.txtAmount2 || textField == self.txtAmount)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
    }
    return YES;
}


#pragma mark ------- Textfield Delegate -----

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if(isPrivate)
    {
        if([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] <=0)
        {
            self.txtDesc2.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
            self.txtDesc2.text = [localization localizedStringForKey:@"Short Description or Message"];
            
        }
        else
        {
            if(![textView.text isEqualToString:[localization localizedStringForKey:@"Short Description or Message"]])
            {
                self.txtDesc2.textColor = [UIColor blackColor];
            }
        }
    }
    else
    {
        if([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] <=0)
        {
            self.txtDescription.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
            self.txtDescription.text = [localization localizedStringForKey:@"Short Description or Message"];
            
        }
        else
        {
            if(![textView.text isEqualToString:[localization localizedStringForKey:@"Short Description or Message"]])
            {
                self.txtDescription.textColor = [UIColor blackColor];
                
            }
        }
    }
   
    
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    
    
    if([textView.text isEqualToString:[localization localizedStringForKey:@"Short Description or Message"]])
    {
        textView.text=@"";
        [textView setTextColor:[UIColor blackColor]];
    }
    else
    {
        [textView setTextColor:[UIColor blackColor]];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 40)];
    UILabel *title =[[UILabel alloc] init];
    [title setFrame:CGRectMake(0,0,self.view.frame.size.width, 40)];
    
    
    if(section==0)
    {
        [title setText:[localization localizedStringForKey:@"Date & Time"]];
    }
    else if (section==1)
    {
        [title setText:[localization localizedStringForKey:@"Location"]];
        
    }
    [headerView setBackgroundColor:[UIColor colorWithRed:(228/255.f) green:(123/255.f) blue:(0/255.f) alpha:1.0f]];
    [title setTextColor:[UIColor whiteColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    
    [headerView addSubview:title];
    
    return headerView;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
   
            return 80;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 80)];
    
    
    UILabel *title =[[UILabel alloc] init];
    
    UIButton *button = [[UIButton alloc] init];
    [button addTarget:self
               action:@selector(addTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake((self.view.frame.size.width/2)-22, 10, 45, 45.0);
    [button setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    button.tag =section;
    [headerView addSubview:button];
    [title setFrame:CGRectMake(0,60,self.view.frame.size.width, 20)];
    
    if(section==0)
    {
        [title setText:[localization localizedStringForKey:@"Add Date & Time"]];
        if(dateAndTimeArray.count==5)
        {
            [button setUserInteractionEnabled:NO];
            [button setEnabled:NO];

        }
        else
        {
            [button setUserInteractionEnabled:YES];
            [button setEnabled:YES];

        }
    }
    else if (section==1)
    {
        [title setText:[localization localizedStringForKey:@"Add Location"]];
        if(locationArray.count==5)
        {
            [button setUserInteractionEnabled:NO];
            [button setEnabled:NO];
        }
        else
        {
            [button setUserInteractionEnabled:YES];
            [button setEnabled:YES];
        }
        
    }
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [title setTextColor:[UIColor colorWithRed:(228/255.f) green:(123/255.f) blue:(0/255.f) alpha:1.0f]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:FONT_Regular(12.0)];
    [headerView addSubview:title];
    
    return headerView;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        if(dateAndTimeArray.count>0)
        {
            return dateAndTimeArray.count;
        }
        else return 0;    }
    else if(section==1)
    {
        if(locationArray.count>0)
        {
            return locationArray.count;
        }
        else return 0;
    }
   
    
    else return 0;
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        DateCell *cell = (DateCell *)[tableView dequeueReusableCellWithIdentifier:nil];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DateCell" owner:self options:nil];
            cell=[nib objectAtIndex:0] ;
        }
        cell.delegate=self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.lblCellTitle.text =[NSString stringWithFormat:@"%@ %d",[localization localizedStringForKey:@"Date & Time"],(int)indexPath.row+1];
        
        [cell.txtDate setPlaceholder:[localization localizedStringForKey:@"Date"]];
        [cell.txtTime setPlaceholder:[localization localizedStringForKey:@"Time"]];

        
         cell.txtDate.tag =1000+indexPath.row;
         cell.txtDate.delegate=self;
         cell.txtDate.inputView =datePicker2;
         cell.txtDate.inputAccessoryView =mytoolbar2;
        
        cell.txtTime.tag =200+indexPath.row;
        cell.txtTime.delegate=self;
        cell.txtTime.inputView =timePicker1;
        cell.txtTime.inputAccessoryView =mytoolbar2;
        
        if([[[dateAndTimeArray objectAtIndex:indexPath.row] valueForKey:@"dateDisplay"] length]>0)
        {
              cell.txtDate.text =[[dateAndTimeArray objectAtIndex:indexPath.row] valueForKey:@"dateDisplay"];
        }
        
        if([[[dateAndTimeArray objectAtIndex:indexPath.row] valueForKey:@"timeDisplay"] length]>0)
        {
            cell.txtTime.text =[[dateAndTimeArray objectAtIndex:indexPath.row] valueForKey:@"timeDisplay"];
        }


        return cell;
    }
    else
    {
        LocationCell2 *cell = (LocationCell2 *)[tableView dequeueReusableCellWithIdentifier:nil];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LocationCell2" owner:self options:nil];
            cell=[nib objectAtIndex:0] ;
        }
        cell.delegate=self;
               
        
        [cell.lblLocation setText:[localization localizedStringForKey:@"Location"]];
        
        cell.btnLocation.layer.borderWidth = 0.5;
        cell.btnLocation.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        cell.btnLocation.layer.cornerRadius = 5;//half of the width
        
        
        cell.btnLocation.tag=indexPath.row;
        cell.btnCancel.tag=indexPath.row;
       
        
        cell.lblCellTitle.text =[NSString stringWithFormat:@"%@%d",[localization localizedStringForKey:@"Location"],(int)indexPath.row+1];
        
        
        if([[[locationArray objectAtIndex:indexPath.row] valueForKey:@"location"] length]>0)
        {
            cell.lblLocation.text =[[locationArray objectAtIndex:indexPath.row] valueForKey:@"location"];
            [cell.lblLocation setTextColor:[UIColor blackColor]];
        }
        
       
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
    
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 80;
    
    
}
-(void)cancelDateTapped:(UIButton *)sender
{
    [self descreaseHeight];
    [dateAndTimeArray removeObjectAtIndex:[sender tag]];
    [self.tableview reloadData];
}
-(void)cancelTapped:(UIButton *)sender
{
    [self descreaseHeight];
    [locationArray removeObjectAtIndex:[sender tag]];
    [self.tableview reloadData];
}
-(void)locTapped:(UIButton *)sender
{
    SeachAddressmapViewController *searchVC =[[SeachAddressmapViewController alloc] initWithNibName:@"SeachAddressmapViewController" LoadFlag:(int)[sender tag]  bundle:nil];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateTextField:(id)sender
{
    NSLog(@"%@",[sender class]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:datePicker1.date];
    if(isPrivate)
    {
        self.txtEnd2.text = [NSString stringWithFormat:@"%@",formattedDate];
      //  NSTimeInterval ti = [datePicker1.date timeIntervalSince1970];
        time2 =[self GetUTCDateTimeFromLocalTime:datePicker1.date];
        //[datePicker1 setDate:[NSDate date]];

    }
    else
    {
        self.txtDate.text = [NSString stringWithFormat:@"%@",formattedDate];
        //NSTimeInterval ti = [datePicker1.date timeIntervalSince1970];
        time =[self GetUTCDateTimeFromLocalTime:datePicker1.date];
        //[datePicker1 setDate:[NSDate date]];

    }
    
}
- (double) GetUTCDateTimeFromLocalTime2:(NSDate *)IN_strLocalTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy hh:mm a"];
    // NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *strDateTime   = [dateFormatter stringFromDate:IN_strLocalTime];
    NSDate *objUTCDate  = [dateFormatter dateFromString:strDateTime];
    double seconds = (long long)([objUTCDate timeIntervalSince1970] );
    
    NSString *strTimeStamp = [NSString stringWithFormat:@"%f",seconds];
    NSLog(@"The Timestamp is = %@",strTimeStamp);
    return seconds;
}
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
- (double) GetUTCTimeFromLocalTime:(NSDate *)IN_strLocalTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    // NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *strDateTime   = [dateFormatter stringFromDate:IN_strLocalTime];
    NSDate *objUTCDate  = [dateFormatter dateFromString:strDateTime];
    double seconds = (long long)([objUTCDate timeIntervalSince1970] );
    
    NSString *strTimeStamp = [NSString stringWithFormat:@"%f",seconds];
    NSLog(@"The Timestamp is = %@",strTimeStamp);
    return seconds;
}

- (double)GetUTCTimeForPublic:(NSDate *)IN_strLocalTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy hh:mm a"];
    // NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *strDateTime   = [dateFormatter stringFromDate:IN_strLocalTime];
    NSDate *objUTCDate  = [dateFormatter dateFromString:strDateTime];
    double seconds = (long long)([objUTCDate timeIntervalSince1970] );
    
    NSString *strTimeStamp = [NSString stringWithFormat:@"%f",seconds];
    NSLog(@"The Timestamp is = %@",strTimeStamp);
    return seconds;
}
-(void)updateTextField2:(id)sender
{
    /*NSLog(@"%@",[sender class]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MM'/'dd'/'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:datePicker1.date];*/
    
    /*    self.txtEnd2.text = [NSString stringWithFormat:@"%@",formattedDate];
        NSTimeInterval ti = [datePicker1.date timeIntervalSince1970];
        time2 =ti/1000;*/
   
    
}

- (IBAction)cameraTapped:(id)sender
{
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
    [alert show];
    pickerController = [[UIImagePickerController alloc]
                        init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
}
- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    
    if(image)
    {
        [self.imgScroll setHidden:NO];

        self.placeImage.hidden =YES;
        
        self.testImage.image =[mc scaleAndRotateImage:image];
        self.testImage.contentMode = UIViewContentModeScaleAspectFill;
        self.testImage.clipsToBounds = YES;
     
        float widthRatio = self.testImage.bounds.size.width / image.size.width;
        float heightRatio = self.testImage.bounds.size.height / image.size.height;
        
        
        float scale = MAX(widthRatio, heightRatio);
        float imageWidth = scale * self.testImage.image.size.width;
        float imageHeight = scale * self.testImage.image.size.height;
        
        //self.testImage.frame = CGRectMake(0, 0, imageWidth, imageHeight);
      //  self.testImage.center = self.testImage.superview.center;
        [self.imgScroll setContentSize:CGSizeMake( imageWidth, imageHeight)];



    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(UIImage*)imageWithImage:(UIImage*)image
             scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (void)inviteBtnTapped:(id)sender
{


    
    
    [[self.view viewWithTag:191] removeFromSuperview];
    
//    AppFriendViewControllerViewController *objVC = [[AppFriendViewControllerViewController alloc]init];
//    
//    objVC.isHideBtnAdd = YES;
//    
//    objVC.eventID = [[NSString alloc]init];
//    
//    objVC.eventID = currentEventId;
//    
//    [self.navigationController pushViewController:objVC animated:YES];
    
    
    
    Guests *guestVC =[[Guests alloc] initWithNibName:@"Guests" bundle:nil];
    
    guestVC.eventId = currentEventId;
    
    guestVC.isMyEvent = YES;
    
    [self.navigationController pushViewController:guestVC animated:YES];
 
    
//    GuestViewController *guestVC =[[GuestViewController alloc] init];
//    
//    guestVC.eventID = currentEventId;
//    guestVC.eventType = @"Y";
//   // [guestVC setEventID:currentEventId];
//    [guestVC setIsMy:YES];
//    [guestVC setIsPrivate:isPrivate];
//    [guestVC setIsFromChat:NO];
//
//    [self.navigationController pushViewController:guestVC animated:YES];
    
    [self clearAllData1];

}
- (void)laterBtnTapped:(id)sender
{
    [self clearAllData1];
    [[self.view viewWithTag:191] removeFromSuperview];
    BOOL found =NO;
    NSLog(@"navigation are %@",self.navigationController.viewControllers);
    //  UINavigationController *controller =[[DELEGATE.tabBarController viewControllers] objectAtIndex:0];
    for(int i=0; i<self.navigationController.viewControllers.count;i++)
    {
        if([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[HomeTabViewController class]])
        {
            found =YES;
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i] animated:NO];
            
            break;
            
        }
    }
    if(!found)
    {
        
        [DELEGATE.tabBarController setSelectedIndex:0];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==151)
    {
        if(buttonIndex==0)
        {
            GuestViewController *guestVC =[[GuestViewController alloc] initWithNibName:@"GuestViewController" bundle:nil];
            [guestVC setEventID:currentEventId];
            [guestVC setIsMy:YES];
            [guestVC setIsPrivate:isPrivate];
            [guestVC setIsFromChat:NO];

            [self.navigationController pushViewController:guestVC animated:YES];
        }
        else
        {
            BOOL found =NO;
            NSLog(@"navigation are %@",self.navigationController.viewControllers);
            //  UINavigationController *controller =[[DELEGATE.tabBarController viewControllers] objectAtIndex:0];
            for(int i=0; i<self.navigationController.viewControllers.count;i++)
            {
                if([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[HomeTabViewController class]])
                {
                    found =YES;
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:i] animated:NO];
                    
                    break;
                    
                }
            }
            if(!found)
            {
                
                [DELEGATE.tabBarController setSelectedIndex:0];
            }
        }
        
        [self clearAllData1];
        
    }
    else
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
    
    
    
    
    
}

- (IBAction)categoryTapped:(id)sender
{
  //  [USER_DEFAULTS removeObjectForKey:@"catid"];
  //  [USER_DEFAULTS synchronize];
    [self.view endEditing:YES];

    CategoryViewController *catVC =[[CategoryViewController alloc] initWithNibName:@"CategoryViewController" bundle:nil];
    [catVC setIsMultiSelect:NO];
    [self.navigationController pushViewController:catVC animated:YES];
}
- (IBAction)eventChanged:(UISwitch *)sender
{

    if (sender.isOn)
    {
        isPrivate=YES;
        self.publicView.hidden=YES;
        self.privateView.hidden=NO;
        
       
        if(![txtDesc2.text isEqualToString:[localization localizedStringForKey:@"Short Description or Message"]])
        {
            self.txtDesc2.textColor = [UIColor blackColor];
        }
        else if(![txtDescription.text isEqualToString:[localization localizedStringForKey:@"Short Description or Message"]])
        {
            self.txtDescription.textColor = [UIColor blackColor];
        }
        
        
        
        
        

        if(IS_Ipad)
        {
            if(previousSize==750)
            {
                previousSize =1500;
            }
            [self.scrollview setContentSize:CGSizeMake(320, previousSize)];
        }
        else
        {
            if(previousSize==750)
            {
                previousSize =1150;
            }
            [self.scrollview setContentSize:CGSizeMake(320, previousSize)];
        }
    }
    else
    {
        isPrivate=NO;
        self.publicView.hidden=NO;
        self.privateView.hidden=YES;
        

        if(IS_Ipad)
        {
            [self.scrollview setContentSize:CGSizeMake(320, 1100)];
        }
        else
        {
            [self.scrollview setContentSize:CGSizeMake(320, 750)];
        }
       // datePicker1.maximumDate = [NSDate date];

    }
}
- (IBAction)locationTapped:(id)sender
{
    [self.view endEditing:YES];
    SeachAddressmapViewController *searchVC =[[SeachAddressmapViewController alloc] initWithNibName:@"SeachAddressmapViewController" bundle:nil];
    [self.navigationController pushViewController:searchVC animated:YES];
}
-(BOOL)checkValidation
{
    [self.view endEditing:YES];
    NSString *name = [self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  /*  NSString *desc = [self.txtDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([desc isEqualToString:@"Short Desciption or Message"])
    {
        desc=@"";
    }*/
    NSString *date = [self.txtDate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   // NSString *amount = [self.txtAmount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([USER_DEFAULTS valueForKey:@"catid"])
    {
        categoryID =[[USER_DEFAULTS valueForKey:@"catid"] intValue];
    }
    
    
    
    if([name length] <= 0 || [date length]<= 0 || [address length]<= 0 || categoryID<=0)
    {
         if(categoryID<=0)
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please select Category"] AlertFlag:1 ButtonFlag:1];

          
            return FALSE;
        }
        else if(name.length <=0 )
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Pleas enter Event Name"] AlertFlag:1 ButtonFlag:1];
       
            return FALSE;
        }
      /*  else  if(desc.length <=0)
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter Description"] AlertFlag:1 ButtonFlag:1];
           
            
            return FALSE;
        }*/
        else  if(date.length <=0)
        {
             [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please select Date"] AlertFlag:1 ButtonFlag:1];
            
            return FALSE;
        }
        else  if(address.length <=0)
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please select Location"] AlertFlag:1 ButtonFlag:1];
            
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
- (IBAction)submitTapped:(id)sender
{
    if([self checkValidation])
    {
        if(DELEGATE.connectedToNetwork)
        {
            if(self.testImage.image)
            {
      
                UIGraphicsBeginImageContextWithOptions(self.imgScroll.bounds.size,
                                                       YES,
                                                       [UIScreen mainScreen].scale);
                
                //this is the key
                CGPoint offset=self.imgScroll.contentOffset;
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y);
                
                [self.imgScroll.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *visibleScrollViewImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                imageData =UIImageJPEGRepresentation(visibleScrollViewImage, 1.0);
                
                NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)imageData.length/1024/1024);

                
                    // do something with the viewImage here.
               

              //  return;

            }
            else
            {
                imageData=nil;
            }
          
            
             //if(isPrivate) ? @"PR" : @"PB";
            
          /*  NSLog(@"date is :%f",time);
            NSLog(@"time is :%f",publicEventTime);
            
            NSLog(@"time and date  is :%f",time+publicEventTime);*/



            NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
            [dict setValue:[NSString stringWithFormat:@"%f",publicEventTime] forKey:@"date"];
           // [dict setValue:[NSString stringWithFormat:@"%f",time+publicEventTime] forKey:@"date"];

            [dict setValue:address forKey:@"location"];
            [dict setValue:[NSString stringWithFormat:@"%f",loc.coordinate.longitude] forKey:@"longitude"];
            [dict setValue:[NSString stringWithFormat:@"%f",loc.coordinate.latitude] forKey:@"latitude"];
            [dict setValue:[NSString stringWithFormat:@"%@",self.txtAmount.text] forKey:@"price"];

            NSArray *array =[[NSArray alloc] initWithObjects:dict, nil];
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
            NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"jsonData as string:\n%@ Error:%@", resultAsString,error);
            NSString *desc = [self.txtDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([desc isEqualToString:[localization localizedStringForKey:@"Short Description or Message"]])
            {
                desc=@"";
            }
            
            if(isEdit)
            {
                 [mc editPublicEvent:[USER_DEFAULTS valueForKey:@"userid"] Name:self.txtName.text Description:desc Image:imageData Category_id:[NSString stringWithFormat:@"%d",categoryID] Type:(isPrivate) ? @"PR" : @"PB" Location_json:resultAsString Date_json:resultAsString Voting_close_date:nil Price:self.txtAmount.text Eventid:self.eventId Sel:@selector(responseCreateEvent:)];
            }
            else
            {
                 [mc addPublicEvent:[USER_DEFAULTS valueForKey:@"userid"] Name:self.txtName.text Description:desc Image:imageData Category_id:[NSString stringWithFormat:@"%d",categoryID] Type:(isPrivate) ? @"PR" : @"PB" Location_json:resultAsString Date_json:resultAsString Voting_close_date:nil Price:self.txtAmount.text Sel:@selector(responseCreateEvent:)];
            }
           
        }
       
    }
    
}
-(void)responseCreateEvent:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        //  [USER_DEFAULTS removeObjectForKey:@"catid"];
        //  [USER_DEFAULTS synchronize];
        
        
        if(isEdit)
        {
            DELEGATE.isEventEdited=YES;
            DELEGATE.isEventEditedList=YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            currentEventId =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"id"]];

            /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Do you want to invite guest to this event?"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Invite now"] otherButtonTitles:[localization localizedStringForKey:@"Later"], nil];
             alert.tag =151;
             [alert show];*/
            
            [DELEGATE showalertNew:self Message:@"" AlertFlag:0];
            
            //[DELEGATE showalertNew:self];

        }
        
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
       
    }
    
    
}
-(void)clearAllData1
{
    [self.placeImage setHidden:NO];
    self.imgEvent.image=nil;
    self.txtName.text =@"";
    self.txtAmount.text =@"";
    self.txtAmount2.text =@"";
    
    [self.imgScroll setHidden:YES];
    

    categoryID =-1;
    [USER_DEFAULTS removeObjectForKey:@"catid"];
    [USER_DEFAULTS synchronize];

    if(isPrivate)
    {
        [self.txtDesc2 setText:[localization localizedStringForKey:@"Short Description or Message"]];
        self.lblselectedCategory.text =[localization localizedStringForKey:@"Select Category"];

        [self.txtDesc2 setTextColor:[UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]];
        if(locationArray.count>1)
        {
            for(int i=1;i<locationArray.count;i++)
            {
                [self descreaseHeight];
            }
        }
        
        if(dateAndTimeArray.count>1)
        {
            for(int i=1;i<dateAndTimeArray.count;i++)
            {
                [self descreaseHeight];
            }
        }
        [locationArray removeAllObjects];
        [locationArray addObject:[self addLocationDictionary]];
        
        [dateAndTimeArray removeAllObjects];
        [dateAndTimeArray addObject:[self addDateDictionary]];
        self.txtEventName2.text=@"";
        self.txtEnd2.text=@"";
        [self.tableview reloadData];
        
    }
    else
    {       
       
        self.txtDate.text=@"";
        self.txtTime.text=@"";
        self.lblselectedCategory.text =[localization localizedStringForKey:@"Select Category"];
        [self.txtDescription setText:[localization localizedStringForKey:@"Short Description or Message"]];
        [self.txtDescription setTextColor:[UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]];
        [self.lblLocation setText:[localization localizedStringForKey:@"Tap to add Location"]];
        [self.lblLocation setTextColor:[UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]];
    }
  
}
- (IBAction)addTapped:(UIButton *)sender
{
    [self increaseHeight];
    if(sender.tag==0)
    {
        [dateAndTimeArray addObject:[self addDateDictionary]];
    }
    else
    {
        [locationArray addObject:[self addLocationDictionary]];
    }
   
    [self.tableview reloadData];
    if (locationArray.count>0) {
        long lastSection=[self.tableview numberOfSections]-1;
        long lastRowNumber = [self.tableview numberOfRowsInSection:lastSection]-1;
        if (lastRowNumber==-1) {
            lastRowNumber = 0;
        }
        NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:lastSection];
        [self.tableview scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }}
-(void)setTableFrame:(int)count
{
    self.tableview.frame = CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, self.tableview.frame.size.height+80);
}
-(void)increaseHeight
{
    self.privateView.frame = CGRectMake(self.privateView.frame.origin.x, self.privateView.frame.origin.y, self.privateView.frame.size.width, self.privateView.frame.size.height+80);
    
    NSLog(@"table frame is %@",NSStringFromCGRect(self.tableview.frame));
     self.tableview.frame = CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, self.tableview.frame.size.height+80);
    
  //   self.btnAdd.frame = CGRectMake(self.btnAdd.frame.origin.x, self.btnAdd.frame.origin.y+142, self.btnAdd.frame.size.width, self.btnAdd.frame.size.height);
    
     self.imgVotingDate.frame = CGRectMake(self.imgVotingDate.frame.origin.x, self.imgVotingDate.frame.origin.y+80, self.imgVotingDate.frame.size.width, self.imgVotingDate.frame.size.height);
    
     self.imgVoteCal.frame = CGRectMake(self.imgVoteCal.frame.origin.x, self.imgVoteCal.frame.origin.y+80, self.imgVoteCal.frame.size.width, self.imgVoteCal.frame.size.height);
    
     self.txtEnd2.frame = CGRectMake(self.txtEnd2.frame.origin.x, self.txtEnd2.frame.origin.y+80, self.txtEnd2.frame.size.width, self.txtEnd2.frame.size.height);
    
     self.btnSubmit2.frame = CGRectMake(self.btnSubmit2.frame.origin.x, self.btnSubmit2.frame.origin.y+80, self.btnSubmit2.frame.size.width, self.btnSubmit2.frame.size.height);
    
   //  self.lblEndDate2.frame = CGRectMake(self.lblEndDate2.frame.origin.x, self.lblEndDate2.frame.origin.y+142, self.lblEndDate2.frame.size.width, self.lblEndDate2.frame.size.height);
    
    self.imgBG.frame = CGRectMake(self.imgBG.frame.origin.x, self.imgBG.frame.origin.y, self.imgBG.frame.size.width, self.imgBG.frame.size.height+80);
    
    if(IS_Ipad)
    {
        [self.scrollview setContentSize:CGSizeMake(self.scrollview.contentSize.width, self.scrollview.contentSize.height+90)];
    }
    else
    {
        [self.scrollview setContentSize:CGSizeMake(self.scrollview.contentSize.width, self.scrollview.contentSize.height+85)];
    }
    previousSize =self.scrollview.contentSize.height;
    
    
}
-(void)descreaseHeight
{
    self.privateView.frame = CGRectMake(self.privateView.frame.origin.x, self.privateView.frame.origin.y, self.privateView.frame.size.width, self.privateView.frame.size.height-80);
    
    self.tableview.frame = CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, self.tableview.frame.size.height-80);
    
   // self.btnAdd.frame = CGRectMake(self.btnAdd.frame.origin.x, self.btnAdd.frame.origin.y-142, self.btnAdd.frame.size.width, self.btnAdd.frame.size.height);
    
    self.imgVotingDate.frame = CGRectMake(self.imgVotingDate.frame.origin.x, self.imgVotingDate.frame.origin.y-80, self.imgVotingDate.frame.size.width, self.imgVotingDate.frame.size.height);
    
    self.imgVoteCal.frame = CGRectMake(self.imgVoteCal.frame.origin.x, self.imgVoteCal.frame.origin.y-80, self.imgVoteCal.frame.size.width, self.imgVoteCal.frame.size.height);
    
    self.txtEnd2.frame = CGRectMake(self.txtEnd2.frame.origin.x, self.txtEnd2.frame.origin.y-80, self.txtEnd2.frame.size.width, self.txtEnd2.frame.size.height);
    
    self.btnSubmit2.frame = CGRectMake(self.btnSubmit2.frame.origin.x, self.btnSubmit2.frame.origin.y-80, self.btnSubmit2.frame.size.width, self.btnSubmit2.frame.size.height);
    
   // self.lblEndDate2.frame = CGRectMake(self.lblEndDate2.frame.origin.x, self.lblEndDate2.frame.origin.y-142, self.lblEndDate2.frame.size.width, self.lblEndDate2.frame.size.height);
    
     self.imgBG.frame = CGRectMake(self.imgBG.frame.origin.x, self.imgBG.frame.origin.y, self.imgBG.frame.size.width, self.imgBG.frame.size.height-80);
    
    
    if(IS_Ipad)
    {
     [self.scrollview setContentSize:CGSizeMake(self.scrollview.contentSize.width, self.scrollview.contentSize.height-90)];
    }
    else
    {
        [self.scrollview setContentSize:CGSizeMake(self.scrollview.contentSize.width, self.scrollview.contentSize.height-85)];
    }
    previousSize =self.scrollview.contentSize.height;

}
-(NSDictionary *)addDictionary
{
    NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
    [dict setValue:@"" forKey:@"date"];
    [dict setValue:@"" forKey:@"location"];
    [dict setValue:@"" forKey:@"latitude"];
    [dict setValue:@"" forKey:@"longitude"];
    [dict setValue:@"" forKey:@"price"];
    [dict setValue:@"" forKey:@"date2"];
    [dict setValue:@"" forKey:@"id"];
    [dict setValue:@"" forKey:@"date_id"];


    return dict;

}
-(NSDictionary *)addLocationDictionary
{
    NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
    
    [dict setValue:@"" forKey:@"location"];
    [dict setValue:@"" forKey:@"latitude"];
    [dict setValue:@"" forKey:@"longitude"];
    [dict setValue:@"" forKey:@"id"];
    return dict;
    
}
-(NSDictionary *)addDateDictionary
{
    NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
    [dict setValue:@"" forKey:@"date"];
    [dict setValue:@"" forKey:@"dateold"];
    [dict setValue:@"" forKey:@"dateDisplay"];
    [dict setValue:@"" forKey:@"time"];
  //  [dict setValue:@"" forKey:@"timeDispaly"];
    [dict setValue:@"" forKey:@"id"];

    
    return dict;
    
}



-(BOOL)checkValidation2
{
    
    NSString *name = [self.txtEventName2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSString *date = [self.txtEnd2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   
    if([USER_DEFAULTS valueForKey:@"catid"])
    {
        categoryID =[[USER_DEFAULTS valueForKey:@"catid"] intValue];
    }
    
    
    
    if([name length] <= 0 /*||  [date length]<= 0*/ || [address length]<= 0 || categoryID<=0)
    {
        if(categoryID<=0)
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please select Category"] AlertFlag:1 ButtonFlag:1];

            return FALSE;
        }
        else if(name.length <=0 )
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Pleas enter Event Name"] AlertFlag:1 ButtonFlag:1];
            
          
            return FALSE;
        }
//       else  if(date.length <=0)
//        {
//            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please select End Voting Date"] AlertFlag:1 ButtonFlag:1];
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
-(BOOL)checkEventAdress
{
    
    /*
     [dict setValue:@"" forKey:@"date"];
     [dict setValue:@"" forKey:@"location"];
     [dict setValue:@"" forKey:@"latitude"];
     [dict setValue:@"" forKey:@"longitude"];
     [dict setValue:@"" forKey:@"price"];
     [dict setValue:@"" forKey:@"date2"];
     */
    BOOL isFound = '\0';
    if(locationArray.count>0)
    {
        for(int i=0; i<locationArray.count;i++)
        {
           if([[[locationArray objectAtIndex:i] valueForKey:@"location"] length]>0)
           {
               NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[locationArray objectAtIndex:i]];
               [dict setValue:[NSString stringWithFormat:@"%@",self.txtAmount2.text] forKey:@"price"];
               [locationArray replaceObjectAtIndex:i withObject:dict];
               isFound=YES;
           }
        }
        if(isFound)
        {
            return TRUE;
        }
        else
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please select minimum one Event Location"] AlertFlag:1 ButtonFlag:1];
          
            return FALSE;
        }
    }
    else
    {
       [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please select minimum one Event Location"] AlertFlag:1 ButtonFlag:1];
      
        return FALSE;
    }
}
-(BOOL)datecomapre:(NSString *)dateSelected{
    
    NSDateFormatter *dateFormatterForGettingDate = [[NSDateFormatter alloc] init];
    [dateFormatterForGettingDate setDateFormat:@"dd'/'MM'/'yyyy"];
    NSDate *dateFromStr = [dateFormatterForGettingDate dateFromString:dateSelected];
    NSDate *voteDate = [dateFormatterForGettingDate dateFromString:self.txtEnd2.text];

    
    
    NSComparisonResult result;
    
    result = [dateFromStr compare:voteDate];
    
    BOOL type;
    
    if(result==NSOrderedAscending)
    {
       // NSLog(@"today is less");
        type= NO;
    }
    else if(result==NSOrderedDescending)
    {
       // NSLog(@"newDate is less");
        type= YES;
    }
    else
    {
      //  NSLog(@"Both dates are same");
        type= YES;
    }
    
    return type;
 
    
}
-(BOOL)checkVotingDate
{
    /*
     date = "1445506620.000000";
     dateDisplay = "22/10/2015";
     dateold = "1445472000.000000";
     id = "";
     time = "1445506620.000000";
     timeDispaly = "";
     timeDisplay = "03:07 PM";
     */
    
    if(dateAndTimeArray.count>0)
    {
        NSSortDescriptor *dblDescr;
        
            dblDescr= [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
            NSArray *sortedArray = [dateAndTimeArray sortedArrayUsingDescriptors:@[dblDescr]];
            return [self datecomapre:[NSString stringWithFormat:@"%@",[[sortedArray objectAtIndex:0] valueForKey:@"dateDisplay"]]];
        
    }
    return NO;
}
-(BOOL)checkEventDates
{
    //[dateArray removeAllObjects];
    
    BOOL isFound = NO;
    if(dateAndTimeArray.count>0)
    {
        for(int i=0; i<dateAndTimeArray.count;i++)
        {
            
            if([[NSString stringWithFormat:@"%@",[[dateAndTimeArray objectAtIndex:i] valueForKey:@"dateold"]] length]>0  && [[NSString stringWithFormat:@"%@",[[dateAndTimeArray objectAtIndex:i] valueForKey:@"date"]] length]>0)
            {
                isFound=YES;
                
            }
            else if([[NSString stringWithFormat:@"%@",[[dateAndTimeArray objectAtIndex:i] valueForKey:@"dateold"]] length]==0  && [[NSString stringWithFormat:@"%@",[[dateAndTimeArray objectAtIndex:i] valueForKey:@"date"]] length]==0)
            {
            }
            else
            {
                if([[NSString stringWithFormat:@"%@",[[dateAndTimeArray objectAtIndex:i] valueForKey:@"dateold"]] length]==0  || [[NSString stringWithFormat:@"%@",[[dateAndTimeArray objectAtIndex:i] valueForKey:@"date"]] length]==0)
                {
                    isFound=NO;
                    break;
                }

                
            }
        }
        if(isFound)
        {
            return TRUE;
        }
        else
        {
             [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please select Event Date with time"] AlertFlag:1 ButtonFlag:1];
           
            return FALSE;
        }
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please select minimum one Event Date with time"] AlertFlag:1 ButtonFlag:1];
      
        return FALSE;
    }
}
- (IBAction)submit2Tapped:(id)sender
{
    if([self checkValidation2])
    {
        if([self checkEventAdress] && [self checkEventDates])
        {
            
           if([self checkVotingDate])
           {
               if(DELEGATE.connectedToNetwork)
               {
     
                   if(self.testImage.image)
                   {
                       
                       UIGraphicsBeginImageContextWithOptions(self.imgScroll.bounds.size,
                                                              YES,
                                                              [UIScreen mainScreen].scale);
                       
                       CGPoint offset=self.imgScroll.contentOffset;
                       CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y);
                       
                       [self.imgScroll.layer renderInContext:UIGraphicsGetCurrentContext()];
                       UIImage *visibleScrollViewImage = UIGraphicsGetImageFromCurrentImageContext();
                       UIGraphicsEndImageContext();
                      // imageData = UIImagePNGRepresentation(visibleScrollViewImage);
                       
                       imageData =UIImageJPEGRepresentation(visibleScrollViewImage, 1.0);

                       
                   }
                   else
                   {
                       imageData=nil;
                   }
                   
                   NSError *error;
                   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:locationArray options:NSJSONWritingPrettyPrinted error:&error];
                   NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                   
                   NSData *dateData = [NSJSONSerialization dataWithJSONObject:dateAndTimeArray options:NSJSONWritingPrettyPrinted error:&error];
                   NSString *dateAsString = [[NSString alloc] initWithData:dateData encoding:NSUTF8StringEncoding];
                   NSString *desc = [self.txtDesc2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                   if([desc isEqualToString:[localization localizedStringForKey:@"Short Description or Message"]])
                   {
                       desc=@"";
                   }
                   
                   if(isEdit)
                   {
                       [mc editPublicEvent:[USER_DEFAULTS valueForKey:@"userid"] Name:self.txtEventName2.text Description:desc Image:imageData Category_id:[NSString stringWithFormat:@"%d",categoryID] Type:(isPrivate) ? @"PR" : @"PB" Location_json:resultAsString Date_json:dateAsString Voting_close_date:[NSString stringWithFormat:@"%f",time2] Price:self.txtAmount2.text Eventid:self.eventId Sel:@selector(responseCreateEvent:)];
                   }
                   else
                   {
                       NSLog(@"%f",time2);
                       [mc addPublicEvent:[USER_DEFAULTS valueForKey:@"userid"] Name:self.txtEventName2.text Description:desc Image:imageData Category_id:[NSString stringWithFormat:@"%d",categoryID] Type:(isPrivate) ? @"PR" : @"PB" Location_json:resultAsString Date_json:dateAsString Voting_close_date:[NSString stringWithFormat:@"%f",time2] Price:self.txtAmount2.text Sel:@selector(responseCreateEvent:)];
                   }
               }
           }
            else
            {
                
                [DELEGATE showalert:self Message:[localization localizedStringForKey:@"End Voting Date must be less than Event Date"] AlertFlag:1 ButtonFlag:1];
            }
        }
    }
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
@end

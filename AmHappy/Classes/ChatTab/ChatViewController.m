//
//  ChatViewController.m
//  iPhoneXMPP
//
//  Created by macmini5 on 29/08/13.
//
//

#import "ChatViewController.h"
#import "XMPPGroupCoreDataStorageObject.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "CoreDataUtils.h"
#import "NSManagedObject+Utilities.h"
#import "ModelClass.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XMPPRoomMemoryStorage.h"
#import "Base64.h"
#import "UIImageView+WebCache.h"
#import "GuestViewController.h"

#import "TYMActivityIndicatorViewViewController.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif


@interface ChatViewController ()

@end

@implementation ChatViewController
{
    ModelClass *mc;
   // NSMutableArray  *groupMessages;
    NSString *myChatJid;
    UIToolbar *mytoolbar1;

    float tHeight;
    TYMActivityIndicatorViewViewController *drk;
    int messageOffset;
    BOOL isMore;
    
    
}
@synthesize userId,lblTitle,chatView,fromJId,fromUserId,isGroupChat,scrollview,eventId,textMessage,name,chatVC,imgOnline,btnPost,imgUser,imgUrl,bgImg,btnShowGuest;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)myMethod
{
    NSDate *nowUTC = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

   // groupMessages=[[NSMutableArray alloc] init];
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:[NSString stringWithFormat:@"%@",[self substituteEmoticons:[DELEGATE FriendMessage]]] forKey:@"msg"];
    [m setObject:[NSString stringWithFormat:@"%@",[DELEGATE FriendName]] forKey:@"sender"];
    [m setObject:@"r" forKey:@"align"];
    
    [m setObject:[dateFormatter stringFromDate:nowUTC] forKey:@"time"];
    [messages addObject:m];
    position = TRUE;
    [_tView reloadData];
    
}
- (void)viewDidLoad
{
  /*  if (![DELEGATE connect])
    {
        [DELEGATE connect];
    }*/
    
    [super viewDidLoad];
   /* if(IS_Ipad || IS_IPHONE_6_PLUS)
    {
        messageOffset=15;
    }
    else
    {*/
        messageOffset=50;
   // }
    isMore =NO;
    
    self.tView.dataSource=self;
    self.tView.delegate =self;
    
    UIColor *image = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bgnew.png"]];
    self.view.backgroundColor = image;
    
    if(IS_IPHONE_4s)
    {
        [self.bgImg setImage:[UIImage imageNamed:@"bg4s.png"]];
    }
    else if (IS_IPHONE_5)
    {
        [self.bgImg setImage:[UIImage imageNamed:@"bg5.png"]];
    }
    else if (IS_IPHONE_6)
    {
        [self.bgImg setImage:[UIImage imageNamed:@"bg6.png"]];
    }
    else if (IS_IPHONE_6_PLUS)
    {
        [self.bgImg setImage:[UIImage imageNamed:@"bg6plus.png"]];
    }
    else if (IS_Ipad)
    {
        [self.bgImg setImage:[UIImage imageNamed:@"bgipad.png"]];
    }
    
   // [self.tView setBackgroundColor:[UIColor clearColor]];
    
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    
    messages = [[NSMutableArray alloc ] init];
    mc =[[ModelClass alloc]init];
    mc.delegate = self;
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc]init];
    //groupMessages=[[NSMutableArray alloc] init];
    if(self.imgUrl.length>0)
    {
        [self.imgUser sd_setImageWithURL:[NSURL URLWithString:self.imgUrl]];
    }
    
   


    [self.lblTitle setText:self.name];
    
    self.imgUser.layer.masksToBounds = YES;
    self.imgUser.layer.cornerRadius = 18.0;

    [self.textMessage setDelegate:self];
    [self.textMessage setReturnKeyType:UIReturnKeyDone];
    [self.textMessage setText:[localization localizedStringForKey:@"Message"]];
    [self.textMessage setFont:FONT_Regular(14.0)];
    [self.textMessage setTextColor:[UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]];
    
    self.textMessage.layer.masksToBounds = YES;
    self.textMessage.layer.cornerRadius = 3.0;
    self.textMessage.layer.borderWidth =1.1;
    self.textMessage.layer.borderColor =[[UIColor colorWithRed:(214/255.f) green:(214/255.f) blue:(214/255.f) alpha:1.0f] CGColor];
    if(IS_IPHONE_4s)
    {
        
          [self.textMessage setFrame:CGRectMake(self.textMessage.frame.origin.x, self.textMessage.frame.origin.y-10, self.textMessage.frame.size.width, self.textMessage.frame.size.height)];
        [self.btnPost setFrame:CGRectMake(self.btnPost.frame.origin.x, self.textMessage.frame.origin.y, self.btnPost.frame.size.width, self.btnPost.frame.size.height)];
    }
   
    
   // NSLog(@"from jid is %@",self.fromJId);
    NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    myChatJid=[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
    
   
    
    if(self.fromJId.length>0)
    {
        [USER_DEFAULTS setValue:self.fromJId forKey:@"fromJId"];
        [USER_DEFAULTS synchronize];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"myMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchMessages) name:@"myMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"myDliver" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deliveredMessage) name:@"myDliver" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideDRK) name:@"connected" object:nil];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = FONT_Heavy(20.0);
	titleLabel.numberOfLines = 1;
	titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Chat";
	[titleLabel sizeToFit];
    
	self.navigationItem.titleView = titleLabel;
    
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(hideKeyBoard)];
    [tapGesture setCancelsTouchesInView:NO];
    
    [self.tView addGestureRecognizer:tapGesture];
   
  
   [self testMessageArchiving];
    
    
    [self setUpTextFieldforIphone];
    
    tHeight =self.tView.frame.size.height;

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    if(self.isGroupChat)
    {
        [self.btnShowGuest setHidden:NO];
        XMPPRoomMemoryStorage *roomStorage = [[XMPPRoomMemoryStorage alloc] init];
        
        
        if(DELEGATE.connectedToNetwork)
        {
            [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
            
            [self performSelector:@selector(hideDRK) withObject:self afterDelay:30.0];
          
            
            XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@conference.%@",self.fromJId,HostingServer]];
            xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomStorage
                                                         jid:roomJID
                                               dispatchQueue:dispatch_get_main_queue()];
            
            [xmppRoom activate:DELEGATE.xmppStream];
            [xmppRoom addDelegate:DELEGATE
                    delegateQueue:dispatch_get_main_queue()];
            
            NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
           // [history addAttributeWithName:@"maxstanzas" stringValue:@"1000"];
           [history addAttributeWithName:@"since" stringValue:@"1970-01-01T00:00:00Z"];
         
            
            [xmppRoom joinRoomUsingNickname:[USER_DEFAULTS valueForKey:@"fullname"]
                                    history:history
                                   password:nil];
            [xmppRoom fetchConfigurationForm];

            
            //[self ConfigureNewRoom];
            
           // NSLog(@"from id is %@",self.fromJId);
            
           // [DELEGATE createRoom:self.fromJId];
        }
       
    }
    else
    {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PresenceChanged" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(presenceChanged)
                                                     name:@"PresenceChanged"
                                                   object:nil];
        [self.imgOnline setHidden:NO];

        self.imgOnline.layer.masksToBounds = YES;
        self.imgOnline.layer.cornerRadius = 6.0;
      

        
    }
    [self fetchMessages];
    //[self sendOfflineMessage];
    
    
    
    
}

-(void)hideKeyBoard
{
    [self.view endEditing:YES];
}
-(void)setUpTextFieldforIphone
{
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-96, self.view.bounds.size.width, 47)];
    textViewMessage = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5, 6,containerView.frame.size.width-70, 32)];
    textViewMessage.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textViewMessage.minNumberOfLines = 1;
    textViewMessage.maxNumberOfLines = 6;
    textViewMessage.returnKeyType = UIReturnKeyDefault; //just as an example
    textViewMessage.font = FONT_Regular(15.0);
    textViewMessage.delegate = self;
    textViewMessage.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textViewMessage.backgroundColor = [UIColor whiteColor];
    

    
    
    [self.view addSubview:containerView];
    
    
    UIImage *rawBackground = [UIImage imageNamed:@"txtBg.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:rawBackground];
    imageView.frame = CGRectMake(textViewMessage.frame.origin.x-5, 0, textViewMessage.frame.size.width+5, textViewMessage.frame.size.height+2);
  //  imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textViewMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    textViewMessage.layer.masksToBounds = YES;
    textViewMessage.layer.cornerRadius = 3.0;
    textViewMessage.layer.borderWidth =1.1;
    textViewMessage.layer.borderColor =[[UIColor colorWithRed:(214/255.f) green:(214/255.f) blue:(214/255.f) alpha:1.0f] CGColor];
    
    textViewMessage.textColor = [UIColor lightGrayColor];
    textViewMessage.text =[localization localizedStringForKey:@"Enter message"];
    [containerView addSubview:textViewMessage];
 
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 68, 3, 62, 40);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    doneBtn.layer.cornerRadius = 3.0;
 
    
    [doneBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setImage:[UIImage imageNamed:@"msend.png"] forState:UIControlStateNormal];
    [containerView setBackgroundColor:[UIColor whiteColor]];

    [containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    
}
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    if([growingTextView.text isEqualToString:[localization localizedStringForKey:@"Enter message"]])
    {
        growingTextView.text=@"";
        [growingTextView setTextColor:[UIColor blackColor]];
    }
    else
    {
        [growingTextView setTextColor:[UIColor blackColor]];
    }
}
- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    if(growingTextView.text.length == 0){
        growingTextView.textColor = [UIColor lightGrayColor];
        growingTextView.text = [localization localizedStringForKey:@"Enter message"];
        
        // self.txtComment.text = [localization localizedStringForKey:@"Comment"];
        [growingTextView resignFirstResponder];
    }
    else
    {
        if(![growingTextView.text isEqualToString:[localization localizedStringForKey:@"Enter message"]])
        {
            growingTextView.textColor = [UIColor blackColor];
            
        }
    }
}
/*
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    if([growingTextView.text isEqualToString:[localization localizedStringForKey:@"Enter message"]])
    {
        growingTextView.text=@"";
        [growingTextView setTextColor:[UIColor blackColor]];
    }
    else
    {
        [growingTextView setTextColor:[UIColor blackColor]];
    }
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    if(growingTextView.text.length == 0){
        growingTextView.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
        growingTextView.text = [localization localizedStringForKey:@"Enter message"];
        
        // self.txtComment.text = [localization localizedStringForKey:@"Comment"];
        [growingTextView resignFirstResponder];
    }
    else
    {
        if(![growingTextView.text isEqualToString:[localization localizedStringForKey:@"Enter message"]])
        {
            growingTextView.textColor = [UIColor blackColor];
            
        }
    }
}
 - (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
 {
 if(growingTextView.text.length == 0){
 growingTextView.textColor = [UIColor lightGrayColor];
 growingTextView.text =[localization localizedStringForKey:@"Enter message"];
 
 //self.txtComment.text = [localization localizedStringForKey:@"Comment"];
 [growingTextView resignFirstResponder];
 }
 }
 */
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
  /*  if (growingTextView.textColor == [UIColor lightGrayColor]) {
        growingTextView.text = @"";
        growingTextView.textColor = [UIColor blackColor];
    }*/
    
    return YES;
}





- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
   // [self.attachView setHidden:YES];
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
    self.tView.frame = CGRectMake(self.tView.frame.origin.x, self.tView.frame.origin.y, self.tView.frame.size.width, self.tView.frame.size.height + diff);
    [self performSelector:@selector(scrollTableview) withObject:nil afterDelay:0.0];

}
- (void)keyboardWillShow:(NSNotification*)aNotification{
    
   
   // [self performSelector:@selector(scrollTableview) withObject:nil afterDelay:0.0];

    CGRect keyboardBounds;
    [[aNotification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    CGRect tableviewframe=self.tView.frame;
    if(IS_Ipad )
    {
        if (tableviewframe.size.height>700)
        {
            if([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)
            {
                tableviewframe.size.height-=210;
            }
            else
            {
                tableviewframe.size.height-=210;
            }
        }
    }
   else if(IS_IPHONE_6_PLUS)
    {
        if (tableviewframe.size.height>500) {
            
            
            if([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)
            {
                tableviewframe.size.height-=210;
            }
            else
            {
                tableviewframe.size.height-=210;
            }
        }
    }
   else if(IS_IPHONE_5)
   {
       if (tableviewframe.size.height>380) {
           
           
           if([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)
           {               
               tableviewframe.size.height-=180;//200
           }
           else
           {
               tableviewframe.size.height-=190;//210
           }
       }
   }
   else if(IS_IPHONE_6)
   {
       if (tableviewframe.size.height>380) {
           
           
           if([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)
           {
               
               tableviewframe.size.height-=170;
           }
           else
           {
               tableviewframe.size.height-=180;
           }
       }
   }
    else
    {
        if (tableviewframe.size.height>300) {
            
            
            if([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)
            {
                
                tableviewframe.size.height-=195;
            }
            else
            {
                tableviewframe.size.height-=195;
            }
        }
    }
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    containerView.frame = containerFrame;
    self.tView.frame=tableviewframe;
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(scrollTableview) withObject:nil afterDelay:0.0];

    //[self scrollTableview];
}
- (void)keyboardWillHide:(NSNotification*)aNotification{
 
    
    NSNumber *duration = [aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyboardBounds;
    [[aNotification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
     float heightpoint ;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0)
    {
        heightpoint =self.view.bounds.size.height-165;
    }
    else
    {
        heightpoint =self.view.bounds.size.height-145;

    }
   
    self.tView.frame =CGRectMake(self.tView.frame.origin.x, self.tView.frame.origin.y, self.tView.frame.size.width, heightpoint);
    
   	// animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
   
    textViewMessage.frame= CGRectMake(5, 6, self.view.bounds.size.width-70, 32);
    
    containerView.frame = CGRectMake(0,self.view.frame.size.height-96, self.view.bounds.size.width, 47);

    [UIView commitAnimations];
   [self scrollTableview];
}
-(void)presenceChanged
{
    if(!self.isGroupChat)
    {
        XMPPPresence *presence1=[DELEGATE.presences valueForKey:[NSString stringWithFormat:@"%@@%@",self.fromJId,HostingServer]];
      //  NSLog(@"presence type is %@",[presence1 type]);
        if ([[presence1 type] isEqualToString:@"available"])
        {
            
            [self.imgOnline setBackgroundColor:[UIColor colorWithRed:160.0/255.0f green:204.0/255.0f blue:0.0/255.0f alpha:1.0]];
        }
        else
        {
            [self.imgOnline setBackgroundColor:[UIColor whiteColor]];
        }
    }
    
}
-(void)scrollTableview
{
    if (messages.count>0) {
      
        NSIndexPath* ip = [NSIndexPath indexPathForRow:messages.count-1 inSection:0];
        [self.tView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    
}

-(void)donePressed
{
    [self.view endEditing:YES];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
    if(isGroupChat)
    {
        [self.btnShowGuest setUserInteractionEnabled:YES];
    }
    self.imgUser.frame =CGRectMake(self.lblTitle.frame.size.width+self.lblTitle.frame.origin.x+2, self.imgUser.frame.origin.y, self.imgUser.frame.size.width, self.imgUser.frame.size.height);
    
    self.imgOnline.frame =CGRectMake(self.lblTitle.frame.origin.x-14, self.imgOnline.frame.origin.y, self.imgOnline.frame.size.width, self.imgOnline.frame.size.height);
    if (![DELEGATE connect])
    {
        [DELEGATE connect];
    }
    
    NSString *unread =@"Y";
    NSArray *myArray = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    NSString *userid =[NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]];
    NSArray  *array= [CoreDataUtils getObjects:[DB description] withQueryString:@"jid = %@ AND userid = %@ AND unread = %@ " queryArguments:@[self.fromJId,userid,unread,] sortBy:nil];
    for (int i=0; i<array.count; i++)
    {
       DB *db = [array objectAtIndex:i];
        db.unread = @"N";
        [CoreDataUtils updateDatabase];
    }
}
-(void)removeObjectsFromDatabase
{
    NSArray *array =[[NSArray alloc]init];

    array= [CoreDataUtils getObjects:[DB description] withQueryString:@" jid = %@ " queryArguments:@[self.fromJId] sortBy:nil];
    if(array.count>0)
    {
        for(int i=0;i<array.count;i++)
        {
            [CoreDataUtils deleteObject:[array objectAtIndex:i]];
        }
            
    }
}
-(void)loadMore
{
    NSArray *array =[[NSArray alloc]init];
    NSArray *result=[[NSArray alloc]init];
    
    NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    NSString *str =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
    
    if(self.isGroupChat)
    {
        array= [CoreDataUtils getObjects:[DB description] withQueryString:@" jid = %@ " queryArguments:@[self.fromJId] sortBy:nil];
    }
    else
    {
        array= [CoreDataUtils getObjects:[DB description] withQueryString:@" jid = %@ AND userid = %@" queryArguments:@[self.fromJId,str] sortBy:nil];
        
    }
        
        if(messageOffset>0)
        {
            if(array.count>messageOffset)
            {
                NSRange theRange;
                theRange.location = [array count] - messageOffset;
                theRange.length = messageOffset;
               result = [array subarrayWithRange:theRange];
                isMore =YES;
            }
            else
            {
                NSRange theRange;
                theRange.location = [array count] - [array count];
                theRange.length = [array count];
               result = [array subarrayWithRange:theRange];
                isMore =NO;
            }
        }
        else
        {
            if(IS_Ipad || IS_IPHONE_6_PLUS)
            {
                if(array.count>15)
                {
                    NSRange theRange;
                    theRange.location = [array count] - 15;
                    theRange.length = 15;
                    result = [array subarrayWithRange:theRange];
                    isMore =YES;
                }
                else
                {
                    NSRange theRange;
                    theRange.location = [array count] - [array count];
                    theRange.length = [array count];
                    result = [array subarrayWithRange:theRange];
                    isMore =NO;
                }
            }
            else
            {
                if(array.count>10)
                {
                    NSRange theRange;
                    theRange.location = [array count] - 10;
                    theRange.length = 10;
                    result = [array subarrayWithRange:theRange];
                    isMore =YES;
                }
                else
                {
                    NSRange theRange;
                    theRange.location = [array count] - [array count];
                    theRange.length = [array count];
                    result = [array subarrayWithRange:theRange];
                    isMore =NO;
                }
            }
            
        }
    
        if(result.count>0)
        {
            [messages removeAllObjects];
            [messages addObjectsFromArray:result];

        }
    
  
        if(messages.count>0)
        {
            self.tView.clearsContextBeforeDrawing =YES;
            [_tView reloadData];
            
           // if(messageOffset==10 || messageOffset==15)

            if(messageOffset==50 )
            {
               /* if (self.tView.contentSize.height > self.tView.frame.size.height)
                {
                   // float height =self.tView.frame.size.height-50;
                     CGPoint offset = CGPointMake(0, self.tView.contentSize.height - self.tView.frame.size.height);
                   // CGPoint offset = CGPointMake(0, 0);

                    [self.tView setContentOffset:offset animated:NO];
                    
                }*/
                
                @try
                {
                    [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }
                @catch (NSException *exception)
                {
                    NSLog(@"%@", exception.reason);
                    NSLog(@" in catch block");

                }
                @finally {
                    NSLog(@" in finally block");
                    
                }
                
                
                
                /*
                 int lastRowNumber = [tableView numberOfRowsInSection:0] - 1;
                 NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
                 [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
                 */
            }
           /* else
            {
                NSIndexPath *indexPath;
                if(IS_Ipad || IS_IPHONE_6_PLUS)
                {
                    indexPath = [NSIndexPath indexPathForRow:messageOffset-15 inSection:0];                }
                else
                {
                    indexPath = [NSIndexPath indexPathForRow:messageOffset-10 inSection:0];                }
                
                [self.tView scrollToRowAtIndexPath:indexPath
                                     atScrollPosition:UITableViewScrollPositionMiddle
                                             animated:NO];
            }*/
            
        }
   
    
    array =nil;
    result =nil;
    
}
-(void)deliveredMessage
{
    if(!self.isGroupChat)
    {
        [self.imgOnline setBackgroundColor:[UIColor colorWithRed:160.0/255.0f green:204.0/255.0f blue:0.0/255.0f alpha:1.0]];
    }
    [self fetchMessages];
}
-(void)fetchMessages
{
  //  messageOffset =0;
   /* if(IS_Ipad || IS_IPHONE_6_PLUS)
    {
        messageOffset=15;
    }
    else
    {*/
        messageOffset=50;
    //}
    [self loadMore];
}

- (void)animateTextField: (UITextView*)textField up: (BOOL) up
{
    if(IS_IPHONE_4s)
    {
        const int movementDistance = 160; // tweak as needed
        const float movementDuration = 0.3f; // tweak as needed
        
        int movement = (up ? -movementDistance : movementDistance);
        
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.scrollview.frame = CGRectOffset(self.scrollview.frame, 0, movement);
    }
    else
    {
        const int movementDistance = 210; // tweak as needed
        const float movementDuration = 0.3f; // tweak as needed
        
        int movement = (up ? -movementDistance : movementDistance);
        
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.scrollview.frame = CGRectOffset(self.scrollview.frame, 0, movement);
    }
    
   // [UIView commitAnimations];
}


/*
-(void) textViewDidChange:(UITextView *)textView
{
    
    if(self.textMessage.text.length == 0){
        //  self.txtDescription.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
        [self.textMessage setText:[localization localizedStringForKey:@"Message"]];
        
        // self.txtDescription.text = [localization localizedStringForKey:@"Desciption"];
        self.textMessage.textColor=[UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
        
        [self.textMessage resignFirstResponder];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(self.textMessage.text.length == 0){
            self.textMessage.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
            [self.textMessage resignFirstResponder];
        }
        
        return NO;
    }
    
    
    
    
    return YES;
}
*/

-(void)testMessageArchiving{
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
   // NSError *error;
  //  NSArray *messages1 = [moc executeFetchRequest:request error:&error];
    
   // [self print:[[NSMutableArray alloc]initWithArray:messages1]];
}
-(void)print:(NSMutableArray*)messages1
{
    
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages1) {
           // NSLog(@"messageStr param is %@",message.messageStr);
          //  NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
          //  NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
         //   NSLog(@"NSCore object id param is %@",message.objectID);
          //  NSLog(@"bareJid param is %@",message.bareJid);
         //   NSLog(@"bareJidStr param is %@",message.bareJidStr);
        //    NSLog(@"body param is %@",message.body);
        //    NSLog(@"timestamp param is %@",message.timestamp);
         //   NSLog(@"outgoing param is %d",[message.outgoing intValue]);
        }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setMessageField:nil];
    [self setTView:nil];
    [super viewDidUnload];
}
- (XMPPStream *)xmppStream {
    return [DELEGATE xmppStream];
}

- (IBAction)sendMessage:(id)sender {
    
  
    NSString *messageID=[DELEGATE.xmppStream generateUUID];

  //  messageOffset =0;
    /*if(IS_Ipad || IS_IPHONE_6_PLUS)
    {
        messageOffset=15;
    }
    else
    {*/
        messageOffset=50;
    //}
   
    // XMPPPresence *presence1=[DELEGATE.presences valueForKey:self.fromJId];
    position = FALSE;
    NSString *messageStr;
    messageStr = [textViewMessage.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    
    if([[textViewMessage.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:[localization localizedStringForKey:@"Enter message"]])
    {
        messageStr = @"";
    }
   
   
    if([messageStr length] > 0)
    {
        
       // NSString *messageStr = [NSString stringWithFormat:@"%@",textViewMessage.text];
        if([messageStr length] > 0) {
            NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
            [body setStringValue:messageStr];
            NSXMLElement *message = [NSXMLElement elementWithName:@"message"];

            if(self.isGroupChat)
            {
                [message addAttributeWithName:@"type" stringValue:@"groupchat"];
                 [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@conference.%@",self.fromJId,HostingServer]];
                [message addAttributeWithName:@"messageType" stringValue:@"G"];
            }
            else
            {
                [message addAttributeWithName:@"type" stringValue:@"chat"];
                 [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",self.fromJId,HostingServer]];
                [message addAttributeWithName:@"messageType" stringValue:@"C"];
                
           

            }
            [message addAttributeWithName:@"id" stringValue:messageID];
            [message addAttributeWithName:@"sendername" stringValue:[USER_DEFAULTS valueForKey:@"fullname"]];
            [message addAttributeWithName:@"align" stringValue:@"L"];
            
           

            [message addChild:body];
            [self.xmppStream sendElement:message];
            
            
            NSDate *nowUTC = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

            
            DB *DB1;
            DB1 = [DB newInsertedObject];
            DB1.waitingType =messageID;
            DB1.delivered =@"N";
            if(self.isGroupChat)
            {
                DB1.messageType =@"G";
            }
            else
            {
                DB1.messageType =@"C";
             
                
            }
            DB1.identifier = @([CoreDataUtils getNextID:[DB description]]);
            BOOL isfrom=NO;
            
            DB1.from=@(isfrom);
            DB1.timestamp = nowUTC;
            DB1.time = [DELEGATE GetUniversalTime:nowUTC];
            DB1.idd =[USER_DEFAULTS valueForKey:@"fullname"];
            NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
            NSString *str =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
            DB1.userid = str ;
            DB1.message =[[message elementForName:@"body"] stringValue];
            DB1.isShow = @"L" ;
            DB1.jid = [NSString stringWithFormat:@"%@",self.fromJId];
          
            
            DB1.isClear = @"Y";
        
           /* if(DELEGATE.connectedToNetwork2)
            {
                DB1.isClear = @"Y";
            }
            else
            {
                DB1.isClear = @"N";
            }*/
                [CoreDataUtils updateDatabase];
                [self fetchMessages];
          
            
            
            
        }
        [textViewMessage setText:@""];
    
        
       
    }
    else
    {
        [self.view endEditing:YES];
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter message"] AlertFlag:1 ButtonFlag:1];
    
    }
}
-(void)sendOfflineMessage
{
    if(self.isGroupChat)
    {
        NSArray *array =[[NSArray alloc]init];
        
        NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
        NSString *str =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
        array= [CoreDataUtils getObjects:[DB description] withQueryString:@" jid = %@ AND userid = %@ AND delivered =%@ AND messageType =%@ AND isClear = %@ " queryArguments:@[self.fromJId,str,@"N",@"G",@"N"] sortBy:nil];
        if(array.count>0)
        {
            if(DELEGATE.connectedToNetwork)
            {
                for(int i=0;i<array.count;i++)
                {
                    
                    DB *db =(DB *)[array objectAtIndex:i];
                    
                    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
                    [body setStringValue:db.message];
                    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
                    // NSLog(@"from jid is %@",[NSString stringWithFormat:@"%@@%@",self.fromJId,HostingServer]);
                    
                    if(self.isGroupChat)
                     {
                     // [self removeObjectsFromDatabase];
                     [message addAttributeWithName:@"type" stringValue:@"groupchat"];
                     
                     [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@conference.%@",self.fromJId,HostingServer]];
                     [message addAttributeWithName:@"messageType" stringValue:@"G"];
                     }
                    
                    [message addAttributeWithName:@"id" stringValue:db.waitingType];
                    [message addAttributeWithName:@"sendername" stringValue:[USER_DEFAULTS valueForKey:@"fullname"]];
                    [message addAttributeWithName:@"align" stringValue:@"L"];
                    
                    [message addChild:body];
                    [self.xmppStream sendElement:message];
                    db.isClear = @"Y";
                    [CoreDataUtils updateDatabase];
                }
                
                
            }
        }
    }
    else
    {
        NSArray *array =[[NSArray alloc]init];
        
        NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
        NSString *str =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
         array= [CoreDataUtils getObjects:[DB description] withQueryString:@" jid = %@ AND userid = %@ AND delivered =%@ AND messageType =%@ AND isClear = %@ " queryArguments:@[self.fromJId,str,@"N",@"C",@"N"] sortBy:nil];
        if(array.count>0)
        {
            if(DELEGATE.connectedToNetwork)
            {
            for(int i=0;i<array.count;i++)
            {
                
                    DB *db =(DB *)[array objectAtIndex:i];
                    
                    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
                    [body setStringValue:db.message];
                    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
                   // NSLog(@"from jid is %@",[NSString stringWithFormat:@"%@@%@",self.fromJId,HostingServer]);
                    
                    /* if(self.isGroupChat)
                     {
                     // [self removeObjectsFromDatabase];
                     [message addAttributeWithName:@"type" stringValue:@"groupchat"];
                     
                     [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@conference.%@",self.fromJId,HostingServer]];
                     [message addAttributeWithName:@"messageType" stringValue:@"G"];
                     }
                     else
                     {*/
                    [message addAttributeWithName:@"type" stringValue:@"chat"];
                    
                    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",self.fromJId,HostingServer]];
                    [message addAttributeWithName:@"messageType" stringValue:@"C"];
                    
                    // }
                    [message addAttributeWithName:@"id" stringValue:db.waitingType];
                    [message addAttributeWithName:@"sendername" stringValue:[USER_DEFAULTS valueForKey:@"fullname"]];
                    [message addAttributeWithName:@"align" stringValue:@"L"];
                    
                    [message addChild:body];
                    [self.xmppStream sendElement:message];
               
                    db.isClear = @"Y";
                    [CoreDataUtils updateDatabase];
                
            }
                
                
            }
        }
    }
}
-(void)responseSendNotification:(NSDictionary *)results
{
  //  NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
      //  NSLog(@"success");

    }
}
-(void)getnotify:(NSDictionary*)result
{
  //  NSLog(@"%@",result);
}

- (NSString *) substituteEmoticons:(NSString *)stringToReplace {
    //See http://www.easyapns.com/iphone-emoji-alerts for a list of emoticons available
    NSString *res = [stringToReplace stringByReplacingOccurrencesOfString:@":)" withString:@"\ue415"];
    res = [res stringByReplacingOccurrencesOfString:@":(" withString:@"\ue403"];
    res = [res stringByReplacingOccurrencesOfString:@";-)" withString:@"\ue405"];
    res = [res stringByReplacingOccurrencesOfString:@":-x" withString:@"\ue418"];
    res = [res stringByReplacingOccurrencesOfString:@"(Y)" withString:@"\ue00e"];
    
    return res;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentOffset = scrollView.contentOffset.y;
   // NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
   
        if (currentOffset <= 10.0  )
        {
           /* if(isMore)
            {
                if(IS_Ipad || IS_IPHONE_6_PLUS)
                {
                    messageOffset+=15;
                }
                else
                {
                    messageOffset+=10;
                }
                
                [self loadMore];
            }*/
        }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(IS_IPHONE_4s)
    {
        UIView *headerView = [[UIView alloc]
                              initWithFrame:CGRectMake(0,0,self.view.frame.size.width, 20)];
        [headerView setBackgroundColor:[UIColor clearColor]];
        
        
        return headerView;
    }
    else
    {
        return nil;
    }
    
   
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(IS_IPHONE_4s)
    {
        return 20;
    }
    else
    {
        return 0;
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isMore)
    {
        if(messages.count>0)
        {
            return messages.count;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        if(messages.count>0)
        {
            return messages.count;
        }
        else
        {
            return 0;
        }
    }
   
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(isMore )
    {
       
        if(indexPath.row==0)
        {
            static NSString *CellIdentifier = @"newFriendCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newFriendCell"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            UIImageView *loadView =[[UIImageView alloc] initWithFrame:CGRectMake(50, 5, self.view.bounds.size.width-100, 35)];
            [loadView setBackgroundColor:[UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:1]];
            
            loadView.layer.masksToBounds = YES;
            loadView.layer.cornerRadius = 8.0;
           // [loadView setImage:[UIImage imageNamed:@"chatLoad.png"]];
            
            
            UILabel  *lblMore = [[UILabel alloc] initWithFrame:loadView.frame];
            [lblMore setFont:FONT_Heavy(15.0)];
            lblMore.tag = 1;
           // lblMore.backgroundColor=[UIColor clearColor];
            lblMore.numberOfLines=0;
            lblMore.textAlignment =NSTextAlignmentCenter;
            lblMore.text =[localization localizedStringForKey:@"Load Earlier Messages"];
            [lblMore setTextColor:[UIColor colorWithRed:54.0/255.0f green:120.0/255.0f blue:204.0/255.0f alpha:1]];
            cell.contentView.backgroundColor =[UIColor clearColor];
            cell.backgroundColor =[UIColor clearColor];
            
            [cell.contentView addSubview:loadView];
            [cell.contentView addSubview:lblMore];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
        else
        {
            if(isGroupChat)
            {
                
                dbmanager =[messages objectAtIndex:indexPath.row];
                
                
                if ([dbmanager.idd isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
                {
                    MessageCell1 *cell = (MessageCell1 *)[self.tView dequeueReusableCellWithIdentifier:nil];
                    cell = nil;
                    if (cell == nil)
                    {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell1" owner:self options:nil];
                        cell = [nib objectAtIndex:0];
                    }
                    
                    [cell setBackgroundColor:[UIColor clearColor]];
                    [cell.contentView setBackgroundColor:[UIColor clearColor]];
                    
                    cell.lblDate.layer.masksToBounds = YES;
                    cell.lblDate.layer.cornerRadius = 8.0;
                    float widthg1 =[self getSizeWidth:dbmanager.message];
                    if(widthg1 < 120)
                    {
                        widthg1 =130;
                    }
                    
                    if(indexPath.row==1)
                    {
                        cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                        
                        cell.lblDate.layer.masksToBounds = YES;
                        cell.lblDate.layer.cornerRadius = 8.0;
                        float height =[self getSize:dbmanager.message];
                        
                        
                        if(height < 30)
                        {
                            height =30;
                        }
                        
                        
                        [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, widthg1, height+20)];
                        
                        [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                        
                        [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                        
                        [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                        
                        
                        
                    }
                    else
                    {
                        
                        DB *db=[messages objectAtIndex:indexPath.row-1];
                        
                        if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]]])
                        {
                            cell.imgSep1.hidden =YES;
                            cell.imgSep2.hidden =YES;
                            cell.lblDate.hidden =YES;
                            
                            float height =[self getSize:dbmanager.message];
                            
                            if(height < 30)
                            {
                                height =30;
                            }
                            
                            [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, 0, widthg1, height+20)];
                            
                            [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                            
                            [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                            
                            [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                            
                        }
                        else
                        {
                            cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                            
                            float height =[self getSize:dbmanager.message];
                            if(height < 30)
                            {
                                height =30;
                            }
                            
                            [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, widthg1, height+20)];
                            
                            [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                            
                            [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                            
                            [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                            
                        }
                        
                    }
                    cell.lblTime.text =[self getDate:[NSString stringWithFormat:@"%@",dbmanager.time]];
                    
                    cell.lblMessage.text =[dbmanager.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    cell.imgBg.layer.masksToBounds = YES;
                    cell.imgBg.layer.cornerRadius = 20.0;
                    UIImageView *deliverimage;
                    if ([dbmanager.delivered isEqualToString:@"Y"])
                    {
                        deliverimage =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deliver"]];
                        [deliverimage setFrame:CGRectMake(cell.imgBg.frame.size.width-20,cell.lblTime.frame.origin.y+5,16,7)];
                        [cell addSubview:deliverimage];
                        
                        
                    }
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    
                    
                    return cell;
                }
                else
                {
                    MessageCell3 *cell = (MessageCell3 *)[self.tView dequeueReusableCellWithIdentifier:nil];
                    cell = nil;
                    if (cell == nil)
                    {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell2" owner:self options:nil];
                        cell = [nib objectAtIndex:0];
                    }
                    
                    [cell setBackgroundColor:[UIColor clearColor]];
                    [cell.contentView setBackgroundColor:[UIColor clearColor]];
                    cell.lblDate.layer.masksToBounds = YES;
                    cell.lblDate.layer.cornerRadius = 8.0;
                    
                    
                    float widthg2 =[self getSizeWidth:dbmanager.message];
                    if(widthg2 < 120)
                    {
                        widthg2 =130;
                    }
                    
                    
                    if(indexPath.row==1)
                    {
                        cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                        float height =[self getSize:dbmanager.message];
                        if(height < 30)
                        {
                            height =30;
                        }
                        
                        [cell.lblName setFrame:CGRectMake(cell.lblName.frame.origin.x, cell.lblName.frame.origin.y-5, cell.lblName.frame.size.width, cell.lblName.frame.size.height)];
                        
                        [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-widthg2-15, cell.lblName.frame.origin.y+cell.lblName.frame.size.height+5, widthg2, height+20)];
                        
                        [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                        
                        [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                        
                        [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                        
                        
                    }
                    else
                    {
                        DB *db=[messages objectAtIndex:indexPath.row-1];
                        
                        if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]]])
                        {
                            cell.imgSep1.hidden =YES;
                            cell.imgSep2.hidden =YES;
                            cell.lblDate.hidden =YES;
                            float height =[self getSize:dbmanager.message];
                            if(height < 30)
                            {
                                height =30;
                            }
                            
                            [cell.lblName setFrame:CGRectMake(cell.lblName.frame.origin.x, 0, cell.lblName.frame.size.width, cell.lblName.frame.size.height)];
                            
                            [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-widthg2-15, cell.imgBg.frame.origin.y-5, widthg2, height+15)];
                            
                            [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                            
                            [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                            
                            [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                            
                            
                            
                        }
                        else
                        {
                            cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                            
                            float height =[self getSize:dbmanager.message];
                            if(height < 30)
                            {
                                height =30;
                            }
                            
                            [cell.lblName setFrame:CGRectMake(cell.lblName.frame.origin.x, cell.lblName.frame.origin.y-5, cell.lblName.frame.size.width, cell.lblName.frame.size.height)];
                            
                            [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-widthg2-15, cell.lblName.frame.origin.y+cell.lblName.frame.size.height+5, widthg2, height+20)];
                            
                            [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                            
                            [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                            
                            [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                            
                            
                        }
                        
                        
                    }
                    
                    cell.lblTime.text =[self getDate:[NSString stringWithFormat:@"%@",dbmanager.time]];
                    
                    cell.lblMessage.text =[dbmanager.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    cell.lblName.text =[NSString stringWithFormat:@"%@",dbmanager.idd];
                    cell.imgBg.layer.masksToBounds = YES;
                    cell.imgBg.layer.cornerRadius = 20.0;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    
                    
                    return cell;
                }
                
                
            }
            else
            {
                dbmanager =[messages objectAtIndex:indexPath.row];
                
               
                if (![dbmanager.idd isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
                {
                    
                    MessageCell2 *cell = (MessageCell2 *)[self.tView dequeueReusableCellWithIdentifier:nil];
                    if (cell == nil)
                    {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell2" owner:self options:nil];
                        cell = [nib objectAtIndex:0];
                    }
                    [cell setBackgroundColor:[UIColor clearColor]];
                    [cell.contentView setBackgroundColor:[UIColor clearColor]];
                    cell.lblDate.layer.masksToBounds = YES;
                    cell.lblDate.layer.cornerRadius = 8.0;
                    
                    [cell.lblName setHidden:YES];
                    if(indexPath.row==1)
                    {
                        cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                        float height =[self getSize:dbmanager.message];
                        float width2 =[self getSizeWidth:dbmanager.message];
                        
                            if(width2<125)
                            {
                                [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                            }
                            else
                            {
                                [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-width2-15, cell.imgBg.frame.origin.y, width2, height+30)];
                            }
                            
                            
                            [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-25)];
                            
                            [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                            [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                      
                        
                        
                    }
                    else
                    {
                        DB *db=[messages objectAtIndex:indexPath.row-1];
                        
                        float width2 =[self getSizeWidth:dbmanager.message];
                        
                        if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]]])
                        {
                            cell.imgSep1.hidden =YES;
                            cell.imgSep2.hidden =YES;
                            cell.lblDate.hidden =YES;
                            float height =[self getSize:dbmanager.message];
                                
                                if(width2<125)
                                {
                                   // [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, 5, cell.imgBg.frame.size.width, height+30)];
                                    
                                    [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, 0, cell.imgBg.frame.size.width, height+30)];
                                }
                                else
                                {
                                    [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-width2-15, 0, width2, height+30)];
                                }
                                
                                [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-25)];
                                
                                [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                                [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                         
                        }
                        else
                        {
                            cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                            
                            float height =[self getSize:dbmanager.message];
                           
                            if(width2<125)
                            {
                                // [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-width2-15, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                                
                                [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                            }
                            else
                            {
                                [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-width2-15, cell.imgBg.frame.origin.y, width2, height+30)];
                            }                            
                            
                            [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-25)];
                            
                            [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                            [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                            
                        }
                        
                    }
                    
                    
                    
                    
                    cell.lblTime.text =[self getDate:[NSString stringWithFormat:@"%@",dbmanager.time]];
                    
                    cell.lblMessage.text =[dbmanager.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    // cell.lblName.text =[NSString stringWithFormat:@"%@",dbmanager.idd];
                    cell.imgBg.layer.masksToBounds = YES;
                    cell.imgBg.layer.cornerRadius = 20.0;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    
                    
                    
                    return cell;
                    
                }
                else
                {
                    MessageCell1 *cell = (MessageCell1 *)[self.tView dequeueReusableCellWithIdentifier:nil];
                    if (cell == nil)
                    {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell1" owner:self options:nil];
                        cell = [nib objectAtIndex:0];
                    }
                    
                    [cell setBackgroundColor:[UIColor clearColor]];
                    [cell.contentView setBackgroundColor:[UIColor clearColor]];
                    cell.lblDate.layer.masksToBounds = YES;
                    cell.lblDate.layer.cornerRadius = 8.0;
                    
                    if(indexPath.row==1)
                    {
                        cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                        float height =[self getSize:dbmanager.message];
                        float width1 =[self getSizeWidth:dbmanager.message];
                        
                        // if([dbmanager.message length]*7 > 120)
                        // {
                        
                        
                        if(width1<125)
                        {
                            [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                            
                        }
                        else
                        {
                            [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, width1, height+30)];
                            
                        }
                        
                        [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                        
                        [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                        
                        [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                        // }
                        // }
                        
                    }
                    else
                    {
                        float width1 =[self getSizeWidth:dbmanager.message];
                        
                        DB *db=[messages objectAtIndex:indexPath.row-1];
                        
                        if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]]])
                        {
                            cell.imgSep1.hidden =YES;
                            cell.imgSep2.hidden =YES;
                            cell.lblDate.hidden =YES;
                            
                            float height =[self getSize:dbmanager.message];
                           
                                
                                if(width1<125)
                                {
                                    [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, 0, cell.imgBg.frame.size.width, height+30)];
                                    
                                }
                                else
                                {
                                    [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, 0, width1, height+30)];
                                    
                                }
                                [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                                
                                [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                                
                                [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                            
                            }
                        else
                        {
                            cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                            float height =[self getSize:dbmanager.message];
                            
                            
                            if(width1<125)
                            {
                                [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                                
                            }
                            else
                            {
                                [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, width1, height+30)];
                                
                            }
                            
                            
                            [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                            
                            [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                            
                            [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                            
                            
                        }
                        
                    }
                    
                    
                    cell.lblTime.text =[self getDate:[NSString stringWithFormat:@"%@",dbmanager.time]];
                    
                    
                    
                    cell.lblMessage.text =[dbmanager.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    cell.imgBg.layer.masksToBounds = YES;
                    cell.imgBg.layer.cornerRadius = 20.0;
                    
                    UIImageView *deliverimage;
                    if ([dbmanager.delivered isEqualToString:@"Y"])
                    {
                        deliverimage =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deliver"]];
                        [deliverimage setFrame:CGRectMake(cell.imgBg.frame.size.width-20,cell.lblTime.frame.origin.y+5,16,7)];
                        [cell addSubview:deliverimage];
                        
                        
                        
                    }
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    return cell;
                }
                
            }
        }
        
        
    }
    else
    {
   
        if(isGroupChat)
        {
            
            dbmanager =[messages objectAtIndex:indexPath.row];
            
            
            if ([dbmanager.idd isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
            {
                MessageCell1 *cell = (MessageCell1 *)[self.tView dequeueReusableCellWithIdentifier:nil];
                cell = nil;
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell1" owner:self options:nil];
                    cell = [nib objectAtIndex:0];
                }
                
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell.contentView setBackgroundColor:[UIColor clearColor]];
                cell.lblDate.layer.masksToBounds = YES;
                cell.lblDate.layer.cornerRadius = 8.0;
                float widthg1 =[self getSizeWidth:dbmanager.message];
                if(widthg1 < 120)
                {
                    widthg1 =130;
                }
                
                if(indexPath.row==0)
                {
                    cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                    float height =[self getSize:dbmanager.message];
                    
                    if(height < 30)
                    {
                        height =30;
                    }
                    
                    
                    [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, widthg1, height+20)];
                    
                    [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                    
                    [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                    
                    [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                    
                    
                    
                }
                else
                {
                    
                    DB *db=[messages objectAtIndex:indexPath.row-1];
                    
                    if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]]])
                    {
                        cell.imgSep1.hidden =YES;
                        cell.imgSep2.hidden =YES;
                        cell.lblDate.hidden =YES;
                        
                        float height =[self getSize:dbmanager.message];
                        
                        if(height < 30)
                        {
                            height =30;
                        }
                        
                        [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, 0, widthg1, height+20)];
                        
                        [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                        
                        [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                        
                        [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                        
                    }
                    else
                    {
                        cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                        
                        float height =[self getSize:dbmanager.message];
                        if(height < 30)
                        {
                            height =30;
                        }
                        
                        [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, widthg1, height+20)];
                        
                        [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                        
                        [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                        
                        [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                        
                    }
                    
                }
                cell.lblTime.text =[self getDate:[NSString stringWithFormat:@"%@",dbmanager.time]];
                
                cell.lblMessage.text =[dbmanager.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                cell.imgBg.layer.masksToBounds = YES;
                cell.imgBg.layer.cornerRadius = 20.0;
                UIImageView *deliverimage;
                if ([dbmanager.delivered isEqualToString:@"Y"])
                {
                    deliverimage =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deliver"]];
                    [deliverimage setFrame:CGRectMake(cell.imgBg.frame.size.width-20,cell.lblTime.frame.origin.y+5,16,7)];
                    [cell addSubview:deliverimage];
                    
                    
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                
                return cell;
            }
            else
            {
                MessageCell3 *cell = (MessageCell3 *)[self.tView dequeueReusableCellWithIdentifier:nil];
                cell = nil;
                if (cell == nil)
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell2" owner:self options:nil];
                    cell = [nib objectAtIndex:0];
                }
                
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell.contentView setBackgroundColor:[UIColor clearColor]];
                
                cell.lblDate.layer.masksToBounds = YES;
                cell.lblDate.layer.cornerRadius = 8.0;
                
                
                float widthg2 =[self getSizeWidth:dbmanager.message];
                if(widthg2 < 120)
                {
                    widthg2 =130;
                }
                
                
                if(indexPath.row==0)
                {
                    cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                    float height =[self getSize:dbmanager.message];
                    if(height < 30)
                    {
                        height =30;
                    }
                    
                    [cell.lblName setFrame:CGRectMake(cell.lblName.frame.origin.x, cell.lblName.frame.origin.y-5, cell.lblName.frame.size.width, cell.lblName.frame.size.height)];
                    
                    [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-widthg2-15, cell.lblName.frame.origin.y+cell.lblName.frame.size.height+5, widthg2, height+20)];
                    
                    [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                    
                    [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                    
                    [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                    
                    
                }
                else
                {
                    DB *db=[messages objectAtIndex:indexPath.row-1];
                    
                    if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]]])
                    {
                        cell.imgSep1.hidden =YES;
                        cell.imgSep2.hidden =YES;
                        cell.lblDate.hidden =YES;
                        float height =[self getSize:dbmanager.message];
                        if(height < 30)
                        {
                            height =30;
                        }
                        
                        [cell.lblName setFrame:CGRectMake(cell.lblName.frame.origin.x, 0, cell.lblName.frame.size.width, cell.lblName.frame.size.height)];
                        
                        [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-widthg2-15, cell.imgBg.frame.origin.y-5, widthg2, height+15)];
                        
                        [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                        
                        [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                        
                        [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                        
                        
                        
                    }
                    else
                    {
                        cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                        
                        float height =[self getSize:dbmanager.message];
                        if(height < 30)
                        {
                            height =30;
                        }
                        
                        [cell.lblName setFrame:CGRectMake(cell.lblName.frame.origin.x, cell.lblName.frame.origin.y-5, cell.lblName.frame.size.width, cell.lblName.frame.size.height)];
                        
                        [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-widthg2-15, cell.lblName.frame.origin.y+cell.lblName.frame.size.height+5, widthg2, height+20)];
                        
                        [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                        
                        [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                        
                        [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                        
                        
                    }
                    
                    
                }
                cell.lblTime.text =[self getDate:[NSString stringWithFormat:@"%@",dbmanager.time]];
                
                cell.lblMessage.text =[dbmanager.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                cell.lblName.text =[NSString stringWithFormat:@"%@",dbmanager.idd];
                cell.imgBg.layer.masksToBounds = YES;
                cell.imgBg.layer.cornerRadius = 20.0;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
                
                return cell;
            }
            
            
        }
        else
        {
        dbmanager =[messages objectAtIndex:indexPath.row];
        
        /*
         if ([dbmanager.isShow isEqualToString:@"R"])
         {
         */
        if (![dbmanager.idd isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
        {
        
            MessageCell2 *cell = (MessageCell2 *)[self.tView dequeueReusableCellWithIdentifier:nil];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell2" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            NSLog(@"message is %@",dbmanager.message);
            cell.lblDate.layer.masksToBounds = YES;
            cell.lblDate.layer.cornerRadius = 8.0;
            
            [cell.lblName setHidden:YES];
            if(indexPath.row==0)
            {
                 cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                float height =[self getSize:dbmanager.message];
                float width2 =[self getSizeWidth:dbmanager.message];
  
                    if(width2<125)
                    {
                       // [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-width2-15, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                        
                        [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                    }
                    else
                    {
                        [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-width2-15, cell.imgBg.frame.origin.y, width2, height+30)];
                    }
                    
                        
                        [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-25)];
                        
                       [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                        [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                                           
            }
            else
            {
                DB *db=[messages objectAtIndex:indexPath.row-1];

                float width2 =[self getSizeWidth:dbmanager.message];

                if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]]])
                {
                    cell.imgSep1.hidden =YES;
                    cell.imgSep2.hidden =YES;
                    cell.lblDate.hidden =YES;
                    float height =[self getSize:dbmanager.message];

                        
                        if(width2<125)
                        {
                            [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, 0, cell.imgBg.frame.size.width, height+30)];
                        }
                        else
                        {
                            [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-width2-15, 0, width2, height+30)];
                        }
                            
                            [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-25)];
                            
                            [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                            [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                    
                }
                else
                {
                      cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                    
                    float height =[self getSize:dbmanager.message];
                   
                    if(width2<125)
                    {
                        // [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-width2-15, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                        
                        [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                    }
                    else
                    {
                        [cell.imgBg setFrame:CGRectMake(cell.frame.size.width-width2-15, cell.imgBg.frame.origin.y, width2, height+30)];
                    }
                    
                    
                    [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-25)];
                    
                    [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x-50, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                    [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                 
                }
                
            }
            
      
            
         
            cell.lblTime.text =[self getDate:[NSString stringWithFormat:@"%@",dbmanager.time]];

            cell.lblMessage.text =[dbmanager.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
           // cell.lblName.text =[NSString stringWithFormat:@"%@",dbmanager.idd];
            cell.imgBg.layer.masksToBounds = YES;
            cell.imgBg.layer.cornerRadius = 20.0;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            
            
            return cell;
            
        }
        else
        {
            MessageCell1 *cell = (MessageCell1 *)[self.tView dequeueReusableCellWithIdentifier:nil];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell1" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            
            cell.lblDate.layer.masksToBounds = YES;
            cell.lblDate.layer.cornerRadius = 8.0;
            
            if(indexPath.row==0)
            {
                 cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                float height =[self getSize:dbmanager.message];
                float width1 =[self getSizeWidth:dbmanager.message];

               // if([dbmanager.message length]*7 > 120)
               // {
                   
                    
                    if(width1<125)
                    {
                        [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                        
                    }
                    else
                    {
                        [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, width1, height+30)];
                        
                    }
                
                        [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                        
                        [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                        
                        [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                   // }
               // }
                
            }
            else
            {
                float width1 =[self getSizeWidth:dbmanager.message];

                DB *db=[messages objectAtIndex:indexPath.row-1];
                
                if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]]])
                {
                    cell.imgSep1.hidden =YES;
                    cell.imgSep2.hidden =YES;
                    cell.lblDate.hidden =YES;
                    
                    float height =[self getSize:dbmanager.message];

                 
                        
                        if(width1<125)
                        {
                            [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, 0, cell.imgBg.frame.size.width, height+30)];
                            
                        }
                        else
                        {
                            [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, 0, width1, height+30)];
                            
                        }
                            [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                            
                            [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                            
                            [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                  
                }
                else
                {
                     cell.lblDate.text =[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",dbmanager.time]]] ;
                    float height =[self getSize:dbmanager.message];
                    
                   /* if([dbmanager.message length]*7 > 120)
                    {*/
                        if(width1<125)
                        {
                            [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, cell.imgBg.frame.size.width, height+30)];
                            
                        }
                        else
                        {
                           [cell.imgBg setFrame:CGRectMake(cell.imgBg.frame.origin.x, cell.imgBg.frame.origin.y, width1, height+30)];
                            
                        }
                        
                        
                        [cell.lblMessage setFrame:CGRectMake(cell.imgBg.frame.origin.x+10, cell.imgBg.frame.origin.y+5, cell.imgBg.frame.size.width-15, cell.imgBg.frame.size.height-20)];
                        
                        [cell.lblTime setFrame:CGRectMake(cell.lblTime.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-16, cell.lblTime.frame.size.width+50, cell.lblTime.frame.size.height)];
                        
                        [cell.imgPointer setFrame:CGRectMake(cell.imgPointer.frame.origin.x, cell.imgBg.frame.origin.y+cell.imgBg.frame.size.height-37, cell.imgPointer.frame.size.width, cell.imgPointer.frame.size.height)];
                        // }
                  //  }
                   
                }
                
            }
            
        
            cell.lblTime.text =[self getDate:[NSString stringWithFormat:@"%@",dbmanager.time]];
           
            
           
            cell.lblMessage.text =[dbmanager.message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            cell.imgBg.layer.masksToBounds = YES;
            cell.imgBg.layer.cornerRadius = 20.0;
            
            UIImageView *deliverimage;
            if ([dbmanager.delivered isEqualToString:@"Y"])
            {
                deliverimage =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deliver"]];
                [deliverimage setFrame:CGRectMake(cell.imgBg.frame.size.width-20,cell.lblTime.frame.origin.y+5,16,7)];
                [cell addSubview:deliverimage];
              
                
                
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }

    }
    }
    
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isMore )
    {
        if(indexPath.row==0)
        {
            return 50;
        }
        else
        {
            if(isGroupChat)
            {
                DB *db=[messages objectAtIndex:indexPath.row];
              
                if ([dbmanager.idd isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
                {
                    if(indexPath.row==1)
                    {
                        
                        float height =[self getSize:db.message];
                        
                        if((height +70)<90)
                        {
                            return 90;
                        }
                        else
                        {
                            return height+70;
                        }
                    }
                    else
                    {
                        DB *db1=[messages objectAtIndex:indexPath.row-1];
                        float height =[self getSize:db.message];
                        
                        
                        if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db1.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]]])
                        {
                            if(height<20)
                            {
                                return 60;
                            }
                            else
                            {
                                return height+40;
                            }
                        }
                        else
                        {
                            
                           /* if((height +60)<80)
                            {
                                return 85;
                            }
                            else
                            {
                                return height+65;
                            }*/
                            if((height +70)<90)
                            {
                                return 90;
                            }
                            else
                            {
                                return height+70;
                            }
                        }
                    }
                   
                    
                }
                else
                {
                    if(indexPath.row==1)
                    {
                        
                        float height =[self getSize:db.message];
                        if((height +70)<100)
                        {
                            return 105;
                        }
                        else
                        {
                            return height+75;
                        }
                    }
                    else
                    {
                        DB *db1=[messages objectAtIndex:indexPath.row-1];
                        float height =[self getSize:db.message];
                        
                        
                        if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db1.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]]])
                        {
                            if(height<20)
                            {
                                return 75;
                            }
                            else
                            {
                                return height+55;
                            }
                        }
                        else
                        {
                            
                            float height =[self getSize:db.message];
                            if((height +70)<100)
                            {
                                return 105;
                            }
                            else
                            {
                                return height+75;
                            }
                        }
                        
                        
                        
                    }
                }
                
            }
            else
            {
                DB *db=[messages objectAtIndex:indexPath.row];
                /* if ([db.isShow isEqualToString:@"R"])
                 {*/
                if (![dbmanager.idd isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
                {
                    
                    if(indexPath.row==1)
                    {
                        
                        float height =[self getSize:db.message];
                        
                        if((height +60)<80)
                        {
                            return 85;
                        }
                        else
                        {
                            return height+70;
                        }
                    }
                    else
                    {
                        DB *db1=[messages objectAtIndex:indexPath.row-1];
                        float height =[self getSize:db.message];
                        
                        
                        if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db1.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]]])
                        {
                            if(height<20)
                            {
                                return 55;
                            }
                            else
                            {
                                return height+40;
                            }
                        }
                        else
                        {
                            
                            // float height =[self getSize:db.message];
                            
                            if((height +60)<80)
                            {
                                return 85;
                            }
                            else
                            {
                                return height+70;
                            }
                        }
                        
                        
                        
                    }
                    
                }
                else
                {
                    if(indexPath.row==1)
                    {
                        
                        float height =[self getSize:db.message];
                        
                        if((height +60)<80)
                        {
                            return 85;
                        }
                        else
                        {
                            return height+70;
                        }
                        /*
                         if((height +70)<90)
                         {
                         return 90;
                         }
                         else
                         {
                         return height+70;
                         }
                         */
                    }
                    else
                    {
                        DB *db1=[messages objectAtIndex:indexPath.row-1];
                        float height =[self getSize:db.message];
                        
                        
                        if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db1.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]]])
                        {
                            if(height<20)
                            {
                                return 55;
                            }
                            else
                            {
                                return height+40;
                            }
                        }
                        else
                        {
                            
                            if((height +60)<80)
                            {
                                return 85;
                            }
                            else
                            {
                                return height+70;
                            }
                        }
                        
                        
                        
                    }
                }
                
                
            }
        }
        
    }
    else
    {
    if(isGroupChat)
    {
        DB *db=[messages objectAtIndex:indexPath.row];
        
        /*if ([db.isShow isEqualToString:@"L"])
        {*/
        if ([dbmanager.idd isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
        {
            if(indexPath.row==0)
            {
                float height =[self getSize:db.message];
                
              /*  if((height +60)<80)
                {
                    return 80;
                }
                else
                {
                    return height+60;
                }*/
                
                if((height +70)<90)
                {
                    return 90;
                }
                else
                {
                    return height+70;
                }
            }
            else
            {
                DB *db1=[messages objectAtIndex:indexPath.row-1];
                float height =[self getSize:db.message];
                
                
                if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db1.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]]])
                {
                    if(height<20)
                    {
                        return 60;
                    }
                    else
                    {
                        return height+40;
                    }
                }
                else
                {
                    
                   /* if((height +60)<80)
                    {
                        return 80;
                    }
                    else
                    {
                        return height+60;
                    }*/
                    if((height +70)<90)
                    {
                        return 90;
                    }
                    else
                    {
                        return height+70;
                    }
                }
            }
            
           
        }
        else
        {
            if(indexPath.row==0)
            {
                
                float height =[self getSize:db.message];
                if((height +70)<100)
                {
                    return 105;
                }
                else
                {
                    return height+75;
                }
            }
            else
            {
                DB *db1=[messages objectAtIndex:indexPath.row-1];
                float height =[self getSize:db.message];
                
                
                if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db1.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]]])
                {
                    if(height<20)
                    {
                        return 75;
                    }
                    else
                    {
                        return height+55;
                    }
                }
                else
                {
                    
                    float height =[self getSize:db.message];
                    if((height +70)<100)
                    {
                        return 105;
                    }
                    else
                    {
                        return height+75;
                    }
                }
                
                
                
            }
        }      

    }
    else
    {
        DB *db=[messages objectAtIndex:indexPath.row];
       /* if ([db.isShow isEqualToString:@"R"])
        {*/
        if (![dbmanager.idd isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
        {
            
            if(indexPath.row==0)
            {
                
                float height =[self getSize:db.message];
                
               /* if((height +60)<80)
                {
                    return 80;
                }
                else
                {
                    return height+60;
                }*/
                
                if((height +60)<80)
                {
                    return 85;
                }
                else
                {
                    return height+70;
                }
            }
            else
            {
                DB *db1=[messages objectAtIndex:indexPath.row-1];
                float height =[self getSize:db.message];
                
                
                if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db1.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]]])
                {
                    if(height<20)
                    {
                        return 55;
                    }
                    else
                    {
                        return height+40;
                    }
                }
                else
                {
                    
                   // float height =[self getSize:db.message];
                    
                    if((height +60)<80)
                    {
                        return 85;
                    }
                    else
                    {
                        return height+70;
                    }
                }
                
                
            }

        }
        else
        {
            if(indexPath.row==0)
            {
                
                float height =[self getSize:db.message];
                
                /*if((height +60)<80)
                {
                    return 80;
                }
                else
                {
                    return height+60;
                }*/
                if((height +60)<80)
                {
                    return 85;
                }
                else
                {
                    return height+70;
                }
            }
            else
            {
                DB *db1=[messages objectAtIndex:indexPath.row-1];
                float height =[self getSize:db.message];
                
                
                if([[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db1.time]]] isEqualToString:[NSString stringWithFormat:@"%@",[self getDate2:[NSString stringWithFormat:@"%@",db.time]]]])
                {
                    if(height<20)
                    {
                        return 55;
                    }
                    else
                    {
                        return height+40;
                    }
                }
                else
                {
                    
                    /*if((height +60)<80)
                    {
                        return 80;
                    }
                    else
                    {
                        return height+60;
                    }*/
                    if((height +60)<80)
                    {
                        return 85;
                    }
                    else
                    {
                        return height+70;
                    }
                }
                
                
                
            }
        }

        
    }
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 //   [self.view endEditing:YES];
    if(isMore && indexPath.row==0)
    {
       /* if(IS_Ipad || IS_IPHONE_6_PLUS)
        {
            messageOffset+=15;
        }
        else
        {*/
            messageOffset+=50;
        //}
        
        [self loadMore];
    }
}

-(NSString *)getDate2:(NSString *)timestamp
{
    
    NSTimeInterval _interval=[timestamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    //dd/MMM/yyyy
    [_formatter setDateFormat:@"EEE, MMM dd, yyyy"];
    NSString *_date=[_formatter stringFromDate:date];
    return _date;
}
-(NSString *)getDate:(NSString *)timestamp
{
    
    NSTimeInterval _interval=[timestamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"hh:mm a"];
  /*  NSString *_date=[_formatter stringFromDate:date];
    return _date;*/
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [dateFormatter stringFromDate:date];
   // NSLog(@"User's current time in their preference format:%@",currentTime);
     return currentTime;
}
-(NSString *)getTime:(NSDate *)timestamp
{
    
//    NSTimeInterval _interval=[timestamp doubleValue];
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
//    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
//    [_formatter setDateFormat:@"hh:mm a"];
//    NSString *_date=[_formatter stringFromDate:date];
//    return _date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
   // [formatter setDateFormat:@"dd/MM/yyyy"];
  //  NSDate *date = [formatter dateFromString:timestamp];
   // [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];

    [formatter setDateFormat:@"hh:mm a"];
    NSString *newDate = [formatter stringFromDate:timestamp];
    return newDate;
}
-(NSString *)getTime2:(NSDate *)timestamp
{
    
    //    NSTimeInterval _interval=[timestamp doubleValue];
    //    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    //    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    //    [_formatter setDateFormat:@"hh:mm a"];
    //    NSString *_date=[_formatter stringFromDate:date];
    //    return _date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // [formatter setDateFormat:@"dd/MM/yyyy"];
    //  NSDate *date = [formatter dateFromString:timestamp];
    [formatter setDateFormat:@"EEE, MMM dd, yyyy"];
    NSString *newDate = [formatter stringFromDate:timestamp];
    return newDate;
}
-(float)getSize:(NSString *)message
{
    CGSize boundingSize ;
    if(IS_Ipad)
    {
        boundingSize = CGSizeMake(240, 10000000);
    }
    else
    {
        boundingSize = CGSizeMake(self.view.bounds.size.width-90, 10000000);
    }
    CGSize itemTextSize = [message sizeWithFont:[UIFont systemFontOfSize:13.0]
                              constrainedToSize:boundingSize
                                  lineBreakMode:NSLineBreakByTruncatingTail];
    float cellHeight = itemTextSize.height+5;
    return cellHeight;
    
    
    /*
     CGSize boundingSize ;
     if(IS_Ipad)
     {
     boundingSize = CGSizeMake(240, 10000000);
     }
     else
     {
     boundingSize = CGSizeMake(self.view.bounds.size.width-110, 10000000);
     }
     CGSize itemTextSize = [message sizeWithFont:[UIFont systemFontOfSize:13.3]
     constrainedToSize:boundingSize
     lineBreakMode:NSLineBreakByTruncatingTail];
     float cellHeight = itemTextSize.height;
     return cellHeight;
     */
}
-(float)getSizeWidth:(NSString *)message
{
    CGSize boundingSize ;
    if(IS_Ipad)
    {
        boundingSize = CGSizeMake(240, 10000000);
        
    }
    else
    {
        boundingSize = CGSizeMake(self.view.bounds.size.width-80, 10000000);
        
    }
    CGSize itemTextSize = [message sizeWithFont:[UIFont systemFontOfSize:15]
                              constrainedToSize:boundingSize
                                  lineBreakMode:NSLineBreakByTruncatingTail];
   // float cellHeight = itemTextSize.height;
    return itemTextSize.width;
}
- (IBAction)backTapped:(id)sender
{
    [USER_DEFAULTS removeObjectForKey:@"fromJId"];
    [USER_DEFAULTS synchronize];
  //  [xmppRoom leaveRoom];
    //[xmppRoom deactivate];
    [xmppRoom removeDelegate:DELEGATE];
   // [DELEGATE leaveFromRoom];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)ConfigureNewRoom
{
   
    [xmppRoom configureRoomUsingOptions:nil];
    [xmppRoom fetchConfigurationForm];
    [xmppRoom fetchBanList];
    [xmppRoom fetchMembersList];
    [xmppRoom fetchModeratorsList];
    
}
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    DDLogVerbose(@"%@: %@ -> %@", THIS_FILE, THIS_METHOD, sender.roomJID.user);
   // NSXMLElement *newConfig = [configForm copy];
    
   
     NSXMLElement *newConfig = [configForm copy];
     NSArray* fields = [newConfig elementsForName:@"field"];
     for (NSXMLElement *field in fields)
     {
         NSString *var = [field attributeStringValueForName:@"var"];
         if ([var isEqualToString:@"muc#roomconfig_persistentroom"])
         {
             [field removeChildAtIndex:0];
             [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
         }
     }
        [sender configureRoomUsingOptions:newConfig];
}

//#pragma mark XMPPRoom Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)hideDRK
{
    [drk hide];
}
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    [drk hide];
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    // [logField setStringValue:@"did create room"];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    [drk hide];
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //[xmppRoom fetchConfigurationForm];
    //[logField setStringValue:@"did join room"];
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    [drk hide];
 [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Could not connect"] AlertFlag:1 ButtonFlag:1];    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //[logField setStringValue:@"did leave room"];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //[logField setStringValue:[NSString stringWithFormat:@"occupant did join: %@", [occupantJID resource]]];
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //[logField setStringValue:[NSString stringWithFormat:@"occupant did join: %@", [occupantJID resource]]];
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  //  NSLog(@"received from %@",occupantJID.resource);
  //  NSLog(@"%@",message);
  //  NSLog(@"%@",[message from] );
    // [messages addObject:message];
    
    //[self.tableview reloadData];
    
    //[logField setStringValue:[NSString stringWithFormat:@"did receive msg from: %@", [occupantJID resource]]];
    
    
    NSDate *nowUTC = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSString *messageID=[DELEGATE.xmppStream generateUUID];
    
    if (occupantJID.resource != (id)[NSNull null] || occupantJID.resource.length != 0 )
    {
        if(![occupantJID.resource isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
        {
            DB *DB1;
            DB1 = [DB newInsertedObject];
            DB1.waitingType =messageID;
            DB1.delivered =@"Y";
            DB1.messageType =@"G";
            DB1.identifier = @([CoreDataUtils getNextID:[DB description]]);
            BOOL isfrom=NO;
            
            DB1.from=@(isfrom);
            DB1.timestamp = nowUTC;
            DB1.time = [DELEGATE GetUniversalTime:nowUTC];
            DB1.idd =occupantJID.resource ;//[USER_DEFAULTS valueForKey:@"fullname"];
            NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
            NSString *str =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
            // NSString *useridd =[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]];
            DB1.userid = str ;
            DB1.message =[[message elementForName:@"body"] stringValue];
            /* if([occupantJID.resource isEqualToString:[USER_DEFAULTS valueForKey:@"fullname"]])
             {
             DB1.isShow = @"L" ;
             }
             else
             {*/
            DB1.isShow = @"R" ;
            // }
            
            DB1.jid = [NSString stringWithFormat:@"%@",self.fromJId];
            
            DB1.isClear = @"Y";
            
            [CoreDataUtils updateDatabase];
            [self fetchMessages];
            
        }

    }
    
    
    /*
     received from Rajesh
     2015-05-01 16:41:00.214 AmHappy[9034:144705] <message xmlns="jabber:client" type="groupchat" to="user27@amhappy.es/9654be5a" messageType="G" id="4D1B6D10-250E-4AAF-9B9A-0151534D0B00" sendername="Rajesh" align="L" from="room165@conference.amhappy.es/Rajesh"><body>fg</body></message>
     2015-05-01 16:41:02.465 AmHappy[9034:144705] room165@conference.amhappy.es/Rajesh
     */
    
    

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

#pragma mark XMPPRoomMemoryStorage Delegate


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
              occupantDidJoin:(XMPPRoomOccupantMemoryStorageObject *)occupant
                      atIndex:(NSUInteger)index
                      inArray:(NSArray *)allOccupants {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
}


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
             occupantDidLeave:(XMPPRoomOccupantMemoryStorageObject *)occupant
                      atIndex:(NSUInteger)index
                    fromArray:(NSArray *)allOccupants {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
   
    
    
}


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
            occupantDidUpdate:(XMPPRoomOccupantMemoryStorageObject *)occupant
                    fromIndex:(NSUInteger)oldIndex
                      toIndex:(NSUInteger)newIndex
                      inArray:(NSArray *)allOccupants {
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    
    
}


- (void)xmppRoomMemoryStorage:(XMPPRoomMemoryStorage *)sender
            didReceiveMessage:(XMPPRoomMessageMemoryStorageObject *)message
                 fromOccupant:(XMPPRoomOccupantMemoryStorageObject *)occupantJID
                      atIndex:(NSUInteger)index
                      inArray:(NSArray *)allMessages {
    
    if(message.isFromMe)
    {
        DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    }
    else
    {
       
    }
   /* [groupMessages removeAllObjects];
    groupMessages=[[NSMutableArray alloc] initWithArray:allMessages];
    [self.tView reloadData];
    NSIndexPath *iPath = [NSIndexPath indexPathForRow:groupMessages.count-1 inSection:0];
    [self.tView scrollToRowAtIndexPath:iPath atScrollPosition:UITableViewScrollPositionTop animated:NO];*/
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
  
    
}



- (IBAction)showGuestTapped:(id)sender
{
    GuestViewController *guestVC =[[GuestViewController alloc] initWithNibName:@"GuestViewController" bundle:nil];
    [guestVC setEventID:self.eventId];
    [guestVC setIsMy:NO];
    [guestVC setIsPrivate:NO];
    [guestVC setIsFromChat:YES];
    
    guestVC.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:guestVC animated:YES];
    
    [self.btnShowGuest setUserInteractionEnabled:NO];
    
}
@end

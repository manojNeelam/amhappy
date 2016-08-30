//
//  EventDetailViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 13/02/15.
//
//

#import "EventDetailViewController.h"
#import "ModelClass.h"
#import "EventListCell.h"
#import "UIImageView+WebCache.h"
#import "EventCalendarViewController.h"
#import "userCell.h"

#import "EventLocationViewController.h"
#import "GuestViewController.h"
#import "EventTabViewController.h"
#import "ShowImageViewController.h"
#import "OtherUserProfileViewController.h"
#import "TYMActivityIndicatorViewViewController.h"
#import "EventPhotoViewController.h"
#import "RegistrationViewController.h"
#import "likesPeople.h"
#import "Guests.h"
#import "TwoImages.h"
#import "ThreeImages.h"
#import "FourImages.h"
#import "FiveImages.h"




#import "DAAttributedLabel.h"
#import "DAAttributedStringFormatter.h"
#import "DAFontSet.h"

#import "UIButton+WebCache.h"



#import "MHFacebookImageViewer.h"
#import "UIImageView+MHFacebookImageViewer.h"
#import <MobileCoreServices/UTCoreTypes.h>

#import "ELCImagePickerHeader.h"
#import "RPMultipleImagePickerViewController.h"
#import <QuartzCore/QuartzCore.h>


#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


#define COMMENT_LABEL_WIDTH 200

#define COMMENT_LABEL_MIN_HEIGHT 60
#define COMMENT_LABEL_PADDING 10

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

#define VIEW_FOR_ZOOM_TAG (1)


#define viewAllcommentsHeight (40)
#define replyCellHeight (40)

@interface EventDetailViewController ()<UIDocumentInteractionControllerDelegate,MHFacebookImageViewerDatasource,DAAttributedLabelDelegate,ELCImagePickerControllerDelegate,FBSDKSharingDelegate>

@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;

@property (nonatomic, strong) RPMultipleImagePickerViewController *multipleImagePicker;

@end



@implementation EventDetailViewController
{
    ModelClass *mc;
    NSMutableArray *commentArray,*arrayToTag,*arrayFilteredTag,*taggedUsers,*UserToHighlight;
    NSMutableArray *locationArray;
    NSMutableArray *dateArray;

    TYMActivityIndicatorViewViewController *drk;

    NSString *pEvendDate;
    NSString *pEvendname;
    BOOL ischanged,isBeginTagging,isSerchFromData;

    BOOL isLast;
    BOOL isPrivate;
    int attendingTag;
    
    int popupTag;
    int attendingCount;
    
    int newTag;
    
    BOOL isReported;
    
    int reportCommentId;
    
    int likeID;
    
    int likeCount;
    
    NSString *isImageLiked;



    
    NSData *imgData,*imgData2,*imgData3,*imgData4,*imgData5;
    UIImagePickerController *pickerController;
    UIToolbar *mytoolbar1;
    
    BOOL isMy,isAdmin;
    int start;
    int catId;
    NSString *imageURL,*strLastTag,*taggedUserIds;
    NSString *eventThumbImageURL;

    int eventType;
    
    int votedDateId;
    int votedLocId;
    
    int deleteTag;
    
    NSString *createdBy;
    
    NSMutableDictionary *locationDict;
    
    BOOL isEventImage;
    
    BOOL isEventShare;
    float commentViewHeight;
    
    NSString *userImageURL;
    
    NSMutableDictionary *shareDict;
    
    BOOL isEventLiked;
    
    NSMutableDictionary *EventDetails;
    
    //************* Version 4 **********
    
    BOOL isShowAddPhotos;
    
    int CurrentIndex,currentIndexPath,currentImageIndex;
    
    
    DAAttributedStringFormatter* formatter;
    
    NSMutableArray *gettedImages;
    
    
}


@synthesize lblLocation,lblAttending,lblCalendar,lblCount,lblCreatedby,lbldesc,lblGuest,lblPrice,lblShare,lblTitle,lblUserName,btnEdit,btnMaybe,btnPost,btnYes,imgEvent,imgUser,scrollviewBtn,userView,commentView,scrollviewMain,tableViewComment,eventID,lblEventName,imgCommentPre,documentInteractionController;

@synthesize btnCalendar,btnGuest,btnLocation,btnPrice,btnShare,btnLastDate,lblLast,lblLastDate,txtComment,lblReport,btnReport;

@synthesize btnLikeEvent,lblLikeEvent;

@synthesize imgShareBig,shareImageView,shareSubview,bgImage;

@synthesize lblPhoto,lblTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recvData:)
                                                 name:@"commentImages"
                                               object:nil];
    
    
    
    formatter = [[DAAttributedStringFormatter alloc] init];
    formatter.defaultFontFamily = @"Avenir";
    formatter.defaultColor = [UIColor lightGrayColor];
    formatter.fontFamilies = @[ @"Courier", @"Arial", @"Georgia" ];
    formatter.defaultPointSize = 14.0f;
    formatter.colors = @[[UIColor colorWithRed:49.0/255.0 green:160.0/255.0 blue:218.0/255.0 alpha:1.0],[UIColor redColor]];

    
    
    
    self.tblUsers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    isBeginTagging = NO;
    

    arrayToTag = [[NSMutableArray alloc]init];

    arrayFilteredTag = [[NSMutableArray alloc]init];
    

    taggedUserIds           = [[NSString alloc] init];
    
    UserToHighlight = [[NSMutableArray alloc]init];
    
    taggedUsers = [[NSMutableArray alloc]init];
    
    
    taggedUserIds = @"";
    strLastTag    = @"";
    

    
    self.btnRepost.hidden = YES;
    
    CurrentIndex = 0;
    
    currentIndexPath = 0;
    
    currentImageIndex = 0;
    
   
 
    imgEvent.contentMode = UIViewContentModeScaleAspectFill;
    imgEvent.clipsToBounds = YES;
    
    
    imgUser.contentMode = UIViewContentModeScaleAspectFill;
    imgUser.clipsToBounds = YES;
    
    
    NSLog(@"%@",self.eventID);
    
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    likeID =-1;
    locationDict =[[NSMutableDictionary alloc] init];
    start =0;
    newTag = 0;
    likeCount =0;
    commentArray =[[NSMutableArray alloc] init];
    locationArray =[[NSMutableArray alloc] init];
    dateArray =[[NSMutableArray alloc] init];
    imageURL =[[NSString alloc] init];
    pEvendname =[[NSString alloc] init];
    userImageURL =[[NSString alloc] init];
    
    eventThumbImageURL =[[NSString alloc] init];

    
    reportCommentId =-1;

    isEventLiked =NO;
    
    isReported =NO;
    
    
    shareDict =[[NSMutableDictionary alloc] init];

    imgData =nil;
    imgData2 =nil;
    imgData3 =nil;
    imgData4 =nil;
    imgData5 =nil;
    createdBy =[[NSString alloc] init];
    
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    
    isEventImage =NO;
    isEventShare =NO;

    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"voteChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(voteChanged)
                                                 name:@"voteChanged"
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"commentAdded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:@"commentAdded"
                                               object:nil];
    
    
    
    commentViewHeight =self.commentView.frame.size.height;

    
    if(IS_IPHONE_4s)
    {
        [self.bgImage setImage:[UIImage imageNamed:@"bg4s.png"]];
    }
    else if (IS_IPHONE_5)
    {
        [self.bgImage setImage:[UIImage imageNamed:@"bg5.png"]];
    }
    else if (IS_IPHONE_6)
    {
        [self.bgImage setImage:[UIImage imageNamed:@"bg6.png"]];
    }
    else if (IS_IPHONE_6_PLUS)
    {
        [self.bgImage setImage:[UIImage imageNamed:@"bg6plus.png"]];
    }
    else if (IS_Ipad)
    {
        [self.bgImage setImage:[UIImage imageNamed:@"bgipad.png"]];
    }


    votedDateId =-1;
    votedLocId =-1;
    deleteTag =-1;
    attendingTag =-1;
    popupTag =-1;
    
    isLast =YES;
    isPrivate=NO;
    isMy=NO;
    isAdmin=NO;
    
    self.scrollviewMain.delegate=self;
    [self.scrollviewMain setContentSize:CGSizeMake(320, 1000)];
    [self.scrollviewBtn setContentSize:CGSizeMake(1025, 50)];
    
    
    
    UITapGestureRecognizer *eventLikesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLIkes:)];
    eventLikesRecognizer.delegate = self;
    [self.lblLikeEvent setUserInteractionEnabled:YES];
    [self.lblLikeEvent addGestureRecognizer:eventLikesRecognizer];
    
    
    
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOtherUser1:)];
    tapGestureRecognizer1.delegate = self;
    [self.imgEvent setUserInteractionEnabled:YES];
    [self.imgEvent addGestureRecognizer:tapGestureRecognizer1];
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOtherUser:)];
    tapGestureRecognizer.delegate = self;
    [self.imgUser setUserInteractionEnabled:YES];
    [self.imgUser addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOtherUser2:)];
    tapGestureRecognizer2.delegate = self;
    [self.lblUserName setUserInteractionEnabled:YES];
    [self.lblUserName addGestureRecognizer:tapGestureRecognizer2];
    
    if(IS_Ipad)
    {
        [self adjustFrame];
    }
    pEvendDate =[[NSString alloc] init];
    self.imgUser.layer.masksToBounds=YES;
    self.imgUser.layer.cornerRadius=30;
    
   // self.btnMaybe.layer.masksToBounds=YES;
   // self.btnMaybe.layer.cornerRadius=3.0;
    
    self.btnPost.layer.masksToBounds=YES;
    self.btnPost.layer.cornerRadius=3.0;
    
  //  self.btnYes.layer.masksToBounds=YES;
  //  self.btnYes.layer.cornerRadius=3.0;
    
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
    [self.txtComment setDelegate:self];
    [self.txtComment setText:[localization localizedStringForKey:@"Comment"]];
    [self.txtComment setFont:FONT_Regular(14.0)];
    [self.txtComment setTextColor:[UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]];
    
    
    
    UIBarButtonItem *done1 = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Done"]
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self action:@selector(donePressed)];
    [done1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
  
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    mytoolbar1.items = [NSArray arrayWithObjects:flexibleSpace,done1, nil];
    self.txtComment.inputAccessoryView =mytoolbar1;
    
  self.imgCommentPre.frame =CGRectMake(self.imgCommentPre.frame.origin.x, self.txtComment.frame.origin.y+90, self.imgCommentPre.bounds.size.width, self.view.bounds.size.height);
    [self.btnShare setEnabled:NO];
    [self.btnPrice setEnabled:NO];
    [self.btnLocation setEnabled:NO];
    [self.btnGuest setEnabled:NO];
    [self.btnCalendar setEnabled:NO];
    [self.btnLastDate setHidden:NO];
    [self.lblLastDate setHidden:NO];
    [self.lblLast setHidden:NO];
    
    [self localize];
    
    [self callApi];
    
    [self.viewAddImages setHidden:YES];
    
   
    // Do any additional setup after loading the view from its nib.
}

- (void) recvData:(NSNotification *) notification
{
    
    imgData = nil;
    imgData2 = nil;
    imgData3 = nil;
    imgData4 = nil;
    imgData5 = nil;
    
    
    
    NSDictionary* userInfo = notification.userInfo;
    NSMutableArray *messageTotal = [userInfo objectForKey:@"images"];
    NSLog (@"Successfully received data from notification! %@", messageTotal);
  
    gettedImages = [[NSMutableArray alloc]initWithArray:[userInfo objectForKey:@"images"]];
    
    if ([gettedImages count]>0)
    {
        
        imgData = nil;
        imgData2 = nil;
        imgData3 = nil;
        imgData4 = nil;
        imgData5 = nil;
        
        [self.image1 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
        [self.image2 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
        [self.image3 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
        [self.image4 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
        [self.image5 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
        
        [self setUpAddimagesPreview];
        
        [self ShowAddImagesPreview:gettedImages];
       
    }
    else{
        
        
        [self hideAddImagesPreview];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
     [self setUpAddimagesPreview];
}

-(void)setUpAddimagesPreview
{

    int imageWidth = (self.viewAddImages.frame.size.width - 40)/5;
    
    if (imageWidth <= 80)
    {
        self.image1.frame = CGRectMake(10, 20, imageWidth, imageWidth);
        
        self.image2.frame = CGRectMake(self.image1.frame.origin.x+self.image1.frame.size.width+5, 20, imageWidth, imageWidth);
        
        self.image3.frame = CGRectMake(self.image2.frame.origin.x+self.image2.frame.size.width+5, 20, imageWidth, imageWidth);
        
        self.image4.frame = CGRectMake(self.image3.frame.origin.x+self.image3.frame.size.width+5, 20, imageWidth, imageWidth);
        
        self.image5.frame = CGRectMake(self.image4.frame.origin.x+self.image4.frame.size.width+5, 20, imageWidth, imageWidth);
     
    }
    else
    {
        
        self.image1.frame = CGRectMake(10, 20, imageWidth, 80);
        
        self.image2.frame = CGRectMake(self.image1.frame.origin.x+self.image1.frame.size.width+5, 20, imageWidth, 80);
        
        self.image3.frame = CGRectMake(self.image2.frame.origin.x+self.image2.frame.size.width+5, 20, imageWidth, 80);
        
        self.image4.frame = CGRectMake(self.image3.frame.origin.x+self.image3.frame.size.width+5, 20, imageWidth, 80);
        
        self.image5.frame = CGRectMake(self.image4.frame.origin.x+self.image4.frame.size.width+5, 20, imageWidth, 80);
        
        
        
    }

}


-(void)refresh
{
    
    [self viewDidLoad];
}


-(void)voteChanged
{
    [self callApi];
}
-(void)addZoomView:(NSString *)showImageUrl
{
    BOOL zoom;
    int selected_index;
    
    float minimumScale;
    
    [[self.shareSubview viewWithTag:899] removeFromSuperview];

    NSArray *getted_images =[[NSArray alloc] initWithObjects:self.bgImage.image, nil];
    
    UIScrollView * mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,self.shareSubview.frame.size.height)];
    
    mainScrollView.pagingEnabled = YES;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.tag=899;
    
    CGRect innerScrollFrame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,self.shareSubview.frame.size.height);
    
    for (NSInteger i = 0; i < [getted_images count]; i++)
    {
        UIImageView *imageForZooming= [[UIImageView alloc] initWithImage:[getted_images objectAtIndex:i]];
       // UIImageView *imageForZooming= [[UIImageView alloc] initWithImage:showImage];

        // UIImageView *imageForZooming= [[UIImageView alloc] init];
       [imageForZooming sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",showImageUrl]]];
        
        zoom=YES;
        imageForZooming.tag = VIEW_FOR_ZOOM_TAG;
        
        UIScrollView *pageScrollView = [[UIScrollView alloc]
                                        initWithFrame:innerScrollFrame];
        
        
        
        pageScrollView.minimumZoomScale = 1.0f;
        pageScrollView.maximumZoomScale = 2.0f;
        pageScrollView.zoomScale = 1.0f;
        pageScrollView.contentSize = imageForZooming.bounds.size;
        pageScrollView.delegate = self;
        pageScrollView.showsHorizontalScrollIndicator = NO;
        pageScrollView.showsVerticalScrollIndicator = NO;
        
        
        imageForZooming.frame=CGRectMake(pageScrollView.bounds.origin.x,pageScrollView.bounds.origin.y,pageScrollView.bounds.size.width,pageScrollView.bounds.size.height);
        
        imageForZooming.contentMode = UIViewContentModeScaleAspectFill;
        imageForZooming.clipsToBounds = YES;

        //******
        
        
        
        [pageScrollView addSubview:imageForZooming];
        
        imageForZooming.layer.masksToBounds=YES;
        imageForZooming.contentMode=UIViewContentModeScaleAspectFit;
        
        minimumScale = [UIScreen mainScreen].bounds.size.width/ imageForZooming.frame.size.width;
        [pageScrollView setMinimumZoomScale:minimumScale];
        [pageScrollView setZoomScale:minimumScale];
        
        [mainScrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width*selected_index,0) animated:YES];
        
        [mainScrollView addSubview:pageScrollView];
        pageScrollView.tag =i+10;
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleDoubleTap:)];
        doubleTapGesture.view.tag=i;
        
        doubleTapGesture.delegate =self;
        
        [doubleTapGesture setNumberOfTapsRequired:2];
        [pageScrollView addGestureRecognizer:doubleTapGesture];
        
        if (i < [getted_images count]-1) {
            innerScrollFrame.origin.x += innerScrollFrame.size.width;
        }
        
        
    }
    
    mainScrollView.contentSize = CGSizeMake(self.shareSubview.frame.size.width, mainScrollView.bounds.size.height);
    
    [self.shareSubview addSubview:mainScrollView];

}


#pragma mark --------- likes clicked ---------

-(void)handleLIkes:(UIGestureRecognizer *)gestureRecognizer
{
    
    likesPeople *objVC =[[likesPeople alloc] initWithNibName:@"likesPeople" bundle:nil];
    
    [EventDetails setValue:@"EL" forKey:@"type"];
    
    objVC.likedDetail = [[NSMutableDictionary alloc]initWithDictionary:EventDetails];
    
    [self.navigationController pushViewController:objVC animated:YES];
 
}



#pragma mark - Zoom methods


- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    //NSLog(@"%d",gestureRecognizer.view.tag);
    UIScrollView *pageScrollView1=(UIScrollView *)[gestureRecognizer view];
    
    if(pageScrollView1.zoomScale > pageScrollView1.minimumZoomScale)
    {
        [pageScrollView1 setZoomScale:pageScrollView1.minimumZoomScale animated:YES];
    }
    else
    {
        [pageScrollView1 setZoomScale:pageScrollView1.maximumZoomScale animated:YES];
    }
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:VIEW_FOR_ZOOM_TAG];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(void)likeClicked:(UITapGestureRecognizer *)recognizer
{
    
    NSLog(@"%@",[commentArray objectAtIndex:recognizer.view.tag]);
    
    likesPeople *objVC =[[likesPeople alloc] initWithNibName:@"likesPeople" bundle:nil];
    
    objVC.gettedId = [[NSString alloc]init];
 
    objVC.gettedId = [NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:recognizer.view.tag]valueForKey:@"id"]];
    
    objVC.gettedType = [[NSString alloc]init];
    
    objVC.gettedType = @"C";
    
    
   
    [self.navigationController pushViewController:objVC animated:YES];
   
}


-(void)viewAllReplies:(UIButton *)sender
{
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:(int)sender.tag] valueForKey:@"id"]]);
    
    CommentDetail *obj = [[CommentDetail alloc]init];
    
    obj.gettedReplies = [[NSMutableArray alloc]initWithArray:[[commentArray objectAtIndex:(int)sender.tag] valueForKey:@"Reply"]];
    obj.commentID = [[NSString alloc]init];
    
    obj.commentID = [[commentArray objectAtIndex:(int)sender.tag] valueForKey:@"id"];
    
    obj.eventID = [[NSString alloc]init];
    obj.eventID = eventID;
    [obj setHidesBottomBarWhenPushed:YES];
    
    [self.navigationController pushViewController:obj animated:YES];

    
}


-(void)commentClicked:(UITapGestureRecognizer *)recognizer
{
    
     NSLog(@"%@",[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:(int)recognizer.view.tag] valueForKey:@"id"]]);
    
    CommentDetail *obj = [[CommentDetail alloc]init];
    
    obj.gettedReplies = [[NSMutableArray alloc]initWithArray:[[commentArray objectAtIndex:(int)recognizer.view.tag] valueForKey:@"Reply"]];
    obj.commentID = [[NSString alloc]init];
    
    obj.commentID = [[commentArray objectAtIndex:(int)recognizer.view.tag] valueForKey:@"id"];
    
    obj.eventID = [[NSString alloc]init];
    obj.eventID = eventID;
    [obj setHidesBottomBarWhenPushed:YES];
    
    [self.navigationController pushViewController:obj animated:YES];
  
}



- (void) handleOtherUser1: (UITapGestureRecognizer *)recognizer
{
    if(self.imgEvent.image && isEventImage)
    {
        self.imgShareBig.image =self.imgEvent.image ;
        [self.imgShareBig setHidden:YES];
        self.shareImageView.hidden=NO;
        isEventShare =YES;
        
        [self addZoomView:imageURL];
    }
}
- (void) handleOtherUser: (UITapGestureRecognizer *)recognizer
{
   /* if(createdBy.length>0)
    {
        OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
        [otherVC setUserId:[NSString stringWithFormat:@"%@",createdBy]];
        
        [self.navigationController pushViewController:otherVC animated:YES];
        
    }*/
    [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",userImageURL] Type:2];
    
}
- (void) handleOtherUser2: (UITapGestureRecognizer *)recognizer
{
    if(createdBy.length>0)
    {
        OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
        [otherVC setUserId:[NSString stringWithFormat:@"%@",createdBy]];
        
        [self.navigationController pushViewController:otherVC animated:YES];
        
    }
    
}
-(void)adjustFrame
{
    
    [self.tableViewComment layoutIfNeeded];
    CGSize tableViewSize=self.tableViewComment.contentSize;
    self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
    
    [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
    
  //  [self.scrollviewMain setContentSize:CGSizeMake(320, 1500)];

    self.imgEvent.frame =CGRectMake(self.imgEvent.frame.origin.x, self.imgEvent.frame.origin.y, self.view.bounds.size.width, 650);
    
    self.imgTrans.frame = self.imgEvent.frame;
     self.btnEdit.frame =CGRectMake(self.btnEdit.frame.origin.x, 600, self.btnEdit.frame.size.width, self.btnEdit.frame.size.height);
      self.lblEventName.frame =CGRectMake(self.lblEventName.frame.origin.x, 565, self.lblEventName.frame.size.width, self.lblEventName.frame.size.height);
    
     self.lblEventDate.frame =CGRectMake(self.lblEventDate.frame.origin.x,self.lblEventName.frame.origin.y+self.lblEventName.frame.size.height, self.lblEventDate.frame.size.width, self.lblEventDate.frame.size.height);
    
    self.lblEventLocation.frame =CGRectMake(self.lblEventDate.frame.origin.x,self.lblEventDate.frame.origin.y+self.lblEventDate.frame.size.height, self.lblEventLocation.frame.size.width, self.lblEventLocation.frame.size.height);
    
    self.lbldesc.frame =CGRectMake(self.lbldesc.frame.origin.x, 700, self.lbldesc.frame.size.width, self.lbldesc.frame.size.height);
    
    self.scrollviewBtn.frame =CGRectMake(self.scrollviewBtn.frame.origin.x, 700+self.lbldesc.frame.size.height, self.scrollviewBtn.frame.size.width, self.scrollviewBtn.frame.size.height);
    
     self.userView.frame =CGRectMake(self.userView.frame.origin.x, self.scrollviewBtn.frame.origin.y+self.scrollviewBtn.frame.size.height, self.userView.frame.size.width, self.userView.frame.size.height);
    
    self.commentView.frame =CGRectMake(self.commentView.frame.origin.x, self.userView.frame.origin.y+self.userView.frame.size.height, self.commentView.frame.size.width, self.commentView.frame.size.height);
    
     self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.commentView.frame.origin.y+self.commentView.frame.size.height, self.tableViewComment.frame.size.width, self.tableViewComment.frame.size.height);
    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.multipleImagePicker = [[RPMultipleImagePickerViewController alloc] init];
    self.multipleImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    self.image1.contentMode = UIViewContentModeScaleAspectFill;
    self.image1.clipsToBounds = YES;
    
    self.image2.contentMode = UIViewContentModeScaleAspectFill;
    self.image2.clipsToBounds = YES;
    
    self.image3.contentMode = UIViewContentModeScaleAspectFill;
    self.image3.clipsToBounds = YES;
    
    self.image4.contentMode = UIViewContentModeScaleAspectFill;
    self.image4.clipsToBounds = YES;
    
    self.image5.contentMode = UIViewContentModeScaleAspectFill;
    self.image5.clipsToBounds = YES;

    
    self.lbldesc.editable = NO;
    self.lbldesc.dataDetectorTypes = UIDataDetectorTypeLink;
    
    if(IS_Ipad)
    {
        [self.tableViewComment layoutIfNeeded];
        CGSize tableViewSize=self.tableViewComment.contentSize;
        self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
        
        [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
      //  [self.scrollviewMain setContentSize:CGSizeMake(320, 1500)];
    }
    else
    {
        [self.tableViewComment layoutIfNeeded];
        CGSize tableViewSize=self.tableViewComment.contentSize;
        self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
        
        [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
        //[self.scrollviewMain setContentSize:CGSizeMake(320, 1000)];

    }

    
    [self.imgEvent setFrame:CGRectMake(self.imgEvent.frame.origin.x, self.imgEvent.frame.origin.x, self.view.frame.size.width, self.imgEvent.frame.size.height)];
   /* [self.btnShare setEnabled:NO];
    [self.btnPrice setEnabled:NO];
    [self.btnLocation setEnabled:NO];
    [self.btnGuest setEnabled:NO];
    [self.btnCalendar setEnabled:NO];
    [self.btnLastDate setHidden:NO];
    [self.lblLastDate setHidden:NO];
    [self.lblLast setHidden:NO];*/
   /* if(!imgData)
    {
        [self callApi];

    }*/
    
    if(DELEGATE.isEventEdited)
    {
        //[self callApi];
        [self viewDidLoad];
    }
    
    
    [tableViewComment reloadData];
}
-(void)localize
{
   // [self.txtComment setPlaceholder:[localization localizedStringForKey:@"Comment"]];
    
    [self.btnYes setTitle:[localization localizedStringForKey:@"Yes"] forState:UIControlStateNormal];
    [self.btnMaybe setTitle:[localization localizedStringForKey:@"No"] forState:UIControlStateNormal];
    [self.btnPost setTitle:[localization localizedStringForKey:@"Post"] forState:UIControlStateNormal];
    
    //[self.lblTitle setText:[localization localizedStringForKey:@"Event Details"]];
    [self.lblPhoto setText:[localization localizedStringForKey:@"Photos"]];
    [self.lblCalendar setText:[localization localizedStringForKey:@"Date"]];
    [self.lblLocation setText:[localization localizedStringForKey:@"Location"]];
    [self.lblGuest setText:[localization localizedStringForKey:@"Guests"]];
    [self.lblShare setText:[localization localizedStringForKey:@"Share"]];
    [self.lblPrice setText:[localization localizedStringForKey:@"Price"]];
    [self.lblLast setText:[localization localizedStringForKey:@"Last Voting Date"]];
    [self.lblAttending setText:[localization localizedStringForKey:@"Are you attending?"]];
    [self.lblCreatedby setText:[localization localizedStringForKey:@"Created By:"]];
    
    self.lblCount.text =[NSString stringWithFormat:@"0 %@",[localization localizedStringForKey:@"people attending"]];
    self.lblReport.text =[NSString stringWithFormat:@"%@",[localization localizedStringForKey:@"Report"]];
    
}
-(void)donePressed
{
    [self.view endEditing:YES];
    
}
- (void)animateTextField: (UITextView*)textField up: (BOOL) up
{
    const int movementDistance = 100; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.scrollviewMain.frame = CGRectOffset(self.scrollviewMain.frame, 0, movement);
    // [UIView commitAnimations];
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    
        if (self.txtComment.textColor == [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f]) {
            self.txtComment.text = @"";
            self.txtComment.textColor = [UIColor blackColor];
        }
    
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
        if(self.txtComment.text.length == 0){
            //  self.txtDescription.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
            [self.txtComment setText:[localization localizedStringForKey:@"Comment"]];
            
            // self.txtDescription.text = [localization localizedStringForKey:@"Desciption"];
            self.txtComment.textColor=[UIColor blackColor];
            
            [self.txtComment resignFirstResponder];
            
            
            [self clickCLose:self.btnClose];
        }
    
   
    
    NSString *lastChar = [txtComment.text substringFromIndex:txtComment.text.length - 1];
    
    
    if (isBeginTagging)
    {
        NSString *searchstring = [[DELEGATE getArrayByRemovingString:@"@" fromstring:txtComment.text] lastObject];
        
        if ([lastChar isEqualToString:@"@"])
        {
            isSerchFromData = NO;
            [self.tblUsers reloadData];
            
            if(arrayToTag.count>0)
            {
                
                isBeginTagging = YES;
                strLastTag     = @"@";
                
                [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    //  self.viewShareReport.frame = self.scrollViewObj.frame;
                    
                     [self.viewTag setFrame:CGRectMake(0, 0, ScreenSize.width, self.viewTag.frame.size.height)];
                    
                } completion:nil];
            }
            
        }
        else if (searchstring == nil)
        {
            isBeginTagging = NO;
            isSerchFromData = NO;
            [self.tblUsers reloadData];
            
            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
             {
                   [self.viewTag setFrame:CGRectMake(0, -1500, ScreenSize.width, self.viewTag.frame.size.height)];
                 
             } completion:nil];
            
            return;
        }
        else
        {
            strLastTag = [@"@" stringByAppendingString:searchstring];
            
            [self filterContentForSearchText:searchstring];
            
        }
        
        return;
    }
    
    
    
    
    if ([lastChar isEqualToString:@"@"] )
    {
        if(arrayToTag.count>0)
        {
            
            isBeginTagging = YES;
            strLastTag     = @"@";
            
            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                //  self.viewShareReport.frame = self.scrollViewObj.frame;
                
                [self.viewTag setFrame:CGRectMake(0,0, ScreenSize.width, self.viewTag.frame.size.height)];
                
            } completion:nil];
        }
        
    }
    
    else
    {
        
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            //  self.viewShareReport.frame = self.scrollViewObj.frame;
            
            [self.viewTag setFrame:CGRectMake(0, -1500, ScreenSize.width, self.viewTag.frame.size.height)];
            
        } completion:nil];
    }

   
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    
    if(arrayToTag.count>0)
    {
        arrayFilteredTag = [[NSMutableArray alloc] init];
        
        for(int i=0;i<arrayToTag.count;i++)
        {
            NSRange nameRange;
            
            nameRange = [[[arrayToTag objectAtIndex:i] valueForKey:@"tag_name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            
            if (nameRange.location != NSNotFound) {
                [arrayFilteredTag addObject:[arrayToTag objectAtIndex:i]];
                
                isSerchFromData = YES;
            }
            
        }
        
        if (arrayFilteredTag.count>0)
        {
            [self.tblUsers reloadData];
        }
        else
        {
            isSerchFromData = NO;
        }
        
        
    }
    
    
}

- (IBAction)clickCLose:(id)sender
{
      [self.viewTag setFrame:CGRectMake(0, -1500, ScreenSize.width, self.viewTag.frame.size.height)];
}





- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  
      /*  if([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            if(self.txtComment.text.length == 0){
                self.txtComment.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
                [self.txtComment resignFirstResponder];
            }
            
            return NO;
        }
    
    */
    
    
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
   // [self animateTextField: textView up: NO];

    
        if([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] <=0)
        {
            self.txtComment.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
            [self.txtComment setText:[localization localizedStringForKey:@"Comment"]];
            
        }
        else
        {
            if(![textView.text isEqualToString:[localization localizedStringForKey:@"Comment"]])
            {
                self.txtComment.textColor = [UIColor blackColor];
                
            }
            
        }
    
  
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    //[self animateTextField: textView up: YES];

    if([textView.text isEqualToString:[localization localizedStringForKey:@"Comment"]])
    {
        textView.text=@"";
        [textView setTextColor:[UIColor blackColor]];
        
    }
    else
    {
        [textView setTextColor:[UIColor blackColor]];
    }
}

-(void)callApi
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc getEventDetail:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Sel:@selector(responsegetEventDetail:)];
        
       // [mc getMyEvents:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%d",start] Limit:@"10" Sel:@selector(responsegetMyEvents:)];
    }
}
-(void)adjustView:(CGFloat)height
{
    [self.scrollviewMain setContentSize:CGSizeMake(320, self.scrollviewMain.contentSize.height+height)];
 
    
    self.lbldesc.frame =CGRectMake(self.lbldesc.frame.origin.x, self.lbldesc.frame.origin.y, self.lbldesc.frame.size.width, height);
    
    self.scrollviewBtn.frame =CGRectMake(self.scrollviewBtn.frame.origin.x, self.lbldesc.frame.origin.y+self.lbldesc.frame.size.height, self.scrollviewBtn.frame.size.width, self.scrollviewBtn.frame.size.height);
    
    self.userView.frame =CGRectMake(self.userView.frame.origin.x, self.scrollviewBtn.frame.origin.y+self.scrollviewBtn.frame.size.height, self.userView.frame.size.width, self.userView.frame.size.height);
    
    self.commentView.frame =CGRectMake(self.commentView.frame.origin.x, self.userView.frame.origin.y+self.userView.frame.size.height, self.commentView.frame.size.width, self.commentView.frame.size.height);
    
    self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.commentView.frame.origin.y+self.commentView.frame.size.height, self.tableViewComment.frame.size.width, self.tableViewComment.frame.size.height);
}
-(void)responsegetEventDetail:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        if(DELEGATE.connectedToNetwork)
        {
            [mc getFriendsforAddinGroup:[USER_DEFAULTS valueForKey:@"userid"] Start:nil Limit:nil Groupid:nil Sel:@selector(responseGetFriends:)];
            
        }
     
        [self.lblzoomViewTitle setText:[[results valueForKey:@"Event"] valueForKey:@"name"]];
        
        EventDetails = [[NSMutableDictionary alloc]initWithDictionary:results];
        
      
        if([[[results valueForKey:@"Event"] valueForKey:@"is_reported"] isEqualToString:@"Y"])
        {
            isReported =YES;
        }
        
       if(DELEGATE.isEventEdited)
       {
           DELEGATE.isEventEdited =NO;
       }
        
        if([[[results valueForKey:@"Event"] valueForKey:@"is_liked"] isEqualToString:@"Y"])
        {
            isEventLiked =YES;
        }
        else
        {
            isEventLiked =NO;
        }
        
        likeCount =(int)[[[results valueForKey:@"Event"] valueForKey:@"like_count"] integerValue];
        
        if(isEventLiked)
        {
            [self.btnLikeEvent setImage:[UIImage imageNamed:@"eventLike2.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnLikeEvent setImage:[UIImage imageNamed:@"eventLike1.png"] forState:UIControlStateNormal];
            
        }
        
        self.lblLikeEvent.text =[NSString stringWithFormat:@"%d",likeCount];
        
        
        shareDict =[NSMutableDictionary dictionaryWithDictionary:[results valueForKey:@"Event"]];
        
        catId =(int)[[[results valueForKey:@"Event"] valueForKey:@"category_id"] integerValue];
        
        self.lblUserName.text =[[results valueForKey:@"Event"] valueForKey:@"creater"];
        self.lblEventName.text =[[results valueForKey:@"Event"] valueForKey:@"name"];
        self.lblEventLocation.text = [[results valueForKey:@"Event"] valueForKey:@"location"];
        self.lbldesc.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"description"]];
        self.lblCalendar.text =[self getDate1:[[results valueForKey:@"Event"] valueForKey:@"date"]];
        self.lblTime.text =[self getTime1:[[results valueForKey:@"Event"] valueForKey:@"date"]];
        
        
        [self.lblEventDate setText:[NSString stringWithFormat:@"%@, %@",[self getDate1:[[results valueForKey:@"Event"] valueForKey:@"date"]],[self getTime1:[[results valueForKey:@"Event"] valueForKey:@"date"]]]];


        
        if([[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]] length]>0)
        {
            self.lblPrice.text =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"price"]];
        }
        else
        {
            self.lblPrice.text =@"0";
        }
       
        
        createdBy =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"creater_id"]];

        if([[[results valueForKey:@"Event"] valueForKey:@"creater_thumb_image"] length]>0)
        {
            userImageURL =[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"creater_thumb_image"]];
            [self.imgUser sd_setImageWithURL:[NSURL URLWithString:[[results valueForKey:@"Event"] valueForKey:@"creater_thumb_image"]]];
        }
        if([[[results valueForKey:@"Event"] valueForKey:@"thumb_image"] length]>0)
        {
            eventThumbImageURL =[[results valueForKey:@"Event"] valueForKey:@"thumb_image"];

        }
        if([[[results valueForKey:@"Event"] valueForKey:@"image"] length]>0)
        {
            isEventImage =YES;
            imageURL =[[results valueForKey:@"Event"] valueForKey:@"image"];
            [self.imgEvent sd_setImageWithURL:[NSURL URLWithString:[[results valueForKey:@"Event"] valueForKey:@"image"]]];
        }
        
        //[localization localizedStringForKey:@"People attending"]
        attendingCount =[[[results valueForKey:@"Event"] valueForKey:@"attending_count"] intValue];
        self.lblCount.text =[NSString stringWithFormat:@"%d %@",attendingCount,[localization localizedStringForKey:@"people attending"]];
        
        if([[[results valueForKey:@"Event"] valueForKey:@"attending"] length]>0)
        {
            if([[[results valueForKey:@"Event"] valueForKey:@"attending"] isEqualToString:@"Y"])
            {
                [self.btnYes setBackgroundImage:[UIImage imageNamed:@"yesGreen.png"] forState:UIControlStateNormal];
                [self.btnMaybe setBackgroundImage:[UIImage imageNamed:@"maybeBlank.png"] forState:UIControlStateNormal];

                [self.btnYes setUserInteractionEnabled:NO];
                [self.btnMaybe setUserInteractionEnabled:YES];

                //[self.btnYes setEnabled:NO];
                //[self.btnMaybe setEnabled:YES];
            }
            else
            {
                [self.btnYes setBackgroundImage:[UIImage imageNamed:@"yesBlank.png"] forState:UIControlStateNormal];
                [self.btnMaybe setBackgroundImage:[UIImage imageNamed:@"maybeGreen.png"] forState:UIControlStateNormal];
                
                
                [self.btnYes setUserInteractionEnabled:YES];
                [self.btnMaybe setUserInteractionEnabled:NO];
            }
            
        }
        else
        {
            [self.btnYes setBackgroundImage:[UIImage imageNamed:@"yesBlank.png"] forState:UIControlStateNormal];
            [self.btnMaybe setBackgroundImage:[UIImage imageNamed:@"maybeBlank.png"] forState:UIControlStateNormal];
            
            [self.btnYes setEnabled:YES];
            [self.btnMaybe setEnabled:YES];
            [self.btnYes setUserInteractionEnabled:YES];
            [self.btnMaybe setUserInteractionEnabled:YES];
        }
        
        
        
        
        if([[[results valueForKey:@"Event"] valueForKey:@"is_creater"] isEqualToString:@"Y"])
        {
            [self.userView setUserInteractionEnabled:NO];
            [self.btnMaybe setHidden:YES];
            [self.btnYes setHidden:YES];
            self.lblAttending.hidden=YES;
            
            [self.btnReport setEnabled:NO];
            
            self.btnEdit.hidden=NO;
            isMy=YES;
        }
        
        
        if([[[results valueForKey:@"Event"] valueForKey:@"is_admin"] isEqualToString:@"Y"])
        {
            
            isAdmin=YES;
            
            [self.btnRepost setHidden:NO];
            
            self.btnEdit.hidden=NO;
            
            [self.btnEdit setEnabled:YES];
            
        }
        else{
            
            [self.btnRepost setHidden:YES];
            
            self.btnEdit.hidden=YES;
            
            [self.btnEdit setEnabled:NO];
            
        }



        
        if([[[results valueForKey:@"Event"] valueForKey:@"type"] isEqualToString:@"Private"])
        {
            if([[results valueForKey:@"Event"] valueForKey:@"date_vote"])
            {
                if([[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"date_vote"]] length]>0)
                {
                    votedDateId=[[[results valueForKey:@"Event"] valueForKey:@"date_vote"] intValue] ;
                }
            }
            if([[results valueForKey:@"Event"] valueForKey:@"loc_vote"])
            {
                if([[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"loc_vote"]] length]>0)
                {
                    votedLocId=[[[results valueForKey:@"Event"] valueForKey:@"loc_vote"] intValue] ;
                     ;
                }
            }
            eventType =2;
            isPrivate=YES;
            [self.btnShare setEnabled:YES];
            [self.btnPrice setEnabled:YES];
            [self.btnLocation setEnabled:YES];
            [self.btnGuest setEnabled:YES];
            [self.btnCalendar setEnabled:YES];
            [self.btnLastDate setHidden:NO];
            [self.lblLastDate setHidden:NO];
            [self.lblLast setHidden:NO];
            
       
            NSNumber *endVoting = [[results valueForKey:@"Event"] valueForKey:@"voting_close_date"];
            
            
            if ([endVoting.description isEqualToString:@""])
            {
                [self.btnLastDate setHidden:YES];
                [self.lblLastDate setHidden:YES];
                [self.lblLast setHidden:YES];
                
            }
            else{
                
               [self.scrollviewBtn setContentSize:CGSizeMake(1125, 50)];
              
            }
       
            
            self.lblLastDate.text =[self getDate1:[[results valueForKey:@"Event"] valueForKey:@"voting_close_date"]];
            
            
            [self.lblTitle setText:[localization localizedStringForKey:@"Private event detail"]];
            
           

        }
        else if ([[[results valueForKey:@"Event"] valueForKey:@"type"] isEqualToString:@"Public"])
        {
            eventType =1;
             isPrivate=NO;
            pEvendDate=[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"date"]];
            [locationDict setValue:[[results valueForKey:@"Event"] valueForKey:@"location"] forKey:@"Paddress"];
            [locationDict setValue:[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"latitude"]] forKey:@"Plat"];
            [locationDict setValue:[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"longitude"]] forKey:@"Plong"];
            
            pEvendname=[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"name"]];

            
            [self.btnShare setEnabled:YES];
            [self.btnGuest setEnabled:YES];
            [self.btnLocation setEnabled:YES];
            [self.btnCalendar setEnabled:YES];

            [self.btnLastDate setHidden:YES];
            [self.lblLastDate setHidden:YES];
            [self.lblLast setHidden:YES];
            
             [self.lblTitle setText:[localization localizedStringForKey:@"Public event detail"]];
     
            
        }
        else
        {
            eventType=3;
            pEvendDate=[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"date"]];
            [locationDict setValue:[[results valueForKey:@"Event"] valueForKey:@"location"] forKey:@"Paddress"];
            [locationDict setValue:[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"latitude"]] forKey:@"Plat"];
            [locationDict setValue:[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"longitude"]] forKey:@"Plong"];
            pEvendname=[NSString stringWithFormat:@"%@",[[results valueForKey:@"Event"] valueForKey:@"name"]];

            isPrivate=NO;
            
            [self.btnYes setUserInteractionEnabled:NO];
            [self.btnMaybe setUserInteractionEnabled:NO];
            
           // [self.btnYes setEnabled:NO];
           
            //[self.btnMaybe setEnabled:NO];
            [self.btnEdit setEnabled:NO];
            [self.btnLocation setEnabled:YES];
            [self.btnCalendar setEnabled:YES];

            [self.btnLastDate setHidden:YES];
            [self.lblLastDate setHidden:YES];
            [self.lblLast setHidden:YES];
            
            [self.userView setUserInteractionEnabled:NO];
            [self.btnMaybe setHidden:YES];
            [self.btnYes setHidden:YES];
            self.lblAttending.hidden=YES;
           // [self.scrollviewMain setUserInteractionEnabled:NO];
            
            
            
             [self.btnPost setEnabled:YES];
            [self.txtComment setEditable:YES];
            [self.btnShare setEnabled:YES];
            
            [self.btnReport setEnabled:NO];
            [self.btnGuest setEnabled:YES];
            [self.btnReport setEnabled:YES];


             [self.lblTitle setText:[localization localizedStringForKey:@"Event Detail"]];

        }

        
      
        
        
        if([[[results valueForKey:@"Event"] valueForKey:@"Location"] count]>0)
        {
            [locationArray removeAllObjects];
            [locationArray addObjectsFromArray:[[results valueForKey:@"Event"] valueForKey:@"Location"]];
        }
        
        if([[[results valueForKey:@"Event"] valueForKey:@"Date"] count]>0)
        {
            [dateArray removeAllObjects];
            [dateArray addObjectsFromArray:[[results valueForKey:@"Event"] valueForKey:@"Date"]];
        }
        
        if([[results valueForKey:@"Comment"] count]>0)
        {
            [commentArray removeAllObjects];
            [commentArray addObjectsFromArray:[results valueForKey:@"Comment"] ];
            [self.tableViewComment reloadData];
            if (commentArray.count>0)
            {
               // NSIndexPath *iPath = [NSIndexPath indexPathForRow:commentArray.count-1 inSection:0];
               
                //[self.tableViewComment scrollToRowAtIndexPath:iPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                
                [self.tableViewComment scrollsToTop];
            }
            
            if(commentArray.count>2)
            {
                if(IS_Ipad)
                {
                    [self.tableViewComment layoutIfNeeded];
                    CGSize tableViewSize=self.tableViewComment.contentSize;
                    self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
                    
                    [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
                    //[self.scrollviewMain setContentSize:CGSizeMake(320, 1500)];
                }
                else
                {
                    [self.tableViewComment layoutIfNeeded];
                    CGSize tableViewSize=self.tableViewComment.contentSize;
                    self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
                    
                    [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
                   // [self.scrollviewMain setContentSize:CGSizeMake(320, 1080)];
                }
            }
            else
            {
                if(IS_Ipad)
                {
                    [self.tableViewComment layoutIfNeeded];
                    CGSize tableViewSize=self.tableViewComment.contentSize;
                    self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
                    
                    [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
                   // [self.scrollviewMain setContentSize:CGSizeMake(320, 1450)];
                }
                else
                {
                    [self.tableViewComment layoutIfNeeded];
                    CGSize tableViewSize=self.tableViewComment.contentSize;
                    self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
                    
                    [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
                   // [self.scrollviewMain setContentSize:CGSizeMake(320, 950)];
                }
            }
            
           
        }
        else
        {
            if(IS_Ipad)
            {
                [self.tableViewComment layoutIfNeeded];
                CGSize tableViewSize=self.tableViewComment.contentSize;
                self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
                
                [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
               // [self.scrollviewMain setContentSize:CGSizeMake(320, 1200)];
            }
            else
            {
                [self.tableViewComment layoutIfNeeded];
                CGSize tableViewSize=self.tableViewComment.contentSize;
                self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
                
                [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
               // [self.scrollviewMain setContentSize:CGSizeMake(320, 680)];
            }
            
        }

        /*[commentArray addObjectsFromArray:[results valueForKey:@"Event"]];
        if(commentArray.count>0)
        {
            [self.tableViewComment reloadData];
            
        }*/
        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
            isLast =YES;
        }
        else
        {
            isLast =NO;
        }
        
        CGFloat height = [self getLabelHeightForText:[[results valueForKey:@"Event"] valueForKey:@"description"]];
        if(height>40)
        {
            [self adjustView:height];
        }
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
     
    }
}


-(void)responseGetFriends:(NSDictionary *)response
{
    
    NSLog(@"result is %@",response);
    
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        arrayToTag = [[NSMutableArray alloc]initWithArray:[response valueForKey:@"Friend"]];
        [_tblUsers reloadData];
        
        [self.tableViewComment reloadData];
    
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

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if(scrollView == self.scrollviewMain)
    {
        // Change 10.0 to adjust the distance from bottom
        if (maximumOffset - currentOffset <= 10.0  ) {
            // [self loadmoredata];
            
            if(!isLast)
            {
                start+=10;
                [self callComment];
                // [self callApi];
            }
            
            
        }
    }
    
   
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    if (tableView.tag == 100)
    {
        if (isSerchFromData)
        {
            return arrayFilteredTag.count;
        }
        else
        {
            return arrayToTag.count;
        }
    }
    
    
    if(commentArray.count>0)
    {
        return commentArray.count;
    }
    else return 0;
 
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 100)
    {
        
        userCell *cell = (userCell *)[self.tblUsers dequeueReusableCellWithIdentifier:@"userCell"];
        
        if (cell==nil)
        {
            NSArray *arrNib=[[NSBundle mainBundle] loadNibNamed:@"userCell" owner:self options:nil];
            cell= (userCell *)[arrNib objectAtIndex:0];
            
        }
        
        if (isSerchFromData)
        {
            
            if (![[[arrayFilteredTag objectAtIndex:indexPath.row]valueForKey:@"image"]isEqualToString:@""])
            {
                
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[arrayFilteredTag objectAtIndex:indexPath.row]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
            }
            
            [cell.lblUserName setText:[[arrayFilteredTag objectAtIndex:indexPath.row]valueForKey:@"tag_name"]];
            
            
        }
        else
        {
            
            if (![[[arrayToTag objectAtIndex:indexPath.row]valueForKey:@"image"]isEqualToString:@""])
            {
                
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[arrayToTag objectAtIndex:indexPath.row]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
            }
            
            [cell.lblUserName setText:[[arrayToTag objectAtIndex:indexPath.row]valueForKey:@"tag_name"]];
            
            
        }
        
        
        return cell;
        
    }
    else{
        
        if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]count]>0)
        {
            CommentList2Cell *cell = (CommentList2Cell *)[tableView dequeueReusableCellWithIdentifier:nil];
            
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentList2Cell" owner:self options:nil];
                cell=[nib objectAtIndex:0] ;
            }
            
            
            cell.btnViewAllReply.tag = indexPath.row;
            [cell.btnViewAllReply addTarget:self action:@selector(viewAllReplies:) forControlEvents:UIControlEventTouchUpInside];
            
           // cell.imgComment.backgroundColor = [UIColor redColor];
            
            
            cell.txtComment.tag = indexPath.row;
            
            UITapGestureRecognizer *likesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeClicked:)];
            likesRecognizer.delegate = self;
            cell.lblLike.userInteractionEnabled = YES;
            cell.lblLike.tag =indexPath.row;
            [cell.lblLike addGestureRecognizer:likesRecognizer];
            
            
            UITapGestureRecognizer *CommentRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentClicked:)];
            CommentRecognizer.delegate = self;
            cell.lblReplies.userInteractionEnabled = YES;
            cell.lblReplies.tag =indexPath.row;
            [cell.lblReplies addGestureRecognizer:CommentRecognizer];
            
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
            tapGestureRecognizer.delegate = self;
            tapGestureRecognizer.cancelsTouchesInView = YES;
            cell.imgUser.tag =indexPath.row;
            [cell.imgUser addGestureRecognizer:tapGestureRecognizer];
            
            cell.imgUser.contentMode = UIViewContentModeScaleAspectFill;
            cell.imgUser.clipsToBounds = YES;
            
            UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom2:)];
            tapGestureRecognizer2.delegate = self;
            // tapGestureRecognizer2.cancelsTouchesInView = NO;
            
            [cell.lblName setUserInteractionEnabled:YES];
            
            cell.lblName.tag =indexPath.row;
            [cell.lblName addGestureRecognizer:tapGestureRecognizer2];
            
            cell.btnReport.frame = CGRectMake(cell.btnView.frame.size.width-55, cell.btnReport.frame.origin.y, cell.btnReport.frame.size.width, cell.btnReport.frame.size.height);
            
            /*
             "is_liked" = N;
             "is_reported" = N;
             "like_count" = 1;
             */
            
            
            if([[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:indexPath.row] valueForKey:@"like_count"]]  isEqualToString:@"0"])
            {
                
                cell.lblLike.text =[NSString stringWithFormat:@"%@ %@",[[commentArray objectAtIndex:indexPath.row] valueForKey:@"like_count"],[localization localizedStringForKey:@"Like"]];
            }
            else
            {
                cell.lblLike.text =[NSString stringWithFormat:@"%@ %@",[[commentArray objectAtIndex:indexPath.row] valueForKey:@"like_count"],[localization localizedStringForKey:@"Likes"]];
            }
            
            
            
            
            
            if(IS_IPAD)
            {
                //[cell.txtComment setFont:FONT_Regular(18)];
                [cell.lblName setFont:FONT_Regular(22)];
                [cell.lblDate setFont:FONT_Regular(18)];
                
            }
            else
            {
                /* [cell.lblPrivate setFont:FONT_Regular(10)];
                 [cell.lblName setFont:FONT_Regular(15)];
                 [cell.lblDate setFont:FONT_Regular(12)];*/
                
                
            }
            
            
            cell.delegate=self;
            cell.btnShare.tag =indexPath.row;
            cell.btnReport.tag =indexPath.row;
            cell.btnLike.tag =indexPath.row;
            cell.btnDelete.tag =indexPath.row;
            cell.btnComment.tag = indexPath.row;
            
            
            cell.imgUser.layer.masksToBounds = YES;
            cell.imgUser.layer.cornerRadius = 25.0;
            
            
            cell.lblDate.text =[self getDate1:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"time"]];
            cell.lblName.text =[[commentArray objectAtIndex:indexPath.row] valueForKey:@"username"];
            
//            CGFloat height=[self getLabelHeightForIndex:indexPath.row];
//            cell.lblComment.frame=CGRectMake(cell.lblComment.frame.origin.x, cell.lblComment.frame.origin.y, cell.lblComment.frame.size.width, height);
            
            CGFloat height=[self getTextHeight:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"comment"]];
            
            
            cell.txtComment.frame=CGRectMake(cell.txtComment.frame.origin.x, cell.txtComment.frame.origin.y,cell.frame.size.width-30,height);
            

            
            //[cell bringSubviewToFront:cell.txtComment];
            
            
            cell.imgComment.frame=CGRectMake(10, cell.txtComment.frame.origin.y+height,self.view.bounds.size.width-20, cell.imgComment.frame.size.height);
            
            //NSLog(@"%@",NSStringFromCGRect(cell.imgComment.frame));
            cell.imgComment.contentMode = UIViewContentModeScaleAspectFill;
            cell.imgComment.clipsToBounds = YES;
            
            //cell.imgComment.backgroundColor = [UIColor yellowColor];
            
            
            //here
            cell.txtComment.text =[self DecodeCommentString:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"comment"] usersTagged:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Tags"]];
            
            
            [cell.txtComment setPreferredHeight];
            
            cell.txtComment.delegate = self;

            
            [cell.lblReplies setText:[NSString stringWithFormat:@"%lu Replies",(unsigned long)[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Reply"] count]]];
            
            if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"userimage_thumb"] length]>0)
            {
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"userimage_thumb"]]];
            }
            
            
            [cell.imgBorder setBackgroundColor:[UIColor whiteColor]];
            
            cell.imgBorder.frame =CGRectMake(10, 15, self.view.bounds.size.width-20, cell.imgBorder.frame.size.height+height);
            [cell.imgBorder.layer setBorderColor:[UIColor lightTextColor].CGColor];
            [cell.imgBorder.layer setBorderWidth:1.0f];
            
            cell.btnView.frame=CGRectMake(cell.btnView.frame.origin.x, cell.imgBorder.frame.origin.y+cell.imgBorder.frame.size.height-44, cell.btnView.frame.size.width,cell.btnView.frame.size.height);
            
            if ([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]count]==1)
            {
                
                cell.imgComment.tag = indexPath.row;
                
                cell.imgComment.hidden = NO;
                
                
                
                [cell.imgComment sd_setImageWithURL:[NSURL URLWithString:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (image)
                    {
                        
                        // UIImage * image1=[self drawImage:image inRect:cell.imgComment.bounds];
                        UIImage * image1=[self drawImage:image inRect: CGRectMake(0, 0, self.view.bounds.size.width, cell.imgComment.bounds.size.height)];
                        
                        cell.imgComment.image =image1;
                        
                        
                        
                        [cell.imgComment setupImageViewerWithDatasource:self initialIndex:0 onOpen:^{
                            
                            
                            NSLog(@"onOpen");
                            
                        } onClose:^{
                            
                            
                        }];
                        
                    }
                }];
                
            }
            else
            {
                
                
                
                cell.imgComment.hidden = NO;
                
                NSMutableArray *imgAry = [[NSMutableArray alloc]initWithArray:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]];
                
                
                TwoImages *ViewTwoImages = [[[NSBundle mainBundle]
                                             loadNibNamed:@"TwoImages"
                                             owner:self options:nil]
                                            firstObject];
                ThreeImages *ViewThreeImages = [[[NSBundle mainBundle]
                                                 loadNibNamed:@"ThreeImages"
                                                 owner:self options:nil]
                                                firstObject];
                FourImages *ViewFourImages = [[[NSBundle mainBundle]
                                               loadNibNamed:@"FourImages"
                                               owner:self options:nil]
                                              firstObject];
                FiveImages *ViewFiveImages = [[[NSBundle mainBundle]
                                               loadNibNamed:@"FiveImages"
                                               owner:self options:nil]
                                              firstObject];
                
                
                
                
                
                switch (imgAry.count)
                {
                        
                    case 2:
                        
                        
                        ViewThreeImages = nil;
                        ViewFourImages = nil;
                        ViewFiveImages = nil;
                        
                       
                        
                        ViewTwoImages.translatesAutoresizingMaskIntoConstraints = YES;
                        
                        
                       ViewTwoImages.frame = CGRectMake(0,0,cell.imgComment.frame.size.width,cell.imgComment.frame.size.height);
                        
                      //  NSLog(@"%@",NSStringFromCGRect(ViewTwoImages.frame));
                        
                        [ViewTwoImages.view2image1 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:0]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        
                        [ViewTwoImages.view2image2 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:1]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        
                        ViewTwoImages.view2image1.contentMode = UIViewContentModeScaleAspectFill;
                        ViewTwoImages.view2image2.contentMode = UIViewContentModeScaleAspectFill;
                        ViewTwoImages.view2image1.clipsToBounds = YES;
                        ViewTwoImages.view2image2.clipsToBounds = YES;
                        
                        ViewTwoImages.view2image1.layer.borderWidth = 1.0;
                        ViewTwoImages.view2image1.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        ViewTwoImages.view2image2.layer.borderWidth = 1.0;
                        ViewTwoImages.view2image2.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        
                        ViewTwoImages.view2image1.tag = indexPath.row;
                        ViewTwoImages.view2image2.tag = indexPath.row;
                        
                        
                        
                        [ViewTwoImages.view2image1 setupImageViewerWithDatasource:self  initialIndex:0 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        [ViewTwoImages.view2image2 setupImageViewerWithDatasource:self initialIndex:1 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        [cell.imgComment setUserInteractionEnabled:YES];
                        [cell.imgComment addSubview:ViewTwoImages];
                        
                        
                        break;
                        
                    case 3:
                        
                        ViewTwoImages = nil;
                        ViewFourImages = nil;
                        ViewFiveImages = nil;
                        
                        
                        
                        ViewThreeImages.translatesAutoresizingMaskIntoConstraints = YES;
                        
                        
                       ViewThreeImages.frame = CGRectMake(0,0,cell.imgComment.frame.size.width,cell.imgComment.frame.size.height);
                        
                        
                        [ViewThreeImages.view3image1 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:0]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        
                        [ViewThreeImages.view3image2 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:1]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        [ViewThreeImages.view3image3 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:2]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        
                        ViewThreeImages.view3image1.contentMode = UIViewContentModeScaleAspectFill;
                        ViewThreeImages.view3image2.contentMode = UIViewContentModeScaleAspectFill;
                        ViewThreeImages.view3image3.contentMode = UIViewContentModeScaleAspectFill;
                        
                        ViewThreeImages.view3image1.clipsToBounds = YES;
                        ViewThreeImages.view3image2.clipsToBounds = YES;
                        ViewThreeImages.view3image3.clipsToBounds = YES;
                        
                        
                        ViewThreeImages.view3image1.layer.borderWidth = 1.0;
                        ViewThreeImages.view3image1.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        ViewThreeImages.view3image2.layer.borderWidth = 1.0;
                        ViewThreeImages.view3image2.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        ViewThreeImages.view3image3.layer.borderWidth = 1.0;
                        ViewThreeImages.view3image3.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        
                        ViewThreeImages.view3image1.tag = indexPath.row;
                        ViewThreeImages.view3image2.tag = indexPath.row;
                        ViewThreeImages.view3image3.tag = indexPath.row;
                        
                        
                        
                        [ViewThreeImages.view3image1 setupImageViewerWithDatasource:self initialIndex:0 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        [ViewThreeImages.view3image2 setupImageViewerWithDatasource:self initialIndex:1 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        [ViewThreeImages.view3image3 setupImageViewerWithDatasource:self initialIndex:2 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        //
                        
                        [cell.imgComment setUserInteractionEnabled:YES];
                        [cell.imgComment addSubview:ViewThreeImages];
                        
                        //[cell.contentView addSubview:ViewThreeImages];
                        
                        
                        
                        break;
                        
                    case 4:
                        
                        ViewTwoImages = nil;
                        ViewThreeImages = nil;
                        ViewFiveImages = nil;
                        
                        
                        ViewFourImages.translatesAutoresizingMaskIntoConstraints = YES;
                        
                        
                       ViewFourImages.frame = CGRectMake(0,0,cell.imgComment.frame.size.width,cell.imgComment.frame.size.height);
                        
                        [ViewFourImages.view4image1 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:0]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        
                        [ViewFourImages.view4image2 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:1]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        [ViewFourImages.view4image3 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:2]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        
                        [ViewFourImages.view4image4 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:3]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        
                        ViewFourImages.view4image1.contentMode = UIViewContentModeScaleAspectFill;
                        ViewFourImages.view4image2.contentMode = UIViewContentModeScaleAspectFill;
                        ViewFourImages.view4image3.contentMode = UIViewContentModeScaleAspectFill;
                        ViewFourImages.view4image4.contentMode = UIViewContentModeScaleAspectFill;
                        
                        
                        
                        ViewFourImages.view4image1.layer.borderWidth = 1.0;
                        ViewFourImages.view4image1.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        ViewFourImages.view4image2.layer.borderWidth = 1.0;
                        ViewFourImages.view4image2.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        ViewFourImages.view4image3.layer.borderWidth = 1.0;
                        ViewFourImages.view4image3.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        ViewFourImages.view4image4.layer.borderWidth = 1.0;
                        ViewFourImages.view4image4.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        
                        
                        
                        ViewFourImages.view4image1.clipsToBounds = YES;
                        ViewFourImages.view4image2.clipsToBounds = YES;
                        ViewFourImages.view4image3.clipsToBounds = YES;
                        ViewFourImages.view4image4.clipsToBounds = YES;
                        
                        
                        ViewFourImages.view4image1.tag = indexPath.row;
                        ViewFourImages.view4image2.tag = indexPath.row;
                        ViewFourImages.view4image3.tag = indexPath.row;
                        ViewFourImages.view4image4.tag = indexPath.row;
                        
                        
                        
                        [ViewFourImages.view4image1 setupImageViewerWithDatasource:self initialIndex:0 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        [ViewFourImages.view4image2 setupImageViewerWithDatasource:self initialIndex:1 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        [ViewFourImages.view4image3 setupImageViewerWithDatasource:self initialIndex:2 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        
                        [ViewFourImages.view4image4 setupImageViewerWithDatasource:self initialIndex:3 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        
                        
                        
                        [cell.imgComment setUserInteractionEnabled:YES];
                        [cell.imgComment addSubview:ViewFourImages];
                       // [cell.contentView addSubview:ViewFourImages];
                        
                        
                        break;
                        
                        
                    case 5:
                        
                        ViewTwoImages = nil;
                        ViewThreeImages = nil;
                        ViewFourImages = nil;
                        
                        
                        ViewFiveImages.translatesAutoresizingMaskIntoConstraints = YES;
                        
                        
                        ViewFiveImages.frame = CGRectMake(0,0,cell.imgComment.frame.size.width,cell.imgComment.frame.size.height);
                        
                        [ViewFiveImages.view5image1 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:0]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        
                        [ViewFiveImages.view5image2 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:1]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        [ViewFiveImages.view5image3 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:2]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        
                        [ViewFiveImages.view5image4 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:3]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        [ViewFiveImages.view5image5 sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]objectAtIndex:4]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                        
                        
                        
                        ViewFiveImages.view5image1.contentMode = UIViewContentModeScaleAspectFill;
                        ViewFiveImages.view5image2.contentMode = UIViewContentModeScaleAspectFill;
                        ViewFiveImages.view5image3.contentMode = UIViewContentModeScaleAspectFill;
                        ViewFiveImages.view5image4.contentMode = UIViewContentModeScaleAspectFill;
                        ViewFiveImages.view5image5.contentMode = UIViewContentModeScaleAspectFill;
                        
                        
                        
                        
                        ViewFiveImages.view5image1.layer.borderWidth = 1.0;
                        ViewFiveImages.view5image1.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        ViewFiveImages.view5image2.layer.borderWidth = 1.0;
                        ViewFiveImages.view5image2.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        ViewFiveImages.view5image3.layer.borderWidth = 1.0;
                        ViewFiveImages.view5image3.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        ViewFiveImages.view5image4.layer.borderWidth = 1.0;
                        ViewFiveImages.view5image4.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        ViewFiveImages.view5image5.layer.borderWidth = 1.0;
                        ViewFiveImages.view5image5.layer.borderColor = [UIColor whiteColor].CGColor;
                        
                        
                        
                        ViewFiveImages.view5image1.clipsToBounds = YES;
                        ViewFiveImages.view5image2.clipsToBounds = YES;
                        ViewFiveImages.view5image3.clipsToBounds = YES;
                        ViewFiveImages.view5image4.clipsToBounds = YES;
                        ViewFiveImages.view5image5.clipsToBounds = YES;
                        
                        
                        ViewFiveImages.view5image1.tag = indexPath.row;
                        ViewFiveImages.view5image2.tag = indexPath.row;
                        ViewFiveImages.view5image3.tag = indexPath.row;
                        ViewFiveImages.view5image4.tag = indexPath.row;
                        ViewFiveImages.view5image5.tag = indexPath.row;
                        
                        
                        
                        
                        [ViewFiveImages.view5image1 setupImageViewerWithDatasource:self initialIndex:0 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        [ViewFiveImages.view5image2 setupImageViewerWithDatasource:self initialIndex:1 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        [ViewFiveImages.view5image3 setupImageViewerWithDatasource:self initialIndex:2 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        
                        [ViewFiveImages.view5image4 setupImageViewerWithDatasource:self initialIndex:3 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        
                        [ViewFiveImages.view5image5 setupImageViewerWithDatasource:self initialIndex:4 onOpen:^{
                            
                            
                        } onClose:^{
                            
                            
                        }];
                        
                        
                        [cell.imgComment setUserInteractionEnabled:YES];
                        [cell.imgComment addSubview:ViewFiveImages];
                        
                        //[cell.contentView addSubview:ViewFiveImages];
                        
                        
                        
                        break;
                        
                        
                    default:
                        break;
                }
                
                
                
            }
            
            
            /*comment = fhdjksfhdjkshgjkdfhsgjkfhgjkdfhsgjkdfhsgjkhdfjkghfgdf;
             id = 49;
             image = "http://192.168.1.100/apps/amhappy/web/img/uploads/comments/1441979256myimage.jpeg";
             "is_delete" = Y;
             "is_liked" = N;
             "is_reported" = N;
             time = 1441979256;
             userid = 18;
             userimage = "";
             "userimage_thumb" = "";
             username = aklesh;
             */
            
            
            
            if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"is_delete"] isEqualToString:@"Y"])
            {
                // [cell.btnDelete setHidden:NO];
                [cell.btnDelete setEnabled:YES];
            }
            else
            {
                // [cell.btnDelete setHidden:YES];
                [cell.btnDelete setEnabled:NO];
                
            }
            
            if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"is_liked"] isEqualToString:@"Y"])
            {
                [cell.btnLike setImage:[UIImage imageNamed:@"like2.png"] forState:UIControlStateNormal];
            }
            else
            {
                [cell.btnLike setImage:[UIImage imageNamed:@"like1.png"] forState:UIControlStateNormal];
            }
            
            if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"is_reported"] isEqualToString:@"Y"])
            {
                [cell.btnReport setImage:[UIImage imageNamed:@"flag2.png"] forState:UIControlStateNormal];
                [cell.btnReport setEnabled:NO];
            }
            else
            {
                [cell.btnReport setImage:[UIImage imageNamed:@"flag1.png"] forState:UIControlStateNormal];
                [cell.btnReport setEnabled:YES];
                
            }
            
          
            
            [self addUpperBorder:cell.btnView];

            
            [self addbottomBorder:cell.btnView];
            
          
            
            //******** set replies View
            
            cell.viewReply.frame = CGRectMake(cell.viewReply.frame.origin.x,cell.btnView.frame.origin.y+cell.btnView.frame.size.height,cell.viewReply.frame.size.width, cell.viewReply.frame.size.height);
            
            //cell.viewReply.frame = CGRectMake(cell.btnView.frame.origin.x, cell.btnView.frame.origin.y+cell.btnView.frame.size.height,cell.btnView.frame.size.width,200);
            
            if ([[[[commentArray objectAtIndex:indexPath.row]valueForKey:@"top_replys_count"] description] intValue] > 0)
            {
                
                cell.btnViewAllReply.frame = CGRectMake(0, 0, cell.viewReply.frame.size.width,viewAllcommentsHeight);
                
                [cell.btnViewAllReply setTitle:[NSString stringWithFormat:@"View previous %@ replies",[[[commentArray objectAtIndex:indexPath.row]valueForKey:@"top_replys_count"] description]] forState:UIControlStateNormal];
                
                cell.btnViewAllReply.titleLabel.font = FONT_Bold(13);
                
                [cell.btnViewAllReply.titleLabel setTextColor:[UIColor blackColor]];
                
                cell.btnViewAllReply.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                
                cell.btnViewAllReply.layer.sublayerTransform = CATransform3DMakeTranslation(7, 0, 0);
                
                cell.viewReply1.frame = CGRectMake(0,viewAllcommentsHeight, cell.viewReply.frame.size.width, replyCellHeight);
                cell.viewReply2.frame = CGRectMake(0,viewAllcommentsHeight+replyCellHeight, cell.viewReply.frame.size.width, replyCellHeight);
                
                cell.viewReply3.frame = CGRectMake(0,viewAllcommentsHeight+replyCellHeight*2, cell.viewReply.frame.size.width, replyCellHeight);
                
                
                [cell.btnViewAllReply setTitle:[NSString stringWithFormat:@"View previous %@ replies",[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"top_replys_count"] description]] forState:UIControlStateNormal];
                
                
                for (int i=0; i< [[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"] count]; i++)
                {
                    
                    
                    
                    switch (i)
                    {
                        case 0:
                            
                            [self setReply1WithImageCell:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        case 1:
                            
                            [self setReply2WithImageCell:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        case 2:
                            
                            [self setReply3WithImageCell:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        default:
                            break;
                    }
                    
                }
                
            }
            
            else
            {
                
                [cell.btnViewAllReply setTitle:@"" forState:UIControlStateNormal];
                
                cell.btnViewAllReply.frame = CGRectMake(0, 0, cell.viewReply.frame.size.width, 0);
                
                cell.viewReply1.frame = CGRectMake(0,0, cell.viewReply.frame.size.width,replyCellHeight);
                cell.viewReply2.frame = CGRectMake(0,replyCellHeight, cell.viewReply.frame.size.width, replyCellHeight);
                
                cell.viewReply3.frame = CGRectMake(0,replyCellHeight*2, cell.viewReply.frame.size.width, replyCellHeight);
                
                
                for (int i=0; i< [[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"] count]; i++)
                {
                    
                    
                    
                    switch (i)
                    {
                        case 0:
                            
                            [self setReply1WithImageCell:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        case 1:
                            
                            [self setReply2WithImageCell:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        case 2:
                            
                            [self setReply3WithImageCell:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        default:
                            break;
                    }
                    
                }
                
                
                
            }

            
            
            //[cell.btnShare setBackgroundColor:[UIColor yellowColor]];
            
            // [cell.btnView.layer setBorderColor:[UIColor colorWithRed:232.0/255.0 green:235.0/255.0 blue:240.0/255.0 alpha:1.0].CGColor];
            //[cell.btnView.layer setBorderWidth:1.0f];
            
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
//            for (int i=0; i<[[[_arrayRecipe objectAtIndex:indexPath.row] valueForKey:@"steps"] count]; i++)
//            {
//                UIView *viewIngri = [[UIView alloc] initWithFrame:CGRectMake(0, 50*(i+1), recipeCell.cellViewSteps.frame.size.width, 50)];
//                
//                
//                //                        if ((i % 2) == 0)
//                //                        {
//                // number is even
//                
//                viewIngri.backgroundColor = [UIColor whiteColor];
//                
//                
//                //                        } else {
//                //                            // number is odd
//                //                            viewIngri.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
//                //
//                //                        }
//                
//                //viewIngri.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
//                
//                //                        UIImageView *viewSaperator = [[UIImageView alloc] initWithFrame:CGRectMake(50, 48, viewIngri.frame.size.width-100, 2)];
//                //                        [viewSaperator setImage:[UIImage imageNamed:@"list_saperator_horizontal.png"]];
//                
//                //                        UIButton *btn_Steps = [[UIButton alloc] initWithFrame:CGRectMake(55, 13, 24, 24)];
//                //                        [btn_Steps setBackgroundImage:[UIImage imageNamed:@"list_steps_circle"] forState:UIControlStateNormal];
//                //                        btn_Steps.titleLabel.font = FONT_Regular(13);
//                //                        [btn_Steps setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                //                        [btn_Steps setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
//                
//                
//                UILabel *lblIngri = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, viewIngri.frame.size.width-100, 40)];
//                [lblIngri setNumberOfLines:0];
//                [lblIngri setTextColor:[UIColor colorWithRed:143/255.0 green:143/255.0 blue:143/255.0 alpha:1]];
//                lblIngri.font = FONT_Regular(14);
//                
//                
//                NSString *ingriText = [NSString stringWithFormat:@"%@",[[[arraySteps objectAtIndex:indexPath.row]objectAtIndex:i] valueForKey:@"step"]];
//                [lblIngri setTextAlignment:NSTextAlignmentCenter];
//                
//                lblIngri.text = ingriText;
//                
//                // [viewIngri addSubview:btn_Steps];
//                [viewIngri addSubview:lblIngri];
//                // [viewIngri addSubview:viewSaperator];
//                
//                [recipeCell.cellViewSteps addSubview:viewIngri];
//                
//                
//            }
            
//            cell.contentView.layer.cornerRadius = 2.0;
//            cell.contentView.layer.borderWidth = 1.0;
//            cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
//            cell.contentView.layer.masksToBounds = YES;
//            
//            cell.layer.shadowColor = [UIColor grayColor].CGColor;
//            cell.layer.shadowOffset = CGSizeMake(0, 2.0);
//            cell.layer.shadowRadius = 2.0;
//            cell.layer.shadowOpacity = 1.0;
//            cell.layer.masksToBounds = NO;
            
            return cell;
        }
        else
        {
            CommentList1Cell *cell = (CommentList1Cell *)[tableView dequeueReusableCellWithIdentifier:nil];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentList1Cell" owner:self options:nil];
                cell=[nib objectAtIndex:0] ;
                
            }
            
        
           
            
            cell.btnViewAllReply.tag = indexPath.row;
            
            [cell.btnViewAllReply addTarget:self action:@selector(viewAllReplies:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnViewAllReply.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            cell.btnViewAllReply.contentEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
            
        
            
 
            
            UITapGestureRecognizer *likesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeClicked:)];
            likesRecognizer.delegate = self;
            cell.lblLike.userInteractionEnabled = YES;
            cell.lblLike.tag =indexPath.row;
            [cell.lblLike addGestureRecognizer:likesRecognizer];
            
            
            
            UITapGestureRecognizer *CommentRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentClicked:)];
            CommentRecognizer.delegate = self;
            cell.lblReplies.userInteractionEnabled = YES;
            cell.lblReplies.tag =indexPath.row;
            [cell.lblReplies addGestureRecognizer:CommentRecognizer];
            
            
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
            tapGestureRecognizer.delegate = self;
            tapGestureRecognizer.cancelsTouchesInView = NO;
            cell.imgUser.tag =indexPath.row;
            [cell.imgUser addGestureRecognizer:tapGestureRecognizer];
            
            cell.imgUser.contentMode = UIViewContentModeScaleAspectFill;
            cell.imgUser.clipsToBounds = YES;
            
            UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom2:)];
            tapGestureRecognizer2.delegate = self;
            [cell.lblName setUserInteractionEnabled:YES];
            cell.lblName.tag =indexPath.row;
            [cell.lblName addGestureRecognizer:tapGestureRecognizer2];
            
            cell.delegate=self;
            cell.btnshare.tag =indexPath.row;
            cell.btnReport.tag =indexPath.row;
            cell.btnLike.tag =indexPath.row;
            cell.btnDelete.tag =indexPath.row;
            cell.btnComment.tag =indexPath.row;
            cell.txtComment.tag = indexPath.row;
       
            
            cell.btnReport.frame = CGRectMake(cell.btnshare.frame.origin.x-(cell.btnReport.frame.size.width+5), cell.btnReport.frame.origin.y, cell.btnReport.frame.size.width, cell.btnReport.frame.size.height);
            
            
            if([[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:indexPath.row] valueForKey:@"like_count"]]  isEqualToString:@"0"])
            {
                
                cell.lblLike.text =[NSString stringWithFormat:@"%@ %@",[[commentArray objectAtIndex:indexPath.row] valueForKey:@"like_count"],[localization localizedStringForKey:@"Like"]];
            }
            else
            {
                cell.lblLike.text =[NSString stringWithFormat:@"%@ %@",[[commentArray objectAtIndex:indexPath.row] valueForKey:@"like_count"],[localization localizedStringForKey:@"Likes"]];
            }
            
            /*comment = fhdjksfhdjkshgjkdfhsgjkfhgjkdfhsgjkdfhsgjkhdfjkghfgdf;
             id = 49;
             image = "http://192.168.1.100/apps/amhappy/web/img/uploads/comments/1441979256myimage.jpeg";
             "is_delete" = Y;
             "is_liked" = N;
             "is_reported" = N;
             time = 1441979256;
             userid = 18;
             userimage = "";
             "userimage_thumb" = "";
             username = aklesh;
             */
            
            [cell.lblReplies setText:[NSString stringWithFormat:@"%lu Replies",(unsigned long)[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Reply"] count]]];
            
            if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"is_delete"] isEqualToString:@"Y"])
            {
                // [cell.btnDelete setHidden:NO];
                [cell.btnDelete setEnabled:YES];
            }
            else
            {
                // [cell.btnDelete setHidden:YES];
                [cell.btnDelete setEnabled:NO];
                
            }
            
            if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"is_liked"] isEqualToString:@"Y"])
            {
                [cell.btnLike setImage:[UIImage imageNamed:@"like2.png"] forState:UIControlStateNormal];
            }
            else
            {
                [cell.btnLike setImage:[UIImage imageNamed:@"like1.png"] forState:UIControlStateNormal];
            }
            
            if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"is_reported"] isEqualToString:@"Y"])
            {
                [cell.btnReport setImage:[UIImage imageNamed:@"flag2.png"] forState:UIControlStateNormal];
                [cell.btnReport setEnabled:NO];
            }
            else
            {
                [cell.btnReport setImage:[UIImage imageNamed:@"flag1.png"] forState:UIControlStateNormal];
                [cell.btnReport setEnabled:YES];
                
            }
            
            
            
            
            if(IS_IPAD)
            {
                //[cell.txtComment setFont:FONT_Regular(14)];
                [cell.lblName setFont:FONT_Regular(22)];
                [cell.lblDate setFont:FONT_Regular(18)];
                
            }
            else
            {
                /* [cell.lblPrivate setFont:FONT_Regular(10)];
                 [cell.lblName setFont:FONT_Regular(15)];
                 [cell.lblDate setFont:FONT_Regular(12)];*/
                
                
            }
            
            cell.imgUser.layer.masksToBounds = YES;
            cell.imgUser.layer.cornerRadius = 25.0;
            
            
            cell.lblDate.text =[self getDate1:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"time"]];
            cell.lblName.text =[[commentArray objectAtIndex:indexPath.row] valueForKey:@"username"];
            
            
            
            //CGFloat height=[self sizeOfText:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"comment"] widthOfTextView:self.view.bounds.size.width-30 withFont:cell.txtComment.font];
            
            //CGFloat height=[self getLabelHeightForIndex:indexPath.row];
            
            
       //  CGSize cmtSize = [self getSizeWithLineBreakMode:NSLineBreakByWordWrapping text:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"comment"] font:cell.txtComment.font.fontName fontSize:16.0f maximumSize:CGSizeMake(cell.txtComment.frame.size.width, 99999)];
            
            
            CGFloat height=[self getTextHeight:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"comment"]];
            
            
            cell.txtComment.frame=CGRectMake(cell.txtComment.frame.origin.x, cell.txtComment.frame.origin.y,cell.frame.size.width-30,height);
            
        
            
            //        cell.lblComment.editable = NO;
            //        cell.lblComment.dataDetectorTypes = UIDataDetectorTypeLink;
            
            [cell.imgBorder setBackgroundColor:[UIColor whiteColor]];
            
            [cell.imgBorder.layer setBorderColor:[UIColor lightTextColor].CGColor];
            [cell.imgBorder.layer setBorderWidth:1.0f];
            
            cell.imgBorder.frame =CGRectMake(10, 10, self.view.bounds.size.width-20, cell.imgBorder.frame.size.height+height);
        
            cell.btnView.frame=CGRectMake(cell.btnView.frame.origin.x, cell.txtComment.frame.origin.y+cell.txtComment.frame.size.height+5, cell.btnView.frame.size.width,cell.btnView.frame.size.height);
            
            [self addUpperBorder:cell.btnView];
            
            [self addbottomBorder:cell.btnView];
            
            //        [cell.btnView.layer setBorderColor:[UIColor colorWithRed:232.0/255.0 green:235.0/255.0 blue:240.0/255.0 alpha:1.0].CGColor];
            //        [cell.btnView.layer setBorderWidth:1.0f];
            
           
            
            UserToHighlight = [[NSMutableArray alloc]init];
            
            cell.txtComment.text = [self DecodeCommentString:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"comment"] usersTagged:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Tags"]];
  
            [cell.txtComment setPreferredHeight];
            
            cell.txtComment.delegate = self;
   
           // [self LinkTextView:cell.txtComment links:UserToHighlight];
          
            //cell.txtComment.attributedText = [self getLinkedString:[self DecodeCommentString:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"comment"] usersTagged:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Tags"]] tagArray:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Tags"]];
        
            
            NSLog(@"%@",[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Tags"]);
           
            
            if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"userimage_thumb"] length]>0)
            {
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"userimage_thumb"]]];
            }
            
            
            //******** set replies View
            
             cell.viewReply.frame = CGRectMake(cell.viewReply.frame.origin.x,cell.btnView.frame.origin.y+cell.btnView.frame.size.height,cell.viewReply.frame.size.width, cell.viewReply.frame.size.height);
            
            //cell.viewReply.frame = CGRectMake(cell.btnView.frame.origin.x, cell.btnView.frame.origin.y+cell.btnView.frame.size.height,cell.btnView.frame.size.width,200);
            
            if ([[[[commentArray objectAtIndex:indexPath.row]valueForKey:@"top_replys_count"] description] intValue] > 0)
            {
                
                cell.btnViewAllReply.frame = CGRectMake(0, 0, cell.viewReply.frame.size.width, viewAllcommentsHeight);
                
                [cell.btnViewAllReply setTitle:[NSString stringWithFormat:@"View previous %@ replies",[[[commentArray objectAtIndex:indexPath.row]valueForKey:@"top_replys_count"] description]] forState:UIControlStateNormal];
              
                cell.btnViewAllReply.titleLabel.font = FONT_Bold(13);
                
                [cell.btnViewAllReply.titleLabel setTextColor:[UIColor blackColor]];
                
                 cell.btnViewAllReply.layer.sublayerTransform = CATransform3DMakeTranslation(7, 0, 0);
                
                cell.viewReply1.frame = CGRectMake(0,viewAllcommentsHeight, cell.viewReply.frame.size.width, replyCellHeight);
                cell.viewReply2.frame = CGRectMake(0,viewAllcommentsHeight+replyCellHeight, cell.viewReply.frame.size.width, replyCellHeight);
                
                cell.viewReply3.frame = CGRectMake(0,viewAllcommentsHeight+replyCellHeight*2, cell.viewReply.frame.size.width, replyCellHeight);
                
                
                [cell.btnViewAllReply setTitle:[NSString stringWithFormat:@"View previous %@ replies",[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"top_replys_count"] description]] forState:UIControlStateNormal];
                
                
                
                
                for (int i=0; i< [[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"] count]; i++)
                {
                    
                    
                    
                    switch (i)
                    {
                        case 0:
                            
                            [self setReply1:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        case 1:
                            
                            [self setReply2:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        case 2:
                            
                            [self setReply3:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        default:
                            break;
                    }
                    
                }
                
            }
            
            else
            {
                
                   [cell.btnViewAllReply setTitle:@"" forState:UIControlStateNormal];
                
                cell.btnViewAllReply.frame = CGRectMake(0, 0, cell.viewReply.frame.size.width, 0);
                
                cell.viewReply1.frame = CGRectMake(0,0, cell.viewReply.frame.size.width,replyCellHeight);
                cell.viewReply2.frame = CGRectMake(0,replyCellHeight, cell.viewReply.frame.size.width, replyCellHeight);
                
                cell.viewReply3.frame = CGRectMake(0,replyCellHeight*2, cell.viewReply.frame.size.width, replyCellHeight);
                
                
                for (int i=0; i< [[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"] count]; i++)
                {
                    
                    
                    
                    switch (i)
                    {
                        case 0:
                            
                            [self setReply1:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        case 1:
                            
                            [self setReply2:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        case 2:
                            
                            [self setReply3:cell indexPath:indexPath i:i];
                            
                            break;
                            
                        default:
                            break;
                    }
                    
                }
                
                
                
            }

            
            
            
            //[cell.txtComment setFont:FONT_Regular(14)];
            
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundColor:[UIColor clearColor]];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
//            cell.contentView.layer.cornerRadius = 2.0;
//            cell.contentView.layer.borderWidth = 1.0;
//            cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
//            cell.contentView.layer.masksToBounds = YES;
//            
//            cell.layer.shadowColor = [UIColor grayColor].CGColor;
//            cell.layer.shadowOffset = CGSizeMake(0, 2.0);
//            cell.layer.shadowRadius = 2.0;
//            cell.layer.shadowOpacity = 1.0;
//            cell.layer.masksToBounds = NO;
            
            return cell;
        }

        
    }
 
}




-(void)setReply3WithImageCell:(CommentList2Cell *)cell indexPath:(NSIndexPath *)indexPath i:(int)i
{
    
    cell.btnUser3Image.frame = CGRectMake(10, 5, 30, 30);
    cell.btnUser3Image.contentMode = UIViewContentModeScaleAspectFill;
    cell.btnUser3Image.layer.cornerRadius = cell.btnUser3Image.frame.size.width/2;
    [cell.btnUser3Image setClipsToBounds:YES];
    
    if (![[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
    {
        
        [cell.btnUser3Image sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
    }
    else{
        
        [cell.btnUser3Image setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
    }
    
    
    
    NSString *userName = [[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
    
    int userNameWidth = [self getTextWidth:userName];
    
    
    //5
    cell.btnUser3Name.frame = CGRectMake(cell.btnUser3Name.frame.origin.x,cell.btnUser3Name.frame.origin.y, userNameWidth, 30);
    
    [cell.btnUser3Name setTitle:userName forState:UIControlStateNormal];
    
    cell.btnUser3Name.titleLabel.font = FONT_Bold(13);
    
    [cell.btnUser3Name.titleLabel setTextColor:[UIColor blackColor]];
    
    //6
    
    cell.lblUser3comment.frame = CGRectMake(cell.btnUser3Name.frame.origin.x+ cell.btnUser3Name.frame.size.width + 5,cell.lblUser3comment.frame.origin.y,(ScreenSize.width-20) - (60+userNameWidth), 30);
    
    
    if ([[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
    {
        [cell.lblUser3comment setText:@"commented with image"];
        
    }
    else{
        
        [cell.lblUser3comment setText:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
        
    }
    
}


-(void)setReply3:(CommentList1Cell *)cell indexPath:(NSIndexPath *)indexPath i:(int)i
{
    cell.btnUser3Image.frame = CGRectMake(10, 5, 30, 30);
    
    cell.btnUser3Image.contentMode = UIViewContentModeScaleAspectFill;
    cell.btnUser3Image.layer.cornerRadius = cell.btnUser3Image.frame.size.width/2;
    [cell.btnUser3Image setClipsToBounds:YES];
    
    if (![[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
    {
        
        [cell.btnUser3Image sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
    }
    else{
        
        [cell.btnUser3Image setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
    }
    
    
    
    NSString *userName = [[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
    
    int userNameWidth = [self getTextWidth:userName];
    
    
    //5
    cell.btnUser3Name.frame = CGRectMake(cell.btnUser3Name.frame.origin.x,cell.btnUser3Name.frame.origin.y, userNameWidth, 30);
    
    [cell.btnUser3Name setTitle:userName forState:UIControlStateNormal];
    
    
    cell.btnUser3Name.titleLabel.font = FONT_Bold(13);
    
    [cell.btnUser3Name.titleLabel setTextColor:[UIColor blackColor]];
    
    //6
    
    cell.lblUser3comment.frame = CGRectMake(cell.btnUser3Name.frame.origin.x+ cell.btnUser3Name.frame.size.width + 5,cell.lblUser3comment.frame.origin.y,(ScreenSize.width-20) - (60+userNameWidth), 30);
    
    
    if ([[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
    {
        [cell.lblUser3comment setText:@"commented with image"];
        
    }
    else{
        
        [cell.lblUser3comment setText:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
        
    }
    
}



-(void)setReply2WithImageCell:(CommentList2Cell *)cell indexPath:(NSIndexPath *)indexPath i:(int)i
{
    cell.btnUser2Image.frame = CGRectMake(10, 5, 30, 30);
    
    cell.btnUser2Image.contentMode = UIViewContentModeScaleAspectFill;
    cell.btnUser2Image.layer.cornerRadius = cell.btnUser2Image.frame.size.width/2;
    [cell.btnUser2Image setClipsToBounds:YES];
    
    if (![[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
    {
        
        [cell.btnUser2Image sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
    }
    else{
        
        [cell.btnUser2Image setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
    }
    
    
    
    NSString *userName = [[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
    
    int userNameWidth = [self getTextWidth:userName];
    
    
    //5
    cell.btnUser2Name.frame = CGRectMake(cell.btnUser2Name.frame.origin.x,cell.btnUser2Name.frame.origin.y, userNameWidth, 30);
    
    [cell.btnUser2Name setTitle:userName forState:UIControlStateNormal];
    
    cell.btnUser2Name.titleLabel.font = FONT_Bold(13);
    
    [cell.btnUser2Name.titleLabel setTextColor:[UIColor blackColor]];
    
    //6
    
    cell.lblUser2comment.frame = CGRectMake(cell.btnUser2Name.frame.origin.x+ cell.btnUser2Name.frame.size.width + 5,cell.lblUser2comment.frame.origin.y,(ScreenSize.width-20) - (60+userNameWidth), 30);
    
    
    if ([[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
    {
        [cell.lblUser2comment setText:@"commented with image"];
        
    }
    else{
        
        [cell.lblUser2comment setText:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
        
    }
    
}

-(void)setReply2:(CommentList1Cell *)cell indexPath:(NSIndexPath *)indexPath i:(int)i
{
    
    cell.btnUser2Image.frame = CGRectMake(10, 5, 30, 30);
    cell.btnUser2Image.contentMode = UIViewContentModeScaleAspectFill;
    cell.btnUser2Image.layer.cornerRadius = cell.btnUser2Image.frame.size.width/2;
    [cell.btnUser2Image setClipsToBounds:YES];
    
    if (![[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
    {
        
        [cell.btnUser2Image sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
    }
    else{
        
        [cell.btnUser2Image setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
    }
    
    
    
    NSString *userName = [[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
    
    int userNameWidth = [self getTextWidth:userName];
    
    
    //5
    cell.btnUser2Name.frame = CGRectMake(cell.btnUser2Name.frame.origin.x,cell.btnUser2Name.frame.origin.y, userNameWidth, 30);
    
    [cell.btnUser2Name setTitle:userName forState:UIControlStateNormal];
    
    
    cell.btnUser2Name.titleLabel.font = FONT_Bold(13);
    
    [cell.btnUser2Name.titleLabel setTextColor:[UIColor blackColor]];
    
    //6
    
    cell.lblUser2comment.frame = CGRectMake(cell.btnUser2Name.frame.origin.x+ cell.btnUser2Name.frame.size.width + 5,cell.lblUser2comment.frame.origin.y,(ScreenSize.width-20) - (60+userNameWidth), 30);
    
    
    if ([[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
    {
        [cell.lblUser2comment setText:@"commented with image"];
        
    }
    else{
        
        [cell.lblUser2comment setText:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
        
    }
    
}

-(void)setReply1:(CommentList1Cell *)cell indexPath:(NSIndexPath *)indexPath i:(int)i
{

      cell.btnUser1Image.frame = CGRectMake(10, 5, 30, 30);
    
    cell.btnUser1Image.contentMode = UIViewContentModeScaleAspectFill;
    cell.btnUser1Image.layer.cornerRadius = cell.btnUser1Image.frame.size.width/2;
    [cell.btnUser1Image setClipsToBounds:YES];

    if (![[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
    {
        
        [cell.btnUser1Image sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
    }
    else{
        
        [cell.btnUser1Image setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
    }
    
    
    
    NSString *userName = [[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
    
    int userNameWidth = [self getTextWidth:userName];
    
    
    //5
    cell.btnUser1Name.frame = CGRectMake(cell.btnUser1Name.frame.origin.x,cell.btnUser1Name.frame.origin.y, userNameWidth, 30);
    
    [cell.btnUser1Name setTitle:userName forState:UIControlStateNormal];
    
    
    cell.btnUser1Name.titleLabel.font = FONT_Bold(13);
    
    [cell.btnUser1Name.titleLabel setTextColor:[UIColor blackColor]];
    
    //6
    
    [cell.lblUser1comment setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    cell.lblUser1comment.frame = CGRectMake(cell.btnUser1Name.frame.origin.x + userNameWidth + 5,cell.lblUser1comment.frame.origin.y,(ScreenSize.width-20) - (60+userNameWidth), 30);
    
    
    if ([[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
    {
        [cell.lblUser1comment setText:@"commented with image"];
        
    }
    else{
        
        [cell.lblUser1comment setText:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
        
    }

}

-(void)setReply1WithImageCell:(CommentList2Cell *)cell indexPath:(NSIndexPath *)indexPath i:(int)i
{
    
    cell.btnUser1Image.frame = CGRectMake(10, 5, 30, 30);
    
    cell.btnUser1Image.contentMode = UIViewContentModeScaleAspectFill;
    cell.btnUser1Image.layer.cornerRadius = cell.btnUser1Image.frame.size.width/2;
    [cell.btnUser1Image setClipsToBounds:YES];
    
    if (![[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
    {
        
        [cell.btnUser1Image sd_setImageWithURL:[NSURL URLWithString:[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
    }
    else{
        
        [cell.btnUser1Image setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
    }
    
    
    
    NSString *userName = [[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
    
    int userNameWidth = [self getTextWidth:userName];
    
    
    //5
    cell.btnUser1Name.frame = CGRectMake(cell.btnUser1Name.frame.origin.x,cell.btnUser1Name.frame.origin.y, userNameWidth, 30);
    
    [cell.btnUser1Name setTitle:userName forState:UIControlStateNormal];
    
    cell.btnUser1Name.titleLabel.font = FONT_Bold(13);
    
    [cell.btnUser1Name.titleLabel setTextColor:[UIColor blackColor]];
    
    //6
    
    [cell.lblUser1comment setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    cell.lblUser1comment.frame = CGRectMake(cell.btnUser1Name.frame.origin.x + userNameWidth + 5,cell.lblUser1comment.frame.origin.y,(ScreenSize.width-20) - (60+userNameWidth), 30);
    
    
    if ([[[[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
    {
        [cell.lblUser1comment setText:@"commented with image"];
        
    }
    else{
        
        [cell.lblUser1comment setText:[[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
        
    }
    
}

-(CGFloat)getTextWidth:(NSString *)text
{
    
    CGSize maximumSize = CGSizeMake(ScreenSize.width-100,30);
    
    UIFont *fontName = FONT_Bold(14);
    
    CGRect labelHeighSize = [text boundingRectWithSize:maximumSize
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                             
                                            attributes:@{NSFontAttributeName:fontName}
                                               context:nil];
    
    return labelHeighSize.size.width;
    
}

- (void)label:(DAAttributedLabel *)label didSelectLink:(NSInteger)linkNum
{
    
    NSLog(@"%@",label);
    
    NSLog(@"%ld",(long)label.tag);
 
    NSLog(@"%ld",(long)linkNum);

    NSMutableArray *tagArray = [[NSMutableArray alloc] initWithArray: [[commentArray objectAtIndex:label.tag] valueForKey:@"Tags"]];
    
    if ([tagArray count]>0)
    {
        
        OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
        [otherVC setUserId:[NSString stringWithFormat:@"%@",[[tagArray objectAtIndex:(long)linkNum] valueForKey:@"id"]]];
        [self.navigationController pushViewController:otherVC animated:YES];

        
        
    }
   
}



-(CGFloat)getTextHeight:(NSString *)text
{
    if ([commentArray count]>0)
    {
        
        CGSize maximumSize = CGSizeMake(ScreenSize.width-30,10000);
        
        UIFont *fontName = [UIFont fontWithName:self.lblTitle.font.fontName size:15];
        
        CGRect labelHeighSize = [text boundingRectWithSize:maximumSize
                                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 
                                                attributes:@{NSFontAttributeName:fontName}
                                                   context:nil];
        
        return labelHeighSize.size.height+5;
        
        
    }
    else{
        
        return 0;
    }
    
}




#pragma mark ------------ Handle User Tag ---------

-(void)LinkTextView:(HBVLinkedTextView*)textView1 links:(NSArray*)links
{
    
    [textView1 linkStrings:links
         defaultAttributes:[self DefaultAttributes]
     highlightedAttributes:[self DefaultAttributes]
                tapHandler:[self exampleHandlerWithTitle:textView1]];
   
}

- (NSMutableDictionary *)DefaultAttributes
{

    return [@{NSFontAttributeName:FONT_Regular(14.0f) ,NSForegroundColorAttributeName:[UIColor colorWithRed:49.0/255.0 green:160.0/255.0 blue:218.0/255.0 alpha:1.0]}mutableCopy];
}

-(NSAttributedString*)getLinkedString:(NSString*)inputString tagArray:(NSMutableArray*)tagArray
{
    NSString *finalInputString = [self removeAtTheRate:inputString];
    
    NSMutableAttributedString *finalString  = [[NSMutableAttributedString alloc] initWithString:finalInputString];
    
    for(int i=0;i<tagArray.count;i++)
    {
        NSRange rangeTemp = [finalInputString rangeOfString:[NSString stringWithFormat:@"%@",[tagArray objectAtIndex:i]]];
        
        
        [finalString addAttribute:NSForegroundColorAttributeName value: [UIColor colorWithRed:49.0/255.0 green:160.0/255.0 blue:218.0/255.0 alpha:1.0] range:rangeTemp];
    }
    
    return finalString;
}


-(NSString*)removeAtTheRate:(NSString*)fromString
{
    
    NSString *finalString = fromString;
    
    
    NSString *match = @"@";
    NSString *preTel = [[NSString alloc] init];
    //   NSString *postTel;
    
    NSMutableArray *strArray = [[NSMutableArray alloc] init];
    
    while ([fromString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)
    {
        NSScanner *scanner = [NSScanner scannerWithString:fromString];
        [scanner scanUpToString:match intoString:&preTel];
        
        [scanner scanString:match intoString:nil];
        preTel = [preTel stringByAppendingString:@" "];
        [strArray addObject:preTel];
        
        preTel = @" ";
        fromString = [fromString substringFromIndex:scanner.scanLocation];
        
    }
    
    
    
    finalString = @"";
    for (int i=0; i<strArray.count; i++)
    {
        finalString = [finalString stringByAppendingString:[strArray objectAtIndex:i]];
    }
    
    return finalString;
    
}








- (LinkedStringTapHandler)exampleHandlerWithTitle:(HBVLinkedTextView*)textView1
{
    
    // captionIndex = (int)textView.tag;
    
    LinkedStringTapHandler exampleHandler = ^(NSString *linkedString)
    {
        
        NSLog(@"%@",linkedString);
        
        NSMutableArray *tagArray = [[NSMutableArray alloc] initWithArray: [[commentArray objectAtIndex:textView1.tag] valueForKey:@"Tags"]];
 
        for (int i=0; i<tagArray.count; i++)
        {
            if ([[[tagArray objectAtIndex:i] valueForKey:@"username"]isEqualToString:linkedString])
            {
                
                
                OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
                [otherVC setUserId:[NSString stringWithFormat:@"%@",[[tagArray objectAtIndex:i] valueForKey:@"id"]]];
                [self.navigationController pushViewController:otherVC animated:YES];
                
            
                
                return ;
            }
            
        }
        
    };
    
    return exampleHandler;
}





- (void)addUpperBorder:(UIView *)View
{
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor colorWithRed:232.0/255.0 green:235.0/255.0 blue:240.0/255.0 alpha:1.0]CGColor];
    upperBorder.frame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width - 20, 1.0f);
    [View.layer addSublayer:upperBorder];
}

- (void)addbottomBorder:(UIView *)View
{
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor colorWithRed:232.0/255.0 green:235.0/255.0 blue:240.0/255.0 alpha:1.0]CGColor];
    upperBorder.frame = CGRectMake(0, View.frame.size.height-1,[UIScreen mainScreen].bounds.size.width - 20, 1.0f);
    [View.layer addSublayer:upperBorder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == 100)
    {
   
        if (isSerchFromData)
        {
            
            
            txtComment.text = [txtComment.text stringByAppendingString:[NSString stringWithFormat:@"%@",[[arrayFilteredTag objectAtIndex:indexPath.row] valueForKey:@"tag_name"]]];
            
//            taggedUserIds = [taggedUserIds stringByAppendingString:[NSString stringWithFormat:@"%@,",[[arrayFilteredTag objectAtIndex:indexPath.row] valueForKey:@"user_id"]]];
//            
//            NSString *searchstring = [[DELEGATE getArrayByRemovingString:@"@" fromstring:txtComment.text] lastObject];
//            
//            NSRange range ;
//            range = [txtComment.text rangeOfString:searchstring];
//            
//            NSString *final = [txtComment.text stringByReplacingCharactersInRange:range withString:@""];
//            
//            txtComment.text = [final stringByAppendingString:[NSString stringWithFormat:@"%@",[[arrayFilteredTag objectAtIndex:indexPath.row] valueForKey:@""]]];
            
         
        }
        else
        {
//            txtComment.text = [txtComment.text stringByAppendingString:[NSString stringWithFormat:@"%@",[[arrayToTag objectAtIndex:indexPath.row] valueForKey:@"name"]]];
//            
//            taggedUserIds = [taggedUserIds stringByAppendingString:[NSString stringWithFormat:@"%@,",[[arrayToTag objectAtIndex:indexPath.row] valueForKey:@"user_id"]]];
          
              txtComment.text = [txtComment.text stringByAppendingString:[NSString stringWithFormat:@"%@",[[arrayToTag objectAtIndex:indexPath.row] valueForKey:@"tag_name"]]];
        }
        
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
         {
             [self.viewTag setFrame:CGRectMake(0, -1500, ScreenSize.width, self.viewTag.frame.size.height)];
             
         } completion:nil];
        
        isSerchFromData = NO;
        isBeginTagging = NO;
        [self.tblUsers reloadData];
        
        
    }
    else{
        
        if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]count]>0)
        {
            
            CommentList2Cell *cell =(CommentList2Cell *)[tableView cellForRowAtIndexPath:indexPath];
            
            if(cell.imgComment.image)
            {
                
                [self.imgShareBig sd_setImageWithURL:[NSURL URLWithString:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image"]]];
                self.shareImageView.hidden=NO;
                [self.imgShareBig setHidden:YES];
                isEventShare =NO;
                newTag =(int)indexPath.row;
                [self addZoomView:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image"]];
            }
        }
        
        
        if(popupTag>=0)
        {
            popupTag =-1;
            [self.tableViewComment reloadData];
        }

        
    }
  
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == 100)
    {
        
        return 45;
        
    }
    
    CGFloat height=[self getTextHeight:[[commentArray objectAtIndex:indexPath.row] valueForKey:@"comment"]];

    if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"image_array"]count]>0)
    {

        int reqHeight = 350+height;
        
        if([[[[commentArray objectAtIndex:indexPath.row]valueForKey:@"top_replys_count"] description] intValue] > 0)
        {
            
            reqHeight += viewAllcommentsHeight;
          
        }
        
        
        if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Topreplys"] count]>0)
        {
            
            reqHeight += replyCellHeight * [[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Topreplys"] count];
            
            
        }
        
        return reqHeight;
   
    }
    else
    {
        
        int reqHeight = 130+height;
        
        if([[[[commentArray objectAtIndex:indexPath.row] valueForKey:@"top_replys_count"] description] intValue] > 0)
        {
            
            reqHeight += viewAllcommentsHeight;
            
            
        }
        
        
        if([[[commentArray objectAtIndex:indexPath.row] valueForKey:@"Topreplys"] count]>0)
        {
            
            reqHeight += replyCellHeight * [[[commentArray objectAtIndex:indexPath.row]  valueForKey:@"Topreplys"] count];
            
            
        }
        
        return reqHeight;
  
    }
    
}



#pragma mark --------------- MHFacebook Image Viewer -----------------------

-(NSInteger)numberImagesForImageViewer:(MHFacebookImageViewer *)imageViewer
{
    
    currentIndexPath = (int)imageViewer.senderView.tag;

    if([[[commentArray objectAtIndex:imageViewer.senderView.tag] valueForKey:@"image_array"]count]>0)
    {

        return [[[commentArray objectAtIndex:imageViewer.senderView.tag] valueForKey:@"image_array"]count];
        
    }
    else{
        
         return 0;
    }
  
}

- (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[[commentArray objectAtIndex:imageViewer.senderView.tag] valueForKey:@"image_array"] objectAtIndex:index] valueForKey:@"image"]]];
}


- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    
    return [UIImage imageNamed:@"placeholder"];
}


-(void)likeTapped:(UIButton *)sender
{
    currentImageIndex = (int)sender.tag;
    
    NSLog(@"%ld",(long)sender.tag);
    
    NSLog(@"%@",[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:sender.tag]);
    
    if ([DELEGATE connectedToNetwork])
    {
        
        isImageLiked = [[NSString alloc]init];
        
        if ([[[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:sender.tag] valueForKey:@"is_liked"]isEqualToString:@"N"])
        {
            
            isImageLiked = @"Y";
            
        }
        else{
            
            isImageLiked = @"N";
        }

        [mc likeComment:[USER_DEFAULTS valueForKey:@"userid"] Comment_id:[NSString stringWithFormat:@"%@",[[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:sender.tag] valueForKey:@"id"]] Is_like:[NSString stringWithFormat:@"%@",isImageLiked] Sel:@selector(imageLiked:)];
    }
   
}

-(void)imageLiked:(NSDictionary *)response
{
    NSLog(@"%@",response);
    
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        DELEGATE.isEventEdited = YES;

        NSMutableDictionary *commentData = [[commentArray objectAtIndex:currentIndexPath] mutableCopy];
        
        NSMutableArray *imageArray = [[commentData valueForKey:@"image_array"]mutableCopy];
        
        NSMutableDictionary *imageData = [[imageArray objectAtIndex:currentImageIndex] mutableCopy];
   
        [imageData setValue:[NSString stringWithFormat:@"%@",isImageLiked] forKey:@"is_liked"];
        [imageData setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"like_count"]] forKey:@"like_count"];
        
        [imageArray setObject:imageData atIndexedSubscript:currentImageIndex];
     
        [commentData  setObject:imageArray forKey:@"image_array"];
        
        [commentArray setObject:commentData atIndexedSubscript:currentIndexPath];
        
        [tableViewComment reloadData];
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"updateGallery" object:@{@"imageIndex":[NSString stringWithFormat:@"%d",currentImageIndex]}];
  
    }
    else
    {
        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
   
}


-(void)CommentTapped:(UIButton *)sender
{
    
   // NSLog(@"%ld",(long)sender.tag);
//
//    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    
//        for (UIViewController *VC in rootViewController.childViewControllers)
//        {
//            if ( [VC isKindOfClass:[MHFacebookImageViewer class]]) {
//                [VC removeFromParentViewController];
//            }
//        }
//    
    //NSLog(@"%@",[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:sender.tag]);
    
    
   // NSLog(@"%@",[NSString stringWithFormat:@"%@",[[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:sender.tag] valueForKey:@"id"]]);
    
    CommentDetail *obj = [[CommentDetail alloc]init];
    
    obj.commentID = [[NSString alloc]init];
    
    obj.commentID = [NSString stringWithFormat:@"%@",[[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:sender.tag] valueForKey:@"id"]];
    
    obj.eventID = [[NSString alloc]init];
    obj.eventID = eventID;
    
    obj.isImageReplies = YES;
    
    
    [obj setHidesBottomBarWhenPushed:YES];

    [self.navigationController pushViewController:obj animated:YES];
    
    
}




-(void)updateLikeComment:(imageLikeComment *)view
{

     //NSLog(@"%@",[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:(long)view.tag]);
    
    
    
    if ([[[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:(long)view.tag]valueForKey:@"is_liked"]isEqualToString:@"N"]){
        [view.btnLike setImage:[UIImage imageNamed:@"like1"] forState:UIControlStateNormal];
        
        }
    else{
        
        [view.btnLike setImage:[UIImage imageNamed:@"like2"] forState:UIControlStateNormal];

    }
  
    
    [view.lblLikes setText:[NSString stringWithFormat:@"%@ Like",[[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:(long)view.tag] valueForKey:@"like_count"]]];
    
    [view.lblComments setText:[NSString stringWithFormat:@"%@ Comment",[[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:(long)view.tag] valueForKey:@"reply_count"]]];
  
}





//func numberImagesForImageViewer(imageViewer: MHFacebookImageViewer) -> Int
//{
//    
//    let images = feedDetails.valueForKey("media")as! NSMutableArray
//    return images.count
//}
//
//func imageURLAtIndex(index: Int, imageViewer: MHFacebookImageViewer) -> NSURL
//{
//    let images = feedDetails.valueForKey("media")as! NSMutableArray
//    
//    return NSURL(string: images.objectAtIndex(index) as! String)!
//}
//
//func imageDefaultAtIndex(index: Int, imageViewer: MHFacebookImageViewer) -> UIImage
//{
//    NSLog("INDEX IS %i", index)
//    ImageIndex = index
//    return UIImage(named:"placeholder")!
//}







- (UIImage *)drawImage2:(UIImage *)inputImage inRect:(CGRect)frame
{
    /*  UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), YES, 0.0);
     
     // get context
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     // push context to make it current
     // (need to do this manually because we are not drawing in a UIView)
     UIGraphicsPushContext(context);
     
     // drawing code comes here- look at CGContext reference
     // for available operations
     // this example draws the inputImage into the context
     [inputImage drawInRect:frame];
     
     // pop context
     UIGraphicsPopContext();
     
     // get a UIImage from the image context- enjoy!!!
     UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
     
     // clean up drawing environment
     UIGraphicsEndImageContext();
     return outputImage;*/
    
    
    
    CGImageRef tmpImgRef = inputImage.CGImage;
    CGImageRef topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 0, inputImage.size.width, inputImage.size.height ));
    UIImage *topImage = [UIImage imageWithCGImage:topImgRef];
    CGImageRelease(topImgRef);
    
    return topImage;
    
    /* CGImageRef bottomImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height / 2.0,  image.size.width, inputImage.size.height / 2.0));
     UIImage *bottomImage = [UIImage imageWithCGImage:bottomImgRef];
     CGImageRelease(bottomImgRef);*/
}
- (UIImage *)drawImage:(UIImage *)inputImage inRect:(CGRect)frame
{
    
    
    
  /*  NSLog(@"origional height: %f",inputImage.size.height);
    NSLog(@"origional width: %f",inputImage.size.width);
    CGImageRef tmpImgRef = inputImage.CGImage;
    CGImageRef topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 50, inputImage.size.width, inputImage.size.height));
    UIImage *topImage = [UIImage imageWithCGImage:topImgRef];
    NSLog(@"image height: %f",topImage.size.height);
    NSLog(@"image width: %f",topImage.size.width);
    NSLog(@"ΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩ");

    CGImageRelease(topImgRef);*/
    
    
    NSLog(@"origional height: %f",inputImage.size.height);
   NSLog(@"origional width: %f",inputImage.size.width);
    
    CGImageRef tmpImgRef = inputImage.CGImage;
    CGImageRef topImgRef;
    
    
    float widthRatio = frame.size.width / inputImage.size.width;
    float heightRatio = frame.size.height / inputImage.size.height;
    float scale = MAX(widthRatio, heightRatio);
   // float imageWidth = scale * inputImage.size.width;
    float imageHeight = scale * inputImage.size.height;
    
    
     if(IS_Ipad)
     {
         if(imageHeight<700)
         {
             topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 0, inputImage.size.width, inputImage.size.height));
         }
         else
         {
             topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height/2.5, inputImage.size.width, inputImage.size.height/2));
         }
     }
     else
        {
            if(imageHeight<350)
            {
                topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 50, inputImage.size.width, inputImage.size.height));
            }
            else
            {
                topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height/2.5, inputImage.size.width, inputImage.size.height/2));
            }
     }
    
   /* NSLog(@"origional height: %f",inputImage.size.height);
    NSLog(@"origional width: %f",inputImage.size.width);
    
    CGImageRef tmpImgRef = inputImage.CGImage;
    CGImageRef topImgRef;
    
    
    float widthRatio = frame.size.width / inputImage.size.width;
    float heightRatio = frame.size.height / inputImage.size.height;
    float scale = MAX(widthRatio, heightRatio);
     float imageWidth = scale * inputImage.size.width;
    float imageHeight = scale * inputImage.size.height;
    
    
    if(IS_Ipad)
    {
        if(imageHeight<350)
        {
            topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 0, imageWidth, imageHeight));
        }
        else
        {
            topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height/2.5, imageWidth, imageHeight));
        }
    }
    else
    {
        if(imageHeight<350)
        {
            topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 50, imageWidth, imageHeight));
        }
        else
        {
            topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height/2.5, imageWidth, imageHeight));
        }
    }
    */
    
    


    
    
    
    
    
  /* if(imageHeight<350)
    {
         topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 50, inputImage.size.width, inputImage.size.height));
    }
    else
    {
        topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height/2.5, inputImage.size.width, inputImage.size.height/2));
    }*/
    
    UIImage *topImage = [UIImage imageWithCGImage:topImgRef];
     NSLog(@"image height: %f",topImage.size.height);
      NSLog(@"image width: %f",topImage.size.width);
    
  //  NSLog(@"image height: %f",topImage.size.height);
  //  NSLog(@"image width: %f",topImage.size.width);
   NSLog(@"ΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩΩ");
  //  CGImageRelease(topImgRef);
    
    
    
    
    return topImage;
    
   /* CGImageRef bottomImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height / 2.0,  image.size.width, inputImage.size.height / 2.0));
    UIImage *bottomImage = [UIImage imageWithCGImage:bottomImgRef];
    CGImageRelease(bottomImgRef);*/
}
- (UIImage *)drawImageNew:(UIImage *)inputImage inRect:(CGRect)frame
{
   
    
    
    
   /* CGImageRef tmpImgRef = inputImage.CGImage;
    CGImageRef topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 0, inputImage.size.width, inputImage.size.height));
    UIImage *topImage = [UIImage imageWithCGImage:topImgRef];
    //  NSLog(@"image height: %f",topImage.size.height);
    //  NSLog(@"image width: %f",topImage.size.width);
    CGImageRelease(topImgRef);
    
    return topImage;*/
    
    /* CGImageRef bottomImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height / 2.0,  image.size.width, inputImage.size.height / 2.0));
     UIImage *bottomImage = [UIImage imageWithCGImage:bottomImgRef];
     CGImageRelease(bottomImgRef);*/
    
    /*  UIGraphicsBeginImageContextWithOptions(CGSizeMake(250,200), YES, 0.0);
     
     CGContextRef context = UIGraphicsGetCurrentContext();
    
     UIGraphicsPushContext(context);
     
     [inputImage drawInRect:frame];
    
     UIGraphicsPopContext();
     
     UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
     
     UIGraphicsEndImageContext();
     return outputImage;*/
    
    CGImageRef tmpImgRef = inputImage.CGImage;
    CGImageRef topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 50, inputImage.size.width, inputImage.size.height));
    UIImage *topImage = [UIImage imageWithCGImage:topImgRef];
    //  NSLog(@"image height: %f",topImage.size.height);
    //  NSLog(@"image width: %f",topImage.size.width);
    CGImageRelease(topImgRef);
    
    return topImage;
}

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    // not equivalent to image.size (which depends on the imageOrientation)!
    double refWidth = CGImageGetWidth(image.CGImage);
    double refHeight = CGImageGetHeight(image.CGImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    return cropped;
}
- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer
{
   /* UIView *view = [recognizer view];
    OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
    [otherVC setUserId:[[commentArray objectAtIndex:view.tag] valueForKey:@"userid"]];
    [self.navigationController pushViewController:otherVC animated:YES];

    */
    UIView *view = [recognizer view];
    if([[[commentArray objectAtIndex:view.tag] valueForKey:@"userimage_thumb"] length]>0)
    {        //image
        [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:view.tag] valueForKey:@"userimage_thumb"]] Type:2];
    }
   
}
- (void) handleTapFrom2: (UITapGestureRecognizer *)recognizer
{
        UIView *view = [recognizer view];
   
        NSString *userID =[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:view.tag] valueForKey:@"userid"]];
   
    
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
        [otherVC setUserId:userID];
        [self.navigationController pushViewController:otherVC animated:YES];
        
    }

}
-(void)likeBtnTapped:(UIButton *)sender
{
    likeID =(int)sender.tag;
    NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[commentArray objectAtIndex:sender.tag]];
    
    BOOL isLike =NO;
    
    if([[dict valueForKey:@"is_liked"] isEqualToString:@"N"])
    {
        isLike=YES;
    }
    else
    {
        isLike=NO;
    }
    
    if(DELEGATE.connectedToNetwork)
    {
        [mc likeComment:[USER_DEFAULTS valueForKey:@"userid"] Comment_id:[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:sender.tag] valueForKey:@"id"]] Is_like:(isLike)?@"Y":@"N" Sel:@selector(responseLikeComments:)];
    }
}
-(void)responseLikeComments:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[commentArray objectAtIndex:likeID]];
        
        if([[dict valueForKey:@"is_liked"] isEqualToString:@"N"])
        {
            [dict setValue:@"Y" forKey:@"is_liked"];
            
            int likeCount1 =(int)[[dict valueForKey:@"like_count"] integerValue];
            likeCount1++;
            [dict setValue:[NSString stringWithFormat:@"%d",likeCount1] forKey:@"like_count"];
        }
        else
        {
            [dict setValue:@"N" forKey:@"is_liked"];
            int likeCount1 =(int)[[dict valueForKey:@"like_count"] integerValue];
            likeCount1--;
            [dict setValue:[NSString stringWithFormat:@"%d",likeCount1] forKey:@"like_count"];
        }
        [commentArray replaceObjectAtIndex:likeID withObject:dict];
        
        /*comment = fhdjksfhdjkshgjkdfhsgjkfhgjkdfhsgjkdfhsgjkhdfjkghfgdf;
         id = 49;
         image = "http://192.168.1.100/apps/amhappy/web/img/uploads/comments/1441979256myimage.jpeg";
         "is_delete" = Y;
         "is_liked" = N;
         "is_reported" = N;
         time = 1441979256;
         userid = 18;
         userimage = "";
         "userimage_thumb" = "";
         username = aklesh;*/
        
        likeID =-1;
        
        [self.tableViewComment reloadData];
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
}
-(void)deleteBtnTapped:(UIButton *)sender
{
    deleteTag =(int)[sender tag];
    popupTag =-1;
    [DELEGATE showalertNew:self Message:[localization localizedStringForKey:@"Are you sure, you want to delete this comment?"] AlertFlag:10];

}
-(void)reportBtnTapped:(UIButton *)sender
{
    reportCommentId =(int)sender.tag;
    [DELEGATE showalertNew:self Message:[localization localizedStringForKey:@"Are you sure, you want to report this comment?"] AlertFlag:5];
  
}
-(void)responseReportComments:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Your report has been submitted"] AlertFlag:1 ButtonFlag:1];
        
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[commentArray objectAtIndex:reportCommentId]];
        [dict setValue:@"Y" forKey:@"is_reported"];
        [commentArray replaceObjectAtIndex:reportCommentId withObject:dict];
        
        /*comment = fhdjksfhdjkshgjkdfhsgjkfhgjkdfhsgjkdfhsgjkhdfjkghfgdf;
        id = 49;
        image = "http://192.168.1.100/apps/amhappy/web/img/uploads/comments/1441979256myimage.jpeg";
        "is_delete" = Y;
        "is_liked" = N;
        "is_reported" = N;
        time = 1441979256;
        userid = 18;
        userimage = "";
        "userimage_thumb" = "";
        username = aklesh;*/
        
        reportCommentId =-1;
        
        [self.tableViewComment reloadData];
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
}
//-(void)callCommentShare:(int)commentTag
//{
//    NSString *message = [NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:commentTag] valueForKey:@"comment"]];
//    
//    if([DELEGATE connectedToNetwork])
//    {
//        
//        //  [drk showWithMessage:nil];
//        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"publish_actions",@"user_friends"]
//                                           allowLoginUI:YES
//                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//                                          
//                                          switch (state) {
//                                              case FBSessionStateOpen:
//                                              {
//                                                  [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
//                                                      if (error) {
//                                                          
//                                                          NSLog(@"error:%@",error);
//                                                          
//                                                          
//                                                      }
//                                                      else
//                                                      {
//                                                          [self callFB:message];
//                                                          [FBSession setActiveSession:session];
//                                                          
//                                                      }
//                                                  }];
//                                                  break;
//                                              }
//                                                  
//                                              case FBSessionStateClosed:
//                                              {
//                                                  
//                                              }
//                                              case FBSessionStateClosedLoginFailed:
//                                              {
//                                                  
//                                                  [FBSession.activeSession closeAndClearTokenInformation];
//                                                  break;
//                                              }
//                                                  
//                                              default:
//                                                  break;
//                                          }
//                                          
//                                      } ];
//    }
//    
//
//}


-(void)commentTapped:(UIButton *)sender
{
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:(int)sender.tag] valueForKey:@"id"]]);
    
    CommentDetail *obj = [[CommentDetail alloc]init];
    
    obj.gettedReplies = [[NSMutableArray alloc]initWithArray:[[commentArray objectAtIndex:(int)sender.tag] valueForKey:@"Reply"]];
    obj.commentID = [[NSString alloc]init];
    
    obj.commentID = [NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:(int)sender.tag] valueForKey:@"id"]];
    
    obj.eventID = [[NSString alloc]init];
    obj.eventID = eventID;
    
     [obj setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:obj animated:YES];
    
    
}

-(void)commentBtnTapped:(UIButton *)sender
{
    
      NSLog(@"%@",[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:(int)sender.tag] valueForKey:@"id"]]);
    
    CommentDetail *obj = [[CommentDetail alloc]init];
    
    obj.gettedReplies = [[NSMutableArray alloc]initWithArray:[[commentArray objectAtIndex:(int)sender.tag] valueForKey:@"Reply"]];
    obj.commentID = [[NSString alloc]init];
    
    obj.commentID = [NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:(int)sender.tag] valueForKey:@"id"]];
    
    obj.eventID = [[NSString alloc]init];
    obj.eventID = eventID;
    
     [obj setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:obj animated:YES];
    
}


-(void)shareBtnTapped:(UIButton *)sender
{
     popupTag =-1;
    
    newTag =(int)sender.tag;
    
   /* if([[[commentArray objectAtIndex:sender.tag] valueForKey:@"image"] length]>0)
    {
        [self.imgShareBig sd_setImageWithURL:[NSURL URLWithString:[[commentArray objectAtIndex:sender.tag] valueForKey:@"image"]]];
        self.shareImageView.hidden=NO;
        isEventShare =NO;
    
        
    }
    else
    {
        [self callCommentShare:newTag];
   
    }*/
    
    [self shareComom:[commentArray objectAtIndex:sender.tag] ShareFlag:2];
    
    
    
}
//-(void)callFB:(NSString *)text
//{
//    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
//    [params setObject:text forKey:@"message"];
//    [params setObject:@"AmHappy" forKey:@"title"];
//    
//    if(self.imgShareBig.image)
//    {
//        self.imgShareBig.hidden=NO;
//        [params setObject:UIImagePNGRepresentation([self screenshot]) forKey:@"picture"];
//        //[params setObject:UIImagePNGRepresentation(self.imgShareBig.image) forKey:@"picture"];
//
//        [FBRequestConnection startWithGraphPath:@"me/photos"
//                                     parameters:params
//                                     HTTPMethod:@"POST"
//                              completionHandler:^(FBRequestConnection *connection,
//                                                  id result,
//                                                  NSError *error)
//         {
//             [drk hide];
//             if (error)
//             {
//                 
//                 [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Error in sharing"] AlertFlag:1 ButtonFlag:1];
//
//                 
//             }
//             else
//             {
//                 [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Shared"] AlertFlag:1 ButtonFlag:1];
//
//             }
//         }];
//
//    }
//    else
//    {
//        [FBRequestConnection startWithGraphPath:@"me/feed"
//                                     parameters:params
//                                     HTTPMethod:@"POST"
//                              completionHandler:^(FBRequestConnection *connection,
//                                                  id result,
//                                                  NSError *error)
//         {
//             [drk hide];
//             if (error)
//             {
//                 
//                 [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Error in sharing"] AlertFlag:1 ButtonFlag:1];
//              
//             }
//             else
//             {
//                 [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Shared"] AlertFlag:1 ButtonFlag:1];
//
//             }
//         }];
//    }
//
//}

-(UIImage *) screenshot
{
    [NSThread sleepForTimeInterval:2.0];
    
    CGRect rect;
    rect=self.view.bounds;
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    [self.shareSubview.layer renderInContext:context];
    
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.shareImageView.hidden=YES;
    self.imgShareBig.image=nil;
    
    return image;
}
-(UIImage*)drawOverlapImage:(UIImage*) fgImage
              inImage:(UIImage*) backImage
{
    UIGraphicsBeginImageContextWithOptions(backImage.size, FALSE, 0.0);
    [backImage drawInRect:CGRectMake( 0, 0, backImage.size.width, backImage.size.height)];
    [fgImage drawInRect:CGRectMake(0, 0, fgImage.size.width, fgImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (IBAction)shareNewTapped:(id)sender
{
    [self shareActual];
}
- (IBAction)cancelTapped:(id)sender
{
    self.shareImageView.hidden=YES;
    self.imgShareBig.image=nil;
}

-(void)shareActual
{
   // NSString *message;
    if(isEventShare)
    {
        [self shareComom:shareDict ShareFlag:1];
        //message = [NSString stringWithFormat:@"%@",self.lbldesc.text];
    }
    else
    {
        [self shareComom:[commentArray objectAtIndex:newTag] ShareFlag:2];

       //message = [NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:newTag] valueForKey:@"comment"]];
    }
    
   

}
-(void)showBtnTapped:(UIButton *)sender
{
    popupTag = (int)sender.tag;
    [self.tableViewComment reloadData];
}

-(CGFloat)getLabelHeightForText:(NSString *)str
{
   /* CGSize maximumSize = CGSizeMake(self.view.bounds.size.width, 100000);
    
    
    CGSize labelHeighSize = [str  sizeWithFont: [UIFont systemFontOfSize:14.0]
                                                                                     constrainedToSize:maximumSize
                                                                                         lineBreakMode:NSLineBreakByWordWrapping];
    return labelHeighSize.height;*/
    
    CGSize boundingSize ;
    if(IS_Ipad)
    {
        boundingSize = CGSizeMake(240, 10000000);
        
    }
    else
    {
        boundingSize = CGSizeMake(200, 10000000);
        
    }
    CGSize itemTextSize = [str sizeWithFont:[UIFont systemFontOfSize:14]
                                                                                  constrainedToSize:boundingSize
                                                                                      lineBreakMode:NSLineBreakByWordWrapping];
    float cellHeight = itemTextSize.height;
    
    
    return cellHeight;
    
    
}

-(CGFloat)getLabelHeightForIndex:(NSInteger)index
{
    
   /* CommentList2Cell *cell = (CommentList2Cell *)[self.tableViewComment dequeueReusableCellWithIdentifier:nil];
    
    
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentList2Cell" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
    }
    CGSize maximumSize = CGSizeMake(cell.lblComment.bounds.size.width, 100000);
    
    NSLog(@"comment is %@",[[commentArray objectAtIndex:index] valueForKey:@"comment"]);
    
    CGSize labelHeighSize = [[[commentArray objectAtIndex:index] valueForKey:@"comment"]  sizeWithFont: [UIFont systemFontOfSize:14.0]
                                                                                  constrainedToSize:maximumSize
                                                                                      lineBreakMode:NSLineBreakByWordWrapping];
    cell =nil;
    return labelHeighSize.height;*/
    
    CGSize boundingSize ;
 
    boundingSize = CGSizeMake(self.view.bounds.size.width-30, 10000000);
        
    
    CGSize itemTextSize = [[[commentArray objectAtIndex:index] valueForKey:@"comment"] sizeWithFont:[UIFont systemFontOfSize:15]
                              constrainedToSize:boundingSize
                                  lineBreakMode:NSLineBreakByWordWrapping];
    float cellHeight = itemTextSize.height;
    
   
    return cellHeight;

    
    
}

-(CGFloat)sizeOfText:(NSString *)textToMesure widthOfTextView:(CGFloat)width withFont:(UIFont*)font
{
    CGSize ts = [textToMesure sizeWithFont:font constrainedToSize:CGSizeMake(width-20.0, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return ts.height;
}
-(void)deleteCommentt:(NSString *)commentId
{
  //  [DELEGATE showalertNew:self Message:[localization localizedStringForKey:@""] AlertFlag:5];

    if(DELEGATE.connectedToNetwork)
    {
        [mc deleteComment:[USER_DEFAULTS valueForKey:@"userid"] Comment_id:commentId Sel:@selector(responseDeleteComments:)];
    }
}
-(void)responseDeleteComments:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [commentArray removeObjectAtIndex:deleteTag];
        [self.tableViewComment reloadData];
        deleteTag =-1;
        
        [self.tableViewComment layoutIfNeeded];
        CGSize tableViewSize=self.tableViewComment.contentSize;
        self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
        
        [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
       
        
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
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
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",formattedDate];
}

-(NSString *)getTime1:(NSString *)str
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
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",formattedDate];
}
- (IBAction)editTapped:(id)sender
{
    EventTabViewController *eventTabVC =[[EventTabViewController alloc] initWithNibName:@"EventTabViewController" bundle:nil];
    [eventTabVC setIsEdit:YES];
    [eventTabVC setEventId:self.eventID];
    [self.navigationController pushViewController:eventTabVC animated:YES];
}


- (IBAction)calTapped:(id)sender
{
    
    NSLog(@"%@",EventDetails);
    
    EventCalendarViewController *eventCalVC;// =[[EventCalendarViewController alloc] initWithNibName:@"EventCalendarViewController" bundle:nil];
   
    if(isPrivate)
    {
        eventCalVC =[[EventCalendarViewController alloc] initWithNibName:@"EventCalendarViewController" VoteID:votedDateId bundle:nil];
      
        eventCalVC.endVoting = [[EventDetails valueForKey:@"Event"]valueForKey:@"voting_close_date"];
        
        
    }

    if(!isPrivate)
    {
        eventCalVC =[[EventCalendarViewController alloc] initWithNibName:@"EventCalendarViewController" bundle:nil];
        eventCalVC.peventDate =[NSString stringWithString:pEvendDate];
        
    }
    
    eventCalVC.eventType = [[NSString alloc]init];
    eventCalVC.eventType = [[EventDetails valueForKey:@"Event"]valueForKey:@"type"];
 
    [eventCalVC setIsMy:isMy];
    [eventCalVC setEventID:self.eventID];
    [eventCalVC setIsPrivate:isPrivate];
   
    
    
  
    
    eventCalVC.voteDateArray =[[NSArray alloc] initWithArray:dateArray];
    [self.navigationController pushViewController:eventCalVC animated:YES];
    
   

}
- (IBAction)locationTapped:(id)sender
{
    EventLocationViewController *eventLocationVC;// =[[EventLocationViewController alloc] initWithNibName:@"EventLocationViewController" bundle:nil];
    
    if(isPrivate)
    {
       eventLocationVC =[[EventLocationViewController alloc] initWithNibName:@"EventLocationViewController" VoteID:votedLocId bundle:nil];
        eventLocationVC.eventName =[NSString stringWithFormat:@"%@",self.lblEventName.text];
        
        eventLocationVC.endVoting = [[EventDetails valueForKey:@"Event"]valueForKey:@"voting_close_date"];

    }
    
    if(!isPrivate)
    {
        eventLocationVC =[[EventLocationViewController alloc] initWithNibName:@"EventLocationViewController" bundle:nil];
        eventLocationVC.pDictionary =[[NSDictionary alloc] initWithDictionary:locationDict];
        eventLocationVC.type=eventType;
        eventLocationVC.eventName =[NSString stringWithString:pEvendname];
    }

    [eventLocationVC setIsMy:isMy];
    [eventLocationVC setEventID:self.eventID];
    [eventLocationVC setCatID:catId];
    [eventLocationVC setImgURL:imageURL];
    [eventLocationVC setIsPrivate:isPrivate];
    if(locationArray)
    {
        eventLocationVC.voteDateArray =[[NSArray alloc] initWithArray:locationArray];
    }
    
    eventLocationVC.eventType = [[NSString alloc]init];
    eventLocationVC.eventType = [[EventDetails valueForKey:@"Event"]valueForKey:@"type"];
    
    NSLog(@"vote array is %@",eventLocationVC.voteDateArray);
    [self.navigationController pushViewController:eventLocationVC animated:YES];
}
- (IBAction)guestTapped:(id)sender
{
//    GuestViewController *guestVC =[[GuestViewController alloc] initWithNibName:@"GuestViewController" bundle:nil];
//    [guestVC setEventID:self.eventID];
//    [guestVC setIsMy:isMy];
//    [guestVC setIsPrivate:isPrivate];
//    [guestVC setIsFromChat:NO];
    
    Guests *guestVC =[[Guests alloc] initWithNibName:@"Guests" bundle:nil];
    
    guestVC.eventId = self.eventID;
    
    guestVC.isMyEvent = isMy;
    
    guestVC.is_admin = isAdmin;
    
    if([[[EventDetails valueForKey:@"Event"] valueForKey:@"type"] isEqualToString:@"Expired"])
    {
        
        guestVC.is_expired = YES;
        
    }
    else{
        
         guestVC.is_expired = NO;
        
    }
    
    

    [self.navigationController pushViewController:guestVC animated:YES];
}


-(void)shareEvent
{
   
    
    NSMutableDictionary *properties = [@{
                                 @"og:type": @"amhappyapp:event",
                                 @"og:title": self.lblEventName.text,
                                 @"og:description": [[shareDict valueForKey:@"type"]isEqualToString:@"Private"] ? [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[[locationArray objectAtIndex:0] valueForKey:@"location"]] : [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[locationDict valueForKey:@"Paddress"]],
                            
                                 @"og:url": DeepLinkUrl,
                              
                                 
                                 }mutableCopy];
    
    
    if(imageURL.length>0)
    {
  
        FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:[[NSURL alloc]initWithString:imageURL] userGenerated:NO];
        // photo.image = self.imgEvent.image;
        [properties setObject:@[photo] forKey:@"og:image"];
        
    

    }
    else
    {

        FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:[[NSURL alloc]initWithString:Icon_PATH] userGenerated:NO];
        UIImage *img = [[UIImage alloc]init];
        img = [UIImage imageNamed:@"iconBlack"];
        //photo.image = img;
        [properties setObject:@[photo] forKey:@"og:image"];
   
    }

    
  
    
    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
    
   
    
    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
    action.actionType = @"amhappyapp:share";
    [action setObject:object forKey:@"event"];
    [action setString:@"true" forKey:@"fb:explicitly_shared"];
    //[action setObject:@"www.apple.com" forKey:@"link"];
    

    
    
    
    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
    
    
    content.action = action;
    content.previewPropertyName = @"event";
    
  
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.fromViewController = self;
    shareDialog.shareContent = content;
    shareDialog.delegate = self;
    
    
    NSError * error = nil;
    BOOL validation = [shareDialog validateWithError:&error];
    if (validation)
    {
        [shareDialog show];
    }
    else
    {
       // Facebook App not Found!
        
        NSLog(@"%@",error);
        
        
           [DELEGATE showalert:self Message:FacebookNotFound AlertFlag:1 ButtonFlag:1];
        
    }
 
}


-(void)shareComment:(NSDictionary *)dict
{
    
    NSString *decodedString = [[self DecodeCommentString:[dict valueForKey:@"comment"] usersTagged:[dict valueForKey:@"Tags"]] string];
 
    NSMutableDictionary *properties = [@{
                                         @"og:type": @"amhappyapp:comment",
                                         @"og:title": self.lblEventName.text,
                                         @"og:description": decodedString ? decodedString : @"",
                                         
                                         @"og:url": DeepLinkUrl,
                                         
                                         
                                         }mutableCopy];
    
    
     NSString *imgurl =[NSString stringWithFormat:@"%@",[dict valueForKey:@"image"]];
    
    if(imgurl.length>0)
    {
        
        FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:[[NSURL alloc]initWithString:imgurl] userGenerated:NO];
        // photo.image = self.imgEvent.image;
        [properties setObject:@[photo] forKey:@"og:image"];
        
        
        
    }
    else
    {
        
        FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:[[NSURL alloc]initWithString:Icon_PATH] userGenerated:NO];
        UIImage *img = [[UIImage alloc]init];
        img = [UIImage imageNamed:@"iconBlack"];
        //photo.image = img;
        [properties setObject:@[photo] forKey:@"og:image"];
        
    }
    
    
    
    
    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
    
    
    
    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
    action.actionType = @"amhappyapp:share";
    [action setObject:object forKey:@"comment"];
    [action setString:@"true" forKey:@"fb:explicitly_shared"];
    //[action setObject:@"www.apple.com" forKey:@"link"];
    
    
    
    
    
    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
    
    
    content.action = action;
    content.previewPropertyName = @"comment";
    
    
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.fromViewController = self;
    shareDialog.shareContent = content;
    shareDialog.delegate = self;
    
    
    NSError * error = nil;
    BOOL validation = [shareDialog validateWithError:&error];
    if (validation)
    {
        [shareDialog show];
    }
    else
    {
        
        NSLog(@"%@",error);
     
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Facebook App is not installed."] AlertFlag:1 ButtonFlag:1];
        
    }
    
}


-(void)shareComom:(NSDictionary *)dict ShareFlag:(int)shareFlag
{

    
   
    //[self shareFB];
   

    
    if(DELEGATE.connectedToNetwork)
    {
        if(shareFlag==1)
        {
            /* id<FBGraphObject> object =
             [FBGraphObject openGraphObjectForPostWithType:@"amhappytest:event"
             title:@"Sample event"
             image:nil
             url:@"http://www.apple.com" // fb.me app links hosted url here
             description:@"desc"];*/
            
            /*   NSString *html = [self htmlWithMetaTags:@[
             @{
             @"al:ios": [NSNull null],
             @"al:ios:url":@"https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/972366090",
             @"al:ios:app_name": @"AmHappy",
             @"al:ios:app_store_id": @"972366090"
             }
             ]];*/
            
             [self shareEvent];
            
//        NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
//            
//          
//            
//          NSMutableDictionary <FBOpenGraphObject> *object =  [FBGraphObject openGraphObjectForPostWithType:@"amhappyapp:event"
//                                                    title:@"testing title"
//                                                    image:nil
//                                                      url:DeepLinkUrl
//                                              description:@""];
//            
//            
//            object.provisionedForPost = YES;
//            object[@"title"] = self.lblEventName.text;
//            object[@"type"] = @"amhappyapp:event";
//            
//            //object[@"link"] = @"https://fb.me/1600227070237260";
//
//           // object[@"link"] = @"AmHappy://";
//            
//            object[@"link"] = @"www.apple.com";
//
//            
//            if(imageURL.length>0)
//            {
//                object[@"image"] = @[
//                                     @{@"url": imageURL, @"user_generated" : @"false" }
//                                     ];
//            }
//            else
//            {
//                object[@"image"] = @[
//                                     @{@"url": Icon_PATH, @"user_generated" : @"false" }
//                                     ];
//            }
//            
//            if([[shareDict valueForKey:@"type"]isEqualToString:@"Private"])
//            {
//                object[@"description"] = [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[[locationArray objectAtIndex:0] valueForKey:@"location"]];
//            }
//            else
//            {
//                object[@"description"] = [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[locationDict valueForKey:@"Paddress"]];
//                
//            }
//            
//            
//            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>) [FBGraphObject graphObject];
//            [action setObject:object forKey:@"event"];
//            //[action setObject:@"AmHappy://" forKey:@"link"];
//            [action setObject:@"www.apple.com" forKey:@"link"];
//
//            FBOpenGraphActionParams *actionParam =[[FBOpenGraphActionParams alloc] init];
//            actionParam.actionType =@"amhappyapp:share";
//            actionParam.previewPropertyName = @"event";
//            actionParam.action =action;
//            
//            if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:actionParam]) {
//                // Show the share dialog
//                [FBDialogs presentShareDialogWithOpenGraphAction:action
//                                                      actionType:@"amhappyapp:share"
//                                             previewPropertyName:@"event"
//                                                         handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                                             if(error) {
//                                                                 // An error occurred, we need to handle the error
//                                                                 // See: https://developers.facebook.com/docs/ios/errors
//                                                                 NSLog(@"Error publishing story: %@", error.localizedDescription);
//                                                                 [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Error occured while sharing"] AlertFlag:1 ButtonFlag:1];
//                                                             } else {
//                                                                 // Success
//                                                                 NSLog(@"result %@", results);
//                                                             }
//                                                         }]; 
//            }
//            else
//            {
//                NSLog(@"can not open");
//            }

        }
        else
        {
            
            [self shareComment:dict];
            
           // NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
            
//            NSMutableDictionary <FBOpenGraphObject> *object =  [FBGraphObject openGraphObjectForPostWithType:@"amhappyapp:comment"                                                                                                       title:@"testing title"                                                                                                       image:nil                                                                                                         url:DeepLinkUrl                                                                                                 description:@""];
//            
//            
//            object.provisionedForPost = YES;
//            object[@"title"] = self.lblEventName.text;
//            object[@"type"] = @"amhappyapp:comment";
//            object[@"link"] = @"www.apple.com";
//
//            
//            NSString *imgurl =[NSString stringWithFormat:@"%@",[dict valueForKey:@"image"]];
//            
//            if(imgurl.length>0)
//            {
//                object[@"image"] = @[
//                                     @{@"url": imgurl, @"user_generated" : @"false" }
//                                     ];
//            }
//            else
//            {
//                object[@"image"] = @[
//                                     @{@"url": Icon_PATH, @"user_generated" : @"false" }
//                                     ];
//            }
//            
//          //  object[@"link"] = @"www.apple.com";
//
//            object[@"description"] = [NSString stringWithFormat:@"%@",[dict valueForKey:@"comment"]];
//            
//            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>) [FBGraphObject graphObject];
//            [action setObject:object forKey:@"comment"];
//            [action setObject:@"www.apple.com" forKey:@"link"];
//
//            
//            FBOpenGraphActionParams *actionParam =[[FBOpenGraphActionParams alloc] init];
//            actionParam.actionType =@"amhappyapp:share";
//            actionParam.previewPropertyName = @"comment";
//            actionParam.action =action;
//            
//            if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:actionParam]) {
//                // Show the share dialog
//                [FBDialogs presentShareDialogWithOpenGraphAction:action
//                                                      actionType:@"amhappyapp:share"
//                                             previewPropertyName:@"comment"
//                                                         handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                                             if(error) {
//                                                                 // An error occurred, we need to handle the error
//                                                                 // See: https://developers.facebook.com/docs/ios/errors
//                                                                 NSLog(@"Error publishing story: %@", error.localizedDescription);
//                                                                 
//                                                                 [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Error occured while sharing"] AlertFlag:1 ButtonFlag:1];
//                                                             } else {
//                                                                 // Success
//                                                                 NSLog(@"result %@", results);
//                                                             }
//                                                         }];
//        }
    }
    }
   
    
}








#pragma mark - FBSDKSharingDelegate

- (void) sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    
    NSLog(@"Facebook sharing completed: %@", results);
    
       //[[[UIAlertView alloc]initWithTitle:nil message:@"Successfully Posted!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show ];
    
    
}

- (void) sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    
    NSLog(@"Facebook sharing failed: %@", error);
    
       // [[[UIAlertView alloc]initWithTitle:nil message:@"Failed posting!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show ];
}

- (void) sharerDidCancel:(id<FBSDKSharing>)sharer {
    
    NSLog(@"Facebook sharing cancelled.");
    
         //[[[UIAlertView alloc]initWithTitle:nil message:@"Cancel posting!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show ];
}


-(void)share2
{
   // NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
    
//     NSMutableDictionary <FBOpenGraphObject> *object =  [FBGraphObject openGraphObjectForPostWithType:@"amhappytest:event"                                                                                                       title:@"testing title"                                                                                                       image:nil                                                                                                         url:DeepLinkUrl                                                                                                 description:@""];
//    
//    object.provisionedForPost = YES;
//    object[@"title"] = @"Inspiration";
//    object[@"type"] = @"amhappytest:event";
//    object[@"description"] = @"Mazama Inspiration route on Goat Wall";
//    object[@"image"] = @[
//                         @{@"url": imageURL, @"user_generated" : @"false" }
//                         ];
//    
//    [FBSession openActiveSessionWithReadPermissions:@[@"publish_actions"]
//                                       allowLoginUI:YES
//                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//                                      
//                                      switch (state) {
//                                          case FBSessionStateOpen:
//                                          {
//                                              [FBSession setActiveSession:session];
//
//                                              [FBRequestConnection startForPostOpenGraphObject:object
//                                                                             completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                                                                 if(error) {
//                                                                                     NSLog(@"Error: %@", error);
//                                                                                 } else {
//                                                                                     NSLog(@"Success.  %@", result);
//                                                                                 }
//                                                                                 
//                                                                                 NSString* objectId = [result objectForKey:@"id"]; // read object ID from previous response
//                                                                                 id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
//                                                                                 [action setObject:objectId forKey:@"event"];
//                                                                                 
//                                                                                 [FBRequestConnection startForPostWithGraphPath:@"/me/amhappytest:attending"
//                                                                                                                    graphObject:action
//                                                                                                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                                                                                                  if(error) {
//                                                                                                                      NSLog(@"Error: %@", error);
//                                                                                                                  } else {
//                                                                                                                      NSLog(@"Success.  Created action with ID: %@", [result objectForKey:@"id"]);
//                                                                                                                      NSLog(@"See the story at: https://www.facebook.com/{your-vanity-url}/activity/%@", [result objectForKey:@"id"]);
//                                                                                                                  }
//                                                                                                              }];
//                                                                             } ];
//                                              
//                                              break;
//                                          }
//                                              
//                                          case FBSessionStateClosed:
//                                          {
//                                              
//                                          }
//                                          case FBSessionStateClosedLoginFailed:
//                                          {
//                                              
//                                              [FBSession.activeSession closeAndClearTokenInformation];
//                                              break;
//                                          }
//                                              
//                                          default:
//                                              break;
//                                      }
//                                      
//                                  } ];
    
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag==0)
    {

            if(buttonIndex==0)
            {
                
                NSLog(@"Facebook");
                
                 [self shareComom:shareDict ShareFlag:1];
                
            }
            else if(buttonIndex==1)
            {
                 NSLog(@"Whatsapp");
                
                [self shareEventOnWhatsApp:shareDict];
                
         
               
            }
            else
            {
                 NSLog(@"Cancel");
                
            }
       
    }
    
    
}

-(void)shareEventOnWhatsApp:(NSDictionary *)EventData
{
    
    if (!EventData)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Something Went Wrong!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
      
    }
    else{
        
        
        //NSLog(@"%@",EventData);
    
        if (isEventImage)
        {
            
            if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]])
            {
                
                UIImage     * iconImage = self.imgEvent.image;
                NSString    * savePath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.wai"];
                
                [UIImageJPEGRepresentation(iconImage, 1.0) writeToFile:savePath atomically:YES];
                
                documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
                documentInteractionController.UTI = @"net.whatsapp.image";
                documentInteractionController.delegate = self;
                
                [documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated: YES];
                
                
            } else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has no WhatsApp installed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
           
        }
        else
        {
            NSString * msg = [EventData valueForKey:@"name"];
            NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
            NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
                [[UIApplication sharedApplication] openURL: whatsappURL];
            } else {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has no WhatsApp installed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        }

        
//        if (EventData)
//        {
 
//            
//        }
//        else{
//            
//            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Something Went Wrong!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//        }
//        
     
    }
    
  
}

- (IBAction)shareTapped:(id)sender
{
    
    //***************** Verion 4 *************
    
    [self shareComom:shareDict ShareFlag:1];

    
//    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:[localization localizedStringForKey:@"Share"]
//                                  delegate:self
//                                  cancelButtonTitle:nil
//                                  destructiveButtonTitle:nil
//                                  otherButtonTitles:@"Facebook",@"Whatsapp",[localization localizedStringForKey:@"Cancel"], nil];
//    
//    
//    [actionSheet setTag:0];
//    
//    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
//    [actionSheet showInView:self.view];
    
    
    
    
    //***************** Verion 3 *************
    
    
    
    
       // [self shareComom:shareDict ShareFlag:1];
    
    
    
    
   // [self shareApp];
    

    
    /*if(self.imgEvent.image && isEventImage)
    {
        self.imgShareBig.image =self.imgEvent.image ;
        self.shareImageView.hidden=NO;
        isEventShare =YES;
    }
    else
    {
        if(self.lbldesc.text.length>0)
        {
            if([DELEGATE connectedToNetwork])
            {
     
            }

        }
        else
        {
            [DELEGATE showalert:self Message:@"There is no event image or description to share" AlertFlag:1 ButtonFlag:1];
        }
    }*/
    
    
    
   
   
    
}
-(void)shareApp
{
    [self shareText:@"AmHappy" andImage:self.imgEvent.image andUrl:[NSURL URLWithString:@"Apple.com"] Description:@"Shared via AmHappy"];
}
- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url Description:(NSString *)description
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    if (description) {
        [sharingItems addObject:description];
    }
  //  UIImage *imagelogo =[UIImage imageNamed:@"mapIconBlack.png"];
   // [sharingItems addObject:imagelogo];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        //  NSLog(@"%f",self.view.frame.size.width/2);
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentViewController:activityController animated:YES completion:nil];

    }
}
- (IBAction)priceTapped:(id)sender {
}

- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)yesTapped:(id)sender
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc attendEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Is_attend:@"Y" Sel:@selector(responseAttending:)];
        attendingTag =1;
      
    }
}
- (IBAction)maybeTapped:(id)sender
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc attendEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Is_attend:@"M" Sel:@selector(responseAttending:)];
        attendingTag =2;
       
    }
}
-(void)responseAttending:(NSDictionary *)results
{
   // NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(attendingTag ==1)
        {
            attendingCount =attendingCount+1;
            self.lblCount.text =[NSString stringWithFormat:@"%d %@",attendingCount,[localization localizedStringForKey:@"people attending"]];
            
            [self.btnYes setBackgroundImage:[UIImage imageNamed:@"yesGreen.png"] forState:UIControlStateNormal];
            [self.btnMaybe setBackgroundImage:[UIImage imageNamed:@"maybeBlank.png"] forState:UIControlStateNormal];
            [self.btnYes setUserInteractionEnabled:NO];
            [self.btnMaybe setUserInteractionEnabled:YES];

        }
        else if (attendingTag==2)
        {
            if(attendingCount !=0)
            {
                attendingCount =attendingCount-1;
                self.lblCount.text =[NSString stringWithFormat:@"%d %@",attendingCount,[localization localizedStringForKey:@"people attending"]];
            }
           
            [self.btnYes setBackgroundImage:[UIImage imageNamed:@"yesBlank.png"] forState:UIControlStateNormal];
            [self.btnMaybe setBackgroundImage:[UIImage imageNamed:@"maybeGreen.png"] forState:UIControlStateNormal];
            [self.btnMaybe setUserInteractionEnabled:NO];
            [self.btnYes setUserInteractionEnabled:YES];

        }
        attendingTag =-1;
        
    }
 
}


- (IBAction)cameraTapped:(id)sender
{
    [self.view endEditing:YES];
    
   // [self.viewAddImages setHidden:NO];
    
    
    
    
//    if (isShowAddPhotos)
//    {
//        isShowAddPhotos = NO;
//        
//        [self hideAddImagesPreview];
//     
//    }
//    else
//    {
//        
//        isShowAddPhotos = YES;
//        
//        [self setUpAddimagesPreview];
//        
//        [self ShowAddImagesPreview];
//     
//    }

    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
    [alert show];
    
    pickerController = [[UIImagePickerController alloc]
                        init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    
    
}
-(CGSize)imageSizeAfterAspectFit:(UIImageView*)imgview{
    
    
    float newwidth;
    float newheight;
    
    UIImage *image=imgview.image;
    
    if (image.size.height>=image.size.width){
        newheight=imgview.frame.size.height;
        newwidth=(image.size.width/image.size.height)*newheight;
        
        if(newwidth>imgview.frame.size.width){
            float diff=imgview.frame.size.width-newwidth;
            newheight=newheight+diff/newheight*newheight;
            newwidth=imgview.frame.size.width;
        }
        
    }
    else{
        newwidth=imgview.frame.size.width;
        newheight=(image.size.height/image.size.width)*newwidth;
        
        if(newheight>imgview.frame.size.height){
            float diff=imgview.frame.size.height-newheight;
            newwidth=newwidth+diff/newwidth*newwidth;
            newheight=imgview.frame.size.height;
        }
    }
    
    NSLog(@"image after aspect fit: width=%f height=%f",newwidth,newheight);
    
    
    //adapt UIImageView size to image size
    //imgview.frame=CGRectMake(imgview.frame.origin.x+(imgview.frame.size.width-newwidth)/2,imgview.frame.origin.y+(imgview.frame.size.height-newheight)/2,newwidth,newheight);
    
    return CGSizeMake(newwidth, newheight);
    
}


-(void)ShowAddImagesPreview:(NSMutableArray *)images
{
    [self.imgCommentPre setHidden:YES];
    
    [self.viewAddImages setHidden:NO];
    

    float height =self.viewAddImages.frame.size.height;
    
    
     self.commentView.frame = CGRectMake(self.commentView.frame.origin.x, self.commentView.frame.origin.y, self.commentView.frame.size.width, commentViewHeight+height+15);
    
     self.viewAddImages.frame =CGRectMake(self.commentView.frame.origin.x, 100, self.commentView.frame.size.width, height);

   
    self.tableViewComment.frame = CGRectMake(self.tableViewComment.frame.origin.x, self.commentView.frame.origin.y+self.commentView.frame.size.height, self.tableViewComment.frame.size.width, self.tableViewComment.frame.size.height);
  
    [self.scrollviewMain setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, self.scrollviewMain.contentSize.height+height+50)];
    
    int imageWidth = (self.viewAddImages.frame.size.width - 40)/5;
    
    self.image1.layer.cornerRadius = imageWidth/2;
    self.image2.layer.cornerRadius = imageWidth/2;
    self.image3.layer.cornerRadius = imageWidth/2;
    self.image4.layer.cornerRadius = imageWidth/2;
    self.image5.layer.cornerRadius = imageWidth/2;
    
    
    self.image1.contentMode = UIViewContentModeScaleAspectFill;
    self.image2.contentMode = UIViewContentModeScaleAspectFill;
    self.image3.contentMode = UIViewContentModeScaleAspectFill;
    self.image4.contentMode = UIViewContentModeScaleAspectFill;
    self.image5.contentMode = UIViewContentModeScaleAspectFill;
    
    self.image1.clipsToBounds = YES;
    self.image2.clipsToBounds = YES;
    self.image3.clipsToBounds = YES;
    self.image4.clipsToBounds = YES;
    self.image5.clipsToBounds = YES;
    
    
    if ([images count]>0)
    {

        for (int i = 0; i < [images count]; i++)
        {
    
            switch (i)
            {
                case 0:
                    
                    [self.image1 setImage:[self compressImage:[images objectAtIndex:i]] forState:UIControlStateNormal];
                    
                    imgData =UIImageJPEGRepresentation([self compressImage:[images objectAtIndex:i]], 1.0);

                    break;
                    
                case 1:
                    
                    [self.image2 setImage:[self compressImage:[images objectAtIndex:i]] forState:UIControlStateNormal];
                    
                     imgData2 =UIImageJPEGRepresentation([self compressImage:[images objectAtIndex:i]], 1.0);
                    
                    break;
                    
                    
                case 2:
                    
                    [self.image3 setImage:[self compressImage:[images objectAtIndex:i]] forState:UIControlStateNormal];
                    
                    imgData3 =UIImageJPEGRepresentation([self compressImage:[images objectAtIndex:i]], 1.0);
                    
                    break;
                    
                    
                case 3:
                    
                    [self.image4 setImage:[self compressImage:[images objectAtIndex:i]] forState:UIControlStateNormal];
                    
                    imgData4 =UIImageJPEGRepresentation([self compressImage:[images objectAtIndex:i]], 1.0);
                    
                    break;
                    
                    
                case 4:
                    
                    [self.image5 setImage:[self compressImage:[images objectAtIndex:i]] forState:UIControlStateNormal];
                    
                    imgData5 =UIImageJPEGRepresentation([self compressImage:[images objectAtIndex:i]], 1.0);
                    
                    break;
            
                    
                default:
                    break;
            }
         
        }
      
    }
 
}



-(void)hideAddImagesPreview
{
    
    [self.viewAddImages setHidden:YES];
    [self.imgCommentPre setHidden:YES];
    
    imgData = nil;
    imgData2 = nil;
    imgData3 = nil;
    imgData4 = nil;
    imgData5 = nil;

    [self.image1 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
    [self.image2 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
    [self.image3 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
    [self.image4 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
    [self.image5 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];

 
    self.commentView.frame = CGRectMake(self.commentView.frame.origin.x, self.commentView.frame.origin.y, self.commentView.frame.size.width, commentViewHeight);
    
    self.tableViewComment.frame = CGRectMake(self.tableViewComment.frame.origin.x, self.commentView.frame.origin.y+self.commentView.frame.size.height, self.tableViewComment.frame.size.width, self.tableViewComment.frame.size.height);
  
    
    [self.scrollviewMain setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, self.scrollviewMain.contentSize.height-(self.viewAddImages.frame.size.height+50))];

    
}




-(void)getImageforPreview
{
    ischanged=YES;
   // float height =self.imgCommentPre.image.size.height;
    
     float height =self.imgCommentPre.image.size.height;
    
    if(height<self.imgCommentPre.bounds.size.width)
    {
       // CGSize size1 =[self imageSizeAfterAspectFit:self.imgCommentPre];
       // height =size1.height;
        
        height =self.imgCommentPre.image.size.height;
    }
    else
    {
        height =(self.view.bounds.size.width / self.imgCommentPre.image.size.width) * self.imgCommentPre.image.size.height;
    }

   // CGFloat correctImageViewHeight = (self.view.bounds.size.width / self.imgCommentPre.image.size.width) * self.imgCommentPre.image.size.height;

   // CGSize size1 =[self imageSizeAfterAspectFit:self.imgCommentPre];
   
    self.commentView.frame = CGRectMake(self.commentView.frame.origin.x, self.commentView.frame.origin.y, self.commentView.frame.size.width, commentViewHeight+height+15);
  
    if(self.imgCommentPre.image)
    {
         [self.imgCommentPre sizeToFit];
        self.imgCommentPre.frame =CGRectMake(self.commentView.frame.origin.x+10, 100, self.commentView.frame.size.width-20, height);
        
       
    }
    
    self.tableViewComment.frame = CGRectMake(self.tableViewComment.frame.origin.x, self.commentView.frame.origin.y+self.commentView.frame.size.height, self.tableViewComment.frame.size.width, self.tableViewComment.frame.size.height);
    
    [self.imgCommentPre setHidden:NO];

    [self.scrollviewMain setContentSize:CGSizeMake(320, self.scrollviewMain.contentSize.height+self.imgCommentPre.frame.size.height+50)];

}


-(void)hideImageforPreview
{
    ischanged=NO;
    
   // float height =self.imgCommentPre.image.size.height;

    self.commentView.frame = CGRectMake(self.commentView.frame.origin.x, self.commentView.frame.origin.y, self.commentView.frame.size.width, commentViewHeight);
   self.tableViewComment.frame = CGRectMake(self.tableViewComment.frame.origin.x, self.commentView.frame.origin.y+self.commentView.frame.size.height, self.tableViewComment.frame.size.width, self.tableViewComment.frame.size.height);
    [self.imgCommentPre setHidden:NO];
    [self.scrollviewMain setContentSize:CGSizeMake(320, self.scrollviewMain.contentSize.height-self.imgCommentPre.frame.size.height+50)];
//    if(IS_Ipad)
//    {
//        [self.scrollviewMain setContentSize:CGSizeMake(320, 1500)];
//    }
//    else
//    {
//        [self.scrollviewMain setContentSize:CGSizeMake(320, 1050)];
//    }

}
- (UIImage *)compressImage:(UIImage *)image {
    
    float maxHeight = 1600.0; //new max. height for image
    float maxWidth = 1200.0; //new max. width for image
  
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5; //50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
   // NSLog(@"Actual height : %f and Width : %f",actualHeight,actualWidth);
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
    
}
- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGRect)frame {
   
     
     // drawing code comes here- look at CGContext reference
     // for available operations
     // this example draws the inputImage into the context
    
    
    float widthRatio = frame.size.width / image.size.width;
    float heightRatio = frame.size.height / image.size.height;
    float scale = MAX(widthRatio, heightRatio);
    float imageWidth = scale * image.size.width;
    float imageHeight = scale * image.size.height;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageWidth, imageHeight), YES, 0.0);
    
    // get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // push context to make it current
    // (need to do this manually because we are not drawing in a UIView)
    UIGraphicsPushContext(context);
    
    CGRect rect =CGRectMake(0, 0, imageWidth, imageHeight);
    [image drawInRect:rect];
     
     // pop context
     UIGraphicsPopContext();
     
     // get a UIImage from the image context- enjoy!!!
     UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
     
     // clean up drawing environment
     UIGraphicsEndImageContext();
     return outputImage;
    
    
    
}

#pragma mark ----------- ImagePicker Delegate -----------------


- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{

    if(image)
    {
 
        if (gettedImages != nil)
        {
            for (int i = 0; i < [gettedImages count]; i++)
            {
                [self.multipleImagePicker addImage:(UIImage *)[gettedImages objectAtIndex:i]];
                
            }
            
        }
        
       [self.multipleImagePicker addImage:[self compressImage:image]];
            
       
        // Done callback
        self.multipleImagePicker.doneCallback = ^(NSArray *images)
        {
            
            NSLog(@"Images: %@", images);
            
        };
        
        // Show RPMultipleImagePickerViewController
        
        [self.multipleImagePicker setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:self.multipleImagePicker animated:YES];
        
        
//        switch (CurrentIndex)
//        {
//            case 0:
//                
//                  [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Something Went Wrong."] AlertFlag:1 ButtonFlag:1];
//                
//                break;
//                
//            case 1:
//                
//                [self.image1 setImage:image forState:UIControlStateNormal];
//                
//                imgData =UIImageJPEGRepresentation([self compressImage:image], 1.0);
//                
//             
//                break;
//                
//                
//            case 2:
//                
//                 [self.image2 setImage:image forState:UIControlStateNormal];
//                
//                imgData2 =UIImageJPEGRepresentation([self compressImage:image], 1.0);
//                
//                break;
//                
//            case 3:
//                
//                [self.image3 setImage:image forState:UIControlStateNormal];
//                
//                imgData3 =UIImageJPEGRepresentation([self compressImage:image], 1.0);
//                
//                break;
//                
//            case 4:
//                
//                [self.image4 setImage:image forState:UIControlStateNormal];
//                
//                imgData4 =UIImageJPEGRepresentation([self compressImage:image], 1.0);
//                
//                break;
//                
//            case 5:
//                
//                [self.image5 setImage:image forState:UIControlStateNormal];
//                imgData5 =UIImageJPEGRepresentation([self compressImage:image], 1.0);
//                
//                break;
//                
//            default:
//                
//                
//                break;
//        }
        
        
 
//        self.imgCommentPre.image =[self drawImage2:[self compressImage:image] inRect:self.imgCommentPre.bounds];
//        
//       // self.imgCommentPre.image =image;
//
//        
//        NSData *data =UIImagePNGRepresentation(image);
//        NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)data.length/1024/1024);
//        
//       
//        imgData =UIImageJPEGRepresentation([self compressImage:image], 1.0);
//       // imgData =UIImageJPEGRepresentation(image, 1.0);
//
//      
//
//      // imgData = UIImagePNGRepresentation([self compressImage:image]);
//        
//        NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)imgData.length/1024/1024);
//
//        
//       // imgData = UIImagePNGRepresentation(image);
//
//        
//        if(!ischanged)
//        {
//            [self getImageforPreview];
//        }

    }
    else
    {
        if(ischanged)
        {
            if(self.imgCommentPre.image==nil)
            {
                [self hideImageforPreview];
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];

   // [self callImage:image];
    
}
-(void)callImage:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 270, 250)];
    
    // imageView.contentMode=UIViewContentModeCenter;
    [imageView setImage:image];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 250)];
    [v addSubview:imageView];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"AmHappy"
                                          message:[localization localizedStringForKey:@"Select Image"]
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController.view setBounds:CGRectMake(0, 00, self.view.frame.size.width, 400)];

   
    
    // alertController.frame = CGRectMake(60, 80, 150, 180);
    
    
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:[localization localizedStringForKey:@"Cancel"]
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       imgData = nil;

                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:[localization localizedStringForKey:@"Ok"]
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    [alertController.view addSubview:v];
    //[alertController setValue:v forKey:@"contentViewController"];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)openMultipleImagePicker
{
    
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    
    if (gettedImages != nil)
    {
        if ([gettedImages count]>=5)
        {
    
            if (gettedImages != nil)
            {
                for (int i = 0; i < [gettedImages count]; i++)
                {
                    [self.multipleImagePicker addImage:(UIImage *)[gettedImages objectAtIndex:i]];
                    
                }
                
            }
            
            // Done callback
            self.multipleImagePicker.doneCallback = ^(NSArray *images)
            {
                
                NSLog(@"Images: %@", images);
                
            };
            
            // Show RPMultipleImagePickerViewController
            
            [self.multipleImagePicker setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:self.multipleImagePicker animated:YES];

            
        }
        else{
            
            elcPicker.maximumImagesCount = 5 - [gettedImages count];
            
            //Set the maximum number of images to select to 100
            elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
            elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
            elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
            elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
            
            elcPicker.imagePickerDelegate = self;
            
            [self presentViewController:elcPicker animated:YES completion:nil];
            
        }
       
    }
    else{
        
        elcPicker.maximumImagesCount = 5;
        
        //Set the maximum number of images to select to 100
        elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
        elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
        elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
        elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
        
        elcPicker.imagePickerDelegate = self;
        
        [self presentViewController:elcPicker animated:YES completion:nil];
        
    }
 
    


}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==5)
    {
        if(buttonIndex==alertView.cancelButtonIndex)
        {
            imgData=nil;
        }
    }
    else
    {
        if(buttonIndex == 2)
        {
            
            
            [self openMultipleImagePicker];
            
//            ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
//            
//            int RemainCount = 0;
//            
//            if (imgData == nil)
//            {
//                RemainCount++;
//            }
//            if (imgData2 == nil)
//            {
//                RemainCount++;
//            }
//            if (imgData3 == nil)
//            {
//                RemainCount++;
//            }
//            if (imgData4 == nil)
//            {
//                RemainCount++;
//            }
//            if (imgData5 == nil)
//            {
//                RemainCount++;
//            }
//            
//            elcPicker.maximumImagesCount = RemainCount; //Set the maximum number of images to select to 100
//            elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
//            elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
//            elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
//            elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
//            
//            elcPicker.imagePickerDelegate = self;
//            
//            [self presentViewController:elcPicker animated:YES completion:nil];
            
           // pickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
            // [self presentModalViewController:pickerController animated:YES];
            //[self presentViewController:pickerController animated:YES completion:nil];
        }
        else if(buttonIndex == 1)
        {
            
            if (gettedImages != nil)
            {
                
                if ([gettedImages count]>=5)
                {
                    
                    
                    if (gettedImages != nil)
                    {
                        for (int i = 0; i < [gettedImages count]; i++)
                        {
                            [self.multipleImagePicker addImage:(UIImage *)[gettedImages objectAtIndex:i]];
                            
                        }
                        
                    }
                    
                    // Done callback
                    self.multipleImagePicker.doneCallback = ^(NSArray *images)
                    {
                        
                        NSLog(@"Images: %@", images);
                        
                    };
                    
                    // Show RPMultipleImagePickerViewController
                    
                    [self.multipleImagePicker setHidesBottomBarWhenPushed:YES];
                    [self.navigationController pushViewController:self.multipleImagePicker animated:YES];
                    
                    
                    
                }
                else{
                    
                    pickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
                    //  [self presentModalViewController:pickerController animated:YES];
                    [self presentViewController:pickerController animated:YES completion:nil];

                }
                
            }
            else{
                
                pickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
                //  [self presentModalViewController:pickerController animated:YES];
                [self presentViewController:pickerController animated:YES completion:nil];
                
            }
            
            
            
        }
        else if(buttonIndex == 3)
        {
          
            switch (CurrentIndex)
            {
                case 0:
                    
                    [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Something Went Wrong."] AlertFlag:1 ButtonFlag:1];
                    
                    break;
                    
                case 1:
                    
                    [self.image1 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
                    
                    imgData = nil;
                    
                    
                    break;
                    
                    
                case 2:
                    
                    [self.image2 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
                    
                    imgData2 = nil;
                    
                    break;
                    
                case 3:
                    
                    [self.image3 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
                    
                    imgData3 = nil;
                    
                    break;
                    
                case 4:
                    
                    [self.image4 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
                    
                    imgData4 = nil;
                    
                    break;
                    
                case 5:
                    
                    [self.image5 setImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
                    imgData5 = nil;
                    break;
                    
                default:
                    
                    
                    break;
            }
            
            
        }
       
    }
    
    
}
- (double) GetUTCDateTimeFromLocalTime:(NSDate *)IN_strLocalTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd'/'MM'/'yyyy hh:mm:ss"];
    // NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *strDateTime   = [dateFormatter stringFromDate:IN_strLocalTime];
    NSDate *objUTCDate  = [dateFormatter dateFromString:strDateTime];
    double seconds = (long long)([objUTCDate timeIntervalSince1970] );
    
    NSString *strTimeStamp = [NSString stringWithFormat:@"%f",seconds];
    NSLog(@"The Timestamp is = %@",strTimeStamp);
    return seconds;
}

-(BOOL)commentValidatation
{
    
    NSString *strComment =[self.txtComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([strComment isEqualToString:[localization localizedStringForKey:@"Comment"]])
    {
        strComment=@"";
    }
    
    if(![strComment length]>0 && imgData == nil)
    {
     
          [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter comment or select an image."] AlertFlag:1 ButtonFlag:1];
        
        return NO;
    }
 
    return YES;
    
    
}

-(NSString *)encodeCommentString:(NSString *)comment
{

   NSMutableString *commentText = [[NSMutableString alloc]initWithString:comment];
    
    NSScanner *scanner = [NSScanner scannerWithString:commentText];
    [scanner scanUpToString:@"@" intoString:nil]; // Scan all characters before #
    while(![scanner isAtEnd])
    {
        NSString *substring = nil;
        [scanner scanString:@"@" intoString:nil]; // Scan the # character
        if([scanner scanUpToString:@" " intoString:&substring]) {
            // If the space immediately followed the #, this will be skipped
            
            //[substrings addObject:substring];
            
            NSRange range = [commentText rangeOfString:substring];
            
            NSLog(@"%@",NSStringFromRange(range));
            
            
            
            
            
            for (int i = 0; i < arrayToTag.count; i++)
            {
                
                if ([[[arrayToTag objectAtIndex:i]valueForKey:@"tag_name"]isEqualToString:substring])
                {

                    commentText = [[commentText stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%@$",[[arrayToTag objectAtIndex:i]valueForKey:@"id"]]] mutableCopy];
                    
                    [taggedUsers addObject:[[arrayToTag objectAtIndex:i]valueForKey:@"id"]];
                
                }
                
            }
            
        }
        [scanner scanUpToString:@"@" intoString:nil]; // Scan all characters before next #
    }
    // do something with substrings
    
    
    NSLog(@"%@",commentText);
    return commentText;

    
}

-(NSAttributedString *)DecodeCommentString:(NSString *)comment usersTagged:(NSMutableArray *)usersTagged
{
    
    NSMutableString *commentText = [[NSMutableString alloc]initWithString:comment];
    
    NSScanner *scanner = [NSScanner scannerWithString:commentText];
    [scanner scanUpToString:@"@" intoString:nil]; // Scan all characters before @
    while(![scanner isAtEnd])
    {
        NSString *substring = nil;
        [scanner scanString:@"@" intoString:nil];
        
        // Scan the @ character
        if([scanner scanUpToString:@" " intoString:&substring])
        {
            // If the space immediately followed the @, this will be skipped
            
            //[substrings addObject:substring];
            
            //NSLog(@"%@",[substring substringFromIndex:[substring length] - 1]);
            
            if ([[substring substringFromIndex:[substring length] - 1] isEqualToString:@"$"])
            {
                
                substring = [substring substringToIndex:[substring length] - 1];
                
                NSRange range = [commentText rangeOfString:substring];
                
                NSLog(@"%lu",(unsigned long)range.location);
                
                
                range.location = range.location - 1;
                
                range.length = range.length+2;
                
               // NSLog(@"%@",NSStringFromRange(range));
                
                for (int i = 0; i < usersTagged.count; i++)
                {
                    
                    if ([[[[usersTagged objectAtIndex:i]valueForKey:@"id"] description]isEqualToString:substring])
                    {
                        
                        commentText = [[commentText stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%@%@%@",@"%0C%L",[[usersTagged objectAtIndex:i]valueForKey:@"username"],@"%c%l"]] mutableCopy];
                        
                        [UserToHighlight addObject:[NSString stringWithFormat:@"%@",[[usersTagged objectAtIndex:i]valueForKey:@"username"]]];
                        
                        break;
                        
                    }
                    
                }
                
                
            }
            
        }
        [scanner scanUpToString:@"@" intoString:nil]; // Scan all characters before next #
    }
    // do something with substrings
    
    
   // NSLog(@"%@",commentText);
    
   // NSLog(@"%@",[formatter formatString:commentText]);
    
    return [formatter formatString:commentText];
    
}


//-(NSAttributedString *)DecodeCommentString:(NSString *)comment usersTagged:(NSMutableArray *)usersTagged
//{
//
//    NSMutableString *commentText = [[NSMutableString alloc]initWithString:comment];
//    
//    NSScanner *scanner = [NSScanner scannerWithString:commentText];
//    [scanner scanUpToString:@"@" intoString:nil]; // Scan all characters before @
//    while(![scanner isAtEnd])
//    {
//        NSString *substring = nil;
//        [scanner scanString:@"@" intoString:nil];
//    
//        // Scan the @ character
//        if([scanner scanUpToString:@"$" intoString:&substring])
//        {
//
//            // If the space immediately followed the @, this will be skipped
//            
//            //[substrings addObject:substring];
//            
//            NSRange range = [commentText rangeOfString:substring];
//            
//           // NSLog(@"%lu",(unsigned long)range.location);
//  
// 
//            
////            for(int i = 0; i < substring.length
////                ; ++i)
////            {
////               
////                //do something with current...
////                  NSString *strComment =[[NSString stringWithFormat:@"%hu",[substring characterAtIndex:i]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
////                
////                
////                if ([strComment isEqualToString:@""])
////                {
////                    
////                    NSLog(@"whiteSpace");
////                }
////                else{
////                    
////                     NSLog(@"%@",[NSString stringWithFormat:@"%hu",[substring characterAtIndex:i]]);
////                    
////                }
////                
////                
////                
////            }
//            
//            range.location = range.location - 1;
//       
//            range.length = range.length + 2;
//            
//           // NSLog(@"%@",NSStringFromRange(range));
//            
//            for (int i = 0; i < usersTagged.count; i++)
//            {
//                
//                if ([[[[usersTagged objectAtIndex:i]valueForKey:@"id"] description]isEqualToString:substring])
//                {
//
//                    commentText = [[commentText stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%@%@%@",@"%0C%L",[[usersTagged objectAtIndex:i]valueForKey:@"username"],@"%c%l"]] mutableCopy];
//                    
//                    [UserToHighlight addObject:[NSString stringWithFormat:@"%@",[[usersTagged objectAtIndex:i]valueForKey:@"username"]]];
//                    
//                    break;
//     
//                }
//                
//            }
//            
//        }
//        [scanner scanUpToString:@"@" intoString:nil]; // Scan all characters before next #
//    }
//    // do something with substrings
//    
//    
//    NSLog(@"%@",commentText);
//    
//    NSLog(@"%@",[formatter formatString:commentText]);
//    
//    return [formatter formatString:commentText];
//
//}


- (IBAction)postTapped:(id)sender
{
    [self.view endEditing:YES];
    NSString *strComment =[self.txtComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([strComment isEqualToString:[localization localizedStringForKey:@"Comment"]])
    {
        strComment=@"";
    }
 
    if([self commentValidatation])
    {

        //********* change comment text with friends here and send it to backend

        //NSString *commentText = self.txtComment.text;
        
        
       // NSLog(@"%@",[localization localizedStringForKey:@"Comment"]);
        
        NSString *commentText =[self.txtComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([commentText isEqualToString:[localization localizedStringForKey:@"Comment"]])
        {
            commentText=@"";
            taggedUsers = [[NSMutableArray alloc]init];
        }
        else{
            
            commentText = [commentText stringByAppendingString:@" "];
            
            taggedUsers = [[NSMutableArray alloc]init];
            
            commentText = [self encodeCommentString:commentText];
      
        }
        
        
        
        NSLog(@"%@",taggedUsers);
        
        if(DELEGATE.connectedToNetwork)
        {
            
            if (imgData)
            {
                if (imgData2||imgData3||imgData4||imgData5)
                {
      
                        [mc addComment:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Time:[NSString stringWithFormat:@"%f",[self GetUTCDateTimeFromLocalTime:[NSDate date]]] Comment:commentText Image:imgData is_multiple:@"Y" image2:imgData2 image3:imgData3 image4:imgData4 image5:imgData5 comment_tags:[taggedUsers count]>0?[NSString stringWithFormat:@"%@",[taggedUsers componentsJoinedByString:@","]]:nil Sel:@selector(responseComment:)];
                        
                
                    
                }
                else{
              
                    [mc addComment:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Time:[NSString stringWithFormat:@"%f",[self GetUTCDateTimeFromLocalTime:[NSDate date]]] Comment:commentText Image:imgData is_multiple:@"N" image2:imgData2 image3:imgData3 image4:imgData4 image5:imgData5 comment_tags:[taggedUsers count]>0?[NSString stringWithFormat:@"%@",[taggedUsers componentsJoinedByString:@","]]:nil Sel:@selector(responseComment:)];
                    
                    
                }
                
            }
            else{
                
                [mc addComment:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Time:[NSString stringWithFormat:@"%f",[self GetUTCDateTimeFromLocalTime:[NSDate date]]] Comment:commentText Image:imgData is_multiple:nil image2:imgData2 image3:imgData3 image4:imgData4 image5:imgData5  comment_tags:[taggedUsers count]>0?[NSString stringWithFormat:@"%@",[taggedUsers componentsJoinedByString:@","]]:nil Sel:@selector(responseComment:)];
                
                
            }
     
           // [mc addComment:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Time:[NSString stringWithFormat:@"%f",[self GetUTCDateTimeFromLocalTime:[NSDate date]]] Comment:strComment Image:imgData Sel:@selector(responseComment:)];
        }
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please enter comment or select an image."] AlertFlag:1 ButtonFlag:1];

     
    }
}
-(void)responseComment:(NSDictionary *)results
{
     NSLog(@"result is %@",results);
    
    gettedImages = nil;
 
    
    [self hideAddImagesPreview];
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
     {
         if(imgData !=nil)
         {
             self.imgCommentPre.image =nil;
             [self.imgCommentPre setHidden:YES];
             [self hideImageforPreview];
             
          
             
             
         }
         self.txtComment.textColor = [UIColor colorWithRed:(191/255.f) green:(191/255.f) blue:(191/255.f) alpha:1.0f];
         [self.txtComment setText:[localization localizedStringForKey:@"Comment"]];         imgData=nil;
         start =0;
         [commentArray removeAllObjects];
         [self callComment];
     }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
   
    }
  
}
-(void)callComment
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc getCommentList:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Start:[NSString stringWithFormat:@"%d",start] Limit1:LimitComment Sel:@selector(responseListComment:)];
    }
}
-(void)responseListComment:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
       // [commentArray removeAllObjects];
        [commentArray addObjectsFromArray:[results valueForKey:@"Comment"]];

        if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
        {
             isLast =YES;
        }
        else
        {
            isLast =NO;
        }
        [self.tableViewComment reloadData];
        if (commentArray.count>0)
        {
            [self.tableViewComment scrollsToTop];
          //  NSIndexPath *iPath = [NSIndexPath indexPathForRow:commentArray.count-1 inSection:0];
            
           // [self.tableViewComment scrollToRowAtIndexPath:iPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
       // [self.scrollviewMain setContentSize:CGSizeMake(320, 1080)];
        if(commentArray.count>2)
        {
            if(IS_Ipad)
            {
                [self.tableViewComment layoutIfNeeded];
                CGSize tableViewSize=self.tableViewComment.contentSize;
                self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
                
                [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
                //[self.scrollviewMain setContentSize:CGSizeMake(320, 1500)];
            }
            else
            {
                [self.tableViewComment layoutIfNeeded];
                CGSize tableViewSize=self.tableViewComment.contentSize;
                 self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
                [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
               // [self.scrollviewMain setContentSize:CGSizeMake(320, 1080)];
            }
        }
        else
        {
            if(IS_Ipad)
            {
                [self.tableViewComment layoutIfNeeded];
                CGSize tableViewSize=self.tableViewComment.contentSize;
                 self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
                [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
               // [self.scrollviewMain setContentSize:CGSizeMake(320, 1450)];
            }
            else
            {
                [self.tableViewComment layoutIfNeeded];
                CGSize tableViewSize=self.tableViewComment.contentSize;
                 self.tableViewComment.frame =CGRectMake(self.tableViewComment.frame.origin.x, self.tableViewComment.frame.origin.y, self.tableViewComment.frame.size.width, tableViewSize.height);
                [self.scrollviewMain setContentSize:CGSizeMake(320, self.tableViewComment.frame.origin.y+tableViewSize.height)];
               // [self.scrollviewMain setContentSize:CGSizeMake(320, 950)];
            }
        }
        
        
    
    }
    
    
}
-(void)ok1BtnTapped:(UIButton *)sender
{
    // NSLog(@"ok1BtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];
    
    if(sender.tag==151)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
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

- (IBAction)downLoadTapped:(id)sender
{
   
    
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:[self.imgShareBig.image CGImage] orientation:(ALAssetOrientation)[self.imgShareBig.image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error)
     {
         if (error) {
             [DELEGATE showalert:self Message:error.localizedDescription AlertFlag:1 ButtonFlag:1];
             // TODO: error handling
         } else {
             
             [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Image Saved to Gallery"] AlertFlag:1 ButtonFlag:1];
             
             // TODO: success handling
         }
     }];
}
- (IBAction)reportTapped:(id)sender
{
    if(isReported)
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"You have already reported this event"] AlertFlag:1 ButtonFlag:1];
    }
    else
    {
        [DELEGATE showalertNew:self Message:[localization localizedStringForKey:@"Are you sure, you want to report this event?"] AlertFlag:1];
    }
    
    
}
- (void)inviteBtnTapped:(UIButton *)sender
{
    [[self.view viewWithTag:191] removeFromSuperview];
  
    
    if(sender.tag==5)
    {
        popupTag =-1;
        [self.tableViewComment reloadData];
        
        if(DELEGATE.connectedToNetwork)
        {
            [mc reportComment:[USER_DEFAULTS valueForKey:@"userid"] Comment_id:[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:reportCommentId] valueForKey:@"id"]] Sel:@selector(responseReportComments:)];
        }
    }
    else if(sender.tag==10)
    {
        popupTag =-1;
        [self deleteCommentt:[NSString stringWithFormat:@"%@",[[commentArray objectAtIndex:deleteTag] valueForKey:@"id"]]];
    }
    else
    {
        if(DELEGATE.connectedToNetwork)
        {
            [mc reportEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:self.eventID Sel:@selector(responseReportEvent:)];
        }
    }
    
    
}
- (void)laterBtnTapped:(id)sender
{
    [[self.view viewWithTag:191] removeFromSuperview];
    
    
}
-(void)responseReportEvent:(NSDictionary *)results
{
    // NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [DELEGATE showalert:self Message:@"123" AlertFlag:1 ButtonFlag:1];
       // [self.navigationController popViewControllerAnimated:YES];
    }
    
}


- (IBAction)timeTapped:(id)sender
{
}
- (IBAction)photoTapped:(id)sender
{
    EventPhotoViewController *eventPhoto =[[EventPhotoViewController alloc] initWithNibName:@"EventPhotoViewController" bundle:nil];
    eventPhoto.eventID=[NSString stringWithFormat:@"%@",self.eventID];
    eventPhoto.eventName=[NSString stringWithFormat:@"%@",self.lblEventName.text];
    eventPhoto.eventUrl=[NSString stringWithFormat:@"%@",eventThumbImageURL];
    
    [self.navigationController pushViewController:eventPhoto animated:YES];
}
- (IBAction)likeEventTapped:(id)sender
{
    if(DELEGATE.connectedToNetwork)
    {
        [mc likeEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:[NSString stringWithFormat:@"%@",self.eventID] Is_like:(isEventLiked)?@"N":@"Y" Sel:@selector(responseLikeEvent:)];
    }
   
}
-(void)responseLikeEvent:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if(isEventLiked)
        {
            isEventLiked =NO;
            likeCount = likeCount-1;
            [self.btnLikeEvent setImage:[UIImage imageNamed:@"eventLike1.png"] forState:UIControlStateNormal];
        }
        else
        {
            isEventLiked =YES;
            likeCount = likeCount+1;
            [self.btnLikeEvent setImage:[UIImage imageNamed:@"eventLike2.png"] forState:UIControlStateNormal];


        }
        self.lblLikeEvent.text =[NSString stringWithFormat:@"%d",likeCount];

    }
}
- (IBAction)clickRepost:(id)sender
{
    
    EventTabViewController *eventTabVC =[[EventTabViewController alloc] initWithNibName:@"EventTabViewController" bundle:nil];
    [eventTabVC setIsRepost:YES];
    [eventTabVC setEventId:self.eventID];
    [self.navigationController pushViewController:eventTabVC animated:YES];
    
}

-(IBAction)clickimage1:(id)sender
{
    
    CurrentIndex = 1;
    
    UIAlertView *alert;
    
    if (imgData != nil)
    {
        alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"],[localization localizedStringForKey:@"Remove Photo"], nil];
        [alert show];
        
    }
    else{
        
        alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
        [alert show];
        
        
    }
    
    

    pickerController = [[UIImagePickerController alloc]
                        init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    
}

- (IBAction)clickimage2:(id)sender
{
    
    CurrentIndex = 2;
    
    UIAlertView *alert;
    
    if (imgData2 != nil)
    {
        alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"],[localization localizedStringForKey:@"Remove Photo"], nil];
        [alert show];
        
    }
    else{
        
        alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
        [alert show];
        
        
    }
        pickerController = [[UIImagePickerController alloc]
                            init];
        pickerController.delegate = self;
        pickerController.allowsEditing = NO;
    
}

- (IBAction)clickimage3:(id)sender
{
    
     CurrentIndex = 3;
    
    UIAlertView *alert;
    
    if (imgData3 != nil)
    {
        alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"],[localization localizedStringForKey:@"Remove Photo"], nil];
        [alert show];
        
    }
    else{
        
        alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
        [alert show];
        
        
    }
    
        pickerController = [[UIImagePickerController alloc]
                            init];
        pickerController.delegate = self;
        pickerController.allowsEditing = NO;
}

- (IBAction)clickimage4:(id)sender
{
    
     CurrentIndex = 4;
    
    UIAlertView *alert;
    
    if (imgData4 != nil)
    {
        alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"],[localization localizedStringForKey:@"Remove Photo"], nil];
        [alert show];
        
    }
    else{
        
        alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
        [alert show];
        
        
    }
    
    pickerController = [[UIImagePickerController alloc]
                        init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
}

- (IBAction)clickimage5:(id)sender
{
    
     CurrentIndex = 5;
    
    UIAlertView *alert;
    
    if (imgData5 != nil)
    {
        alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"],[localization localizedStringForKey:@"Remove Photo"], nil];
        [alert show];
        
    }
    else{
        
        alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
        [alert show];
        
        
    }
    
    pickerController = [[UIImagePickerController alloc]
                        init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    
}


#pragma mark ------------------- Custom image Picker ------------------------


- (void)displayPickerForGroup:(ALAssetsGroup *)group
{
    ELCAssetTablePicker *tablePicker = [[ELCAssetTablePicker alloc] initWithStyle:UITableViewStylePlain];
    tablePicker.singleSelection = YES;
    tablePicker.immediateReturn = YES;
    
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:tablePicker];
    elcPicker.maximumImagesCount = 1;
    elcPicker.imagePickerDelegate = self;
    elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    elcPicker.onOrder = NO; //For single image selection, do not display and return order of selected images
    tablePicker.parent = elcPicker;
    
    // Move me
    tablePicker.assetGroup = group;
    [tablePicker.assetGroup setAssetsFilter:[ALAssetsFilter allAssets]];
    
    [self presentViewController:elcPicker animated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    

//    CGRect workingFrame = _scrollView.frame;
//    workingFrame.origin.x = 0;
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info)
    {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage])
            {
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [images addObject:image];
                
                //UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                //[imageview setContentMode:UIViewContentModeScaleAspectFit];
               // imageview.frame = workingFrame;
                
               // [_scrollView addSubview:imageview];
                
              //  workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                
                [images addObject:image];
                
                //UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                //[imageview setContentMode:UIViewContentModeScaleAspectFit];
               // imageview.frame = workingFrame;
                
               // [_scrollView addSubview:imageview];
                
                //workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
    }
    
    self.chosenImages = images;
    
    if ([self.chosenImages count]>0)
    {
        
        // Add image to RPMultipleImagePickerViewController
        
        if (gettedImages != nil)
        {
            for (int i = 0; i < [gettedImages count]; i++)
            {
                [self.multipleImagePicker addImage:(UIImage *)[gettedImages objectAtIndex:i]];
                
            }
            
        }
        
        for (int i = 0; i < [self.chosenImages count]; i++)
        {
            [self.multipleImagePicker addImage:(UIImage *)[self.chosenImages objectAtIndex:i]];
            
        }
     
   
        // Done callback
        self.multipleImagePicker.doneCallback = ^(NSArray *images)
        {
            
            NSLog(@"Images: %@", images);
            
        };
        
        // Show RPMultipleImagePickerViewController
    
        [self.multipleImagePicker setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:self.multipleImagePicker animated:YES];
    }
    
//    switch (self.chosenImages.count)
//    {
//        case 0:
//            
//            break;
//            
//            
//        case 1:
//            
//          
//            
//            break;
//            
//        case 2:
//            
//            break;
//            
//            
//        case 3:
//            
//            break;
//            
//            
//        case 4:
//            
//            break;
//            
//            
//        case 5:
//            
//            break;
//            
//        default:
//            break;
//    }
    
    NSLog(@"%@",self.chosenImages);
    
//    [_scrollView setPagingEnabled:YES];
//    [_scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)clickWhatsapp:(id)sender
{
     [self shareEventOnWhatsApp:shareDict];
}
@end

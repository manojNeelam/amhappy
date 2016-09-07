//
//  TimeLineViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 11/09/15.
//
//

#import "TimeLineViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "EventDetailViewController.h"
#import "OtherUserProfileViewController.h"
#import "Toast+UIView.h"
#import "RegistrationViewController.h"
#import "TYMActivityIndicatorViewViewController.h"
#import "likesPeople.h"

#import "TwoImages.h"
#import "ThreeImages.h"
#import "FourImages.h"
#import "FiveImages.h"

#import "MHFacebookImageViewer.h"
#import "UIImageView+MHFacebookImageViewer.h"
#import "PromotionCellTableViewCell.h"


#import "DAAttributedLabel.h"
#import "DAAttributedStringFormatter.h"
#import "DAFontSet.h"

#import "UIButton+WebCache.h"

#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


#define VIEW_FOR_ZOOM_TAG (1)

#define RowPerSection (5)

#define viewAllcommentsHeight (40)
#define replyCellHeight (40)



@interface TimeLineViewController ()<UIGestureRecognizerDelegate,MHFacebookImageViewerDatasource,DAAttributedLabelDelegate,FBSDKSharingDelegate>

@end

@implementation TimeLineViewController
{
    NSMutableArray *timeLineArray,*promotionArray,*UserToHighlight;
    ModelClass *mc;
    
    int likeID;
    int deleteID;
    int reportID;
    int shareID;
    
    int start;
    BOOL isLast;
    
    int shareImageTag;
    
    NSString *eventName;
    
    UIRefreshControl *refreshControl;
    NSMutableArray *mainArray;
    int postOffset;
    
    NSMutableArray *reverseArray;
    
    TYMActivityIndicatorViewViewController *drk;
    
    BOOL canCall;
    
    DAAttributedStringFormatter* formatter;
    
    int currentIndexPath,currentImageIndex;
    
     NSString *isImageLiked;

}
@synthesize lblTitle,shareImageView,shareSubview,bgImage,imgShareBig,btnFeed;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
        {
            
            [self tabBarItem].selectedImage = [[UIImage imageNamed:@"timelinelogo.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self tabBarItem].image = [[UIImage imageNamed:@"timelinelogo1.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else
        {
            [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"timelinelogo.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"timelinelogo1.png"]];
        }
        
    }
    self.title =[localization localizedStringForKey:@"Board"];
    
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentIndexPath = 0;
    
    currentImageIndex = 0;
    
    UserToHighlight = [[NSMutableArray alloc]init];
    
    
    
    formatter = [[DAAttributedStringFormatter alloc] init];
    formatter.defaultFontFamily = @"Avenir";
    formatter.defaultColor = [UIColor lightGrayColor];
    formatter.fontFamilies = @[ @"Courier", @"Arial", @"Georgia" ];
    formatter.defaultPointSize = 14.0f;
    formatter.colors = @[[UIColor colorWithRed:49.0/255.0 green:160.0/255.0 blue:218.0/255.0 alpha:1.0],[UIColor redColor]];

    
    
    
    
    timeLineArray =[[NSMutableArray alloc] init];
    promotionArray = [[NSMutableArray alloc]init];
    mc =[[ModelClass alloc] init];
    mc.delegate =self;
    
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    
    likeID =-1;
    deleteID =-1;
    reportID=-1;
    shareID=-1;
    
    start =0;
    isLast =NO;
    postOffset=0;
    
    
    reverseArray =[[NSMutableArray alloc] init];
    mainArray =[[NSMutableArray alloc] init];
    self.btnFeed.layer.masksToBounds = YES;
    self.btnFeed.layer.cornerRadius = 20.0;
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tblTimeLIne addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    
    [self.tblTimeLIne registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
   // [self.tblTimeLIne registerClass:[TimeLineCell1 class] forCellReuseIdentifier:@"TimeLineCell1"];

    
}

- (void)refreshTable {
    //TODO: refresh your data
    [refreshControl endRefreshing];
    start=0;
 
    [self callApi];
}

- (void)didReceiveMemoryWarning
{
   // isMemory =YES;
    [super didReceiveMemoryWarning];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callTmerApi) object:nil];

}
-(void)viewWillAppear:(BOOL)animated
{
    
    DELEGATE.BoardbadgeValue = 0;
    
    UITabBarItem *item2 = [self.tabBarController.tabBar.items objectAtIndex:2];
    
    if(DELEGATE.BoardbadgeValue==0)
    {
        [item2 setBadgeValue:nil];
    }
    else
    {
        [item2 setBadgeValue:[NSString stringWithFormat:@"%d",DELEGATE.BoardbadgeValue]];
    }
   
  //  isMemory =NO;
    canCall =YES;
    start =0;
    [timeLineArray removeAllObjects];
    [promotionArray removeAllObjects];
    [_tblTimeLIne reloadData];
    
    [self callApi];
    [self performSelector:@selector(callTmerApi) withObject:nil afterDelay:40.0];
    
    self.lblTitle.text =[localization localizedStringForKey:@"Board"];
    self.lblFeed.text =[localization localizedStringForKey:@"New Feeds"];
    
    

}

-(void)callTmerApi
{
    
    if(DELEGATE.connectedToNetwork)
    {
        
        if(timeLineArray.count>0)
        {
            [mc getUserNewsfeed:[USER_DEFAULTS valueForKey:@"userid"] Timestamp:[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:0] valueForKey:@"time"]] Sel:@selector(responseGetTimer:)];
            
           // [mc getUserNewsfeed:@"6" Timestamp:[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:0] valueForKey:@"time"]] Sel:@selector(responseGetTimer:)];
            
        }
        else
        {
            [mc getUserNewsfeed:[USER_DEFAULTS valueForKey:@"userid"] Timestamp:@"0" Sel:@selector(responseGetTimer:)];
            
           // [mc getUserNewsfeed:@"6" Timestamp:@"0" Sel:@selector(responseGetTimer:)];
        }
       
    }
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callTmerApi) object:nil];
  
        [self performSelector:@selector(callTmerApi) withObject:nil afterDelay:40.0];
    

}


-(void)responseGetTimer:(NSDictionary *)results
{
   // NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if([results valueForKey:@"Feed"])
        {
            if([[results valueForKey:@"Feed"] count]==0)
            {
                
            }
            else
            {
                /* int z=(int)[[results valueForKey:@"Feed"] count];
                 NSRange range = NSMakeRange(0, z);
                 NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                 [timeLineArray insertObjects:[results valueForKey:@"Feed"] atIndexes:indexSet];*/
                
                NSArray *temp =[[NSArray alloc] initWithArray:timeLineArray];
                 //NSArray *promotionstemp =[[NSArray alloc] initWithArray:promotionArray];
                [timeLineArray removeAllObjects];
               // [promotionArray removeAllObjects];
                [timeLineArray addObjectsFromArray:[results valueForKey:@"Feed"]];
               // [promotionArray addObjectsFromArray:[results valueForKey:@"Promotion"]];
                
                
                [timeLineArray addObjectsFromArray:temp];
                
                [self.tblTimeLIne reloadData];
                
               // [promotionArray addObjectsFromArray:promotionstemp];
                
                 start =(int)[timeLineArray count];
                
                temp=nil;
               
                
                if(self.tblTimeLIne.contentOffset.y >100)
                {
                    [self.feebView setHidden:NO];
                }
                else
                {
                    [self.tblTimeLIne setContentOffset:CGPointZero animated:NO];
                    [self.tblTimeLIne reloadData];
                }
                
                
            }
        }
        
    }
  
}

-(void)callApi
{
    if(DELEGATE.connectedToNetwork)
    {
        
        if([timeLineArray count]==0)
        {
            [mc getMyFeed:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%lu",(unsigned long)[timeLineArray count]] Limit:LimitComment Timestamp:@"0" promo_ids:nil Sel:@selector(responseGetTimeLine:)];
            
           // [mc getMyFeed:@"6" Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Timestamp:@"0" Sel:@selector(responseGetTimeLine:)];
           
        }
        else
        {
            
            if (start ==0)
            {
                
                [mc getMyFeed:[USER_DEFAULTS valueForKey:@"userid"] Start:@"0" Limit:LimitComment Timestamp:@"0" promo_ids:nil Sel:@selector(responseGetTimeLine:)];
                
                
            }
            else{
                
                
                if(timeLineArray.count>0)
                {
                    
                    if ([promotionArray count]>0)
                    {
                        
                        NSMutableArray *promoIds = [[NSMutableArray alloc]init];
                        
                        for (int i =0; i<[promotionArray count]; i++)
                        {
                            [promoIds addObject:[[promotionArray objectAtIndex:i] valueForKey:@"id"]];
                            
                        }
                        
                        [mc getMyFeed:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%lu",(unsigned long)[timeLineArray count]] Limit:LimitComment Timestamp:[NSString stringWithFormat:@"%@",[[timeLineArray lastObject] valueForKey:@"time"]] promo_ids:[NSString stringWithFormat:@"%@",[promoIds componentsJoinedByString:@","]] Sel:@selector(responseGetTimeLine:)];
                        
                    }
                    else{
                        
                        [mc getMyFeed:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%lu",(unsigned long)[timeLineArray count]] Limit:LimitComment Timestamp:[NSString stringWithFormat:@"%@",[[timeLineArray lastObject] valueForKey:@"time"]] promo_ids:nil Sel:@selector(responseGetTimeLine:)];
                        
                    }
                    
                    
                    
                    
                    //[mc getMyFeed:@"6" Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Timestamp:[NSString stringWithFormat:@"%@",[[timeLineArray lastObject] valueForKey:@"time"]] Sel:@selector(responseGetTimeLine:)];
                    
                }
                else
                {
                    [mc getMyFeed:[USER_DEFAULTS valueForKey:@"userid"] Start:[NSString stringWithFormat:@"%lu",(unsigned long)[timeLineArray count]] Limit:LimitComment Timestamp:@"0" promo_ids:nil Sel:@selector(responseGetTimeLine:)];
                    
                    //[mc getMyFeed:@"6" Start:[NSString stringWithFormat:@"%d",start] Limit:LimitComment Timestamp:@"0" Sel:@selector(responseGetTimeLine:)];
                    
                }

                
                
            }
            
            
        }
        
   
    }
}


-(void)responseGetTimeLine:(NSDictionary *)results
{
   // NSLog(@"result is %@",results);
    
   
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if([results valueForKey:@"Feed"])
        {
            if(start==0)
            {
                [timeLineArray removeAllObjects];
                [promotionArray removeAllObjects];
               
            }
    
            if([[results valueForKey:@"Feed"] count]>0)
            {
               // [mainArray addObjectsFromArray:[results valueForKey:@"Feed"]];

               // [self getDataFromMainArray];
                
                 [timeLineArray addObjectsFromArray:[results valueForKey:@"Feed"]];
                [promotionArray addObjectsFromArray:[results valueForKey:@"Promotion"]];


            }
            
            [self.tblTimeLIne reloadData];
            
            [self.tblTimeLIne layoutIfNeeded];
            
            start =(int)[timeLineArray count];

            if(timeLineArray.count==0)
            {
                [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
            }
            
            if([[results valueForKey:@"is_last"] isEqualToString:@"Y"])
            {
                isLast =YES;
            }
            else
            {
                isLast =NO;
            }

           
          
        }
        
        
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
    }
     canCall =YES;
}

- (void)addUpperBorder:(UIView *)View
{
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor colorWithRed:232.0/255.0 green:235.0/255.0 blue:240.0/255.0 alpha:1.0]CGColor];
    upperBorder.frame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width - 20, 1.0f);
    [View.layer addSublayer:upperBorder];
}
-(void)getDataFromMainArray
{
    
    NSArray *result=[[NSArray alloc]init];

            if(mainArray.count>20)
            {
                NSRange theRange;
                theRange.location = [mainArray count] - 10;
                theRange.length = 10;
                result = [mainArray subarrayWithRange:theRange];
                //postOffset =postOffset+10;
            }
            else
            {
                NSRange theRange;
                theRange.location = [mainArray count] - [mainArray count];
                theRange.length = [mainArray count];
                result = [mainArray subarrayWithRange:theRange];
                //postOffset = (int)[mainArray count];
            }
   
    
    [timeLineArray removeAllObjects];
    [timeLineArray addObjectsFromArray:result];
   // NSLog(@"last mainArray object is %@",[mainArray lastObject]);
   // NSLog(@"last mainArray object is %@",[timeLineArray lastObject]);
    self.tblTimeLIne.clearsContextBeforeDrawing =YES;
    [self.tblTimeLIne reloadData];
    
    result =nil;
    
    reverseArray=[[[mainArray reverseObjectEnumerator] allObjects] mutableCopy];

}
-(void)getPrevoiusDataFromMainArray
{
    NSArray *result=[[NSArray alloc]init];
   // int prev = (int)[timeLineArray count] + 20;
  
    if(reverseArray.count>20)
    {
        NSRange theRange;
        theRange.location = [reverseArray count] - 10;
        theRange.length = 10;
        result = [reverseArray subarrayWithRange:theRange];
        //postOffset =postOffset+10;
    }
    else
    {
        NSRange theRange;
        theRange.location = [reverseArray count] - [reverseArray count];
        theRange.length = [reverseArray count];
        result = [reverseArray subarrayWithRange:theRange];
        //postOffset = (int)[mainArray count];
    }
  
    
    [timeLineArray removeAllObjects];
    [timeLineArray addObjectsFromArray:result];
   // NSLog(@"last mainArray object is %@",[mainArray lastObject]);
   // NSLog(@"last mainArray object is %@",[timeLineArray lastObject]);
    self.tblTimeLIne.clearsContextBeforeDrawing =YES;
    [self.tblTimeLIne reloadData];
    
    result =nil;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    
    
  //  NSLog(@"table offset is %f",self.tblTimeLIne.contentOffset.y);
    
   /* if(self.tblTimeLIne.contentOffset.y <50)
    {
        [self.tblTimeLIne reloadData];
        [self.feebView setHidden:YES];
    }*/
    
   
    
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if(translation.y > 0)
    {
         //NSLog(@"down");
        if(self.tblTimeLIne.contentOffset.y <50)
        {
          //  [self getPrevoiusDataFromMainArray];
        }
    } else
    {
        //NSLog(@"up");
        
        if (maximumOffset - currentOffset <= 10.0  )
        {
            if(!isLast )
            {
                if(canCall)
                {
                    canCall =NO;
                   // [self.tblTimeLIne setUserInteractionEnabled:NO];

                    [self callApi];
                }
            }
        }
    }
    
  
    
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if(timeLineArray.count>0)
    {
        
        if(timeLineArray.count<5)
        {
               return 1;
        }
        
        if ([promotionArray count]>0)
        {
     
            return [promotionArray count];
        }
        else {
            
            return 1;
   
        }
        
        //return ceil(timeLineArray.count/RowPerSection);
    }
    else return 0;
    
    
}
//private void injectPromotionInList(ArrayList<Feed> feedList, ArrayList<Promotion> promotionlist){
//    int i = 0;
//    int section = 0;
//    int promotionIndex = 0;
//    while (i < feedList.size()) {
//        if (section == 5) {
//            if (promotionlist.size() > 0) {
//                Feed newFeed = new Feed();
//                newFeed.setPromotion(promotionlist.get(promotionIndex));
//                feedList.add(i, newFeed);
//                promotionIndex++;
//                if (promotionIndex > promotionlist.size() - 1) {
//                    promotionIndex = 0;
//                }
//                section=0;
//            }
//        } else {
//            section++;
//        }
//        i++;
//    }
//}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(timeLineArray.count>0)
    {
        if(timeLineArray.count<5)
        {
            return timeLineArray.count;
        }
        
            if ([promotionArray count]>0)
            {
                
                if (section == [promotionArray count]-1)
                {
                    return timeLineArray.count - ([promotionArray count]-1)*RowPerSection;
                    
                }
                else{
                    
                    return RowPerSection;
                    
                }
            
            }
            else{
                
                return timeLineArray.count;
                
            }

 
//        if (section == ceil(timeLineArray.count/RowPerSection)-1)
//        {
//            
//            return timeLineArray.count-((ceil(timeLineArray.count/RowPerSection)-1)*RowPerSection);
//          
//        }
//        return RowPerSection;
    }
    else return 0;
   
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
//            NSLog(@"%lu",(unsigned long)range.location);
//            
//            
//            range.location = range.location - 1;
//            
//            range.length = range.length + 2;
//            
//            NSLog(@"%@",NSStringFromRange(range));
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

- (void)label:(DAAttributedLabel *)label didSelectLink:(NSInteger)linkNum
{
    
    NSLog(@"%@",label);
    
    NSLog(@"%ld",(long)label.tag);
    
    NSLog(@"%ld",(long)linkNum);
    
    NSMutableArray *tagArray = [[NSMutableArray alloc] initWithArray: [[[timeLineArray objectAtIndex:label.tag] valueForKey:@"Comment"] valueForKey:@"Tags"]];
    
    if ([tagArray count]>0)
    {
        OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
        [otherVC setUserId:[NSString stringWithFormat:@"%@",[[tagArray objectAtIndex:(long)linkNum] valueForKey:@"id"]]];
        [self.navigationController pushViewController:otherVC animated:YES];
        
    }
    
}


-(void)configureTimeLineCellEventWithImage:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell.contentView subviews]){
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    
    FRHyperLabel *lblCellTitle =[[FRHyperLabel alloc] init];
    UILabel *lblName=[[UILabel alloc] init];
    UILabel *lblStatus=[[UILabel alloc] init];
    UILabel *lblEventName=[[UILabel alloc] init];
    UILabel *lblDate=[[UILabel alloc] init];
    UILabel *lblComment=[[UILabel alloc] init];
    UIView *btnView=[[UIView alloc] init];
    
    UIImageView *imgUser=[[UIImageView alloc] init];
    UIImageView *imgComment=[[UIImageView alloc] init];

    UILabel *lblCommentCount=[[UILabel alloc] init];
    UIButton *btnLike=[[UIButton alloc] init];
    UILabel *lblLikeCount=[[UILabel alloc] init];
    UIButton *btnComment=[[UIButton alloc] init];
    UIButton *btnProfile=[[UIButton alloc] init];
    UIButton *btnShare=[[UIButton alloc] init];
    UIButton *btnReport=[[UIButton alloc] init];
    UIView *bgView=[[UIView alloc] init];
    UIButton *btnDelete=[[UIButton alloc] init];
    UIButton *btnEvent=[[UIButton alloc] init];;
    UIButton *btnName=[[UIButton alloc] init];
    
    UIButton *viewAllReplies = [[UIButton alloc] init];
    
    UIView *replyView = [[UIView alloc] init];
    
    
    
    
    bgView.frame =CGRectMake(10, 10, self.view.bounds.size.width-20, cell.frame.size.height-25);
    
    [bgView setBackgroundColor:[UIColor whiteColor]];
    
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];

    
    imgUser.frame =CGRectMake(5, 9, 50, 50);
    [imgUser setImage:[UIImage imageNamed:@"iconBlack.png"]];
    
    
    
    
    btnProfile.frame =CGRectMake(5, 9, 48, 45);
    
    
    
    btnName.frame =CGRectMake(56, 0, 85, 20);//56 6 85 26
    
    
    btnEvent.frame =CGRectMake(139, 9, bgView.frame.size.width-140, 26);//139 9 153 26
    
    
    lblName.frame =CGRectMake(61, 6, 63, 26);//61 6 63 26
   // [bgView addSubview:lblName];
    
    lblStatus.frame =CGRectMake(123, 9, 93, 26);//123 9 93 26
    
    
    lblEventName.frame =CGRectMake(209, 6, bgView.frame.size.width-210, 26);//209 6 77 26
   // [bgView addSubview:lblEventName];
    
    lblCellTitle.frame =CGRectMake(61, 0, bgView.frame.size.width-62, 40);//61 0 231 40
    
    
    
    lblDate.frame =CGRectMake(61, 38, 124, 18);//61 38 124 18
    
    
    lblComment.frame =CGRectMake(5, 61, bgView.frame.size.width-10, 1);//5 61 290 1
    
    
    imgComment.frame = CGRectMake(0, 76,bgView.frame.size.width, 215);
    
    
    if(IS_IPHONE_4s || IS_IPHONE_5)
    {
       // imgComment.frame =CGRectMake(0, 76, 300, 215);// 0 76 300 215
        
    }
    else
    {
       // float x = (bgView.frame.size.width-300)/2;
//        NSLog(@"My view frame: %@", NSStringFromCGRect(bgView.frame));
//        NSLog(@"%f",x);
        //imgComment.frame =CGRectMake(x, 76, 300, 215);// 0 76 300 215
        
    }
    
   // imgComment.backgroundColor = [UIColor yellowColor];
    
    
    btnView.frame =CGRectMake(0, cell.frame.size.height-55, bgView.frame.size.width, 46);//0 70 300 46
    
    
    btnLike.frame =CGRectMake(0, 6, 32, 34);//0 6 32 34
    
    
    lblLikeCount.frame =CGRectMake(30, 3, 48, 40);//30 3 48 40
    
    
    
    btnComment.frame =CGRectMake(79, 6, 32, 34);//79 6 32 34
    
    
    lblCommentCount.frame =CGRectMake(113, 3, 85, 40);//30 3 85 40
    
    
    btnDelete.frame =CGRectMake(bgView.frame.size.width-32, 6, 32, 32);//268 6 32 34
    
    
    btnShare.frame =CGRectMake(bgView.frame.size.width-64, 6, 32, 34);//234 6 32 34
    
    
    btnReport.frame =CGRectMake(bgView.frame.size.width-96, 6, 32, 34);//198 6 32 34
    
    
    /**************** Add Targer to buttons *********/
    
    [btnReport addTarget:nil action:@selector(reportPostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnDelete addTarget:nil action:@selector(deletePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnLike addTarget:nil action:@selector(likePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnShare addTarget:nil action:@selector(sharePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnComment addTarget:nil action:@selector(commentPostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnProfile addTarget:nil action:@selector(profilePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnName addTarget:nil action:@selector(namePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if([[UIScreen mainScreen] bounds].size.width>375)
    {
        [btnEvent addTarget:nil action:@selector(eventPostTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    [btnDelete setImage:[UIImage imageNamed:@"deleteNewIcon.png"] forState:UIControlStateNormal];
    [btnShare setImage:[UIImage imageNamed:@"shareNew2.png"] forState:UIControlStateNormal];
    [btnComment setImage:[UIImage imageNamed:@"commentIcon.png"] forState:UIControlStateNormal];
    
    
    
    
    /**************** Add label fonts *********/
    
    
    lblComment.font =FONT_Regular(14.0);
    [lblComment setNumberOfLines:0];
    [lblComment setMinimumScaleFactor:0.5];
    
    lblCommentCount.font =FONT_Regular(11.0);
    [lblCommentCount setNumberOfLines:0];
    [lblCommentCount setMinimumScaleFactor:0.5];
    
    
    lblDate.font =FONT_Regular(12.0);
    [lblDate setNumberOfLines:0];
    [lblDate setMinimumScaleFactor:0.5];
    
    
    lblLikeCount.font =FONT_Regular(11.0);
    [lblLikeCount setNumberOfLines:0];
    [lblLikeCount setMinimumScaleFactor:0.5];
    
    [lblCellTitle setNumberOfLines:0];
    [lblCellTitle setMinimumScaleFactor:0.5];
    
  
    CGFloat cellHeight=[self getLabelHeightForIndex:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"description"]];
    
    NSString *type =[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"type"]];
    
    
    cell.clipsToBounds = YES;
    imgUser.layer.masksToBounds = YES;
    imgUser.layer.cornerRadius = 25.0;
    
    
    
    btnShare.tag =indexPath.row;
    btnReport.tag =indexPath.row;
    btnProfile.tag =indexPath.row;
    btnName.tag =indexPath.row;
    btnLike.tag =indexPath.row;
    btnEvent.tag =indexPath.row;
    btnDelete.tag =indexPath.row;
    
    
    if(IS_Ipad)
    {
        btnEvent.frame = CGRectMake(lblCellTitle.frame.origin.x, btnEvent.frame.origin.y, btnEvent.frame.size.width+100, btnEvent.frame.size.height);
    }
    
    //************* Add Tap Gesture on like Label ******
    
    UITapGestureRecognizer *likesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likecliked:)];
    likesRecognizer.delegate = self;
    [lblLikeCount setUserInteractionEnabled:YES];
    lblLikeCount.tag =indexPath.row;
    [lblLikeCount addGestureRecognizer:likesRecognizer];
    
    likesRecognizer = nil;
    
    //***********************
    
    UITapGestureRecognizer *tapCommentRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentTap:)];
    tapCommentRecognizer.delegate = self;
    [lblCommentCount setUserInteractionEnabled:YES];
    lblCommentCount.tag =indexPath.row;
    [lblCommentCount addGestureRecognizer:tapCommentRecognizer];
    tapCommentRecognizer =nil;

    
    /*************  User detail ******************/
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"thumb_image"] length]>0)
    {
        [imgUser sd_setImageWithURL:[NSURL URLWithString:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"thumb_image"]]];
    }
    
    lblName.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"name"];
    
    /*************  Event detail ******************/
    
    [imgComment sd_setImageWithURL:[NSURL URLWithString:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"image"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
        {
            
            // UIImage * image1=[self drawImage:image inRect:cell.imgComment.bounds];
            /*  UIImage * image1=[self drawImage:image inRect: CGRectMake(0, 0, self.view.bounds.size.width, cell.imgComment.bounds.size.height)];
             
             cell.imgComment.image =image1;*/
            
            UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap2:)];
            tapGestureRecognizer2.delegate = self;
            [imgComment setUserInteractionEnabled:YES];
            imgComment.tag =indexPath.row;
            [imgComment addGestureRecognizer:tapGestureRecognizer2];
            
            tapGestureRecognizer2 =nil;

            
            UIImage * image1=[self drawImage:image inRect: CGRectMake(0, 0, self.view.bounds.size.width, imgComment.bounds.size.height)];
            
            imgComment.image =nil;
            imgComment.image =image1;
            if(IS_Ipad)
            {
                imgComment.contentMode = UIViewContentModeScaleAspectFill;
                
            }
            image1 =nil;
            
            
        }
    }];
    
    lblEventName.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"];
    
    lblComment.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"description"];
    
    lblComment.frame =CGRectMake(lblComment.frame.origin.x, lblComment.frame.origin.y, lblComment.frame.size.width, cellHeight);
    
    lblDate.text =[self getDate:[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"time"] ];
    
    
    if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"like_count"]] isEqualToString:@"0"])
    {
        
        lblLikeCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"like_count"],[localization localizedStringForKey:@"Like"]];
    }
    else
    {
        lblLikeCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"like_count"],[localization localizedStringForKey:@"Likes"]];
    }
    
    
    
    if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"comment_count"]] isEqualToString:@"0"])
    {
        
        lblCommentCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"comment_count"],[localization localizedStringForKey:@"Comment"]];
    }
    else
    {
        lblCommentCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"comment_count"],[localization localizedStringForKey:@"Comments"]];
    }
    
    
    
    
    
    
    UIFont *nameFont = FONT_Heavy(16.0);;
    NSDictionary *nameDict = [NSDictionary dictionaryWithObject: nameFont forKey:NSFontAttributeName];
    NSMutableAttributedString *nameString;
    
    if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
    {
        if(![type isEqualToString:@"NE"])
        {
            nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You2"] attributes: nameDict];
            
        }
        else
        {
           nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You"] attributes: nameDict];
        }

    }
    else
    {
        nameString = [[NSMutableAttributedString alloc] initWithString:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"name"] attributes: nameDict];
    }
    [nameString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:228/255.0f green:123/255.0f blue:0 alpha:1] range:(NSMakeRange(0, nameString.length))];
    
    
    UIFont *statusFont = FONT_Regular(16.0);
    NSDictionary *statusDict = [NSDictionary dictionaryWithObject:statusFont forKey:NSFontAttributeName];
    NSMutableAttributedString *statusString;
    
    if([type isEqualToString:@"NE"])
    {
        //cell.lblStatus.text =@"created an event";
        
        if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"created an event2"]] attributes:statusDict];
        }
        else
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"created an event"]] attributes:statusDict];
        }
        
        
        
    }
    else
    {
        //cell.lblStatus.text =@"liked an event";
        
      //  statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"liked an event"]] attributes:statusDict];
        
        if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"liked an event2"]] attributes:statusDict];
        }
        else
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"liked an event"]] attributes:statusDict];
        }
    }
    
    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:(NSMakeRange(0, statusString.length))];
    
    UIFont *eventFont = FONT_Heavy(16.0);;
    NSDictionary *eventDict = [NSDictionary dictionaryWithObjectsAndKeys:eventFont,NSFontAttributeName, [UIColor greenColor], NSForegroundColorAttributeName, nil];
    
    
    NSMutableAttributedString *eventNameString = [[NSMutableAttributedString alloc]initWithString: [[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"] attributes:eventDict];
    
    //[eventNameString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:228/255.0f green:123/255.0f blue:0 alpha:1] range:(NSMakeRange(0, eventNameString.length))];
    
    [nameString appendAttributedString:statusString];
    [nameString appendAttributedString:eventNameString];
    
    
    
    lblCellTitle.attributedText = nameString;
    
    void(^handler)(FRHyperLabel *label, NSString *substring) = ^(FRHyperLabel *label, NSString *substring){
        
        //  [self checkNameTag:substring Index:(int)indexPath.row];
      /*  UIAlertController *controller = [UIAlertController alertControllerWithTitle:substring message:nil preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];*/
        
        [self customPostEvent:(int)indexPath.row];

        
    };
    
    //Step 3: Add link substrings
    if([[UIScreen mainScreen] bounds].size.width<=375)
    {
        [lblCellTitle setLinksForSubstrings:@[ [[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"]] withLinkHandler:handler];
    }
    
    
    
    
    
    //******************** Manage Flag / Delete Here

    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"is_creater"] isEqualToString:@"Y"])
    {
        //[btnDelete setHidden:NO];
        
        [btnReport setHidden:YES];
     
        [btnDelete setHidden:NO];
        
    }
    else
    {
        [btnDelete setHidden:YES];
        
        btnReport.frame = CGRectMake(btnReport.frame.origin.x+35, btnReport.frame.origin.y, btnReport.frame.size.width,btnReport.frame.size.height);
        btnShare.frame = CGRectMake(btnShare.frame.origin.x+35, btnShare.frame.origin.y, btnShare.frame.size.width,btnShare.frame.size.height);
    }
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"is_liked"] isEqualToString:@"Y"])
    {
        [btnLike setImage:[UIImage imageNamed:@"like2.png"] forState:UIControlStateNormal];
    }
    else
    {
        [btnLike setImage:[UIImage imageNamed:@"like1.png"] forState:UIControlStateNormal];
    }
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"is_reported"] isEqualToString:@"Y"])
    {
        [btnReport setImage:[UIImage imageNamed:@"flag2.png"] forState:UIControlStateNormal];
        [btnReport setEnabled:NO];
    }
    else
    {
        [btnReport setImage:[UIImage imageNamed:@"flag1.png"] forState:UIControlStateNormal];
        [btnReport setEnabled:YES];
        
    }
    
    
    bgView.frame =CGRectMake(10, 10, self.view.bounds.size.width-20, bgView.frame.size.height+cellHeight);
    
    //  NSLog(@"bgView frame is %@", NSStringFromCGRect(cell.bgView.frame));
    
    lblComment.frame =CGRectMake(lblComment.frame.origin.x, lblComment.frame.origin.y, lblComment.frame.size.width, cellHeight);
    
    imgComment.frame=CGRectMake(imgComment.frame.origin.x, lblComment.frame.origin.y+cellHeight+10, imgComment.frame.size.width, imgComment.frame.size.height);
    
    //  NSLog(@"image frame is %@", NSStringFromCGRect(cell.imgComment.frame));
    
    
    [bgView.layer setBorderColor:[UIColor lightTextColor].CGColor];
    [bgView.layer setBorderWidth:1.0f];
    
    
    
    //btnView.frame =CGRectMake(btnView.frame.origin.x, cell.frame.size.height-55, bgView.frame.size.width, 46);
    
    
    //******** set replies View
    

    
    //******** set replies View
    
    btnView.frame = CGRectMake(btnView.frame.origin.x,lblComment.frame.origin.y+cellHeight+imgComment.frame.size.height+15,bgView.frame.size.width, 46);
    
    
    
    int replyHeight = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"top_comments_count"] description] intValue] > 0 ? viewAllcommentsHeight : 0 + [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"] count]>0 ? replyCellHeight * (int)[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"] count] : 0 ;
    
    //1
    
    [replyView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    replyView = [[UIView alloc]initWithFrame:CGRectMake(btnView.frame.origin.x, btnView.frame.origin.y+btnView.frame.size.height, btnView.frame.size.width,replyHeight)];
    
    if ([[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"top_comments_count"] description] intValue] > 0)
    {
        
        //2
        
        viewAllReplies = [[UIButton alloc]initWithFrame:CGRectMake(7,0,replyView.frame.size.width-10,viewAllcommentsHeight)];
        
        
        viewAllReplies.tag = indexPath.row;
        
        [viewAllReplies addTarget:self action:@selector(openReplies:) forControlEvents:UIControlEventTouchUpInside];
        
        [viewAllReplies setTitle:[NSString stringWithFormat:@"View previous %@ replies",[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"top_comments_count"] description]] forState:UIControlStateNormal];
        
        viewAllReplies.titleLabel.font = FONT_Bold(13);
        
        [viewAllReplies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        viewAllReplies.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [replyView addSubview:viewAllReplies];
        
        for (int i=0; i< [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"] count]; i++)
        {
            
            
            //3
            UIView *viewReply = [[UIView alloc] initWithFrame:CGRectMake(0, replyCellHeight*(i+1), viewAllReplies.frame.size.width,replyCellHeight)];
            
            viewReply.backgroundColor = [UIColor whiteColor];
            
            
            if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"image"]isEqualToString:@""])
            {
                
                //4
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                
                //5
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                
                
                [lblUserName setText:userName];
                
                //6
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                
                if ([[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
                {
                    [lblComment setText:@"commented with image"];
                    
                }
                else{
                    
                    [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]];
                    
                }
                
                
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
                
                
            }
            else{
                
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"username"];
                
                
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth , 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]];
                
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            
            [replyView addSubview:viewReply];
            
        }
        
    }
    else
    {
        for (int i=0; i< [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"] count]; i++)
        {
            
            
            UIView *viewReply = [[UIView alloc] initWithFrame:CGRectMake(0, replyCellHeight*(i), viewAllReplies.frame.size.width,replyCellHeight)];
            
            viewReply.backgroundColor = [UIColor whiteColor];
            
            
            if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"image"]isEqualToString:@""])
            {
                
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                btnUSer.titleLabel.font = FONT_Bold(13);
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                
                if ([[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
                {
                    [lblComment setText:@"commented with image"];
                    
                }
                else{
                    
                    [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]];
                    
                }
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            else{
                
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                btnUSer.titleLabel.font = FONT_Bold(13);
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+lblUserName.frame.size.width + 5,5, replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]];
                
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            
            [replyView addSubview:viewReply];
            
        }
    }
    
    
    // [replyView setBackgroundColor:[UIColor yellowColor]];
    
    [bgView addSubview:replyView];
    
    
    //   NSLog(@"btnView frame is %@", NSStringFromCGRect(cell.btnView.frame));
    
    
    [bgView addSubview:imgUser];
    [bgView addSubview:btnProfile];
    
   
    
    [bgView addSubview:lblStatus];
    
    
    if([[UIScreen mainScreen] bounds].size.width>375)
    {
        [bgView addSubview:lblCellTitle];
        [bgView addSubview:btnEvent];
    }
    else
    {
        [bgView addSubview:btnEvent];
        [bgView addSubview:lblCellTitle];
        
    }
    
    [bgView addSubview:btnName];
    [bgView addSubview:lblDate];
    [bgView addSubview:lblComment];
    [bgView addSubview:imgComment];
    [btnView addSubview:btnLike];
    [btnView addSubview:lblLikeCount];
    [btnView addSubview:btnComment];
    [btnView addSubview:lblCommentCount];
    [btnView addSubview:btnDelete];
    [btnView addSubview:btnShare];
    [btnView addSubview:btnReport];
    [bgView addSubview:btnView];
    [cell.contentView addSubview:bgView];
    
    lblLikeCount.tag = indexPath.row;
    

    
    [btnView.layer setBorderColor:[UIColor colorWithRed:232.0/255.0 green:235.0/255.0 blue:240.0/255.0 alpha:1.0].CGColor];
    [btnView.layer setBorderWidth:1.0f];
    
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    
    
    
    [imgUser setContentMode:UIViewContentModeScaleAspectFill];
    [imgUser setClipsToBounds:YES];
    
    [imgComment setContentMode:UIViewContentModeScaleAspectFill];
    [imgComment setClipsToBounds:YES];
    
    
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    nameDict =nil;
    nameString =nil;
    statusDict =nil;
    statusString =nil;
    eventDict =nil;
    eventNameString =nil;
    type =nil;
    nameFont =nil;
    statusFont =nil;
    eventFont =nil;
    

    
}
-(void)configureTimeLineCellEvent:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell.contentView subviews]){
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    
    FRHyperLabel *lblCellTitle =[[FRHyperLabel alloc] init];
    UILabel *lblName=[[UILabel alloc] init];
    UILabel *lblStatus=[[UILabel alloc] init];
    UILabel *lblEventName=[[UILabel alloc] init];
    UILabel *lblDate=[[UILabel alloc] init];
    UILabel *lblComment=[[UILabel alloc] init];
    UIView *btnView=[[UIView alloc] init];
    
    UIImageView *imgUser=[[UIImageView alloc] init];
    UILabel *lblCommentCount=[[UILabel alloc] init];
    UIButton *btnLike=[[UIButton alloc] init];
    UILabel *lblLikeCount=[[UILabel alloc] init];
    UIButton *btnComment=[[UIButton alloc] init];
    UIButton *btnProfile=[[UIButton alloc] init];
    UIButton *btnShare=[[UIButton alloc] init];
    UIButton *btnReport=[[UIButton alloc] init];
    UIView *bgView=[[UIView alloc] init];
    UIButton *btnDelete=[[UIButton alloc] init];
    UIButton *btnEvent=[[UIButton alloc] init];;
    UIButton *btnName=[[UIButton alloc] init];
    
    
    UIButton *viewAllReplies = [[UIButton alloc] init];
    
    UIView *replyView = [[UIView alloc] init];
    
    
    bgView.frame =CGRectMake(10, 10, self.view.bounds.size.width-20, cell.frame.size.height-10);
    [bgView setBackgroundColor:[UIColor whiteColor]];

    
    imgUser.frame =CGRectMake(5, 9, 50, 50);
    [imgUser setImage:[UIImage imageNamed:@"iconBlack.png"]];
    
    
    btnProfile.frame =CGRectMake(5, 9, 48, 45);
    
    
    
    btnName.frame =CGRectMake(56, 0, 85, 20);//56 6 85 26
    
    
    btnEvent.frame =CGRectMake(139, 9, bgView.frame.size.width-140, 26);//139 9 153 26
    
    
    lblName.frame =CGRectMake(61, 6, 63, 26);//61 6 63 26
   // [bgView addSubview:lblName];
    
    lblStatus.frame =CGRectMake(123, 9, 93, 26);//123 9 93 26
    
    
    lblEventName.frame =CGRectMake(209, 6, bgView.frame.size.width-210, 26);//209 6 77 26
   // [bgView addSubview:lblEventName];
    
    lblCellTitle.frame =CGRectMake(61, 0, bgView.frame.size.width-62, 40);//61 0 231 40
    
    
    
    lblDate.frame =CGRectMake(61, 38, 124, 18);//61 38 124 18
    
    
    lblComment.frame =CGRectMake(5, 61, bgView.frame.size.width-10, 1);//5 61 290 1
    
    
    btnView.frame =CGRectMake(0, cell.frame.size.height-55, bgView.frame.size.width, 46);//0 70 300 46
   
    
    btnLike.frame =CGRectMake(0, 6, 32, 34);//0 6 32 34
    
    
    lblLikeCount.frame =CGRectMake(30, 3, 48, 40);//30 3 48 40
    
    
    
    btnComment.frame =CGRectMake(79, 6, 32, 34);//79 6 32 34
    
    
    lblCommentCount.frame =CGRectMake(113, 3, 85, 40);//30 3 85 40
   
    
    btnDelete.frame =CGRectMake(bgView.frame.size.width-32, 6, 32, 32);//268 6 32 34
    
    
    btnShare.frame =CGRectMake(bgView.frame.size.width-64, 6, 32, 34);//234 6 32 34
    
    
    btnReport.frame =CGRectMake(bgView.frame.size.width-96, 6, 32, 34);//198 6 32 34
    
    
    /**************** Add Targer to buttons *********/
     
    [btnReport addTarget:nil action:@selector(reportPostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnDelete addTarget:nil action:@selector(deletePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnLike addTarget:nil action:@selector(likePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnShare addTarget:nil action:@selector(sharePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnComment addTarget:nil action:@selector(commentPostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnProfile addTarget:nil action:@selector(profilePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnName addTarget:nil action:@selector(namePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if([[UIScreen mainScreen] bounds].size.width>375)
    {
        [btnEvent addTarget:nil action:@selector(eventPostTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    [btnDelete setImage:[UIImage imageNamed:@"deleteNewIcon.png"] forState:UIControlStateNormal];
    [btnShare setImage:[UIImage imageNamed:@"shareNew2.png"] forState:UIControlStateNormal];
    [btnComment setImage:[UIImage imageNamed:@"commentIcon.png"] forState:UIControlStateNormal];
    
    
    
    
    /**************** Add label fonts *********/
    
    
    lblComment.font =FONT_Regular(14.0);
    [lblComment setNumberOfLines:0];
    [lblComment setMinimumScaleFactor:0.5];
    
    lblCommentCount.font =FONT_Regular(11.0);
    [lblCommentCount setNumberOfLines:0];
    [lblCommentCount setMinimumScaleFactor:0.5];
    
    
    lblDate.font =FONT_Regular(12.0);
    [lblDate setNumberOfLines:0];
    [lblDate setMinimumScaleFactor:0.5];
    
    
    lblLikeCount.font =FONT_Regular(11.0);
    [lblLikeCount setNumberOfLines:0];
    [lblLikeCount setMinimumScaleFactor:0.5];
    
    [lblCellTitle setNumberOfLines:0];
    [lblCellTitle setMinimumScaleFactor:0.5];
    

     /*
     
     - (void)sharePostTapped:(id)sender;
     - (void)deletePostTapped:(id)sender;
     - (void)likePostTapped:(id)sender;
     - (void)reportPostTapped:(id)sender;
     - (void)commentPostTapped:(id)sender;
     
     - (void)profilePostTapped:(id)sender;
     - (void)namePostTapped:(id)sender;
     - (void)eventPostTapped:(id)sender;
     
     */
     
    
    
    
    
    CGFloat cellHeight=[self getLabelHeightForIndex:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"description"]];
    NSString *type =[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"type"]];
    
   
    
    cell.clipsToBounds = YES;
    
    imgUser.layer.masksToBounds = YES;
    imgUser.layer.cornerRadius = 25.0;
    
    /*[cell.btnInvite setHidden:YES];
     [cell.btnAccept setHidden:YES];
     [cell.btnAdd setHidden:YES];*/
    
    //cell.delegate=self;
    
    btnShare.tag =indexPath.row;
    btnReport.tag =indexPath.row;
    btnProfile.tag =indexPath.row;
    btnName.tag =indexPath.row;
    btnLike.tag =indexPath.row;
    btnEvent.tag =indexPath.row;
    btnDelete.tag =indexPath.row;
    
  
    
    //************* Add Tap Gesture on like Label ******
    
    UITapGestureRecognizer *likesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likecliked:)];
    likesRecognizer.delegate = self;
    [lblLikeCount setUserInteractionEnabled:YES];
    lblLikeCount.tag =indexPath.row;
    [lblLikeCount addGestureRecognizer:likesRecognizer];
    
    likesRecognizer = nil;
    
    
    //***********************
  
    
    UITapGestureRecognizer *tapCommentRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentTap:)];
    tapCommentRecognizer.delegate = self;
    [lblCommentCount setUserInteractionEnabled:YES];
    lblCommentCount.tag =indexPath.row;
    [lblCommentCount addGestureRecognizer:tapCommentRecognizer];
    
    tapCommentRecognizer =nil;

    
    /*************  User detail ******************/
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"thumb_image"] length]>0)
    {
        [imgUser sd_setImageWithURL:[NSURL URLWithString:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"thumb_image"]]];
    }
    
    lblName.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"name"];
    
    /*************  Event detail ******************/
    
    lblEventName.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"];
    
    lblComment.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"description"];
    
    lblComment.frame =CGRectMake(lblComment.frame.origin.x, lblComment.frame.origin.y, lblComment.frame.size.width, cellHeight);
    
    lblDate.text =[self getDate:[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"time"] ];
    

    
    if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"like_count"]] isEqualToString:@"0"])
    {
        
       lblLikeCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"like_count"],[localization localizedStringForKey:@"Like"]];
    }
    else
    {
        lblLikeCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"like_count"],[localization localizedStringForKey:@"Likes"]];
    }
    
    
    
    if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"comment_count"]] isEqualToString:@"0"])
    {
        
        lblCommentCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"comment_count"],[localization localizedStringForKey:@"Comment"]];
    }
    else
    {
        lblCommentCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"comment_count"],[localization localizedStringForKey:@"Comments"]];
    }
    
    
    
    UIFont *nameFont = FONT_Heavy(16.0);
    NSDictionary *nameDict = [NSDictionary dictionaryWithObject: nameFont forKey:NSFontAttributeName];
    NSMutableAttributedString *nameString;
    
    if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
    {
        if(![type isEqualToString:@"NE"])
        {
            nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You2"] attributes: nameDict];
            
        }
        else
        {
            nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You"] attributes: nameDict];
        }
       // nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You"] attributes: nameDict];
    }
    else
    {
        nameString = [[NSMutableAttributedString alloc] initWithString:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"name"] attributes: nameDict];
    }
    [nameString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:228/255.0f green:123/255.0f blue:0 alpha:1] range:(NSMakeRange(0, nameString.length))];
    
    
    UIFont *statusFont = FONT_Regular(16.0);
    NSDictionary *statusDict = [NSDictionary dictionaryWithObject:statusFont forKey:NSFontAttributeName];
    NSMutableAttributedString *statusString;
    
    if([type isEqualToString:@"NE"])
    {
        if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"created an event2"]] attributes:statusDict];
        }
        else
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"created an event"]] attributes:statusDict];
        }
        
    }
    else
    {
        if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"liked an event2"]] attributes:statusDict];
        }
        else
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"liked an event"]] attributes:statusDict];
        }
        
    }
    
    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:(NSMakeRange(0, statusString.length))];
    
    UIFont *eventFont = FONT_Heavy(16.0);;
    NSDictionary *eventDict = [NSDictionary dictionaryWithObjectsAndKeys:eventFont,NSFontAttributeName, [UIColor greenColor], NSForegroundColorAttributeName, nil];
    
    
    NSMutableAttributedString *eventNameString = [[NSMutableAttributedString alloc]initWithString: [[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"] attributes:eventDict];
    
    //[eventNameString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:228/255.0f green:123/255.0f blue:0 alpha:1] range:(NSMakeRange(0, eventNameString.length))];
    
    [nameString appendAttributedString:statusString];
    [nameString appendAttributedString:eventNameString];
    
    
    
    lblCellTitle.attributedText = nameString;
    
    void(^handler)(FRHyperLabel *label, NSString *substring) = ^(FRHyperLabel *label, NSString *substring){
        
        //  [self checkNameTag:substring Index:(int)indexPath.row];
       /* UIAlertController *controller = [UIAlertController alertControllerWithTitle:substring message:nil preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];*/
        
        [self customPostEvent:(int)indexPath.row];

        
    };
    
    //Step 3: Add link substrings
    if([[UIScreen mainScreen] bounds].size.width<=375)
    {
        [lblCellTitle setLinksForSubstrings:@[ [[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"]] withLinkHandler:handler];
    }
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"is_creater"] isEqualToString:@"Y"])
    {
        
        
        
        [btnReport setHidden:YES];
        [btnDelete setHidden:NO];
        
    }
    else
    {
        [btnDelete setHidden:YES];
        
        
        btnReport.frame = CGRectMake(btnReport.frame.origin.x+35, btnReport.frame.origin.y, btnReport.frame.size.width,btnReport.frame.size.height);
        btnShare.frame = CGRectMake(btnShare.frame.origin.x+35, btnShare.frame.origin.y, btnShare.frame.size.width,btnShare.frame.size.height);
    }
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"is_liked"] isEqualToString:@"Y"])
    {
        [btnLike setImage:[UIImage imageNamed:@"like2.png"] forState:UIControlStateNormal];
    }
    else
    {
        [btnLike setImage:[UIImage imageNamed:@"like1.png"] forState:UIControlStateNormal];
    }
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"is_reported"] isEqualToString:@"Y"])
    {
        [btnReport setImage:[UIImage imageNamed:@"flag2.png"] forState:UIControlStateNormal];
        [btnReport setEnabled:NO];
    }
    else
    {
        [btnReport setImage:[UIImage imageNamed:@"flag1.png"] forState:UIControlStateNormal];
        [btnReport setEnabled:YES];
        
    }
    
    
   // bgView.frame =CGRectMake(10, 10, self.view.bounds.size.width-20, bgView.frame.size.height+cellHeight);
    
    //btnView.frame =CGRectMake(btnView.frame.origin.x,cell.frame.size.height-55, bgView.frame.size.width, 46);
    
    //******** set replies View
    
    btnView.frame = CGRectMake(btnView.frame.origin.x,lblComment.frame.origin.y+lblComment.frame.size.height+13,bgView.frame.size.width, 46);
    
    
    
    int replyHeight = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"top_comments_count"] description] intValue] > 0 ? viewAllcommentsHeight : 0 + [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"] count]>0 ? replyCellHeight * (int)[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"] count] : 0 ;
    
    //1
    
    [replyView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    replyView = [[UIView alloc]initWithFrame:CGRectMake(btnView.frame.origin.x, btnView.frame.origin.y+btnView.frame.size.height, btnView.frame.size.width,replyHeight)];
    
    if ([[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"top_comments_count"] description] intValue] > 0)
    {
        
        //2
        
        viewAllReplies = [[UIButton alloc]initWithFrame:CGRectMake(7,0,replyView.frame.size.width-10,viewAllcommentsHeight)];
        
        viewAllReplies.tag = indexPath.row;
        
        [viewAllReplies addTarget:self action:@selector(openReplies:) forControlEvents:UIControlEventTouchUpInside];
        
        [viewAllReplies setTitle:[NSString stringWithFormat:@"View previous %@ replies",[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"top_comments_count"] description]] forState:UIControlStateNormal];
        
        viewAllReplies.titleLabel.font = FONT_Bold(13);
        
        [viewAllReplies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        viewAllReplies.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [replyView addSubview:viewAllReplies];
        
        for (int i=0; i< [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"] count]; i++)
        {
            
            //3
            UIView *viewReply = [[UIView alloc] initWithFrame:CGRectMake(0, replyCellHeight*(i+1), viewAllReplies.frame.size.width,replyCellHeight)];
            
            viewReply.backgroundColor = [UIColor whiteColor];
            
            
            if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"image"]isEqualToString:@""])
            {
                
                //4
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                
                //5
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                
                
                [lblUserName setText:userName];
                
                //6
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                if ([[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
                {
                    [lblComment setText:@"commented with image"];
                    
                }
                else{
                    
                    [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]];
                    
                }
                
                
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
                
                
            }
            else{
                
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"username"];
                
                
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth , 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]];
                
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            
            [replyView addSubview:viewReply];
            
        }
        
    }
    else
    {
        for (int i=0; i< [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"] count]; i++)
        {
            UIView *viewReply = [[UIView alloc] initWithFrame:CGRectMake(0, replyCellHeight*(i), viewAllReplies.frame.size.width,replyCellHeight)];
            
            viewReply.backgroundColor = [UIColor whiteColor];
            
            
            if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"image"]isEqualToString:@""])
            {
                
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                btnUSer.titleLabel.font = FONT_Bold(13);
                
                
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                if ([[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
                {
                    [lblComment setText:@"commented with image"];
                    
                }
                else{
                    
                    [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]];
                    
                }
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            else{
                
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                btnUSer.titleLabel.font = FONT_Bold(13);
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+lblUserName.frame.size.width + 5,5, replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"]objectAtIndex:i]valueForKey:@"comment"]];
                
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            
            [replyView addSubview:viewReply];
            
        }
    }
    
    
    // [replyView setBackgroundColor:[UIColor yellowColor]];
    
    [bgView addSubview:replyView];
    
    
    
    [bgView addSubview:imgUser];
    [bgView addSubview:btnProfile];
    
    [bgView addSubview:lblStatus];
    if([[UIScreen mainScreen] bounds].size.width>375)
    {
        [bgView addSubview:lblCellTitle];
        [bgView addSubview:btnEvent];
    }
    else
    {
        [bgView addSubview:btnEvent];
        [bgView addSubview:lblCellTitle];
        
    }
    [bgView addSubview:btnName];
    [bgView addSubview:lblDate];
    [bgView addSubview:lblComment];
    [btnView addSubview:btnLike];
    [btnView addSubview:lblLikeCount];
    [btnView addSubview:btnComment];
    [btnView addSubview:lblCommentCount];
    [btnView addSubview:btnDelete];
    [btnView addSubview:btnShare];
    [btnView addSubview:btnReport];
     [bgView addSubview:btnView];
    [cell.contentView addSubview:bgView];

    
    [bgView.layer setBorderColor:[UIColor lightTextColor].CGColor];
    [bgView.layer setBorderWidth:1.0f];
    
    [btnView.layer setBorderColor:[UIColor colorWithRed:232.0/255.0 green:235.0/255.0 blue:240.0/255.0 alpha:1.0].CGColor];
    [btnView.layer setBorderWidth:1.0f];
    
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    
    [imgUser setContentMode:UIViewContentModeScaleAspectFill];
    [imgUser setClipsToBounds:YES];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    nameDict =nil;
    nameString =nil;
    statusDict =nil;
    statusString =nil;
    eventDict =nil;
    eventNameString =nil;
    type =nil;
    nameFont =nil;
    statusFont =nil;
    eventFont =nil;

}

-(void)configureTimeLineCellComment:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell.contentView subviews]){
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    
    
    FRHyperLabel *lblCellTitle =[[FRHyperLabel alloc] init];
    UILabel *lblName=[[UILabel alloc] init];
    UILabel *lblStatus=[[UILabel alloc] init];
    UILabel *lblEventName=[[UILabel alloc] init];
    UILabel *lblDate=[[UILabel alloc] init];
    DAAttributedLabel *lblComment=[[DAAttributedLabel alloc] init];
    
    UIView *btnView=[[UIView alloc] init];
    
    UIImageView *imgUser=[[UIImageView alloc] init];
    UILabel *lblCommentCount=[[UILabel alloc] init];
    UIButton *btnLike=[[UIButton alloc] init];
    UILabel *lblLikeCount=[[UILabel alloc] init];
    UIButton *btnComment=[[UIButton alloc] init];
    UIButton *btnProfile=[[UIButton alloc] init];
    UIButton *btnShare=[[UIButton alloc] init];
    UIButton *btnReport=[[UIButton alloc] init];
    UIView *bgView=[[UIView alloc] init];
    UIButton *btnDelete=[[UIButton alloc] init];
    UIButton *btnEvent=[[UIButton alloc] init];;
    UIButton *btnName=[[UIButton alloc] init];
    
    
    
    UIButton *viewAllReplies = [[UIButton alloc] init];
    
    UIView *replyView = [[UIView alloc] init];
    
 
    
    
    
    bgView.frame =CGRectMake(10, 10, self.view.bounds.size.width-20, cell.frame.size.height-10);
    
    [bgView setBackgroundColor:[UIColor whiteColor]];
    
    imgUser.frame =CGRectMake(5, 9, 50, 50);
    [imgUser setImage:[UIImage imageNamed:@"iconBlack.png"]];
    
    btnProfile.frame =CGRectMake(5, 9, 48, 45);
    
    btnName.frame =CGRectMake(56, 0, 85, 20);//56 6 85 26
    
    btnEvent.frame =CGRectMake(139, 9, bgView.frame.size.width-140, 26);//139 9 153 26
    
    lblName.frame =CGRectMake(61, 6, 63, 26);//61 6 63 26
    // [bgView addSubview:lblName];
    
    lblStatus.frame =CGRectMake(123, 9, 93, 26);//123 9 93 26
    
    lblEventName.frame =CGRectMake(209, 6, bgView.frame.size.width-210, 26);//209 6 77 26
    //[bgView addSubview:lblEventName];
    
    lblCellTitle.frame =CGRectMake(61, 0, bgView.frame.size.width-62, 40);//61 0 231 40
    
    
    lblDate.frame =CGRectMake(61, 38, 124, 18);//61 38 124 18
    
    lblComment.frame =CGRectMake(5, 61, bgView.frame.size.width-10, 1);//5 61 290 1
    
    btnView.frame =CGRectMake(0, cell.frame.size.height-55, bgView.frame.size.width, 46);//0 70 300 46
    
    btnLike.frame =CGRectMake(0, 6, 32, 34);//0 6 32 34
    
    
    lblLikeCount.frame =CGRectMake(30, 3, 48, 40);//30 3 48 40
    
    btnComment.frame =CGRectMake(79, 6, 32, 34);//79 6 32 34
    
    lblCommentCount.frame =CGRectMake(113, 3, 85, 40);//30 3 85 40
    
    btnDelete.frame =CGRectMake(bgView.frame.size.width-32, 6, 32, 32);//268 6 32 34
    
    btnShare.frame =CGRectMake(bgView.frame.size.width-64, 6, 32, 34);//234 6 32 34
    
    btnReport.frame =CGRectMake(bgView.frame.size.width-96, 6, 32, 34);//198 6 32 34
    
    
    
    
    /**************** Add Targer to buttons *********/
    
    [btnReport addTarget:nil action:@selector(reportPostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnDelete addTarget:nil action:@selector(deletePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnLike addTarget:nil action:@selector(likePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnShare addTarget:nil action:@selector(sharePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnComment addTarget:nil action:@selector(commentPostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnProfile addTarget:nil action:@selector(profilePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnName addTarget:nil action:@selector(namePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if([[UIScreen mainScreen] bounds].size.width>375)
    {
        [btnEvent addTarget:nil action:@selector(eventPostTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
    [btnDelete setImage:[UIImage imageNamed:@"deleteNewIcon.png"] forState:UIControlStateNormal];
    
    [btnShare setImage:[UIImage imageNamed:@"shareNew2.png"] forState:UIControlStateNormal];
    [btnComment setImage:[UIImage imageNamed:@"commentIcon.png"] forState:UIControlStateNormal];
    
    
    
    
    /**************** Add label fonts *********/
    
    
    lblComment.font =FONT_Regular(14.0);
    //    [lblComment setNumberOfLines:0];
    //    [lblComment setMinimumScaleFactor:0.5];
    
    lblCommentCount.font =FONT_Regular(11.0);
    [lblCommentCount setNumberOfLines:0];
    [lblCommentCount setMinimumScaleFactor:0.5];
    
    
    lblDate.font =FONT_Regular(12.0);
    [lblDate setNumberOfLines:0];
    [lblDate setMinimumScaleFactor:0.5];
    
    
    lblLikeCount.font =FONT_Regular(11.0);
    [lblLikeCount setNumberOfLines:0];
    [lblLikeCount setMinimumScaleFactor:0.5];
    
    [lblCellTitle setNumberOfLines:0];
    [lblCellTitle setMinimumScaleFactor:0.5];
    
    lblComment.tag = indexPath.row;
    
    //NSLog(@"%@",timeLineArray);
    
    
    //********* get Height from here
    
    UserToHighlight = [[NSMutableArray alloc]init];
    
    CGFloat cellHeight = 0;
    
    if (![[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"comment"]isEqualToString:@""])
    {
        
        //cell.lblComment.hidden = NO;
        
        NSData *data = [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"comment"] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *decodedComment = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        DAAttributedLabel *lbl = [[DAAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, ScreenSize.width-30, 26)];
        
        
        lbl.text = [self DecodeCommentString:decodedComment usersTagged:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Tags"]];
        
        [lbl setPreferredHeight];
        
        cellHeight = [lbl getPreferredHeight];
        
        UserToHighlight = [[NSMutableArray alloc]init];
        
        lblComment.frame =CGRectMake(lblComment.frame.origin.x, lblComment.frame.origin.y, lblComment.frame.size.width, cellHeight);
        
        
        lblComment.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"comment"];
        
        
        lblComment.text = [self DecodeCommentString:decodedComment usersTagged:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Tags"]];
        
        [lblComment setPreferredHeight];
        
        lblComment.delegate = self;
        
        
        
    }
    else{
        
        lblComment.frame =CGRectMake(lblComment.frame.origin.x, lblComment.frame.origin.y, lblComment.frame.size.width,1);
        
        cellHeight = 1;
        
    }
    
    
    
    //CGFloat cellHeight =[self getLabelHeightForIndex:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"comment"]];
    
    NSString *type =[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"type"]];
    
    
    
    cell.clipsToBounds = YES;
    
    imgUser.layer.masksToBounds = YES;
    imgUser.layer.cornerRadius = 25.0;
    
    
    
    
    btnShare.tag =indexPath.row;
    btnReport.tag =indexPath.row;
    btnProfile.tag =indexPath.row;
    btnName.tag =indexPath.row;
    btnLike.tag =indexPath.row;
    btnEvent.tag =indexPath.row;
    btnDelete.tag =indexPath.row;
    
    
    
    
    //************* Add Tap Gesture on like Label ******
    
    UITapGestureRecognizer *likesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likecliked:)];
    likesRecognizer.delegate = self;
    [lblLikeCount setUserInteractionEnabled:YES];
    lblLikeCount.tag =indexPath.row;
    [lblLikeCount addGestureRecognizer:likesRecognizer];
    
    likesRecognizer = nil;
    
    //***********************
    
    UITapGestureRecognizer *tapCommentRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentTap:)];
    tapCommentRecognizer.delegate = self;
    [lblCommentCount setUserInteractionEnabled:YES];
    lblCommentCount.tag =indexPath.row;
    [lblCommentCount addGestureRecognizer:tapCommentRecognizer];
    
    tapCommentRecognizer =nil;
    
    /*************  User detail ******************/
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"thumb_image"] length]>0)
    {
        [imgUser sd_setImageWithURL:[NSURL URLWithString:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"thumb_image"]]];
    }
    
    lblName.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"name"];
    
    /*************  Event detail ******************/
    
    lblEventName.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"];
    
    /*************  Comment detail ******************/
    
    
    //******* set text here *****
    
    //    lblComment.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"comment"];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    
    lblDate.text =[self getDate:[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"time"] ];
    
    
    if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"like_count"]] isEqualToString:@"0"])
    {
        
        lblLikeCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"like_count"],[localization localizedStringForKey:@"Like"]];
    }
    else
    {
        lblLikeCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"like_count"],[localization localizedStringForKey:@"Likes"]];
    }
    
    // [cell.lblCommentCount setHidden:YES];
    // [cell.btnComment setHidden:YES];
    
    //Here
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Reply"]count]>1)
    {
        
        lblCommentCount.text =[NSString stringWithFormat:@"%d %@",(int)[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Reply"]count],[localization localizedStringForKey:@"Reply"]];
    }
    else
    {
        lblCommentCount.text =[NSString stringWithFormat:@"%d %@",(int)[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Reply"]count],[localization localizedStringForKey:@"Replies"]];
    }
    
    UIFont *nameFont = FONT_Heavy(16.0);;
    NSDictionary *nameDict = [NSDictionary dictionaryWithObject: nameFont forKey:NSFontAttributeName];
    NSMutableAttributedString *nameString;
    
    if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
    {
        if([type isEqualToString:@"CL"])
        {
            nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You2"] attributes: nameDict];
            
        }
        else
        {
            nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You"] attributes: nameDict];
        }
        // nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You"] attributes: nameDict];
    }
    else
    {
        nameString = [[NSMutableAttributedString alloc] initWithString:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"name"] attributes: nameDict];
    }
    [nameString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:228/255.0f green:123/255.0f blue:0 alpha:1] range:(NSMakeRange(0, nameString.length))];
    
    
    UIFont *statusFont = FONT_Regular(16.0);
    NSDictionary *statusDict = [NSDictionary dictionaryWithObject:statusFont forKey:NSFontAttributeName];
    NSMutableAttributedString *statusString;
    
    if([type isEqualToString:@"CL"])
    {
        
        //statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"liked a comment on"]] attributes:statusDict];
        
        if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"liked a comment on2"]] attributes:statusDict];
        }
        else
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"liked a comment on"]] attributes:statusDict];
        }
    }
    else
    {
        if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"commented on2"]] attributes:statusDict];
        }
        else
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"commented on"]] attributes:statusDict];
        }
        
        
        
    }
    
    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:(NSMakeRange(0, statusString.length))];
    
    UIFont *eventFont = FONT_Heavy(16.0);;
    NSDictionary *eventDict = [NSDictionary dictionaryWithObjectsAndKeys:eventFont,NSFontAttributeName, [UIColor greenColor], NSForegroundColorAttributeName, nil];
    
    //dictionaryWithObject:eventFont forKey:NSFontAttributeName];
    
    NSMutableAttributedString *eventNameString = [[NSMutableAttributedString alloc]initWithString: [[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"] attributes:eventDict];
    
    //[eventNameString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:228/255.0f green:123/255.0f blue:0 alpha:1] range:(NSMakeRange(0, eventNameString.length))];
    
    [nameString appendAttributedString:statusString];
    [nameString appendAttributedString:eventNameString];
    
    
    
    lblCellTitle.attributedText = nameString;
    
    void(^handler)(FRHyperLabel *label, NSString *substring) = ^(FRHyperLabel *label, NSString *substring){
        
        //  [self checkNameTag:substring Index:(int)indexPath.row];
        /* UIAlertController *controller = [UIAlertController alertControllerWithTitle:substring message:nil preferredStyle:UIAlertControllerStyleAlert];
         [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
         [self presentViewController:controller animated:YES completion:nil];*/
        
        [self customPostEvent:(int)indexPath.row];
        
    };
    
    //Step 3: Add link substrings
    
    
    if([[UIScreen mainScreen] bounds].size.width<=375)
    {
        [lblCellTitle setLinksForSubstrings:@[ [[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"]] withLinkHandler:handler];
    }
    
    
    //******************** Manage Flag / Delete Here
    
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"is_delete"] isEqualToString:@"Y"])
    {
        
        //        NSLog(@"%@",[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]]);
        //
        //        NSLog(@"%@",[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]);
        
        //
        //        if ([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"userid"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
        //        {
        //
        //
        //            [btnReport setHidden:YES];
        //
        //
        //
        //        }
        //        else{
        
        [btnReport setHidden:YES];
        
        // }
        
        [btnDelete setHidden:NO];
        // [cell.btnDelete setEnabled:YES];
    }
    else
    {
        
        
        if ([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
        {
            
            
            
            
            
        }
        else{
            
            
            
        }
        
        
        
        
        
        [btnDelete setHidden:YES];
        //[cell.btnDelete setEnabled:NO];
        btnReport.frame = CGRectMake(btnReport.frame.origin.x+35, btnReport.frame.origin.y, btnReport.frame.size.width,btnReport.frame.size.height);
        btnShare.frame = CGRectMake(btnShare.frame.origin.x+35, btnShare.frame.origin.y, btnShare.frame.size.width,btnShare.frame.size.height);
        
    }
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"is_liked"] isEqualToString:@"Y"])
    {
        [btnLike setImage:[UIImage imageNamed:@"like2.png"] forState:UIControlStateNormal];
    }
    else
    {
        [btnLike setImage:[UIImage imageNamed:@"like1.png"] forState:UIControlStateNormal];
    }
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"is_reported"] isEqualToString:@"Y"])
    {
        [btnReport setImage:[UIImage imageNamed:@"flag2.png"] forState:UIControlStateNormal];
        [btnReport setEnabled:NO];
    }
    else
    {
        [btnReport setImage:[UIImage imageNamed:@"flag1.png"] forState:UIControlStateNormal];
        [btnReport setEnabled:YES];
        
    }
    
    
    //bgView.frame =CGRectMake(10, 10, self.view.bounds.size.width-20, bgView.frame.size.height+cellHeight);
    
    //btnView.frame =CGRectMake(btnView.frame.origin.x, cell.frame.size.height-55, bgView.frame.size.width, 46);
    
    
    //******** set replies View
    
    btnView.frame = CGRectMake(btnView.frame.origin.x,lblComment.frame.origin.y+lblComment.frame.size.height+13,bgView.frame.size.width, 46);
    

    
    int replyHeight = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"top_replys_count"] description] intValue] > 0 ? viewAllcommentsHeight : 0 + [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"] count]>0 ? replyCellHeight * (int)[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"] count] : 0 ;
    
    //1

    [replyView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    replyView = [[UIView alloc]initWithFrame:CGRectMake(btnView.frame.origin.x, btnView.frame.origin.y+btnView.frame.size.height, btnView.frame.size.width,replyHeight)];
    
    if ([[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"top_replys_count"] description] intValue] > 0)
    {
        
        //2
        
        viewAllReplies = [[UIButton alloc]initWithFrame:CGRectMake(7,0,replyView.frame.size.width-10,viewAllcommentsHeight)];
        
        viewAllReplies.tag = indexPath.row;
    
        [viewAllReplies addTarget:self action:@selector(openReplies:) forControlEvents:UIControlEventTouchUpInside];
        
    
        [viewAllReplies setTitle:[NSString stringWithFormat:@"View previous %@ replies",[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"top_replys_count"] description]] forState:UIControlStateNormal];
        
        
        
        viewAllReplies.titleLabel.font = FONT_Bold(13);
        
        [viewAllReplies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
        viewAllReplies.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
       
        [replyView addSubview:viewAllReplies];
        
        for (int i=0; i< [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"] count]; i++)
        {
            
            //3
            UIView *viewReply = [[UIView alloc] initWithFrame:CGRectMake(0, replyCellHeight*(i+1), viewAllReplies.frame.size.width,replyCellHeight)];
            
            viewReply.backgroundColor = [UIColor whiteColor];
            
            
            if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"image"]isEqualToString:@""])
            {
                
                //4
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                
                //5
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                  lblUserName.font = FONT_Bold(13);
                
                 [lblUserName setTextColor:[UIColor blackColor]];
                
                
                
                [lblUserName setText:userName];
                
                //6
                
                 UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                if ([[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
                {
                    [lblComment setText:@"commented with image"];
                    
                }
                else{
                    
                    [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
                    
                }
                
            
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            
                
            }
            else{
                
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
                
                
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth , 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setText:userName];
                
                
                
               UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
                
              
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            
            [replyView addSubview:viewReply];
            
        }
  
    }
    else
    {
        for (int i=0; i< [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"] count]; i++)
        {
            UIView *viewReply = [[UIView alloc] initWithFrame:CGRectMake(0, replyCellHeight*(i), viewAllReplies.frame.size.width,replyCellHeight)];
            
            viewReply.backgroundColor = [UIColor whiteColor];
            
            
            if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"image"]isEqualToString:@""])
            {
                
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                btnUSer.titleLabel.font = FONT_Bold(13);
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                 lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                if ([[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
                {
                    [lblComment setText:@"commented with image"];
                    
                }
                else{
                    
                    [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
                    
                }
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            else{
                
                
               UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                btnUSer.titleLabel.font = FONT_Bold(13);
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+lblUserName.frame.size.width + 5,5, replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
               
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            
            [replyView addSubview:viewReply];
            
        }
    }
    
  
   // [replyView setBackgroundColor:[UIColor yellowColor]];
    
    [bgView addSubview:replyView];
    
   

    
    
    [bgView addSubview:imgUser];
    [bgView addSubview:btnProfile];
    [bgView addSubview:lblStatus];
    if([[UIScreen mainScreen] bounds].size.width>375)
    {
        [bgView addSubview:lblCellTitle];
        [bgView addSubview:btnEvent];
    }
    else
    {
        [bgView addSubview:btnEvent];
        [bgView addSubview:lblCellTitle];
        
    }
    [bgView addSubview:btnName];
    [bgView addSubview:lblDate];
    [bgView addSubview:lblComment];
    
    [btnView addSubview:btnLike];
    [btnView addSubview:lblLikeCount];
    [btnView addSubview:btnComment];
    [btnView addSubview:lblCommentCount];
    [btnView addSubview:btnDelete];
    [btnView addSubview:btnShare];
    [btnView addSubview:btnReport];
    [bgView addSubview:btnView];
    [cell.contentView addSubview:bgView];
    
    
    [bgView.layer setBorderColor:[UIColor lightTextColor].CGColor];
    [bgView.layer setBorderWidth:1.0f];
    
    [btnView.layer setBorderColor:[UIColor colorWithRed:232.0/255.0 green:235.0/255.0 blue:240.0/255.0 alpha:1.0].CGColor];
    [btnView.layer setBorderWidth:1.0f];
    
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    
    [imgUser setContentMode:UIViewContentModeScaleAspectFill];
    [imgUser setClipsToBounds:YES];
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    nameDict =nil;
    nameString =nil;
    statusDict =nil;
    statusString =nil;
    eventDict =nil;
    eventNameString =nil;
    type =nil;
    nameFont =nil;
    statusFont =nil;
    eventFont =nil;
    
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
-(void)configureTimeLineCellCommentWithImage:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell.contentView subviews]){
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    
    FRHyperLabel *lblCellTitle =[[FRHyperLabel alloc] init];
    UILabel *lblName=[[UILabel alloc] init];
    UILabel *lblStatus=[[UILabel alloc] init];
    UILabel *lblEventName=[[UILabel alloc] init];
    UILabel *lblDate=[[UILabel alloc] init];
    DAAttributedLabel *lblComment=[[DAAttributedLabel alloc] init];
    UIView *btnView=[[UIView alloc] init];
    
    UIImageView *imgUser=[[UIImageView alloc] init];
    UIImageView *imgComment=[[UIImageView alloc] init];
    
    UILabel *lblCommentCount=[[UILabel alloc] init];
    UIButton *btnLike=[[UIButton alloc] init];
    UILabel *lblLikeCount=[[UILabel alloc] init];
    UIButton *btnComment=[[UIButton alloc] init];
    UIButton *btnProfile=[[UIButton alloc] init];
    UIButton *btnShare=[[UIButton alloc] init];
    UIButton *btnReport=[[UIButton alloc] init];
    UIView *bgView=[[UIView alloc] init];
    UIButton *btnDelete=[[UIButton alloc] init];
    UIButton *btnEvent=[[UIButton alloc] init];;
    UIButton *btnName=[[UIButton alloc] init];

    UIButton *viewAllReplies = [[UIButton alloc] init];
    
    UIView *replyView = [[UIView alloc] init];
   
    
    bgView.frame =CGRectMake(10, 10, self.view.bounds.size.width-20, cell.frame.size.height- 10);
    [bgView setBackgroundColor:[UIColor whiteColor]];

    
    imgUser.frame =CGRectMake(5, 9, 50, 50);
    [imgUser setImage:[UIImage imageNamed:@"iconBlack.png"]];
    
    
    
    
    btnProfile.frame =CGRectMake(5, 9, 48, 45);
    
    
    
    btnName.frame =CGRectMake(56, 0, 85, 20);//56 6 85 26
   
    
    btnEvent.frame =CGRectMake(139, 9, bgView.frame.size.width-140, 26);//139 9 153 26
    
    
    lblName.frame =CGRectMake(61, 6, 63, 26);//61 6 63 26
   // [bgView addSubview:lblName];
    
    lblStatus.frame =CGRectMake(123, 9, 93, 26);//123 9 93 26
    
    
    lblEventName.frame =CGRectMake(209, 6, bgView.frame.size.width-210, 26);//209 6 77 26
   // [bgView addSubview:lblEventName];
    
    lblCellTitle.frame =CGRectMake(61, 0, bgView.frame.size.width-62, 40);//61 0 231 40
    
    
    
    lblDate.frame =CGRectMake(61, 38, 124, 18);//61 38 124 18
    
    
    lblComment.frame =CGRectMake(5, 61, bgView.frame.size.width-10, 1);//5 61 290 1
    
    
    
    imgComment.frame = CGRectMake(0, 76,bgView.frame.size.width, 215);
    
    
    if(IS_IPHONE_4s || IS_IPHONE_5)
    {
       // imgComment.frame =CGRectMake(0, 76, 300, 215);// 0 76 300 215
        
    }
    else
    {
        //float x = (bgView.frame.size.width-300)/2;
        //imgComment.frame =CGRectMake(x, 76, 300, 215);// 0 76 300 215
        
    }
    
    
    btnView.frame =CGRectMake(0, cell.frame.size.height-55, bgView.frame.size.width, 46);//0 70 300 46
    
    
    btnLike.frame =CGRectMake(0, 6, 32, 34);//0 6 32 34
    
    
    lblLikeCount.frame =CGRectMake(30, 3, 48, 40);//30 3 48 40
    
    
    
    btnComment.frame =CGRectMake(79, 6, 32, 34);//79 6 32 34
    
    
    lblCommentCount.frame =CGRectMake(113, 3, 85, 40);//30 3 85 40
    
    
    btnDelete.frame =CGRectMake(bgView.frame.size.width-32, 6, 32, 32);//268 6 32 34
    
    
    btnShare.frame =CGRectMake(bgView.frame.size.width-64, 6, 32, 34);//234 6 32 34
    
    
    btnReport.frame =CGRectMake(bgView.frame.size.width-96, 6, 32, 34);//198 6 32 34
    
    
    /**************** Add Targer to buttons *********/
    
    [btnReport addTarget:nil action:@selector(reportPostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnDelete addTarget:nil action:@selector(deletePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnLike addTarget:nil action:@selector(likePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnShare addTarget:nil action:@selector(sharePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnComment addTarget:nil action:@selector(commentPostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnProfile addTarget:nil action:@selector(profilePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnName addTarget:nil action:@selector(namePostTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if([[UIScreen mainScreen] bounds].size.width>375)
    {
        [btnEvent addTarget:nil action:@selector(eventPostTapped:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    [btnDelete setImage:[UIImage imageNamed:@"deleteNewIcon.png"] forState:UIControlStateNormal];
    [btnShare setImage:[UIImage imageNamed:@"shareNew2.png"] forState:UIControlStateNormal];
    [btnComment setImage:[UIImage imageNamed:@"commentIcon.png"] forState:UIControlStateNormal];
    
    
    
    
    /**************** Add label fonts *********/
    
    
    lblComment.font =FONT_Regular(14.0);
    //[lblComment setNumberOfLines:0];
    //[lblComment setMinimumScaleFactor:0.5];
    
    lblCommentCount.font =FONT_Regular(11.0);
    [lblCommentCount setNumberOfLines:0];
    [lblCommentCount setMinimumScaleFactor:0.5];
    
    
    lblDate.font =FONT_Regular(12.0);
    [lblDate setNumberOfLines:0];
    [lblDate setMinimumScaleFactor:0.5];
    
    
    lblLikeCount.font =FONT_Regular(11.0);
    [lblLikeCount setNumberOfLines:0];
    [lblLikeCount setMinimumScaleFactor:0.5];
    
    [lblCellTitle setNumberOfLines:0];
    [lblCellTitle setMinimumScaleFactor:0.5];
    
    
    
    //here
    
    
    
    UserToHighlight = [[NSMutableArray alloc]init];
    
    CGFloat cellHeight = 0;
    
    if (![[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"comment"]isEqualToString:@""])
    {
        
        //cell.lblComment.hidden = NO;
        
        NSData *data = [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"comment"] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *decodedComment = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        DAAttributedLabel *lbl = [[DAAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, ScreenSize.width-30, 26)];
        
        
        lbl.text = [self DecodeCommentString:decodedComment usersTagged:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Tags"]];
        
        [lbl setPreferredHeight];
        
        cellHeight = [lbl getPreferredHeight];
        
        UserToHighlight = [[NSMutableArray alloc]init];
        
        lblComment.frame =CGRectMake(lblComment.frame.origin.x, lblComment.frame.origin.y, lblComment.frame.size.width, cellHeight);
        
        
        lblComment.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"comment"];
        
        
        lblComment.text = [self DecodeCommentString:decodedComment usersTagged:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Tags"]];
        
        [lblComment setPreferredHeight];
        
        lblComment.delegate = self;
        
        
        
    }
    else{
        
        lblComment.frame =CGRectMake(lblComment.frame.origin.x, lblComment.frame.origin.y, lblComment.frame.size.width,1);
        
        cellHeight = 1;
        
    }
    

    
    NSString *type =[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"type"]];
 
  
    
    imgUser.layer.masksToBounds = YES;
    imgUser.layer.cornerRadius = 25.0;
    
    btnShare.tag =indexPath.row;
    btnReport.tag =indexPath.row;
    btnProfile.tag =indexPath.row;
    btnName.tag =indexPath.row;
    btnLike.tag =indexPath.row;
    btnEvent.tag =indexPath.row;
    btnDelete.tag =indexPath.row;
    if(IS_Ipad)
    {
        btnEvent.frame = CGRectMake(lblCellTitle.frame.origin.x, btnEvent.frame.origin.y, btnEvent.frame.size.width+100, btnEvent.frame.size.height);
    }
    
    
    
    //************* Add Tap Gesture on like Label ******
    
    UITapGestureRecognizer *likesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likecliked:)];
    likesRecognizer.delegate = self;
    [lblLikeCount setUserInteractionEnabled:YES];
    lblLikeCount.tag =indexPath.row;
    [lblLikeCount addGestureRecognizer:likesRecognizer];
    
    likesRecognizer = nil;
    
    //***********************
    
    
    UITapGestureRecognizer *tapCommentRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentTap:)];
    tapCommentRecognizer.delegate = self;
    [lblCommentCount setUserInteractionEnabled:YES];
    lblCommentCount.tag =indexPath.row;
    [lblCommentCount addGestureRecognizer:tapCommentRecognizer];
    
    tapCommentRecognizer =nil;
    
    
    
    /*************  User detail ******************/
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"thumb_image"] length]>0)
    {
        [imgUser sd_setImageWithURL:[NSURL URLWithString:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"thumb_image"]]];
        
    }
    
    lblName.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"name"];
    
    /*************  Event detail ******************/
    
    lblEventName.text =[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"];
    
    /*************  Comment detail ******************/
    
    imgComment.tag = indexPath.row;
    

//    [imgComment sd_setImageWithURL:[NSURL URLWithString:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"image"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if (image)
//        {
//            
//            
////            UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
////            tapGestureRecognizer2.delegate = self;
////            [imgComment setUserInteractionEnabled:YES];
////            imgComment.tag =indexPath.row;
////            [imgComment addGestureRecognizer:tapGestureRecognizer2];
////            tapGestureRecognizer2 =nil;
//
//            
//            UIImage * image1=[self drawImage:image inRect: CGRectMake(0, 0, self.view.bounds.size.width, imgComment.bounds.size.height)];
//            
//            imgComment.image =nil;
//            imgComment.image =image1;
//            
//            if(IS_Ipad)
//            {
//                imgComment.contentMode = UIViewContentModeScaleAspectFill;
//                
//            }
//            
//            
//            
//            
//            image1 =nil;
//            
//            
//        }
//    }];
    
    
    
    
    
    if ([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]count]==1)
    {
        
       // cell.imgComment.hidden = NO;
        
        [imgComment sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:0] valueForKey:@"image"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
            {
                
                // UIImage * image1=[self drawImage:image inRect:cell.imgComment.bounds];
                UIImage * image1=[self drawImage:image inRect:imgComment.frame];
                
                imgComment.image =image1;
                
                [imgComment setupImageViewerWithDatasource:self initialIndex:0 onOpen:^{


                    NSLog(@"onOpen");

                } onClose:^{


                }];

            }
        }];
        
    }
    else
    {
        
        
        
        //imgComment.hidden = NO;
        
        NSMutableArray *imgAry = [[NSMutableArray alloc]initWithArray:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]];
        
        
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
                
               // NSLog(@"%@",NSStringFromCGRect(imgComment.frame));
                
                ViewTwoImages.frame = imgComment.frame;
                
                 //NSLog(@"%@",NSStringFromCGRect(ViewTwoImages.frame));
                
                [ViewTwoImages.view2image1 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:0]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
                [ViewTwoImages.view2image2 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:1]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
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
                
          
                
                [ViewTwoImages.view2image1 setupImageViewerWithDatasource:self initialIndex:0 onOpen:^{


                } onClose:^{


                }];

                [ViewTwoImages.view2image2 setupImageViewerWithDatasource:self  initialIndex:1 onOpen:^{


                } onClose:^{


                }];
                
                
                 ViewTwoImages.frame = CGRectMake(0, lblComment.frame.origin.y+cellHeight, bgView.frame.size.width,imgComment.frame.size.height+15);
              
                [bgView addSubview:ViewTwoImages];
                
                
                break;
                
            case 3:
                
                ViewTwoImages = nil;
                ViewFourImages = nil;
                ViewFiveImages = nil;
                
                
                
                ViewThreeImages.translatesAutoresizingMaskIntoConstraints = YES;
                
                
                ViewThreeImages.frame = imgComment.frame;
                
                [ViewThreeImages.view3image1 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:0]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
                [ViewThreeImages.view3image2 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:1]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                [ViewThreeImages.view3image3 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:2]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
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
                
                
                
                ViewThreeImages.frame = CGRectMake(0, lblComment.frame.origin.y+cellHeight, bgView.frame.size.width,imgComment.frame.size.height+15);
                
              
                [bgView  addSubview:ViewThreeImages];
                
                
                
                break;
                
            case 4:
                
                ViewTwoImages = nil;
                ViewThreeImages = nil;
                ViewFiveImages = nil;
                
                
                ViewFourImages.translatesAutoresizingMaskIntoConstraints = YES;
                
                
                ViewFourImages.frame = imgComment.frame;
                
                [ViewFourImages.view4image1 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:0]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
                [ViewFourImages.view4image2 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:1]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                [ViewFourImages.view4image3 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:2]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
                [ViewFourImages.view4image4 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:3]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
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
                
                
                ViewFourImages.frame = CGRectMake(0, lblComment.frame.origin.y+cellHeight, bgView.frame.size.width,imgComment.frame.size.height+15);
             
                [bgView  addSubview:ViewFourImages];
                
                
                break;
                
                
            case 5:
                
                ViewTwoImages = nil;
                ViewThreeImages = nil;
                ViewFourImages = nil;
                
                
                ViewFiveImages.translatesAutoresizingMaskIntoConstraints = YES;
                
                
                ViewFiveImages.frame = imgComment.frame;
                
                [ViewFiveImages.view5image1 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:0]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
                [ViewFiveImages.view5image2 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:1]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                [ViewFiveImages.view5image3 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:2]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
                [ViewFiveImages.view5image4 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:3]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                [ViewFiveImages.view5image5 sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:4]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                
                
                
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
                
                
                ViewFiveImages.frame = CGRectMake(0, lblComment.frame.origin.y+cellHeight, bgView.frame.size.width,imgComment.frame.size.height+15);
              
                [bgView addSubview:ViewFiveImages];
                
                
                
                break;
                
                
            default:
                break;
        }
        
        
        
    }
    
 
   
    
    lblDate.text =[self getDate:[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"time"] ];
    
    
    // [cell.lblCommentCount setHidden:YES];
    // [cell.btnComment setHidden:YES];
    
    
    //here
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Reply"]count]>1)
    {
        
        lblCommentCount.text =[NSString stringWithFormat:@"%d %@",(int)[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Reply"]count],[localization localizedStringForKey:@"Reply"]];
    }
    else
    {
        lblCommentCount.text =[NSString stringWithFormat:@"%d %@",(int)[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Reply"]count],[localization localizedStringForKey:@"Replies"]];
    }
    
    
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"is_delete"] isEqualToString:@"Y"])
    {
        [btnDelete setHidden:NO];
        // [cell.btnDelete setEnabled:YES];
        
        
    }
    else
    {
        [btnDelete setHidden:YES];
        // [cell.btnDelete setEnabled:NO];
        btnReport.frame = CGRectMake(btnReport.frame.origin.x+35, btnReport.frame.origin.y, btnReport.frame.size.width,btnReport.frame.size.height);
        btnShare.frame = CGRectMake(btnShare.frame.origin.x+35, btnShare.frame.origin.y, btnShare.frame.size.width,btnShare.frame.size.height);
        
    }
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"is_liked"] isEqualToString:@"Y"])
    {
        [btnLike setImage:[UIImage imageNamed:@"like2.png"] forState:UIControlStateNormal];
    }
    else
    {
        [btnLike setImage:[UIImage imageNamed:@"like1.png"] forState:UIControlStateNormal];
    }
    
    if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"is_reported"] isEqualToString:@"Y"])
    {
        [btnReport setImage:[UIImage imageNamed:@"flag2.png"] forState:UIControlStateNormal];
        [btnReport setEnabled:NO];
    }
    else
    {
        [btnReport setImage:[UIImage imageNamed:@"flag1.png"] forState:UIControlStateNormal];
        [btnReport setEnabled:YES];
        
    }
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UIFont *nameFont = FONT_Heavy(16.0);
    NSDictionary *nameDict = [NSDictionary dictionaryWithObject: nameFont forKey:NSFontAttributeName];
    NSMutableAttributedString *nameString;
    
    if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
    {
        if([type isEqualToString:@"CL"])
        {
            nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You2"] attributes: nameDict];
            
        }
        else
        {
            nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You"] attributes: nameDict];
        }
        //nameString = [[NSMutableAttributedString alloc] initWithString:[localization localizedStringForKey:@"You"] attributes: nameDict];
    }
    else
    {
        nameString = [[NSMutableAttributedString alloc] initWithString:[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"name"] attributes: nameDict];
    }
    
    
    
    [nameString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:228/255.0f green:123/255.0f blue:0 alpha:1] range:(NSMakeRange(0, nameString.length))];
    
    
    UIFont *statusFont = FONT_Regular(16.0);
    NSDictionary *statusDict = [NSDictionary dictionaryWithObject:statusFont forKey:NSFontAttributeName];
    NSMutableAttributedString *statusString;
    
    if([type isEqualToString:@"CL"])
    {
        if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
        {
             statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"liked a comment on2"]] attributes:statusDict];
        }
        else
        {
             statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"liked a comment on"]] attributes:statusDict];
        }
        
       
    }
    else
    {
        
        if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"User"] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]])
        {
           statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"commented on2"]] attributes:statusDict];
        }
        else
        {
            statusString = [[NSMutableAttributedString alloc]initWithString: [NSString stringWithFormat:@" %@ ",[localization localizedStringForKey:@"commented on"]] attributes:statusDict];
        }
        
        
    }
    
    [statusString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:(NSMakeRange(0, statusString.length))];
    
    UIFont *eventFont = FONT_Heavy(16.0);;
    NSDictionary *eventDict = [NSDictionary dictionaryWithObjectsAndKeys:eventFont,NSFontAttributeName, [UIColor greenColor], NSForegroundColorAttributeName, nil];
    
    
    NSMutableAttributedString *eventNameString = [[NSMutableAttributedString alloc] initWithString: [[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"] attributes:eventDict];
    
    //[eventNameString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:228/255.0f green:123/255.0f blue:0 alpha:1] range:(NSMakeRange(0, eventNameString.length))];
    
    
    [nameString appendAttributedString:statusString];
    [nameString appendAttributedString:eventNameString];
    
    
    lblCellTitle.attributedText = nameString;
    
    void(^handler)(FRHyperLabel *label, NSString *substring) = ^(FRHyperLabel *label, NSString *substring){
        
        //  [self checkNameTag:substring Index:(int)indexPath.row];
       /* UIAlertController *controller = [UIAlertController alertControllerWithTitle:substring message:nil preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];*/
        [self customPostEvent:(int)indexPath.row];

        
    };
    
    //Step 3: Add link substrings
    if([[UIScreen mainScreen] bounds].size.width<=375)
    {
        [lblCellTitle setLinksForSubstrings:@[ [[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"name"]] withLinkHandler:handler];
    }
    
    //   NSLog(@"cell frame is %@", NSStringFromCGRect(cell.frame));
    
    
    bgView.frame =CGRectMake(10, 10, self.view.bounds.size.width-20, bgView.frame.size.height);
    
   // NSLog(@"bgView frame is %@", NSStringFromCGRect(bgView.frame));
    
   
    
    
    
    //   NSLog(@"image frame is %@", NSStringFromCGRect(cell.imgComment.frame));
    
    
    [bgView.layer setBorderColor:[UIColor lightTextColor].CGColor];
    [bgView.layer setBorderWidth:1.0f];
    
   // btnView.frame =CGRectMake(btnView.frame.origin.x, cell.frame.size.height-55, bgView.frame.size.width, 46);
    
    //[btnView setBackgroundColor:[UIColor whiteColor]];
    
    //  NSLog(@"btnView frame is %@", NSStringFromCGRect(cell.btnView.frame));
    
    if([[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"like_count"]] isEqualToString:@"0"])
    {
        
        lblLikeCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"like_count"],[localization localizedStringForKey:@"Like"]];
    }
    else
    {
        lblLikeCount.text =[NSString stringWithFormat:@"%@ %@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"like_count"],[localization localizedStringForKey:@"Likes"]];
    }
    
   
    
   imgComment.frame=CGRectMake(imgComment.frame.origin.x, lblComment.frame.origin.y+cellHeight,imgComment.frame.size.width, imgComment.frame.size.height);
    
    
    //******** set replies View
    
   btnView.frame = CGRectMake(btnView.frame.origin.x,lblComment.frame.origin.y+cellHeight+imgComment.frame.size.height+15,bgView.frame.size.width, 46);
    
    
    
    int replyHeight = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"top_replys_count"] description] intValue] > 0 ? viewAllcommentsHeight : 0 + [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"] count]>0 ? replyCellHeight * (int)[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"] count] : 0 ;
    
    //1
    
    [replyView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    replyView = [[UIView alloc]initWithFrame:CGRectMake(btnView.frame.origin.x, btnView.frame.origin.y+btnView.frame.size.height, btnView.frame.size.width,replyHeight)];
    
    if ([[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"top_replys_count"] description] intValue] > 0)
    {
        
        //2
        
        viewAllReplies = [[UIButton alloc]initWithFrame:CGRectMake(7,0,replyView.frame.size.width-10,viewAllcommentsHeight)];
        
        viewAllReplies.tag = indexPath.row;
        
        [viewAllReplies addTarget:self action:@selector(openReplies:) forControlEvents:UIControlEventTouchUpInside];
        
        [viewAllReplies setTitle:[NSString stringWithFormat:@"View previous %@ replies",[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"top_replys_count"] description]] forState:UIControlStateNormal];
        
        viewAllReplies.titleLabel.font = FONT_Bold(13);
        
        
        
        [viewAllReplies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        viewAllReplies.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [replyView addSubview:viewAllReplies];
        
        for (int i=0; i< [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"] count]; i++)
        {
            
            //3
            UIView *viewReply = [[UIView alloc] initWithFrame:CGRectMake(0, replyCellHeight*(i+1), viewAllReplies.frame.size.width,replyCellHeight)];
            
            viewReply.backgroundColor = [UIColor whiteColor];
            
            
            if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"image"]isEqualToString:@""])
            {
                
                //4
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                
                //5
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                
                
                [lblUserName setText:userName];
                
                //6
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                
                if ([[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
                {
                    [lblComment setText:@"commented with image"];
                    
                }
                else{
                    
                     [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
                    
                }
                
        
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
                
                
            }
            else{
                
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
                
                
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth , 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
                
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            
            [replyView addSubview:viewReply];
            
        }
        
    }
    else
    {
        for (int i=0; i< [[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"] count]; i++)
        {
            UIView *viewReply = [[UIView alloc] initWithFrame:CGRectMake(0, replyCellHeight*(i), viewAllReplies.frame.size.width,replyCellHeight)];
            
            viewReply.backgroundColor = [UIColor whiteColor];
            
            
            if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"image"]isEqualToString:@""])
            {
                
                
                UIButton *btnUSer = [[UIButton alloc] initWithFrame:CGRectMake(10,5, 30, 30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                btnUSer.titleLabel.font = FONT_Bold(13);
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+ lblUserName.frame.size.width + 5,5,replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                
                if ([[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]isEqualToString:@""])
                {
                    [lblComment setText:@"commented with image"];
                    
                }
                else{
                    
                    [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
                    
                }
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            else{
                
                
                UIButton *btnUSer = [[UIButton alloc]initWithFrame:CGRectMake(10,5, 30,30)];
                btnUSer.contentMode = UIViewContentModeScaleAspectFill;
                btnUSer.layer.cornerRadius = btnUSer.frame.size.width/2;
                [btnUSer setClipsToBounds:YES];
                
                btnUSer.titleLabel.font = FONT_Bold(13);
                
                if (![[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]isEqualToString:@""])
                {
                    
                    [btnUSer sd_setImageWithURL:[NSURL URLWithString:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"userimage_thumb"]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                }
                else{
                    
                    [btnUSer setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
                }
                
                
                
                NSString *userName = [[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"username"];
                
                int userNameWidth = [self getTextWidth:userName];
                
                UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(btnUSer.frame.origin.x+btnUSer.frame.size.width + 5,5, userNameWidth, 30)];
                
                [lblUserName setTextAlignment:NSTextAlignmentCenter];
                
                [lblUserName setTextColor:[UIColor blackColor]];
                
                lblUserName.font = FONT_Bold(13);
                
                [lblUserName setText:userName];
                
                
                
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblUserName.frame.origin.x+lblUserName.frame.size.width + 5,5, replyView.frame.size.width - (60+lblUserName.frame.size.width), 30)];
                
                [lblComment setTextColor:[UIColor lightGrayColor]];
                
                lblComment.font = [UIFont fontWithName:self.lblTitle.font.fontName size:13];
                
                [lblComment setText:[[[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"]objectAtIndex:i]valueForKey:@"comment"]];
                
                
                [viewReply addSubview:btnUSer];
                
                [viewReply addSubview:lblUserName];
                
                [viewReply addSubview:lblComment];
                
                
            }
            
            [replyView addSubview:viewReply];
            
        }
    }
    
    
    // [replyView setBackgroundColor:[UIColor yellowColor]];
    
    [bgView addSubview:replyView];
    
    
    
   
    
    [bgView addSubview:imgUser];
    [bgView addSubview:btnProfile];
    
    [bgView addSubview:lblStatus];
    if([[UIScreen mainScreen] bounds].size.width>375)
    {
        [bgView addSubview:lblCellTitle];
        [bgView addSubview:btnEvent];
    }
    else
    {
        [bgView addSubview:btnEvent];
        [bgView addSubview:lblCellTitle];
        
    }
    [bgView addSubview:btnName];
    [bgView addSubview:lblDate];
    [bgView addSubview:lblComment];
    [bgView addSubview:imgComment];
    [btnView addSubview:btnLike];
    [btnView addSubview:lblLikeCount];
    [btnView addSubview:btnComment];
    [btnView addSubview:lblCommentCount];
    [btnView addSubview:btnDelete];
    [btnView addSubview:btnShare];
    [btnView addSubview:btnReport];
    [bgView addSubview:btnView];
    [cell.contentView addSubview:bgView];

    [btnView.layer setBorderColor:[UIColor colorWithRed:232.0/255.0 green:235.0/255.0 blue:240.0/255.0 alpha:1.0].CGColor];
    [btnView.layer setBorderWidth:1.0f];
    
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
 
    [imgComment setContentMode:UIViewContentModeScaleAspectFill];
    [imgComment setClipsToBounds:YES];
    
    [imgUser setContentMode:UIViewContentModeScaleAspectFill];
    [imgUser setClipsToBounds:YES];
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    nameDict =nil;
    nameString =nil;
    statusDict =nil;
    statusString =nil;
    eventDict =nil;
    eventNameString =nil;
    type =nil;
    nameFont =nil;
    statusFont =nil;
    eventFont =nil;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if([promotionArray count]>0)
    {
        int DataAtIndexpath = (int)indexPath.section * RowPerSection + (int)indexPath.row;
        
        
        NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:DataAtIndexpath inSection:0];
        
        
        static NSString *CellIdentifier = @"Cell";
        
        
        NSString *type =[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"type"]];
        
        if([type isEqualToString:@"CL"] || [type isEqualToString:@"C"])
        {
            
            // NSLog(@"%@",[timeLineArray objectAtIndex:tempIndexPath.row]);
            if([[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]count]>0)
            {
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                [self configureTimeLineCellCommentWithImage:cell atIndexPath:tempIndexPath];
                
                cell.contentView.layer.cornerRadius = 2.0;
                cell.contentView.layer.borderWidth = 1.0;
                cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
                cell.contentView.layer.masksToBounds = YES;
                
                cell.layer.shadowColor = [UIColor grayColor].CGColor;
                cell.layer.shadowOffset = CGSizeMake(0, 2.0);
                cell.layer.shadowRadius = 2.0;
                cell.layer.shadowOpacity = 1.0;
                cell.layer.masksToBounds = NO;
                
                return cell;
            }
            else
            {
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                [self configureTimeLineCellComment:cell atIndexPath:tempIndexPath];
                
                
                
                cell.contentView.layer.cornerRadius = 2.0;
                cell.contentView.layer.borderWidth = 1.0;
                cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
                cell.contentView.layer.masksToBounds = YES;
                
                cell.layer.shadowColor = [UIColor grayColor].CGColor;
                cell.layer.shadowOffset = CGSizeMake(0, 2.0);
                cell.layer.shadowRadius = 2.0;
                cell.layer.shadowOpacity = 1.0;
                cell.layer.masksToBounds = NO;
                
                return cell;
            }
            
        }
        else if([type isEqualToString:@"NE"] || [type isEqualToString:@"EL"])
        {
            
            
            if([[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Event"] valueForKey:@"image"] length]>0)
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                [self configureTimeLineCellEventWithImage:cell atIndexPath:tempIndexPath];
                
                cell.contentView.layer.cornerRadius = 2.0;
                cell.contentView.layer.borderWidth = 1.0;
                cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
                cell.contentView.layer.masksToBounds = YES;
                
                cell.layer.shadowColor = [UIColor grayColor].CGColor;
                cell.layer.shadowOffset = CGSizeMake(0, 2.0);
                cell.layer.shadowRadius = 2.0;
                cell.layer.shadowOpacity = 1.0;
                cell.layer.masksToBounds = NO;
                
                return cell;
            }
            else
            {
                
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                [self configureTimeLineCellEvent:cell atIndexPath:tempIndexPath];
                
                cell.contentView.layer.cornerRadius = 2.0;
                cell.contentView.layer.borderWidth = 1.0;
                cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
                cell.contentView.layer.masksToBounds = YES;
                
                cell.layer.shadowColor = [UIColor grayColor].CGColor;
                cell.layer.shadowOffset = CGSizeMake(0, 2.0);
                cell.layer.shadowRadius = 2.0;
                cell.layer.shadowOpacity = 1.0;
                cell.layer.masksToBounds = NO;
                
                return cell;
                
            }
            
        }
        
        return nil;

        
    }
    else{
        
    
        static NSString *CellIdentifier = @"Cell";
        
        
        NSString *type =[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"type"]];
        
        if([type isEqualToString:@"CL"] || [type isEqualToString:@"C"])
        {
            
            // NSLog(@"%@",[timeLineArray objectAtIndex:tempIndexPath.row]);
            if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Comment"]valueForKey:@"image_array"]count]>0)
            {
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                [self configureTimeLineCellCommentWithImage:cell atIndexPath:indexPath];
                
                cell.contentView.layer.cornerRadius = 2.0;
                cell.contentView.layer.borderWidth = 1.0;
                cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
                cell.contentView.layer.masksToBounds = YES;
                
                cell.layer.shadowColor = [UIColor grayColor].CGColor;
                cell.layer.shadowOffset = CGSizeMake(0, 2.0);
                cell.layer.shadowRadius = 2.0;
                cell.layer.shadowOpacity = 1.0;
                cell.layer.masksToBounds = NO;
                
                return cell;
            }
            else
            {
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                [self configureTimeLineCellComment:cell atIndexPath:indexPath];
                
                cell.contentView.layer.cornerRadius = 2.0;
                cell.contentView.layer.borderWidth = 1.0;
                cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
                cell.contentView.layer.masksToBounds = YES;
                
                cell.layer.shadowColor = [UIColor grayColor].CGColor;
                cell.layer.shadowOffset = CGSizeMake(0, 2.0);
                cell.layer.shadowRadius = 2.0;
                cell.layer.shadowOpacity = 1.0;
                cell.layer.masksToBounds = NO;
                
                return cell;
            }
            
        }
        else if([type isEqualToString:@"NE"] || [type isEqualToString:@"EL"])
        {
            
            
            if([[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"image"] length]>0)
            {
                
                
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                [self configureTimeLineCellEventWithImage:cell atIndexPath:indexPath];
                
                cell.contentView.layer.cornerRadius = 2.0;
                cell.contentView.layer.borderWidth = 1.0;
                cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
                cell.contentView.layer.masksToBounds = YES;
                
                cell.layer.shadowColor = [UIColor grayColor].CGColor;
                cell.layer.shadowOffset = CGSizeMake(0, 2.0);
                cell.layer.shadowRadius = 2.0;
                cell.layer.shadowOpacity = 1.0;
                cell.layer.masksToBounds = NO;
                
                return cell;
            }
            else
            {
                
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                [self configureTimeLineCellEvent:cell atIndexPath:indexPath];
                
                cell.contentView.layer.cornerRadius = 2.0;
                cell.contentView.layer.borderWidth = 1.0;
                cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
                cell.contentView.layer.masksToBounds = YES;
                
                cell.layer.shadowColor = [UIColor grayColor].CGColor;
                cell.layer.shadowOffset = CGSizeMake(0, 2.0);
                cell.layer.shadowRadius = 2.0;
                cell.layer.shadowOpacity = 1.0;
                cell.layer.masksToBounds = NO;
                
                return cell;
                
            }
            
        }
        
        return nil;

    }
   
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    if ([promotionArray count]>0)
    {
        NSString *cellIdentifre =@"PromotionCellTableViewCell";
        
        PromotionCellTableViewCell *cell =(PromotionCellTableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifre];
        
        if (cell==nil)
        {
            NSArray *arrNib=[[NSBundle mainBundle] loadNibNamed:cellIdentifre owner:self options:nil];
            cell= (PromotionCellTableViewCell *)[arrNib objectAtIndex:0];
            
        }
        
        
        UIFont *priceFont = [UIFont fontWithName:self.lblTitle.font.fontName size:20];
        NSString *string = [NSString stringWithFormat:@"$%@",[[[promotionArray objectAtIndex:section] valueForKey:@"price"] description]];
        CGSize BoundingBox = [string sizeWithFont:priceFont];
        
        CGFloat reqWidth = BoundingBox.width;
        
        if (reqWidth < ScreenSize.width/2)
        {
            
            cell.lblPriceWidth.constant = reqWidth;
            
        }
        else{
            
            cell.lblPriceWidth.constant = (ScreenSize.width/2)+10;
            
        }
        
        
        cell.lblPrice.layer.cornerRadius = cell.lblPriceWidth.constant * 10 / 100;
        cell.lblPrice.clipsToBounds = YES;
        
        cell.lblDiscount.layer.cornerRadius = cell.lblPriceWidth.constant * 10 / 100;
        cell.lblDiscount.clipsToBounds = YES;
        
        cell.lblPrice.text = [NSString stringWithFormat:@"$%@",[[[promotionArray objectAtIndex:section] valueForKey:@"price"] description]];
        
        
        UIFont *Font = [UIFont fontWithName:self.lblTitle.font.fontName size:16];
        NSString *text = [NSString stringWithFormat:@"$%@",[[[promotionArray objectAtIndex:section] valueForKey:@"discount"] description]];
        CGSize Box = [text sizeWithFont:Font];
        
        CGFloat Width = Box.width;
        
        if (Width < ScreenSize.width/2)
        {
            
            cell.lblDiscountWidth.constant = Width;
            
        }
        else{
            
            cell.lblDiscountWidth.constant = (ScreenSize.width/2)+10;
            
        }
        
        cell.lblDiscount.text = [NSString stringWithFormat:@"$%@",[[[promotionArray objectAtIndex:section] valueForKey:@"discount"] description]];
        
        
        
        cell.btnDelete.hidden = YES;
        
        cell.imgPromotion.clipsToBounds = YES;
        
        if (![[[promotionArray objectAtIndex:section] valueForKey:@"image"]isEqualToString:@""])
        {
            
            [cell.imgPromotion sd_setImageWithURL:[NSURL URLWithString:[[promotionArray objectAtIndex:section] valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            
        }
        else
        {
            
            [cell.imgPromotion setImage:[UIImage imageNamed:@"placeholder"]];
            
            
            
        }
        
        
        
        if ([[[promotionArray objectAtIndex:section] valueForKey:@"status"]isEqualToString:@"Active"])
        {
            
            [cell.imgGreenDot setImage:[UIImage imageNamed:@"greenDot"]];
            
        }
        else if ([[[promotionArray objectAtIndex:section] valueForKey:@"status"]isEqualToString:@"Inactive"])
        {
            
            [cell.imgGreenDot setImage:[UIImage imageNamed:@"redDot"]];
            
        }
        else
        {
            [cell.imgGreenDot setImage:[UIImage imageNamed:@"orangeDot"]];
            
        }
        
        
        
        UIFont *yourFont = [UIFont fontWithName:self.lblTitle.font.fontName size:16];
        CGSize stringBoundingBox = [[[promotionArray objectAtIndex:section] valueForKey:@"company_name"] sizeWithFont:yourFont];
        
        CGFloat requiredWidth = stringBoundingBox.width;
        
        if (requiredWidth < ScreenSize.width-45)
        {
            cell.lblCompanyNameWidth.constant = requiredWidth;
            
        }
        else{
            
            cell.lblCompanyNameWidth.constant = ScreenSize.width-45;
            
        }
        
        [cell.lblCompanyname setText:[[promotionArray objectAtIndex:section] valueForKey:@"company_name"]];
        
        CGFloat requiredHeight = [self getDescriptionHeight:[[promotionArray objectAtIndex:section] valueForKey:@"description"]];
        
        if (requiredHeight <= 21)
        {
            cell.lblDescriptionHeight.constant = requiredHeight;
            cell.lblCompanyTop.constant = 125 + (45-requiredHeight);
            
        }
        else{
            
            cell.lblDescriptionHeight.constant = 45;
            cell.lblCompanyTop.constant = 125;
            
        }
        
        
        [cell.lblDescription setText:[[promotionArray objectAtIndex:section] valueForKey:@"description"]];
        
        [cell.lblLocation setText:[[promotionArray objectAtIndex:section] valueForKey:@"location"]];
        
        [cell.lblLocation setText:[[promotionArray objectAtIndex:section] valueForKey:@"location"]];
        
        
        [cell.lblType setText:[[promotionArray objectAtIndex:section] valueForKey:@"type_name"]];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        cell.contentView.layer.cornerRadius = 2.0;
        cell.contentView.layer.borderWidth = 1.0;
        cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        cell.contentView.layer.masksToBounds = YES;
        
        cell.contentView.layer.shadowColor = [UIColor grayColor].CGColor;
        cell.contentView.layer.shadowOffset = CGSizeMake(0, 2.0);
        cell.contentView.layer.shadowRadius = 2.0;
        cell.contentView.layer.shadowOpacity = 1.0;
        cell.contentView.layer.masksToBounds = NO;
       // cell.contentView.backgroundColor = [UIColor redColor];
        
        cell.contentView.layer.sublayerTransform = CATransform3DMakeTranslation(0, 5, 0);
        
        return cell.contentView;
        
        
    }
    else{
        
        
        UIView *view = [[UIView alloc]init];
        
        return view;
    }

    
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    if ([promotionArray count]>0)
//    {
//        NSString *cellIdentifre =@"PromotionCellTableViewCell";
//        
//        PromotionCellTableViewCell *cell =(PromotionCellTableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifre];
//        
//        if (cell==nil)
//        {
//            NSArray *arrNib=[[NSBundle mainBundle] loadNibNamed:cellIdentifre owner:self options:nil];
//            cell= (PromotionCellTableViewCell *)[arrNib objectAtIndex:0];
//            
//        }
//        
//        
//        UIFont *priceFont = [UIFont fontWithName:self.lblTitle.font.fontName size:20];
//        NSString *string = [NSString stringWithFormat:@"$%@",[[[promotionArray objectAtIndex:section] valueForKey:@"price"] description]];
//        CGSize BoundingBox = [string sizeWithFont:priceFont];
//        
//        CGFloat reqWidth = BoundingBox.width;
//        
//        if (reqWidth < ScreenSize.width/2)
//        {
//            
//            cell.lblPriceWidth.constant = reqWidth;
//            
//        }
//        else{
//            
//            cell.lblPriceWidth.constant = (ScreenSize.width/2)+10;
//            
//        }
//        
//        
//        cell.lblPrice.layer.cornerRadius = cell.lblPriceWidth.constant * 10 / 100;
//        cell.lblPrice.clipsToBounds = YES;
//        
//        cell.lblDiscount.layer.cornerRadius = cell.lblPriceWidth.constant * 10 / 100;
//        cell.lblDiscount.clipsToBounds = YES;
//    
//        cell.lblPrice.text = [NSString stringWithFormat:@"$%@",[[[promotionArray objectAtIndex:section] valueForKey:@"price"] description]];
//        
//        
//        UIFont *Font = [UIFont fontWithName:self.lblTitle.font.fontName size:16];
//        NSString *text = [NSString stringWithFormat:@"$%@",[[[promotionArray objectAtIndex:section] valueForKey:@"discount"] description]];
//        CGSize Box = [text sizeWithFont:Font];
//        
//        CGFloat Width = Box.width;
//        
//        if (Width < ScreenSize.width/2)
//        {
//            
//            cell.lblDiscountWidth.constant = Width;
//            
//        }
//        else{
//            
//            cell.lblDiscountWidth.constant = (ScreenSize.width/2)+10;
//            
//        }
//        
//        cell.lblDiscount.text = [NSString stringWithFormat:@"$%@",[[[promotionArray objectAtIndex:section] valueForKey:@"discount"] description]];
//        
//
//        
//        cell.btnDelete.hidden = YES;
//        
//        cell.imgPromotion.clipsToBounds = YES;
//        
//        if (![[[promotionArray objectAtIndex:section] valueForKey:@"image"]isEqualToString:@""])
//        {
//            
//            [cell.imgPromotion sd_setImageWithURL:[NSURL URLWithString:[[promotionArray objectAtIndex:section] valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
//            
//        }
//        else
//        {
//            
//            [cell.imgPromotion setImage:[UIImage imageNamed:@"placeholder"]];
//            
//            
//            
//        }
//        
//        
//        
//        if ([[[promotionArray objectAtIndex:section] valueForKey:@"status"]isEqualToString:@"Active"])
//        {
//            
//            [cell.imgGreenDot setImage:[UIImage imageNamed:@"greenDot"]];
//            
//        }
//        else if ([[[promotionArray objectAtIndex:section] valueForKey:@"status"]isEqualToString:@"Inactive"])
//        {
//            
//            [cell.imgGreenDot setImage:[UIImage imageNamed:@"redDot"]];
//            
//        }
//        else
//        {
//            [cell.imgGreenDot setImage:[UIImage imageNamed:@"orangeDot"]];
//            
//        }
//        
//        
//        
//        UIFont *yourFont = [UIFont fontWithName:self.lblTitle.font.fontName size:16];
//        CGSize stringBoundingBox = [[[promotionArray objectAtIndex:section] valueForKey:@"company_name"] sizeWithFont:yourFont];
//        
//        CGFloat requiredWidth = stringBoundingBox.width;
//        
//        if (requiredWidth < ScreenSize.width-45)
//        {
//            cell.lblCompanyNameWidth.constant = requiredWidth;
//            
//        }
//        else{
//            
//            cell.lblCompanyNameWidth.constant = ScreenSize.width-45;
//            
//        }
//        
//        [cell.lblCompanyname setText:[[promotionArray objectAtIndex:section] valueForKey:@"company_name"]];
//        
//        CGFloat requiredHeight = [self getDescriptionHeight:[[promotionArray objectAtIndex:section] valueForKey:@"description"]];
//        
//        if (requiredHeight <= 21)
//        {
//            cell.lblDescriptionHeight.constant = requiredHeight;
//            cell.lblCompanyTop.constant = 125 + (45-requiredHeight);
//            
//        }
//        else{
//            
//            cell.lblDescriptionHeight.constant = 45;
//            cell.lblCompanyTop.constant = 125;
//            
//        }
//        
//        
//        [cell.lblDescription setText:[[promotionArray objectAtIndex:section] valueForKey:@"description"]];
//        
//        [cell.lblLocation setText:[[promotionArray objectAtIndex:section] valueForKey:@"location"]];
//        
//        [cell.lblLocation setText:[[promotionArray objectAtIndex:section] valueForKey:@"location"]];
// 
//        
//        [cell.lblType setText:[[promotionArray objectAtIndex:section] valueForKey:@"type_name"]];
//        
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        
//        
//     
//        
//        
//        return cell.contentView;
//
//        
//    }
//    else{
//        
//        
//        UIView *view = [[UIView alloc]init];
//        
//        return view;
//    }
//    
//    
//}



//-(CGFloat)getTextWidth:(NSString *)text
//{
//    if ([promotionArray count]>0)
//    {
//        
//        CGSize maximumSize = CGSizeMake(ScreenSize.width-40,21);
//        
//        UIFont *fontName = [UIFont fontWithName:self.lblTitle.font.fontName size:17];
//        
//        CGRect labelHeighSize = [text boundingRectWithSize:maximumSize
//                                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
//                                 
//                                                attributes:@{NSFontAttributeName:fontName}
//                                                   context:nil];
//        
//        return labelHeighSize.size.width;
//        
//        
//    }
//    else{
//        
//        return 0;
//    }
//    
//}

-(CGFloat)getDescriptionHeight:(NSString *)text
{
    
    CGSize maximumSize = CGSizeMake(ScreenSize.width-30,45);
    
    UIFont *fontName = [UIFont fontWithName:self.lblTitle.font.fontName size:14];
    
    
    CGRect labelHeighSize = [text boundingRectWithSize:maximumSize
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                            attributes:@{NSFontAttributeName:fontName}
                                               context:nil];
    
    return labelHeighSize.size.height;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
    
    [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:indexPath.row] valueForKey:@"Event"] valueForKey:@"id"]]];
    
    [self.navigationController pushViewController:eventDetailVC animated:YES];
  
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if([promotionArray count]>0)
    {
        
        return 250;
    }
    else{
        
        return 0;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if([promotionArray count]>0)
//    {
//
//        return 250;
//    }
//    else{
//        
        return 0.01;
   // }
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
    int DataAtIndexpath = (int)indexPath.section * RowPerSection + (int)indexPath.row;
    
    
    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:DataAtIndexpath inSection:0];
  
    CGFloat cellHeight=0;
    
    NSLog(@"%@",[timeLineArray objectAtIndex:tempIndexPath.row]);
    
    NSString *type =[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"type"]];
    
    if([type isEqualToString:@"CL"] || [type isEqualToString:@"C"])
    {
        
        
        
        NSLog(@"%@",[timeLineArray objectAtIndex:tempIndexPath.row]);
        
        
        if([[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Comment"] valueForKey:@"image"] length]>0)
        {
     
          cellHeight +=350;
            
        }
        else
        {
            cellHeight +=130;
        }
        
        
        
        if (![[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Comment"] valueForKey:@"comment"]isEqualToString:@""])
        {
            
            //cell.lblComment.hidden = NO;
            
            NSData *data = [[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Comment"] valueForKey:@"comment"] dataUsingEncoding:NSUTF8StringEncoding];
            NSString *decodedComment = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            
            DAAttributedLabel *lbl = [[DAAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, ScreenSize.width-30, 26)];
            
            
            lbl.text = [self DecodeCommentString:decodedComment usersTagged:[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Comment"] valueForKey:@"Tags"]];
            
            [lbl setPreferredHeight];
            
            NSLog(@"%f",[lbl getPreferredHeight]);
            
            cellHeight += [lbl getPreferredHeight];
           
            lbl = nil;
          
        }
        else{
            
            cellHeight += 1;
         
        }

   
        if([[[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Comment"] valueForKey:@"top_replys_count"] description] intValue] > 0)
        {
            
            cellHeight += viewAllcommentsHeight;
            
            
        }
        
        
        if([[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"] count]>0)
        {
            
            cellHeight += replyCellHeight * [[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Comment"] valueForKey:@"Topreplys"] count];
            
            
        }
   
    }
   else if([type isEqualToString:@"NE"] || [type isEqualToString:@"EL"])
    {
        if([[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Event"] valueForKey:@"image"] length]>0)
        {

        cellHeight +=350;
          
        }
        else
        {
            cellHeight +=130;
        }
        
        cellHeight +=[self getLabelHeightForIndex:[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Event"] valueForKey:@"description"]];
        
        
        if([[[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Event"] valueForKey:@"top_comments_count"] description] intValue] > 0)
        {
            
            cellHeight += viewAllcommentsHeight;
            
            
        }
        
        
        if([[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"] count]>0)
        {
            
            cellHeight += replyCellHeight * [[[[timeLineArray objectAtIndex:tempIndexPath.row] valueForKey:@"Event"] valueForKey:@"Topcomments"] count];
            
            
        }
    
    }
    
    
    return cellHeight;
 
}




-(void)likeTapped:(UIButton *)sender
{
    currentImageIndex = (int)sender.tag;
    
    NSLog(@"%ld",(long)sender.tag);
    
    NSLog(@"%@",[[[[timeLineArray objectAtIndex:currentIndexPath]valueForKey:@"Comment"] valueForKey:@"image_array"]objectAtIndex:sender.tag]);
    
    if ([DELEGATE connectedToNetwork])
    {
        
        isImageLiked = [[NSString alloc]init];
        
        if ([[[[[[timeLineArray objectAtIndex:currentIndexPath] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:sender.tag] valueForKey:@"is_liked"]isEqualToString:@"N"])
        {
            
            isImageLiked = @"Y";
            
        }
        else{
            
            isImageLiked = @"N";
        }
        
        [mc likeComment:[USER_DEFAULTS valueForKey:@"userid"] Comment_id:[NSString stringWithFormat:@"%@",[[[[[timeLineArray objectAtIndex:currentIndexPath]valueForKey:@"Comment"] valueForKey:@"image_array"]objectAtIndex:sender.tag] valueForKey:@"id"]] Is_like:[NSString stringWithFormat:@"%@",isImageLiked] Sel:@selector(imageLiked:)];
    }
    
}

-(void)imageLiked:(NSDictionary *)response
{
    NSLog(@"%@",response);
    
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        DELEGATE.isEventEdited = YES;
        
        NSMutableDictionary *commentData = [[timeLineArray objectAtIndex:currentIndexPath] mutableCopy];
        
        NSMutableDictionary *dict = [[commentData valueForKey:@"Comment"] mutableCopy];
       
        NSMutableArray *imageArray = [[dict valueForKey:@"image_array"]mutableCopy];
        
        NSMutableDictionary *imageData = [[imageArray objectAtIndex:currentImageIndex] mutableCopy];
        
        [imageData setValue:[NSString stringWithFormat:@"%@",isImageLiked] forKey:@"is_liked"];
        [imageData setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"like_count"]] forKey:@"like_count"];
        
        [imageArray setObject:imageData atIndexedSubscript:currentImageIndex];
        
        [dict  setObject:imageArray forKey:@"image_array"];
        
        [commentData setObject:dict forKey:@"Comment"];
        
        [timeLineArray setObject:commentData atIndexedSubscript:currentIndexPath];
        
        [_tblTimeLIne reloadData];
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"updateGallery" object:@{@"imageIndex":[NSString stringWithFormat:@"%d",currentImageIndex]}];
        
    }
    else
    {
        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
    
}

-(void)openReplies:(UIButton *)sender
{
    
 
    if([self isInvitedOnEvent:(int)sender.tag])
    {
        
        NSLog(@"%@",[timeLineArray objectAtIndex:sender.tag]);
        
        if ([[[timeLineArray objectAtIndex:sender.tag]valueForKey:@"type"]isEqualToString:@"C"]||[[[timeLineArray objectAtIndex:sender.tag]valueForKey:@"type"]isEqualToString:@"CL"])
        {
            
            
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:sender.tag] valueForKey:@"id"]]);
            
            CommentDetail *obj = [[CommentDetail alloc]init];
            
            obj.gettedReplies = [[NSMutableArray alloc]initWithArray:[[[timeLineArray objectAtIndex:sender.tag] valueForKey:@"Comment"]valueForKey:@"Reply"]];
            obj.commentID = [[NSString alloc]init];
            
            obj.commentID = [NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:sender.tag] valueForKey:@"Comment"] valueForKey:@"id"]];
            
            obj.eventID = [[NSString alloc]init];
            
            obj.eventID = [NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:sender.tag] valueForKey:@"Event"] valueForKey:@"id"]];
            [obj setHidesBottomBarWhenPushed:YES];
            
            [self.navigationController pushViewController:obj animated:YES];
            
            
        }
        else
        {
            EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
            
            [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:sender.tag] valueForKey:@"Event"] valueForKey:@"id"]]];
            
            [self.navigationController pushViewController:eventDetailVC animated:YES];
            
        }
        
    }
    else
    {
        if(IS_Ipad)
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
        else
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
    }


    
}


-(void)CommentTapped:(UIButton *)sender
{
    
    // NSLog(@"%ld",(long)sender.tag);
 
    //NSLog(@"%@",[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:sender.tag]);
    
    
    // NSLog(@"%@",[NSString stringWithFormat:@"%@",[[[[commentArray objectAtIndex:currentIndexPath] valueForKey:@"image_array"]objectAtIndex:sender.tag] valueForKey:@"id"]]);
    
    CommentDetail *obj = [[CommentDetail alloc]init];
    
    obj.commentID = [[NSString alloc]init];
    
    obj.commentID = [NSString stringWithFormat:@"%@",[[[[[timeLineArray objectAtIndex:currentIndexPath]valueForKey:@"Comment"] valueForKey:@"image_array"]objectAtIndex:sender.tag] valueForKey:@"id"]];
    
    //here
    
    obj.eventID = [[NSString alloc]init];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:currentIndexPath]valueForKey:@"Event"] valueForKey:@"id"]]);
    obj.eventID = [NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:currentIndexPath]valueForKey:@"Event"] valueForKey:@"id"]];
    
    obj.isImageReplies = YES;
    
    
    [obj setHidesBottomBarWhenPushed:YES];
    
    [self.navigationController pushViewController:obj animated:YES];
    
    
}



-(void)updateLikeComment:(imageLikeComment *)view
{
    
   // NSLog(@"%d",(int)view.tag);
    
   // NSLog(@"%@",[[[[timeLineArray objectAtIndex:currentIndexPath] valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:(int)view.tag]);
   
    if ([[[[[[timeLineArray objectAtIndex:currentIndexPath]valueForKey:@"Comment"]valueForKey:@"image_array"]objectAtIndex:(long)view.tag]valueForKey:@"is_liked"]isEqualToString:@"N"])
    {
        [view.btnLike setImage:[UIImage imageNamed:@"like1"] forState:UIControlStateNormal];
        
    }
    else{
        
        [view.btnLike setImage:[UIImage imageNamed:@"like2"] forState:UIControlStateNormal];
        
    }
    
    
    [view.lblLikes setText:[NSString stringWithFormat:@"%@ Like",[[[[[timeLineArray objectAtIndex:currentIndexPath]valueForKey:@"Comment"] valueForKey:@"image_array"]objectAtIndex:(long)view.tag] valueForKey:@"like_count"]]];
    
    [view.lblComments setText:[NSString stringWithFormat:@"%@ Comment",[[[[[timeLineArray objectAtIndex:currentIndexPath]valueForKey:@"Comment"] valueForKey:@"image_array"]objectAtIndex:(long)view.tag] valueForKey:@"reply_count"]]];
    
}



#pragma mark --------------- MHFacebook Image Viewer -----------------------

-(NSInteger)numberImagesForImageViewer:(MHFacebookImageViewer *)imageViewer
{
    
    currentIndexPath = (int)imageViewer.senderView.tag;
    
    if([[[[timeLineArray objectAtIndex:imageViewer.senderView.tag] valueForKey:@"Comment"]valueForKey:@"image_array"]count]>0)
    {
        
        return [[[[timeLineArray objectAtIndex:imageViewer.senderView.tag] valueForKey:@"Comment"]valueForKey:@"image_array"]count];
        
    }
    else{
        
        return 0;
    }
    
}

- (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[[[timeLineArray objectAtIndex:imageViewer.senderView.tag] valueForKey:@"Comment"]valueForKey:@"image_array"] objectAtIndex:index] valueForKey:@"image"]]];
}
- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer
{
    
    return [UIImage imageNamed:@"placeholder"];
}




- (void) onTouch: (UITapGestureRecognizer*) tgr
{
    
    UILabel *tappedview = (UILabel *)[tgr view];

    CGPoint p = [tgr locationInView: tappedview];
    
    // in case the background of the label isn't transparent...
    UIColor* labelBackgroundColor = tappedview.backgroundColor;
    tappedview.backgroundColor = [UIColor clearColor];
    
    // get a UIImage of the label
    UIGraphicsBeginImageContext( tappedview.bounds.size );
    CGContextRef c = UIGraphicsGetCurrentContext();
    [tappedview.layer renderInContext: c];
    UIImage* i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // restore the label's background...
    tappedview.backgroundColor = labelBackgroundColor;
    
    // draw the pixel we're interested in into a 1x1 bitmap
    unsigned char pixel = 0x00;
    c = CGBitmapContextCreate(&pixel,
                              1, 1, 8, 1, NULL,
                              kCGImageAlphaOnly);
    UIGraphicsPushContext(c);
    [i drawAtPoint: CGPointMake(-p.x, -p.y)];
    UIGraphicsPopContext();
    CGContextRelease(c);
    
    if ( pixel != 0 )
    {
        //NSLog( @"touched text %@",c );
    }
}


- (UIImage *)drawImage:(UIImage *)inputImage inRect:(CGRect)frame
{
    
    
    
   // NSLog(@"origional height: %f",inputImage.size.height);
   // NSLog(@"origional width: %f",inputImage.size.width);
    
    CGImageRef tmpImgRef = inputImage.CGImage;
    CGImageRef topImgRef;
    
    
    float widthRatio = (frame.size.width) / inputImage.size.width;
    float heightRatio = (frame.size.height) / inputImage.size.height;
    float scale = MAX(widthRatio, heightRatio);
     float imageWidth = scale * inputImage.size.width;
    float imageHeight = scale * inputImage.size.height;
    
    
    if(IS_Ipad)
    {
        if(imageHeight<350)
        {
            topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, 0, inputImage.size.width, inputImage.size.height));
        }
        else
        {
            topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height/3.5, inputImage.size.width, inputImage.size.height));
            
           // topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, imageHeight/2.0, imageWidth, imageHeight/2));
            
            // topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height/2.5, inputImage.size.width, inputImage.size.height/2));
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
            topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, inputImage.size.height/3.5, inputImage.size.width, inputImage.size.height));
            
             //topImgRef = CGImageCreateWithImageInRect(tmpImgRef, CGRectMake(0, imageHeight/2.0, imageWidth, imageHeight/2));
        }
    }
    
    

    UIImage *topImage = [UIImage imageWithCGImage:topImgRef];
    
    return topImage;
  
}

- (void) handleCommentTap: (UITapGestureRecognizer *)recognizer
{
    UIView *view = [recognizer view];
    if([self isInvitedOnEvent:(int)view.tag])
    {

        NSLog(@"%@",[timeLineArray objectAtIndex:view.tag]);
        
        if ([[[timeLineArray objectAtIndex:view.tag]valueForKey:@"type"]isEqualToString:@"C"]||[[[timeLineArray objectAtIndex:view.tag]valueForKey:@"type"]isEqualToString:@"CL"])
        {
            
            
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:view.tag] valueForKey:@"id"]]);
            
            CommentDetail *obj = [[CommentDetail alloc]init];
            
            obj.gettedReplies = [[NSMutableArray alloc]initWithArray:[[[timeLineArray objectAtIndex:view.tag] valueForKey:@"Comment"]valueForKey:@"Reply"]];
            obj.commentID = [[NSString alloc]init];
            
            obj.commentID = [NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:view.tag] valueForKey:@"Comment"] valueForKey:@"id"]];
            
            obj.eventID = [[NSString alloc]init];
        
            obj.eventID = [NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:view.tag] valueForKey:@"Event"] valueForKey:@"id"]];
            [obj setHidesBottomBarWhenPushed:YES];
            
            [self.navigationController pushViewController:obj animated:YES];
            
            
        }
        else
        {
            EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
            
            [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:view.tag] valueForKey:@"Event"] valueForKey:@"id"]]];
            
            [self.navigationController pushViewController:eventDetailVC animated:YES];
          
        }
      
    }
    else
    {
        if(IS_Ipad)
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
        else
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
    }
    
    
    
    
}

- (void) handleImageTap: (UITapGestureRecognizer *)recognizer
{
    UIView *view = [recognizer view];
    
    shareImageTag =(int)view.tag;
    
    self.shareImageView.hidden=NO;
    
    
    [self.lblzoomImageTitle setText:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:view.tag] valueForKey:@"Event"] valueForKey:@"name"]]];
    
    [self.imgShareBig sd_setImageWithURL:[NSURL URLWithString:[[[timeLineArray objectAtIndex:view.tag] valueForKey:@"Comment"] valueForKey:@"image"]]];
    [self.imgShareBig setHidden:YES];
    [self addZoomView:[[[timeLineArray objectAtIndex:view.tag] valueForKey:@"Comment"] valueForKey:@"image"] ];
}
- (void) handleImageTap2: (UITapGestureRecognizer *)recognizer
{
    UIView *view = [recognizer view];
    shareImageTag =(int)view.tag;
      self.shareImageView.hidden=NO;
    [self.lblzoomImageTitle setText:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:view.tag] valueForKey:@"Event"] valueForKey:@"name"]]];
    
     [self.imgShareBig sd_setImageWithURL:[NSURL URLWithString:[[[timeLineArray objectAtIndex:view.tag] valueForKey:@"Event"] valueForKey:@"image"]]];
     [self.imgShareBig setHidden:YES];
     [self addZoomView:[[[timeLineArray objectAtIndex:view.tag] valueForKey:@"Event"] valueForKey:@"image"] ];
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


#pragma mark ----------- likes Tapped ------------

-(void)likecliked:(UIGestureRecognizer *)gestureRecognizer
{
    
   // NSLog(@"%@", [timeLineArray objectAtIndex:gestureRecognizer.view.tag]);
    
    
    likesPeople *objVC =[[likesPeople alloc] initWithNibName:@"likesPeople" bundle:nil];
  
    
    objVC.likedDetail = [[NSMutableDictionary alloc]initWithDictionary:[timeLineArray objectAtIndex:gestureRecognizer.view.tag]];
    
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

-(NSString *)getDateShare:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
  //  NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
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
    
    dateFormatter =nil ;
    date =nil;
    return [NSString stringWithFormat:@"%@",formattedDate];
}


-(NSString *)getDate:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
  //  NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  
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
    [dateFormatter setDateFormat:@"dd MMM yyyy hh:mm a"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    
    dateFormatter =nil ;
    date =nil;
    return [NSString stringWithFormat:@"%@",formattedDate];
}
-(CGFloat)getLabelHeightForIndex:(NSString *)str
{
    
    
    CGSize boundingSize ;
 /*   if(IS_Ipad)
    {
        boundingSize = CGSizeMake(self.view.bounds.size.width-30, 10000000);
        
    }
    else
    {*/
        boundingSize = CGSizeMake(self.view.bounds.size.width-20, 10000000);
        
   // }
    CGSize itemTextSize = [str sizeWithFont:[UIFont systemFontOfSize:14]
                                                                                  constrainedToSize:boundingSize
                                                                                      lineBreakMode:NSLineBreakByWordWrapping];
    
    
    
    float cellHeight = itemTextSize.height;
    
    
    return cellHeight;
}

-(BOOL)isCommentOrEvent:(int)row
{
    NSString *type =[NSString stringWithFormat:@"%@",[[timeLineArray objectAtIndex:row] valueForKey:@"type"]];
    
    if([type isEqualToString:@"CL"] || [type isEqualToString:@"C"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)isInvitedOnEvent:(int)row
{
    
  //  NSLog(@"event data is %@",[[timeLineArray objectAtIndex:row] valueForKey:@"Event"]);
    NSString *invited =[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:row] valueForKey:@"Event"] valueForKey:@"is_invited"]];
    
    if([invited isEqualToString:@"Y"] )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sharePostTapped:(UIButton *)sender
{
    
    if([self isInvitedOnEvent:(int)sender.tag])
    {
        shareID =(int)sender.tag;
        BOOL isComment =[self isCommentOrEvent:(int)sender.tag];
        
        if(isComment)
        {
            
            eventName = [[NSString alloc]init];
            
            eventName = [[[timeLineArray objectAtIndex:shareImageTag]valueForKey:@"Event"] valueForKey:@"name"];
            NSLog(@"%@",[[timeLineArray objectAtIndex:shareID] valueForKey:@"Comment"]);
            
            [self shareComom:[[timeLineArray objectAtIndex:shareID] valueForKey:@"Comment"] ShareFlag:2];
        }
        else
        {
            [self shareComom:[[timeLineArray objectAtIndex:shareID] valueForKey:@"Event"] ShareFlag:1];
        }
    }
    else
    {
        if(IS_Ipad)
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
        else
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
    }
    
    

}
- (void)deletePostTapped:(UIButton *)sender
{
    deleteID =(int)sender.tag;
    [DELEGATE showalertNew:self Message:[localization localizedStringForKey:@"Are you sure, you want to delete?"] AlertFlag:10];
    
}
-(void)responseDelete:(NSDictionary *)results
{
  //  NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        [timeLineArray removeObjectAtIndex:deleteID];
        deleteID =-1;
        [self.tblTimeLIne reloadData];
    }
}
- (void)likePostTapped:(UIButton *)sender
{
    likeID =(int)sender.tag;
    BOOL isComment =[self isCommentOrEvent:(int)sender.tag];
    
    if(isComment)
    {
        BOOL islike =NO;
        if([[[[timeLineArray objectAtIndex:likeID] valueForKey:@"Comment"] valueForKey:@"is_liked"] isEqualToString:@"Y"])
        {
            islike =YES;
        }
        else
        {
            islike =NO;
        }
        if(DELEGATE.connectedToNetwork)
        {
            [mc likeComment:[USER_DEFAULTS valueForKey:@"userid"] Comment_id:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:likeID] valueForKey:@"Comment"] valueForKey:@"id"]] Is_like:(islike)?@"N":@"Y" Sel:@selector(responseLike:)];
        }
    }
    else
    {
        BOOL islike =NO;
        if([[[[timeLineArray objectAtIndex:likeID] valueForKey:@"Event"] valueForKey:@"is_liked"] isEqualToString:@"Y"])
        {
            islike =YES;
        }
        else
        {
            islike =NO;
        }
        if(DELEGATE.connectedToNetwork)
        {
           
            [mc likeEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:likeID] valueForKey:@"Event"] valueForKey:@"id"]] Is_like:(islike)?@"N":@"Y" Sel:@selector(responseLike:)];
        }
    }
}
-(void)responseLike:(NSDictionary *)results
{
  //  NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        BOOL isComment =[self isCommentOrEvent:likeID];
        if(isComment)
        {
            NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[timeLineArray objectAtIndex:likeID]];
            
            NSMutableDictionary *subdict =[[NSMutableDictionary alloc] initWithDictionary:[dict valueForKey:@"Comment"]];
            
            int like =[[subdict valueForKey:@"like_count"] intValue];

           
            if([[[[timeLineArray objectAtIndex:likeID] valueForKey:@"Comment"] valueForKey:@"is_liked"] isEqualToString:@"Y"])
            {
                [subdict setValue:@"N" forKey:@"is_liked"];
                
                like--;
                
                [subdict setValue:[NSString stringWithFormat:@"%d",like] forKey:@"like_count"];

                [subdict setValue:@"N" forKey:@"is_liked"];
                

            }
            else
            {
                like++;
                
                [subdict setValue:[NSString stringWithFormat:@"%d",like] forKey:@"like_count"];
                [subdict setValue:@"Y" forKey:@"is_liked"];
            }
            [dict setObject:subdict forKey:@"Comment"];
            [timeLineArray replaceObjectAtIndex:likeID withObject:dict];

           
        }
        else
        {
            
            NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[timeLineArray objectAtIndex:likeID]];
            
            NSMutableDictionary *subdict =[[NSMutableDictionary alloc] initWithDictionary:[dict valueForKey:@"Event"]];
            
            int like =[[subdict valueForKey:@"like_count"] intValue];

            
            if([[[[timeLineArray objectAtIndex:likeID] valueForKey:@"Event"] valueForKey:@"is_liked"] isEqualToString:@"Y"])
            {
                [subdict setValue:@"N" forKey:@"is_liked"];
                
                like--;
                [subdict setValue:[NSString stringWithFormat:@"%d",like] forKey:@"like_count"];
            }
            else
            {
                [subdict setValue:@"Y" forKey:@"is_liked"];
                
                like++;
                [subdict setValue:[NSString stringWithFormat:@"%d",like] forKey:@"like_count"];
            }
            
            [dict setObject:subdict forKey:@"Event"];
            
            [timeLineArray replaceObjectAtIndex:likeID withObject:dict];

            
        }
        
        likeID =-1;
        [self.tblTimeLIne reloadData];

    }
    else
    {
         [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
}
- (void)reportPostTapped:(UIButton *)sender
{
    if([self isInvitedOnEvent:(int)sender.tag])
    {
        reportID =(int)sender.tag;
        [DELEGATE showalertNew:self Message:[localization localizedStringForKey:@"Are you sure, you want to report this?"] AlertFlag:5];
    }
    else
    {
        if(IS_Ipad)
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
        else
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
    }
  
}
-(void)responseReport:(NSDictionary *)results
{
   // NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        BOOL isComment =[self isCommentOrEvent:reportID];
        if(isComment)
        {
            NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[timeLineArray objectAtIndex:reportID]];
            
            NSMutableDictionary *subdict =[[NSMutableDictionary alloc] initWithDictionary:[dict valueForKey:@"Comment"]];
            
            if([[[[timeLineArray objectAtIndex:reportID] valueForKey:@"Comment"] valueForKey:@"is_reported"] isEqualToString:@"Y"])
            {
                [subdict setValue:@"N" forKey:@"is_reported"];
            }
            else
            {
                [subdict setValue:@"Y" forKey:@"is_reported"];
            }
            [dict setObject:subdict forKey:@"Comment"];
            [timeLineArray replaceObjectAtIndex:reportID withObject:dict];
            
            
        }
        else
        {
            
            NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[timeLineArray objectAtIndex:reportID]];
            
            NSMutableDictionary *subdict =[[NSMutableDictionary alloc] initWithDictionary:[dict valueForKey:@"Event"]];
            
            if([[[[timeLineArray objectAtIndex:reportID] valueForKey:@"Event"] valueForKey:@"is_reported"] isEqualToString:@"Y"])
            {
                [subdict setValue:@"N" forKey:@"is_reported"];
            }
            else
            {
                [subdict setValue:@"Y" forKey:@"is_reported"];
            }
            
            [dict setObject:subdict forKey:@"Event"];
            
            [timeLineArray replaceObjectAtIndex:reportID withObject:dict];
            
            
        }
        
        reportID =-1;
        [self.tblTimeLIne reloadData];
        
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
}
- (void)commentPostTapped:(UIButton *)sender
{
    if([self isInvitedOnEvent:(int)sender.tag])
    {
    }
    else
    {
        if(IS_Ipad)
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
        else
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
    }
}
- (void)profilePostTapped:(UIButton *)sender
{
    
    
    NSString *userID =[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:sender.tag] valueForKey:@"User"] valueForKey:@"id"]]];
    
    
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
        
        [otherVC setUserId:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:sender.tag] valueForKey:@"User"] valueForKey:@"id"]]];
        
        [self.navigationController pushViewController:otherVC animated:YES];
        
    }
    
}
- (void)namePostTapped:(UIButton *)sender
{
    
    
    NSString *userID =[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:sender.tag] valueForKey:@"User"] valueForKey:@"id"]]];
    
    
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
        
        [otherVC setUserId:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:sender.tag] valueForKey:@"User"] valueForKey:@"id"]]];
        
        [self.navigationController pushViewController:otherVC animated:YES];
        
    }
}

-(void)customPostEvent:(int)tag
{
    if([self isInvitedOnEvent:tag])
    {
        EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
        
        [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:tag] valueForKey:@"Event"] valueForKey:@"id"]]];
        [self.navigationController pushViewController:eventDetailVC animated:YES];
        
    }
    else
    {
        if(IS_Ipad)
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
        else
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
        
    }
    
}
- (void)eventPostTapped:(UIButton *)sender
{
    if([self isInvitedOnEvent:(int)sender.tag])
    {
        EventDetailViewController *eventDetailVC =[[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
        
        [eventDetailVC setEventID:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:sender.tag] valueForKey:@"Event"] valueForKey:@"id"]]];
        [self.navigationController pushViewController:eventDetailVC animated:YES];

    }
    else
    {
        if(IS_Ipad)
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
        else
        {
            [self.view makeToast:[localization localizedStringForKey:@"You are not invited for this event"]
                        duration:2.0
                        position:@"center"];
        }
        
    }
    
    
}

- (void)inviteBtnTapped:(UIButton *)sender
{
    [[self.view viewWithTag:191] removeFromSuperview];
    
    
    if(sender.tag==5)
    {
        BOOL isComment =[self isCommentOrEvent:reportID];
        if(isComment)
        {
            if(DELEGATE.connectedToNetwork)
            {
                [mc reportComment:[USER_DEFAULTS valueForKey:@"userid"] Comment_id:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:reportID] valueForKey:@"Comment"] valueForKey:@"id"]] Sel:@selector(responseReport:)];               
            }
        }
        else
        {
            if(DELEGATE.connectedToNetwork)
            {
                [mc reportEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:reportID] valueForKey:@"Event"] valueForKey:@"id"]] Sel:@selector(responseReport:)];
            }
        }
    }
    else if(sender.tag==10)
    {
        BOOL isComment =[self isCommentOrEvent:deleteID];
        if(isComment)
        {
            if(DELEGATE.connectedToNetwork)
            {
                [mc deleteComment:[USER_DEFAULTS valueForKey:@"userid"] Comment_id:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:deleteID] valueForKey:@"Comment"] valueForKey:@"id"]] Sel:@selector(responseDelete:)];
            }
        }
        else
        {
            if(DELEGATE.connectedToNetwork)
            {
                [mc deleteEvent:[USER_DEFAULTS valueForKey:@"userid"] Eventid:[NSString stringWithFormat:@"%@",[[[timeLineArray objectAtIndex:deleteID] valueForKey:@"Event"] valueForKey:@"id"]] Sel:@selector(responseDelete:)];
            }
        }
    }
   
    
    
}
- (void)laterBtnTapped:(id)sender
{
    [[self.view viewWithTag:191] removeFromSuperview];
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

-(void)shareComom:(NSDictionary *)shareDict ShareFlag:(int)shareFlag
{
    
    
    //[self shareFB];
    
    
    
    if(DELEGATE.connectedToNetwork)
    {
        if(shareFlag==1)
        {
            
            

            NSMutableDictionary *properties = [@{
                                                 @"og:type": @"amhappyapp:event",
                                                 @"og:title": [shareDict valueForKey:@"name"],
                                                 @"og:description": [[shareDict valueForKey:@"type"]isEqualToString:@"Private"] ? [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[shareDict valueForKey:@"location"]] : [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[shareDict valueForKey:@"location"]],
                                                 
                                                 @"og:url": DeepLinkUrl,
                                                 
                                                 
                                                 }mutableCopy];
            
            
            
            NSString *imageURL = [shareDict valueForKey:@"thumb_image"];
            
            
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
        else
        {
            
            
                NSString *decodedString = [[self DecodeCommentString:[shareDict valueForKey:@"comment"] usersTagged:[shareDict valueForKey:@"Tags"]] string];
            
                NSMutableDictionary *properties = [@{
                                                     @"og:type": @"amhappyapp:comment",
                                                     @"og:title": eventName,
                                                     @"og:description": decodedString ? decodedString : @"",
            
                                                     @"og:url": DeepLinkUrl,
            
            
                                                     }mutableCopy];
            
            
                NSString *imgurl =[NSString stringWithFormat:@"%@",[shareDict valueForKey:@"image"]];
            
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
    }

    
    
//    if(DELEGATE.connectedToNetwork)
//    {
//        if(shareFlag==1)
//        {
//            
//            NSMutableDictionary <FBOpenGraphObject> *object =  [FBGraphObject openGraphObjectForPostWithType:@"amhappyapp:event"                                                                                                       title:@"testing title"                                                                                                       image:nil                                                                                                         url:DeepLinkUrl                                                                                                 description:@""];
//            object.provisionedForPost = YES;
//            object[@"title"] = [dict valueForKey:@"name"];
//            object[@"type"] = @"amhappyapp:event";
//            
//            //object[@"link"] = @"https://fb.me/1600227070237260";
//            
//            // object[@"link"] = @"AmHappy://";
//            
//            object[@"link"] = @"www.apple.com";
//            
//            
//            if([[dict valueForKey:@"image"] length]>0)
//            {
//                object[@"image"] = @[
//                                     @{@"url": [dict valueForKey:@"image"], @"user_generated" : @"false" }
//                                     ];
//            }
//            else
//            {
//                object[@"image"] = @[
//                                     @{@"url": Icon_PATH, @"user_generated" : @"false" }
//                                     ];
//            }
//            
//           /* if([[shareDict valueForKey:@"type"]isEqualToString:@"Private"])
//            {*/
//                object[@"description"] = [NSString stringWithFormat:@"%@ on %@ at %@",[dict valueForKey:@"description"],[self getDateShare:[dict valueForKey:@"date"]],[dict valueForKey:@"location"]];
//            /*}
//            else
//            {
//                object[@"description"] = [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[locationDict valueForKey:@"Paddress"]];
//                
//            }*/
//            
//            
//            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>) [FBGraphObject graphObject];
//            [action setObject:object forKey:@"event"];
//            //[action setObject:@"AmHappy://" forKey:@"link"];
//            [action setObject:@"www.apple.com" forKey:@"link"];
//            
//            
//            
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
//                                                              //   NSLog(@"Error publishing story: %@", error.localizedDescription);
//                                                                 [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Error occured while sharing"] AlertFlag:1 ButtonFlag:1];
//                                                             } else {
//                                                                 // Success
//                                                                // NSLog(@"result %@", results);
//                                                             }
//                                                         }];
//            }
//            
//        }
//        else
//        {
//            NSString *imgurl =[NSString stringWithFormat:@"%@",[dict valueForKey:@"image"]];
//
//            
//            // NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
//            
//            NSMutableDictionary <FBOpenGraphObject> *object =  [FBGraphObject openGraphObjectForPostWithType:@"amhappyapp:comment"                                                                                                       title:@"Amhappy"                                                                                                       image:nil                                                                                                         url:DeepLinkUrl                                                                                                 description:@""];
//            
//            
//            object.provisionedForPost = YES;
//            object[@"title"] = @"Comment";
//            object[@"type"] = @"amhappyapp:comment";
//            object[@"link"] = @"www.apple.com";
//            
//            
//            //[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgurl]]]
//            
//            //imgurl =@"https://www.google.co.in/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png";
//            
//            if(imgurl.length>0)
//            {
//                object[@"image"] = @[
//                                     @{@"url": imgurl, @"user_generated" : @"false" }
//                                     ];
//                
//            }
//            else
//            {
//                object[@"image"] = @[
//                                     @{@"url": Icon_PATH, @"user_generated" : @"false" }
//                                     ];
//            }
//          
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
//                                                                // NSLog(@"result %@", results);
//                                                             }
//                                                         }];
//            }
//        }
//    }
//    
    
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


-(void)shareEvent
{
    
}


//-(void)shareComment:(NSDictionary *)dict
//{
//    
//    NSString *decodedString = [[self DecodeCommentString:[dict valueForKey:@"comment"] usersTagged:[dict valueForKey:@"Tags"]] string];
//    
//    NSMutableDictionary *properties = [@{
//                                         @"og:type": @"amhappyapp:comment",
//                                         @"og:title": self.lblEventName.text,
//                                         @"og:description": decodedString ? decodedString : @"",
//                                         
//                                         @"og:url": DeepLinkUrl,
//                                         
//                                         
//                                         }mutableCopy];
//    
//    
//    NSString *imgurl =[NSString stringWithFormat:@"%@",[dict valueForKey:@"image"]];
//    
//    if(imgurl.length>0)
//    {
//        
//        FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:[[NSURL alloc]initWithString:imgurl] userGenerated:NO];
//        // photo.image = self.imgEvent.image;
//        [properties setObject:@[photo] forKey:@"og:image"];
//        
//        
//        
//    }
//    else
//    {
//        
//        FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:[[NSURL alloc]initWithString:Icon_PATH] userGenerated:NO];
//        UIImage *img = [[UIImage alloc]init];
//        img = [UIImage imageNamed:@"iconBlack"];
//        //photo.image = img;
//        [properties setObject:@[photo] forKey:@"og:image"];
//        
//    }
//    
//    
//    
//    
//    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
//    
//    
//    
//    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
//    action.actionType = @"amhappyapp:share";
//    [action setObject:object forKey:@"comment"];
//    [action setString:@"true" forKey:@"fb:explicitly_shared"];
//    //[action setObject:@"www.apple.com" forKey:@"link"];
//    
//    
//    
//    
//    
//    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
//    
//    
//    content.action = action;
//    content.previewPropertyName = @"comment";
//    
//    
//    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
//    shareDialog.fromViewController = self;
//    shareDialog.shareContent = content;
//    shareDialog.delegate = self;
//    
//    
//    NSError * error = nil;
//    BOOL validation = [shareDialog validateWithError:&error];
//    if (validation)
//    {
//        [shareDialog show];
//    }
//    else
//    {
//        
//        NSLog(@"%@",error);
//        
//        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Facebook App is not installed."] AlertFlag:1 ButtonFlag:1];
//        
//    }
//    
//}

- (IBAction)back2Tapped:(id)sender
{
    self.shareImageView.hidden=YES;
    self.imgShareBig.image=nil;
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

- (IBAction)shareTapped:(id)sender
{
    BOOL isComment =[self isCommentOrEvent:shareImageTag];
    
    if(isComment)
    {
        NSLog(@"%@",[timeLineArray objectAtIndex:shareImageTag]);

        eventName = [[NSString alloc]init];
        
        eventName = [[[timeLineArray objectAtIndex:shareImageTag]valueForKey:@"Event"] valueForKey:@"name"];
        
        [self shareComom:[[timeLineArray objectAtIndex:shareImageTag] valueForKey:@"Comment"] ShareFlag:2];
    }
    else
    {
        [self shareComom:[[timeLineArray objectAtIndex:shareImageTag] valueForKey:@"Event"] ShareFlag:1];
    }
}
- (IBAction)feedTapped:(id)sender
{
    [self.tblTimeLIne reloadData];
    [self.tblTimeLIne setContentOffset:CGPointZero animated:NO];
    [self.feebView setHidden:YES];
    
}
@end

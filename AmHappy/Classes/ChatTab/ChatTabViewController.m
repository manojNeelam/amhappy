//
//  ChatTabViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import "ChatTabViewController.h"
#import "ChatUserCell.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "ChatFriendsViewController.h"
#import "ChatViewController.h"
#import "NSManagedObject+Utilities.h"
#import "CoreDataUtils.h"



#import "XMPPFramework.h"
#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface ChatTabViewController ()

@end

@implementation ChatTabViewController
{
    ModelClass *mc;
    NSMutableArray *eventsArray;
    NSMutableArray *usersArray;
    int start;
    BOOL isLast;
    NSMutableArray *searchArray;
    BOOL isSearching;
    UIToolbar *mytoolbar1;
    int badgeCount;

}
@synthesize lblTitle,tableViewChat,txtSearch;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
        {
            
            [self tabBarItem].selectedImage = [[UIImage imageNamed:@"chat.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self tabBarItem].image = [[UIImage imageNamed:@"chat2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else
        {
            [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"chat.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"chat2.png"]];
        }
        
    }
    self.title =[localization localizedStringForKey:@"Chat"];
    
   

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title =[localization localizedStringForKey:@"Chat"];
    
    [self.lblTitle setText:[localization localizedStringForKey:@"Chat"]];
    
    [self.txtSearch setPlaceholder:[localization localizedStringForKey:@"Search"]];

    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    [USER_DEFAULTS setValue:[USER_DEFAULTS valueForKey:@"myjid"] forKey:@"myjid"];
    //[USER_DEFAULTS setValue:@"aklesh@192.168.1.100" forKey:@"myjid"];
   // [self.tableViewChat setUserInteractionEnabled:NO];
    
    //[self fetchMessages];
    // [[self tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];


    [USER_DEFAULTS synchronize];
    eventsArray =[[NSMutableArray alloc] init];
    usersArray =[[NSMutableArray alloc] init];
    searchArray =[[NSMutableArray alloc] init];

    start =0;
    isLast =YES;
    isSearching =NO;
    
    if(![DELEGATE connect])
    {
        [DELEGATE connect];
    }
    
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

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UnreadGroupMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UnreadMessage1) name:@"UnreadGroupMessage" object:nil]  ;  //[DELEGATE connect];
    
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Unread" object:nil];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UnreadMessage1) name:@"Unread" object:nil];
    [self.tableViewChat reloadData];
}
-(void)fetchMessages
{
    NSArray *array =[[NSArray alloc]init];
    NSMutableArray *idArray =[[NSMutableArray alloc]init];

    NSString *type =@"C";
    
    NSArray *myArray1 = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    NSString *str =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
   
        array= [CoreDataUtils getObjects:[DB description] withQueryString:@"userid = %@ AND messageType = %@" queryArguments:@[str,type] sortBy:nil];
    
    
    
    // DB1.jid = [NSString stringWithFormat:@"%@",self.fromJId];
    if(array.count>0)
    {
        for(int i=0; i<array.count;i++)
        {
            DB *db =(DB*)[array objectAtIndex:i];
            //[NSString stringWithFormat:@"%@@%@",db.jid,HostingServer];
            [idArray addObject:[NSString stringWithFormat:@"%@@%@",db.jid,HostingServer]];
        }
        
        NSError *error;
        NSData *dateData = [NSJSONSerialization dataWithJSONObject:idArray options:NSJSONWritingPrettyPrinted error:&error];
        NSString *strid = [[NSString alloc] initWithData:dateData encoding:NSUTF8StringEncoding];
        
        if(DELEGATE.connectedToNetwork)
        {
            [mc listInvitedEvents:[USER_DEFAULTS valueForKey:@"userid"] Json:strid Sel:@selector(responseGetEvents:)];
        }
    }
    else
    {
        if(DELEGATE.connectedToNetwork)
        {
            [mc listInvitedEvents:[USER_DEFAULTS valueForKey:@"userid"] Json:@"" Sel:@selector(responseGetEvents:)];
        }
    }
   
}



-(void)donePressed
{
    [self.view endEditing:YES];
    
}
-(void)updateDataBase
{
    NSString *unread =@"Y";
    
   // NSArray *myArray = [[USER_DEFAULTS valueForKey:@"myjid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
  //  NSString *userid =[NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]];
    if(isSearching)
    {
        for (int i=0; i<searchArray.count; i++)
        {
            
            NSArray *myArray1 = [[[searchArray objectAtIndex:i]valueForKey:@"jid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
            NSString *jid =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
            
            NSArray *array =[[NSArray alloc ]initWithArray:[CoreDataUtils getObjects:[DB description] withQueryString:@"jid = %@ AND unread = %@ " queryArguments:@[jid,unread]]];
            
            NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithDictionary:[searchArray objectAtIndex:i]];
            
            [dict setValue:[NSString stringWithFormat:@"%lu",(unsigned long)array.count] forKey:@"message_count"];
            if(array.count>0)
            {
                DB *db =(DB*)[array lastObject];
                [dict setValue:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",db.message]] forKey:@"last_message"];
            }
            else
            {
                
                NSArray *array =[[NSArray alloc ]initWithArray:[CoreDataUtils getObjects:[DB description] withQueryString:@"jid = %@" queryArguments:@[jid]]];
                if(array.count>0)
                {
                    DB *db =(DB*)[array lastObject];
                    [dict setValue:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",db.message]] forKey:@"last_message"];
                    [dict setValue:[NSString stringWithFormat:@"%@",db.time] forKey:@"time"];

                }
                else
                {
                  /*  if([[[searchArray objectAtIndex:i]valueForKey:@"is_group"] isEqualToString:@"N"])
                    {*/
                        [dict setValue:@"" forKey:@"time"];
                        [dict setValue:[localization localizedStringForKey:@"No message"] forKey:@"last_message"];
                    
                   // }
                }
            }
            [searchArray replaceObjectAtIndex:i withObject:dict];
            
            dict =nil;
            array =nil;
            
        }
        
        NSArray *temp =[[NSArray alloc] initWithArray:searchArray];
        NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO ];
        [searchArray removeAllObjects];
        [searchArray addObjectsFromArray:[temp sortedArrayUsingDescriptors:@[sort1]]] ;
        badgeCount=0;
        for(int i=0;i<searchArray.count;i++)
        {
            badgeCount +=[[[searchArray objectAtIndex:i] valueForKey:@"message_count"] intValue];
        }
        
        if(badgeCount==0)
        {
            
            [[self tabBarItem] setBadgeValue:nil];
            
        }
        else
        {
            [[self tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
        }
        
    }
    else
    {
        [usersArray removeAllObjects];
        for (int i=0; i<eventsArray.count; i++)
        {
            
            NSArray *myArray1 = [[[eventsArray objectAtIndex:i]valueForKey:@"jid"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
            NSString *jid =[NSString stringWithFormat:@"%@",[myArray1 objectAtIndex:0]];
            
            NSArray *array =[[NSArray alloc ]initWithArray:[CoreDataUtils getObjects:[DB description] withQueryString:@"jid = %@ AND unread = %@ " queryArguments:@[jid,unread]]];
            
            NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithDictionary:[eventsArray objectAtIndex:i]];
            [dict setValue:[NSString stringWithFormat:@"%lu",(unsigned long)array.count] forKey:@"message_count"];
            if(array.count>0)
            {
                DB *db =(DB*)[array lastObject];
                [dict setValue:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",db.message]] forKey:@"last_message"];
                [dict setValue:[NSString stringWithFormat:@"%@",db.time] forKey:@"time"];
                [usersArray addObject:dict];

            }
            else
            {
                
                NSArray *array =[[NSArray alloc ]initWithArray:[CoreDataUtils getObjects:[DB description] withQueryString:@"jid = %@" queryArguments:@[jid]]];
                if(array.count>0)
                {
                    DB *db =(DB*)[array lastObject];
                    [dict setValue:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",db.message]] forKey:@"last_message"];
                    [dict setValue:[NSString stringWithFormat:@"%@",db.time] forKey:@"time"];
                    [usersArray addObject:dict];


                }
                else
                {
                   /* if([[[eventsArray objectAtIndex:i]valueForKey:@"is_group"] isEqualToString:@"N"])
                    {*/
                        [dict setValue:[localization localizedStringForKey:@"No message"] forKey:@"last_message"];
                    [dict setValue:@"" forKey:@"time"];


                   // }
                     if([[[eventsArray objectAtIndex:i]valueForKey:@"is_group"] isEqualToString:@"Y"])
                     {
                         [usersArray addObject:dict];

                     }
                    
                }
            }
            
            [eventsArray replaceObjectAtIndex:i withObject:dict];
            dict =nil;
            array =nil;
            
        }
        
        NSArray *temp =[[NSArray alloc] initWithArray:usersArray];
       NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO ];
        [usersArray removeAllObjects];
        [usersArray addObjectsFromArray:[temp sortedArrayUsingDescriptors:@[sort1]]] ;
        if(usersArray.count>0)
        {
            badgeCount=0;
            for(int i=0;i<usersArray.count;i++)
            {
                badgeCount +=[[[usersArray objectAtIndex:i] valueForKey:@"message_count"] intValue];
            }
            
            if(badgeCount==0)
            {
                [[self tabBarItem] setBadgeValue:nil];
            }
            else
            {
                [[self tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
            }
        }
    }

   // [[eventsArray objectAtIndex:indexPath.row] valueForKey:@"message_count"]
    
    //
    [self.tableViewChat reloadData];
}
-(void)viewWillAppear:(BOOL)animated
{
    
    
    
    
  //  NSLog(@"chat is %@",[localization localizedStringForKey:@"Chat"]);


  /*  if(DELEGATE.isInvited)
    {*/
        start=0;
        isSearching=NO;
        [searchArray removeAllObjects];
        [eventsArray removeAllObjects];
        
       [self fetchMessages];
   // }
    
    
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
        [self.tableViewChat reloadData];
    }
}
- (void)filterListForSearchText:(NSString *)searchText
{
    [searchArray removeAllObjects];
    
    if(usersArray.count>0)
    {
        for(int i=0;i<usersArray.count;i++)
        {
            NSRange nameRange;
            //            if(socialId==2)
            //            {
            //                GTLPlusPerson *per =[friendsArray objectAtIndex:i];
            //                 nameRange = [per.displayName rangeOfString:searchText options:NSCaseInsensitiveSearch];
            //                per =nil;
            //            }
            //            else
            //            {
            nameRange = [[[usersArray objectAtIndex:i] valueForKey:@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            //}
            if (nameRange.location != NSNotFound) {
                [searchArray addObject:[usersArray objectAtIndex:i]];
            }
            
            
        }
    }
    [self.tableViewChat reloadData];
    
}

-(void)responseGetEvents:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        DELEGATE.isInvited =NO;
        /*
         id = 6;
         image = "";
         "is_group" = Y;
         jid = "room6@conference.192.168.1.102";
         "last_message" = "";
         "message_count" = 0;
         name = "zakir test";
         */
        
        [eventsArray addObjectsFromArray:[results valueForKey:@"Group"]];
        [self updateDataBase];
        [self.tableViewChat reloadData];
        
     
    }
    else
    {
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
      /*  UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"No result found"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
        [alert show];*/
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
   /* CGPoint targetPoint = *targetContentOffset;
    CGPoint currentPoint = scrollView.contentOffset;
    
    if (targetPoint.y > currentPoint.y)
    {
        NSLog(@"up");
    }
    else
    {
        if(!isLast)
        {
            start=start+10;
            //[self callApi];
        }
        NSLog(@"down");
    }*/
}

-(void)UnreadMessage1
{
    [self updateDataBase];
}
- (void)handleFriendsTapFrom: (UITapGestureRecognizer *)recognizer
{
    UIView *view = [recognizer view];
    
    if(isSearching)
    {
        if([[[searchArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:1];
        }
    }
    else
    {
        if([[[usersArray objectAtIndex:view.tag] valueForKey:@"thumb_image"] length]>0)
        {
            [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[usersArray objectAtIndex:view.tag] valueForKey:@"image"]] Type:1];
        }
    }
    
  
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearching)
    {
        if(searchArray.count>0)
        {
            return searchArray.count;
        }
        else return 0;
    }
    else
    {
        if(usersArray.count>0)
        {
            return usersArray.count;
        }
        else return 0;
    }
    
   
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    ChatUserCell *cell = (ChatUserCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatUserCell" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
    }
    
    if(IS_IPAD)
    {
        [cell.lblCount setFont:FONT_Regular(18)];
        [cell.lblName setFont:FONT_Regular(22)];
        
    }
    else
    {
        /* [cell.lblPrivate setFont:FONT_Regular(10)];
         [cell.lblName setFont:FONT_Regular(15)];
         [cell.lblDate setFont:FONT_Regular(12)];*/
        
        
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFriendsTapFrom:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.cancelsTouchesInView = YES;
    cell.imgUser.tag =indexPath.row;
    [cell.imgUser addGestureRecognizer:tapGestureRecognizer];
    
    cell.imgUser.layer.masksToBounds = YES;
    cell.imgUser.layer.cornerRadius = 25.0;
    
    /*
     "category_id" = 5;
     date = 1424111400;
     description = "The ";
     id = 3;
     image = "";
     latitude = "23.022505";
     location = "Ahmedabad, Gujarat, India";
     longitude = "72.571365";
     name = "the ";
     "room_id" = "";
     type = Expired;
     */
    [cell.lblName setHidden:YES];
    if(isSearching)
    {
        cell.lblName2.text =[[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.lblCount.text =[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] valueForKey:@"message_count"]];
        if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[searchArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
    }
    else
    {
        cell.lblName2.text =[[usersArray objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.lblCount.text =[NSString stringWithFormat:@"%@",[[usersArray objectAtIndex:indexPath.row] valueForKey:@"message_count"]];
        if([[[usersArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"] length]>0)
        {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[usersArray objectAtIndex:indexPath.row] valueForKey:@"thumb_image"]]];
        }
        
         cell.lblLastMessage.text =[NSString stringWithFormat:@"%@",[[usersArray objectAtIndex:indexPath.row] valueForKey:@"last_message"]];
    }
    
    
   
   
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewController *cvc = [[ChatViewController alloc]init];
    if(isSearching)
    {
        if([[[searchArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
        {
            cvc.imgUrl = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] valueForKey:@"image"]];
            
            
        }
        [cvc setEventId:[NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row]valueForKey:@"id"]]];
        
        NSString *abc = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row]valueForKey:@"jid"]];
        NSArray *myArray = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
        cvc.fromJId = [NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]];
        if([[[searchArray objectAtIndex:indexPath.row]valueForKey:@"is_group"] isEqualToString:@"N"])
        {
            [cvc setIsGroupChat:NO];
            cvc.fromUserId = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row]valueForKey:@"id"]];
        }
        else
        {
            [cvc setIsGroupChat:YES];
        }
        badgeCount -=[[[searchArray objectAtIndex:indexPath.row]valueForKey:@"message_count"] intValue];
        
        if(badgeCount==0)
        {
            
            [[self tabBarItem] setBadgeValue:nil];
            
        }
        else
        {
            [[self tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
        }
        

        cvc.name = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] valueForKey:@"name"]];
    }
    else
    {
        [cvc setEventId:[NSString stringWithFormat:@"%@",[[usersArray objectAtIndex:indexPath.row]valueForKey:@"id"]]];
        NSString *abc = [NSString stringWithFormat:@"%@",[[usersArray objectAtIndex:indexPath.row]valueForKey:@"jid"]];
        NSArray *myArray = [abc componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
        cvc.fromJId = [NSString stringWithFormat:@"%@",[myArray objectAtIndex:0]];
        if([[[usersArray objectAtIndex:indexPath.row]valueForKey:@"is_group"] isEqualToString:@"N"])
        {
            [cvc setIsGroupChat:NO];
            cvc.fromUserId = [NSString stringWithFormat:@"%@",[[usersArray objectAtIndex:indexPath.row]valueForKey:@"id"]];
        }
        else
        {
            [cvc setIsGroupChat:YES];
        }
        if([[[usersArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
        {
            cvc.imgUrl = [NSString stringWithFormat:@"%@",[[usersArray objectAtIndex:indexPath.row] valueForKey:@"image"]];
        }
        
            
        
        badgeCount -=[[[usersArray objectAtIndex:indexPath.row]valueForKey:@"message_count"] intValue];
        
        if(badgeCount==0)
        {
            
            [[self tabBarItem] setBadgeValue:nil];
            
        }
        else
        {
            [[self tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
        }
        
        cvc.name = [NSString stringWithFormat:@"%@",[[usersArray objectAtIndex:indexPath.row] valueForKey:@"name"]];
    }
    
    [self.view endEditing:YES];
    self.txtSearch.text =@"";
    
       [self.navigationController pushViewController:cvc animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [DELEGATE managedObjectContext_roster];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            DDLogError(@"Error performing fetch: %@", error);
        }
        
    }
    
    return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableViewChat] reloadData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
//    NSLog(@"groups are %@",user.groups);
//    if(user.groups.count>0)
//    {
//        NSArray *array =[NSArray arrayWithArray:[user.groups allObjects]];
//        for(int i=0;i<array.count;i++)
//        {
//            XMPPGroupCoreDataStorageObject *group =[array objectAtIndex:i];
//            NSLog(@"group is %@",group.users);
//        }
//    }
    if (user.photo != nil)
    {
        cell.imageView.image = user.photo;
    }
    else
    {
        NSData *photoData = [[DELEGATE xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            cell.imageView.image = [UIImage imageWithData:photoData];
        else
            cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    NSLog(@"count is %lu",(unsigned long)[[[self fetchedResultsController] sections] count]);
//    return [[[self fetchedResultsController] sections] count];
//}
//
//- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
//{
//    NSArray *sections = [[self fetchedResultsController] sections];
//    
//    if (sectionIndex < [sections count])
//    {
//        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
//        
//        int section = [sectionInfo.name intValue];
//        // NSLog(@"section is %d",section);
//        // NSLog(@"section is %@",sectionInfo.indexTitle);
//        
//        switch (section)
//        {
//            case 0  : return @"Available";
//            case 1  : return @"Away";
//            default : return @"Offline";
//        }
//    }
//    
//    return @"";
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
//{
//    NSArray *sections = [[self fetchedResultsController] sections];
//    
//    if (sectionIndex < [sections count])
//    {
//        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
//        return sectionInfo.numberOfObjects;
//    }
//    
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                      reuseIdentifier:CellIdentifier];
//    }
//    
//    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    cell.textLabel.text = user.displayName;
//    [self configurePhotoForCell:cell user:user];
//    return cell;
//}

- (XMPPStream *)xmppStream {
    return [DELEGATE xmppStream];
}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    NSLog(@"user man %@",user);
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    ChatViewController *cvc = [[ChatViewController alloc]init];
//    cvc.userId = [NSString stringWithFormat:@"%@",user.jid];
//    [self.navigationController pushViewController:cvc animated:YES];
//}


- (IBAction)addTapped:(id)sender
{
    ChatFriendsViewController *chathVC =[[ChatFriendsViewController alloc] initWithNibName:@"ChatFriendsViewController" bundle:nil];
    [self.navigationController pushViewController:chathVC animated:YES];
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

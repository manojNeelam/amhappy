//
//  CommentDetail.m
//  
//
//  Created by Peerbits MacMini9 on 28/03/16.
//
//

#import "CommentDetail.h"
#import "ReplyCell.h"
#import "NSDate+TimeAgo.h"
#import "userCell.h"

#import "DAAttributedLabel.h"
#import "DAAttributedStringFormatter.h"
#import "DAFontSet.h"
#import "OtherUserProfileViewController.h"

#define AddCommentPlaceHolder @"Write a comment..."

@interface CommentDetail ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,DAAttributedLabelDelegate>

{
    ModelClass *mc;
    
    NSMutableArray *Comments,*arrayToTag,*arrayFilteredTag,*UserToHighlight,*taggedUsers;
    
    BOOL isLoadMoreCalled,isBeginTagging,isSerchFromData,isLast;
 
    UIImagePickerController *pickerController;
    
    UIImage *pickedImage;
    
    NSString *isLiked,*strLastTag,*taggedUserIds;
    
    int likedIndex;
    
    DAAttributedStringFormatter* formatter;

   
}

@end

@implementation CommentDetail

@synthesize commentID,gettedReplies,eventID,isImageReplies;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _txtviewComment.autocorrectionType = UITextAutocorrectionTypeNo;
    
    formatter = [[DAAttributedStringFormatter alloc] init];
    formatter.defaultFontFamily = @"Avenir";
    formatter.defaultColor = [UIColor lightGrayColor];
    formatter.fontFamilies = @[ @"Courier", @"Arial", @"Georgia" ];
    formatter.defaultPointSize = 14.0f;
    formatter.colors = @[[UIColor colorWithRed:49.0/255.0 green:160.0/255.0 blue:218.0/255.0 alpha:1.0],[UIColor redColor]];
    

   // NSLog(@"%@",gettedReplies);
   // NSLog(@"%@",commentID);
    
     self.tblComments.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tblUsers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    [self initialSetup];
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{

    [DELEGATE enableIQKeyboard];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [DELEGATE DisableIQKeyboard];
}

-(void)initialSetup
{

    isBeginTagging = NO;
    
  
    
    arrayToTag = [[NSMutableArray alloc]init];
    
    
    taggedUsers = [[NSMutableArray alloc]init];
    
    UserToHighlight = [[NSMutableArray alloc]init];
    
   
    
    
    arrayFilteredTag = [[NSMutableArray alloc]init];
    
    likedIndex = -1;
    
    isLiked = [[NSString alloc]init];
    taggedUserIds           = [[NSString alloc] init];
    
    taggedUserIds = @"";
    strLastTag    = @"";
    
    isLast = YES;

    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    
    _imgPickedimage.contentMode = UIViewContentModeScaleAspectFill;
    _imgPickedimage.clipsToBounds = YES;

    [self checkForPickedImage];

    [self.tblComments reloadData];
  
    
    if (isImageReplies)
    {
        if ([DELEGATE connectedToNetwork])
        {
            
            [mc GetReplies:[USER_DEFAULTS valueForKey:@"userid"] comment_id:[NSString stringWithFormat:@"%@",commentID] Sel:@selector(gettedReplies:)];
            
        }
        
    }
    else{
        
        if(DELEGATE.connectedToNetwork)
        {
            [mc getFriendsforAddinGroup:[USER_DEFAULTS valueForKey:@"userid"] Start:nil Limit:nil Groupid:nil Sel:@selector(responseGetFriends:)];
            
        }
    }
   
}


-(void)responseGetFriends:(NSDictionary *)response
{
    
    NSLog(@"result is %@",response);
    
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        arrayToTag = [[NSMutableArray alloc]initWithArray:[response valueForKey:@"Friend"]];
        [_tblUsers reloadData];
        
        [self.tblComments reloadData];
        
    }
    else
    {
        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
        
    }
    
}

-(void)gettedReplies:(NSDictionary *)response
{
    
    NSLog(@"result is %@",response);
 
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        if(DELEGATE.connectedToNetwork)
        {
            [mc getFriendsforAddinGroup:[USER_DEFAULTS valueForKey:@"userid"] Start:nil Limit:nil Groupid:nil Sel:@selector(responseGetFriends:)];
            
        }
        
        gettedReplies = [[NSMutableArray alloc]initWithArray:[response valueForKey:@"Reply"]];
        
        [_tblComments reloadData];
        
    }
    else
    {
        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }

    
}

//-(void)usersToTag:(NSDictionary *)response
//{
//
//    NSLog(@"result is %@",response);
//  
//    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
//    {
// 
//        [arrayToTag addObjectsFromArray:[response valueForKey:@"Users"]];
//        
//        [_tblUsers reloadData];
//    
//    }
//    else
//    {
//        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
//        
//    }
//  
//}


-(void)DisplayUserToTag
{
    
    _viewTagTop.constant = 0;
}

-(void)hideUsersToTag
{
    
    _viewTagTop.constant = -1000;
    
}


#pragma mark ---------- table view datasorce ----------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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
    
    return [gettedReplies count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
        
        
       
        
        ReplyCell *cell = (ReplyCell *)[self.tblComments dequeueReusableCellWithIdentifier:@"ReplyCell"];
        
        if (cell==nil)
        {
            NSArray *arrNib=[[NSBundle mainBundle] loadNibNamed:@"ReplyCell" owner:self options:nil];
            cell= (ReplyCell *)[arrNib objectAtIndex:0];
            
        }
        
        cell.tag = indexPath.row;
        
        cell.btnLike.tag = indexPath.row;
        cell.lblComment.tag = indexPath.row;
        
        
        [cell.btnLike addTarget:self action:@selector(likeReply:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.lblLikes setText:[NSString stringWithFormat:@"%@ Like",[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"like_count"]]];
        
        
        if ([[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"is_liked"]isEqualToString:@"N"])
        {
            
            [cell.imgLike setImage:[UIImage imageNamed:@"like1"]];
            
        }
        else
        {
            
            [cell.imgLike setImage:[UIImage imageNamed:@"like2"]];
            
        }
        
        
        if (![[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"userimage"]isEqualToString:@""])
        {
            
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"userimage"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            
        }
        else{
            
            [cell.imgUser setImage:[UIImage imageNamed:@"placeholder"]];
            
        }
        
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.width/2;
        cell.imgUser.clipsToBounds = YES;
        
        cell.imgUser.contentMode = UIViewContentModeScaleAspectFill;
        
        if ([[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"username"])
        {
            [cell.lblUserName setText:[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"username"]];
            
        }
        
        if ([[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"time"])
        {
            
            NSDate *date= [NSDate dateWithTimeIntervalSince1970:[[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"time"] doubleValue]];
            
            cell.lblTimeWidth.constant = [self getTextWidth:[date timeAgo]];
            
            [cell.lblTime setText:[date timeAgo]];
            
        }
        
        if (![[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"comment"]isEqualToString:@""])
        {
            
             //cell.lblComment.hidden = NO;
      
            NSData *data = [[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"comment"] dataUsingEncoding:NSUTF8StringEncoding];
            NSString *decodedComment = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            
            DAAttributedLabel *lbl = [[DAAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, ScreenSize.width-70, 26)];
            
            
            lbl.text = [self DecodeCommentString:decodedComment usersTagged:[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"Tags"]];
            
            [lbl setPreferredHeight];
            
            int requiredHeight = [lbl getPreferredHeight];
            
            
            if (requiredHeight < 26)
            {
                
                cell.lblCommentHeight.constant = 26;
            }
            else{
                
                cell.lblCommentHeight.constant = requiredHeight;
                
            }
            
            
            
            
            UserToHighlight = [[NSMutableArray alloc]init];
     
            
            cell.lblComment.text = [self DecodeCommentString:decodedComment usersTagged:[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"Tags"]];
            
            [cell.lblComment setPreferredHeight];
            
            cell.lblComment.delegate = self;
            
            
            //cell.lblCommentHeight.constant = [cell.lblComment getPreferredHeight];
        
        }
        else
        {
            
            cell.lblComment.text = @"";
            
            [cell.lblComment setPreferredHeight];
            
            cell.lblComment.delegate = self;
            
           cell.lblCommentHeight.constant = 0;
            
           cell.imgCommentTop.constant = 0;
            
            //cell.lblComment.hidden = YES;
        }
        
        
        if (![[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"image"]isEqualToString:@""])
        {
            
            [self updateCellwithCommentImage:cell];
            
            [cell.imgComment sd_setImageWithURL:[NSURL URLWithString:[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            
        }
        else{
            
            [self updateCellwithNOCommentImage:cell];
            
        }
        
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
 
        
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







- (LinkedStringTapHandler)exampleHandlerWithTitle:(HBVLinkedTextView*)textView1
{
    
    // captionIndex = (int)textView.tag;
    
    LinkedStringTapHandler exampleHandler = ^(NSString *linkedString)
    {
        
        NSLog(@"%@",linkedString);
        
        //        NSMutableArray *tagArray = [[NSMutableArray alloc] initWithArray: [[commentArray objectAtIndex:textView1.tag] valueForKey:@"tagged_user_id"]];
        //
        //        BOOL isUser = NO;
        //
        //        for (int i=0; i<tagArray.count; i++)
        //        {
        //            if ([[[tagArray objectAtIndex:i] valueForKey:@"user_name"]isEqualToString:linkedString])
        //            {
        //                // UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        //
        ////                ProfileCommonViewController *profile = [[ProfileCommonViewController alloc] initWithNibName:@"ProfileCommonViewController" bundle:nil];
        ////                [profile setHidesBottomBarWhenPushed:NO];
        ////                profile.user_id = [[tagArray objectAtIndex:i] valueForKey:@"user_id"];
        ////                profile.IsOthersProfile = YES;
        //
        //                //    isUser = YES;
        //
        //               // [self.navigationController pushViewController:profile animated:YES];
        //
        //                
        //                return ;
        //            }
        //            
        //        }
        
    };
    
    return exampleHandler;
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
            
           // NSLog(@"%@",[substring substringFromIndex:[substring length] - 1]);
            
            if ([[substring substringFromIndex:[substring length] - 1] isEqualToString:@"$"])
            {
                
                substring = [substring substringToIndex:[substring length] - 1];
                
                NSRange range = [commentText rangeOfString:substring];
                
                //NSLog(@"%lu",(unsigned long)range.location);
                
                
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
    
    
    //NSLog(@"%@",commentText);
    
    //NSLog(@"%@",[formatter formatString:commentText]);
    
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





-(void)likeReply:(UIButton *)sender
{
    
    
    likedIndex = (int)sender.tag;
    NSLog(@"%ld",(long)sender.tag
          );
    
    if ([DELEGATE connectedToNetwork])
    {

        if ([[[gettedReplies objectAtIndex:likedIndex]valueForKey:@"is_liked"]isEqualToString:@"N"])
        {

             isLiked = @"Y";
         
        }
        else{
            
              isLiked = @"N";
         
        }
        
        [mc ReplyLike:[USER_DEFAULTS valueForKey:@"userid"] reply_id:[NSString stringWithFormat:@"%@",[[gettedReplies objectAtIndex:likedIndex]valueForKey:@"id"]] is_like:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",isLiked]] Sel:@selector(LikedReply:)];
     
    }

}

#pragma mark -------- Liked Reply -----------

-(void)LikedReply:(NSDictionary *)response
{
    NSLog(@"result is %@",response);
    
    
    
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        DELEGATE.isEventEdited=YES;
 
        NSMutableDictionary *replyData = [[gettedReplies objectAtIndex:likedIndex]mutableCopy];
        [replyData setValue:[NSString stringWithFormat:@"%@",isLiked] forKey:@"is_liked"];
        [replyData setValue:[NSString stringWithFormat:@"%@",[response valueForKey:@"like_count"]] forKey:@"like_count"];
        [gettedReplies setObject:replyData atIndexedSubscript:likedIndex];
        
        [_tblComments reloadData];
     
    }
    else
    {
        [DELEGATE showalert:self Message:[response valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
        
    }
 
}

-(void)updateCellwithNOCommentImage:(ReplyCell *)cell
{

    cell.imgCommentTop.constant = 0;
    cell.imgCommentHeight.constant = 0;

}

-(void)updateCellwithCommentImage:(ReplyCell *)cell
{
    
    cell.imgComment.contentMode = UIViewContentModeScaleAspectFill;
    cell.imgComment.clipsToBounds = YES;
    cell.imgCommentHeight.constant = ScreenSize.width/2;

    cell.imgCommentTop.constant = 5;

   // [cell layoutIfNeeded];
  
}

-(CGFloat)getTextWidth:(NSString *)text
{
    if ([gettedReplies count]>0)
    {
        
        CGSize maximumSize = CGSizeMake(150,20);
        
        UIFont *fontName = [UIFont fontWithName:self.lblTopHeader.font.fontName size:12.5];
        
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




-(CGFloat)getTextHeight:(NSString *)text
{
    if ([gettedReplies count]>0)
    {
        
        CGSize maximumSize = CGSizeMake(ScreenSize.width-70,10000);
        
        UIFont *fontName = [UIFont fontWithName:self.lblTopHeader.font.fontName size:14.5];
        
        CGRect labelHeighSize = [text boundingRectWithSize:maximumSize
                                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 
                                                attributes:@{NSFontAttributeName:fontName}
                                                   context:nil];
        
        return labelHeighSize.size.height;
        
        
    }
    else{
        
        return 0;
    }
    
}



//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    static NSString *CellIdentifier = @"headercell";
//    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (headerView == nil){
//        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
//    }
//    
//   
//    return headerView;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    
//    return 44;
//    
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == 100)
    {
        
        return 45;
        
    }
    else{
        
        if ([gettedReplies count]>0)
        {
            
            
            
            
            if ([[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"comment"]isEqualToString:@""])
            {
                
                return 38 + (ScreenSize.width/2) + 25;
                
            }
            else
            {
                // where 33 is the y postion of comment label
                
                NSData *data = [[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"comment"] dataUsingEncoding:NSUTF8StringEncoding];
                NSString *decodedComment = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
                
                
                DAAttributedLabel *lbl = [[DAAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, ScreenSize.width-70, 26)];
                
             
                lbl.text = [self DecodeCommentString:decodedComment usersTagged:[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"Tags"]];
                
                [lbl setPreferredHeight];
                
                NSLog(@"%f",[lbl getPreferredHeight]);
                
                
                
                int requiredHeight = [lbl getPreferredHeight];
                
                if (requiredHeight < 26)
                {
                    
                    if (![[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"image"]isEqualToString:@""])
                    {
                        
                        return 80 + (ScreenSize.width/2) + 10;
                    }
                    
                    return 85;
                    
                }
                else{
                    
                    
                    if (![[[gettedReplies objectAtIndex:indexPath.row]valueForKey:@"image"]isEqualToString:@""])
                    {
                        return 33 + [lbl getPreferredHeight] + 25 + (ScreenSize.width/2) + 10;
                    }
                    else{
                        
                        return 33 + [lbl getPreferredHeight] + 30;
                        
                    }
                    
                    
                }
                
                
                
            }
            
            
        }
        else{
            
            return 0;
        }

        
    }
 
}

#pragma mark --------- tableview Delegate ---------

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == 100)
    {
        if (isSerchFromData)
        {
            
            taggedUserIds = [taggedUserIds stringByAppendingString:[NSString stringWithFormat:@"%@,",[[arrayFilteredTag objectAtIndex:indexPath.row] valueForKey:@"user_id"]]];
            
            NSString *searchstring = [[DELEGATE getArrayByRemovingString:@"@" fromstring:_txtviewComment.text] lastObject];
            
            NSRange range ;
            range = [_txtviewComment.text rangeOfString:searchstring];
            
            NSString *final = [_txtviewComment.text stringByReplacingCharactersInRange:range withString:@""];
            
            _txtviewComment.text = [final stringByAppendingString:[NSString stringWithFormat:@"%@",[[arrayFilteredTag objectAtIndex:indexPath.row] valueForKey:@"tag_name"]]];
            
         
            
            
        }
        else
        {
            _txtviewComment.text = [_txtviewComment.text stringByAppendingString:[NSString stringWithFormat:@"%@",[[arrayToTag objectAtIndex:indexPath.row] valueForKey:@"tag_name"]]];
            
          
            
            
            taggedUserIds = [taggedUserIds stringByAppendingString:[NSString stringWithFormat:@"%@,",[[arrayToTag objectAtIndex:indexPath.row] valueForKey:@"user_id"]]];
        }
        
        isSerchFromData = NO;
        isBeginTagging = NO;
        [self.tblUsers reloadData];
        
 
    }
    
    
   
}


- (void)didReceiveMemoryWarning
{
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

#pragma mark ----------- TextView / add Comment --------



-(void)formateTextView:(UITextView *)textView
{
    textView.text = AddCommentPlaceHolder;
    textView.textColor = [UIColor lightGrayColor];
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    
    NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![trimmedString isEqualToString:@""])
    {
        
        if ([trimmedString isEqualToString:@"Write a comment..."])
        {
            textView.text = @"";
            textView.textColor = [UIColor lightGrayColor];
    
        }
        else{
            
            textView.textColor = [UIColor blackColor];
            
        }
  
    }
    else{
        
         textView.textColor = [UIColor blackColor];
        
    }
    
    [self UpdateTopBar];

}

-(void)UpdateTopBar
{
    if (IS_IPAD)
    {
        self.viewHeaderTop.constant = 313;
    }
    else{
        
        self.viewHeaderTop.constant = 216;
        
    }
 
}

-(void)TopBar
{
    self.viewHeaderTop.constant = 0;
}


-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmedString isEqualToString:@""] || [trimmedString isEqualToString:@"Write a comment..."])
    {
        
        textView.text = AddCommentPlaceHolder;
        textView.textColor = [UIColor lightGrayColor];
        
    }
    else{
     
        textView.text = trimmedString;
        textView.textColor = [UIColor blackColor];
    }
   
    [self TopBar];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self TopBar];
    return YES;
}




-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
 
    if ([text isEqualToString:@"\n"])
    {
        return NO;  
    }
  
    return YES;
}



-(void)valueChanged:(UITextView *)textView
{
    int numLines = [textView.text sizeForWidth:textView.frame.size.width font:textView.font].height / textView.font.lineHeight - 1;
    
    if (numLines < 5 && numLines > 0)
    {
        
        [textView.superview setTranslatesAutoresizingMaskIntoConstraints:YES];
        CGRect tFrame = textView.superview.frame;
        
        CGRect frame = CGRectMake(tFrame.origin.x, ScreenSize.height - (50 + 15.0*numLines), tFrame.size.width, 50.0+(15.0*numLines));
       
        textView.superview.frame = frame;
   
    }
 
}

-(void)textViewDidChange:(UITextView *)textView
{
    
    NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmedString isEqualToString:@""] || [trimmedString isEqualToString:@"Write a comment..."])
    {
         textView.textColor = [UIColor lightGrayColor];
        
    }
    else{
        
          textView.textColor = [UIColor blackColor];
        
    }
    
    if (_txtviewComment.text.length == 0)
    {
        [self clickCLose:self.btnClose];
        return;
    }
    
    NSString *lastChar = [_txtviewComment.text substringFromIndex:_txtviewComment.text.length - 1];
    
    
    if (isBeginTagging)
    {
        NSString *searchstring = [[DELEGATE getArrayByRemovingString:@"@" fromstring:_txtviewComment.text] lastObject];
        
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
                    
                    _viewTagTop.constant = 255;
                    
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
                _viewTagTop.constant = -1500;
                
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
                
                _viewTagTop.constant = 255;
                
            } completion:nil];
        }
        
    }
    
    else
    {
        
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            //  self.viewShareReport.frame = self.scrollViewObj.frame;
            
           _viewTagTop.constant = -1500;
        } completion:nil];
    }

    
    [self valueChanged:textView];
    
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





#pragma mark ----------- Click Events ------------------

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)CommentValidation
{
    
    [self.view endEditing:YES];
    
    if (pickedImage != nil)
    {
        
         return YES;
    }
    else{
        
        NSString *trimmedString = [_txtviewComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([trimmedString isEqualToString:@""]||[trimmedString isEqualToString:@"Write a comment..."])
        {
            return NO;
            
        }
        else{
            
            return YES;
        }
        
    }
   
}

- (IBAction)clickSend:(id)sender
{
    
    _viewTagTop.constant = -1500;
    
    if ([self CommentValidation])
    {
        if ([DELEGATE connectedToNetwork])
        {
 
            if (pickedImage == nil)
            {
              
                
                
                NSData *data = [_txtviewComment.text dataUsingEncoding:NSNonLossyASCIIStringEncoding];
                NSString *unicodeString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                
                
                //********* change comment text with friends here and send it to backend
                
                NSString *commentText = unicodeString;
                
                commentText = [commentText stringByAppendingString:@" "];
                
                taggedUsers = [[NSMutableArray alloc]init];
                
                commentText = [self encodeCommentString:commentText];
                
                
                NSLog(@"%@",taggedUsers);
            
                
                [mc ReplyOnComment:[USER_DEFAULTS valueForKey:@"userid"] eventid:[NSString stringWithFormat:@"%@",eventID] comment_id:[NSString stringWithFormat:@"%@",commentID] reply:[NSString stringWithFormat:@"%@",commentText] reply_tags:[taggedUsers count]>0?[NSString stringWithFormat:@"%@",[taggedUsers componentsJoinedByString:@","]]:nil  image:nil Sel:@selector(replyAdded:)];
                
                
                
            }
            else{
                
                
                NSString *trimmedString = [_txtviewComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if ([trimmedString isEqualToString:@""]||[trimmedString isEqualToString:@"Write a comment..."])
                {
          
                    NSData *imageData = UIImageJPEGRepresentation(pickedImage, 1);
                    
                    [mc ReplyOnComment:[USER_DEFAULTS valueForKey:@"userid"] eventid:[NSString stringWithFormat:@"%@",eventID] comment_id:[NSString stringWithFormat:@"%@",commentID] reply:nil reply_tags:nil image:imageData Sel:@selector(replyAdded:)];
                    
                }
                else{
                    
                    NSData *data = [_txtviewComment.text dataUsingEncoding:NSNonLossyASCIIStringEncoding];
                    NSString *unicodeString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    
                    //********* change comment text with friends here and send it to backend
                    
                    NSString *commentText = unicodeString;
                    
                    commentText = [commentText stringByAppendingString:@" "];
                    
                    taggedUsers = [[NSMutableArray alloc]init];
                    
                    commentText = [self encodeCommentString:commentText];
                    
                    
                    NSLog(@"%@",taggedUsers);

                    NSData *imageData = UIImageJPEGRepresentation(pickedImage, 1);
                    
                    [mc ReplyOnComment:[USER_DEFAULTS valueForKey:@"userid"] eventid:[NSString stringWithFormat:@"%@",eventID] comment_id:[NSString stringWithFormat:@"%@",commentID] reply:[NSString stringWithFormat:@"%@",commentText] reply_tags:[taggedUsers count]>0?[NSString stringWithFormat:@"%@",[taggedUsers componentsJoinedByString:@","]]:nil image:imageData Sel:@selector(replyAdded:)];
                    
                }
                
                
               
                
            }
      
        }
        
    }
  
}


- (void)label:(DAAttributedLabel *)label didSelectLink:(NSInteger)linkNum
{
    
    NSLog(@"%@",label);
    
    NSLog(@"%ld",(long)label.tag);
    
    NSLog(@"%ld",(long)linkNum);
    
    NSMutableArray *tagArray = [[NSMutableArray alloc] initWithArray: [[gettedReplies objectAtIndex:label.tag] valueForKey:@"Tags"]];
    
    if ([tagArray count]>0)
    {
        
        OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
        [otherVC setUserId:[NSString stringWithFormat:@"%@",[[tagArray objectAtIndex:(long)linkNum] valueForKey:@"id"]]];
        [self.navigationController pushViewController:otherVC animated:YES];
     
    }
    
}

- (IBAction)cameraClicked:(id)sender
{
    pickerController = [[UIImagePickerController alloc]
                        init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"" message:[localization localizedStringForKey:@"Select your image source type"] delegate:self cancelButtonTitle:[localization localizedStringForKey:@"Cancel"] otherButtonTitles:[localization localizedStringForKey:@"Camera"],[localization localizedStringForKey:@"Photo Library"], nil];
    [alert show];

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
  
}

-(void)checkForPickedImage
{
    
    if (pickedImage == nil)
    {
        _viewPickedImageWidth.constant = 0;
        _btnCancel.hidden = YES;
        
    }
    else{
        
        _viewPickedImageWidth.constant = 40;
        _btnCancel.hidden = NO;
    }
    
}

- (IBAction)clickCancelImage:(id)sender
{
    pickedImage = nil;
    
    [self checkForPickedImage];
}

#pragma mark ------------ Image Picker Controller Delegate ------------------

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    
    if(image)
    {
        
        self.imgPickedimage.image =[mc scaleAndRotateImage:image];
        
        pickedImage = [mc scaleAndRotateImage:image];
        
        [self checkForPickedImage];
      
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)ResetComment
{
    [_txtviewComment setText:AddCommentPlaceHolder];
    [_txtviewComment setTextColor:[UIColor lightGrayColor]];
    
    [_txtviewComment.superview setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    pickedImage = nil;
    
    _viewPickedImageWidth.constant = 0;

    _txtviewComment.superview.frame = CGRectMake(0, ScreenSize.height-50, ScreenSize.width,50);

    
}

-(void)replyAdded:(NSDictionary *)response
{
    
    NSLog(@"%@",response);
    
    [self.view endEditing:YES];
    
    if ([[NSString stringWithFormat:@"%@",[response valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        [self clickCancelImage:self.btnCancel];
        
        DELEGATE.isEventEdited=YES;
        
        [self ResetComment];
        
        self.gettedReplies = [[NSMutableArray alloc]initWithArray:[response valueForKey:@"Reply"]];
        [self.tblComments reloadData];
        
        //[self.tblComments layoutIfNeeded];
        
        
//        [UIView animateWithDuration:0 animations:^
//        {
//           [self.tblComments reloadData];
//        } completion:^(BOOL finished) {
//            //Do something after that...
//            
//            [self.tblComments setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
//        }];
        
        
    
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

- (IBAction)clickCLose:(id)sender
{
    _viewTagTop.constant = -1500;
}
@end
